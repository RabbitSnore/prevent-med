# PreventMED - Power Analysis

# Design and Data Structure

The following sections provide brief descriptions of the data structures
for the primary and secondary outcomes.

## Primary Outcome (SOTIPS)

The primary outcome will be measured at baseline, one months, six
months, and twelve months.

We argue that a 5 point reduction in SOTIPS score after 12 months as a
function of the medication would be clinically meaningful. This
corresponds to an average reduction of 0.42 points per month.

The power simulations presented here are based on the following model.

``` r
summary(design_lmm)
```

    Linear mixed model fit by REML ['lmerMod']
    Formula: sotips ~ 1 + measurement * degarelix + measurement * testosterone +  
        measurement * estradiol + (1 | id)
       Data: sim_str

    REML criterion at convergence: 5332.7

    Scaled residuals: 
        Min      1Q  Median      3Q     Max 
    -3.8095 -0.7753 -0.0406  0.7969  4.2682 

    Random effects:
     Groups   Name        Variance Std.Dev.
     id       (Intercept) 15       3.873   
     Residual             16       4.000   
    Number of obs: 720, groups:  id, 180

    Fixed effects:
                             Estimate Std. Error t value
    (Intercept)               0.00000    0.61884   0.000
    measurement              -0.50000    0.05421  -9.224
    degarelix                 0.00000    0.97848   0.000
    testosterone              0.00000    1.07187   0.000
    estradiol                 0.00000    1.07187   0.000
    measurement:degarelix    -0.42000    0.08571  -4.900
    measurement:testosterone -0.10000    0.09389  -1.065
    measurement:estradiol    -0.10000    0.09389  -1.065

    Correlation of Fixed Effects:
                (Intr) msrmnt degrlx tststr estrdl msrmnt:d msrmnt:t
    measurement -0.416                                              
    degarelix   -0.632  0.263                                       
    testosteron  0.000  0.000 -0.548                                
    estradiol    0.000  0.000 -0.548  0.500                         
    msrmnt:dgrl  0.263 -0.632 -0.416  0.228  0.228                  
    msrmnt:tsts  0.000  0.000  0.228 -0.416 -0.208 -0.548           
    msrmnt:strd  0.000  0.000  0.228 -0.208 -0.416 -0.548    0.500  

In this model, “measurement” refers to the amount of time spent (in
months) in the trial. The coefficient of primary interest is the
interaction term between time (measurement) and Degarelix.

The variance components of this model are based on preliminary data from
a different trial with a similar population of participants, adjusted to
be slightly more conservative.

# Power Simulation

## Power to Detect Effects on the SOTIPS

With the assumptions of the model described above, the following
simulation estimates the statistical power for the effect of Degarelix
over time.

This simulation assumes *n* = 60 in the TAU arm and *n* = 120 in the
treatment arm.

``` r
power_simulation
```

    Power for predictor 'measurement:degarelix', (95% confidence interval):
          99.90% (99.44, 100.00)

    Test: t-test with Satterthwaite degrees of freedom (package lmerTest)
          Effect size for measurement:degarelix is -0.42

    Based on 1000 simulations, (0 warnings, 0 errors)
    alpha = 0.05, nrow = 720

    Time elapsed: 0 h 1 m 3 s

If we recruit and retain the full planned sample, we will have
statistical power approaching 100% to detect an effect in a magnitude we
regard as clinically significant.

## Accounting for Data/Power Loss

We can also consider how much power we will have if there is a
substantial attrition rate. The following simulation assumes the loss of
33% of the sample.

``` r
power_simulation_33
```

    Power for predictor 'measurement:conditiontreat_ppdt', (95% confidence interval):
          79.90% (77.28, 82.34)

    Test: t-test with Satterthwaite degrees of freedom (package lmerTest)
          Effect size for measurement:conditiontreat_ppdt is -0.42

    Based on 1000 simulations, (0 warnings, 0 errors)
    alpha = 0.05, nrow = 236

    Time elapsed: 0 h 0 m 53 s

If we have a dropout rate of 33% (equally across conditions), we will
have approximately 80% power to detect a clinically significant effect.
Lower dropout rates will yield higher levels of power. As such,
attrition rates must be quite severe before the study becomes
underpowered to detect relevant effects.
