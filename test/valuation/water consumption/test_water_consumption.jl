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