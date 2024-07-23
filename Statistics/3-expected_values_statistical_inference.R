# Exponential Distribution
exp_dist_density <- function(x, lambda) {
  (1/lambda) * exp(-x/lambda)
}

# 1 visualize the dist for lambdas
library("ggplot2")
lambdas = c(0.1, 1, 10)


ggplot() +
  xlim(.05, 5) +
  purrr::map(.x=c(0.1, 1, 10),
             .f = ~ geom_function(fun=exp_dist_density, 
                                  mapping=aes(color=as.character(.x)),
                                  args=list(lambda=.x))) +
  labs(y = "Density", x = "x")

# visualize the log-likelihood function with a concrete sample

# Draw a normal sample x with μ=3 and σ2=4 of size n=13

# Plot the log-likelihood function for this sample as a function of σ2 with μ=x¯ fixed
set.seed(1234)
log_likelihood <- function(mu, variance, x) {
  -(length(x)/2) * log(2 * pi) - (length(x)/2) * log(variance) - (1/(2*variance)) * sum((x-mu)^2)
}

x <- rnorm(n=13, mean=3, sd=2)

ggplot() +
  xlim(1, 10) +
  geom_function(fun=log_likelihood, args=list(mu=mean(x), x=x)) +
  labs(x="variance", y="log-likelihood")

# Confidence Intervals

# Implement a function that – given the sample data and α – returns the estimated 
# mean and its (1-α)-confidence interval and the width of the confidence interval.
estimated_mean <- function(sample, alpha) {
  smean = mean(sample)
  stdev = sd(sample)
  t_term = qt(p=(1-alpha/2), df=length(sample)-1)
  quantile1 = smean - t_term * (stdev/sqrt(length(sample)))
  quantile2 = smean + t_term * (stdev/sqrt(length(sample)))
  return(list(mean=smean, ci=c(quantile1, quantile2), ci.width=diff(c(quantile1, quantile2))))
}

# Draw samples of size n={2,3,5,10,25,100,500,1000} from a normal distribution 
# with fixed μ=0 and variance σ2=4
# width of the CI with fixed α=0.05 depends on the sample size n

library("tibble")

set.seed(98765) #reproducible "randomness"
resN <- tibble(n = c(2, 3, 5, 10, 25, 100, 500, 1000)) |>
dplyr::rowwise() |> 
dplyr::mutate(width = estimated_mean(sample = rnorm(n=n, sd=2), alpha = .05)$ci.width)

ggplot(resN, mapping = aes(x=n, y=width)) + 
  geom_line() + geom_point() + 
  scale_y_log10(name = "Width of CI") +
  labs(title = "Effect of sample size", x = "n")

# see effect of variability
set.seed(98765)
resSD <- tibble(sigma = c(.5, 1, 4, 9, 25, 50)) |>
dplyr::rowwise() |>
dplyr::mutate(width = estimated_mean(sample = rnorm(n=25, sd=sqrt(sigma)), alpha = .05)$ci.width)

ggplot(resSD, mapping = aes(x=sigma, y=width)) + 
  geom_line() + geom_point() + 
  scale_y_log10(name = "Width of CI") +
  labs(title = "Effect of var", x = "n")

# see effect of alpha
set.seed(98765)
resA <- tibble(alph = c(0.001,0.01,0.05,0.1,0.15,0.2,0.25)) |>
  dplyr::rowwise() |>
  dplyr::mutate(width = estimated_mean(sample = rnorm(n=25, sd=2), alpha = alph)$ci.width)

ggplot(resA, mapping = aes(x=alph, y=width)) + 
  geom_line() + geom_point() + 
  scale_y_log10(name = "Width of CI") +
  labs(title = "Effect of alpha", x = "n")
