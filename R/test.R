
#' @name test
#' @title Test a module
#' @description Test an outsider module by making sure it installs,
#' imports and its examples run correctly. Raises an error if a test fails.
#' @param flpth File path to location of module
#' @param pull Pull Docker image from Docker Hub? T/F
#' @return logical
#' @family testing
test <- function(flpth, pull = FALSE) {
  pkgnm <- pkgnm_get(flpth = flpth)
  res1 <- tryCatch(outsider.base::pkg_install(flpth = flpth, verbose = TRUE),
                   error = function(e) {
                    message(paste0('Unable to install package! ',
                                   "See error below:\n\n"))
                    stop(e)
                  })
  on.exit(outsider.base::uninstall(pkgnm = pkgnm))
  tags <- tags_get(flpth = flpth)
  for (tag in tags) {
    tag_msg <- paste0('Tag = ', char(tag))
    res2 <- tryCatch(outsider.base::image_install(pkgnm = pkgnm, tag = tag,
                                                  pull = pull),
                    error = function(e) {
                      message(paste0('Unable to install image! ', tag_msg,
                                     ". See error below:\n\n"))
                      stop(e)
                    })
    res3 <- examples_test(flpth = flpth)
    if (!res3) {
      stop('Unable to run all module examples! ', tag_msg, call. = FALSE)
    }
  }
  invisible(res1 & res2 & res3)
}

#' @name examples_test
#' @title Run each example of an outsider module
#' @description Return TRUE if all of the outsider module functions successfully
#' run.
#' @param flpth File path to location of module
#' @return logical
#' @family testing
examples_test <- function(flpth) {
  res <- TRUE
  example_scripts <- examples_get(flpth = flpth)
  for (example_script in example_scripts) {
    res <- tryCatch(expr = {
      ex_source(file = example_script)
      TRUE
    }, error = function(e) {
      message('Failed to run example script`', example_script, '`')
      message(as.character(e))
      FALSE
    })
  }
  res
}
ex_source <- function(file) {
  source(file = file, local = TRUE)
}
