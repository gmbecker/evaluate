#' Object class tests
#' @export is.message is.warning is.error is.value is.source is.recordedplot
#' @aliases is.message is.warning is.error is.value is.source is.recordedplot
#' @keywords internal
#' @rdname is.message
is.message <- function(x) inherits(x, "message")
#' @rdname is.message
is.warning <- function(x) inherits(x, "warning")
#' @rdname is.message
is.error <- function(x) inherits(x, "error")
#' @rdname is.message
is.value <- function(x) inherits(x, "value")
#' @rdname is.message
is.source <- function(x) inherits(x, "source")
#' @rdname is.message
is.recordedplot <- function(x) inherits(x, "recordedplot")

new_value <- function(value, visible = TRUE) {
  structure(list(value = value, visible = visible), class = "value")
}

new_source <- function(src) {
  structure(list(src = src), class = "source")
}

classes <- function(x) vapply(x, function(x) class(x)[1], character(1))

render <- function(x) if (isS4(x)) show(x) else print(x)

#' Create 'no output' object
#'
#' value handlers can indicate that nothing should be added directly
#' to the output list by returning an object returned from this function
#'
#' @return an object of class \code{___no_output___}
#' @export

no_output <- function() structure(list(), class="___no_output___")

render_capture <- function(x)
{
  out <- capture.output(render(x))
  if(length(out) == 0) {
    no_output()
  } else {
    out
  }
}

#' Custom output handlers.
#'
#' An \code{output_handler} handles the results
#' of \code{\link{evaluate}}, including the values, graphics,
#' conditions. Each type of output is handled by a particular
#' function in the handler object.
#'
#' The handler functions should accept an output object as their
#' first argument. The return value of the handlers is ignored,
#' except in the case of the value handler, where the handler is
#' assumed to process and return the value in the exact
#' form it should appear in the output list returned by
#' \code{link{evaluate}}.
#'
#' The default value handler returns a character vector containing
#' the textual output when \code{link{print}}/\code{link{output}}
#' is called on the object.
#'
#' Value handlers which wish to indicate that nothing should be
#' added to the output list should return an objected created
#' via \code{\link{no_output}}.
#'
#' Calling the constructor with no arguments results in the default
#' handler, which mimics the behavior of the console by printing
#' visible values.
#'
#' Note that recursion is common: for example, if \code{value} does
#' any printing, then the \code{text} or \code{graphics} handlers may be
#' called.
#'
#' @param source Function to handle the echoed source code under
#'   evaluation.
#' @param text Function to handle any textual console output.
#' @param graphics Function to handle graphics, as returned by
#'   \code{\link{recordPlot}}.
#' @param message Function to handle \code{\link{message}} output.
#' @param warning Function to handle \code{\link{warning}} output.
#' @param error Function to handle \code{\link{stop}} output.
#' @param value Function to handle the visible values, i.e., the
#'   return values of evaluation. This function is responsible for
#'   returning the value in the exact form it should appear in the
#'   outputs list returned by \code{link{evaluate}}. 
#' @return A new \code{output_handler} object
#' @aliases output_handler
#' @export
new_output_handler <- function(source = identity,
                               text = identity, graphics = identity,
                               message = identity, warning = identity,
                               error = identity, value = render_capture) {
  source <- match.fun(source)
  stopifnot(length(formals(source)) >= 1)
  text <- match.fun(text)
  stopifnot(length(formals(text)) >= 1)
  graphics <- match.fun(graphics)
  stopifnot(length(formals(graphics)) >= 1)
  message <- match.fun(message)
  stopifnot(length(formals(message)) >= 1)
  warning <- match.fun(warning)
  stopifnot(length(formals(warning)) >= 1)
  error <- match.fun(error)
  stopifnot(length(formals(error)) >= 1)
  value <- match.fun(value)
  stopifnot(length(formals(value)) >= 1)

  structure(list(source = source, text = text, graphics = graphics,
                 message = message, warning = warning, error = error,
                 value = value),
            class = "output_handler")
}
