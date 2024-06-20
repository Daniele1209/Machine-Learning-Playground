#install.packages("ggplot2")
library("ggplot2")


# used for reproducibility
set.seed(1289)
data(diamonds, package = "ggplot2")

# randomly sample 20 observations per group defined by color & cut
diam <- diamonds |> dplyr::slice_sample(n=20, by=c(color, cut))

# 1 Base graphics
# left: scatter plot price (y-axis) versus carat (x-axis)
plot(price ~ carat, data = diam)
# right: boxplot price (y-axis) versus cut (x-axis)
boxplot(price ~ cut, data = diam)

# plots with ggplot2

# Scatter plots

# simple histogram for carat 
ggplot(data = diam, mapping = aes(x = carat)) + geom_histogram()
# price distributions between cut and classes
ggplot(data = diam, mapping = aes(x = price, color = cut)) + geom_freqpoly()
# scatter plot y - price | x - weight (carat)
ggplot(data = diam, mapping = aes(x = carat, y = price)) + geom_point()
# Plot price (y-axis) versus weight (x-axis), log-transformed x- & y-axis, fix point color, add a trend line
ggplot(data = diam, mapping = aes(x = carat, y = price)) + 
  geom_point(col = 'orange') + 
  scale_y_continuous(trans='log10') +
  scale_x_continuous(trans='log10') +
  geom_smooth(color = "blue")

# Plot price (y-axis) versus weight (x-axis), color according to cut, log-transformed x- & y-axis
ggplot(data=diam, mapping=aes(x=carat, y=price, color=cut)) +
  geom_point() +
  scale_y_continuous(trans='log10') +
  scale_x_continuous(trans='log10')

# Box plots

#Plot price distribution per cut-group, log-transformed y-axis
ggplot(data = diam, aes(y=price, x=cut)) +
  geom_boxplot() + 
  scale_y_continuous(trans='log10')
  
# Plot price distribution as violin plot per cut-group for all diamonds in diam with weight less than 1.75 carat on log-scale. Separate plots as per diamond color
diam |> 
  dplyr::filter(carat < 1.75)