# MIAGED

Application Flutter d'inscription à des activités (TP2 – MIAGE IA2), avec Firebase Cloud Firestore. Elle fonctionne sur Android et dans le navigateur (Chrome).

## Utilisateurs de test

| Login | Password |
|-------|----------|
| user1 | password1 |
| user2 | password2 |

## Fonctionnalités

| User Story | Statut |
|------------|--------|
| US#1 [MVP] Interface de login | Réalisée |
| US#2 [MVP] Liste des activités | Réalisée |
| US#3 [MVP] Détail d'une activité | Réalisée |
| US#4 [MVP] Le panier | Réalisée |
| US#5 [MVP] Profil utilisateur | Réalisée |
| US#6 Ajouter une nouvelle activité (IA) | Réalisée (ML Kit sur Android, MobileNet sur le web) |

- **Login** : le login est l'identifiant du document `users/{login}` ; le password est comparé à celui stocké. Champs vides ou utilisateur inconnu : message dans la console (`debugPrint`) et à l'écran, l'application reste utilisable.
- **Activités / panier** : lus en temps réel (`snapshots()`), donc le panier et son total se mettent à jour dès qu'une activité est ajoutée ou retirée.
- **Profil** : login en lecture seule, password masqué, code postal limité aux chiffres (clavier numérique). « Valider » enregistre en base, « Se déconnecter » revient au login.
- **Ajout d'une activité** : depuis le profil ; image, titre, catégorie (non éditable, remplie par l'IA), lieu, nombre de personnes maximum et prix (chiffres uniquement). « Valider » enregistre en base.

## US#6 : catégorie détectée par l'IA

À l'ajout d'une activité, la catégorie n'est pas saisie : dès que l'image est choisie, l'IA la reconnaît et la catégorie se remplit dans un champ non éditable. Deux moteurs sont utilisés selon la plateforme, avec la même règle de choix :

| Plateforme | Moteur | Fonctionnement |
|------------|--------|----------------|
| Android (téléphone, émulateur) | **Google ML Kit Image Labeling** (`google_mlkit_image_labeling`) | Modèle embarqué dans l'application, exécuté sur le téléphone : ni connexion, ni clé d'API, ni coût. ~400 étiquettes (« Kayak », « Food », « Museum »…), conservées au-dessus de 50 % de confiance. |
| Web (Chrome) | **MobileNet via TensorFlow.js** | ML Kit n'existe pas sur le web. Le modèle (1 000 classes ImageNet : « canoe », « palace », « dough »…) est téléchargé à la première analyse puis gardé en mémoire (`web/ai_classifier.js`, appelé depuis Dart par `dart:js_interop`). |

**Règle de choix** (`lib/services/image_classifier.dart`) :

- Chaque étiquette utile est rattachée à une catégorie : **Sport, Shopping, Gastronomie, Culture, Nature**. Pour ML Kit, par une table d'étiquettes ; pour MobileNet, par mots-clés comparés mot à mot (« skillet » n'est pas pris pour « ski »).
- Les étiquettes trop générales (« Sky », « Rock », « Plant »), présentes sur presque toutes les photos d'extérieur, sont ignorées.
- La catégorie retenue est celle dont les étiquettes **cumulent la plus forte confiance** : une photo de repas reconnue « Food » + « Bread » l'emporte sur un « Statue » isolé en arrière-plan. Aucune étiquette reconnue → **Autre**.
- Les étiquettes reconnues et leur confiance sont écrites dans la console (`ML Kit : … → Sport`, ou `MobileNet : … → Sport` sur le web), ce qui permet de vérifier le choix de l'IA.
- La règle est testée unitairement (`test/activity_test.dart`), y compris avec les résultats réels de MobileNet ci-dessous.

### Images utilisées pour tester l'IA

Les photos des activités de démo (liens dans `tool/seed.json`, Wikimedia Commons), plus une photo de sacs de courses. Résultats mesurés avec MobileNet :

| Photo | MobileNet reconnaît | Catégorie |
|-------|---------------------|-----------|
| Kayak | canoe 61 %, paddle 34 % | Sport |
| Plongée | scuba diver 67 %, snorkel 20 % | Sport |
| Socca | dough 41 %, frying pan 33 % | Gastronomie |
| Lac d'Allos | lakeside 54 %, valley 21 %, alp 16 % | Nature |
| Musée Matisse | palace 76 %, monastery 13 % | Culture |
| Sacs de courses | plastic bag 91 % | Shopping |

Sur un émulateur Android, il suffit de glisser une image sur la fenêtre de l'émulateur pour l'ajouter à sa galerie. Dans Chrome, « Choisir une image » ouvre l'explorateur de fichiers.

## Design

- **Charte** (`lib/theme.dart`) : sarcelle des maquettes du TP, bleu nuit pour les textes, corail pour les prix, fond sable, une couleur par catégorie ; police **Poppins** embarquée (`fonts/`, licence SIL OFL) ; Material 3, interface en français (calendrier, infobulles).
- **Connexion** : en-tête en dégradé terminé par une vague, formulaire dans une carte qui le chevauche.
- **Activités** : cartes photo avec titre et lieu sur un dégradé, catégorie et prix en pastilles ; une colonne sur téléphone, jusqu'à trois sur tablette ; les photos apparaissent en fondu.
- **Détail** : grande photo qui se replie au défilement, animée depuis la liste (Hero), informations en tuiles, boutons fixés en bas.
- **Panier** : badge du nombre d'activités sur l'onglet, total dans une barre sombre, écran « panier vide ».
- **Profil** : carte d'en-tête avec l'initiale du login, champs regroupés par section, calendrier pour l'anniversaire, password affichable à la demande.
- **Icône** de l'application (Android, icône adaptative comprise, et web) : soleil couchant sur la mer, aux couleurs de l'app.
- Messages d'erreur et de confirmation en bas d'écran, indicateurs de chargement.

## Modèle de données (Firestore)

```
users/{login}                   password, birthday, address, postalCode, city
users/{login}/cart/{activityId} copie de l'activité ajoutée au panier
activities/{id}                 title, category, location, price, maxPeople, image
```

`image` est une URL pour les activités de démo, et l'image encodée en base64 pour les activités ajoutées depuis l'application. Firebase Storage demande désormais le forfait payant Blaze ; l'image est donc réduite (800 px max) et stockée directement dans le document.

## Organisation du code

```
lib/
  main.dart                          initialisation Firebase, localisation
  theme.dart                         thème de l'application
  models/activity.dart               modèle Activity (lecture/écriture Firestore)
  services/db.dart                   références des collections Firestore
  services/image_classifier.dart     IA : choix du moteur et de la catégorie
  services/web_classifier_web.dart   pont Dart → TensorFlow.js (version web)
  services/web_classifier_stub.dart  remplaçant hors web (ML Kit est utilisé)
  utils/date_format.dart             dates JJ/MM/AAAA
  widgets/                           composants réutilisés (carte, image, catégorie, password, section, barre du bas, mise en page)
  pages/                             une page par écran (login, accueil, activités, détail, panier, profil, ajout)
fonts/                               police Poppins (licence SIL OFL)
web/ai_classifier.js                 chargement de MobileNet et classification dans le navigateur
test/                                tests du modèle, de l'IA, des dates et de la page de login
tool/setup.ps1                       installation complète (Flutter, Firebase, données de démo)
tool/seed.json                       données de démo : 2 utilisateurs, 8 activités
firestore.rules                      règles de sécurité Firestore
```

## Lancer l'application

```powershell
flutter pub get
flutter run -d chrome     # web : IA avec MobileNet
flutter run               # émulateur ou téléphone Android : IA avec ML Kit
flutter test
```

Pour recréer l'environnement Firebase de zéro sur un autre compte (nouveau projet Firebase, base, règles, données de démo) : supprimer `.firebaserc` et `lib/firebase_options.dart`, puis lancer
`powershell -ExecutionPolicy Bypass -File tool\setup.ps1`

## Limites connues

- Le TP impose une connexion « maison » sans Firebase Authentication. Les passwords sont donc stockés en clair, comme dans le modèle fourni, et les règles Firestore ne peuvent pas restreindre l'accès par utilisateur : la base est ouverte en lecture/écriture.
- Sur le web, l'IA a besoin d'Internet à la première analyse (téléchargement de TensorFlow.js et de MobileNet). Sur Android, ML Kit fonctionne hors ligne.
