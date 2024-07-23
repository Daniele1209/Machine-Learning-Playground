# Density function for normally distributed random variable X

density_function <- function(x, mu=52, variance=4) {
  1/sqrt(2*pi*variance) * exp(-(x - mu)^2/(2*variance))
}

plot_density <- function() {
  print(density_function(c(47, 50, 52, 54, 55)))
  ggplot() +
    xlim(40, 65) +
    geom_function(fun=density_function) +
    labs(x="Value", y="Density")
}

draw_sample <- function(n, mean=52, sd=2, seed=111) {
  # use rnorm to pull random samples from the normal distribution
  set.seed(seed)
  x <- rnorm(n, mean, sd)
  
  print(c(sample_mean=mean(x, trim=0.1), sample_var = var(x)))
}

# 1 plot density function
plot_density()

# 2 probability to have <= 54
integrate(density_function, -Inf, 54)

# 3 probability in interval 48, 56
integrate(density_function, 48, 56)

# 4 calculations in R
# use p-norm - probability of normal function
# standard dev is 2 <- variance = 4
pnorm(q=54, mean=52, sd=2)

pnorm(q=56, mean=52, sd=2) - pnorm(q=48, mean=52, sd=2)

# According to the Gliwenko Cantelli theorem the sample estimators like mean and variance
# (understood as random variables) will converge uniformly to the underlying 
# parameter values from the true distribution with increasing n

draw_sample(n=10, seed=41)
draw_sample(n=100, seed=41)
draw_sample(n=1000, seed=41)
draw_sample(n=10000, seed=41)
draw_sample(n=100000, seed=41)



