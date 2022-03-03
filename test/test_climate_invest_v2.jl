Base.@kwdef mutable struct Benchmark
    b::Vector{Float64} # benchmark weights
    c::Vector{Float64} # Climate costs per $ mv
    σ::Vector{Float64} # Volatility 
    ρ::Matrix # Correlation matrix
    Σ::Union{Matrix,Nothing} = nothing # Covariance Matrix
end



ρ = [
    1 0.8 0.7 0.6 0.7 0.5 0.7 0.6
    0.8 1 0.75 0.65 0.5 0.6 0.5 0.65
    0.7 0.75 1 0.8 0.7 0.7 0.7 0.7
    0.6 0.65 0.8 1 0.85 0.8 0.75 0.75
    0.7 0.5 0.7 0.85 1 0.6 0.8 0.65
    0.5 0.6 0.7 0.8 0.6 1 0.5 0.7
    0.7 0.5 0.7 0.75 0.8 0.5 1 0.8
    0.6 0.65 0.7 0.75 0.65 0.7 0.8 1
]


our_benchmark = Benchmark(b = [0.23, 0.19, 0.17, 0.13, 0.09, 0.08, 0.06, 0.05],
                        c= [0.06, 0.8, 0.39, 0.01, 0.05, 0.13, 0.5, 0.45],
                        σ = [0.22, 0.20, 0.25, 0.18, 0.35, 0.23, 0.13, 0.29],
                        ρ = ρ)


function get_benchmark_climate_costs(bench::Benchmark, mv::Int)::Float64
    return - round(bench.b' * bench.c * mv; digits= 2)
end

get_benchmark_climate_costs(our_benchmark, 1000)


Base.@kwdef mutable struct TiltedPortfolio
    x::Vector{Float64} # Optimal weights
end

other_portfolio = TiltedPortfolio(x = [0.30, 0.10, 0.08, 0.02, 0.48, 0.01, 0.005, 0.0055])

function get_climate_benefits(portfolio::TiltedPortfolio, bench::Benchmark, mv::Int)::Float64 
    return -1 * round((portfolio.x - bench.b)' * bench.c * mv;digits = 5)
end

get_climate_benefits(other_portfolio, our_benchmark,1000)

check = other_portfolio.x' * our_benchmark.c * 1000

using LinearAlgebra
function get_cov_from_corr!(bench::Benchmark)::Benchmark
    D = diagm(bench.σ) # diagonal matrix of volatiltiy
    bench.Σ = D * bench.ρ * D # multiplying columns and rows of correlation matrix by volatiltiy
    return bench
end

get_cov_from_corr!(our_benchmark) 


function tracking_error_volatility(portfolio::TiltedPortfolio, bench::Benchmark)::Float64
    return sqrt((portfolio.x - bench.b)' * bench.Σ * (portfolio.x - bench.b))
end


# get_excess_score(portfolio, our_benchmark)


# tracking_error_volatility(portfolio, our_benchmark)


using JuMP, COSMO # for the optimization


# tilt the benchmark according to gamma
function portfolio_tilting(bench::Benchmark, γ::Float64)::TiltedPortfolio
    n = length(bench.c) # number of assets
    model = JuMP.Model(COSMO.Optimizer)
    # the optimal weights we want to find
    @variable(model, x[1:n])
    @objective(model, Min, 1/2 * x' * bench.Σ * x - x' * (γ * -1 * bench.c + bench.Σ * bench.b))
    @constraint(model, zeros(n) .<= x .<= ones(n))
    @constraint(model, ones(n)' * x == 1)
    JuMP.optimize!(model)
    portfolio = TiltedPortfolio(x = JuMP.value.(x))
    return portfolio
end


# simulate for gammas between 0 and 10
using Plots
gammas = [i for i in 0.0:0.001:0.012]
climate_benefits = zeros(length(gammas))
excess_te = zeros(length(gammas))

for i in 1:length(gammas)
    new_portfolio = portfolio_tilting(our_benchmark, gammas[i])
    climate_benefits[i] = get_climate_benefits(new_portfolio, our_benchmark, 1000) # suppose 1000 billion of MV for the benchmark
    excess_te[i] = tracking_error_volatility(new_portfolio, our_benchmark) * 100
end



plot(excess_te, climate_benefits, xlabel = "Tracking error volatility (in %)",
                                ylabel = "Climate benefits for society (in billion USD)",
                                label = "")

