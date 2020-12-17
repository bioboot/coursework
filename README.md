
# coursework

<!-- badges: start -->
<!-- badges: end -->

The goal of coursework (a.k.a. "gradesheet") is to help manage Barry's boring coursework logistics. For now this includes adding to the online gradebook (a google sheet). Merging homework and quiz results from other sources to this gradebook. Sending automated results emails, assigning letter grades, and other such logistical nonsense.

## Installation

This package is not on CRAN nor will it ever likely be. You can install the development version from [GitHub](https://CRAN.R-project.org) with:

``` r
devtools::install_github("bioboot/coursework")
```

## Example

This is a basic example which shows how to read the course gradebook, add some homework, and determine overall letter grade from a precentage:

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


