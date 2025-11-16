# Application R Shiny — Analyse des DPE du Rhône (69)

Projet réalisé dans le cadre du BUT SD2 (IUT Lyon 2) — Module R Shiny.  
L’objectif est de construire une application complète permettant d’explorer les DPE (Diagnostics de Performance Énergétique) du département 69 à partir :

- de l’API ADEME (logements existants + logements neufs)
- du fichier `adresses-69.csv` contenant les coordonnées géographiques BAN

L’application intègre les packs **Standard**, **Intermédiaire** et **Expert** demandés dans le cahier des charges.

---

## Fonctionnalités principales

### Pack Standard

- Filtrage dynamique :
  - Code postal
  - Type de logement (Existant / Neuf / Tous)
  - Année de construction
- KPI :
  - Nombre total de DPE
  - Surface habitable moyenne
  - Part des étiquettes A–C
  - Dernière date de DPE
- Analyses statistiques :
  - Histogrammes (avec gestion des outliers via trimming p1–p99)
  - Boxplots par type de logement
  - Répartition des étiquettes DPE
- Analyse bivariée :
  - Nuage de points
  - Régression linéaire simple
  - Coefficient de corrélation de Pearson
- Cartographie interactive (Leaflet) :
  - Markers individuels géolocalisés
  - Agrégation par code postal
- Export :
  - Export des données filtrées au format `.csv`
  - Export des graphiques au format `.png`
- Interface :
  - Application disponible en dark mode (thème `cyborg` de `shinythemes`)

---

### Pack Intermédiaire

- Choix du thème de l’application via `themeSelector()`
- Sélection libre des variables X et Y pour l’analyse bivariée
- Export des graphiques (histogrammes, boxplots, nuages de points) au format `.png`

---

### Pack Expert

- Authentification utilisateur via `shinymanager` :
  - Utilisateur : `admin` / Mot de passe : `admin`
  - Utilisateur : `etudiant` / Mot de passe : `iut69`
- Actualisation des données en direct via l’API ADEME (bouton « Rafraîchir les données »)
- Architecture factorisée avec :
  - Helpers pour le thème dark ggplot2
  - Fonction de gestion des outliers (trimming p1–p99)
  - Fonctions dédiées pour l’API : logements existants et neufs
- Jointure automatique entre :
  - Coordonnées ADEME (`coordonnee_cartographique_x_ban`, `coordonnee_cartographique_y_ban`)
  - Coordonnées BAN issues de `adresses-69.csv` (`x`, `y`, `lon`, `lat`)

---

## Structure du projet

```text
Projet R Shiny/
│
├── app.R
├── adresses-69.csv
│
└── www/
    └── images/
         ├── logo_app.png
         └── logo_iut.png
