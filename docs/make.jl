using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for ESG Valuation",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Julia for IAM" => Any[
            "Integrated Assessment Models"=>"Julia for IAM/intro.md",
            "Economy Component"=>"Julia for IAM/economy_component.md",
            "Emissions Component"=>"Julia for IAM/emissions_component.md",
            "Climate Component"=>"Julia for IAM/climate_component.md",
            "Damages Component"=>"Julia for IAM/damages_component.md",
            "Social Cost of Carbon"=>"Julia for IAM/scc.md",
        ],
        "Climate Valuation" => Any[
            "The FUND Model"=>"Climate Valuation/fund_model.md",
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
