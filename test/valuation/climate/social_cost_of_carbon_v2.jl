using Mimi


# STEP 1 DEFINE THE COMPONENTS

# gross economy component
@defcomp grosseconomy begin 
    Y = Variable(index = [time]) # Gross output 
    K = Variable(index = [time]) # Capital 
    L = Parameter(index = [time]) # Labor
    TFP = Parameter(index = [time]) # Total factor productivity 
    s = Parameter(index = [time]) # Savings rate
    δ = Parameter() # Depreciation rate on capital 
    k0 = Parameter() # Initial level of capital 
    β = Parameter() # Capital share

    function run_timestep(p, v, d, t)
        # Define an equation for K 
        if is_first(t)
            # Note the use of v. and p. to distinguish between variables 
            # and parameters 
            v.K[t] = p.k0 
        else
            v.K[t] = (1 - p.δ) * v.K[t-1] + v.Y[t-1] * p.s[t-1]
        end

        # Define an equation for YGROSS 
        v.Y[t] = p.TFP[t] * v.K[t]^p.β * p.L[t]^(1-p.β)
    end
end

# component for greenhouse gas emissions 
@defcomp emissions begin 
    E = Variable(index = [time]) # Total greenhouse gas emissions 
    M = Variable(index = [time]) # Energy consumption

    ω = Parameter(index = [time]) # CO2 intensity of energy mix
    ϵ = Parameter(index = [time]) # energy intensity of output
    Y = Parameter(index = [time]) # Gross output - now a Parameter

    function run_timestep(p, v, d, t)
        # equation for M 
        v.M[t] = p.ϵ[t] * p.Y[t] # note the p. in front of gross 
        # Define an equation for E 
        v.E[t] = p.ω[t] * v.M[t]
    end
end

# component for climate 
@defcomp climate begin
    CO2_AT = Variable(index = [time]) # Atmospheric CO2 concentration 
    CO2_UP = Variable(index = [time]) # Upper ocean CO2 concentration 
    CO2_LO = Variable(index = [time]) # Lower ocean CO2 concentration 
    F = Variable(index = [time]) # Radiative forcing 
    FEX = Variable(index = [time]) # Radiative forcing due to non CO2 
    T_AT = Variable(index = [time]) # Atmospheric temperature over pre-industrial levels 
    T_LO = Variable(index = [time]) # Lower ocean tempature over pre-industrial levels 

    CO2_AT_0 = Parameter() # Initial value for CO2_AT
    CO2_UP_0 = Parameter() # Initial value for CO2_UP
    CO2_LO_0 = Parameter() # Initial value for CO2_LO
    F_0 = Parameter() # Initial value for F
    FEX_0 = Parameter() # Initial value for FEX
    T_AT_0 = Parameter() # Initial value for T_AT
    T_LO_0 = Parameter() # Initial value for T_LO

    CO2_AT_PRE = Parameter() # Pre-industrial CO2 concentration in atmosphere 
    CO2_LO_PRE = Parameter() # Pre-industrial CO2 concentration in lower ocean 
    CO2_UP_PRE = Parameter() # Pre-industrial CO2 concentration in upper ocean 
    F2CO2 = Parameter() # Increase in radiative forcing (since the pre-industrial period) due to doubling of CO2
    fex = Parameter() # Annual increase in radiative forcing (since the pre-industrial level)
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
    S = Parameter() # Equilibrium climate sensitivity 
    
    
    E = Parameter(index = [time]) # Total greenhouse gas emissions

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
            # Equation for CO2_AT
            v.CO2_AT[t] = p.E[t] + p.ϕ_11 * v.CO2_AT[t-1] + p.ϕ_21 * v.CO2_UP[t-1]
            # Equation for CO2_UP 
            v.CO2_UP[t] = p.ϕ_12 * v.CO2_AT[t-1] + p.ϕ_22 * v.CO2_UP[t-1] + p.ϕ_32 * v.CO2_LO[t-1]
            # Equation for CO2_LO 
            v.CO2_LO[t] = p.ϕ_23 * v.CO2_UP[t-1] + p.ϕ_22 * v.CO2_LO[t-1]
            # radiative forcing other 
            v.FEX[t] = v.FEX[t-1] + p.fex 
            # Radiative forcing 
            v.F[t] = p.F2CO2 * log2(v.CO2_AT[t]/p.CO2_AT_PRE) + v.FEX[t]
            # Atmospheric temperature 
            v.T_AT[t] = v.T_AT[t-1] + p.t_1 * (v.F[t] - p.F2CO2 / p.S * v.T_AT[t-1] - p.t_2 * (v.T_AT[t-1] - v.T_LO[t-1]))
            # Lower ocean temperature
            v.T_LO[t] = v.T_LO[t-1] + p.t_3 * (v.T_AT[t-1] - v.T_LO[t-1])
        end
    end
end


# component for damages 
@defcomp damages begin
    D = Variable(index = [time]) # Damages (in % of gross output)
    Ω = Variable(index  = [time]) # Damages in USD

    η₁ = Parameter() # Parameter of damage function 
    η₂ = Parameter() # Parameter of damage function 
    η₃ = Parameter() # Parameter of damage function 

    T_AT = Parameter(index = [time]) # Atmospheric temperature increase 
    Y = Parameter(index = [time]) # Gross output 

    function run_timestep(p, v, d, t)

        v.D[t] = 1 - 1 / (1 + p.η₁ * p.T_AT[t] + p.η₂ * p.T_AT[t]^2 + p.η₃ * p.T_AT[t]^6.754)
        v.Ω[t] = v.D[t] * p.Y[t]
        
    end

end


# STEP 2: CONSTRUCT A MODEL BY BINDING BOTH COMPONENTS 

# if anay variables of one component are parameters for another, connect_param! is
# used to couple the two

function construct_model(;marginal = false)
    m = Model()

    set_dimension!(m, :time, collect(2015:1:2100))

    # Order matters here, if the emissions component defined first, error
    add_comp!(m, grosseconomy)
    add_comp!(m, emissions)
    add_comp!(m, climate)
    add_comp!(m, damages)

    """
    update_param! used to assign values each component parameter 
    with an external connection to an unshared model param 
    """
    # Update parameters for the grosseconomy component
    update_param!(m, :grosseconomy, :L, [(1. + 0.003)^t * 6.404 for t in 1:86])
    update_param!(m, :grosseconomy, :TFP, [(1 + 0.01)^t * 3.57 for t in 1:86])
    update_param!(m, :grosseconomy, :s, ones(86) .* 0.22)
    update_param!(m, :grosseconomy, :δ, 0.1)
    update_param!(m, :grosseconomy, :k0, 130.)
    update_param!(m, :grosseconomy, :β, 0.3)

    # update parameters for the emissions component 
    update_param!(m, :emissions, :ω, [(1. - 0.002)^t * 0.07 for t in 1:86])
    
    if marginal
        pulse = 1/1e10 # units of emissions are Gt then we convert 1 ton of pulse in Gt 
        update_param!(m, :emissions, :ϵ, [(1. - 0.002)^t * (7.92 + pulse) for t in 1:86])
    else
        update_param!(m, :emissions, :ϵ, [(1. - 0.002)^t * 7.92 for t in 1:86])
    end

    # update parameters for the climate component 
    update_param!(m, :climate, :CO2_AT_0, 3120)
    update_param!(m, :climate, :CO2_UP_0, 5628.8)
    update_param!(m, :climate, :CO2_LO_0, 36706.7)
    update_param!(m, :climate, :F_0, 2.30)
    update_param!(m, :climate, :FEX_0, 0.28)
    update_param!(m, :climate, :T_AT_0, 1.0)
    update_param!(m, :climate, :T_LO_0, 0.0068)

    update_param!(m, :climate, :CO2_AT_PRE, 2156.2)
    update_param!(m, :climate, :CO2_LO_PRE, 36670.0)
    update_param!(m, :climate, :CO2_UP_PRE, 4950.5)
    update_param!(m, :climate, :F2CO2, 3.8)
    update_param!(m, :climate, :fex, 0.005)
    update_param!(m, :climate, :ϕ_11, 0.9817)
    update_param!(m, :climate, :ϕ_12, 0.0183)
    update_param!(m, :climate, :ϕ_21, 0.0080)
    update_param!(m, :climate, :ϕ_22, 0.9915)
    update_param!(m, :climate, :ϕ_23, 0.0005)
    update_param!(m, :climate, :ϕ_32, 0.0001)
    update_param!(m, :climate, :ϕ_33, 0.9999)
    update_param!(m, :climate, :t_1, 0.027)
    update_param!(m, :climate, :t_2, 0.018)
    update_param!(m, :climate, :t_3, 0.005)
    update_param!(m, :climate, :S, 3)

    # update parameters for damages function 

    update_param!(m, :damages, :η₁, 0)
    update_param!(m, :damages, :η₂, 0.00284)
    update_param!(m, :damages, :η₃, 0.000005)

    # connect parameters for the emissions component 
    connect_param!(m, :emissions, :Y, :grosseconomy, :Y)

    # connect parameters for the climate component 
    connect_param!(m, :climate, :E, :emissions, :E)

    # connect parameters for the damages component
    connect_param!(m, :damages, :T_AT, :climate, :T_AT)
    connect_param!(m, :damages, :Y, :grosseconomy, :Y)

    return m
end

# STEP 3 RUN THE MODEL

# run the model 

m = construct_model()
run(m)

# check model results 
getdataframe(m, :climate, :T_AT)

# STEP 4 VISUALIZE
# plot model results 
Mimi.plot(m, :grosseconomy, :Y)
Mimi.plot(m, :emissions, :E)
Mimi.plot(m, :climate, :T_AT)
Mimi.plot(m, :damages, :D)



# observe all model result graphs in UI 
explore(m)

# STEP 5 PRESENT VALUE OF DAMAGES IN BASELINE SCENARIO

discount_rate = 0.035
discount_factors = [(1/(1 + discount_rate))^((t-1)) for t in 1:86] 
damages_usd = getdataframe(m, :damages, :Ω)
present_value_damages = sum(discount_factors .* damages_usd[:,:Ω])

# STEP 6 RUN THE MARGINAL MODEL 

m2 = construct_model(marginal = true)
run(m2)

damages_usd_m2 = getdataframe(m2, :damages, :Ω)
present_value_damages_m2 = sum(discount_factors .* damages_usd_m2[:,:Ω])

scc = (present_value_damages_m2 - present_value_damages) * 10^12

