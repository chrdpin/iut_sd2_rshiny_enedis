# ===================================================================
#  Application Shiny DPE 69 - iut_sd2_rshiny_enedis
#  Version enrichie (plus de variables, plus de graphiques)
# ===================================================================

# -------------------------------------------------------------------
# 1. Packages
# -------------------------------------------------------------------
library(shiny)
library(shinythemes)
library(shinymanager)
library(leaflet)
library(DT)
library(ggplot2)
library(dplyr)
library(httr)
library(jsonlite)
library(plyr)
library(lubridate)

# Ressources statiques (images)
addResourcePath("img", "www/images")

# -------------------------------------------------------------------
# 2. Thème dark ggplot & gestion des outliers (p1–p99)
# -------------------------------------------------------------------

theme_app_dark <- function() {
  theme_minimal(base_family = "sans") +
    theme(
      plot.background  = element_rect(fill = "#222222", colour = NA),
      panel.background = element_rect(fill = "#222222", colour = NA),
      legend.background = element_rect(fill = "#222222", colour = NA),
      legend.key = element_rect(fill = "#222222", colour = NA),
      text       = element_text(colour = "white"),
      axis.text  = element_text(colour = "white"),
      axis.title = element_text(colour = "white"),
      plot.title = element_text(colour = "white", face = "bold")
    )
}

trim_var_for_plot <- function(df, var, probs = c(0.01, 0.99)) {
  if (!var %in% names(df)) return(list(df = df[0, ], limits = c(NA, NA)))
  
  num <- suppressWarnings(as.numeric(df[[var]]))
  if (all(is.na(num))) return(list(df = df[0, ], limits = c(NA, NA)))
  
  q <- quantile(num, probs = probs, na.rm = TRUE, names = FALSE)
  keep <- num >= q[1] & num <= q[2]
  
  list(df = df[keep | is.na(num), , drop = FALSE], limits = q)
}

# -------------------------------------------------------------------
# 3. Authentification (Pack Expert)
# -------------------------------------------------------------------

credentials <- data.frame(
  user = c("admin", "etudiant"),
  password = c("admin", "iut69"),
  stringsAsFactors = FALSE
)

# -------------------------------------------------------------------
# 4. Chargement adresses_69 + codes postaux
# -------------------------------------------------------------------

adresses_69 <- read.csv(
  "adresses-69.csv",
  header = TRUE, sep = ";", dec = ".", encoding = "latin1"
)

adresses_69$x   <- suppressWarnings(as.numeric(adresses_69$x))
adresses_69$y   <- suppressWarnings(as.numeric(adresses_69$y))
adresses_69$lon <- suppressWarnings(as.numeric(adresses_69$lon))
adresses_69$lat <- suppressWarnings(as.numeric(adresses_69$lat))

code_postaux <- sort(unique(adresses_69$code_postal))

# -------------------------------------------------------------------
# 5. Fonctions API ADEME (existants + neufs) avec champs enrichis
# -------------------------------------------------------------------

# Champs communs demandés
dpe_fields_common <- c(
  "numero_dpe",
  "date_reception_dpe",
  "date_etablissement_dpe",
  "date_visite_diagnostiqueur",
  "modele_dpe",
  "numero_dpe_remplace",
  "date_fin_validite_dpe",
  "version_dpe",
  "numero_dpe_immeuble_associe",
  "annee_construction",
  "type_batiment",
  "type_installation_chauffage",
  "type_installation_ecs",
  "periode_construction",
  "code_departement_ban",
  "code_insee_ban",
  "coordonnee_cartographique_x_ban",
  "coordonnee_cartographique_y_ban",
  "type_energie_principale_chauffage",
  "type_energie_principale_ecs",
  "cout_total_5_usages",
  "etiquette_dpe",
  "etiquette_ges",
  "classe_inertie_batiment",
  "cout_chauffage",
  "cout_ecs",
  "cout_refroidissement",
  "cout_eclairage",
  "code_postal_ban",
  "score_ban",
  "surface_habitable_logement",
  "conso_5_usages_par_m2_ep",
  "conso_5_usages_par_m2_ef",
  "conso_5_usages_ef",
  "conso_ecs_ep",
  "emission_ges_5_usages",
  "emission_ges_5_usages_par_m2",
  "qualite_isolation_murs",
  "qualite_isolation_plancher_bas",
  "qualite_isolation_enveloppe",
  "isolation_toiture",
  "inertie_lourde",
  "indicateur_confort_ete",
  "besoin_chauffage",
  "besoin_refroidissement",
  "besoin_ecs",
  "zone_climatique",
  "classe_altitude",
  "nom_commune_ban",
  "_geopoint"
)

dpe_fields_existant <- c(
  dpe_fields_common,
  "adresse_ban",
  "numero_voie_ban",
  "nom_rue_ban"
)

dpe_fields_neuf <- c(
  dpe_fields_common,
  "adresse_ban",
  "numero_voie_ban",
  "nom_rue_ban",
  "surface_habitable_immeuble"
)

# Colonnes numériques à convertir
numeric_cols_common <- c(
  "annee_construction",
  "surface_habitable_logement",
  "surface_habitable_immeuble",
  "coordonnee_cartographique_x_ban",
  "coordonnee_cartographique_y_ban",
  "cout_total_5_usages",
  "cout_chauffage",
  "cout_ecs",
  "cout_refroidissement",
  "cout_eclairage",
  "score_ban",
  "conso_5_usages_par_m2_ep",
  "conso_5_usages_par_m2_ef",
  "conso_5_usages_ef",
  "conso_ecs_ep",
  "emission_ges_5_usages",
  "emission_ges_5_usages_par_m2",
  "besoin_chauffage",
  "besoin_refroidissement",
  "besoin_ecs"
)

date_cols_common <- c(
  "date_reception_dpe",
  "date_etablissement_dpe",
  "date_visite_diagnostiqueur",
  "date_fin_validite_dpe"
)

fetch_dpe_existant <- function(codes) {
  df_final <- data.frame()
  base_url <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe03existant/lines"
  
  for (code_postal in codes) {
    params <- list(
      page = 1,
      size = 250,  # réduit pour limiter le volume par CP
      select = paste(dpe_fields_existant, collapse = ","),
      qs = paste0('code_postal_ban:"', code_postal, '"')
    )
    
    url_encoded <- modify_url(base_url, query = params)
    response <- GET(url_encoded)
    if (status_code(response) != 200) next
    
    content <- fromJSON(rawToChar(response$content))
    df <- content$results
    if (!is.null(df) && nrow(df) > 0) df_final <- rbind.fill(df_final, df)
  }
  
  if (nrow(df_final) == 0) return(NULL)
  
  # Dates
  for (col in intersect(date_cols_common, names(df_final))) {
    df_final[[col]] <- as.Date(df_final[[col]])
  }
  # Numériques
  for (col in intersect(numeric_cols_common, names(df_final))) {
    df_final[[col]] <- suppressWarnings(as.numeric(df_final[[col]]))
  }
  
  df_final$type_logement <- "Existant"
  df_final
}

fetch_dpe_neuf <- function(codes) {
  df_final <- data.frame()
  base_url <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe02neuf/lines"
  
  for (code_postal in codes) {
    params <- list(
      page = 1,
      size = 250,  # réduit pour limiter le volume par CP
      select = paste(dpe_fields_neuf, collapse = ","),
      qs = paste0('code_postal_ban:"', code_postal, '"')
    )
    
    url_encoded <- modify_url(base_url, query = params)
    response <- GET(url_encoded)
    if (status_code(response) != 200) next
    
    content <- fromJSON(rawToChar(response$content))
    df <- content$results
    if (!is.null(df) && nrow(df) > 0) df_final <- rbind.fill(df_final, df)
  }
  
  if (nrow(df_final) == 0) return(NULL)
  
  # Dates
  for (col in intersect(date_cols_common, names(df_final))) {
    df_final[[col]] <- as.Date(df_final[[col]])
  }
  # Numériques
  for (col in intersect(numeric_cols_common, names(df_final))) {
    df_final[[col]] <- suppressWarnings(as.numeric(df_final[[col]]))
  }
  
  df_final$type_logement <- "Neuf"
  df_final
}

fetch_all_dpe <- function(codes) {
  df_ex   <- fetch_dpe_existant(codes)
  df_neuf <- fetch_dpe_neuf(codes)
  
  if (is.null(df_ex) && is.null(df_neuf))
    return(list(data = NULL, last_date = NA))
  
  if (is.null(df_ex))   df_ex <- data.frame()
  if (is.null(df_neuf)) df_neuf <- data.frame()
  
  if (nrow(df_ex)   > 0) df_ex$date_dpe   <- df_ex$date_etablissement_dpe
  if (nrow(df_neuf) > 0) df_neuf$date_dpe <- df_neuf$date_reception_dpe
  
  all_dpe <- rbind.fill(df_ex, df_neuf)
  all_dpe <- all_dpe[, order(names(all_dpe))]
  
  last_date <- suppressWarnings(max(all_dpe$date_dpe, na.rm = TRUE))
  if (!is.finite(last_date)) last_date <- NA
  
  list(data = all_dpe, last_date = last_date)
}

# Chargement initial
initial <- fetch_all_dpe(code_postaux)
initial_data <- initial$data
initial_last_date <- initial$last_date

# -------------------------------------------------------------------
# 6. UI
# -------------------------------------------------------------------

app_ui <- fluidPage(
  theme = shinytheme("cyborg"),
  
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "img/logo_app.png"),
    tags$title("DPE 69 - iut_sd2_rshiny_enedis")
  ),
  
  themeSelector(),
  
  # En-tête
  fluidRow(
    column(
      width = 8,
      div(
        class = "app-header",
        img(src = "img/logo_app.png", height = "40px"),
        span("Tableau de bord DPE 69", class = "app-title-text")
      )
    ),
    column(
      width = 4,
      div(
        class = "app-header-right",
        img(src = "img/logo_iut.png", height = "40px"),
        span(icon("bolt"), " Projet R Shiny Enedis")
      )
    )
  ),
  
  # Filtres + KPI
  fluidRow(
    column(
      width = 3,
      wellPanel(
        h4(icon("filter"), "Filtres"),
        selectInput("code_postal", "Code postal", choices = c("Tous", code_postaux)),
        radioButtons("type_logement", "Type de logement",
                     choices = c("Tous", "Existant", "Neuf")),
        sliderInput("annee_min", "Année min (existants)", 1900, year(Sys.Date()), 1960, step = 5),
        sliderInput("annee_max", "Année max (existants)", 1900, year(Sys.Date()), year(Sys.Date()), step = 5),
        actionButton("refresh_data", "Rafraîchir API", icon = icon("sync"))
      )
    ),
    column(
      width = 9,
      fluidRow(
        column(width = 3, div(class = "kpi-box", h5("Nombre DPE"), textOutput("kpi_n_dpe"))),
        column(width = 3, div(class = "kpi-box", h5("Surface moy (m²)"), textOutput("kpi_surface_moy"))),
        column(width = 3, div(class = "kpi-box", h5("Part A–C (%)"), textOutput("kpi_part_bonne_classe"))),
        column(width = 3, div(class = "kpi-box", h5("Dernière date"), textOutput("kpi_last_date")))
      )
    )
  ),
  
  navbarPage(
    "",
    
    # Onglet Contexte ------------------------------------------------
    tabPanel(
      "Contexte", icon = icon("info-circle"),
      fluidRow(
        column(
          width = 6,
          h3("Données et contexte"),
          p("Analyse des DPE du département 69 via l'API ADEME."),
          DTOutput("table_contexte")
        ),
        column(
          width = 6,
          h3("Distribution DPE"),
          plotOutput("plot_bar_etiquette", height = "260px"),
          downloadButton("download_bar_etiquette_png", "Exporter répartition DPE (.png)"),
          br(), br(),
          h3("Histogramme surfaces (sans outliers)"),
          plotOutput("plot_hist_surface", height = "260px"),
          downloadButton("download_hist_surface_png", "Exporter histogramme surfaces (.png)")
        )
      )
    ),
    
    # Onglet Univarié -----------------------------------------------
    tabPanel(
      "Analyse univariée", icon = icon("chart-bar"),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          selectInput("var_univ", "Variable numérique", choices = c(
            "Surface habitable logement"        = "surface_habitable_logement",
            "Année de construction"            = "annee_construction",
            "Coût total 5 usages"              = "cout_total_5_usages",
            "Coût chauffage"                   = "cout_chauffage",
            "Coût ECS"                         = "cout_ecs",
            "Conso 5 usages EP/m²"             = "conso_5_usages_par_m2_ep",
            "Conso 5 usages EF/m²"             = "conso_5_usages_par_m2_ef",
            "Émissions GES 5 usages/m²"        = "emission_ges_5_usages_par_m2"
          )),
          checkboxInput("log_scale", "Échelle logarithmique (surface)", FALSE),
          downloadButton("download_hist_png", "Exporter histogramme (.png)")
        ),
        mainPanel(
          width = 9,
          h3("Histogramme (sans outliers)"),
          plotOutput("plot_univ_hist", height = "300px"),
          h3("Boîte à moustache par type de logement"),
          plotOutput("plot_univ_box", height = "300px"),
          downloadButton("download_box_png", "Exporter boxplot (.png)")
        )
      )
    ),
    
    # Onglet Bivarié ------------------------------------------------
    tabPanel(
      "Analyse bivariée", icon = icon("braille"),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          selectInput("var_x", "Variable X", choices = c(
            "Surface habitable logement"        = "surface_habitable_logement",
            "Année de construction"            = "annee_construction",
            "Coût total 5 usages"              = "cout_total_5_usages",
            "Conso 5 usages EP/m²"             = "conso_5_usages_par_m2_ep",
            "Conso 5 usages EF/m²"             = "conso_5_usages_par_m2_ef",
            "Émissions GES 5 usages/m²"        = "emission_ges_5_usages_par_m2"
          )),
          selectInput("var_y", "Variable Y", choices = c(
            "Surface habitable logement"        = "surface_habitable_logement",
            "Année de construction"            = "annee_construction",
            "Coût total 5 usages"              = "cout_total_5_usages",
            "Conso 5 usages EP/m²"             = "conso_5_usages_par_m2_ep",
            "Conso 5 usages EF/m²"             = "conso_5_usages_par_m2_ef",
            "Émissions GES 5 usages/m²"        = "emission_ges_5_usages_par_m2"
          )),
          downloadButton("download_scatter_png", "Exporter nuage de points (.png)")
        ),
        mainPanel(
          width = 9,
          h3("Nuage de points + régression linéaire (sans outliers)"),
          plotOutput("plot_scatter_reg", height = "330px"),
          h4("Statistiques bivariées"),
          verbatimTextOutput("stats_biv")
        )
      )
    ),
    
    # Onglet Énergie & coûts ----------------------------------------
    tabPanel(
      "Énergie & coûts", icon = icon("fire"),
      fluidRow(
        column(
          width = 6,
          h3("Coût total 5 usages par étiquette DPE"),
          plotOutput("plot_box_cout_etiquette", height = "280px"),
          downloadButton("download_box_cout_etiquette_png", "Exporter graphique (.png)")
        ),
        column(
          width = 6,
          h3("Répartition des énergies de chauffage"),
          plotOutput("plot_bar_energie_chauffage", height = "280px"),
          downloadButton("download_bar_energie_chauffage_png", "Exporter graphique (.png)")
        )
      ),
      fluidRow(
        column(
          width = 6,
          h3("Distribution conso 5 usages EP/m² (sans outliers)"),
          plotOutput("plot_hist_conso_ep", height = "280px"),
          downloadButton("download_hist_conso_ep_png", "Exporter histogramme (.png)")
        ),
        column(
          width = 6,
          h3("Répartition des énergies ECS"),
          plotOutput("plot_bar_energie_ecs", height = "280px"),
          downloadButton("download_bar_energie_ecs_png", "Exporter graphique (.png)")
        )
      )
    ),
    
    # Onglet Carte --------------------------------------------------
    tabPanel(
      "Cartographie", icon = icon("map-marked-alt"),
      fluidRow(
        column(
          width = 4,
          radioButtons("map_agg", "Niveau d'agrégation",
                       choices = c(
                         "DPE individuels" = "dpe",
                         "Centroïdes CP"   = "cp"
                       ))
        ),
        column(
          width = 8,
          leafletOutput("map_dpe", height = "520px")
        )
      )
    ),
    
    # Onglet Export -------------------------------------------------
    tabPanel(
      "Export & Mise à jour", icon = icon("file-export"),
      fluidRow(
        column(
          width = 6,
          h3("Export CSV"),
          downloadButton("download_csv", "Exporter données filtrées"),
          br(), br(),
          h4("Dernière mise à jour API :"),
          textOutput("txt_last_update")
        ),
        column(
          width = 6,
          h3("Rapport d'étude"),
          p("Le rapport RMarkdown est fourni séparément dans le projet.")
        )
      )
    ),
    
    # Onglet À propos -----------------------------------------------
    tabPanel(
      "À propos", icon = icon("question-circle"),
      fluidRow(
        column(
          width = 8,
          h3("À propos"),
          p("Application R Shiny développée dans le cadre du projet BUT SD2 - Enedis."),
          tags$ul(
            tags$li("Pack Standard : filtres, KPIs, cartes, graphes"),
            tags$li("Pack Intermédiaire : thème, exports PNG/CSV, corrélation"),
            tags$li("Pack Expert : login + refresh API ADEME")
          )
        )
      )
    )
  )
)

ui <- secure_app(app_ui)

# -------------------------------------------------------------------
# 7. Server
# -------------------------------------------------------------------

server <- function(input, output, session) {
  
  res_auth <- secure_server(check_credentials = check_credentials(credentials))
  
  dpe_data    <- reactiveVal(initial_data)
  last_update <- reactiveVal(initial_last_date)
  
  # Refresh API
  observeEvent(input$refresh_data, {
    showNotification("Récupération des données…", type = "message")
    new <- fetch_all_dpe(code_postaux)
    dpe_data(new$data)
    last_update(new$last_date)
    showNotification("Mise à jour effectuée !", type = "message")
  })
  
  # Données filtrées
  data_filtered <- reactive({
    df <- dpe_data()
    req(df)
    
    if (input$code_postal != "Tous") {
      df <- df %>% filter(code_postal_ban == input$code_postal)
    }
    
    if (input$type_logement != "Tous") {
      df <- df %>% filter(type_logement == input$type_logement)
    }
    
    if ("annee_construction" %in% names(df)) {
      df <- df %>%
        mutate(annee_construction = suppressWarnings(as.integer(annee_construction))) %>%
        filter(is.na(annee_construction) |
                 (annee_construction >= input$annee_min &
                    annee_construction <= input$annee_max))
    }
    df
  })
  
  # Jointure pour la carte
  data_map <- reactive({
    df <- data_filtered()
    req(df)
    
    df_xy <- df %>% filter(
      !is.na(coordonnee_cartographique_x_ban),
      !is.na(coordonnee_cartographique_y_ban)
    )
    if (nrow(df_xy) == 0) return(df_xy)
    
    df_join <- df_xy %>%
      left_join(
        adresses_69 %>% select(x, y, lon, lat) %>% distinct(),
        by = c(
          "coordonnee_cartographique_x_ban" = "x",
          "coordonnee_cartographique_y_ban" = "y"
        )
      ) %>%
      filter(!is.na(lon), !is.na(lat))
    
    df_join
  })
  
  # ---------------- KPI ----------------
  output$kpi_n_dpe <- renderText(nrow(data_filtered()))
  
  output$kpi_surface_moy <- renderText({
    df <- data_filtered()
    if (!"surface_habitable_logement" %in% names(df)) return("NA")
    val <- mean(df$surface_habitable_logement, na.rm = TRUE)
    if (!is.finite(val)) return("NA")
    round(val, 1)
  })
  
  output$kpi_part_bonne_classe <- renderText({
    df <- data_filtered()
    df <- df %>% filter(!is.na(etiquette_dpe))
    if (nrow(df) == 0) return("NA")
    part <- mean(df$etiquette_dpe %in% c("A", "B", "C")) * 100
    round(part, 1)
  })
  
  output$kpi_last_date <- renderText({
    dt <- last_update()
    if (is.na(dt)) return("NA")
    format(dt, "%d/%m/%Y")
  })
  
  output$txt_last_update <- renderText({
    dt <- last_update()
    if (is.na(dt)) return("NA")
    format(dt, "%d/%m/%Y")
  })
  
  # ---------------- Contexte ----------------
  output$table_contexte <- renderDT({
    datatable(
      data_filtered(),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  output$plot_bar_etiquette <- renderPlot({
    df <- data_filtered()
    if (!"etiquette_dpe" %in% names(df)) return(NULL)
    
    ggplot(df, aes(x = etiquette_dpe)) +
      geom_bar(fill = "steelblue") +
      theme_app_dark() +
      labs(x = "Étiquette DPE", y = "Nombre")
  })
  
  output$download_bar_etiquette_png <- downloadHandler(
    filename = function() "bar_etiquette_dpe.png",
    content = function(file) {
      df <- data_filtered()
      if (!"etiquette_dpe" %in% names(df)) return(NULL)
      png(file, 800, 600)
      print(
        ggplot(df, aes(x = etiquette_dpe)) +
          geom_bar(fill = "steelblue") +
          theme_minimal() +
          labs(x = "Étiquette DPE", y = "Nombre",
               title = "Répartition des étiquettes DPE")
      )
      dev.off()
    }
  )
  
  output$plot_hist_surface <- renderPlot({
    df <- data_filtered()
    req("surface_habitable_logement" %in% names(df))
    
    res <- trim_var_for_plot(df, "surface_habitable_logement")
    ggplot(res$df, aes(surface_habitable_logement)) +
      geom_histogram(bins = 30, fill = "darkorange") +
      theme_app_dark() +
      coord_cartesian(xlim = res$limits) +
      labs(x = "Surface habitable (m²)", y = "Nombre")
  })
  
  output$download_hist_surface_png <- downloadHandler(
    filename = function() "hist_surface_habitable.png",
    content = function(file) {
      df <- data_filtered()
      if (!"surface_habitable_logement" %in% names(df)) return(NULL)
      res <- trim_var_for_plot(df, "surface_habitable_logement")
      png(file, 800, 600)
      print(
        ggplot(res$df, aes(surface_habitable_logement)) +
          geom_histogram(bins = 30, fill = "darkorange") +
          theme_minimal() +
          coord_cartesian(xlim = res$limits) +
          labs(x = "Surface habitable (m²)", y = "Nombre",
               title = "Histogramme des surfaces (p1–p99)")
      )
      dev.off()
    }
  )
  
  # ---------------- Univarié ----------------
  output$plot_univ_hist <- renderPlot({
    df <- data_filtered()
    var <- input$var_univ
    req(var %in% names(df))
    
    res <- trim_var_for_plot(df, var)
    if (nrow(res$df) == 0) return(NULL)
    
    p <- ggplot(res$df, aes(.data[[var]])) +
      geom_histogram(bins = 30, fill = "skyblue") +
      theme_app_dark() +
      coord_cartesian(xlim = res$limits) +
      labs(x = var, y = "Nombre")
    
    if (input$log_scale && var == "surface_habitable_logement") {
      p <- p + scale_x_log10()
    }
    p
  })
  
  output$plot_univ_box <- renderPlot({
    df <- data_filtered()
    var <- input$var_univ
    req(var %in% names(df), "type_logement" %in% names(df))
    
    res <- trim_var_for_plot(df, var)
    if (nrow(res$df) == 0) return(NULL)
    
    ggplot(res$df, aes(type_logement, .data[[var]], fill = type_logement)) +
      geom_boxplot(alpha = 0.7) +
      theme_app_dark() +
      theme(legend.position = "none") +
      labs(x = "Type de logement", y = var)
  })
  
  output$download_hist_png <- downloadHandler(
    filename = function() paste0("hist_", input$var_univ, ".png"),
    content = function(file) {
      df <- data_filtered()
      var <- input$var_univ
      res <- trim_var_for_plot(df, var)
      
      png(file, 800, 600)
      print(
        ggplot(res$df, aes(.data[[var]])) +
          geom_histogram(bins = 30, fill = "skyblue") +
          theme_minimal() +
          labs(x = var, y = "Nombre")
      )
      dev.off()
    }
  )
  
  output$download_box_png <- downloadHandler(
    filename = function() paste0("box_", input$var_univ, ".png"),
    content = function(file) {
      df <- data_filtered()
      var <- input$var_univ
      res <- trim_var_for_plot(df, var)
      
      png(file, 800, 600)
      print(
        ggplot(res$df, aes(type_logement, .data[[var]], fill = type_logement)) +
          geom_boxplot(alpha = 0.7) +
          theme_minimal() +
          labs(x = "Type de logement", y = var)
      )
      dev.off()
    }
  )
  
  # ---------------- Bivarié ----------------
  output$plot_scatter_reg <- renderPlot({
    df <- data_filtered()
    xvar <- input$var_x
    yvar <- input$var_y
    req(xvar, yvar)
    
    res_x <- trim_var_for_plot(df, xvar)
    df_x  <- res_x$df
    res_y <- trim_var_for_plot(df_x, yvar)
    df_xy <- res_y$df %>% filter(!is.na(.data[[xvar]]), !is.na(.data[[yvar]]))
    if (nrow(df_xy) == 0) return(NULL)
    
    ggplot(df_xy, aes(.data[[xvar]], .data[[yvar]])) +
      geom_point(alpha = 0.5, color = "lightgreen") +
      geom_smooth(method = "lm", se = FALSE, color = "orange") +
      theme_app_dark() +
      labs(x = xvar, y = yvar)
  })
  
  output$stats_biv <- renderPrint({
    df <- data_filtered()
    xvar <- input$var_x
    yvar <- input$var_y
    
    if (!all(c(xvar, yvar) %in% names(df))) {
      cat("Variables non disponibles.\n")
      return()
    }
    
    df_xy <- df %>% filter(!is.na(.data[[xvar]]), !is.na(.data[[yvar]]))
    if (nrow(df_xy) < 3) {
      cat("Données insuffisantes.\n")
      return()
    }
    
    vx <- as.numeric(df_xy[[xvar]])
    vy <- as.numeric(df_xy[[yvar]])
    
    if (sd(vx, na.rm = TRUE) == 0 || sd(vy, na.rm = TRUE) == 0) {
      cat("Corrélation non définie.\n")
      return()
    }
    
    cat("Corrélation :", round(cor(vx, vy, use = "complete.obs"), 3), "\n\n")
    print(summary(lm(vy ~ vx)))
  })
  
  output$download_scatter_png <- downloadHandler(
    filename = function() paste0("scatter_", input$var_x, "_", input$var_y, ".png"),
    content = function(file) {
      df <- data_filtered()
      xvar <- input$var_x
      yvar <- input$var_y
      res_x <- trim_var_for_plot(df, xvar)
      df_x  <- res_x$df
      res_y <- trim_var_for_plot(df_x, yvar)
      df_xy <- res_y$df %>% filter(!is.na(.data[[xvar]]), !is.na(.data[[yvar]]))
      
      png(file, 800, 600)
      print(
        ggplot(df_xy, aes(.data[[xvar]], .data[[yvar]])) +
          geom_point(alpha = 0.5, color = "darkgreen") +
          geom_smooth(method = "lm", se = FALSE, color = "orange") +
          theme_minimal() +
          labs(x = xvar, y = yvar)
      )
      dev.off()
    }
  )
  
  # ---------------- Énergie & coûts ----------------
  output$plot_box_cout_etiquette <- renderPlot({
    df <- data_filtered()
    if (!all(c("cout_total_5_usages", "etiquette_dpe") %in% names(df))) return(NULL)
    
    df2 <- df %>%
      filter(!is.na(cout_total_5_usages), !is.na(etiquette_dpe))
    if (nrow(df2) == 0) return(NULL)
    
    res <- trim_var_for_plot(df2, "cout_total_5_usages")
    
    ggplot(res$df, aes(etiquette_dpe, cout_total_5_usages, fill = etiquette_dpe)) +
      geom_boxplot(alpha = 0.7) +
      theme_app_dark() +
      theme(legend.position = "none") +
      labs(x = "Étiquette DPE", y = "Coût total 5 usages", title = "Coût total par étiquette DPE")
  })
  
  output$download_box_cout_etiquette_png <- downloadHandler(
    filename = function() "box_cout_total_par_etiquette.png",
    content = function(file) {
      df <- data_filtered()
      if (!all(c("cout_total_5_usages", "etiquette_dpe") %in% names(df))) return(NULL)
      df2 <- df %>%
        filter(!is.na(cout_total_5_usages), !is.na(etiquette_dpe))
      if (nrow(df2) == 0) return(NULL)
      res <- trim_var_for_plot(df2, "cout_total_5_usages")
      
      png(file, 800, 600)
      print(
        ggplot(res$df, aes(etiquette_dpe, cout_total_5_usages, fill = etiquette_dpe)) +
          geom_boxplot(alpha = 0.7) +
          theme_minimal() +
          theme(legend.position = "none") +
          labs(x = "Étiquette DPE", y = "Coût total 5 usages",
               title = "Coût total 5 usages par étiquette DPE")
      )
      dev.off()
    }
  )
  
  output$plot_hist_conso_ep <- renderPlot({
    df <- data_filtered()
    if (!"conso_5_usages_par_m2_ep" %in% names(df)) return(NULL)
    
    res <- trim_var_for_plot(df, "conso_5_usages_par_m2_ep")
    if (nrow(res$df) == 0) return(NULL)
    
    ggplot(res$df, aes(conso_5_usages_par_m2_ep)) +
      geom_histogram(bins = 30, fill = "tomato") +
      theme_app_dark() +
      coord_cartesian(xlim = res$limits) +
      labs(x = "Conso 5 usages EP/m²", y = "Nombre")
  })
  
  output$download_hist_conso_ep_png <- downloadHandler(
    filename = function() "hist_conso_5_usages_ep_m2.png",
    content = function(file) {
      df <- data_filtered()
      if (!"conso_5_usages_par_m2_ep" %in% names(df)) return(NULL)
      res <- trim_var_for_plot(df, "conso_5_usages_par_m2_ep")
      if (nrow(res$df) == 0) return(NULL)
      
      png(file, 800, 600)
      print(
        ggplot(res$df, aes(conso_5_usages_par_m2_ep)) +
          geom_histogram(bins = 30, fill = "tomato") +
          theme_minimal() +
          coord_cartesian(xlim = res$limits) +
          labs(x = "Conso 5 usages EP/m²", y = "Nombre",
               title = "Histogramme conso 5 usages EP/m² (p1–p99)")
      )
      dev.off()
    }
  )
  
  output$plot_bar_energie_chauffage <- renderPlot({
    df <- data_filtered()
    if (!"type_energie_principale_chauffage" %in% names(df)) return(NULL)
    
    df2 <- df %>% filter(!is.na(type_energie_principale_chauffage))
    if (nrow(df2) == 0) return(NULL)
    
    ggplot(df2, aes(x = type_energie_principale_chauffage)) +
      geom_bar(fill = "steelblue") +
      theme_app_dark() +
      coord_flip() +
      labs(x = "Type énergie chauffage", y = "Nombre")
  })
  
  output$download_bar_energie_chauffage_png <- downloadHandler(
    filename = function() "bar_type_energie_chauffage.png",
    content = function(file) {
      df <- data_filtered()
      if (!"type_energie_principale_chauffage" %in% names(df)) return(NULL)
      df2 <- df %>% filter(!is.na(type_energie_principale_chauffage))
      if (nrow(df2) == 0) return(NULL)
      
      png(file, 800, 600)
      print(
        ggplot(df2, aes(x = type_energie_principale_chauffage)) +
          geom_bar(fill = "steelblue") +
          theme_minimal() +
          coord_flip() +
          labs(x = "Type énergie chauffage", y = "Nombre",
               title = "Répartition des énergies de chauffage")
      )
      dev.off()
    }
  )
  
  output$plot_bar_energie_ecs <- renderPlot({
    df <- data_filtered()
    if (!"type_energie_principale_ecs" %in% names(df)) return(NULL)
    
    df2 <- df %>% filter(!is.na(type_energie_principale_ecs))
    if (nrow(df2) == 0) return(NULL)
    
    ggplot(df2, aes(x = type_energie_principale_ecs)) +
      geom_bar(fill = "darkseagreen") +
      theme_app_dark() +
      coord_flip() +
      labs(x = "Type énergie ECS", y = "Nombre")
  })
  
  output$download_bar_energie_ecs_png <- downloadHandler(
    filename = function() "bar_type_energie_ecs.png",
    content = function(file) {
      df <- data_filtered()
      if (!"type_energie_principale_ecs" %in% names(df)) return(NULL)
      df2 <- df %>% filter(!is.na(type_energie_principale_ecs))
      if (nrow(df2) == 0) return(NULL)
      
      png(file, 800, 600)
      print(
        ggplot(df2, aes(x = type_energie_principale_ecs)) +
          geom_bar(fill = "darkseagreen") +
          theme_minimal() +
          coord_flip() +
          labs(x = "Type énergie ECS", y = "Nombre",
               title = "Répartition des énergies ECS")
      )
      dev.off()
    }
  )
  
  # ---------------- Carte ----------------
  output$map_dpe <- renderLeaflet({
    df_map <- data_map()
    
    if (nrow(df_map) == 0) {
      return(
        leaflet() %>% addTiles() %>%
          addPopups(0, 0, "Aucune coordonnée disponible.")
      )
    }
    
    if (input$map_agg == "cp") {
      df_plot <- df_map %>%
        group_by(code_postal_ban) %>%
        summarise(
          lon = mean(lon, na.rm = TRUE),
          lat = mean(lat, na.rm = TRUE),
          n_dpe = n(),
          .groups = "drop"
        )
    } else {
      df_plot <- df_map
    }
    
    leaflet(df_plot) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addCircleMarkers(
        lng = ~lon, lat = ~lat,
        radius = 4, fillOpacity = 0.8, stroke = FALSE,
        popup = ~{
          if ("n_dpe" %in% names(df_plot)) {
            paste0("Code postal : ", code_postal_ban, "<br>",
                   "Nombre de DPE : ", n_dpe)
          } else {
            paste0(
              "DPE : ", numero_dpe, "<br>",
              "CP : ", code_postal_ban, "<br>",
              "Étiquette : ", etiquette_dpe
            )
          }
        }
      )
  })
  
  # ---------------- Export CSV ----------------
  output$download_csv <- downloadHandler(
    filename = function() paste0("dpe_filtre_", Sys.Date(), ".csv"),
    content = function(file) {
      write.csv2(data_filtered(), file, row.names = FALSE, fileEncoding = "latin1")
    }
  )
}

# -------------------------------------------------------------------
# 8. Lancement de l'application
# -------------------------------------------------------------------
shinyApp(ui = ui, server = server)