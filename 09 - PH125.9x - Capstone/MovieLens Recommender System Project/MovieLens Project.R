#############################################################
# Create edx set, validation set, and submission file
#############################################################

# Note: this process could take a couple of minutes

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")

# MovieLens 10M dataset:
# https://grouplens.org/datasets/movielens/10m/
# http://files.grouplens.org/datasets/movielens/ml-10m.zip

dl <- tempfile()
download.file("http://files.grouplens.org/datasets/movielens/ml-10m.zip", dl)

ratings <- read.table(text = gsub("::", "\t", readLines(unzip(dl, "ml-10M100K/ratings.dat"))),
                      col.names = c("userId", "movieId", "rating", "timestamp"))

movies <- str_split_fixed(readLines(unzip(dl, "ml-10M100K/movies.dat")), "\\::", 3)
colnames(movies) <- c("movieId", "title", "genres")
movies <- as.data.frame(movies) %>% mutate(movieId = as.numeric(levels(movieId))[movieId],
                                           title = as.character(title),
                                           genres = as.character(genres))

movielens <- left_join(ratings, movies, by = "movieId")

# Validation set will be 10% of MovieLens data

set.seed(1)
test_index <- createDataPartition(y = movielens$rating, times = 1, p = 0.1, list = FALSE)
edx <- movielens[-test_index,]
temp <- movielens[test_index,]

# Make sure userId and movieId in validation set are also in edx set

validation <- temp %>% 
  semi_join(edx, by = "movieId") %>%
  semi_join(edx, by = "userId")

# Add rows removed from validation set back into edx set

removed <- anti_join(temp, validation)
edx <- rbind(edx, removed)

rm(dl, ratings, movies, test_index, temp, movielens, removed)


#######################################################
# Quiz
#######################################################

# Q1
# How many rows and columns are there in the edx dataset?

dim(edx)


# Q2
# How many zeros were given as ratings in the edx dataset?

edx %>% filter(rating == 0) %>% tally()

# How many threes were given as ratings in the edx dataset?

edx %>% filter(rating == 3) %>% tally()


# Q3
# How many different movies are in the edx dataset?

n_distinct(edx$movieId)


# Q4
# How many different users are in the edx dataset?

n_distinct(edx$userId)


# Q5
# How many movie ratings are in each of the following genres in the edx dataset?

edx %>% separate_rows(genres, sep = "\\|") %>%
  group_by(genres) %>%
  summarize(count = n()) %>%
  arrange(desc(count))


# Q6
# Which movie has the greatest number of ratings?

edx %>% group_by(movieId, title) %>%
  summarize(count = n()) %>%
  arrange(desc(count))


# Q7
# What are the five most given ratings in order from most to least?

edx %>% group_by(rating) %>% summarize(count = n()) %>% top_n(5) %>%
  arrange(desc(count))  


# Q8
# True or False: In general, half star ratings are less common than 
# whole star ratings (e.g., there are fewer ratings of 3.5 than there 
# are ratings of 3 or 4, etc.).

edx %>%
  group_by(rating) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = rating, y = count)) +
  geom_line()

#####################################################################
# MovieLens Reccomender System Project
#
# Introduction
#
# For this project, you will be creating a movie recommendation system 
# using  the MovieLens dataset. The version of movielens included in the 
# dslabs package(which was used for some of the exercises in PH125.8x: Data 
# Science: Machine Learning) is just a small subset of a much larger 
# dataset with millions of ratings. You can find the entire latest 
# MovieLens dataset here. You will be creating your own recommendation 
# system using all the tools we have shown you throughout the courses 
# in this series. We will use the 10M version of the MovieLens dataset 
# to make the computation a little easier.
# 
# You will download the MovieLens data and run code we will provide to 
# generate your datasets.
# 
# First, there will be a short quiz on the MovieLens data. You can view 
# this quiz as an opportunity to familiarize yourself with the data in order 
# to prepare for your project submission.
# 
# Second, you will train a machine learning algorithm using the inputs 
# in one subset to predict movie ratings in the validation set. 
# Your project itself will be assessed by peer grading.
#
# Instruction
#
# The submission for the MovieLens project will be three files: a report 
# in the form of an Rmd file, a report in the form of a PDF document knit 
# from your Rmd file, and an R script or Rmd file that generates your 
# predicted movie ratings and calculates RMSE. Your grade for the project 
# will be based on two factors:
#   
# - Your report and script (75%)
# - The RMSE returned by testing your algorithm on the validation set (25%)
# 
# Please note that once you submit your project, you will not be able to make 
# changes to your submission.
# 
# Report and Script (75%)
# 
# Your report and script will be graded by your peers, based on a rubric 
# defined by the course staff. Each submission will be graded by three peers 
# and the median grade will be awarded. To receive your grade, you must review 
# and grade the submissions of five of your fellow learners after 
# submitting your own. This will give you the chance to learn from your peers. 
# Take note of the deadline as you must grade the reports of your peers by 
# this deadline in order to receive your grade.
# 
# RMSE (25%)
# 
# Your movie rating predictions will be compared to the true ratings in the 
# validation set using RMSE. Be sure that your report includes the RMSE 
# and that your R script outputs the RMSE.

#####################################################################
