### SETUP ###
# imports
library(ggplot2)
library(dplyr)
library(car)
library(report)
library(gamlss)
library(visreg)  # package containing visualization function visreg
library(multcomp)
library(agricolae)
library(effects)
library(stringr)
library(rstatix)
library(khroma)


# set working directory
setwd('insert/path/here]')


# GPT-2
file <- "tibblin_EN_templates_logresults_SG_gpt2.csv"
file = "tibblin_EN_templates_logresults_PL_gpt2.csv"

file <- "tibblin_EN_templates_logresults_SG_gpt2-ft3N.csv"
file <- "tibblin_EN_templates_logresults_PL_gpt2-ft3N.csv"

#OLMO
file <- "tibblin_EN_templates_logresults_SG_olmo1B-4bit.csv"
file <- "tibblin_EN_templates_logresults_PL_olmo1B-4bit.csv"

file <- "tibblin_EN_templates_logresults_SG_olmo7B-4bit.csv"
file <- "tibblin_EN_templates_logresults_PL_olmo7B-4bit.csv"

file <- "tibblin_EN_templates_logresults_PL_olmo2-13B-4bit.csv"
file <- "tibblin_EN_templates_logresults_SG_olmo2-13B-4bit.csv"

# Qwen
file <- "tibblin_EN_templates_logresults_PL_qwen32B-4bit.csv"
file <- "tibblin_EN_templates_logresults_SG_qwen32B-4bit.csv"

# DE - Leo Mistral
file <- "tibblin_DE_templates_logresults_PL_leo7B-4bit.csv" # mean token prob
file = "tibblin_DE_templates_logresults_PL_leo7B-4bit_firsttok.csv"


data <- read.csv(file)
data$coref_logprob <- data$coref_prob
data$coref_prob <- exp(data$coref_prob)

# example
data[20, "phrases_cut"]


# set up colorblind-friendly colors
okabe_ito_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
                      "#0072B2", "#D55E00", "#CC79A7")
okabe <- color("okabe ito")


### BOX PLOT ###

# ENGLISH 
ggplot(data, aes(x = coref_gender, y = coref_logprob, fill = coref_gender)) +
  facet_wrap(~ante_gender, labeller = as_labeller(c(f='antecedent female', 
                                                    m='antecedent male',
                                                    n='antecedent neutral')))+
  geom_boxplot()+
  scale_fill_manual(values = okabe_ito_colors)+
  labs(y = "log(p)",
       x = "coreferent gender",
       subtitle = "[MODEL INFO]", #subtitle = "Qwen (32B, 4bit) \U2012 EN SG dataset",
       fill = "coreferent gender") +
  theme_bw(base_size = 20) +
  guides(fill="none")+
  ylim(-12.5,0)


# GERMAN

data$ante_gender <- factor(data$ante_gender) %>% recode(big_i = "capital_I", 
                                                        star = "asterisk")

data$ante_gender <- factor(data$ante_gender, levels = c("masc", "fem", 
                                                        "coord_m", "coord_f",
                                                        "capital_I", "colon",
                                                        "asterisk", "underscore"))

ggplot(data, aes(x = coref_gender, y = coref_logprob, fill = coref_gender)) +
  facet_wrap(~ante_gender, nrow=1)+
  geom_boxplot()+
  scale_fill_manual(values = okabe_ito_colors)+
  labs(y = "log(p)",
       x = "coreferent gender",
       subtitle = "Leo Mistral (7B, 4bit) \U2012 DE PL dataset",
       fill = "coreferent gender") +
  theme_bw(base_size = 17)+
  theme(
    panel.grid.major = element_line(color = "gray90"),
    legend.position = "none")


### DESCRIPTIVE STATISTICS BY GROUP ###


group_by(data, ante_gender, coref_gender) %>%
  summarise(
    mean = mean(coref_prob, na.rm = TRUE),
    sd = sd(coref_prob, na.rm = TRUE)
  )


### ANOVA ###

res_aov <- aov(coref_logprob ~ ante_gender * coref_gender,
               data = data)

summary(res_aov)

report(res_aov)


### POST-HOC ### 
tukey_test <- TukeyHSD(res_aov, which = "ante_gender:coref_gender")

tukey_test

# set axis margins so labels do not get cut off
par(mar = c(4.1, 13.5, 4.1, 2.1))

# create confidence interval for each comparison
plot(tukey_test,
     las = 2 # rotate x-axis ticks
)


### EFFECTS VISUALIZATION ### 
plot(allEffects(res_aov))



### ASSUMPTIONS ###

## 1. NORMALITY of the residuals ##

# but doesn't need to be fulfilled for 2-way ANOVA
# when sample size for each group >30

#par(mfrow = c(1, 2)) # combine plots

# histogram
hist(res_aov$residuals)

# from car package
qqPlot(res_aov$residuals,
       id = FALSE # id = FALSE to remove point identification
)

# alternative qqplot
plot(res_aov, which = 2)

# sample size too big for Shapiro test 
# H0 should not be rejected 
shapiro.test(res_aov$residuals)

# Kolmogorov-Smirnov Tests
# H0 should be rejected
ks.test(res_aov$residuals, "pnorm")


## 2. EQUALITY of VARIANCES (homoscedasticity) ##
# (otherwise Welch's test)

plot(res_aov, which = 3)
