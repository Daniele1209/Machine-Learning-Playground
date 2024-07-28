# 1 Tooth growth in guinea pigs

data("ToothGrowth")

library("ggplot2")
library(dplyr)
library(patchwork)

tail(ToothGrowth)

print(unique(ToothGrowth["supp"]))

# explore and compare the effects of vitamin C in tooth growth
ggplot(data=ToothGrowth) +
  geom_boxplot(mapping=aes(x=supp, y=len))

# filter by vitamin C supp
VC_subset <- ToothGrowth |>
              dplyr::filter(supp == "VC")
OJ_subset <- ToothGrowth |>
  dplyr::filter(supp == "OJ")

# box plots by supp and by dose
ggplot(data=VC_subset, mapping=aes(x=dose, y=len, color=as.factor(dose))) +
  geom_boxplot() |
ggplot(data=OJ_subset, mapping=aes(x=dose, y=len, color=as.factor(dose))) +
  geom_boxplot()

# scatter by dose and color by supp type
ggplot(data=ToothGrowth, mapping=aes(x=dose, y=len, color=as.factor(supp))) +
  geom_point()

# linear model
simple_lm <- lm(len ~ as.factor(dose) + supp, data=ToothGrowth)
summary(simple_lm)

# analysis of variance
anova(simple_lm)

# interaction linear model
lm_inter_model <- lm(len ~ as.factor(dose) * supp, data=ToothGrowth)
summary(lm_inter_model)

# analysis of variance
anova(lm_inter_model)

# analysis of variance for model comparison
anova(simple_lm, lm_inter_model)

# 2 Weight change on different diets

# load dataset
filename <- file.choose()
weight_data <- read.table(file = filename, header = TRUE, sep=",")
head(weight_data)

library("ggplot2")

ggplot(data=weight_data, mapping=aes(x=as.factor(Country), y=Weight_change, color=Diet)) +
  geom_boxplot()

ggplot(data=weight_data, mapping=aes(x=as.factor(Country), y=Weight_change, color=Diet)) +
  geom_point()

# weight change per diet type is not consistent across all countries

weight_simple_lm <- lm(Weight_change ~ Country + Diet, data=weight_data)
summary(weight_simple_lm)

anova(weight_simple_lm)
# highly significant effect of country on weight change 
# same for diet

weight_joined_lm <- lm(Weight_change ~ Country * Diet, data=weight_data)
anova(weight_joined_lm)
# interaction between Country and Diet is statistically significant for a sign level of 5%

# see the analysis in variance between the 2 models
anova(weight_simple_lm, weight_joined_lm)

# 3 A study on nutrition education
filename <- file.choose()
study_data <- read.table(file = filename, header = TRUE, sep=",")
head(study_data)

ggplot(data=study_data, mapping=aes(y=Calories.per.day, x=Month)) +
  geom_line(mapping=aes(group=Student, color=Student)) +
  facet_wrap( ~ Instruction)

library(nlme)
library(lmerTest)
library(lme4)

mixel_effects_model <- lme(Calories.per.day ~ Instruction + Month + Instruction*Month, data=study_data, random=~1|Student)
summary(mixel_effects_model)
