#load lubrary ----
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2026-11-14"))
if (!require("pacman")) install.packages("pacman")

pacman::p_load(tidyverse,
               ggplot2,
               lmtest, 
               sandwich
)

#load interest rate ----

##usa ----

interest_usa <- readr::read_csv("Data/Source-data/IRSTCI01USM156N.csv")

interest_usa <- interest_usa %>%
  dplyr::rename(date = observation_date,
                usa_interest_rate = IRSTCI01USM156N
                )

##mexico -----

interest_mex <- readr::read_csv("Data/Source-data/IRSTCI01MXM156N.csv")

interest_mex <- interest_mex %>%
  dplyr::rename(date = observation_date,
                mex_interest_rate = IRSTCI01MXM156N
  )

##colombia -----

interest_col <- readr::read_csv("Data/Source-data/COLIRSTCI01STM.csv")

interest_col <- interest_col %>%
  dplyr::rename(date = observation_date,
                col_interest_rate = COLIRSTCI01STM
  )

#exchange rate ----

##mex ----

exchange_mex <- readr::read_csv("Data/Source-data/EXMXUS.csv")

exchange_mex <- exchange_mex %>%
  dplyr::rename(date = observation_date,
                mex_exchange = EXMXUS
  )

##col ----

exchange_col <- readr::read_csv("Data/Source-data/COLCCUSMA02STM.csv")

exchange_col <- exchange_col %>%
  dplyr::rename(date = observation_date,
                col_exchange = COLCCUSMA02STM
  )

#merge all the data ----

list_variables <- list(exchange_col, exchange_mex, interest_usa, interest_mex, interest_col)

uip <- list_variables[[1]]

for (i in 2:length(list_variables)) {
  uip <- dplyr::inner_join(uip, list_variables[[i]], by = "date")
}

#add the spreands ----

uip_spreands <- uip %>%
  dplyr::mutate(
    spread_mex_anual = mex_interest_rate - usa_interest_rate,
    spread_col_anual = col_interest_rate - usa_interest_rate,
    mex_ds_anual = (log(mex_exchange) - log(dplyr::lag(mex_exchange, 1))) * 100,
    col_ds_anual = (log(col_exchange) - log(dplyr::lag(col_exchange, 1))) * 100
  )

#plots ----

#theme
tema_ensayo <- ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold", size = 12),
    plot.subtitle = ggplot2::element_text(color = "gray30", size = 10),
    plot.caption = ggplot2::element_text(color = "gray45", size = 8, hjust = 0),
    legend.position = "bottom",
    legend.title = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank()
  )

#mexico
scale_mex <- max(uip_spreands$mex_exchange, na.rm = TRUE) / max(uip_spreands$spread_mex_anual, na.rm = TRUE)

g1_mexico <- ggplot2::ggplot(uip_spreands, ggplot2::aes(x = date)) +
  ggplot2::geom_line(ggplot2::aes(y = mex_exchange, color = "Tipo de Cambio (MXN/USD)"), linewidth = 0.9) +
  ggplot2::geom_line(ggplot2::aes(y = spread_mex_anual * scale_mex, color = "Diferencial de Tasas (MX - EE.UU.)"),
                     linetype = "dashed", linewidth = 0.9) +
  ggplot2::scale_y_continuous(
    name = "Pesos Mexicanos por Dólar (MXN/USD)",
    sec.axis = ggplot2::sec_axis(~ . / scale_mex, name = "Diferencial de Tasas (% anual)")
  ) +
  ggplot2::scale_color_manual(values = c(
    "Tipo de Cambio (MXN/USD)" = "#1B4F72",
    "Diferencial de Tasas (MX - EE.UU.)" = "#C0392B"
  )) +
  ggplot2::labs(
    #title = "Diferencial de tasas de interés y tipo de cambio en México (2018–2023)",
    # subtitle = "El aumento del diferencial de tasas (2021–2023) coincidió con una apreciación del peso mexicano",
    x = NULL,
    #caption = "Fuente: Elaboración propia con datos de OCDE y Reserva Federal (FRED)."
  ) +
  tema_ensayo

print(g1_mexico)
ggplot2::ggsave(
  filename = "Plots/Figura1_Mexico_UIP.pdf",
  plot = g1_mexico,
  device = cairo_pdf,
  width = 8,
  height = 4.8,
  units = "in"
)

#colombia

scale_col <- max(uip_spreands$col_exchange, na.rm = TRUE) / max(uip_spreands$spread_col_anual, na.rm = TRUE)

g2_colombia <- ggplot2::ggplot(uip_spreands, ggplot2::aes(x = date)) +
  ggplot2::geom_line(ggplot2::aes(y = col_exchange, color = "Tipo de Cambio (COP/USD)"), linewidth = 0.9) +
  ggplot2::geom_line(ggplot2::aes(y = spread_col_anual * scale_col, color = "Diferencial de Tasas (CO - EE.UU.)"),
                     linetype = "dashed", linewidth = 0.9) +
  ggplot2::scale_y_continuous(
    name = "Pesos Colombianos por Dólar (COP/USD)",
    labels = scales::comma,
    sec.axis = ggplot2::sec_axis(~ . / scale_col, name = "Diferencial de Tasas (% anual)")
  ) +
  ggplot2::scale_color_manual(values = c(
    "Tipo de Cambio (COP/USD)" = "#117864",
    "Diferencial de Tasas (CO - EE.UU.)" = "#D35400"
  )) +
  ggplot2::labs(
    #title = "Diferencial de tasas de interés y tipo de cambio en Colombia (2018–2023)",
    #subtitle = "A pesar del alza en tasas locales, el COP mostró alta volatilidad y depreciación estructural",
    x = NULL,
    #caption = "Fuente: Elaboración propia con datos de OCDE y Reserva Federal (FRED)."
  ) +
  tema_ensayo

print(g2_colombia)
ggplot2::ggsave(
  filename = "Plots/Figura2_Colombia_UIP.pdf",
  plot = g2_colombia,
  device = cairo_pdf,
  width = 8,
  height = 4.8,
  units = "in"
)

# fama regresion ----

uip_reg <- uip_spreands %>%
  dplyr::mutate(
    mex_ds_lead = dplyr::lead(mex_ds_anual, 1),
    col_ds_lead = dplyr::lead(col_ds_anual, 1)
  )

dplyr::glimpse(uip_reg)

fama_mex <- stats::lm(mex_ds_lead ~ spread_mex_anual, data = uip_reg)

summary(fama_mex)

fama_col <- stats::lm(col_ds_lead ~ spread_col_anual, data = uip_reg)


resumen_mex <- lmtest::coeftest(fama_mex, vcov = sandwich::NeweyWest(fama_mex))
resumen_col <- lmtest::coeftest(fama_col, vcov = sandwich::NeweyWest(fama_col))

print(resumen_mex)


g3_fama <- ggplot2::ggplot(uip_reg) +
  ggplot2::geom_point(ggplot2::aes(x = spread_mex_anual, y = mex_ds_lead, color = "México"), alpha = 0.6) +
  ggplot2::geom_smooth(ggplot2::aes(x = spread_mex_anual, y = mex_ds_lead, color = "México"), method = "lm", se = FALSE) +
  ggplot2::geom_point(ggplot2::aes(x = spread_col_anual, y = col_ds_lead, color = "Colombia"), alpha = 0.6) +
  ggplot2::geom_smooth(ggplot2::aes(x = spread_col_anual, y = col_ds_lead, color = "Colombia"), method = "lm", se = FALSE) +
  ggplot2::scale_color_manual(values = c("México" = "#1B4F72", "Colombia" = "#117864")) +
  ggplot2::labs(
    x = "Diferencial de Tasas (Local - EE.UU.)",
    y = "Variación del Tipo de Cambio t+1 (%)"
  ) +
  tema_ensayo

print(g3_fama)
ggplot2::ggsave(
  filename = "Plots/Figura3_regresion_UIP.pdf",
  plot = g3_fama,
  device = cairo_pdf,
  width = 8,
  height = 4.8,
  units = "in"
)

#save csv ----

uip_export <- uip_reg %>%
  dplyr::select(
    -mex_ds_anual, 
    -col_ds_anual,
    -usa_interest_rate,
    -mex_interest_rate,
    -col_interest_rate
  )

dplyr::glimpse(uip_export)

readr::write_csv(uip_export, "Data/Csv/UIP_Mexico_Colombia_Clean.csv")
