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

# Install all needed libraries if it is not present

if(!require(tidyverse)) install.packages("tidyverse") 
if(!require(kableExtra)) install.packages("kableExtra")
if(!require(tidyr)) install.packages("tidyr")
if(!require(tidyverse)) install.packages("tidyverse")
if(!require(stringr)) install.packages("stringr")
if(!require(forcats)) install.packages("forcats")
if(!require(ggplot2)) install.packages("ggplot2")

# Loading all needed libraries

library(dplyr)
library(tidyverse)
library(kableExtra)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)

# The RMSE function that will be used in this project is:
RMSE <- function(true_ratings = NULL, predicted_ratings = NULL) {
    sqrt(mean((true_ratings - predicted_ratings)^2))
}

# Convert timestamp to a human readable date

edx$date <- as.POSIXct(edx$timestamp, origin="1970-01-01")
validation$date <- as.POSIXct(validation$timestamp, origin="1970-01-01")

# Extract the year and month of rate in both dataset

edx$yearOfRate <- format(edx$date,"%Y")
edx$monthOfRate <- format(edx$date,"%m")

validation$yearOfRate <- format(validation$date,"%Y")
validation$monthOfRate <- format(validation$date,"%m")

# Extract the year of release for each movie in both dataset
# edx dataset

edx <- edx %>%
   mutate(title = str_trim(title)) %>%
   extract(title,
           c("titleTemp", "release"),
           regex = "^(.*) \\(([0-9 \\-]*)\\)$",
           remove = F) %>%
   mutate(release = if_else(str_length(release) > 4,
                                as.integer(str_split(release, "-",
                                                     simplify = T)[1]),
                                as.integer(release))
   ) %>%
   mutate(title = if_else(is.na(titleTemp),
                          title,
                          titleTemp)
         ) %>%
  select(-titleTemp)

# validation dataset

validation <- validation %>%
   mutate(title = str_trim(title)) %>%
   extract(title,
           c("titleTemp", "release"),
           regex = "^(.*) \\(([0-9 \\-]*)\\)$",
           remove = F) %>%
   mutate(release = if_else(str_length(release) > 4,
                                as.integer(str_split(release, "-",
                                                     simplify = T)[1]),
                                as.integer(release))
   ) %>%
   mutate(title = if_else(is.na(titleTemp),
                          title,
                          titleTemp)
         ) %>%
  select(-titleTemp)

# Extract the genre in edx datasets

edx <- edx %>%
   mutate(genre = fct_explicit_na(genres,
                                       na_level = "(no genres listed)")
          ) %>%
   separate_rows(genre,
                 sep = "\\|")

# Extract the genre in validation datasets

validation <- validation %>%
   mutate(genre = fct_explicit_na(genres,
                                       na_level = "(no genres listed)")
          ) %>%
   separate_rows(genre,
                 sep = "\\|")

# remove unnecessary columns on edx and validation dataset

edx <- edx %>% select(userId, movieId, rating, title, genre, release, yearOfRate, monthOfRate)

validation <- validation %>% select(userId, movieId, rating, title, genre, release, yearOfRate, monthOfRate)

# Convert the columns into the desidered data type

edx$yearOfRate <- as.numeric(edx$yearOfRate)
edx$monthOfRate <- as.numeric(edx$monthOfRate)
edx$release <- as.numeric(edx$release)

validation$yearOfRate <- as.numeric(validation$yearOfRate)
validation$monthOfRate <- as.numeric(validation$monthOfRate)
validation$release <- as.numeric(validation$release)

# Calculate the average of all movies

mu_hat <- mean(edx$rating)

# Predict the RMSE on the validation set

rmse_mean_model_result <- RMSE(validation$rating, mu_hat)

# Creating a results dataframe that contains all RMSE results

results <- data.frame(model="Naive Mean-Baseline Model", RMSE=rmse_mean_model_result)

# Calculate the average by movie

movie_avgs <- edx %>%
   group_by(movieId) %>%
   summarize(b_i = mean(rating - mu_hat))

# Compute the predicted ratings on validation dataset

rmse_movie_model <- validation %>%
   left_join(movie_avgs, by='movieId') %>%
   mutate(pred = mu_hat + b_i) %>%
   pull(pred)

rmse_movie_model_result <- RMSE(validation$rating, rmse_movie_model)

# Adding the results to the results dataset

results <- results %>% add_row(model="Movie-Based Model", RMSE=rmse_movie_model_result)

# Calculate the average by user

user_avgs <- edx %>%
   left_join(movie_avgs, by='movieId') %>%
   group_by(userId) %>%
   summarize(b_u = mean(rating - mu_hat - b_i))

# Compute the predicted ratings on validation dataset

rmse_movie_user_model <- validation %>%
   left_join(movie_avgs, by='movieId') %>%
   left_join(user_avgs, by='userId') %>%
   mutate(pred = mu_hat + b_i + b_u) %>%
   pull(pred)

rmse_movie_user_model_result <- RMSE(validation$rating, rmse_movie_user_model)

# Adding the results to the results dataset

results <- results %>% add_row(model="Movie+User Based Model", RMSE=rmse_movie_user_model_result)

genre_pop <- edx %>%
   left_join(movie_avgs, by='movieId') %>%
   left_join(user_avgs, by='userId') %>%
   group_by(genre) %>%
   summarize(b_u_g = mean(rating - mu_hat - b_i - b_u))

# Compute the predicted ratings on validation dataset

rmse_movie_user_genre_model <- validation %>%
   left_join(movie_avgs, by='movieId') %>%
   left_join(user_avgs, by='userId') %>%
   left_join(genre_pop, by='genre') %>%
   mutate(pred = mu_hat + b_i + b_u + b_u_g) %>%
   pull(pred)

rmse_movie_user_genre_model_result <- RMSE(validation$rating, rmse_movie_user_genre_model)

# Adding the results to the results dataset

results <- results %>% add_row(model="Movie+User+Genre Based Model", RMSE=rmse_movie_user_genre_model_result)

lambdas <- seq(0, 10, 0.1)

# Compute the predicted ratings on validation dataset using different values of lambda

rmses <- sapply(lambdas, function(lambda) {
   
  # Calculate the average by user
  
   b_i <- edx %>%
      group_by(movieId) %>%
      summarize(b_i = sum(rating - mu_hat) / (n() + lambda))
   
   # Compute the predicted ratings on validation dataset
   
   predicted_ratings <- validation %>%
      left_join(b_i, by='movieId') %>%
      mutate(pred = mu_hat + b_i) %>%
      pull(pred)
   
   # Predict the RMSE on the validation set
   
   return(RMSE(validation$rating, predicted_ratings))
})


# Get the lambda value that minimize the RMSE
min_lambda <- lambdas[which.min(rmses)]

# Predict the RMSE on the validation set

rmse_regularized_movie_model <- min(rmses)

# Adding the results to the results dataset

results <- results %>% add_row(model="Regularized Movie-Based Model", RMSE=rmse_regularized_movie_model)

rmses <- sapply(lambdas, function(lambda) {

   # Calculate the average by user
   
   b_i <- edx %>%
      group_by(movieId) %>%
      summarize(b_i = sum(rating - mu_hat) / (n() + lambda))
   
   # Calculate the average by user
   
   b_u <- edx %>%
      left_join(b_i, by='movieId') %>%
      group_by(userId) %>%
      summarize(b_u = sum(rating - b_i - mu_hat) / (n() + lambda))
   
   # Compute the predicted ratings on validation dataset
   
   predicted_ratings <- validation %>%
      left_join(b_i, by='movieId') %>%
      left_join(b_u, by='userId') %>%
      mutate(pred = mu_hat + b_i + b_u) %>%
      pull(pred)
   
   # Predict the RMSE on the validation set
   
   return(RMSE(validation$rating, predicted_ratings))
})

# Get the lambda value that minimize the RMSE

min_lambda <- lambdas[which.min(rmses)]

# Predict the RMSE on the validation set

rmse_regularized_movie_user_model <- min(rmses)

# Adding the results to the results dataset

results <- results %>% add_row(model="Regularized Movie+User Based Model", RMSE=rmse_regularized_movie_user_model)

lambdas <- seq(0, 15, 0.1)

# Compute the predicted ratings on validation dataset using different values of lambda

rmses <- sapply(lambdas, function(lambda) {

   # Calculate the average by user
   
   b_i <- edx %>%
      group_by(movieId) %>%
      summarize(b_i = sum(rating - mu_hat) / (n() + lambda))
   
   # Calculate the average by user
   
   b_u <- edx %>%
      left_join(b_i, by='movieId') %>%
      group_by(userId) %>%
      summarize(b_u = sum(rating - b_i - mu_hat) / (n() + lambda))
   
    b_u_g <- edx %>%
      left_join(b_i, by='movieId') %>%
      left_join(b_u, by='userId') %>%
      group_by(genre) %>%
      summarize(b_u_g = sum(rating - b_i - mu_hat - b_u) / (n() + lambda))
   
   # Compute the predicted ratings on validation dataset
   
   predicted_ratings <- validation %>%
      left_join(b_i, by='movieId') %>%
      left_join(b_u, by='userId') %>%
      left_join(b_u_g, by='genre') %>%
      mutate(pred = mu_hat + b_i + b_u + b_u_g) %>%
      pull(pred)
   
   # Predict the RMSE on the validation set
   
   return(RMSE(validation$rating, predicted_ratings))
})

# Get the lambda value that minimize the RMSE

min_lambda <- lambdas[which.min(rmses)]

# Predict the RMSE on the validation set

rmse_regularized_movie_user_genre_model <- min(rmses)

# Adding the results to the results dataset

results <- results %>% add_row(model="Regularized Movie+User+Genre Based Model", RMSE=rmse_regularized_movie_user_genre_model)