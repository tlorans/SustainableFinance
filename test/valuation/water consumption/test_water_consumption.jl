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


@defcomp effect_factor begin
    
    EF = Variable(index = [time]) # Effect factor 
    
    WR = Parameter() # Minimum per capita water requirement of water for the agricultural sector to avoid malnutrition
    HDF = Parameter() # Human development factor related to vulnerability to malnutrition

    function run_timestep(p, v, d, t)
        
        v.EF[t] = p.WR^(-1) * p.HDF
    end

end

@defcomp human_health begin 

    HHF = Variable(index = [time]) # human health factor

    WDF = Parameter(index = [time]) # water depravation factor
    EF = Parameter(index = [time]) # Effect factor
    DF_malnutrition = Parameter() # Damage factor for malnutrition

    function run_timestep(p, v, d, t)
        v.HHF[t] = p.WDF[t] * p.EF[t] * p.DF_malnutrition
    end

end


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


function construct_model()

    m = Model()
    set_dimension!(m, :time, collect(1:1)) # we only have date for one year here and no proj

    add_comp!(m, )

end