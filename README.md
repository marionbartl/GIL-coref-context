# Gender-inclusive Language in a Coreference Context

This repository holds the code and data used for our paper [Adapting Psycholinguistic Research for LLMs: Gender-inclusive Language in a Coreference Context](https://arxiv.org/abs/2502.13120). 


## Data

The data can be found in the `data` repository. 
The original data from Tibblin et al. (2023) as well as the German and English translations are contained in `tibblin_data_en_de.csv`. The terms used as antecedents are contained in the files `triplets_*.csv`. The templates can be found in `templates_*.csv`.
The original catalogue of gendered terms and gender neutral replacements (Bartl et al., 2024) is contained in the file `replacements+plural-final.csv`. 

The creation of templates and LLM prompts was done in `code/experiments.ipynb` for English and in `code/data_DE.ipynb` for German.


## LLM Experiments

Our LLM experiments are contained in `code/experiments.ipynb`. The code contains cells to specifiy experiment parameters (language, SG or PL, model etc.) and will run the experiments for the specified settings.

## Annotation

The annotations from our three annotators are contained in `results/annotations`. The combination of annotations was done with `code/annotations.ipynb`. We calculated inter-annotator agreeement with `code/annotator_agreement.r`. 

## Statistical Evaluation
We performed $\chi^2$ tests (for the coreferent generation experiments) with `code/chi_squared.r`. The code for the ANOVAs (for the coreferent probability experiments) is contained in `code/anova.r`.