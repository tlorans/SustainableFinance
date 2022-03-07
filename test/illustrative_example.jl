## Company Statement
Base.@kwdef mutable struct CompanyResults
    EBITDA::Float64 #Ebitda
    ghg_emissions::Float64 # GHG emissions in milions tonnes of CO2eq 
    climate_costs::Union{Nothing,Float64} = nothing # Climate-related damages to society from the company, in Billion USD
end


company_a = CompanyResults(EBITDA = 25.2, ghg_emissions =  374)



## GHG emissions valuation 
using Plots

function climate_valuation!(data::CompanyResults, scc::Float64)::CompanyResults
    data.climate_costs = - data.ghg_emissions * scc * 10^(-3) # to express in billion USD
    legend_axis = ["EBITDA", "GHG",
                "Air Pollution",
                "Water Consumption",
                "Water Pollution",
                "Land Use",
                "Waste","Incidents"]
    
    air_pollution = data.climate_costs * 0.2
    water_consumption = data.climate_costs * 0.1
    water_pollution = data.climate_costs * 0.08
    land_use = data.climate_costs * 0.05
    waste = data.climate_costs * 0.04
    incidents = data.climate_costs * 0.02

    list_data = [data.EBITDA, 
                data.climate_costs,
                air_pollution,
                water_consumption,
                water_pollution,
                land_use,
                waste,
                incidents]
    list_data = reduce(vcat, list_data)
    println(list_data)
    display(bar(legend_axis, list_data, orientation = :horizontal, bar_width = 1, legend = nothing, xlabel = "Billion USD"))
    return data
end


climate_valuation!(company_a, 51.)

company_a.climate_costs / company_a.EBITDA * -1
