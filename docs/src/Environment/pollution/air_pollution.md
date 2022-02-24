# Social Cost of Air Pollution

The Value Balancing Alliance methodology recommends to apply dispersion modelling (process from emissions to concentrations) using the Sim-Air ATMoS-4.0 model.
The ATMoS model enables to compute the source-receptor transfer matrix.
The source-receptor transfer matrix presents the incremental change in concentrations due to an incremental change in emissions.

However, we choose to refer here to a reduced for approach, following Muller and Mendelsohn (2007,2009)

We describe here a stylized version of the Air Pollution Emissions Experiments and Policy (APEEP) model for one region.

This approach enables to determine the social cost (or marginal damages) corresponding to emissions of $SO_2$, $VOC$, $NO_x$, $PM_{2.5}$, $PM_{10}$ and $NH_3$.

The computing process of the social cost of air pollution is common to the social cost of carbon:

- Computing a baseline model (a one year model here) with last available data

- Computing a marginal model with 1 tonne of the evaluated pollutant

- Differences between both estimated damages gives the social cost of the pollutant

## The Exposure Component

 

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $Y_t$  |  Gross output   | $Y_t = TFP_t * K_t^\beta * L_t^{(1-\beta)}$    |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $\delta$  |  Depreciation rate on capital  | 


### Exogeneous Variables
| Notation      | Description |  
| ----------- | ----------- |
| $PM_{2.5}$  |  Fine particles or Particulate Matter 2.5  | 
| $PM_{10}$  |  Inhalable particles of Particulate Matter 10   | 
| $SO_2$  |  Sulfur Dioxide   | 
| $NOx$  | Nitrogen Oxides  | 
| $VOC$  |   | 
| $NH_3$  |   | 


## The Human Health Component

Dose-response functions translate ambient concentrations and exposures into various physical effects

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $\frac{Y_1}{Pop}$  | Ratio of persons with chronic exposure mortality due to $PM_{25}$ to total population  |  $\frac{Y_1}{Pop} = exp^{(\alpha_1 + \gamma_1 X + \beta_1 C_{PM_25})}$ |
| $\frac{Y_2}{Pop}$  | Ratio of persons with acute exposure mortality due to $PM_{25}$ to total population  |   |
| $\frac{Y_3}{Pop}$  | Ratio of persons with chronic bronchitis due to $PM_{10}$ to total population  |   |
| $\frac{Y_4}{Pop}$  | Ratio of persons with chronic asthma due to $O_3$ to total population  |   |
| $\frac{Y_5}{Pop}$  | Ratio of persons with chronic respiratory admissions due to $O_3$ to total population  |   |
| $\frac{Y_6}{Pop}$  | Ratio of persons with ER-visits asthma due to $O_3$ to total population  |   |
| $\frac{Y_7}{Pop}$  | Ratio of persons with COPD admissions due to $NO_2$ to total population  |   |
| $\frac{Y_8}{Pop}$  | Ratio of persons with IHD admissions due to $NO_2$ to total population  |   |
| $\frac{Y_9}{Pop}$  | Ratio of persons with asthma admissions due to $SO_2$ to total population  |   |
| $\frac{Y_{10}}{Pop}$  | Ratio of persons with cardiac admissions due to $SO_2$ to total population  |   |

### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $p_1$  |  Chronic mortality value, in USD| 
| $p_2$  |  Acute mortality value, in USD | 
| $p_3$  |  Chronic bronchitis value, in USD | 
| $p_4$  |  Chronic asthma value, in USD | 
| $p_5$  |  General respiratory hopital admission value, in USD | 
| $p_6$  |  General cardiac hopital admission value, in USD | 
| $p_7$  |  Asthma hopital admission value, in USD | 
| $p_8$  |  COPD hopital admission value, in USD | 
| $p_9$  |  Ischemic heart disease hopital admission value, in USD | 
| $p_{10}$  |  Asthma ER visit value, in USD | 

