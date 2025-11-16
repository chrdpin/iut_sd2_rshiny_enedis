# 🔥 Application R Shiny — Analyse des DPE du Rhône (69)

Projet réalisé dans le cadre du BUT SD2 (IUT Lyon 2) — Module R Shiny.  
L’objectif est de construire une application complète permettant d’explorer les DPE (Diagnostics de Performance Énergétique) du département 69 à partir :

- de l’API ADEME (logements existants + logements neufs)
- du fichier `adresses-69.csv` contenant les coordonnées géographiques BAN

L’application intègre les **packs Standard + Intermédiaire + Expert** demandés dans le cahier des charges.

---

## 🚀 Fonctionnalités principales

### 🔹 **Pack Standard**
- Filtrage dynamique : code postal, type de logement, année
- Plusieurs KPI :  
  - Nombre de DPE  
  - Surface moyenne  
  - Part des classes A–C  
  - Dernière date de DPE
- Analyse statistique :
  - Histogrammes
  - Boxplots
  - Gestion automatique des outliers (p1–p99)
- Analyse bivariée :
  - Nuage de points
  - Régression linéaire simple
  - Corrélation de Pearson
- Cartographie interactive (Leaflet) :  
  - Markers individuels  
  - Agrégation par code postal  
- Export des données filtrées (.csv)
- Export des graphiques (.png)
- Application disponible en **dark mode**

---

### 🔹 **Pack Intermédiaire**
- Choix du thème via `themeSelector()`
- Sélection libre des variables X/Y pour l’analyse bivariée
- Gestion avancée des variables numériques

---

### 🔹 **Pack Expert**
- Authentification utilisateur via `shinymanager`
- Actualisation des données en direct via l’API ADEME (bouton “Rafraîchir les données”)
- Architecture propre + helpers + gestion outliers
- Jointure automatique entre coordonnées BAN ADEME et `adresses-69.csv`

---

## 📂 Structure du projet

Projet R Shiny/
-  app.R
- adresses-69.csv
- www/
  - images/
  - logo_app.png
  - logo_iut.png
- report/
- (rapport RMarkdown fourni séparément)

---

## 🛠️ Installation et lancement

### 1. Installer les packages nécessaires

```r
install.packages(c(
  "shiny", "shinythemes", "shinymanager", "leaflet", "DT",
  "ggplot2", "dplyr", "httr", "jsonlite", "plyr", "lubridate"
))
2. Placer adresses-69.csv et le dossier www/ dans le même répertoire que app.R.
3. Lancer l'application
r
Copier le code
shiny::runApp()
🔑 Authentification
L’accès à l’application est protégé par shinymanager.

Identifiants disponibles :

Utilisateur	Mot de passe
admin	admin
etudiant	iut69

🌍 Déploiement shinyapps.io
Installer rsconnect :

r
Copier le code
install.packages("rsconnect")
Configurer votre compte :

r
Copier le code
rsconnect::setAccountInfo(
  name="VOTRE_NOM",
  token="VOTRE_TOKEN",
  secret="VOTRE_SECRET"
)
Déployer l'app :

r
Copier le code
rsconnect::deployApp()
L’application sera accessible via :

arduino
Copier le code
https://votre_nom.shinyapps.io/iut_sd2_rshiny_enedis/
📌 Sources des données
🔹 API ADEME — DPE Logements existants
https://data.ademe.fr/datasets/dpe03existant

🔹 API ADEME — DPE Logements neufs
https://data.ademe.fr/datasets/dpe02neuf

🔹 Coordonnées géographiques BAN
Fichier local adresses-69.csv

👤 Auteur
Arthur Mallière
BUT Science des Données — IUT Lumière Lyon 2
2024–2025

🧩 Remarques
Le rapport RMarkdown n’est pas généré automatiquement dans l’app : il est fourni séparément.

L’application charge automatiquement les données via l’API au démarrage.

Les coordonnées ADEME sont jointes avec adresses-69.csv pour permettre l’affichage sur Leaflet.

yaml
Copier le code

---

# ✔️ Le README est :
- **Stylé**
- **Clair**
- **Court**
- **Parfait pour GitHub**
- **100% fidèle à TON appli**
- **Sans texte inutile**

---

Si tu veux la **version courte**, la **version pro entreprise**, ou une **version 100% emojis**, je te la génère en 30 secondes.





