# Portfolio Simulation

## Portfolio definition 

- We consider a universe of $n$ assets

- The vector of weights in the portfolio: 

$x = (x_1,...,x_n)$ 

- The portfolio is fuly invested:

$\sum^n_{i=1} x_i = 1_n^Tx = 1$

- The vector of asset returns where $R_i$ is the return of asset $i$

$R = (R_1,...,R_n)$

- The return of the portfolio is equal to:

$R(x) = \sum^n_{i=1}x_iR_i = x^TR$

- The vector of expected returns

$\mu = E[R]$ 

- The covariance matrix of asset returns:

$\Sigma = E[(R-\mu)(R-\mu)^T]$

Let's implement a `Portfolio` struct to encode these first informations: 
```julia
Base.@kwdef mutable struct Portfolio 
    μ::Vector{Float64} # the expected returns 
    σ::Vector{Float64} # volatiltiy
    x::Vector{Float64} # Weights
    C::Matrix # Correlation matrix
    Σ::Union{Nothing, Matrix} = nothing # Covariance matrix
end
```

And create a first example:
```julia
example_1 = Portfolio(μ = [0.05, 0.06, 0.08, 0.06],
                        σ = [0.15, 0.20, 0.25, 0.30],
                        x = [1/4 for i in 1:4], # just equally-weighted portfolio,
                        C = [
                            1 0.1 0.4 0.5
                            0.1 1 0.7 0.4
                            0.4 0.7 1 0.8
                            0.5 0.4 0.8 1
                            ])
```

We extend the function `pretty_table` to be used with our `Portfolio` struct:
```julia
using PrettyTables

function PrettyTables.pretty_table(portf::Portfolio)
    return pretty_table(reduce(hcat,[portf.μ, portf.σ, portf.x]), header = ["μ","σ","x"])
end


pretty_table(example_1)
```
We get:
```
┌──────┬──────┬──────┐
│    μ │    σ │    x │
├──────┼──────┼──────┤
│ 0.05 │ 0.15 │ 0.25 │
│ 0.06 │  0.2 │ 0.25 │
│ 0.08 │ 0.25 │ 0.25 │
│ 0.06 │  0.3 │ 0.25 │
└──────┴──────┴──────┘
```

## Expected return and volatility 

The expected return of the portfolio is:

$\mu(x) = E[R(x)] = E[x^TR] = x^T E[R] = x^T \mu$

Implementing this in Julia:
```julia
using LinearAlgebra

function get_portfolio_return(portfolio::Portfolio)
    return portfolio.x' * portfolio.μ # transpose of the vector of weights times the vector of expected reutnrs
end

get_portfolio_return(example_1)
```

Whereas its variance is equal to:

$\sigma^2(x) = E[(R(x) - \mu(x))(R(x) -\mu(x))^T]$

$= E[(x^T R - x^T \mu)(x^T R - x^T \mu)^T]$

$= E[x^T(R-\mu)(R-\mu)^Tx]$

$= x^T E[(R-\mu)(R-\mu)^T]x$

$= x^T \Sigma x$

As a shorthand, because the correlation matrix $C$ and standard deviation $\sigma$ will be given in most examples, we will deduce the covariance matrix $\Sigma$ based on the correlation matrix $C$ and $\sigma$, such as:

$\Sigma = diag(\sigma) * C * diag(\sigma)$

It means that we multiply each column of the correlation matrix by the corresponding standard deviation ($diag(\sigma) * C$) then we multiply each row of the result from this multiplication by the corresponding standard deviation.

To implement this in Julia, we need two functions. First we need to obtain the covariance matrix $\Sigma$ based on the correlation matrix $C$ given at the beginning:
```julia
function get_cov_from_corr!(portfolio::Portfolio)::Portfolio
    D = diagm(portfolio.σ) # diagonal matrix of volatiltiy
    portfolio.Σ = D * portfolio.C * D # multiplying columns and rows of correlation matrix by volatiltiy
    return portfolio
end

get_cov_from_corr!(example_1) 
```

Then, we can obtain the volatility such as:
```julia
function get_portfolio_volatility(portfolio::Portfolio)
    return sqrt(portfolio.x' * portfolio.Σ * portfolio.x)
end

get_portfolio_volatility(example_1)
```

## Portfolio simulation 

Base on these information, we will simulate 1000 portfolios thanks to our struct `Portfolio` and plot the expected returns and volatility of each of them thanks to our previously defined functions. 

First, to simulate 1000 different portfolios (different in terms of weights associated to each asset!), we need to define a function to get random vector of weights $x$ for each portfolio simulated:

```julia
using Random # to get random values

Random.seed!(123) # to fix the "random simulation" to something similar for each run.


function rand_weights(n::Int)
    k = rand(n) # n random numbers 
    return k / sum(k) # we normalized these random numbers to get weights which sum to 1
end
```
Once done, we can now create a function to generate a portfolio with randomly simulated weights:
```julia
n = 4 # number of assets

function random_portfolio(μ::Vector{Float64}, σ::Vector{Float64}, C::Matrix, n::Int)::Portfolio
    portfolio_random = Portfolio(μ = μ,
                                σ = σ,
                                x = rand_weights(n), # this is the only thing which change
                                C = C)
    get_cov_from_corr!(portfolio_random) # to get the covariance matrix
    return portfolio_random
end

μ = [0.05, 0.06, 0.08, 0.06] # same expected returns 
σ = [0.15, 0.20, 0.25, 0.30] # same volatility
C = [
    1 0.1 0.4 0.5
    0.1 1 0.7 0.4
    0.4 0.7 1 0.8
    0.5 0.4 0.8 1
    ] # same correlation matrix

test_portfolio = random_portfolio(μ, σ, C, n)
pretty_table(test_portfolio)
```

And you obtain a randomly simulated portfolio:
```
┌──────┬──────┬───────────┐
│    μ │    σ │         x │
├──────┼──────┼───────────┤
│ 0.05 │ 0.15 │  0.194085 │
│ 0.06 │  0.2 │  0.410517 │
│ 0.08 │ 0.25 │  0.363097 │
│ 0.06 │  0.3 │ 0.0323015 │
└──────┴──────┴───────────┘ 
```

Now, let's simulate 1000 portfolios, compute the expected returns and volatility for each, and plot it!
```julia
using Plots

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
```

!["markowitz"](markowitz_simulation.png)

