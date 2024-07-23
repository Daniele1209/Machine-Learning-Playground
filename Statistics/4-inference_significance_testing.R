# Weibull density visualization

weibull_dist <- function(mu, k, x) {
  k/mu * (x/mu)^(k-1) * exp(-(x/mu)^k)
}

library("ggplot2")

pdata <- expand.grid(shape = c(0.25, 1, 2), scale = c(1,5))

ggplot() +
  xlim(0.08, 9.5) +
  purrr::pmap(pdata,
             .f = ~ geom_function(mapping=aes(color=as.character(.x), linetype = as.character(.y)), fun=weibull_dist, args=list(k=.x, mu=.y)))


# Log-likelihood

# load data for brain tumor
# load("survtime_bt.rds")

log_likelihood <- function(k) {
  mu = 10
  x <- survtime_data
  length(x) * log(k) - (k*length(x)*log(mu)) + (k-1) * sum(log(x)) - 1/(mu^k) * sum(x^k)
}

# vectorize our log-likelihood function to decouple the parameter k and the data vector
ll <- Vectorize(FUN=log_likelihood)

ggplot() +
  xlim(0.25, 1.5) +
  geom_function(fun=ll, args=list())

# find the optimal parameter k for the function (max point in the function)
ll_opt <- optimize(f=ll, interval=c(0.1, 10.0), maximum=TRUE)

ggplot() +
  xlim(0.25, 1.5) +
  geom_function(fun=ll) +
  geom_point(mapping=aes(x=ll_opt$maximum, y=ll_opt$objective)) +
  labs(x = "k", y="objective")


# Significance testing 
data("USmelanoma", package = "HSAUR3")
head(USmelanoma)

ggplot() +
  geom_boxplot(data=USmelanoma, mapping=aes(x=ocean, y=mortality))

# t-test (Welch)
# if we assume that bot ocean and non ocean are normally dist
t.test(mortality ~ ocean, data=USmelanoma)

# U-test
wilcox.test(mortality ~ ocean, data = USmelanoma)