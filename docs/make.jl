using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Julia for Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Portfolio Optimization" => Any[
            "The Markowitz framework"=>"Portfolio Optimization/markowitz_framework.md",
            "Capital asset pricing model (CAPM)"=>"Portfolio Optimization/capm.md",
            "Portfolio optimization in the presence of a benchmark"=>"Portfolio Optimization/optimization_benchmark.md",
            "Black-Litterman model"=>"Portfolio Optimization/black_litterman.md",
            "Covariance matrix"=>"Portfolio Optimization/covariance_matrix.md",
            "Expected returns"=>"Portfolio Optimization/expected_returns.md",
            "Regularization of optimized portfolios"=>"Portfolio Optimization/regularization.md",
            "Adding constraints"=>"Portfolio Optimization/adding_constraints.md"
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
