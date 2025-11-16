OBSERVATOIRE DPE – DÉPARTEMENT DU RHÔNE (69)

Tableau de bord interactif pour analyser et visualiser les Diagnostics de Performance Énergétique (DPE) des logements du département du Rhône à partir des données de l’ADEME.

Table des Matières

À Propos

Fonctionnalités

Démo

Installation

Utilisation

Architecture

Technologies

Documentation

Contributeurs

À Propos
Contexte du Projet

Cette application Shiny a été développée dans le cadre d’un projet universitaire (BUT SD2 – IUT Lyon 2) autour de l’analyse des DPE du département du Rhône, en partenariat pédagogique avec Enedis.

L’outil permet d’explorer les performances énergétiques des logements (existants et neufs), de visualiser les étiquettes DPE, de repérer d’éventuelles anomalies, de réaliser des analyses statistiques et d’afficher une cartographie interactive basée sur les coordonnées BAN du fichier adresses-69.csv.

Objectifs

L’application vise à :

Visualiser la répartition des étiquettes énergétiques du Rhône (69).

Identifier les classes énergétiques favorables (A–C) et défavorables (E–G).

Étudier :

Surface habitable

Année de construction

Types de logements

Analyser la relation entre deux variables numériques (corrélation + régression).

Cartographier les logements à l’aide d’une jointure BAN (coordonnées X/Y → latitude/longitude).

Permettre une mise à jour automatique via l’API ADEME.

Exporter facilement les graphiques et les données filtrées.

Source des Données

Les données proviennent de l’ADEME :

API DPE v2 – Logements existants

API DPE v2 – Logements neufs

Les coordonnées géographiques proviennent du fichier local :

adresses-69.csv (BAN – Base Adresse Nationale)

Fonctionnalités
Niveau Standard

Tableau de bord complet avec plusieurs onglets thématiques

Interface en dark mode (thème cyborg)

4 KPI dynamiques :

Nombre total de DPE

Surface habitable moyenne

Part des étiquettes A–C

Dernière date de DPE

4 graphes statistiques :

Histogramme

Barplot

Boxplot

Nuage de points

Gestion automatique des outliers (p1–p99) pour éviter les valeurs aberrantes

Carte interactive Leaflet :

Markers individuels

Agrégation par code postal

Filtres multi-critères :

Code postal

Type de logement (existant / neuf)

Année de construction

Niveau Intermédiaire

Export des données filtrées (.csv)

Export des graphiques (.png)

Sélection libre de X et Y pour la régression

Régression linéaire simple + droite de tendance

Calcul du coefficient de corrélation

Niveau Expert

Authentification utilisateur (shinymanager)

Identifiant : admin / Mot de passe : admin

Identifiant : etudiant / Mot de passe : iut69

Mise à jour automatique des données via l’API ADEME

Jointure automatique coordonnées API → lat/lon via BAN

Charte visuelle dark intégrée

Démo
Application en Ligne

(à compléter après déploiement shinyapps.io)
Exemple :
URL : https://<ton_compte>.shinyapps.io/iut_sd2_rshiny_enedis/

Vidéo de Démonstration (optionnel)

(lien YouTube si tu fais une vidéo)

Installation
1. Installer les packages nécessaires
install.packages(c(
  "shiny", "shinythemes", "shinymanager", "leaflet", "DT",
  "ggplot2", "dplyr", "httr", "jsonlite", "plyr", "lubridate"
))

2. Placer les fichiers au bon endroit
Projet/
├── app.R
├── adresses-69.csv
└── www/
    └── images/
         ├── logo_app.png
         └── logo_iut.png

3. Lancer l’application
shiny::runApp()

Utilisation

Se connecter avec les identifiants fournis.

Choisir un code postal, un type de logement et une période de construction.

Explorer les KPI dynamiques.

Ouvrir les onglets d’analyse (univariée, bivariée).

Visualiser les logements sur la carte interactive.

Exporter les graphiques ou les données filtrées.

Architecture
iut_sd2_rshiny_enedis/
│
├── app.R                      # Application Shiny principale
│
├── www/
│   └── images/
│        ├── logo_app.png
│        └── logo_iut.png
│
└── adresses-69.csv            # Coordonnées BAN


Le script se compose de :

Helpers : thème dark + gestion outliers

Authentification utilisateur

Appels API ADEME (existant + neuf)

Jointure géographique BAN

Interface (UI)

Logique (server)

Export des données et graphiques

Technologies

R Shiny

Leaflet

DT

ggplot2

dplyr

shinythemes

shinymanager

API ADEME (DataFair)

Documentation
Document	Description
README.md	Vue d’ensemble du projet
doc_fonctionnelle.md	Documentation fonctionnelle (onglets, utilisation)
doc_technique.md	Architecture et logique interne
Contributeurs

Arthur Mallière – Développeur Shiny
BUT Science des Données — IUT Lyon 2

Encadrants / contexte :
Projet réalisé dans le cadre de l’enseignement R Shiny et du partenariat universitaire avec Enedis.












