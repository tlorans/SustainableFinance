### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ d535c33a-84b1-11ec-1209-9558b54ae47c
begin
	using PlutoUI
	md"""
	# Performance of ESG Investing
	
	An introduction to performance in ESG investing based on Thierry Roncalli's [lecture](https://www.researchgate.net/publication/358229347_A_Course_in_Sustainable_Finance).
	"""
end

# ╔═╡ 451662d6-6b87-414f-9cea-7aa5fae9208d
using CSV, DataFrames, D3Trees, Statistics, StatsBase, Distributions, LinearAlgebra, JuMP, COSMO, SparseArrays, Random,NamedArrays

# ╔═╡ 35eab9cc-0609-4da9-aa93-1a494e5a61dd
md"""
## Lecture Outline
- Passive Management (Optimized Portfolios) and ESG Scores
  - ESG Excess Score
"""

# ╔═╡ b061a081-5bbb-409c-a1aa-931063ef085e
md"""
## Tilted Portfolios with ESG and Carbon Intensity Constraints


"""

# ╔═╡ 64692caa-30ec-4d8f-bfeb-a341aff44f3e
md"""

### CAPM Model and Covariance Matrix

Let's consider the CAPM model:

$R_i - r = \beta_i (R_m - r) + \epsilon_i$
where $R_i$ is the return of Asset $i$, $R_m$ is the return of the market portfolio, $r$ is the risk free asset, $\beta_i$ is the beta of Asset $i$ with respect to the market portfolio and $\epsilon_i$ is the idiosyncratic risk

We assume that $R_m \perp \epsilon_i$ and $\epsilon_i \perp \epsilon_j$.

We note $\sigma_m$ the volatility of the market portfolio and $\tilde{\sigma_i}$ the idiosyncratic volatility.

We consider a universe of 5 assets:
"""

# ╔═╡ 122f7117-1913-4778-b74d-9d0768250c9c
five_assets = NamedArray([0.30 0.5 0.9 1.3 2;
						0.15 0.16 0.1 0.11 0.12], (["Beta", "sigma"],["A","B","C","D","E"]))

# ╔═╡ 9c222eea-2fbf-471f-9baa-c0a83fcd7a6d
md"""
And $\sigma_m = 20\%$. The risk free return is set to $1\%$ and we assume that the expected return of the market portfolio is equal to $\mu_m = 6 \%$.
"""

# ╔═╡ ffb6c335-d9ce-4e66-ba1f-2dbd3689ba5c
md"""
The vector $\mu$ of expected returns is then:

$\mu = E[R_i]$
$= r + \beta_i (\mu_m - r)$
"""

# ╔═╡ 80c8b7cb-96b5-41de-8fb3-050a2a6c159b
μ_tilt_example = vec(0.01 .+ five_assets["Beta",:] * (0.06 - 0.01))

# ╔═╡ b4f6bf13-d22c-4534-a8c2-6867e44ac2b5
md"""
We can then compute the covariance matrix Σ:

$\Sigma = cov(R)$
$=\beta \beta^T \sigma^2_m + diag(\tilde{\sigma}^2_1,...,\tilde{\sigma}^2_5)$
"""

# ╔═╡ 1b15d18c-f629-4159-a4fb-a60c21289694
begin
	Σ_tilt_example = vec(five_assets["Beta",:]) * vec(five_assets["Beta",:])' * (0.2^2) + diagm(vec(five_assets["sigma",:]))
end

# ╔═╡ 7bac9ff2-c22a-4c5a-b797-cf9f8c975695
md"""
We can deduce the volatility $\sigma_i$:

$\sigma_i = \sqrt{\beta_i^2 \sigma^2_m + \tilde{\sigma_i^2}}$
"""

# ╔═╡ 6c477ca6-326b-4e77-8ddb-8cd91b5acd80
sigma_tilted_example = sqrt.(vec(five_assets["Beta",:]).^2 * (0.2^2) + vec(five_assets["sigma",:]).^2)

# ╔═╡ 84788dee-5a25-43e1-a070-1195dfb0c43d
md"""
and the correlation matrix:
"""

# ╔═╡ fc50663d-b4c1-401f-a8b8-9fa93e0421b3
correl_tilted = cov2cor(Σ_tilt_example, sigma_tilted_example)

# ╔═╡ efb67489-06ad-4f53-bc1a-ce3991afb48f
md"""
### Portfolio's Extrafinancial and Financial Excess Performance
"""

# ╔═╡ d014fe03-3bb9-4d3e-9033-1c3b04087a0d
md"""
### Modified QP Problem for Tilted Portfolios

Recall that the formulation of a standard QP problem is:

$\begin{equation*}
\begin{aligned}
& x^* = 
& & {\text{arg min}}  \frac{1}{2}x^TQx-x^TR\\
& \text{subject to}
& & Ax = B \\
&&& Cx \leq D \\
&&& x^- \leq x \leq x^+
\end{aligned}
\end{equation*}$

Let's assume an example where we would like to tilt the benchmark $b$ in order to improve its expected return. We have a modified $\gamma$ problem where $\gamma$ is the risk aversion parameter.
What we want in this exercise is:
- enhance the excess expected return compared to the benchmark: 

$\mu(x|b)$

- and minimize the tracking error volatility relative to the benchmark:

$\sigma^2(x |b)$
"""

# ╔═╡ a7343a93-2f6f-4455-b2e1-1a8a3b19b733
md"""

#### Modified Objective Function

The initial objective function:

$x^* = \text{arg min} \frac{1}{2}x^TQx-x^TR$

becomes: 

$x^* =  \text{arg min} \frac{1}{2} \sigma^2(x |b) - \mu(x|b)$

Since we want to formulate the $\gamma$-problem of portfolio optimization, it becomes:

$x^*(\gamma) = \text{arg min} \frac{1}{2} \sigma^2(x |b) - \gamma\mu(x|b)$

Finally, since $\sigma^2(x|b)=(x-b)^T \Sigma (x-b)$ and $\mu(x|b) = (x-b)^T \mu$, we have the QP objective function:

$x^*(\gamma) = \text{arg min} \frac{1}{2} x^T \Sigma x - x^T (\gamma \mu + \Sigma b)$
"""

# ╔═╡ d970feaf-9fb0-4c51-8738-0164e4fb68da
md"""
#### Modified Constraints

Let's now reformulate the initial constraints. 
We first had in the initial QP problem:

$Ax = B$

which will become:

$1^T_nx = 1$
(i.e. the sum of the weights $x_i$ must sum to one)

We then had:

$x^- \leq x \leq x^+$

Which becomes:

$0_n \leq x \leq 1_n$
(i.e. the weights $x_i$ must be between 0 and 1)

"""

# ╔═╡ f26affef-fcac-4356-9826-a30d0c86339e
md"""
#### Drawing Financial and Extrafinancial Efficient Frontiers

We compute $x^*(\gamma)$ for several values for $\gamma \in [0,10]$ to draw the efficient frontier.

To assess the performance of the portfolio against the benchmark, we will specifically:

- Draw the relationship between the tracking error volatility $\sigma(x^*(\gamma)|b)$ and the excess expected return $\mu (x^*(\gamma)|b)$
- Draw the relationship between $\sigma(x^*(\gamma)|b)$ and $S^{ESG}(x^*(\gamma))$
"""

# ╔═╡ 80f3dd59-3d0f-4ce4-8127-251e062ac424
md"""
## Passive Management (Optimized Portfolios) and ESG Scores

We consider the following optimization problem:

$x^*(\gamma) = argmin \frac{1}{2}\sigma^2(x | b) - \gamma s(x | b)$
With $b$ the benchmark, $s$ the vector of scores.
$\sigma(x|b)$ is the ex_ante tracking error (TE) of Portfolio $x$ with respect to the benchmark $b$:

$\sigma(x|b)=\sqrt{(x|b)^T\Sigma(x-b)}$
Where $\Sigma$ is the covariance matrix.
And $s(|b)$ is the excess score (ES) of Portfolio $x$ with respect to the benchmark $b$:

$s(x|b) = (x-b)^Ts = s(x) - s(b)$

- The objective is to find the optimal portfolio with the minimum TE for a given ESG excess score
- This is a standard $\gamma$-problem where the expected returns are replaced by the ESG scores.
"""

# ╔═╡ 7a49eae9-80eb-4bf3-a3f9-875a3c6996ce
md"""
### ESG Excess Score

We consider a capitalization-weighted equity index, which is composed of 8 stocks. Their weights, volatilities and ESG scores are the following:
"""

# ╔═╡ 5e72150a-3c78-4c6f-b09d-d8ad2cf14340
begin
	issuers = ["A","B","C","D","E","F","G","H"]
	cw_weights = [0.23, 0.19, 0.17, 0.13, 0.09, 0.08, 0.06, 0.05]
	volatility = [0.22, 0.20, 0.25, 0.18, 0.35, 0.23, 0.13, 0.29]
	esg_score = [-1.20, 0.80, 2.75, 1.60, -2.75, -1.30,0.90, -1.70]
	data_passive = DataFrame(:issuers => issuers,
							:CW_weight => cw_weights,
							:volatility => volatility,
							:ESG_score => esg_score)
end

# ╔═╡ 3f95f990-9666-45b3-bdbd-c54eb693fb98
md"""
And the correlation matrix is given by:
"""

# ╔═╡ 69f86a8f-ea90-4c45-95b7-326bd7a48f02
correlation_matrix = (sparse([1,2,3,4,5,6,7,8,2,3,4,5,6,7,8,3,4,5,6,7,8,4,5,6,7,8,5,6,7,8,6,7,8,7,8,8],
[1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,6,6,6,7,7,8],
[1,0.8,0.7,0.6,0.7,0.5,0.7,0.6,1,0.75,0.65,0.5,0.6,0.5,0.65,1,0.8,0.7,0.7,0.7,0.7,1,0.85,0.8,0.75,0.75,1,0.6,0.8,0.65,1,0.5,0.7,1,0.8,1]))

# ╔═╡ 88419920-d494-4d5a-a468-77e804e3a205
benchmark_score = sum(data_passive[:,:CW_weight] .* data_passive[:,:ESG_score]);

# ╔═╡ 8a40f17b-ac5f-43ba-8fbf-e35b12b3d642
md"""
With $b_i$ the weight in the benchmark and $s_i$ the ESG score of the stock $i$, the ESG score of the benchmark is equal to:
$s(b) = \sum^8_{i=1}b_is_i$=$benchmark_score
"""

# ╔═╡ 94e60890-bdac-457c-8e56-14a927facba0
ew_score = mean(data_passive[:,:ESG_score]);

# ╔═╡ 0cf160f2-51ea-4a4c-8e45-d06b6ceba3e9
md"""
Let's now compute the equally-weighted (EW) portfolio's score:
$s(x_{ew}) = \sum^8_{i=1}\frac{s_i}{8}$=$ew_score
"""

# ╔═╡ 83a7874d-62ec-4d0e-b2ac-c58fbcc51440
excess_score_ew = ew_score - benchmark_score;

# ╔═╡ c72c1f2b-a7c0-4d09-8654-2677063c382b
md"""
We can now compute the ESG excess score with respect to the benchmark:

$s(x|b) = s(x) - s(b)$

Then:
$s(x_{ew}|b)$ = $ew_score - $benchmark_score = $excess_score_ew

The EW portfolio is then less performant than the benchmark portfolio in terms of ESG score.
"""

# ╔═╡ 1873099e-cc57-4088-bf42-ca6f228f0737
md"""
### Tracking Error Control

- Recall that the ESG Excess score is: 

$s(x|b) = (x-b)^Ts$ 

and that the volatility of the tracking error is:

$\sigma^2(x|b)=(x-b)^T\Sigma(x-b)$

- The initial objective function 

$x^*(\gamma) = argmin \frac{1}{2}\sigma^2(x | b) - \gamma s(x | b)$ 

becomes:

$x^*(\gamma) = argmin \frac{1}{2}x^T\Sigma x-x^T(\gamma s+\Sigma b)$
(ie. the efficient portfolio must enhancing the ESG score while minimizing the tracking error volatility compared to the benchmark, with respect to the $\gamma$ parameter or risk aversion parameter).

- The constraints are simply:
  - $1^Tx=1$ (ie. the weights must sum to one)
  - $0\leq x \leq 1$ (ie. the weights must be between 0 and 1)
"""

# ╔═╡ 63ad8da3-4e7a-4603-bcee-08825e77e20d
Σ = Matrix(transpose(volatility .* transpose(correlation_matrix)) .* volatility)

# ╔═╡ fe6fc46f-45d4-4240-ab2d-1168956eb9be
test = cov2cor(Σ, volatility)

# ╔═╡ f4d51f64-f997-484e-b5d7-e9948b53ba3b
new_sigma = transpose(volatility .* transpose(test)) .* volatility

# ╔═╡ d40bf6c5-133c-4d01-b94c-ffa7e76d9088
begin
	# generate the data
	n = length(issuers) # number of assets
	# the risk-aversion parameter
	γ = 0.07355
	# μ (the expected returns) is replaced by the ESG excess score
	# the risk factor is replaced by the tracking error volatility
	model = JuMP.Model(COSMO.Optimizer)
	# the optimal weights we want to find
	@variable(model, x[1:n])
	@objective(model, Min, 1/2 * x' * new_sigma * x - x' * (γ * esg_score + new_sigma * cw_weights))
	@constraint(model, zeros(n) .<= x .<= ones(n))
	@constraint(model, ones(n)' * x == 1)
	@constraint(model, x .<= 0.3)
	#latex_formulation(model)
	JuMP.optimize!(model)
	x_opt = JuMP.value.(x)
	#esg_excess_score = (x_opt - cw_weights)' * esg_score
	#tracking_error_excess = sqrt((x_opt - cw_weights)' * Σ * (x_opt- cw_weights))
end

# ╔═╡ 3420498c-1824-4f97-813c-8fbbcbb25592


# ╔═╡ 4dd763d8-f6e1-4d1f-bef8-6e2c7372b41b
ones(7)

# ╔═╡ ce07b82b-accf-474c-b995-7149345312ad


# ╔═╡ 26541245-58e9-4b7c-8f47-0b0f95f72e16


# ╔═╡ 2461c78a-2201-4f1c-8057-83daa941bad7
TableOfContents(title="ESG Performance", depth=4)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
COSMO = "1e616198-aa4e-51ec-90a2-23f7fbd31d8d"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
D3Trees = "e3df1716-f71e-5df9-9e2d-98e193103c45"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
NamedArrays = "86f7a689-2022-50b4-a561-43c23ac3c673"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
COSMO = "~0.8.3"
CSV = "~0.10.2"
D3Trees = "~0.3.1"
DataFrames = "~1.3.2"
Distributions = "~0.25.46"
JuMP = "~0.22.2"
NamedArrays = "~0.9.6"
PlutoUI = "~0.7.33"
StatsBase = "~0.33.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AMD]]
deps = ["Libdl", "LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "fc66ffc5cff568936649445f58a55b81eaf9592c"
uuid = "14f7f29c-3bd6-536c-9a0b-7339e30b5a3e"
version = "0.4.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "940001114a0147b6e4d10624276d56d531dd9b49"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.2"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[COSMO]]
deps = ["AMD", "COSMOAccelerators", "DataStructures", "IterTools", "LinearAlgebra", "MathOptInterface", "Pkg", "Printf", "QDLDL", "Random", "Reexport", "Requires", "SparseArrays", "Statistics", "SuiteSparse", "Test", "UnsafeArrays"]
git-tree-sha1 = "cd4c6dcda06302b5c20517d4acf1740c9cda8b8c"
uuid = "1e616198-aa4e-51ec-90a2-23f7fbd31d8d"
version = "0.8.3"

[[COSMOAccelerators]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "b1153b40dd95f856e379f25ae335755ecc24298e"
uuid = "bbd8fffe-5ad0-4d78-a55e-85575421b4ac"
version = "0.1.0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "9519274b50500b8029973d241d32cfbf0b127d97"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.2"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[D3Trees]]
deps = ["AbstractTrees", "Base64", "JSON", "Random", "Test"]
git-tree-sha1 = "311af855efa91a595940cd5c0cdb0ff9e8d6b948"
uuid = "e3df1716-f71e-5df9-9e2d-98e193103c45"
version = "0.3.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "84083a5136b6abf426174a58325ffd159dd6d94f"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.9.1"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "2e97190dfd4382499a4ac349e8d316491c9db341"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.46"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "1bd6fc0c344fc0cbee1f42f8d2e7ec8253dda2d2"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.25"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JuMP]]
deps = ["Calculus", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MathOptInterface", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "Random", "SparseArrays", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "30bbc998df62c12eee113685c6f4d2ad30a8781c"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "0.22.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "JSON", "LinearAlgebra", "MutableArithmetics", "OrderedCollections", "Printf", "SparseArrays", "Test", "Unicode"]
git-tree-sha1 = "625f78c57a263e943f525d3860f30e4d200124ab"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "0.10.8"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "73deac2cbae0820f43971fad6c08f6c4f2784ff2"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.3.2"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "da2314d0b0cb518906ea32a497bb4605451811a4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.33"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[QDLDL]]
deps = ["AMD", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "3d9d783667d3114f4d6c46a935e7f106aab68017"
uuid = "bfc457fd-c171-5ab7-bd9e-d5dbfc242d63"
version = "0.1.5"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "15dfe6b103c2a993be24404124b8791a09460983"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.11"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e6bf188613555c78062842777b116905a9f9dd49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a635a9333989a094bddc9f940c04c549cd66afcf"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.4"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f35e1879a71cca95f4826a14cdbf0b9e253ed918"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.15"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnsafeArrays]]
git-tree-sha1 = "038cd6ae292c857e6f91be52b81236607627aacd"
uuid = "c4a57d5a-5b31-53a6-b365-19f8c011fbd6"
version = "1.0.3"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═d535c33a-84b1-11ec-1209-9558b54ae47c
# ╠═35eab9cc-0609-4da9-aa93-1a494e5a61dd
# ╠═451662d6-6b87-414f-9cea-7aa5fae9208d
# ╠═b061a081-5bbb-409c-a1aa-931063ef085e
# ╟─64692caa-30ec-4d8f-bfeb-a341aff44f3e
# ╟─122f7117-1913-4778-b74d-9d0768250c9c
# ╟─9c222eea-2fbf-471f-9baa-c0a83fcd7a6d
# ╟─ffb6c335-d9ce-4e66-ba1f-2dbd3689ba5c
# ╟─80c8b7cb-96b5-41de-8fb3-050a2a6c159b
# ╟─b4f6bf13-d22c-4534-a8c2-6867e44ac2b5
# ╟─1b15d18c-f629-4159-a4fb-a60c21289694
# ╟─7bac9ff2-c22a-4c5a-b797-cf9f8c975695
# ╟─6c477ca6-326b-4e77-8ddb-8cd91b5acd80
# ╟─84788dee-5a25-43e1-a070-1195dfb0c43d
# ╟─fc50663d-b4c1-401f-a8b8-9fa93e0421b3
# ╠═efb67489-06ad-4f53-bc1a-ce3991afb48f
# ╟─d014fe03-3bb9-4d3e-9033-1c3b04087a0d
# ╟─a7343a93-2f6f-4455-b2e1-1a8a3b19b733
# ╟─d970feaf-9fb0-4c51-8738-0164e4fb68da
# ╟─f26affef-fcac-4356-9826-a30d0c86339e
# ╠═80f3dd59-3d0f-4ce4-8127-251e062ac424
# ╟─7a49eae9-80eb-4bf3-a3f9-875a3c6996ce
# ╠═5e72150a-3c78-4c6f-b09d-d8ad2cf14340
# ╠═3f95f990-9666-45b3-bdbd-c54eb693fb98
# ╠═69f86a8f-ea90-4c45-95b7-326bd7a48f02
# ╠═fe6fc46f-45d4-4240-ab2d-1168956eb9be
# ╟─8a40f17b-ac5f-43ba-8fbf-e35b12b3d642
# ╟─88419920-d494-4d5a-a468-77e804e3a205
# ╟─0cf160f2-51ea-4a4c-8e45-d06b6ceba3e9
# ╟─94e60890-bdac-457c-8e56-14a927facba0
# ╟─c72c1f2b-a7c0-4d09-8654-2677063c382b
# ╟─83a7874d-62ec-4d0e-b2ac-c58fbcc51440
# ╠═1873099e-cc57-4088-bf42-ca6f228f0737
# ╠═63ad8da3-4e7a-4603-bcee-08825e77e20d
# ╠═f4d51f64-f997-484e-b5d7-e9948b53ba3b
# ╠═d40bf6c5-133c-4d01-b94c-ffa7e76d9088
# ╠═3420498c-1824-4f97-813c-8fbbcbb25592
# ╠═4dd763d8-f6e1-4d1f-bef8-6e2c7372b41b
# ╠═ce07b82b-accf-474c-b995-7149345312ad
# ╠═26541245-58e9-4b7c-8f47-0b0f95f72e16
# ╠═2461c78a-2201-4f1c-8057-83daa941bad7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
