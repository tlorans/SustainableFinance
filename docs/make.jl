using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Mathematical Tools" => Any[
            "Solutions of Nonlinear Equations"=>"Mathematical Tools/solutions_nonlinear.md"
        ],
        "Introduction to Portfolio Optimization" => Any[
            "Portfolio Simulation"=>"Portfolio Optimization/portfolio_simulation.md",
            "QP Formulation"=>"Portfolio Optimization/qp_formulation.md"
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
