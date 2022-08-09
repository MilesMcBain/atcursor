#' Get word or selection at cursor
#'
#' Uses the {rstudioapi} to get the word the cursor is on or active selection in
#' the active document. This is useful for addins that want bind keys to trigger
#' commands using the cursor context.
#'
#' This function defines a word as a possibly namespaced R symbol. So a cursor
#' on the name of `pkg::var(foo)` will return 'pkg::var'. `$` is considered a separator.
#'
#' If there are any selections the primary selection takes precedence and is returned.
#'
#' @returns a character vector containing the current word at the cursor or primary selection
#' @export
get_word_or_selection <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  current_selection <- rstudioapi::primary_selection(context)
  if (!is_zero_length_selection(current_selection)) {
    return(current_selection$text)
  }
  cursor_line <- get_cursor_line(context, current_selection)
  cursor_col <- get_cursor_col(current_selection)
  symbol_locations <- get_symbol_locations(cursor_line)
  cursor_symbol <-
    symbol_locations[
      symbol_locations$start <= cursor_col &
        symbol_locations$end >= cursor_col,
    ]
  if (nrow(cursor_symbol) == 0) {
    return(character(0))
  }
  substring(cursor_line, cursor_symbol$start, cursor_symbol$end)
}

is_zero_length_selection <- function(selection) {
  all(selection$range$start == selection$range$end)
}

#' get the line the cursor is on
#' 
#' @param context the rtsudioapi document context
#' @param current_selection the selection to find the line for, defaults to primary selection
#' 
#' @export
get_cursor_line <- function(
  context,
  current_selection = rstudioapi::primary_selection(context)
) {
  line_num <- current_selection$range$start["row"]
  context$contents[[line_num]]
}

#' get the column the cursor is on from a selection
#' 
#' @param current_selection a selection from the rstudioapi document context
#' 
#' @export
get_cursor_col <- function(current_selection) {
  current_selection$range$start["column"]
}

get_symbol_locations <- function(code_line) {
  matches <- gregexpr(
    "(?:[A-Za-z]|[.][A-Za-z])[A-Za-z0-9_.]+(?::{2,3}(?:[A-Za-z]|[.][A-Za-z])[A-Za-z0-9_.]+)?",
    code_line,
    perl = TRUE
  )
  match_df <- data.frame(
    start = c(matches[[1]]),
    length = attr(matches[[1]], "match.length")
  )
  match_df$end <- match_df$start + match_df$length - 1
  match_df
}
