# Application R Shiny — Analyse des DPE du Rhône (69)

Projet réalisé dans le cadre du BUT SD2 (IUT Lyon 2) — Module R Shiny.  
L’objectif est de construire une application complète permettant d’explorer les DPE (Diagnostics de Performance Énergétique) du département 69 à partir :

- de l’API ADEME (logements existants + logements neufs)
- du fichier `adresses-69.csv` contenant les coordonnées géographiques BAN

L’application intègre les packs **Standard**, **Intermédiaire** et **Expert** demandés dans le cahier des charges.

---

## Table des matières

- [À propos du projet](#à-propos-du-projet)
- [Objectifs de lapplication](#objectifs-de-lapplication)
- [Fonctionnalités principales](#fonctionnalités-principales)
  - [Pack Standard](#pack-standard)
  - [Pack Intermédiaire](#pack-intermédiaire)
  - [Pack Expert](#pack-expert)
- [Structure du projet](#structure-du-projet)
- [Installation](#installation)
- [Déploiement sur shinyappsio](#déploiement-sur-shinyappsio)
- [Auteur](#auteur)

---

## À propos du projet

Ce projet s’inscrit dans le cadre du module R Shiny du BUT Science des Données (IUT Lyon 2).  
L’application développe un **observatoire des DPE du département du Rhône (69)** en s’appuyant sur :

- les données ouvertes de l’ADEME (DPE logements existants et neufs)
- les coordonnées géographiques issues du fichier `adresses-69.csv` (Base Adresse Nationale)

L’objectif n’est pas uniquement de visualiser des données, mais de proposer un **tableau de bord interactif complet**, combinant :
- indicateurs de synthèse (KPI),
- analyses statistiques univariées et bivariées,
- cartographie interactive,
- capacités d’export et de mise à jour automatique via API.

---

## Objectifs de l’application

L’application a pour but de fournir un **outil d’analyse et de visualisation** des DPE à l’échelle du département 69, utilisable aussi bien dans un cadre pédagogique que pour une première exploration métier.

Plus précisément, elle vise à :

1. **Explorer la performance énergétique des logements**
   - Visualiser la répartition des étiquettes DPE (A à G).
   - Mettre en évidence la part des logements considérés comme “performants” (A–C) ou “moins performants”.
   - Observer la distribution des surfaces habitables et des années de construction.

2. **Analyser l’impact de différentes variables**
   - Étudier le lien entre la surface habitable et l’année de construction.
   - Permettre à l’utilisateur de choisir librement les variables X et Y pour réaliser une analyse bivariée.
   - Fournir des outils de **corrélation** et de **régression linéaire simple** pour quantifier les relations observées.

3. **Proposer une vision territoriale des DPE**
   - Cartographier les logements (ou agrégations par code postal) grâce à une jointure entre :
     - les coordonnées X/Y fournies par l’API ADEME ;
     - les coordonnées géographiques `lon` / `lat` présentes dans `adresses-69.csv`.
   - Identifier les zones avec forte concentration de DPE filtrés (par type de logement, code postal, etc.).

4. **Offrir une expérience interactive et reproductible**
   - Permettre le filtrage dynamique des données (code postal, type de logement, année).
   - Mettre à disposition des exports CSV des données filtrées et des exports PNG des graphiques.
   - Assurer une mise à jour des données via l’API ADEME (bouton dédié), pour que l’application puisse être réutilisée sans modifications majeures.

5. **Respecter un cahier des charges “Pack” complet**
   - Intégrer l’ensemble des exigences des packs Standard, Intermédiaire et Expert (KPI, cartes, filtres, exports, login, API, dark mode, etc.).
   - Servir de démonstration d’une application Shiny structurée (architecture claire, helpers, gestion des outliers, authentification, etc.).

---

## Fonctionnalités principales

### Pack Standard

- **Filtrage dynamique** :
  - Code postal
  - Type de logement (Existant / Neuf / Tous)
  - Année de construction
- **KPI** :
  - Nombre total de DPE
  - Surface habitable moyenne
  - Part des étiquettes A–C
  - Dernière date de DPE
- **Analyses statistiques** :
  - Histogrammes (avec gestion des outliers via trimming p1–p99)
  - Boxplots par type de logement
  - Répartition des étiquettes DPE
- **Analyse bivariée** :
  - Nuage de points
  - Régression linéaire simple
  - Coefficient de corrélation de Pearson
- **Cartographie interactive (Leaflet)** :
  - Markers individuels géolocalisés
  - Agrégation par code postal
- **Export** :
  - Export des données filtrées au format `.csv`
  - Export des graphiques au format `.png`
- **Interface** :
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
