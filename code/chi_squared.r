### SETUP ###
# imports
library(irr)
library(dplyr)
library(report)

# set working directory
setwd('insert/path/here]')

# ENGLISH DATA
combined = read.csv("annotations_EN_majorityvotes.csv")
combined$ref_mv <- factor(combined$ref_mv, levels = c("yes", "no", "NULL"))


# GERMAN DATA
data_de <- read.csv("annotations_DE.csv")
data_de$ante_gender <- factor(data_de$ante_gender, levels = c("masc", "fem", 
                                                              "coord_m", "coord_f",
                                                              "big_i", "colon",
                                                              "star", "underscore"))
data_de$gender <- factor(data_de$gender, 
                         levels = c("feminine", "masculine", "neutral", "masc_fem"))
data_de$ref <- data_de$ref %>% factor(levels= c("yes", "no"))


# STATS - Chi-squared test

ftable(combined$ref_mv,combined$ante_gender,combined$gender_mv)

# ENGLISH
table(combined$ref_mv)
table(combined$ante_gender, combined$ref_mv, combined$gender_mv)
test <- chisq.test(table(combined$ante_gender, combined$gender_mv))
test
report(test)

combined_coref <- combined %>% filter(ref_mv == 'yes')
combined_nocoref <- combined %>% filter(ref_mv == 'no')

# no coreference 
test <- chisq.test(table(combined_nocoref$ante_gender, combined_nocoref$gender_mv))
test
report(test)

# coreference
test <- chisq.test(table(combined_coref$ante_gender, combined_coref$gender_mv))
test
report(test)

# GERMAN

table(data_de$ref)

data_de_coref <- data_de %>% filter(ref == 'yes')
data_de_nocoref <- data_de %>% filter(ref == 'no')

# coreference
table(data_de_coref$ante_gender, data_de_coref$gender)
test <- chisq.test(table(data_de_coref$ante_gender, data_de_coref$gender))
test
report(test)

# no coreference
test <- chisq.test(table(data_de_nocoref$ante_gender, data_de_nocoref$gender))
test
report(test)

