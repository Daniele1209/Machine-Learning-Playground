# Independent events
# What is the probability to throw at least one ⚅ in 5 rolls of a regular fair dice 
# with six faces? Can you deduce the functional relationship that links number of rolls to the probability? Plot it

library("ggplot2")

oneOfSix <- function(x) {
  return(1 - (5/6)^x)
}

ggplot() +
  xlim(1, 30) +
  geom_function(fun=oneOfSix) +
  geom_point(mapping=aes(x=5, y=oneOfSix(5))) +
  labs(x="Number of tosses", y="At least a six")

# Reliability Theory
# compare two air plane designs with respect to their safety:
# 1 a three-engine design with a main engine and two side engines. It will crash when either the main engine fails or both side engines.
# 2 a four-engine design with two side engines on the left and the right. The plane crashes if both engines of one side fail.

#install.packages("purrr")

saftyFun <- function(p, alpha) {
  return(p*(alpha-p-alpha*p^2+p^3))
}

ggplot() + xlim(0, 1) + 
  geom_hline(yintercept = 0, linetype = 'dashed', colour = 'grey') +
  purrr::map(.x = c(0.2, .1, .05),
             .f = ~ geom_function(mapping = aes(colour = as.character(.x)),
                                  fun = saftyFun, args = list(alpha = .x))) + 
  labs(x = 'Crash probability p of side engine',
       # expression() in plot labels allow for math-expressions
       # see help page for `plotmath`: ?plotmath
       y = expression(paste(f[alpha](p))),
       colour = expression(alpha * ' = '),
       title = expression('4-engine safer than 3-engine plane when p < ' * alpha),
       subtitle = expression('Shown is function ' * f == P(C[3]) - P(C[4])))