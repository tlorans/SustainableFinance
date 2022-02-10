using Random, LinearAlgebra, Plots

Random.seed!(123)

# Notations 

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
                        C = [1.0 0.0 0.0 0.0
                            0.10 1.0 0.0 0.0
                            0.4 0.7 1.0 0.0
                            0.5 0.4 0.8 1.0
                            ])



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


```
    function get_portfolio_volatility
Returns the portfolio volatilitiy.
```
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
C = [1.0 0.0 0.0 0.0
    0.10 1.0 0.0 0.0
    0.4 0.7 1.0 0.0
    0.5 0.4 0.8 1.0
    ]

test_portfolio = random_portfolio(μ, σ, C, n)


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



