source("renv/activate.R")

if (interactive()) {
  suppressMessages(require(usethis))

  # add shortcuts
  if (requireNamespace("shrtcts", quietly = TRUE)) {
    shrtcts::add_rstudio_shortcuts(set_keyboard_shortcuts = TRUE)
  }
}

options(
  dplyr.summarise.inform = FALSE,
  repos = c("https://cran.rstudio.com/", "https://stan-dev.r-universe.dev"),
  scipen = 999,
  pillar.bold = TRUE,
  hrbrthemes.loadfonts = TRUE,
  hrbragg.verbose = FALSE,
  ratlas.loadfonts = TRUE,
  ratlas.auto_format = TRUE,
  lifecycle_verbosity = "warning"
)
