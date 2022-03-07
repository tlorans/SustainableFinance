using Mimi
using MimiFUND
using DataFrames


# Run FUND for baseline scenario
m = MimiFUND.get_model()

# set_dimension!(m, :time, 1950:2100) # set the timeline to be 1950 to 2100


run(m)

explore(m)

p = Mimi.plot(m, :impactagriculture, :aglevel)
p = Mimi.plot(m, :impactagriculture, :agrate)
p = Mimi.plot(m, :impactagriculture, :agcost)


scc_year = 2020

update_param!(m, :climatedynamics, :climatesensitivity, 4.5)

mm = MimiFUND.get_marginal_model(m, year = scc_year)   # The additional emissions pulse will be added in the specified year


run(mm)

MimiFUND.compute_scc(m, year = scc_year, eta = 1., prtp = 0.) * 1.68
