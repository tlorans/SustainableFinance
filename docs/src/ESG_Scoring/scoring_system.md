# ESG Scoring

- Most of ESG scoring systems are based on scoring trees. 
- Raw data are normalised in order to obtain features $X_1,...,X_m$
- Features $X_1,...,X_m$ are aggregated to obtain sub-scores $s_1,...,s_n$:
$s_i = \sum_{j=1}^m \omega_{i,j}^{(1)}X_j$
- Sub-scores $s_1,...,s_n$ are aggregated to obtain the final score $s$:
$s_i = \sum_{i=1}^n \omega_i^{(2)}s_i$
This two-level structure can be extended to multi-level tree structures.

Let's implement the first stage of our scoring system.

First, we create a struct `Variable`, with two examples variables:
```julia
Base.@kwdef mutable struct Variable
    X::Vector{Float64}
    name::String 
end

X₁ = Variable(X = [94.0, 38.6, 30.6, 74.4, 97.1, 57.1, 132.4, 92.5, 64.9], name = "X₁") 

X₂ = Variable(X = [-0.03, -0.0550, 0.056, -0.013, -0.168, -0.035, 0.0850, -0.0910, -0.0460], name = "X₂")
```

However, how can we aggregate $X_1$ and $X_2$ to create a synthetic score? We need to normalize the features $X_1, ..., X_n$!


## Normalizing Scores

Once raw data have been normalized in order to facilitate the comparison (ie. absolute carbon emissions amount transformed to carbon intensity for example), resulting features $X_1, ..., X_m$ need to be normalized to facilitate the aggregation process.


Several normalization approches exist:

- q-score normalization:
  - 0-1 normalization: $q_i \in [0,1]$
  - 0-10 normalization: $q_i \in [0,10]$
  - 0-100 normalization: $q_i \in [0,100]$
$q_i = \hat F(x_i)$
Where $\hat F$ is the empirical probability distribution.
- z-score normalization:

$z_i = \frac{x_i - \hat\mu(X)}{\hat\sigma(X)}$

### q-score

Let $x_1, .., x_n$ be the sample. We have:

$q_i = \hat{F}(x_i) = Pr(X \leq x_i) = \frac{\#(x_j \leq x_i)}{n_q}$

We can use two normalization factors:

- $n_q = n$
- $n_q = n + 1$

Let's implement this in Julia:
```julia
function q_score!(X::Variable; scale = 100)::Variable 
    # the number of observations
    n = length(X.X)
    # we normalize the number of observations less or equal to each observation by n + 1 (the second normalization factor)
    q = [length(filter(x -> x <= i, X.X))/(n+1) for i in X.X] .* scale
    X.X = q
    return X
end

q_score!(X₁)
q_score!(X₂)
```

The outputs will be:
```
Variable([70.0, 20.0, 10.0, 50.0, 80.0, 30.0, 90.0, 60.0, 40.0], "X₁")
Variable([60.0, 30.0, 80.0, 70.0, 10.0, 50.0, 90.0, 20.0, 40.0], "X₂")
```
### z-score

Another normalization method can be the $z$-score:
```julia
using Statistics # to load the mean and std functions

function z_score!(X::Variable)::Variable
    μ = mean(X.X)
    σ = std(X.X)
    z = [(i - μ) / σ for i in X.X]
    X.X = z
    return X
end

X₁ = Variable(X = [94.0, 38.6, 30.6, 74.4, 97.1, 57.1, 132.4, 92.5, 64.9], name = "X₁") 
X₂ = Variable(X = [-0.03, -0.0550, 0.056, -0.013, -0.168, -0.035, 0.0850, -0.0910, -0.0460], name = "X₂")

z_score!(X₁)
z_score!(X₂)
```

The outputs will be:
```
Variable([0.5717875741990099, -1.1623564920760896, -1.4127744077836852, -0.04173631928459912, 0.6688245165357031, -0.5832650620022748, 1.7737935695954692, 0.5248342150038358, -0.3391075941873689], "X₁")
Variable([0.04022409138923949, -0.294976670187756, 1.1933147112141038, 0.2681606092615964, -1.8100841125157756, -0.02681606092615966, 1.5821475946434187, -0.7776657668586294, -0.1743043960200376], "X₂")
```

### From z-score to q-score



## Scoring Trees 

Let's illustrate this with a two-level tree structure.
Let's assume that at level 2:

$\omega_1^{(2)} = \omega_2^{(2)} = \omega_3^{(2)} = 33.33\%$

