library(datasets)
data(iris)

# Q1 There will be an object called 'iris' in your workspace. 
# In this dataset, what is the mean of 'Sepal.Length' for the species virginica?
# Please round your answer to the nearest whole number.

mean(iris[iris$Species == "virginica",]$Sepal.Length)
tapply(iris$Sepal.Length, iris$Species, mean)

# Q2 Continuing with the 'iris' dataset from the previous Question, 
# what R code returns a vector of the means of the variables 
# 'Sepal.Length', 'Sepal.Width', 'Petal.Length', and 'Petal.Width'?


apply(iris[, 1:4], 2, mean)


# Q3 How can one calculate the average miles per gallon (mpg) 
# by number of cylinders in the car (cyl)? Select all that apply.
library(datasets)
data(mtcars)


sapply(split(mtcars$mpg, mtcars$cyl), mean)
tapply(mtcars$mpg, mtcars$cyl, mean)
#don't need to retype the name of the data frame for every time you 
# reference a column
with(mtcars, tapply(mpg, cyl, mean))


#what is the absolute difference between the average horsepower 
#of 4-cylinder cars and the average horsepower of 8-cylinder cars?
new <- tapply(mtcars$hp, mtcars$cyl, mean)
round(abs(new[3]-new[1]))

