
## The Climate Component

The formulation below of climate dynamics linked to emissions follows the traditional integrated assessment models. 
The emissions increase the atmospheric $CO_2$ concentration alongside the carbon cycle. The carbon cycle shows that every year there is exchange of carbon between the atmosphere and the upper ocean/biosphere and between the upper ocean/biosphere and the lower ocean. 

The accumulation of atmospheric $CO_2$ concentration increases radiative forcing, placing upward pressures on the atmospheric temperature.

Note that emissions are taken as exogenous in this component. 

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $CO2_{AT_t}$  | Atmospheric $CO_2$ concentration (Gt) | $CO2_{AT_t} = E_t + \phi_{1,1}CO2_{AT_{t-1}} + \phi_{2,1} CO2_{UP_{t-1}}$ |
| $CO2_{UP_t}$  |  Upper ocean/biosphere $CO_2$ concentration (Gt)  | $CO2_{UP_t} = \phi_{1,2}CO2_{AT_{t-1}}+\phi_{2,2}CO2_{UP_{t-1}} + \phi_{3,2}CO2_{LO_{t-1}}$ |
| $CO2_{LO_t}$  |   Lower ocean $CO_2$ concentration (Gt)   | $CO2_{LO_t} = \phi_{2,3}CO2_{UP_{t-1}} + \phi_{3,3}CO2_{LO_{t-1}}$ |
| $F_t$  |  Radiative forcing over pre-industrial levels (W/m2)  | $F_t = F_{2*CO2} log2\frac{CO2_{AT_t}}{CO2_{AT-PRE}} + F_{EX_t}$ |
| $F_{EX_t}$  |  Radiative forcing over pre-industrial levels, due to non $CO_2$ greenhouse gases (W/m2)  | $F_{EX_t} = F_{EX_{t-1}} + fex$ |
| $T_{AT_t}$  |  Atmospheric temperature over pre-industrial levels (°C)  | $T_{AT_t} = T_{AT_{t-1}} + t_1(F_t - \frac{F_{2*CO2}}{S}T_{AT_{t-1}} - t_2(T_{AT_{t-1}} - T_{LO_{t-1}}))$ |
| $T_{LO_t}$  |  Lower ocean temperature over pre-industrial levels (°C)  | $T_{LO_t} = T_{LO_{t-1}} + t_3(T_{AT_{t-1}} - T_{LO_{t-1}})$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $CO2_{AT-PRE}$  | Pre-industrial $CO_2$ concentration in atmosphere (Gt)  | 
| $CO2_{LO-PRE}$  | Pre-industrial $CO_2$ concentration in lower ocean (Gt)  | 
| $CO2_{UP-PRE}$  | Pre-industrial $CO_2$ concentration in upper ocean / biosphere (Gt)  | 
| $F_{2*CO2}$  | Increase in radiative forcing (since the pre-industrial period) due to doubling of $CO_2$ concentration from pre-industrial levels (W/m2) | 
| $fex$  | Annual increase in radiative forcing (since the pre-industrial period) due to non-$CO_2$ agents (W/m2)  | 
| $\phi_{1,1}$  | Transfer coefficient for carbon from the atmosphere to the atmosphere  | 
| $\phi_{1,2}$  | Transfer coefficient for carbon from the atmosphere to the upper ocean/biosphere  | 
| $\phi_{2,1}$  | Transfer coefficient for carbon from the upper ocean/biosphere to the atmosphere  | 
| $\phi_{2,2}$  | Transfer coefficient for carbon from the upper ocean/biosphere to the upper ocean/biosphere  | 
| $\phi_{2,3}$  | Transfer coefficient for carbon from the upper ocean/biosphere to the lower ocean  | 
| $\phi_{3,2}$  | Transfer coefficient for carbon from the lower ocean to the upper ocean/biosphere  | 
| $\phi_{3,3}$  | Transfer coefficient for carbon from the lower ocean to the lower ocean  | 
| $t_1$  | Speed of adjustment parameter in the atmospheric temperature equation | 
| $t_2$  | Coefficient of heat loss from the atmosphere to the lower ocean (atmospheric temperature equation) | 
| $t_3$  | Coefficient of heat loss from the atmosphere to the lower ocean (lower ocean temperature equation) | 
| $S$  | Equilibrium climate sensitivity | 

### Exogeneous Variables
| Notation      | Description |  
| ----------- | ----------- |
| $E_t$  |  Total greenhouse gas emissions  | 

### Julia Implementation 

We can implement it in Julia:
```julia
# component for climate 
@defcomp climate begin
    CO2_AT = Variable(index = [time]) # Atmospheric CO2 concentration 
    CO2_UP = Variable(index = [time]) # Upper ocean CO2 concentration 
    CO2_LO = Variable(index = [time]) # Lower ocean CO2 concentration 
    F = Variable(index = [time]) # Radiative forcing 
    FEX = Variable(index = [time]) # Radiative forcing due to non CO2 
    T_AT = Variable(index = [time]) # Atmospheric temperature over pre-industrial levels 
    T_LO = Variable(index = [time]) # Lower ocean tempature over pre-industrial levels 

    CO2_AT_0 = Parameter() # Initial value for CO2_AT
    CO2_UP_0 = Parameter() # Initial value for CO2_UP
    CO2_LO_0 = Parameter() # Initial value for CO2_LO
    F_0 = Parameter() # Initial value for F
    FEX_0 = Parameter() # Initial value for FEX
    T_AT_0 = Parameter() # Initial value for T_AT
    T_LO_0 = Parameter() # Initial value for T_LO

    CO2_AT_PRE = Parameter() # Pre-industrial CO2 concentration in atmosphere 
    CO2_LO_PRE = Parameter() # Pre-industrial CO2 concentration in lower ocean 
    CO2_UP_PRE = Parameter() # Pre-industrial CO2 concentration in upper ocean 
    F2CO2 = Parameter() # Increase in radiative forcing (since the pre-industrial period) due to doubling of CO2
    fex = Parameter() # Annual increase in radiative forcing (since the pre-industrial level)
    ϕ_11 = Parameter() # Transfer coefficient for carbon from the atmosphere to the atmosphere
    ϕ_12 = Parameter() # Transfer coefficient for carbon from the atmosphere to the upper ocean/biosphere
    ϕ_21 = Parameter() # Transfer coefficient for carbon from the upper ocean/biosphere to the atmosphere
    ϕ_22 = Parameter() # Transfer coefficient for carbon from the upper ocean/biosphere to the upper ocean/biosphere
    ϕ_23 = Parameter() # Transfer coefficient for carbon from the upper ocean/biosphere to the lower ocean
    ϕ_32 = Parameter() # Transfer coefficient for carbon from the lower ocean to the upper ocean/biosphere
    ϕ_33 = Parameter() # Transfer coefficient for carbon from the lower ocean to the lower ocean
    t_1 = Parameter() # Speed of adjustment parameter in the atmospheric temperature equation
    t_2 = Parameter() # Coefficient of heat loss from the atmosphere to the lower ocean (atmospheric temperature equation)
    t_3 = Parameter() # Coefficient of heat loss from the atmosphere to the lower ocean (lower ocean temperature equation)
    S = Parameter() # Equilibrium climate sensitivity 
    
    
    E = Parameter(index = [time]) # Total greenhouse gas emissions

    function run_timestep(p, v, d, t)
        if is_first(t)
            v.CO2_AT[t] = p.CO2_AT_0
            v.CO2_UP[t] = p.CO2_UP_0
            v.CO2_LO[t] = p.CO2_LO_0
            v.FEX[t] = p.FEX_0
            v.F[t] = p.F_0
            v.T_AT[t] = p.T_AT_0
            v.T_LO[t] = p.T_LO_0
        else
            # Equation for CO2_AT
            v.CO2_AT[t] = p.E[t] + p.ϕ_11 * v.CO2_AT[t-1] + p.ϕ_21 * v.CO2_UP[t-1]
            # Equation for CO2_UP 
            v.CO2_UP[t] = p.ϕ_12 * v.CO2_AT[t-1] + p.ϕ_22 * v.CO2_UP[t-1] + p.ϕ_32 * v.CO2_LO[t-1]
            # Equation for CO2_LO 
            v.CO2_LO[t] = p.ϕ_23 * v.CO2_UP[t-1] + p.ϕ_22 * v.CO2_LO[t-1]
            # radiative forcing other 
            v.FEX[t] = v.FEX[t-1] + p.fex 
            # Radiative forcing 
            v.F[t] = p.F2CO2 * log2(v.CO2_AT[t]/p.CO2_AT_PRE) + v.FEX[t]
            # Atmospheric temperature 
            v.T_AT[t] = v.T_AT[t-1] + p.t_1 * (v.F[t] - p.F2CO2 / p.S * v.T_AT[t-1] - p.t_2 * (v.T_AT[t-1] - v.T_LO[t-1]))
            # Lower ocean temperature
            v.T_LO[t] = v.T_LO[t-1] + p.t_3 * (v.T_AT[t-1] - v.T_LO[t-1])
        end
    end
end

```