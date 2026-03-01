library(tidyverse)
library(moments)
library(ggpubr)
library(gridExtra)


# data
set.seed(999)
n <- 500 
health_data <- data.frame(
  Patient_id = 1:n,
  Age = round(runif(n, 18, 80)),
  Treatment_group = sample(c("Drug_A", "Drug_B", "Placebo"), n, replace = TRUE),
  Dosage_mg = round(runif(n, 50, 200))
)
#View(health_data)


# make Recovery_Time
health_data <- health_data %>%
  mutate(Recovery_Days = 15 + (Age * 0.1) - (ifelse(Treatment_group == "Drug_A", 5, ifelse(Treatment_group == "Drug_B", 3, 0))) + 
           rnorm(n(), mean = 0, sd = 2))
#view(health_data)


# Normality Check  (histogram & Q-Q plot)
# histogram 
p1 <- ggplot(health_data, aes(x = Recovery_Days)) + 
  geom_histogram(aes(y = ..density..), bins = 30, fill = "steelblue", alpha = 0.6) +
  geom_density(color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Recovery Days Distribution", x = "Recovery Days", y = "Density")

# Q-Q plot 
p2 <- ggplot(health_data, aes(sample = Recovery_Days)) +
  stat_qq(color = "steelblue", alpha = 0.6) + 
  stat_qq_line(color = "red", size = 1) + 
  theme_minimal() +
  labs(title = "Normal Q-Q Plot",
       subtitle = "Dots on the red line = Normal Data",
       x = "Theoretical", y = "Sample")

combined_normality_plot <- grid.arrange(p1, p2, ncol = 2)
ggsave("normality_analysis.png", combined_normality_plot, width = 10, height = 5)



# Hypothesis testing 
anova_result <- aov(Recovery_Days ~ Treatment_group, data = health_data)
summary(anova_result)


# post-hook analysts (tukey HSD)
tukey_test <- TukeyHSD(anova_result)
print(tukey_test)


# visualization - 2 ((Boxplot with Jitter))
p3 <- ggplot(health_data, aes(x = Treatment_group, y = Recovery_Days, fill = Treatment_group)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.2) +
  theme_classic()+
  labs(title = "Treatment Efficacy Comparison",
       subtitle = "Boxplot showing distribution of recovery days across drug groups",
       x = "Drug Type", y = "Recovery Days")


ggsave("treatment_efficacy.png", p3, width = 8, height = 5)

# correlation and regression 
regression_model <- lm(Recovery_Days ~ Age + Dosage_mg + Treatment_group, data = health_data)
model_summary <- summary(regression_model)
print(model_summary)


# probability calculation 
avg_recovery <- mean(health_data$Recovery_Days)
sd_recovery <- sd(health_data$Recovery_Days)
prob_fast_recovery <- pnorm(avg_recovery - 2, mean = avg_recovery, sd = sd_recovery)

print(paste("Probability of recovering 2 days faster than average:", 
            round(prob_fast_recovery * 100, 2), "%"))







