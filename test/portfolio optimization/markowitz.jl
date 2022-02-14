using Random, LinearAlgebra, Plots
using PrettyTables
Random.seed!(123)

# Portfolio 

Base.@kwdef mutable struct Portfolio 
    μ::Vector{Float64} # the expected returns 
    σ::Vector{Float64} # volatiltiy
    x::Vector{Float64} # Weights
    C::Matrix # Correlation matrix
    Σ::Union{Nothing, Matrix} = nothing # Covariance matrix
end


example_1 = Portfolio(μ = [0.05, 0.06, 0.08, 0.06],
                        σ = [0.15, 0.20, 0.25, 0.30],
                        x = [1/4 for i in 1:4], # just equally-weighted portfolio,         
                        C = [
                        1 0.1 0.4 0.5
                        0.1 1 0.7 0.4
                        0.4 0.7 1 0.8
                        0.5 0.4 0.8 1
                        ])

function PrettyTables.pretty_table(portf::Portfolio)
    return pretty_table(reduce(hcat,[portf.μ, portf.σ, portf.x]), header = ["μ","σ","x"])
end


pretty_table(example_1)


# portfolio return 
```
    function get_portfolio_return
Obtain the portfolio returns.
```
function get_portfolio_return(portfolio::Portfolio)
    return portfolio.x' * portfolio.μ # transpose of the vector of weights times the vector of expected reutnrs
end

get_portfolio_return(example_1)

# covariance matrix 
```
    function get_cov_from_corr!
Convert the correlation matrix to the covariance matrix Σ.
```
function get_cov_from_corr!(portfolio::Portfolio)::Portfolio
    D = diagm(portfolio.σ)
    portfolio.Σ = D * portfolio.C * D
    return portfolio
end

get_cov_from_corr!(example_1)




function get_portfolio_volatility(portfolio::Portfolio)
    return sqrt(portfolio.x' * portfolio.Σ * portfolio.x)
end

get_portfolio_volatility(example_1)

###### Efficient Frontier: Simulation

# Number of assets 
n = 4 

```
    function rand_weights 
Produces n random weights that sum to 1.
```
function rand_weights(n::Int)
    k = rand(n)
    return k / sum(k)
end

rand_weights(n)

function random_portfolio(μ::Vector{Float64}, σ::Vector{Float64}, C::Matrix, n::Int)::Portfolio
    portfolio_random = Portfolio(μ = μ,
                                σ = σ,
                                x = rand_weights(n),
                                C = C)
    get_cov_from_corr!(portfolio_random)
    return portfolio_random
end

μ = [0.05, 0.06, 0.08, 0.06]
σ = [0.15, 0.20, 0.25, 0.30]
C = [
    1 0.1 0.4 0.5
    0.1 1 0.7 0.4
    0.4 0.7 1 0.8
    0.5 0.4 0.8 1
    ]

test_portfolio = random_portfolio(μ, σ, C, n)

pretty_table(test_portfolio)
test_portfolio.Σ

# number of observations 
n_obs = 1000

returns = zeros(n_obs)
volatility = zeros(n_obs)

for i in 1:n_obs
    portf = random_portfolio(μ, σ, C, n)
    returns[i] = get_portfolio_return(portf)
    volatility[i] = get_portfolio_volatility(portf)
end

plot(volatility, returns, seriestype = :scatter, label = "",
    xlabel = "Volatility", ylabel = "Expected returns")


# Efficient Frontier

using JuMP, COSMO # Optimization

function optimal_portfolio_markowitz(μ::Vector{Float64}, Σ::Matrix, ϕ::Float64)::Vector{Float64}
    n = length(μ) # number of assets
    model = JuMP.Model(COSMO.Optimizer)
    @variable(model, x[1:n]) # the optimal weights we want to find
    @objective(model, Max, x' * μ - ϕ/2 * x' * Σ * x)
    @constraint(model, ones(n)' * x == 1)
    JuMP.optimize!(model)
    x_opt = JuMP.value.(x)
    return x_opt
end

μ = [0.05, 0.06, 0.08, 0.06]

Σ = [
    0.0225  0.003  0.015   0.0225
    0.003   0.04   0.035   0.024
    0.015   0.035  0.0625  0.06
    0.0225  0.024  0.06    0.09
]


x_opt = optimal_portfolio_markowitz(μ, Σ, 0.2)
portf = Portfolio(μ = μ, σ = σ, C = C, Σ = Σ, x = x_opt)
returns = get_portfolio_return(portf)
volatility = get_portfolio_volatility(portf)

phis = [i for i in 1:0.1:500]


returns = zeros(length(phis))
volatility = zeros(length(phis))
for i in 1:length(phis)
    x = optimal_portfolio_markowitz(μ, Σ, phis[i])
    portf = Portfolio(μ = μ, σ = σ, C = C, Σ = Σ, x = x)
    returns[i] = get_portfolio_return(portf)
    volatility[i] = get_portfolio_volatility(portf)
end


plot(volatility, returns, seriestype = :line, label = "",
    xlabel = "Volatility", ylabel = "Expected returns")

