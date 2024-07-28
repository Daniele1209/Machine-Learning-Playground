# Logistic regression

# Titanic Dataset
install.packages("titanic")
library(titanic)

head(titanic_train)

# transform into categorical data for the 3 classes
titanic_train$Pclass <- factor(titanic_train$Pclass)

set.seed(41)
# fit a logistic model (sex, age, class) -> survived
log_model <- glm(Survived ~ Sex + Age + Pclass, data=titanic_train, family="binomial")
summary(log_model)
log_model$coefficients

odds <- exp(log_model$coefficients[2])
odds

install.packages("emmeans")
library(emmeans)

log_model$coefficients
log_model$coefficients["Pclass2"]
log(1 - log_model$coefficients["Pclass2"])

odds_ratio_class <- exp(coef(log_model)["Pclass2"])
odds_ratio_class # this is for class 1, compute for each of the 3

# logistic regression with 2 way interaction between class and sex
way2_log_model <- glm(Survived ~ Sex + Age + Pclass + Pclass * Sex, data=titanic_train, family="binomial")
summary(way2_log_model)

# Analysis of deviance between models
anova(log_model, way2_log_model, test="Chisq")
# -> Resid. Dev (first 647.28 - second 613.43) = 33.856

# Compute the difference in survival rates of two sexes
exp(summary(way2_log_model)$coefficients["Sexmale", "Estimate"])


# Agresti (p. 204) describes data on 35 patients who received general anesthesia for surgery
# dataset
duration<-c(45,15,40,83,90,25,35,65,95,35,75,45,50,75,
            30,25,20,60,70,30,60, 61,65,15,20,45,15,25,
            15,30,40,15,135,20,40)
type<-c("M","M","M","T","T","T",rep("M",5),"T","T","T","M","M","T","T","T",
        rep("M",4),"T","T","M","T","M","T","M","M",rep("T",4))
sore<-c(0,0,rep(1,10),0,1,0,1,0,rep(1,4),0,1,0,0,1,0,1,0,1,1,0,1,0,0)
sore.fr<-as.data.frame(cbind(duration, type, sore))
xtabs(~sore+type,data=sore.fr)

# Fit a logistic regression model to investigate whether the surgery duration and anesthesia type have a significant effect 
log_anestesia <- glm(sore ~ duration + type, family="binomial")
summary(log_anestesia)

# Multiple linear regression
filename <- file.choose()
prostate <- read.table(filename, header = TRUE)
head(prostate)
prostate_df <- prostate[1:9]
head(prostate_df)

# Compute the correlation matrix of the data
cor_matrix <- cor(prostate_df)
print(cor_matrix)

install.packages("GGally")
library(GGally)

ggpairs(prostate_df, title = "Scatter Plot Matrix")
# all variables seem highly correlated with lpsa (response), but age and lbph
