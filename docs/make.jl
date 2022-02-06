using Documenter
using SustainableFinance

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Sustainable Finance",
    format = Documenter.HTML(),
    modules = [SustainableFinance];
    pages = [
        "Home" => "index.md",
        "Introduction" => Any[
            "Definition" => "Introduction/definition.md",
            "Actors of Sustainable Finance"=>"Introduction/actors.md",
            "The Market of ESG Investing"=>"Introduction/markets.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/tlorans/SustainableFinance.git"
)
