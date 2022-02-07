using Statistics


Base.@kwdef mutable struct Variable
    X::Vector{Float64}
    name::String 
end


Base.@kwdef mutable struct Score
    S::Vector{Float64} # resulting score
    ω::Vector{Float64} # the vector of weights
    name::String
end


X₁ = Variable(X = [94.0, 38.6, 30.6, 74.4, 97.1, 57.1, 132.4, 92.5, 64.9], name = "X₁") 

X₂ = Variable(X = [-0.03, -0.0550, 0.056, -0.013, -0.168, -0.035, 0.0850, -0.0910, -0.0460], name = "X₂")

# How to create the synthetic score 30% X₁ + 70% X₂?

# q_score normalization
function q_score!(X::Variable; scale = 100)::Variable 
    n = length(X.X)
    q = [length(filter(x -> x <= i, X.X))/(n+1) for i in X.X] .* scale
    X.X = q
    return X
end

q_score!(X₁)
q_score!(X₂)

# z-score normalization 
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

using Distributions


test = Normal(0,1)

test = cdf.(test, X₁.X)
