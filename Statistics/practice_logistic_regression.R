# crash of the NASA space shuttle Challenger on January 28th 1986

filename <- file.choose()
shuttle_data <- read.csv(filename, header=TRUE)
head(shuttle_data)

log_reg <- glm(cbind(damage, 6-damage) ~ temp, data=shuttle_data, family=binomial)
summary(log_reg)

# estimated coef value for `temp` -> -0.021
# it is highly significant at a significance level of 5%

# odds ratio
exp(log_reg$coefficients["temp"])

# => an increase by 1 degree F lowers the odds of failure by 1 - 0.8055471 = 19,45%

# the H0 is that Beta1 = 0 (Beta for temp) 
# in our case P-value is 4.78e-05 -> != 0 -> reject H0 

# compute by hand the probability for 31 degrees
logits <- log_reg$coefficients["(Intercept)"] + 31 * log_reg$coefficients["temp"]
odds <- exp(compute)
probability <- odds / (odds + 1)
probability


1 / (1 + exp(-logits)) 

install.packages("sigmoid")
library(sigmoid)

sigmoid(logits)
