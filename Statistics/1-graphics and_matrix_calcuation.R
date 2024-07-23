#install.packages('patchwork')

library("ggplot2")

# load Malginant Melanoma Study dataset
data("USmelanoma", package = "HSAUR3")

# Make a histogram and a boxplot for the observed mortality rates across all US-states.
#Interpret the plots. Also add a title to the plots.

ggplot(data = USmelanoma, mapping = aes(y=mortality)) +
  geom_boxplot() + 
  labs(x="mortality", 
       title="Mortality rate per 10 million of white males due to malignant melanoma")

ggplot(data = USmelanoma, mapping = aes(x=mortality)) +
  geom_histogram() +
  labs(x="mortality", 
       title="Mortality rate per 10 million of white males per state")


# code for agregating blox plot
ggp <- ggplot(USmelanoma, aes(x=mortality)) +
  xlim(80.5, 234.5) +
   theme_void()
 
ggp + geom_boxplot() +
   labs(x=NULL)
   
# box plot comparison for ocean and non-ocean
ggplot(data=USmelanoma, mapping=aes(x=ocean, y=mortality)) +
  geom_boxplot() +
  labs(x="ocean", y="mortality rates")

# Density plots
# A density plot is similar but instead of binning the distribution density f
# is estimated as a smooth line. Using a sliding window approach, for a point x
#only observations from the its near neighbourhood are considered for the density estimation f(x)
ggplot(data=USmelanoma, mapping=aes(x=mortality, color=ocean)) + 
  geom_density() +
  labs(title = 'Mortality Rate', colour = 'Contiguous to\nocean?')

# Scatter plots
# Consider now the influence of the geographic location of the states on mortality rate. 
# All three variables longitude, latitude and mortality are on metric scale, so scatterplots are a suitable to visualize the bivariate relationships. 
# As mortality is our variable of interest it should go on the y-axis.
ggp <- ggplot(data=USmelanoma, mapping=aes(y=mortality, color=ocean, shape=ocean))
ggp1 <- ggp +
  geom_point(mapping=aes(x=longitude))
ggp2 <- ggp +
  geom_point(mapping=aes(x=latitude))

library("patchwork")
ggp1 + ggp2 + 
  plot_layout(nrow = 1, heights = c(1, 4))

# Imagine that it is known that a hospital has a capacity of 580 beds which are
#distributed in 200 rooms that are equipped with either two or three beds.
# x = number or rooms with 2 beds
# y = number or rooms with 3 beds
# x * 2 + y * 3 = 580
# x + y = 200

A <- matrix(c(2, 3, 1, 1), nrow=2, byrow = TRUE)
b <- c(580, 200)
sol <- solve(A, b)
sol