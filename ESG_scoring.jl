### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0588e72e-83ef-11ec-106a-517c7ec687cc
begin
	using PlutoUI
	md"""
	# ESG Scoring
	
	An introduction to ESG scoring based on Thierry Roncalli's [lecture](https://www.researchgate.net/publication/358229347_A_Course_in_Sustainable_Finance).
	"""
end

# ╔═╡ 61e63742-fd93-4825-bd77-184e66b9fe27
using CSV, DataFrames, D3Trees, Statistics, StatsBase, Distributions

# ╔═╡ 042774fe-33cc-4162-b50f-aaba28a13e53
using Plots; default(fontfamily="Computer Modern", framestyle=:box) # LaTex-style

# ╔═╡ 882ebf57-19b6-475b-aa19-e9b2e168acbf
md"""
## Lecture Outline
- Data
  - Sovereign Issuers Example
  - Corporate Issuers Example
- Scoring System
  - Scoring Trees
  - Normalizing Scores
- Illustations
  - Issuer's ESG Score Computation
  - ESG Score Distribution and Portfolio Concentration
"""

# ╔═╡ b83f41ea-665d-474f-a32f-0f93ff6af1f5
md"""
## Data

ESG requires a lot of data and alternative data. These data must covers various critera.
For example, an ESG scoring system for sovereign issuers could cover:

Environmental | Social | Governance
:----------- | :-------------- | :--------------
Carbon emissions | Income inequality | Political stability
Energy transition risk | Living standards | Institutional strength
Fossil fuel exposure | Non-discrimiation | Levels of corruption
Emissions reduction target | Health & security | Rule of law
Physical risk exposure | Local communities and human rights | Government and regulatory effectiveness
Green economy | Social cohesion | Rights of shareholders
 | Access to education | 

For corporate issuers, an example of ESG criteria could be:

Environmental | Social | Governance
:----------- | :-------------- | :--------------
Carbon emissions | Employment conditions | Board independence
Energy use | Community involvement | Corporate behaviour
Pollution | Gender equality | Audit and control
Waste disposal | Diversity | Executive compensation
Water use | Stakeholder opposition | Shareholder' rights
Renewable energy | Access to medicine | CSR strategy
Green cars (Automobiles sector) |  | 
Green financing (Financials sector)|  | 

- Raw data have to be normalized to facilitate the comparison! 
"""

# ╔═╡ 44cfca3d-5dd7-491a-b1a0-4b72d64c445f
md"""
### Sovereign Issuers Example

Let's take the Sovereign ESG Data Framework from the World Bank as an example of public data source. 

The graph below shows the CO2 emissions normalized as a ratio per capita.
"""

# ╔═╡ 6988ff32-8695-4215-bfc4-14c312eb1e69
function data_world_bank(path::String, name_variable::String)
	data = CSV.read(joinpath("data","esg_scoring",path, string(name_variable,".csv")), DataFrame)
	data = data[1:end-3, 3:end]
	dropmissing!(data, "Country Name")
	data = stack(data, Not(["Country Name", "Country Code"]))
	rename!(data, :variable => :Year)
	rename!(data, "value" => name_variable)
	data = filter(name_variable => !=(".."), data)
	data[!,name_variable] = convert.(String, data[:,name_variable])
	data[!,name_variable] = parse.(Float64, data[:,name_variable])
	return data
end

# ╔═╡ f96fdbbf-c04f-44b9-a357-d0699576c298
begin
	co2_emissions_per_capita = data_world_bank("environmental","CO2_emissions_per_capita")
	list_countries = unique(co2_emissions_per_capita[:,"Country Name"])
	nothing
end

# ╔═╡ 9b1aede8-655d-4544-9aac-8407d7a19127
@bind country Select(list_countries)

# ╔═╡ 03c9ee13-e9ac-4daf-97e4-11080a271eea
begin
	co2_for_plot = filter("Country Name" => ==(country), co2_emissions_per_capita)
	label_years = split.(co2_for_plot[:,:Year])
	label_years = [label_years[i][1] for i in eachindex(label_years)]
	plot(label_years, co2_for_plot[:,:CO2_emissions_per_capita], seriestype = :line,
	title = country,
	xlabel = "Year",
	ylabel = "CO2 emissions per capita",
	label = nothing)
end

# ╔═╡ 773ff61f-d350-4f50-8707-487b3a67819d
md"""
### Corporate Issuers Example

The Dodd-Frank Act requitres that publicly traded companies disclose:
- The median total annual compensation of all employees other than the CEO;
- The ratio of the CEO's annuial total compensation to that median employee;
- The wage ratio of the CEO to the median employee.

These data are examples or raw data normalized (median or ratio) in order to be comparable.
"""

# ╔═╡ 7981f6c6-d7f1-498b-b1ca-1c315053b3d2
begin
	companys = ["Abercrombie & Fitch Co.",
				"McDonald’s Corporation",
				"The Coca-Cola Company",
	"The Gap, Inc.",
	"Alphabet Inc.",
	"Walmart Inc.",
	"The Estee Lauder Companies, Inc.",
	"Ralph Lauren Corporation",
	"NIKE, Inc.",
	"Citigroup Inc.",
	"PepsiCo, Inc.",
	"Microsoft Corporation",
	"Apple Inc."]

	median_workers = [
		1954,
		 9291,
		11285,
		6177,
	258708,
	 22484,
	 30733,
	 21358,
	 25386,
	 52988,
	 45896,
	172512,
	 57596
	]

	ceo_pay_ratio = [
		 4293,
		1939,
		1657,
		 1558,
		 1085,
		983,
		697,
		570,
		550,
		482,
		368,
		249,
		201
	]
	ceo_df = DataFrame("Company Name" => companys, "Median Worker Pay (in USD)" => median_workers, "CEO Pay Ratio" => ceo_pay_ratio)
	nothing
end

# ╔═╡ fdd7a244-765b-4d7b-91b8-6ccb7cd4b369
@bind variable_corporate_pay Select(names(ceo_df)[2:end])

# ╔═╡ f1b886e2-3d88-4744-9ad4-4577b5ed8164
begin
	ceo_indic_plot = ceo_df[:,["Company Name", variable_corporate_pay]]
	sort!(ceo_indic_plot, variable_corporate_pay, rev = true)
	plot(ceo_indic_plot[:,"Company Name"], ceo_indic_plot[:,variable_corporate_pay], seriestype = :bar,
	title = variable_corporate_pay,
	xlabel = "Company",
	label = nothing,
	xrotation = 90)
end

# ╔═╡ c6c95635-bc11-4600-ad66-e76dc2ae5385
md"""
## Scoring System

- Most of ESG scoring systems are based on scoring trees. 
- Raw data are normalised in order to obtain features $X_1,...,X_m$
- Features $X_1,...,X_m$ are aggregated to obtain sub-scores $s_1,...,s_n$:
$s_i = \sum_{j=1}^m \omega_{i,j}^{(1)}X_j$
- Sub-scores $s_1,...,s_n$ are aggregated to obtain the final score $s$:
$s_i = \sum_{i=1}^n \omega_i^{(2)}s_i$
This two-level structure can be extended to multi-level tree structures.
"""

# ╔═╡ 641c7448-a08d-4744-904f-efd9da02b228
md"""
### Scoring Trees
Let's illustrate this with a two-level tree structure.
Let's assume that at level 2:

$\omega_1^{(2)} = \omega_2^{(2)} = \omega_3^{(2)} = 33.33\%$

The rest of the weighting scheme is depicted in the tree graph below.
"""

# ╔═╡ bd7ed811-9d4b-4e69-97cd-8f155628263b
begin
	children = [[2,3,4], [5,6,7], [8,9], [10]]
	text = ["s", "s_1 \n 33.33%", "s_2  \n 33.33%", "s_3  \n 33.33%",
			"X_1 \n 50%", "X_2 \n 25%", "X_3 \n 25%", "X_4 \n 50%", "X_5 \n 50%","X_6 \n 100%"]
	link_style = ["","stroke:green","stroke:red", "stroke:blue"]
	t = D3Tree(children,
				text = text,
				link_style = link_style,
				init_expand = 10,
	title = "A two-level tree structure")
end

# ╔═╡ a72f0724-bf7b-4eed-b1ff-7ef9c5dcc9c4
md"""
### Normalizing Scores

Scores have to be normalized to facilitate the aggregation process.

Several normalization approches:

- q-score normalization:
  - 0-1 normalization: $q_i \in [0,1]$
  - 0-10 normalization: $q_i \in [0,10]$
  - 0-100 normalization: $q_i \in [0,100]$
$q_i = \hat F(x_i)$
Where $\hat F$ is the empirical probability distribution.
- z-score normalization:

$z_i = \frac{x_i - \hat\mu(X)}{\hat\sigma(X)}$
"""

# ╔═╡ 6010df7b-366e-423d-b60c-85a233e92857
md"""
Let's illustrate this by building a synthetic score for sovereign issuers, based on three data from the World Bank Sovereign Issuers Framework:
- CO2 emissions per capita ($X_1$)
- Natural resources depletion (in % of GNI) ($X_2$)
- Renewable energy consumption (in % of total energy consumption) ($X_3$)

Let's take a look at the 15-worst sovereign issuers per variable below:
"""

# ╔═╡ 8afeeacf-1cd5-478a-9600-c677e6474751
begin
	natural_resources_depletion = data_world_bank("environmental","natural_resources_depletion")
	renewable_energy = data_world_bank("environmental","renewable_energy")
	raw_data_for_scoring = leftjoin(co2_emissions_per_capita, natural_resources_depletion, on = ["Country Name", "Country Code", "Year"])
	raw_data_for_scoring = leftjoin(raw_data_for_scoring, renewable_energy, on = ["Country Name", "Country Code", "Year"])
	raw_data_for_scoring = combine(groupby(raw_data_for_scoring, ["Country Name"]), last)
	dropmissing!(raw_data_for_scoring)
	raw_data_for_scoring = raw_data_for_scoring[:,["Country Name","CO2_emissions_per_capita","natural_resources_depletion","renewable_energy"]]	
	nothing
end

# ╔═╡ 4e73a774-cb4d-40a9-949a-98b8c6aa1640
@bind variable_raw_data_for_scoring Select(names(raw_data_for_scoring)[2:end])

# ╔═╡ a82a497f-a000-4cfc-85a5-db8504985c82
begin
		raw_data_scoring_plot = raw_data_for_scoring[:,["Country Name", variable_raw_data_for_scoring]]
	if variable_raw_data_for_scoring == "renewable_energy"
			sort!(raw_data_scoring_plot, variable_raw_data_for_scoring)
	else
		sort!(raw_data_scoring_plot, variable_raw_data_for_scoring, rev = true)
	end
	raw_data_scoring_plot = raw_data_scoring_plot[1:15,:]
	plot(raw_data_scoring_plot[:,"Country Name"], raw_data_scoring_plot[:,variable_raw_data_for_scoring], seriestype = :bar,
	title = variable_raw_data_for_scoring,
	xlabel = "Country",
	label = nothing,
	xrotation = 90)
end

# ╔═╡ 13d93335-cb71-4dec-a33d-5d3f248f174e
md"""
Let's take the weights defined in the previous part.
How to create a synthetic score with $50\% X_1 + 25\% X_2 + 25\% X_3$ ?
"""

# ╔═╡ 456f88f6-c7ce-4aa9-8b88-d0b00108a302
md"""
We can first try to transform the initial raw data using q-score normalization, where the empirical probability distribution for the variable selected previously gives us the potential scoring function for each value of $x_i$. We can also simply apply a z-score normalization. Let's choose one of the approach below and observes the resulting function in the graph:
"""

# ╔═╡ ad2c47e1-b0d2-4eb9-a453-a3240f30f167
@bind type_scoring Select(["q-score", "z-score"])

# ╔═╡ fae09e9d-b1c7-446c-a035-6ea7fd386515
begin
	function q_score_normalization_plot(variable_raw_data_for_scoring::String)
		if variable_raw_data_for_scoring == "renewable_energy"
			empirical_plot = sort(raw_data_for_scoring[:,variable_raw_data_for_scoring])
		else
			empirical_plot = sort(raw_data_for_scoring[:,variable_raw_data_for_scoring], rev = true)
		end
		n = length(raw_data_for_scoring[:,variable_raw_data_for_scoring])
	p = plot(empirical_plot, (1:n)./n .* 100, 
	    xlabel = variable_raw_data_for_scoring, ylabel = "Score (q-score normalisation 0 -100)", 
	    title = "q-score normalization", label = "")
	end

	function z_score_normalization_plot(variable_raw_data_for_scoring::String)
		μ = mean(raw_data_for_scoring[:,variable_raw_data_for_scoring])
		σ = std(raw_data_for_scoring[:,variable_raw_data_for_scoring])
		zscores = [(i - μ)/σ for i in minimum(raw_data_for_scoring[:,variable_raw_data_for_scoring]):maximum(raw_data_for_scoring[:,variable_raw_data_for_scoring])]
		if variable_raw_data_for_scoring == "renewable_energy"
			zscores = zscores 
		else
			zscores = zscores .* -1
		end
		plot([i for i in minimum(raw_data_for_scoring[:,variable_raw_data_for_scoring]):maximum(raw_data_for_scoring[:,variable_raw_data_for_scoring])], zscores,
	    xlabel = variable_raw_data_for_scoring, ylabel = "Score (z-score normalisation)", 
	    title = "z-score normalization", label = "")
	end
	nothing
end

# ╔═╡ 55ff9a90-0061-4b9a-a759-bb41ff492d41
begin
	if type_scoring == "q-score"
		q_score_normalization_plot(variable_raw_data_for_scoring)
	elseif type_scoring == "z-score"
		z_score_normalization_plot(variable_raw_data_for_scoring)
	end
end

# ╔═╡ 409625e2-8a43-4ab6-901e-17cb284afe86
md"""
Let $x_1, .., x_n$ be the sample. We have:

$q_i = \hat{F}(x_i) = Pr(X \leq x_i) = \frac{\#(x_j \leq x_i)}{n_q}$

We can use two normalization factors:

- $n_q = n$
- $n_q = n + 1$
"""

# ╔═╡ 16705f37-c426-4356-9d99-8c554020974c
md"""
Of course, one can transform the z-score into q-score using the Normal distribution for example, or transform the q-score to a z-score.

Once normalized, scores can be aggregated as a simple weighted sum, using the scoring tree.
"""

# ╔═╡ ee0db9e1-529f-4f31-ba5a-3aebffda732f
md"""
## ESG Score and Portfolio

### Issuers and Portfolio Score Computation

We consider an investment universe of 8 issuers with the following ESG scores:
"""

# ╔═╡ 18a1e02b-2d45-4ad2-929f-f43d74a955c5
issuers_scores = DataFrame(:ESG_pillar => ["E","S","G"], 
							:A => [-2.80, -1.70, 0.30],
							:B => [-1.80, -1.90, -0.70],
							:C => [-1.75, 0.75, -2.75],
							:D => [0.60, -1.60, 2.60],
							:E => [0.75, 1.85, 0.45],
							:F => [1.30, 1.05, 2.35],
							:G => [1.90, 0.90, 2.20],
							:H => [2.70, 0.70, 1.70])

# ╔═╡ 3bc75374-b625-4fb4-a23e-cac6720cb911
md"""
Suppose we have the following simple scoring tree:
"""

# ╔═╡ e2a9255f-0d41-4341-88b2-bfdcf50daebc
begin
	children_two = [[2,3,4]]
	text_two = ["s", "E \n 40%", "S  \n 40%", "G  \n 20%"]
	link_style_two = ["","stroke:green","stroke:red", "stroke:blue"]
	t_two = D3Tree(children_two,
				text = text_two,
				link_style = link_style_two,
				init_expand = 10)
end

# ╔═╡ a9d4ff67-a00c-49e1-b16d-3a98389d031e
md"""
Then we would simply have:

$s_i^{(ESG)} = 0.4 s_i^{(E)} + 0.4 s_i^{(S)} + 0.2 s_i^{(G)}$
"""

# ╔═╡ 704831fa-c82c-4f96-99d2-6d7163c2e4cc
begin
	issuers = names(issuers_scores)[2:end]
	scores = [0.4 * issuers_scores[1,i] + 0.4*issuers_scores[2,i] + 0.2 * issuers_scores[3,i] for i in issuers]
	results_issuers_scores = DataFrame(:issuer => issuers, :ESG_score => scores)
end

# ╔═╡ 899cf609-7fe6-430d-8558-3e4a83e0fc01
equally_weighted_portfolio_score = mean(results_issuers_scores[:,:ESG_score]);

# ╔═╡ 142c5ab1-464b-4582-a01b-9277f264badb
md"""
Now let's calculate the ESG score of the equally-weighted portfolio $x_{ew}$:

$s^{(ESG)}(x_{ew}) = \sum^8_{i=1}x_{ew,i}s_i^{(ESG)}$

Then $s^{(ESG)}(x_{ew})$
= $equally_weighted_portfolio_score
"""

# ╔═╡ e1159637-b3bc-438d-8a22-538c5334947a
md"""
### ESG Score Distribution and Portfolio Concentration

Now let's take a look at some relationship between ESG score distribution and / or Portfolio concentration.
First, let's implement a simple algorithm to simulate portfolio $x$ distribution:

- simulate $n$ independent uniform random numbers $(u_1,...,u_n)$
- compute the random variates $(t_1,...,t_n)$ where:

$t_i = u_i^{1/\alpha}$
Where $\alpha$ is the parameter governing the concentration.
- calculate the normalization constant:

$c = (\sum^n_{i=1}t_i)^{-1}$
- and deduce the portfolio weights $x=(x_1,...,x_n)$

$x_i = ct_i$
"""

# ╔═╡ 88e81cef-a3ed-4eb3-b532-42334012248a
function simulating_portfolio(α::Float64,n::Int)
	# we simulate n independent uniform random numbers
	uniform_u = rand(n)
	# we compute the random variates
	t_vector = uniform_u .^(1/α)
	# we calculate the normalization constant
	c = sum(t_vector)^(-1)
	# we deduce the portfolio weights 
	x = c .* t_vector
end


# ╔═╡ 30db975f-d595-4811-beed-8c7c28c82803
@bind α Slider(0.5:0.5:70, default = 0.5, show_value = true)

# ╔═╡ 88d8dad1-01e5-49e7-bb62-67358a10b44f
begin
	simulated_weights = simulating_portfolio(α, 50)
	n = length(simulated_weights)
	sort!(simulated_weights, rev = true)
	plot((1:n)./n .* 100, simulated_weights .*100, seriestype = :bar, xlabel = "percentage of issuers", ylabel = "portfolio weights (in %)", label = "", ylims = (0,7))
end

# ╔═╡ 57c33025-2a90-463f-89b7-91f4b6929b6f
md"""
- We assume that the weight $x_i$ and the ESG score $s_i$ of the issuer $i$ are independent. 
- We can generate the vector of ESG scores $s = (s_1, ..., s_n)$ with normally-distributed random variables.
- We deduce that the simulated value of the portfolio ESG score $s(x)$ is equal to:

$s(x) = \sum^n_{i=1}x_is_i$

- We replicate the simulation of $s(x)$ 50 000 times and draw the corresponding diagram.
"""

# ╔═╡ 74f40223-5f64-41ef-868c-369227f0c54d
function simulating_portfolio_esg_score_indep(α::Float64, n::Int)
	vector_results = zeros(n)
	for i in 1:n
		x = simulating_portfolio(α, 50)
		s = rand(Normal(0.0,1.0), 50)
		s_x = sum(x .* s)
		vector_results[i] = s_x
	end
	return vector_results
end

# ╔═╡ 5544adf7-98f7-4216-855a-c3b6ed36d541
@bind α_2 Slider(0.5:0.5:70, default = 0.5, show_value = true)

# ╔═╡ 017ba49c-ff42-4317-b219-332e239f4d6e
histogram( simulating_portfolio_esg_score_indep(α_2, 50000), bins = 100, label = "", ylims = (0.0,3000), xlims = (-0.5,0.5))

# ╔═╡ 316d1744-e5d7-4117-8646-a8f6a2914f6b
md"""
We observe that the portfolio ESG score $s(x)$ is equal to zero on average, and its variance is an increasing function of the portfolio concentration.
"""

# ╔═╡ 5de86ff6-440a-4db2-91cb-872bd4ea6ef0
md"""
We now assume that the weight $x_i$ and the ESG score $s_i$ of the issuer $i$ are positively correlated. 

Here is the algorithm to simulate the ESG portfolio score $s(x)$ assuming positive correlation between $x_i$ and $s_i$, with a correlation parameter $\rho$:
- simulate $n$ independent normally-distributed random numbers $g'_i$ and $g_i^{''}$ and compute the copula $(u_i, v_i)$:

$u_i = \phi(g'_i)$
$v_i = \phi(\rho g'_i + \sqrt{1-\rho^2g^{''}_i})$
- compute the random variates $(t_1, ..., t_n)$ where $t_i = u^{1/\alpha}$
- deduce the vector of weights $x = (x_1,...,x_n)$:

$x_i = t_i/\sum^n_{j=1}t_j$
- simulate the vector of scores $s=(s_1,...,s_n)$
- calculate the portfolio score:
$s(x) = \sum^n_{i=1}x_is_i$
"""

# ╔═╡ c9353c5d-5032-4220-a257-ed900f9323ff
function simulating_portfolio_score_copula(n::Int, ρ::Float64, α::Float64)
	vector_results = zeros(n)
	for i in 1:n
		# simulate n indep normally-distributed random numbers
		g_i = rand(Normal(0.0,1.0), 50)	
		g_i_2 = rand(Normal(0.0,1.0), 50)
		# compute u and v
		u_i = cdf.(Normal(0.0,1.0),g_i)
		v_i = cdf.(Normal(0.0,1.0), ρ * g_i_2 .+ sqrt(1 - ρ^2) * g_i_2)
		# we compute the random variate t 
		t_i = u_i.^(1/α)
		# we deduce the vector of weights
		x_i = t_i / sum(t_i)
		# we simulate the vector of scores s
		s_i = ρ * g_i .+ sqrt(1 - ρ^2) * g_i_2
		#s_i = quantile.(Normal(0.0, 1.0), v_i)
		# we calculate the portfolio score
		s = sum(x_i .* s_i)

		vector_results[i] = s
	end
	return vector_results
end

# ╔═╡ 2c7993cc-196d-4320-a3c1-0e87ab5b8873
@bind α_3 Slider(0.5:0.5:70, default = 0.5, show_value = true)

# ╔═╡ 9e1a258c-e595-4eba-bf2a-44c62f3db909

histogram(simulating_portfolio_score_copula(50000,0.5,α_3), bins = 100, label = "", ylims = (0.0,3000), xlims = (-0.5,1))

# ╔═╡ 67099b48-39af-41d2-bbd3-96a87936a676
md"""
In the independent case, we found that $E[s(x)]=0$, while we notice that $E[s(x)]\neq 0$ when $\rho = 50\%$. We can graph the relationship between the correlation parameter $\rho$ and the expected ESG score $E[s(x)]$ of the portfolio $x$:
"""

# ╔═╡ b3aefed4-195e-4a52-bf82-5097a82ce816
begin
	data_alpha_05 = [mean(simulating_portfolio_score_copula(5000,i,0.5)) for i in 0:0.1:1]
	data_alpha_15 = [mean(simulating_portfolio_score_copula(5000,i,1.5)) for i in 0:0.1:1]
	data_alpha_25 = [mean(simulating_portfolio_score_copula(5000,i,2.5)) for i in 0:0.1:1]
	data_alpha_70 = [mean(simulating_portfolio_score_copula(5000,i,70.0)) for i in 0:0.1:1]
	plot([i for i in 0:0.1:1], data_alpha_05, xlabel = "correlation parameter", ylabel = "Expected ESG score of the portfolio", label = 0.5)
	plot!([i for i in 0:0.1:1], data_alpha_15, xlabel = "correlation parameter",  label = 1.5)
	plot!([i for i in 0:0.1:1], data_alpha_25, xlabel = "correlation parameter",  label = 2.5)
	plot!([i for i in 0:0.1:1], data_alpha_70, xlabel = "correlation parameter",  label = 70)
end

# ╔═╡ 0264fe0a-eefa-4739-86a5-4a25c9c104c8
md"""
- Big cap companies have more resources to develop an ESG policy than small cap companies.
- Therefore, we observe a positive correlation between the market capitalization and the ESG score of an issuer.
- If follows that ESG portfolios have generally a size bias. For instance, we generally observe that cap-weighted indexes have an ESG score which is greater than the average of ESG socres.
"""

# ╔═╡ bcd04c15-49dc-469f-890c-18169a6d9827
TableOfContents(title="ESG Scoring", depth=4)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
D3Trees = "e3df1716-f71e-5df9-9e2d-98e193103c45"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CSV = "~0.10.2"
D3Trees = "~0.3.1"
DataFrames = "~1.3.2"
Distributions = "~0.25.45"
Plots = "~1.25.7"
PlutoUI = "~0.7.32"
StatsBase = "~0.33.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "9519274b50500b8029973d241d32cfbf0b127d97"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.2"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

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

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

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

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "24d26ca2197c158304ab2329af074fbe14c988e4"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.45"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

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

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

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

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

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

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

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

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

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

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

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

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7e4920a7d4323b8ffc3db184580598450bde8a8e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.7"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

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

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

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

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

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

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

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

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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
git-tree-sha1 = "2884859916598f974858ff01df7dfc6c708dd895"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.3"

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

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

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

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═0588e72e-83ef-11ec-106a-517c7ec687cc
# ╠═882ebf57-19b6-475b-aa19-e9b2e168acbf
# ╟─b83f41ea-665d-474f-a32f-0f93ff6af1f5
# ╟─61e63742-fd93-4825-bd77-184e66b9fe27
# ╟─042774fe-33cc-4162-b50f-aaba28a13e53
# ╟─44cfca3d-5dd7-491a-b1a0-4b72d64c445f
# ╠═9b1aede8-655d-4544-9aac-8407d7a19127
# ╟─6988ff32-8695-4215-bfc4-14c312eb1e69
# ╟─f96fdbbf-c04f-44b9-a357-d0699576c298
# ╠═03c9ee13-e9ac-4daf-97e4-11080a271eea
# ╟─773ff61f-d350-4f50-8707-487b3a67819d
# ╟─fdd7a244-765b-4d7b-91b8-6ccb7cd4b369
# ╟─7981f6c6-d7f1-498b-b1ca-1c315053b3d2
# ╠═f1b886e2-3d88-4744-9ad4-4577b5ed8164
# ╠═c6c95635-bc11-4600-ad66-e76dc2ae5385
# ╠═641c7448-a08d-4744-904f-efd9da02b228
# ╠═bd7ed811-9d4b-4e69-97cd-8f155628263b
# ╠═a72f0724-bf7b-4eed-b1ff-7ef9c5dcc9c4
# ╠═6010df7b-366e-423d-b60c-85a233e92857
# ╟─4e73a774-cb4d-40a9-949a-98b8c6aa1640
# ╟─8afeeacf-1cd5-478a-9600-c677e6474751
# ╠═a82a497f-a000-4cfc-85a5-db8504985c82
# ╟─13d93335-cb71-4dec-a33d-5d3f248f174e
# ╠═456f88f6-c7ce-4aa9-8b88-d0b00108a302
# ╠═ad2c47e1-b0d2-4eb9-a453-a3240f30f167
# ╠═55ff9a90-0061-4b9a-a759-bb41ff492d41
# ╠═fae09e9d-b1c7-446c-a035-6ea7fd386515
# ╠═409625e2-8a43-4ab6-901e-17cb284afe86
# ╟─16705f37-c426-4356-9d99-8c554020974c
# ╟─ee0db9e1-529f-4f31-ba5a-3aebffda732f
# ╟─18a1e02b-2d45-4ad2-929f-f43d74a955c5
# ╟─3bc75374-b625-4fb4-a23e-cac6720cb911
# ╟─e2a9255f-0d41-4341-88b2-bfdcf50daebc
# ╟─a9d4ff67-a00c-49e1-b16d-3a98389d031e
# ╟─704831fa-c82c-4f96-99d2-6d7163c2e4cc
# ╟─142c5ab1-464b-4582-a01b-9277f264badb
# ╟─899cf609-7fe6-430d-8558-3e4a83e0fc01
# ╟─e1159637-b3bc-438d-8a22-538c5334947a
# ╠═88e81cef-a3ed-4eb3-b532-42334012248a
# ╠═30db975f-d595-4811-beed-8c7c28c82803
# ╠═88d8dad1-01e5-49e7-bb62-67358a10b44f
# ╠═57c33025-2a90-463f-89b7-91f4b6929b6f
# ╟─74f40223-5f64-41ef-868c-369227f0c54d
# ╟─5544adf7-98f7-4216-855a-c3b6ed36d541
# ╟─017ba49c-ff42-4317-b219-332e239f4d6e
# ╟─316d1744-e5d7-4117-8646-a8f6a2914f6b
# ╟─5de86ff6-440a-4db2-91cb-872bd4ea6ef0
# ╟─c9353c5d-5032-4220-a257-ed900f9323ff
# ╟─2c7993cc-196d-4320-a3c1-0e87ab5b8873
# ╟─9e1a258c-e595-4eba-bf2a-44c62f3db909
# ╟─67099b48-39af-41d2-bbd3-96a87936a676
# ╟─b3aefed4-195e-4a52-bf82-5097a82ce816
# ╟─0264fe0a-eefa-4739-86a5-4a25c9c104c8
# ╟─bcd04c15-49dc-469f-890c-18169a6d9827
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002