
# coursework

<!-- badges: start -->
<!-- badges: end -->

The goal of coursework is to help manage Barry's boring coursework logistics. For now this includes adding to the online gradebook (a google sheet). Merging homework and quiz results to this gradebook. Sending results emails and of course assigning letter grades. etc.

## Installation

You can install the development version of coursework from [GitHub](https://CRAN.R-project.org) with:

``` r
devtools::install_github("bioboot/coursework")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(coursework)

## read the gradebook 
gradebook.file <- "eGrade-BIMM143_F20"
gradebook <- gradebook_read(gradebook.file)
```

Now we can extract max pts for each assignment
```{r}
max.pts.extract(gradebook)

# sweep to determine precent etc.
```

We can add other work to the gradebook by matching emails
```{r}
# adding hw score to gradebook
hw4 <- read.csv("HW4_R_quiz (Responses) - Form Responses 1.csv")
hw_clean <- hw_clean_quiz(hw4)
head(hw_clean)

# hw2gradebook(hw_clean, gradebook)
```

Example of reading from GradeScope

Determine letter grades
```{r}
# Letter grades
percent2letter( c(80, 45, 64, 99, 60) )
```


