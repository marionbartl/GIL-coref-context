### SETUP ###
# imports
library(irr)
library(dplyr)
library(ggplot2)
library(report)
library(ggrepel)

# set working directory
setwd('insert/path/here]')

# ENGLISH DATA
combined = read.csv("annotations_EN_majorityvotes.csv")
combined$ref_mv <- factor(combined$ref_mv, levels = c("yes", "no", "NULL"))

# calculcate fleiss' kappa

# gender col
combined %>%
  { .[, c(6, 8, 10)] } %>%
  kappam.fleiss()

# coreference col
combined %>%
  { .[, c(7, 9, 11)] } %>%
  kappam.fleiss()

# display majority votes in a bar chart

table(combined$ante_gender, combined$gender_mv)



# GERMAN DATA
data_de <- read.csv("annotations_DE.csv")
data_de$ante_gender <- factor(data_de$ante_gender, levels = c("masc", "fem", 
                                                              "coord_m", "coord_f",
                                                              "big_i", "colon",
                                                              "star", "underscore"))
data_de$gender <- factor(data_de$gender, 
                         levels = c("feminine", "masculine", "neutral", "masc_fem"))
data_de$ref <- data_de$ref %>% factor(levels= c("yes", "no"))



# Okabe-Ito colors
okabe_ito_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
                      "#0072B2", "#D55E00", "#CC79A7")



### GENDER V COREFERENCE

# Stacked bar chart with faceting and dynamically computed counts
ggplot(combined %>% filter(ref_mv != "NULL"), # remove NULL values
       aes(x = ante_gender, fill = gender_mv)) +
  geom_bar(position = "stack") +  # Automatically computes counts and stacks bars
  geom_text(stat = "count", aes(label = ifelse(..count.. > 2, ..count.., "")),  # Only show labels for counts > 5
            position = position_stack(vjust = 0.5), 
            color = "black", size = 4) +  # Text for each group
  facet_wrap(~ ref_mv, labeller = as_labeller(c(yes = 'coreference', no = 'no coreference'))) +
  labs(
    x = "antecedent gender",
    y = "count",
    fill = "gender in generation",
    title = "Qwen-2.5 (32B) \U2012 Generated gender by antecedent gender",
    #subtitle = "divided by whether or not coreference is present"
  ) +
  theme_bw(base_size = 14) +
  theme(
    panel.grid.major = element_line(color = "gray90"),
    legend.position = "bottom"
  ) +
  scale_fill_manual(values = okabe_ito_colors)


# German
ggplot(data_de, aes(x = ante_gender, fill = gender)) +
  geom_bar(position = "stack") +  # Bar chart with automatic counts
  facet_wrap(~ ref, labeller = as_labeller(c(yes='coreference', no='no coreference'))) +
  geom_text(stat = "count", aes(label = ..count..), 
            position = position_stack(vjust = 0.5), 
            color = "black", size = 4) +  # Text for each group
  labs(x = "antecedent gender", 
       y = "count", 
       title = "Leo Mistral (7B) \U2012 Generated gender by antecedent gender",
       fill = "gender in generation") +
  scale_fill_manual(values = okabe_ito_colors)+
  theme_bw(base_size = 14)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  theme(
    panel.grid.major = element_line(color = "gray90"),
    legend.position = "bottom"
  )


