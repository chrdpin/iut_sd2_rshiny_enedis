
- La mise à jour automatique des données via l’API

---

## 🚀 Fonctionnalités principales
### 🔹 Pack Standard
- Interface moderne en dark mode (thème *cyborg*)
- 3 onglets d’analyse + contexte + carte + export
- Filtres dynamiques : code postal, type de logement, année de construction
- KPI : nombre de DPE, surface moyenne, part des classes A–C, dernière date
- Analyse univariée :
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
- Export :
  - Données filtrées (.csv)
  - Graphiques (.png)

### 🔹 Pack Intermédiaire
- Choix du thème Shiny (sélecteur interactif)
- Export PNG pour chaque graphique
- Sélection libre des variables X/Y pour corrélation et régression

### 🔹 Pack Expert
- Système de connexion utilisateur (shinymanager)
- Actualisation des données via l’API ADEME
- Architecture propre + helpers + gestion avancée des données

---

## 📁 Structure du projet

Projet R Shiny/
│
├─ app.R
├─ adresses-69.csv
│
├─ www/
│ └─ images/
│ ├─ logo_app.png
│ └─ logo_iut.png
│
└─ report/
└─ (rapport RMarkdown fourni séparément)

powershell
Copier le code

---

## 🔧 Installation locale

### 1. Prérequis
Installer R et RStudio, puis les packages :

```r
install.packages(c(
  "shiny", "shinythemes", "shinymanager", "leaflet", "DT",
  "ggplot2", "dplyr", "httr", "jsonlite", "plyr", "lubridate"
))
