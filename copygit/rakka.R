setwd('/home/t/rallatin')
cs<-scan(file='cors.lst')
hist(log(cs)*40)
max(cs)
library(gamlss)
library(gamlss.dist)
library(gamlss.add)
fit <- fitDist(cs, k = 2, type = "counts", trace = FALSE, try.gamlss = TRUE)

summary(fit)


