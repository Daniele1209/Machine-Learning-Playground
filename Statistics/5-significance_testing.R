# Sleep data

# load sleep dataset
data(sleep)
head(sleep)

# violin plot that shows the extra sleep duration of both groups side-by-side
library("ggplot2")

ggplot() +
  geom_violin(data=sleep, mapping=aes(x=group, y=extra)) +
  geom_jitter(data=sleep, mapping=aes(x=group, y=extra), height=0, width=0.1)

# significance test
# welch test
t.test(extra ~ group, data=sleep)

# => while the diff of mean sleep increase from both groups is 1.58
#    it is not statistically significant for a significance level of 5%

# paired t-test
t.test(extra ~ group, data=sleep, paired=TRUE)
# => reject the null hypothesis since p value < 0.05 5% significance level

# plot to see the corresponding IDs
ggplot() +
  geom_violin(data=sleep, mapping=aes(x=group, y=extra)) +
  geom_jitter(data=sleep, mapping=aes(x=group, y=extra,
                                      shape=factor(as.numeric(ID) %% 3),
                                      color=factor(as.numeric(ID) %% 5)),
                                      height=0, width=0.1)

# Lung cancer data

# Binomial test
pi0 = 0.6
N = 811
x = 521
expected_success = N * pi0

stats::dbinom(x, size=N, prob=pi0)

smallOutc <- seq(from = 0, to = floor(expected_success))
# +1e-7 to compensate rounding issues
smallOutc2 <- smallOutc[which(dbinom(smallOutc, size = N, prob = pi0, log=TRUE) <= dbinom(x, size = N, prob = pi0, log=TRUE) + 1e-7)]

pbinom(smallOutc2[length(smallOutc2)], size = N, prob = pi0) + pbinom(x-.1, size = N, prob = pi0, lower.tail = FALSE)

binom.test(x = x, n = N, p = pi0)

sleep$extra[!sleep$group==1]
ys <- sample(sleep$extra)

sleep$group==1
