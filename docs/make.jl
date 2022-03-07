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
            "Air Pollution"=>"ESG Valuation/Environmentals/Air Pollution/air_pollution.md",
            "Water Consumption"=>"ESG Valuation/Environmentals/Water Consumption/malnutrition.md",
        ],
        "ESG Investing" => Any[
            "Climate Investing" => "ESG Investing/Climate Investing/benchmark_climate.md"
        ],
        "ESG Performance" => Any[
            "Climate Unsustainability" => "ESG Performance/Climate Performance/unsustainability.md",
            "Climate Uncertainty" => "ESG Performance/Climate Performance/climate_uncertainty.md",
            "Probability of Climate Unsustainability" => "ESG Performance/Climate Performance/probability.md",
        ],
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
