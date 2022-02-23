using Mimi

# when using @defcomp, regions index must be specified 
# in the run_timestep function, regions must be specified
# set_dimension! must be used to specify your regions 
# update_param! each row corresponds to a time step / each column corresponds to a region 
# with regionalized models, easing to save each component as separate file 

include("MyModel.jl")
using .MyModel

m = construct_MyModel()
run(m)

getdataframe(m, :emissions, :E_Global)
explore(m)