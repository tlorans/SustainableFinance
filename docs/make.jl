using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "ESG Scoring" => Any[
            "Scoring System" => "ESG_Scoring/scoring_system.md",
            "ESG Scores and Portfolio" =>"ESG_Scoring/esg_scores_portfolio.md"

        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
