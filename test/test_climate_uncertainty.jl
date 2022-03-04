using Mimi 
using MimiFUND
using Plots
using Statistics
using Distributions

# get the model 
m = MimiFUND.get_model()
run(m)
explore(m)

sd = @defsim begin 
    # Define random variables 
    climatedynamics.climatesensitivity = truncated(Normal(2, 1), 0.1, 5) # truncated to be stricly positive
    save(climatedynamics.temp)
end

# Run 100 trials 
si = run(sd, m, 100)

test = getdataframe(si, :climatedynamics, :temp)

test = filter("time" => ==(2100), test)

histogram(test[:,:temp], label = nothing, xlabel = "Temperature Increase", ylabel = "Nber of trials")
