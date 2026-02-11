print(here::here())

library(wjake)
library(showtext)
library(english)

# ggplot2 theme-----------------------------------------------------------------
set_theme(
  base_family = "Open Sans",
  plot_margin = ggplot2::margin(10, 10, 10, 10)
)

font_add_google("Open Sans")
showtext_auto()
showtext_opts(dpi = 192)

msr_colors <- c("#8ECAE6", "#023047", "#D7263D")

# gt theme ---------------------------------------------------------------------
gt_theme_rdcm <- function(gt_dat, bg_color = "#FFFFFF", ...) {
  gt_dat |>
    gt::opt_all_caps() |>
    gt::opt_table_font(
      font = list(gt::google_font("Open Sans"), gt::default_fonts())
    ) |>
    gt::tab_options(
      column_labels.background.color = bg_color,
      column_labels.border.top.width = gt::px(3),
      column_labels.border.top.color = bg_color,
      table.border.top.width = gt::px(1),
      table.border.bottom.width = gt::px(1),
      heading.align = "left",
      heading.background.color = bg_color,
      source_notes.padding = gt::px(10),
      source_notes.border.lr.width = gt::px(0),
      source_notes.font.size = 12,
      source_notes.background.color = bg_color,
      table.font.size = 16,
      data_row.padding = gt::px(3),
      table.background.color = bg_color,
      ...
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = "bottom",
        color = "transparent",
        weight = gt::px(2)
      ),
      locations = gt::cells_body(
        columns = gt::everything(),
        rows = nrow(gt_dat$`_data`)
      )
    ) |>
    gt::tab_style(
      style = list(
        gt::cell_text(
          weight = "bold",
          align = "center",
          v_align = "middle",
          color = msr_colors[2]
        ),
        gt::cell_borders(
          sides = "bottom",
          color = msr_colors[2],
          weight = gt::px(3)
        )
      ),
      locations = gt::cells_column_labels(gt::everything())
    ) |>
    gt::tab_style(
      style = gt::cell_fill(color = bg_color),
      locations = list(gt::cells_body(
        columns = gt::everything(),
        rows = gt::everything()
      ))
    )
}

# options ----------------------------------------------------------------------
options(mc.cores = 4, tidyverse.quiet = TRUE, width = 80, cli.width = 70)

# misc functions ---------------------------------------------------------------
article_req_pkgs <- function(x, what = "To use code in this article, ") {
  x <- sort(x)
  x <- paste0("`{", x, "}`")
  x <- knitr::combine_words(x, and = " and ")
  paste0(
    what,
    " you will need to install the following packages: ",
    x,
    "."
  )
}

small_session <- function(pkgs = NULL) {
  pkgs <- c(
    pkgs,
    # r-dcm packages
    "dcmdata",
    "dcmstan",
    "measr",

    # Stan packages
    "rstan",
    "cmdstanr",
    "loo",
    "posterior",
    "bridgesampling",

    # core tidyverse
    "dplyr",
    "forcats",
    "ggplot2",
    "lubridate",
    "purrr",
    "readr",
    "stringr",
    "tibble",
    "tidyr",

    # other helpers
    "rlang"
  )
  pkgs <- unique(pkgs)

  sinfo <- sessioninfo::session_info()
  cls_platform <- class(sinfo$platform)
  cls_pkgs <- class(sinfo$packages)

  if ("rstan" %in% sinfo$packages$package) {
    sinfo$platform <- c(
      sinfo$platform,
      list("Stan (rstan)" = rstan::stan_version())
    )
  }

  if ("cmdstanr" %in% sinfo$packages$package) {
    sinfo$platform <- c(
      sinfo$platform,
      list(
        "Stan (cmdstanr)" = paste(
          cmdstanr::cmdstan_version(),
          "@",
          cmdstanr::cmdstan_path()
        )
      )
    )
  }

  sinfo$packages <-
    sinfo$packages |>
    dplyr::filter(package %in% pkgs) |>
    dplyr::mutate(loadedpath = path, attached = FALSE, library = 1)

  class(sinfo$platform) <- cls_platform
  class(sinfo$packages) <- cls_pkgs

  remove_double_newlines <- function(x) {
    ind <- x == ""
    count <- 0
    for (i in seq_along(ind)) {
      if (ind[i]) {
        count <- count + 1
        if (count == 1) {
          ind[i] <- FALSE
        }
      } else {
        count <- 0
      }
    }
    x[!ind]
  }

  sinfo <- capture.output(sinfo)

  sinfo <- sinfo |>
    stringr::str_subset("^ \\[\\d+\\] ", negate = TRUE) |>
    stringr::str_subset(
      "^ (setting|os|system|ui|collate|ctype|tz)",
      negate = TRUE
    ) |>
    stringr::str_remove(" @ .*") |>
    stringr::str_replace_all("\\*", " ") |>
    stringr::str_replace("lib source", "source") |>
    stringr::str_replace(" \\[\\d+\\] ", " ") |>
    stringr::str_subset(
      "Packages attached to the search path",
      negate = TRUE
    ) |>
    remove_double_newlines()

  cat(sinfo, sep = "\n")
}
