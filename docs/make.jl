using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Integrated Assessment Modeling" => Any[
            "Integrated Assessment Models"=>"Julia for IAM/intro.md",
            "Economy Component"=>"Julia for IAM/economy_component.md",
            "Emissions Component"=>"Julia for IAM/emissions_component.md",
            "Climate Component"=>"Julia for IAM/climate_component.md",
            "Damages Component"=>"Julia for IAM/damages_component.md",
            "Social Cost of Carbon"=>"Julia for IAM/scc.md",
        ],
        "Climate Valuation" => Any[
            "Impacts"=>"Climate Valuation/Impacts/impacts.md",
            "Social Cost"=>"Climate Valuation/Social Cost/social_costs.md",

        ],
        "Climate Investing" => Any[
            "Climate Investing" => "Climate Investing/benchmark_climate.md"
        ],
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
