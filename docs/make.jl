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
            "Scoring System" => "ESG_Scoring/scoring_system.md"
        ],
        "ESG Tilting" => Any[
            "QP Problem for Tilting" => "ESG_Tilting/qp_problem_for_tilting.md",
            "QP Problem for Enhanced ESG Score" => "ESG_Tilting/qp_problem_for_enhanced_esg.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
