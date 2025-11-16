# Application R Shiny — Analyse des DPE du Rhône (69)

Projet réalisé dans le cadre du BUT SD2 (IUT Lyon 2) — Module R Shiny.  
L’objectif est de construire une application complète permettant d’explorer les DPE (Diagnostics de Performance Énergétique) du département 69 à partir :

- de l’API ADEME (logements existants + logements neufs)
- du fichier `adresses-69.csv` contenant les coordonnées géographiques BAN

L’application intègre les packs **Standard**, **Intermédiaire** et **Expert** demandés dans le cahier des charges.

Lien de l'application : https://chrdpin.shinyapps.io/projet_r_shiny/

---

## Table des matières

- [À propos du projet](#à-propos-du-projet)
- [Objectifs de l’application](#objectifs-de-lapplication)
- [Fonctionnalités principales](#fonctionnalités-principales)
  - [Pack Standard](#pack-standard)
  - [Pack Intermédiaire](#pack-intermédiaire)
  - [Pack Expert](#pack-expert)
- [Structure du projet](#structure-du-projet)
- [Installation](#installation)
- [Déploiement sur shinyapps.io](#déploiement-sur-shinyappsio)
- [Auteur](#auteur)

---

## À propos du projet

Ce projet s’inscrit dans le cadre du module R Shiny du BUT Science des Données (IUT Lyon 2).  
L’application développe un **observatoire des DPE du département du Rhône (69)** en s’appuyant sur :

- les données ouvertes de l’ADEME (DPE logements existants et neufs)
- les coordonnées géographiques issues du fichier `adresses-69.csv` (Base Adresse Nationale)

L’objectif n’est pas uniquement de visualiser des données, mais de proposer un **tableau de bord interactif complet**, combinant :

- indicateurs de synthèse (**KPI**),
- analyses statistiques univariées et bivariées,
- analyses énergie / coûts / émissions de GES,
- cartographie interactive,
- capacités d’export et de mise à jour automatique via API,
- authentification et dark mode.

---

## Objectifs de l’application

L’application a pour but de fournir un **outil d’analyse et de visualisation** des DPE à l’échelle du département 69, utilisable aussi bien dans un cadre pédagogique que pour une première exploration métier.

Plus précisément, elle vise à :

1. **Explorer la performance énergétique des logements**
   - Visualiser la répartition des étiquettes DPE (A à G) et des étiquettes GES.
   - Mettre en évidence la part des logements considérés comme “performants” (A–C) ou “moins performants”.
   - Observer la distribution des surfaces habitables et des années / périodes de construction.

2. **Analyser l’impact de différentes variables**
   - Étudier le lien entre **surface habitable** et **année / période de construction**.
   - Analyser l’influence de la **zone climatique**, de la **classe d’altitude** et des **types d’énergie** (chauffage / ECS).
   - Étudier les **coûts énergétiques** (`cout_total_5_usages`, `cout_chauffage`, `cout_ecs`, etc.) et les **émissions de GES** (`emission_ges_5_usages`, `emission_ges_5_usages_par_m2`).
   - Permettre à l’utilisateur de choisir librement les variables X et Y pour réaliser une **analyse bivariée** (nuage de points + régression).

3. **Analyser la qualité de l’enveloppe et du confort**
   - Exploiter les indicateurs de **qualité d’isolation** (`qualite_isolation_murs`, `qualite_isolation_plancher_bas`, `isolation_toiture`, `qualite_isolation_enveloppe`).
   - Prendre en compte l’**inertie du bâtiment** (`inertie_lourde`) et l’**indicateur de confort d’été** (`indicateur_confort_ete`).
   - Relier ces éléments aux consommations et aux étiquettes DPE / GES.

4. **Proposer une vision territoriale des DPE**
   - Cartographier les logements (ou agrégations par code postal) grâce à une jointure entre :
     - les coordonnées X/Y fournies par l’API ADEME ;
     - les coordonnées géographiques `lon` / `lat` présentes dans `adresses-69.csv`.
   - Identifier les zones avec forte concentration de DPE filtrés (par type de logement, code postal, etc.).

5. **Offrir une expérience interactive et reproductible**
   - Permettre le **filtrage dynamique** des données (code postal, type de logement, année).
   - Mettre à disposition des **exports CSV** des données filtrées et des **exports PNG** de l’ensemble des graphiques.
   - Assurer une mise à jour des données via l’**API ADEME** (bouton dédié), pour que l’application puisse être réutilisée sans modifications majeures.

6. **Respecter un cahier des charges “Pack” complet**
   - Intégrer l’ensemble des exigences des packs Standard, Intermédiaire et Expert (KPI, cartes, filtres, exports, login, API, dark mode, etc.).
   - Servir de démonstration d’une application Shiny **structurée** (architecture claire, helpers, gestion des outliers, authentification, etc.).

---

## Fonctionnalités principales

### Pack Standard

- **Filtrage dynamique** :
  - Code postal (à partir de `adresses-69.csv`)
  - Type de logement (Existant / Neuf / Tous)
  - Année de construction (slider)
- **KPI** :
  - Nombre total de DPE filtrés
  - Surface habitable moyenne
  - Part des étiquettes A–C
  - Dernière date de DPE (existants + neufs)
- **Analyses statistiques univariées** :
  - Histogrammes (avec gestion des outliers via trimming p1–p99)
  - Boxplots par type de logement (Existant / Neuf)
  - Distribution des étiquettes DPE
  - Histogrammes et indicateurs sur :
    - surface habitable,
    - coûts (`cout_total_5_usages`, `cout_chauffage`, etc.),
    - consommations (`conso_5_usages_par_m2_ep`, `conso_5_usages_par_m2_ef`),
    - émissions de GES (`emission_ges_5_usages`, `emission_ges_5_usages_par_m2`).

- **Analyses bivariées** :
  - Nuage de points (variables X / Y choisies parmi les variables numériques principales)
  - Régression linéaire simple
  - Coefficient de corrélation de Pearson
  - Exemples de couples possibles :
    - `annee_construction` vs `conso_5_usages_par_m2_ep`
    - `surface_habitable_logement` vs `cout_total_5_usages`
    - `conso_5_usages_par_m2_ef` vs `emission_ges_5_usages_par_m2`

- **Analyses énergie / coûts (selon l’implémentation retenue dans l’UI)** :
  - Coûts par étiquette DPE (boxplots)
  - Consommations par type d’énergie principale (chauffage / ECS)
  - Comparaison existant vs neuf sur les coûts et consommations.

- **Cartographie interactive (Leaflet)** :
  - Markers individuels géolocalisés (niveau DPE)
  - Agrégation par code postal (centroïdes + nombre de DPE)
  - Fond de carte sombre (providers `CartoDB.DarkMatter`)

- **Export** :
  - Export des données filtrées au format `.csv`
  - Export de tous les graphiques principaux au format `.png` :
    - histogrammes
    - boxplots
    - nuages de points + droite de régression
    - graphiques énergie / coûts (si activés)

- **Interface** :
  - Application disponible en **dark mode** (thème `cyborg` de `shinythemes`)

---

### Pack Intermédiaire

- Choix du **thème de l’application** via `themeSelector()`
- Sélection libre des **variables X et Y** pour l’analyse bivariée
- Export des graphiques (histogrammes, boxplots, nuages de points, graphiques énergie / coûts) au format `.png`
- Gestion des variables numériques avec **filtrage des outliers** (p1–p99) pour éviter les graphiques aberrants.

---

### Pack Expert

- **Authentification utilisateur** via `shinymanager` :
  - Utilisateur : `admin` / Mot de passe : `admin`
  - Utilisateur : `etudiant` / Mot de passe : `iut69`
- **Actualisation des données en direct** via l’API ADEME (bouton « Rafraîchir les données »)
- Architecture factorisée avec :
  - helper pour le thème dark ggplot2 (`theme_app_dark`)
  - fonction de gestion des outliers (trimming p1–p99)
  - fonctions dédiées de récupération API pour :
    - DPE logements **existants** (`dpe03existant`)
    - DPE logements **neufs** (`dpe02neuf`)
- **Jointure automatique** entre :
  - coordonnées ADEME (`coordonnee_cartographique_x_ban`, `coordonnee_cartographique_y_ban`)
  - coordonnées BAN issues de `adresses-69.csv` (`x`, `y`, `lon`, `lat`)
- Application prête à être **déployée sur shinyapps.io** (un seul fichier `app.R` + ressources `www/`).

---

## Structure du projet

```text
Projet R Shiny/
│
├── app.R              # Application Shiny (UI + server + appels API)
├── adresses-69.csv    # Fichier des adresses géocodées (BAN) pour le Rhône
│
└── www/
    └── images/
         ├── logo_app.png   # Logo de l'application
         └── logo_iut.png   # Logo de l'IUT
