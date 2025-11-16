# 🏠 Application R Shiny — Analyse des DPE du Rhône (69)
**Projet : iut_sd2_rshiny_enedis**  
**BUT SD2 — Université Lyon 2 — Enedis**

---

## 🎯 Objectifs du projet
Cette application permet d’explorer les Diagnostics de Performance Énergétique (DPE) des logements du département du Rhône (code 69), en combinant :

- Les données de l’API ADEME (logements existants et neufs)
- Les coordonnées géographiques issues du fichier BAN `adresses-69.csv`
- Des analyses statistiques univariées et bivariées
- Une cartographie interactive
- L’export des données et des graphiques
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
