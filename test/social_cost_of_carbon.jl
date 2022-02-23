using Mimi 
using MimiDICE2010
using Distributions


"""
Case: We want to do an SCC calculation with MimiDICE2010, which consists of running both a base and modified model 
(the latter being a model including an additional emissions pulse, 
see the create_marginal_model function or create your own two models). 
We then take the difference between the consumption level in these two models and 
obtain the discounted net present value to get the SCC.
"""

## STEP 1 Defining typical variables for a simulation, number of trials and simulation definition


# Define the number of trials 
N = 100


# define your simulation (defaults to Monte Carlo sampling)
sd = @defsim begin
    t2xco2 = Truncated(Gamma(6.47815626,0.547629469), 1.0, Inf) # a dummy distribution
end

## STEP 2 Payload object

"""
Simulation definitions can hold a user-defined payload object which is not used or modified by Mimi. 
In this example, we will use the payload to hold an array of pre-computed 
discount factors that we will use in the SCC calculation, as well as a storage array for saving the SCC values.
"""
# Choose what year to calculate the SCC for 
scc_year = 2015 
year_idx = findfirst(isequal(scc_year), MimiDICE2010.model_years)

# Pre-coimpute the discount factors for each discount rate 
discount_rates = [0.03, 0.05, 0.07]
nyears = length(MimiDICE2010.model_years)
discount_factors = [[zeros(year_idx - 1)... [(1/(1 + r))^((t-year_idx)*10) for t in year_idx:nyears]...] for r in discount_rates] 

# Create an array to store the compute SCC in each trial for each discount rate 
scc_results = zeros(N, length(discount_rates))  

# Set the payload object in the simulation definition
my_payload_object = (discount_factors, scc_results) # In this case, the payload object is a tuple which holds both both arrays
Mimi.set_payload!(sd, my_payload_object)

## STEP 3 Post-trial function 
"""
User may ned to perform other calculations before or after each trial is run 
For example, the SCC is calculated using two models, so this calculation needs to happen in a post-trial function 
"""
function my_scc_calculation(sim_inst::SimulationInstance, trialnum::Int, ntimesteps::Int, tup::Nothing)
    mm = sim_inst.models[1] 
    discount_factors, scc_results = Mimi.payload(sim_inst)  # Unpack the payload object

    marginal_damages = mm[:neteconomy, :C] * -1 * 10^12 * 12/44 # convert from trillion $/ton C to $/ton CO2; multiply by -1 to get positive value for damages
    for (i, df) in enumerate(discount_factors)
        scc_results[trialnum, i] = sum(df .* marginal_damages .* 10)
    end
end


# STEP 4: RUN THE SIMULATION 
# Build the marginal model
mm = MimiDICE2010.get_marginal_model(year = scc_year)   # The additional emissions pulse will be added in the specified year

# Run
si = run(sd, mm, N; trials_output_filename = "ecs_sample.csv", post_trial_func = my_scc_calculation)

# View the scc_results by retrieving them from the payload object
scc_results = Mimi.payload(si)[2]   # Recall that the SCC array was the second of two arrays we stored in the payload tuple



