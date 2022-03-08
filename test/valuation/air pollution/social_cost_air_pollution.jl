using Mimi


# STEP 1 Define the components 

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


# STEP 2: Model

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
    update_param!(m, :human_health, :e, 0.6) 
    update_param!(m, :human_health, :VSL_OECD, 3.4 * 10^6) 

    connect_param!(m, :human_health, :POP_25, :exposure, :POP_25)
    connect_param!(m, :human_health, :Exceed_PM25, :exposure, :Exceed_PM25)

    return m
end


m = construct_model()
run(m)

value_baseline = getdataframe(m, :human_health, :Ω_Mort)
getdataframe(m, :human_health, :Mort)
getdataframe(m, :human_health, :VSL)

getdataframe(m, :human_health, :Exceed_PM25)

getdataframe(m, :human_health, :Ω_Mort)[1, :Ω_Mort]/ (14722730.70 * 10^6)

# STEP 4 VISUALIZE
# plot model results 


# explore(m)

china_PM25 = 9926.4 * 10^(3)

social_cost = getdataframe(m, :human_health, :Ω_Mort)[1, :Ω_Mort] / china_PM25