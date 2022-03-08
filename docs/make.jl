using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "ESG Valuation" => Any[
            "Introduction"=>"ESG Valuation/intro.md",
            "GHG Emissions"=>"ESG Valuation/Environmentals/Climate/impacts.md",
            "Water Consumption"=>"ESG Valuation/Environmentals/Water Consumption/impacts.md",
        ],

    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
