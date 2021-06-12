#' Tidy Quiz Questions from Google Forms
#'
#' This function processes Barry's goggle forms quiz results. It takes a
#' data.frame object as input, as obtained from read.csv(), and cleans the
#' score column returning a data.frame with 'Email.Address', 'Score', and new
#' 'Total.Score' columns
#'
#' @param sheet Data.frame of quiz results as obtained from `read.csv()`
#' @param email Column name for student Email record
#' @param score Column name for student final Score record
#'
#' @return A data.frame with cleaned score values
#' @export
#'
#' @examples
#' # hw4 <- read.csv("HW4_R_quiz (Responses) - Form Responses 1.csv")
#' # hw_clean <- hw_clean_quiz(hw4)
#' # head(hw_clean)
#'
hw_clean_quiz <- function(sheet, email="Email.Address", score="Score") {

  # Clean score
  hw.clean <- sheet[,c("Email.Address","Score")]
  hw.clean$Total.score <- as.numeric(sub(" / 10","", hw.clean$Score))

  # Remove duplicated responses
  dup.hw.inds <- duplicated(hw.clean$Email.Address)
  if(sum(dup.hw.inds) > 0) {
    warning( paste("Some students have duplicated responses:\n",
                   paste(hw.clean[dup.hw.inds,], sep="\n"),
                   "  Taking first response only\n") )

    hw.clean <- hw.clean[!dup.hw.inds,]
  }
  return(hw.clean)
}


#' Read Class Gradebook from GoogleDrive
#'
#' Given an adequate file slug (i.e. file name matching pattern) this function
#' will go online to try and read a classes gradebook entry. It is assumed that
#' the start of this file (i.e. first 5 columns) are in UCSD eGrade plus email
#' address format that Barry and the eGrade system like to work with. This
#' makes final grade submission much easier
#'
#' @param file.pattern Single element character vector specifying the gradebook
#'   sheet name as stored in Drive e.g. 'eGrade-BIMM143_S20'.
#' @param write.local.csv Logical, if TRUE a local CSV file will be written to
#'   the CWD.
#'
#' @return Returns a tibble/data.frame of gradebook data
#' @export
#'
#' @examples
#'  # gradebook <- gradebook_read("eGrade-BIMM143_S20")
#'  # head(gradebook)
gradebook_read <- function(file.pattern="eGrade-BIMM143_S20", write.local.csv=FALSE) {
  #
  # Note to self looks like googlesheets4 is going through a rename
  # the main sheets_read() will be called range_read() in the next release
  #

  cat(">  Using remote google drive file!\n")

  #library(googledrive)
  #library(googlesheets4)


  # Find our sheet
  gs <- googledrive::drive_find(pattern = file.pattern, type = "spreadsheet", orderBy = "name")


  # Check sheet name(s)
  #gs
  if(nrow(gs) == 0) { stop("File not found: please check filename")}
  #if(nrow(gs) >  1) { warning("More than one matching file found")}

  # Our forml sheet will start with "eGrade" at the name begining 
  #  (note [1] here to pick first file by name due to 'orderBy' parm above)
  gradebook_sheet <- gs[ grep("^eGrade",gs$name)[1], ]
  cat("  Working with remote sheet:", gradebook_sheet$name, "with ID", gradebook_sheet$id, "\n")

  # Read the sheet onetime to find number of assignments
  tmp <- googlesheets4::range_read(gradebook_sheet$id)

  ## Now read with proper Column types specified as 'd' (double)
  nc <- ncol(tmp)
  egrade_col_foramt <- "ccccdccccc"
  gradebook_format  <- paste0(egrade_col_foramt,
                              paste( rep("d", nc-10), collapse = "") )

  cat(paste("  Reading with col_types:", gradebook_format),"\n")

  # Or just read all as character with col_types="c"
  gradebook <- googlesheets4::range_read(gradebook_sheet$id,
                                          col_types=gradebook_format,
                                          na=c("","NA", " "))

  # Optionally write a local CSV file
  if(write.local.csv) {
    out.file <- paste0(file.pattern, "-local.csv")
    cat(paste("  Writting local copy to CSV file:", out.file),"\n")

    readr::write_csv(gradebook, path=out.file )
  }

  return(gradebook)
}



#' Map HW to Gradebook Email for adding score to gradebook
#'
#' @param hw data.frame of hw with a `Email.Address` and `Total.score` columns
#' @param gradebook data.frame of class gradebook entries in eGrades foramt as obtained from the functon
#'  `gradebook_read()`.
#'
#' @return a vector of homework scores in order that matches gradebook
#' @export
#'
#' @examples
#' # ToDo:
hw2gradebook <- function(hw, gradebook) {
  inds <- match(gradebook$Email, hw$Email.Address)
  hw.score <- hw$Total.score[inds]

  # visual check or rtn object??
  #data.frame( email.gb=gradebook$Email,
  #            email.hw=hw$Email.Address[inds],
  #            score=hw$Total.score[inds],
  #            inds=inds)

  return(hw.score)
}


#' Extract the max pts per asignment from gradebook column names
#'
#' This function looks for numbers within square brackets and
#' assumes these are the max pts for that assignment (i.e column)
#'
#' @param gradebook data.frame of class gradebook entries in eGrades foramt as obtained from the functon
#'  `gradebook_read()`.
#'
#' @return a numeric vector of max pts with NA values for missing pts
#' @export
#'
#' @examples
#'  gradebook.file <- "eGrade-BIMM143_F20"
#'  gradebook <- gradebook_read(gradebook.file)
#'  max.pts.extract(gradebook)
#'
max.pts.extract <- function(gradebook) {
  #library(stringr)

  pts <- colnames(gradebook)
  max.pts <- stringr::str_extract(pts, "\\[.+\\]")
  max.grades <- as.numeric(stringr::str_replace_all(max.pts, "\\[|\\]",""))
  names(max.grades) <- pts
  return(max.grades)
}



#' Convert percent score to letter grade
#'
#' @param percent a numeric vector of precent values in
#'   the zero to 100 range.
#'
#' @return a data frame with colums for Percent and Grade
#' @export
#'
#' @examples
#'   percent2letter( c(80, 45, 64, 99, 60) )
#'
percent2letter <- function(percent) {

    letter.grades <- c("F"=0,
                     "D-"=60,
                     "D"=63.3,
                     "D+"=66.7,
                     "C-"=70,
                     "C"=73.3,
                     "B-"=80,
                     "B"=83.3,
                     "B+"=86.7,
                     "A-"=90,
                     "A"=93.3,
                     "A+"=96.7)

  final.grades <- cut(
    percent,
    breaks = c(letter.grades,100),
    labels = names(letter.grades))

  return( data.frame(Percent=round(percent,2),
                     Grade=as.character(final.grades)) )
}


