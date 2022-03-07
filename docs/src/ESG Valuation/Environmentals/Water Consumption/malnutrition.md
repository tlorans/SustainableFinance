# Water Consumption 

Reduction calculated by considering:
- The volume of corporate water consumption (m3) per capita
- level of water stress in local watershed using a water-stress index.


## Water Depravation Factor

Estimates the amount of water that the agricultural sector is deprived of as a result of water consumption by others, in relation to the sector's total water consumption

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $WDF$  | Water depravation factor |  $WDF = WSI * WU_{agriculture}$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $WSI$  | Water stress index | 
| $WU_{agriculture}$  | Percentage of water consumption by agriculture | 

### Julia Implementation

```julia
using Mimi


# STEP 1 Define the components 

@defcomp water_depravation begin 
    WDF = Variable(index = [time]) # Water depravation factor 

    WSI = Parameter() # Water stress index 
    WU = Parameter() # Percentage of water consumption by agriculture

    function run_timestep(p, v, d, t)
        
        v.WDF[t] = p.WSI * p.WSU
    end

end 
```

## Effect Factor 

Number of malnourishment cases caused each year by the deprivation of one cubic metre of freshwater.


### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $EF$  | Effect Factor |  $EF = WR_{malnutrition}^{-1}*HDF_{malnutrition}$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $WR_{malnutrition}$  | Minimum per capita water requirement of water for the agricultural sector to avoid malnutrition | 
| $HDF_{malnutrition}$  | Human development factor related to vulnerability to malnutrition | 

### Julia Implementation

```julia
@defcomp effect_factor begin
    
    EF = Variable(index = [time]) # Effect factor 
    
    WR = Parameter() # Minimum per capita water requirement of water for the agricultural sector to avoid malnutrition
    HDF = Parameter() # Human development factor related to vulnerability to malnutrition

    function run_timestep(p, v, d, t)
        
        v.EF[t] = p.WR^(-1) * p.HDF
    end

end
```


## Damage Factor

Damage factor estimates the amount of harm per case of malnutrition. 


