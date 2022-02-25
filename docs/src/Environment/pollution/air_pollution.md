# Social Cost of Air Pollution

The Value Balancing Alliance methodology recommends to apply dispersion modelling (process from emissions to concentrations) using the Sim-Air ATMoS-4.0 model.
The ATMoS model enables to compute the source-receptor transfer matrix.
The source-receptor transfer matrix presents the incremental change in concentrations due to an incremental change in emissions.


## The Exposure Component

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $Pop_{PM_{2.5}}$  | Population exposed to certain threshold of $PM_{2.5}$ |  $Pop_{PM_{2.5}} = \%Pop_{PM_{2.5}} * Pop_{Tot}$ |
| $Exceed_{PM_{2.5}}$  | Excess exposure to $PM_{2.5}$ in micro gram / m3 |  $Exceed_{PM_{2.5}} = \mu_{PM_{2.5}} - \theta_{PM_{2.5}}$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $\theta_{PM_{2.5}}$  | Threshold to $PM_{2.5}$ exposure in micro gram / m3| 
| $\mu_{PM_{2.5}}$  | Average $PM_{2.5}$ exposure in micro gram / m3 | 

### Julia Implementation 
```julia 
using Mimi

@defcomp exposure begin 
    
    POP_25 = Variable(index = [time]) # Population exposed to certain threshold of PM2.5 concentration 
    Exceed_PM25 = Variable(index = [time]) # Excess micro gram exposure to PM2.5

    Percent_POP_PM25 = Parameter() # Percentage of population exposed to certain threshold 
    Pop_Tot = Parameter() # Total population 
    θ_PM25 = Parameter() # Threshold to PM_25 exposure 
    μ_PM25 = Parameter() # Average PM_25 exposure

    function run_timestep(p, v, d, t)
        v.POP_25[t] = p.Percent_POP_PM25 * p.Pop_Tot
        v.Exceed_PM25[t] = p.μ_PM25 - p.θ_PM25
    end

end
```

## The Human Health Component

Dose-response functions translate ambient concentrations and exposures into various physical effects. The value of statistical life (VSL) is the result of the sum of many individuals' Willingness to Pay (WTP) for marginal reductions in their mortality.

However, one need to determine a value transfer of this VSL, generally only available for some high income countries.

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $Mort$  | Premature mortality |  $Mort = \alpha _0 * Exceed_{PM_{2.5}} * Pop_{PM_{2.5}}$ |
| $\Omega_{Mort}$  | Health cost of premature mortality |  $\Omega_{Mort} = VSL * Mort$ |
| $VSL$  | Value of statistical life |  $VSL = VSL_{OECD} (\frac{y}{y_{OECD}})^e$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $Pop_{PM_{2.5}}$  | Population exposed to certain threshold of $PM_{2.5}$ | 
| $\alpha _0$  | Dose response function of premature mortality | 
| $y$  | GDP per capita in the country of the activity considered | 
| $y_{OECD}$  | Average GDP per capita in OECD countries | 
| $e$  | Income elasticity of the VSL | 

### Julia Implementation 
```julia 
@defcomp human_health begin
    
    Mort = Variable(index = [time]) # Premature Mortality
    Ω_Mort = Variable(index = [time]) # Health costs of premature Mortality
    VSL = Variable(index = [time]) # Value of statistical life

    POP_25 = Parameter(index = [time]) # Population exposed to certain threshold of PM 2.5
    Exceed_PM25 = Parameter(index = [time]) # Excess exposure in micro gram / m3

    alpha_0 = Parameter() # Dose response function of premature mortality 
    y = Parameter() # GDP per capita in the country of the activity 
    y_OECD = Parameter() # Average GDP per capita in the OECD countries 
    e = Parameter() # Income elasticity of VSL
    VSL_OECD = Parameter() # Value of statistic life of reference

    function run_timestep(p, v, d, t)
        v.Mort[t] = p.alpha_0 * p.Exceed_PM25[t] * p.POP_25[t]
        v.VSL[t] = p.VSL_OECD * (p.y / p.y_OECD)^(p.e)
        v.Ω_Mort[t] = v.VSL[t] * v.Mort[t]
    end
end
```

## Binding All Components Together

```julia 

function construct_model()

    m = Model()
    set_dimension!(m, :time, collect(1:1))

    add_comp!(m, exposure)
    add_comp!(m, human_health)

    update_param!(m, :exposure, :Percent_POP_PM25, 1.) # China
    update_param!(m, :exposure, :Pop_Tot, 1.4*10^9) # China
    update_param!(m, :exposure, :θ_PM25, 35)
    update_param!(m, :exposure, :μ_PM25, 53) # China

    update_param!(m, :human_health, :alpha_0, 0.000134) 
    update_param!(m, :human_health, :y, 10500.) 
    update_param!(m, :human_health, :y_OECD, 37000.) 
    update_param!(m, :human_health, :e, 0.8) 
    update_param!(m, :human_health, :VSL_OECD, 1. * 10^6) 

    connect_param!(m, :human_health, :POP_25, :exposure, :POP_25)
    connect_param!(m, :human_health, :Exceed_PM25, :exposure, :Exceed_PM25)

    return m
end
```
