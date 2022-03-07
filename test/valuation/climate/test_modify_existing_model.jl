
# Step 2 Run DICE
using MimiDICE2010 

m = MimiDICE2010.get_model()
run(m)

# Step 3: Altering Parameters

using Mimi

# update the forcings of equilibrium CO2
update_param!(m, :fco22x, 3.000)
run(m)

# update the time horizon 
const ts = 10 # timestep 10 years 
const years = collect(1995:ts:2505)
nyears = length(years)
set_dimension!(m, :time, years)


