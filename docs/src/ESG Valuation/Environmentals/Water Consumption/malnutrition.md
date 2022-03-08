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

## Human Health Factor

The human health factor brings together the outputs of the water depravation factor and the effect factor, using a damage factor to describes the disability adjusted life years (DALYs) per unit of water consumed. 



### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $HHF$  | Human Health Factor |  $HHF = WDF * EF * DF_{malnutrition}$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $WDF$  | Water Depravation Factor | 
| $EF$  | Effect Factor | 
| $DF_{malnutrition}$  | Damage factor (DALYs per capita per year)| 

### Julia Implementation

```julia
@defcomp human_health begin 

    HHF = Variable(index = [time]) # human health factor

    WDF = Parameter(index = [time]) # water depravation factor
    EF = Parameter(index = [time]) # Effect factor
    DF_malnutrition = Parameter() # Damage factor for malnutrition

    function run_timestep(p, v, d, t)
        v.HHF[t] = p.WDF[t] * p.EF[t] * p.DF_malnutrition
    end

end
```

## Social Cost of Water Consumption

The monetary value of each DALY is based on the value of a statistical life (VSL) and the lost DALYs associated with the VSL estimate to produce a welfare estimate of the impacts.

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $DALY_{value}$  | DALY monetary value in the production site's country |  $DALY_{value} = DALY_{ref} * \frac{GNI}{GNI_{ref}}^e$ 
| $SC$  | Social cost of water consumption |  $SC = HHF * DALY_{value}$ 


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $DALY_{ref}$  | DALY reference monetary value | 
| $GNI$  | Gross national income per capita of the production site's country, adjusted for purchasing power parity | 
| $GNI_{ref}$  | Gross national income per capita of the reference country, adjusted for purchasing power parity | 
| $e$  | Income elasticity of the willingness to pay for health or life | 
| $P$  | Population in the production site's country | 
| $HHF$  |  Human Health Factor | 

### Julia Implementation

```julia
@defcomp social_cost begin 

    DALY_value = Variable(index = [time]) # DALY monetary value in the production site's country 
    SC = Variable(index = [time]) # Social cost of water consumption

    DALY_ref = Parameter() # DALY reference value
    GNI = Parameter() # Gross national income per capita of the production site's country, adjusted for purchasing power parity
    GNI_ref = Parameter() # Gross national income per capita of the reference country
    e = Parameter() # Income elasticity of willingness to pay for health or life
    P = Parameter() # Population in the production site's country 
    HHF = Parameter(index = [time]) # Human health factor

    function run_timestep(p, v, d, t)
        v.DALY_value[t] = p.DALY_ref * (p.GNI / p.GNI_ref)^p.e
        v.SC[t] = p.HHF[t] * v.DALY_value[t]

    end
end 
```

## Binding All Together

