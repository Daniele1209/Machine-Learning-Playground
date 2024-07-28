# Automobile dataset 

data("mtcars")
View(mtcars)
head(mtcars)

# select fields of interest
# cyl, vs, am, gear

library("dplyr")

car_df <- mtcars |>
  mutate(
    cyl = factor(cyl),
    vs = factor(vs, levels=c(0, 1), labels=c("V", "S")),
    am = factor(am, levels=c(0, 1), labels=c("automatic", "manual")),
    gear = factor(gear)
  )

head(car_df)

# full additive linear model (lm)
car_lm <- lm(mpg ~ ., data=car_df)
summary(car_lm)

# coef for value `disp` = 0.0125
# it is not statistically significant for the outcome of the response variable at 5% sign level
# if all other variables would remain constant and disp would change by one unit,
# the expected change in output is 0.0125 - not stat sign

# interpretation for `cyl`
# values for cyl6 and cyl8 are relative to cyl4 
# if all other variables are held constant,
# the expected change in `mpg` if cyl changes from 4 to 6 is -1.1994
# the expected change in `mpg` if cyl changes from 4 to 8 is 3.0549

# none of the predictors are statistically significant at alpha=5% 
drop1(car_lm, test = 'F')

pf(q=summary(car_lm)$fstatistic[["value"]], df1=12, df2=19, lower.tail=FALSE)
