# atcursor

Get the thing at the cursor using `{rstudioapi}`:

# Installation

```r
install.packages(
   "atcursor", 
   repos = c(mm = "https://milesmcbain.r-universe.dev", c(getOption("repos"))))
```
# Usage

You probably want to use this in your addin in a package:

```r
word_or_selection <- atcursor::get_word_or_selection()

..do stuff with the word or selection..
```
