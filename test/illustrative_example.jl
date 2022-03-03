## Company Statement
Base.@kwdef mutable struct CompanyResults
    revenue::Float64 # Revenue
    ghg_emissions::Float64 # GHG emissions in milions tonnes of CO2eq 
    climate_costs::Union{Nothing,Float64} = nothing # Climate-related damages to society from the company, in Billion USD
end


company_a = CompanyResults(revenue = 164.2, ghg_emissions =  374)



## GHG emissions valuation 
using Plots

function climate_valuation!(data::CompanyResults, scc::Float64)::CompanyResults
    data.climate_costs = - data.ghg_emissions * scc * 10^(-3) # to express in billion USD
    legend_axis = ["Revenue", "Climate Costs"]
    display(bar(legend_axis, vcat(data.revenue, data.climate_costs), orientation = :horizontal, bar_width = 1, legend = nothing, xlabel = "Billion USD",
    colour = ["blue","green"]))
    return data
end


climate_valuation!(company_a, 51.)

company_a.climate_costs / company_a.revenue * -1
