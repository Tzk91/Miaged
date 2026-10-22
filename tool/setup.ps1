# Prepare le projet MIAGED : projet Flutter, dependances, projet Firebase,
# base Firestore (regles + donnees de demo), verification et depot git.
#
# A lancer depuis la racine du projet :
#   powershell -ExecutionPolicy Bypass -File tool\setup.ps1
# Il peut etre relance sans risque : les etapes deja faites sont sautees.

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

# Lance une commande externe et s'arrete si elle echoue.
function Run {
    $exe = $args[0]
    # Toujours un tableau : un argument seul (ex. "login") serait sinon eclate en caracteres.
    $rest = @($args | Select-Object -Skip 1)
    & $exe @rest
    if ($LASTEXITCODE) { throw "Echec de : $exe $rest" }
}

Write-Host '1/8 Projet Flutter' -ForegroundColor Cyan
if (-not (Test-Path android)) {
    Run flutter create . --project-name miaged --org fr.miage '--platforms=android,web'
    # Test du compteur genere par flutter create, sans rapport avec l'appli.
    Remove-Item test\widget_test.dart -ErrorAction SilentlyContinue
}

Write-Host '2/8 Dependances' -ForegroundColor Cyan
Run flutter pub add firebase_core cloud_firestore image_picker google_mlkit_image_labeling

Write-Host '3/8 Outils Firebase' -ForegroundColor Cyan
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    throw 'Node.js est requis : winget install OpenJS.NodeJS.LTS, puis relance ce script dans un nouveau terminal.'
}
# Dossier des commandes npm globales (firebase.cmd), pas toujours dans le PATH.
$env:Path += ';' + (npm.cmd prefix -g)
if (-not (Get-Command firebase.cmd -ErrorAction SilentlyContinue)) {
    Run npm.cmd install -g firebase-tools
}
Run firebase.cmd login
Run dart pub global activate flutterfire_cli

Write-Host '4/8 Projet Firebase' -ForegroundColor Cyan
if (Test-Path .firebaserc) {
    $project = (Get-Content .firebaserc -Raw | ConvertFrom-Json).projects.default
} else {
    $project = 'miaged-' + (Get-Random -Minimum 100000 -Maximum 999999)
    Run firebase.cmd projects:create $project --display-name MIAGED
    [IO.File]::WriteAllText("$PWD\.firebaserc", "{ `"projects`": { `"default`": `"$project`" } }")
}
Write-Host "   projet : $project"

Write-Host '5/8 Configuration FlutterFire (Android + web)' -ForegroundColor Cyan
if (-not (Test-Path lib\firebase_options.dart)) {
    Run dart pub global run flutterfire_cli:flutterfire configure "--project=$project" '--platforms=android,web' --yes
}

Write-Host '6/8 Base Firestore et regles' -ForegroundColor Cyan
$config = if (Test-Path firebase.json) { Get-Content firebase.json -Raw | ConvertFrom-Json } else { New-Object psobject }
if (-not $config.firestore) {
    # firebase deploy cree la base "(default)" a cet emplacement si elle n'existe pas.
    $config | Add-Member firestore ([pscustomobject]@{ rules = 'firestore.rules'; location = 'eur3' })
    [IO.File]::WriteAllText("$PWD\firebase.json", ($config | ConvertTo-Json -Depth 20))
}
Run firebase.cmd deploy --only firestore --project $project

Write-Host '7/8 Donnees de demo (2 utilisateurs, 8 activites)' -ForegroundColor Cyan
$options = Get-Content lib\firebase_options.dart -Raw
$apiKey = [regex]::Match($options, "web = FirebaseOptions\(\s*apiKey: '([^']+)'").Groups[1].Value
if (-not $apiKey) { throw 'Cle API web introuvable dans lib\firebase_options.dart' }
$base = "https://firestore.googleapis.com/v1/projects/$project/databases/(default)/documents"
$seed = Get-Content tool\seed.json -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($collection in $seed.PSObject.Properties) {
    foreach ($doc in $collection.Value.PSObject.Properties) {
        $fields = @{}
        foreach ($field in $doc.Value.PSObject.Properties) {
            $fields[$field.Name] = if ($field.Value -is [string]) { @{ stringValue = $field.Value } }
                                   else { @{ integerValue = "$($field.Value)" } }
        }
        $body = [Text.Encoding]::UTF8.GetBytes((@{ fields = $fields } | ConvertTo-Json -Depth 5))
        # PATCH = creation ou remplacement du document : relancer le script ne cree pas de doublon.
        for ($try = 1; ; $try++) {
            try {
                Invoke-RestMethod -Method Patch -Uri "$base/$($collection.Name)/$($doc.Name)?key=$apiKey" `
                    -Body $body -ContentType 'application/json; charset=utf-8' | Out-Null
                break
            } catch {
                # Une base et des regles toutes neuves mettent parfois quelques minutes a etre actives.
                if ($try -ge 18) { throw "Echec Firestore : $($_.ErrorDetails.Message)" }
                Write-Host "   base pas encore prete ($($_.Exception.Message)), nouvel essai dans 10 s"
                Start-Sleep -Seconds 10
            }
        }
        Write-Host "   $($collection.Name)/$($doc.Name)"
    }
}

Write-Host '8/8 Verification et depot git' -ForegroundColor Cyan
flutter analyze
flutter test
if (-not (Test-Path .git)) {
    git init -q
    git add -A
    git commit -q -m 'TP2 MIAGED : MVP (US#1 a US#5) et IA (US#6)'
}
Write-Host "Termine. Lance l'appli : flutter run -d chrome (ou sur un emulateur Android pour l'IA)" -ForegroundColor Green
