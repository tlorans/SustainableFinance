using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Introduction to Portfolio Optimization" => Any[
            "The Markowitz framework"=>"Portfolio Optimization/markowitz_framework.md"
        ],
        "Sustainable Finance" => Any[
            "Scoring System" => "Sustainable Finance/scoring_system.md",
            "QP Problem for Tilting" => "Sustainable Finance/qp_problem_for_tilting.md",
            "QP Problem for Enhanced ESG Score" => "Sustainable Finance/qp_problem_for_enhanced_esg.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
