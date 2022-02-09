

Base.@kwdef mutable struct Benchmark
    μ::Vector{Float64} # Expected returns 
    b::Vector{Float64} # benchmark weights
    s::Vector{Float64} # ESG Score
    Σ::Matrix # Covariance Matrix
end


Σ = [ 0.1536  0.006  0.0108  0.0156  0.024
0.006   0.17   0.018   0.026   0.04
0.0108  0.018  0.1324  0.0468  0.072
0.0156  0.026  0.0468  0.1776  0.104
0.024   0.04   0.072   0.104   0.28]

our_benchmark = Benchmark(μ = [0.03,0.04,0.05,0.07,0.1],
                        b = [0.2, 0.2, 0.2, 0.2, 0.2],
                        s= [1.1,2.7,-0.9,-2.2,0.4], 
                        Σ = Σ)


# What is the ESG score of the benchmark?

function get_benchmark_score(bench::Benchmark)::Float64
    return round(bench.b' * bench.s; digits= 2)
end

get_benchmark_score(our_benchmark)


# Excess returns and tracking error volatility

Base.@kwdef mutable struct TiltedPortfolio
    x::Vector{Float64} # Optimal weights
end

portfolio = TiltedPortfolio(x = [0.1, 0.1, 0.3, 0.3, 0.2])

function get_portfolio_score(portfolio::TiltedPortfolio, bench::Benchmark)::Float64
    return round(portfolio.x' * bench.s; digits= 2)
end

get_portfolio_score(portfolio, our_benchmark)

function get_excess_returns(portfolio::TiltedPortfolio, bench::Benchmark)::Float64 
    return round((portfolio.x - bench.b)' * bench.μ;digits = 5)
end

get_excess_returns(portfolio, our_benchmark)


function tracking_error_volatility(portfolio::TiltedPortfolio, bench::Benchmark)::Float64
    return sqrt((portfolio.x - bench.b)' * bench.Σ * (portfolio.x - bench.b))
end

tracking_error_volatility(portfolio, our_benchmark)

function information_ratio(portfolio::TiltedPortfolio, bench::Benchmark)::Float64
    return get_excess_returns(portfolio, bench) / tracking_error_volatility(portfolio, bench)
end

information_ratio(portfolio, our_benchmark)

# Modified QP problem

using JuMP, COSMO


# tilt the benchmark according to gamma
function portfolio_tilting(bench::Benchmark, γ::Float64)::TiltedPortfolio
    n = length(bench.μ) # number of assets
    model = JuMP.Model(COSMO.Optimizer)
    # the optimal weights we want to find
    @variable(model, x[1:n])
    @objective(model, Min, 1/2 * x' * Σ * x - x' * (γ * bench.μ + bench.Σ * bench.b))
    @constraint(model, zeros(n) .<= x .<= ones(n))
    @constraint(model, ones(n)' * x == 1)
    JuMP.optimize!(model)
    portfolio = TiltedPortfolio(x = JuMP.value.(x))
    return portfolio
end

# simulate for gammas between 0 and 10
using Plots
gammas = [i for i in 0.0:1:10.0]
excess_returns = zeros(length(gammas))
excess_te = zeros(length(gammas))
esg_scores = zeros(length(gammas))

for i in 1:length(gammas)
    new_portfolio = portfolio_tilting(our_benchmark, gammas[i])
    excess_returns[i] = get_excess_returns(new_portfolio, our_benchmark)
    excess_te[i] = tracking_error_volatility(new_portfolio, our_benchmark)
    esg_scores[i] = get_portfolio_score(new_portfolio, our_benchmark)
end


plot(excess_te, excess_returns, xlabel = "Tracking error volatility",
                                ylabel = "Excess expected returns",
                                label = "")


plot(excess_te, esg_scores, xlabel = "Tracking error volatility",
ylabel = "ESG score", label = "")