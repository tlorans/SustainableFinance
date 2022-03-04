using Mimi 
using MimiFUND
using Plots
using Statistics
using Distributions

# get the model 
m = MimiFUND.get_model()

update_param!(m, :climatedynamics, :climatesensitivity, 4.5)


discounting = [i for i in 0:0.005:0.05]

results_sc = []

for i in eachindex(discounting)
    push!(results_sc, MimiFUND.compute_scc(m, year = 2020, eta = 1., prtp = discounting[i]) * 1.68)
end

plot(discounting, results_sc, label = nothing, xlabel = "PRTP (in %)", ylabel = "Social Cost of Carbon (2020 USD)")