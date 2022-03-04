# Social costs dynamic
using Mimi
using MimiFUND

m = MimiFUND.get_model()
update_param!(m, :climatedynamics, :climatesensitivity, 4.5)

list_scc_year = [i for i in 2000:2020]

scc_dynamic = []

for i in eachindex(list_scc_year)
    push!(scc_dynamic, MimiFUND.compute_scc(m, year = list_scc_year[i], eta = 1., prtp = 0.) * 1.68)
end


using Plots 

plot(list_scc_year, scc_dynamic, label = nothing, xlabel = "Year", ylabel = "Social Cost of Carbon")

