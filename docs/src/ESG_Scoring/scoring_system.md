# ESG Scoring

## Scoring System

- Most of ESG scoring systems are based on scoring trees. 
- Raw data are normalised in order to obtain features $X_1,...,X_m$
- Features $X_1,...,X_m$ are aggregated to obtain sub-scores $s_1,...,s_n$:
$s_i = \sum_{j=1}^m \omega_{i,j}^{(1)}X_j$
- Sub-scores $s_1,...,s_n$ are aggregated to obtain the final score $s$:
$s_i = \sum_{i=1}^n \omega_i^{(2)}s_i$
This two-level structure can be extended to multi-level tree structures.

```julia
julia> Base.@kwdef mutable struct SubScore
    X::Vector{Float64}
    s::Vector{Float64}
end
```

```julia
julia> Base.@kwdef mutable struct Score
    s::Vector{ScoringVariable}
    ω::Vector{Float64}
end
```

```julia
```





### Scoring Trees 

Let's illustrate this with a two-level tree structure.
Let's assume that at level 2:

$\omega_1^{(2)} = \omega_2^{(2)} = \omega_3^{(2)} = 33.33\%$

```julia
julia>Base.@kwdef mutable struct ScoringTree

end
```
