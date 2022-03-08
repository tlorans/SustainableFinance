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

m[:malnutrition, :HHF]

m[:social_cost, :DALY_value]

m[:social_cost, :SC]