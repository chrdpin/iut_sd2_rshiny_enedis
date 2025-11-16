








# 🔥 Application R Shiny — Analyse des DPE du Rhône (69)

Projet réalisé dans le cadre du BUT SD2 (IUT Lyon 2) — Module R Shiny.  
Cette application permet d’explorer les Diagnostics de Performance Énergétique (DPE) du département du Rhône (69) en utilisant les données de l’API ADEME et les coordonnées géographiques du fichier `adresses-69.csv`.

---

## 🚀 Fonctionnalités principales

### 🔹 Pack Standard
- Filtres : code postal, type de logement, années.
- 4 KPI dynamiques :
  - Nombre de DPE  
  - Surface moyenne  
  - Part des classes A–C  
  - Dernière date de DPE
- Analyses :
  - Histogramme (sans outliers p1–p99)
  - Boxplot (sans outliers)
  - Répartition des étiquettes DPE
- Analyse bivariée :
  - Nuage de points
  - Régression linéaire simple
  - Corrélation de Pearson
- Cartographie Leaflet :
  - Markers individuels
  - Agrégation par code postal
- Exports :
  - Export des données filtrées (.csv)
  - Export PNG des graphiques
- Dark mode intégré par défaut

---

### 🔹 Pack Intermédiaire
- Choix du thème via `themeSelector()`
- Sélection libre des variables X/Y
- Export PNG des graphiques

---

### 🔹 Pack Expert
- Connexion sécurisée via `shinymanager`
- Actualisation des données via l’API ADEME
- Jointure automatique des coordonnées BAN avec `adresses-69.csv`
- Architecture propre + helpers + gestion avancée des outliers

---

## 📁 Structure du projet

Projet R Shiny/
-  app.R
- adresses-69.csv
- www/
  - images/
  - logo_app.png
  - logo_iut.png
- report/
- (rapport RMarkdown fourni séparément)

css
Copier le code

---

## 🛠️ Installation et lancement

1. Installer les packages nécessaires :

```r
install.packages(c(
  "shiny", "shinythemes", "shinymanager", "leaflet", "DT",
  "ggplot2", "dplyr", "httr", "jsonlite", "plyr", "lubridate"
))
Placer adresses-69.csv et le dossier www/images au même endroit que app.R.

Lancer l'application :

r
Copier le code
shiny::runApp()
🔑 Authentification
L’accès est protégé.

Utilisateur	Mot de passe
admin	admin
etudiant	iut69

🌍 Déploiement sur shinyapps.io
Installer :

r
Copier le code
install.packages("rsconnect")
Configurer :

r
Copier le code
rsconnect::setAccountInfo(
  name="VOTRE_NOM",
  token="VOTRE_TOKEN",
  secret="VOTRE_SECRET"
)
Déployer :

r
Copier le code
rsconnect::deployApp()
URL finale :
https://votre_nom.shinyapps.io/iut_sd2_rshiny_enedis/

📌 Sources de données
API ADEME — DPE existants :
https://data.ademe.fr/datasets/dpe03existant

API ADEME — DPE neufs :
https://data.ademe.fr/datasets/dpe02neuf

Coordonnées BAN :
fichier local adresses-69.csv

👤 Auteur
Arthur Mallière
BUT Science des Données — IUT Lumière Lyon 2
Année 2024–2025

📝 Remarques
Le rapport RMarkdown n'est pas généré dans l'application (fourni séparément).

L’application charge automatiquement les données via l’API au démarrage.

Les coordonnées BAN ADEME sont jointes avec adresses-69.csv pour activer la carte.






