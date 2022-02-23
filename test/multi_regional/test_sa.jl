using Mimi, Distributions

include("MyModel.jl")
using .MyModel

m = construct_MyModel()

# Step 2: Define the Simulation

"""
@defsim macro is the first step in the process and returns a SimulationDef

allows users to define random variables as distributions, and associate model 
parameters with the defined random variables 
"""

sd = @defsim begin 

    # Define random variables. The rv() is only required 
    # when defining correlations or sharing an RV across parameters
    # otherwise, you can use the shortcut syntax
    # to assign a distribution to a parameter name
    rv(name1) = Normal(1, 0.2)
    rv(name2) = Uniform(0.75, 1.25)
    rv(name3) = LogNormal(20, 4)

    # Define the sampling strategy
    sampling(LHSData,corrlist = [(:name1, :name2, 0.7), (:name1, :name3, 0.5)])

    # assign RVs to model Parameters 
    grosseconomy.share = Uniform(0.2, 0.8)

    # you can use the *= operator to replace the values in the parameter with the 
    # product of the original value and the value of the RV for the current 
    # trial (note that in both lines below, all indexed values will be mulitplied by the
    # same draw from the given random parameter (name2 or Uniform(0.8, 1.2))

    emissions.sigma[:,Region1] *= name2 
    emissions.sigma[2020:5:2050, (Region2, Region3)] *= Uniform(0.8, 1.2)

    # For parameters that have a region dimension, you can assign an array of distributions, 
    # keyed by region label, which must match the region labels in the model
    grosseconomy.depk = [Region1 => Uniform(0.7, .9),
                        Region2 => Uniform(0.8, 1.),
                        Region3 => Truncated(Normal(), 0, 1)]
    
    # Indicate which variables to save for each model run
    # The syntax is: component_name.variable_name 
    save(grosseconomy.K, grosseconomy.YGROSS,
        emissions.E, emissions.E_Global)
end


# STEP 3: Run Simulation

# Run 100 trials and optionally save results to the indicated directories 
si = run(sd, m, 100; trials_output_filename = "/tmp/trialdata.csv", results_output_dir = "/tmp/tutorial4")

# Explore the results saved in-memory by using getdataframe with the returned SimulationInstance.
# Values are saved from each trial for each variable or parameter specified by the call to "save()" at the end of the @defsim block.
K_results = getdataframe(si, :grosseconomy, :K)
E_results = getdataframe(si, :emissions, :E)

explore(si)
