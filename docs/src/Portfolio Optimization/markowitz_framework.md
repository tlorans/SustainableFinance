# The Markowitz framework

## Notations 

- We consider a universe of $n$ assets

- $x = (x_1,...,x_n)$ is the vector of weights in the portfolio

- The portfolio is fuly invested:

$\sum^n_{i=1} x_i = 1_n^Tx = 1$

- $R = (R_1,...,R_n)$ is the vector of asset returns where $R_i$ is the return of asset $i$.

- The return of the portfolio is equal to:

$R(x) = \sum^n_{i=1}x_iR_i = x^TR$

- $\mu = E[R]$ and $\Sigma = E[(R-\mu)(R-\mu)^T]$ are the vector of expected returns and the covariance matrix of asset returns

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
                        C = [1.0 0.0 0.0 0.0
                            0.10 1.0 0.0 0.0
                            0.4 0.7 1.0 0.0
                            0.5 0.4 0.8 1.0
                            ])
```

## Computation of the first two moments 

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

To implement this in Julia, we need two functions. First we need to obtain the covariance matrix $\Sigma$ based on the correlation matrix $C$ given at the beginning:
```julia
function get_cov_from_corr!(portfolio::Portfolio)::Portfolio
    D = diagm(portfolio.σ) # diagonal matrix of volatiltiy
    portfolio.Σ = D * portfolio.C * D
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


## Efficient frontier

We have two equivalent optimization problems:

- Maximizing the expected return of the portfolio under a volatility constraint ($\sigma$-problem):

$\begin{equation*}
\begin{aligned}
& \text{max}
&& \mu (x)
&&& {\text{u.c.}}
&&&& \sigma(x) \leq \sigma^* \\
\end{aligned}
\end{equation*}$

- Or minimizing the volatility of the portfolio under a return constraint ($\mu$-problem):

$\begin{equation*}
\begin{aligned}
& \text{min}
&& \sigma(x)
&&& {\text{u.c.}}
&&&& \mu(x) \geq \mu^*\\
\end{aligned}
\end{equation*}$

Let's first implement a simulation for 1000 portfolios:
```julia
using Random, Plots

Random.seed!(123)


###### Efficient Frontier: Simulation

# Number of assets 
n = 4 

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
```


!["markowitz"](markowitz_simulation.png)

## Markowitz trick 

Markowitz transforms the two original non-linear optimization problems into a quadratric optimization problem:


$\begin{equation*}
\begin{aligned}
& x^*(\phi) = 
& & {\text{arg max}}  x^T \mu - \frac{\phi}{2}x^T \Sigma x\\
& \text{u.c.}
& & 1^T_n x = 1 \\
\end{aligned}
\end{equation*}$

where $\phi$ is a risk-aversion parameter:

- $\phi = 0$: we have $\mu(x^*(0)) = \mu^+$

- if $\phi = \infty$, the optimization problem becomes:

$\begin{equation*}
\begin{aligned}
& x^*(\infty) = 
& & {\text{arg min}}  \frac{1}{2}x^T \Sigma x\\
& \text{u.c.}
& & 1^T_n x = 1 \\
\end{aligned}
\end{equation*}$

We have, in this case, $\sigma(x^*(\infty)) = \sigma^-$. This is the minimum variance (or MV) portfolio.