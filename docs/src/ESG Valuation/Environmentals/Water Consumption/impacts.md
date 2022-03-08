# Water Consumption 




## Malnutrition Impacts

Estimates the amount of water that the agricultural sector is deprived of as a result of water consumption by others, in relation to the sector's total water consumption. 
It assumes that increased water consumption reduces water availability to agricultural users. 

The water deprivation factor $WDF$ estimates the amount of water that the agricultural sector is deprived. 

The effect factor $EF$ is the number of malnourishment cases caused each year by the deprivation of one cubic metre of freshwater (in capita per m3 deprived).

The damage factor $DF$ is the amount of harm per case of malnutrition. It is expressed in Disability-adjusted life years (DALYs) per capita.

Finally, the human health factor $HHF$ expresses the number of DALYs per m3 consumed.

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $WDF$  | Water depravation factor |  $WDF = WSI * WU_{agriculture}$ |
| $EF$  | Effect Factor |  $EF = WR_{malnutrition}^{-1}*HDF_{malnutrition}$ |
| $HDF_{malnutrition}$  | Human development factor related to vulnerability to malnutrition | derived from $HDI$ (see Pfister 2009) |
| $HHF$  | Human Health Factor |  $HHF = WDF * EF * DF_{malnutrition}$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $WSI$  | Water stress index | 
| $WU_{agriculture}$  | Percentage of water consumption by agriculture |
| $WR_{malnutrition}$  | Minimum per capita water requirement of water for the agricultural sector to avoid malnutrition | 
| $HDI$  | Human development index | 
| $WDF$  | Water Depravation Factor | 
| $EF$  | Effect Factor | 
| $DF_{malnutrition}$  | Damage factor (DALYs per capita per year)| 
| $HHF$  |  Human Health Factor | 

### Julia Implementation

```julia
using Mimi

@defcomp malnutrition begin 
	WDF = Variable() # Water depravation factor 
    EF = Variable() # Effect factor 
	HDF = Variable() # Human development factor related to vulnerability to malnutrition
    HHF = Variable() # human health factor


	WSI = Parameter() # Water stress index 
	WU = Parameter() # Percentage of water consumption by agriculture
    WR = Parameter() # Minimum per capita water requirement of water for the agricultural sector to avoid malnutrition
	HDI = Parameter() # Human Development Index
    DF_malnutrition = Parameter() # Damage factor for malnutrition



	function run_timestep(p, v, d, t)
		v.WDF = p.WSI * p.WU
        if p.HDI < 0.3
			v.HDF = 1
		elseif p.HDI > 0.88
			v.HDF = 0
		else 
			v.HDF = 2.03 * p.HDI^2 - 4.09 * p.HDI + 2.04
		end
        v.EF = p.WR^(-1) * v.HDF
        v.HHF = v.WDF * v.EF * p.DF_malnutrition
	end
end 
```

## Water-borne Diseases Impacts

### Endogenous variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $DALY_{diseases, baseline}$  | Disability-adjusted life years due to water-borne diseases, baseline scenario|  $DALY_{diseases, baseline} = exp^{(\alpha + \beta_1 ln dww + \beta_2 ln undernour + \beta_3 ln healthexp + \beta_4 lnwsi + \beta_5 ln govteff)}$ |
| $DALY_{diseases, marginal}$  | Disability-adjusted life years due to water-borne diseases, marginal scenario|  $DALY_{diseases, marginal} = exp^{(\alpha + \beta_1 ln (dww - 1) + \beta_2 ln undernour + \beta_3 ln healthexp + \beta_4 lnwsi + \beta_5 ln govteff)}$ |
| $\Delta DALY_{disease}$  | Discrease in DALYs if domestic water consumption descreased by 1 m3| $\Delta DALY_{disease} = DALY_{diseases, baseline} - DALY_{diseases, marginal}$  |

### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $\alpha$  | Parameter in the water-borne disease function | 
| $\beta_1$  | Parameter in the water-borne disease function | 
| $\beta_2$  | Parameter in the water-borne disease function | 
| $\beta_3$  | Parameter in the water-borne disease function | 
| $\beta_4$  | Parameter in the water-borne disease function | 
| $\beta_5$  | Parameter in the water-borne disease function | 
| $dww$  | Domestic water use, in m3 | 
| $undernour$  | Prevalence of undernourishment | 
| $healthexp$  | Health expenditure | 
| $wsi$  | Water stress index | 
| $govteff$  | Government effectiveness | 

## Social Cost of Water Consumption


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

### Julia Implementation


```julia

@defcomp social_cost begin 
    DALY_value = Variable() # DALY monetary value in the production site's country 
    SC = Variable() # Social cost of water consumption

    DALY_ref = Parameter() # DALY reference value
    GNI = Parameter() # Gross national income per capita of the production site's country, adjusted for purchasing power parity
    GNI_ref = Parameter() # Gross national income per capita of the reference country
    e = Parameter() # Income elasticity of willingness to pay for health or life
    HHF = Parameter() # Human Health Factor 

    function run_timestep(p, v, d, t)
        v.DALY_value = p.DALY_ref * (p.GNI / p.GNI_ref)^p.e
        v.SC = p.HHF * v.DALY_value
    end

end


function construct_model()
	# initiate the model
	m = Model()
    set_dimension!(m, :time, collect(1:1))

	# add components to the model
	add_comp!(m, malnutrition)
	add_comp!(m, social_cost)


	# give value to parameters	
	update_param!(m, :malnutrition, :WSI, 0.4322) # for China, source Worldbank, https://data.worldbank.org/indicator/ER.H2O.FWST.ZS
	update_param!(m, :malnutrition, :WU, 0.64) # https://data.worldbank.org/indicator/ER.H2O.FWAG.ZS
	update_param!(m, :malnutrition, :WR, 1350.) # m3, per capita per year, from Pfister 2009
	update_param!(m, :malnutrition, :HDI, 0.761) #https://hdr.undp.org/en/countries/profiles/CHN
	update_param!(m, :malnutrition, :DF_malnutrition, 0.0184) #Pfister 2009
	update_param!(m, :social_cost, :DALY_ref, 185000) #VBA 2021
	update_param!(m, :social_cost, :GNI, 16201.4) #https://data.worldbank.org/indicator/NY.GNP.PCAP.PP.KD?locations=CN
	update_param!(m, :social_cost, :GNI_ref, 42135) # https://data.worldbank.org/indicator/NY.GNP.PCAP.PP.KD?locations=OE
	update_param!(m, :social_cost, :e, 0.6) # VBA 2021

    connect_param!(m, :social_cost, :HHF, :malnutrition, :HHF)

	return m	
end

m = construct_model()

run(m)


m[:social_cost, :SC]
```


