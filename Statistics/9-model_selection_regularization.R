# Predicting Fat Content of Meat

filename <- file.choose()
nirData <- readRDS(filename)
head(nirData)

print(ncol(nirData)) # 101, 1 being the "fat" column -> 100 NIR variables
print(nrow(nirData["fat"])) # 215 roes for "fat" col

fat_col <- nirData["fat"]
#nirData <- nirData[2:ncol(nirData)]
#head(nirData)

# set aside a subset of 25% of all observations as test data set
# use the remaining 75% as training data

set.seed(2023)
testIdx <- sample(nrow(nirData), size=0.25*nrow(nirData))

nirData_train <- dplyr::slice(nirData, -testIdx)
nirData_test <- dplyr::slice(nirData, testIdx)
#fat_train <- dplyr::slice(fat_col, -testIdx)
#fat_test <- dplyr::slice(fat_col, testIdx)

library("ggplot2")
ggplot(data=fat_col,mapping=aes(x=fat)) +
  geom_density(mapping=aes(color="red"))

# describe values in the "fat" column
mean(nirData_train$fat)
median(nirData_train$fat)
var(nirData_train$fat)

nirVar_train <- nirData_train |>
  dplyr::summarise(across(starts_with("NIR"), .fns=var)) |>
  tidyr::pivot_longer(cols = everything(),
                      names_to = "feature", values_to = "var")
# extract column as a vector
nirVar_train |>
  dplyr::pull(var) |>
  summary()

# correlation matrix (pairwise Pearson correlations between fat and all NIR-features)
nirFeatureCor_train <- cor(nirData_train)
# excerpt of correlation matrix
correlation_matrix <- nirFeatureCor_train[c(1, 2, 16, 31, 51, 81, 101), seq(to = 101, by = 8)] |> 
  signif(digits = 3)

heatmap(correlation_matrix)

# Linear Model
nir_lm <- lm(fat ~ ., data=nirData_train)

summary(nir_lm)

heatmap(cor(dplyr::select(nirData, !fat))[1:5, 1:10])
heatmap(vcov(nir_lm)[2:5,2:9])
heatmap(cov2cor(vcov(nir_lm))[2:5,2:9])

# only 4 predictors (NIR48, NIR40, NIR55, NIR31) are significant at the 5%-significance level

# Variable Selection

# AIC-criterion to decide if dropping or adding a variable improves the model
aic_lm <- step(nir_lm, direction="both", trace=0)
summary(aic_lm)

#final number of coef after AIC
length(coef(aic_lm))

# BIC
bic_lm <- step(nir_lm, k=log(nobs(nir_lm)) ,direction="both", trace=0)
summary(bic_lm)

# Shrinkage Methods

# 10 fold sets
# training data
y_train <- nirData_train |> dplyr::pull(fat)
x_train <- nirData_train |> dplyr::select(!fat) |> as.matrix()

install.packages("glmnet")
library("glmnet")

fm_nir_ridge_cv <- cv.glmnet(x = x_train, y = y_train, alpha = 0)
fm_nir_lasso_cv <- cv.glmnet(x = x_train, y = y_train, alpha = 1)
fm_nir_elnet_cv <- cv.glmnet(x = x_train, y = y_train, alpha = .3)

coef_nir_ridge_cv <- coef(fm_nir_ridge_cv, s = "lambda.1se")
coef_nir_lasso_cv <- coef(fm_nir_lasso_cv, s = "lambda.1se")
coef_nir_elnet_cv <- coef(fm_nir_elnet_cv, s = "lambda.1se")

par(mfrow = c(1, 3)) # three base-plots in a row
plot(fm_nir_ridge_cv, main = "Ridge")
plot(fm_nir_lasso_cv, main = "Lasso")
plot(fm_nir_elnet_cv, main = "Elastic net")

