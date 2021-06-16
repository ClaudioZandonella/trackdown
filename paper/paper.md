---
title: 'PRDA: An R package for Prospective and Retrospective Design Analysis'
tags:
  - R
  - design analysis
  - power analysis
  - Type M error
  - Type S error
  - replicabiliyt
authors:
  - name: Claudio Zandonella Callegher
    orcid: 0000-0001-7721-6318
    affiliation: 1
  - name: Giulia Bertoldo
    orcid: 0000-0002-6960-3980
    affiliation: 1
  - name: Enrico Toffalini
    orcid: 0000-0002-1404-5133
    affiliation: 3
  - name: Anna Vesely
    orcid: 0000-0001-6696-2390
    affiliation: 2
  - name: Angela Andreella
    orcid: 0000-0002-1141-3041
    affiliation: 2
  - name: Massimiliano Pastore
    orcid: 0000-0002-7922-6365
    affiliation: 1
  - name: Gianmarco Altoè
    orcid: 0000-0003-1154-9528
    affiliation: 1
affiliations:
 - name: Department of Developmental Psychology and Socialisation, University of Padova, Padova, Italy
   index: 1
 - name: Department of Statistical Sciences, University of Padova, Padova, Italy
   index: 2
 - name: Department of General Psychology, University of Padova, Padova, Italy
   index: 3
date: "10 December, 2020"
bibliography: paper_JOSS.bib
editor_options: 
  chunk_output_type: console
---




# Summary

*Design Analysis* was introduced by @gelmanPowerCalculationsAssessing2014 as an extension of Power Analysis. Traditional power analysis has a narrow focus on statistical significance. Design analysis, instead, evaluates together with power levels also other inferential risks (i.e., Type M error and Type S error), to assess estimates uncertainty under hypothetical replications of a study.

Given an hypothetical value of effect size and study characteristics (i.e., sample size, statistical test directionality, significance level),
*Type M error* (Magnitude, also known as Exaggeration Ratio) indicates the factor by which a statistically significant effect is on average exaggerated. *Type S error* (Sign), instead, indicates the probability of finding a statistically significant result in the opposite direction to the hypothetical effect.

Although Type M error and Type S error depend directly on power level, they underline valuable information regarding estimates uncertainty that would otherwise be overlooked. This enhances researchers awareness about the inferential risks related to their studies and helps them in the interpretation of their results. However, design analysis is rarely applied in real research settings also for the lack of dedicated software.

To know more about design analysis consider @gelmanPowerCalculationsAssessing2014 and @luNoteTypeErrors2018. While, for an introduction to design analysis with examples in psychology see @altoeEnhancingStatisticalInference2020 and  @bertoldoDesigningStudiesEvaluating2020.


# Statement of need 

`PRDA` is an R package performing prospective or retrospective design analysis to evaluate inferential risks (i.e., power, Type M error, and Type S error) in a study considering Pearson's correlation between two variables or mean comparisons (one-sample, paired, two-sample, and Welch's *t*-test). *Prospective Design Analysis* is performed in the planning stage of a study to define the required sample size to obtain a given level of power. *Retrospective Design Analysis*, instead, is performed when the data have already been collected to evaluate the inferential risks associated with the study.

Another recent R package, `retrodesign` [@timmRetrodesignToolsType2019], allows conducting retrospective design analysis considering estimate of the unstandardized effect size (i.e., regression coefficient or mean difference) and standard error of the estimate. `PRDA` package, instead, considers standardized effect size (i.e., Pearson correlation coefficient or Cohen's *d*) and study sample size. These are more commonly used in research fields such as Psychology or Social Science, and therefore are implemented in `PRDA` to facilitate researchers' reasoning about design analysis. `PRDA`, additionally, offers the possibility to conduct a prospective design analysis and to account for the uncertainty about the hypothetical value of effect size. In fact, hypothetical effect size can be defined as a single value according to previous results in the literature or experts indications, or by specifying a distribution of plausible values.

The package is available from GitHub (https://github.com/ClaudioZandonella/PRDA) and CRAN (https://CRAN.R-project.org/package=PRDA). Documentation about the package is available at https://claudiozandonella.github.io/PRDA/.

# Examples

Imagine a study evaluating the relation a given personality trait (e.g., introversion) and math performance. Suppose that 20 participants were included in the study and results indicated a statistically significant correlation (e.g, $r = .55, p = .012$). The magnitude of the estimated correlation, however, is beyond what could be considered plausible in this field. 

## Retrospective design analysis

Suppose previous results in the literature indicate correlations in this area are more likely to be around $\rho = .25$. To evaluate the inferential risks associated with the study design, we can use the function `retrospective()`.


```r
library(PRDA)

set.seed(2020) # set seed to make results reproducible

retrospective(effect_size = .25, sample_n1 = 20, test_method = "pearson")
```

```
## 
## 	Design Analysis
## 
## Hypothesized effect:  rho = 0.25 
## 
## Study characteristics:
##    test_method   sample_n1   sample_n2   alternative   sig_level   df
##    pearson       20          NULL        two_sided     0.05        18
## 
## Inferential risks:
##    power   typeM   typeS
##    0.185   2.161   0.008
## 
## Critical value(s): rho  =  ± 0.444
```

In the output, we have the summary information about the hypothesized population effect, the study characteristics, and the inferential risks. We obtained a statistical power of almost 20% that is associated with a Type M error of around 2.2 and a Type S error of 0.01. That means, statistical significant results are on average an overestimation of 120% of the hypothesized population effect and there is a 1% probability of obtaining a statistically significant result in the opposite direction. To know more about function arguments and examples see the function documentation and vignette.

### Effect size distribution

Alternatively, if no precise information about hypothetical effect size is available, researchers could specify a distribution of values  to account for their uncertainty. For example, they might define a normal distribution with mean of .25 and standard deviation of .1, truncated between .10 and 40.


```r
retrospective(effect_size = function(n) rnorm(n, .25, .1), sample_n1 = 20,
              test_method = "pearson", tl = .1, tu = .4, B = 1e3, 
              display_message = FALSE)
```

```
## Truncation could require long computational time
```

```
## 
## 	Design Analysis
## 
## Hypothesized effect:  rho ~ rnorm(n, 0.25, 0.1) [tl =  0.1 ; tu = 0.4 ]
##    n_effect   Min.    1st Qu.   Median   Mean    3rd Qu.   Max.
##    1000       0.101   0.197     0.25     0.252   0.308     0.4 
## 
## Study characteristics:
##    test_method   sample_n1   sample_n2   alternative   sig_level   df
##    pearson       20          NULL        two_sided     0.05        18
## 
## Inferential risks:
##         Min.    1st Qu.   Median   Mean       3rd Qu.   Max. 
## power   0.055   0.133     0.1880   0.203727   0.26600   0.449
## typeM   1.407   1.785     2.1645   2.347745   2.70075   5.263
## typeS   0.000   0.000     0.0060   0.017573   0.02300   0.246
## 
## Critical value(s): rho  =  ± 0.444
```

Consequently this time we obtained a distribution of values for power, Type M error, and Type S error. Summary information are provided in the output.

## Prospective design analysis

Given the previous results, researchers might consider planning a replication study to obtain more reliable results. The function `prospective()` can be used to compute the sample size needed to obtain a given level of power (e.g., power = 80%).


```r
prospective(effect_size = .25, power = .8, test_method = "pearson",
            display_message = FALSE)
```

```
## 
## 	Design Analysis
## 
## Hypothesized effect:  rho = 0.25 
## 
## Study characteristics:
##    test_method   sample_n1   sample_n2   alternative   sig_level   df 
##    pearson       122         NULL        two_sided     0.05        120
## 
## Inferential risks:
##    power   typeM   typeS
##    0.796   1.12    0    
## 
## Critical value(s): rho  =  ± 0.178
```

In the output, we have again the summary information about the hypothesized population effect, the study characteristics, and the inferential risks. To obtain a power of around 80% the required sample size is $n = 122$, the associated Type M error is around 1.10 and the Type S error is approximately 0. To know more about function arguments and examples see the function documentation and vignette.

In `PRDA` there are no implemented functions to obtain graphical representations of the results. However, it is easy to access all the results and use them to create the plots according to your own needs and preferences. See vignettes for an example.




# References



