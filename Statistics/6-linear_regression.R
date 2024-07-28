# Linear Regression

# "Old Faithful" geyser

data(faithful)    ### download the Old-faithful data set from R
attach(faithful)

head(faithful)

# Create a boxplot and a frequency histogram of the inter-eruption time. 
# Can we assume that its distribution is approximately normal?
library("ggplot2")
library("patchwork")

base_gg <- ggplot(data=faithful)

base_gg + geom_boxplot(mapping=aes(y=waiting)) +
base_gg + geom_histogram(mapping=aes(x=waiting))

# based on the plots it looks left-skewed

# scatterplot of eruption duration (on Y-axis) vs waiting time (on X-axis)
base_gg + geom_point(mapping=aes(y=eruptions, x=waiting))

# linear regression between duration and waiting time 
lm_pred <- lm(eruptions ~ waiting, data=faithful)
summary(pred)

base_gg + 
  geom_point(mapping=aes(y=eruptions, x=waiting)) +
  geom_function(fun=\(x) lm_pred$coefficients[1] + lm_pred$coefficients[2] * x, mapping=aes(color="red"))

# Parametric Bootstrap for regression model

# new data subset for erruptions less than 3 minutes
less3faithful <- subset(faithful, faithful$eruptions < 3)

N <- 100
lm_base <- lm(eruptions ~ waiting, data=less3faithful)
init_coef <- coef(lm_base)
init_fit <- fitted(lm_base)
init_resid <- residuals(lm_base)

# bootstrap estimates storing
bootstrap_coefs <- matrix(NA, nrow = N, ncol = 2)

for(i in 1:N) {
  
  # sample with replacement from residuals
  sample_resid <- sample(init_resid, length(init_resid), replace=TRUE)
  
  # pred with adjusted response
  lm_new <- lm((eruptions + sample_resid) ~ waiting, data=faithful)
  
  # store new estimates
  bootstrap_coefs[i, ] <- coef(lm_new)
}

t.test(bootstrap_coefs[,1])
t.test(bootstrap_coefs[,2])