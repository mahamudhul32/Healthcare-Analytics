library(tidyverse)
library(moments)


set.seed(999)
n <- 500 
health_data <- data.frame(
  Patient_id = 1:n,
  Age = round(runif(n, 18, 80)),
  Treatment_group = sample(c("Drug_A", "Drug_B", "Placebo"), n, replace = TRUE),
  Dosage_mg = round(runif(n, 50, 200))
)
View(health_data)


# make Recovery_Time
health_data <- health_data %>%
  mutate(Recovery_Days = 15 + (Age * 0.1) - (ifelse(Treatment_group == "Drug_A", 5, ifelse(Treatment_group == "Drug_B", 3, 0))) + 
           rnorm(n(), mean = 0, sd = 2))
view(health_data)



ggplot(health_data, aes(x = Recovery_Days)) + 
  geom_histogram(aes(y = ..density..), fill = "steelblue", alpha = 0.6) +
  geom_density(color = "red", size = 1 ) +
  labs(title = "Recovery Time Distribution")

#probability 
prob_less_10 = pnorm(10, mean = mean(health_data$Recovery_Days), sd = sd(health_data$Recovery_Days))
print(prob_less_10)


# Hypothesis testing 
anova_result <- aov(Recovery_Days ~ Treatment_group, data = health_data)
summary(anova_result)



# correlation and regression 
regression_model <- lm(Recovery_Days ~ Age + Dosage_mg, data = health_data)
summary(regression_model)




