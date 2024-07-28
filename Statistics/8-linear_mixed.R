# Analysis of Longitudinal Data

install.packages("nlme")
install.packages("lmerTest")
install.packages("lme4")

library(nlme)
library(lmerTest)
library(lme4)


data(Orthodont)
head(Orthodont)

# fit a simple linear regression model: distance vs age
simple_lm <- lm(distance ~ age, data=Orthodont)
summary(simple_lm)

# - model can explain about 25% of var in data (R-squared)
# - model is not good to account for the fact that data is grouped for multiple individuals
# -> use of mixed models

list_lms <- lmList(distance ~ age | Subject, data=Orthodont)
summary(list_lms)

plot(intervals(list_lms))
# there is a lot of variability 

# Linear Mixed-Effects Models
linear_mixed_models <- lme(distance ~ age, data=Orthodont, random= ~age | Subject, method="ML")
summary(linear_mixed_models)


