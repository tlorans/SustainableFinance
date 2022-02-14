using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Introduction to Optimization" => Any[
            "Bisection Algorithm"=>"Introduction to Optimization/bisection_algorithm.md"
        ],
        "Introduction to Portfolio Optimization" => Any[
            "The Markowitz framework"=>"Portfolio Optimization/markowitz_framework.md"
        ],
        "ESG Investing" => Any[
            "Scoring System" => "ESG Investing/scoring_system.md",
            "QP Problem for Tilting" => "ESG Investing/qp_problem_for_tilting.md",
            "QP Problem for Enhanced ESG Score" => "ESG Investing/qp_problem_for_enhanced_esg.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
