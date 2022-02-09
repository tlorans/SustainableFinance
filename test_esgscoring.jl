using Statistics
using PrettyTables
using Plots


Base.@kwdef mutable struct Variable
    X::Vector{Float64}
    name::String 
end

Base.@kwdef mutable struct Score
    S::Vector{Union{Float64, Missing}} # resulting score
    name::String
end


using Graphs
using GraphPlot
import Cairo, Fontconfig


Base.@kwdef mutable struct ScoringSystem
    X::Vector{Variable}
    S::Union{Nothing, Vector{Score}} = nothing # the vector of subscores
    ω::Union{Nothing, Vector{Float64}} = nothing # the vector of weights
    graph::Union{Nothing,SimpleDiGraph} = nothing # directed graph representing the scoring tree 
    score::Union{Nothing,Score} = nothing # the vector of aggregated score
end

X₁ = Variable(X = [94.0, 38.6, 30.6, 74.4, 97.1, 57.1, 132.4, 92.5, 64.9], name = "X₁") 

X₂ = Variable(X = [-0.03, -0.0550, 0.056, -0.013, -0.168, -0.035, 0.0850, -0.0910, -0.0460], name = "X₂")



function PrettyTables.pretty_table(X::Vector{Variable})
    x = reduce(hcat,[X[i].X for i in eachindex(X)])
    X_names = reduce(vcat,[X[i].name for i in eachindex(X)])
    return pretty_table(x, header = X_names)
end

pretty_table([X₁, X₂])

# How to create the synthetic score 30% X₁ + 70% X₂?
our_scoring = ScoringSystem(X = [X₁,X₂])

# q_score normalization
function q_score(X::Variable; scale = 100, get_plot = true)::Score 
    n = length(X.X)
    q = [length(filter(x -> x <= i, X.X))/(n+1) for i in X.X] .* scale
    s = Score(S = q, name = string("q-score ",X.name))
    if get_plot
        display(plot(sort(X.X), (1:n)./n * 100, 
            xlabel = X.name, ylabel = s.name,
            title = "q-score normalization", label = ""))
    end
    return s
end

function q_score(X::Vector{Variable}; scale = 100)::Vector{Score}
    s = []
    for i in eachindex(X)
        push!(s, q_score(X[i]))
    end 
    return s 
end

function q_score!(s::ScoringSystem)::ScoringSystem
    s.S = q_score(s.X)
    return s
end
q_score(X₁)
q_score([X₁, X₂])
q_score!(our_scoring)


function PrettyTables.pretty_table(s::ScoringSystem)
    X = reduce(hcat,[s.X[i].X for i in eachindex(s.X)])
    S = reduce(hcat,[s.S[i].S for i in eachindex(s.S)])
    X_names = reduce(vcat,[s.X[i].name for i in eachindex(s.X)])
    S_names = reduce(vcat,[s.S[i].name for i in eachindex(s.S)])
    return pretty_table(hcat(X,S), header = vcat(X_names, S_names))
end

pretty_table(our_scoring)


# z-score normalization 
function z_score(X::Variable; get_plot = true)::Score 
    μ = mean(X.X)
    σ = std(X.X)
    z = [(i - μ) / σ for i in X.X]
    s = Score(S = z, name = string("z-score ",X.name))
    if get_plot
        display(plot(sort(X.X), sort(s.S), 
            xlabel = X.name, ylabel = s.name,
            title = "z-score normalization", label = ""))
    end
    return s
end


function z_score(X::Vector{Variable}; get_plot = true)::Vector{Score}
    s = []
    for i in eachindex(X)
        push!(s, z_score(X[i]; get_plot))
    end 
    return s 
end

function z_score!(s::ScoringSystem; get_plot = true)::ScoringSystem
    s.S = z_score(s.X; get_plot)
    return s
end

z_score!(our_scoring)


pretty_table(our_scoring)

## aggregation
function get_scoring_tree!(s::ScoringSystem)::ScoringSystem
    n = length(s.S) # number of subscores
    G = Graphs.SimpleDiGraph(n+1) # we add + 1 to n because we need to take into account the score (aggregated)
    for i in 2:n+1 
        add_edge!(G,i, 1)
    end 
    # plot the graph 
    nodelabel = vcat(["s"],[s.S[i].name for i in eachindex(s.S)])
    display(gplot(G, nodelabel = nodelabel))
    s.graph = G
    return s
end


get_scoring_tree!(our_scoring)


function get_aggregate_score!(s::ScoringSystem)::ScoringSystem
    s.score = Score(S = sum([s.S[i].S * s.ω[i] for i in eachindex(s.ω)]),
                    name = "Aggregate score")

    pretty_table(s.score.S, header = [s.score.name])
    return s
end

our_scoring.ω = [0.3, 0.7]

get_aggregate_score!(our_scoring)



# using Distributions


# test = Normal(0,1)

# test = cdf.(test, X₁.X)


