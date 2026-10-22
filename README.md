# MIAGED

Application Flutter d'inscription à des activités (TP2 – MIAGE IA2), avec Firebase Cloud Firestore.

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
| US#6 Ajouter une nouvelle activité (IA) | Réalisée sur Android (voir ci-dessous) |

- **Login** : le login est l'identifiant du document `users/{login}` ; le password est comparé à celui stocké. Champs vides ou utilisateur inconnu : message dans la console (`debugPrint`) et à l'écran, l'application reste utilisable.
- **Activités / panier** : lus en temps réel (`snapshots()`), donc le panier et son total se mettent à jour dès qu'une activité est ajoutée ou retirée.
- **Profil** : login en lecture seule, password masqué, code postal limité aux chiffres (clavier numérique). « Valider » enregistre en base, « Se déconnecter » revient au login.

## US#6 : catégorie détectée par l'IA

À l'ajout d'une activité (bouton « Ajouter une activité » du profil), la catégorie n'est pas saisie : elle est déduite de l'image avec **Google ML Kit Image Labeling** (`google_mlkit_image_labeling`).

- Le modèle de base est embarqué dans l'application et s'exécute sur le téléphone : ni connexion, ni clé d'API, ni coût.
- ML Kit renvoie des étiquettes (« Kayak », « Food », « Museum »…) avec un score de confiance. L'application garde celles au-dessus de 0,5, de la plus probable à la moins probable, et prend la catégorie de la première étiquette connue : **Sport, Shopping, Gastronomie, Culture, Nature**, sinon **Autre** (table dans `lib/services/image_classifier.dart`).
- Les étiquettes détectées sont affichées dans la console (`ML Kit : …`).
- ML Kit n'existe que sur Android/iOS : sur le web, la catégorie vaut toujours « Autre ».

Images de test : les photos des activités de démo (liens dans `tool/seed.json`, Wikimedia Commons). Par exemple, le kayak donne « Sport », la socca « Gastronomie », le lac d'Allos « Nature ».

Sur un émulateur Android, il suffit de glisser une image sur la fenêtre de l'émulateur pour l'ajouter à sa galerie.

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
  main.dart                       initialisation Firebase, thème
  models/activity.dart            modèle Activity (lecture/écriture Firestore)
  services/db.dart                références des collections Firestore
  services/image_classifier.dart  IA : ML Kit → catégorie
  widgets/activity_image.dart     affichage d'une image (URL ou base64)
  pages/                          une page par écran (login, accueil, activités, détail, panier, profil, ajout)
test/activity_test.dart           tests du modèle et du choix de catégorie
tool/setup.ps1                    installation complète (Flutter, Firebase, données de démo)
tool/seed.json                    données de démo : 2 utilisateurs, 8 activités
firestore.rules                   règles de sécurité Firestore
```

## Lancer l'application

```powershell
flutter pub get
flutter run -d chrome     # ou sur un émulateur / téléphone Android (nécessaire pour l'IA)
flutter test
```

Pour recréer l'environnement Firebase de zéro sur un autre compte (nouveau projet Firebase, base, règles, données de démo) : supprimer `.firebaserc` et `lib/firebase_options.dart`, puis lancer
`powershell -ExecutionPolicy Bypass -File tool\setup.ps1`

## Limites connues

- Le TP impose une connexion « maison » sans Firebase Authentication. Les passwords sont donc stockés en clair, comme dans le modèle fourni, et les règles Firestore ne peuvent pas restreindre l'accès par utilisateur : la base est ouverte en lecture/écriture.
- L'IA (US#6) ne fonctionne pas sur le web (ML Kit n'y est pas disponible).
