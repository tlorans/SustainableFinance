# Social Cost

We define the social cost of a greenhouse gas as the net present value of the change in future damages from a marginal (1 tonne)
change in emissions of that gas today. 

In order to estimate the social cost of a greenhouse gas, the model need to first compute the difference between total monetised climate change impacts of business as usual emissions and a path with slightly higher emissions.

Then, the differences in monetized climate change impacts are discounted back to the chosen year (2020 here) and normalised by the difference in emission (namely, 1 tonne)

## Marginal Model 

It is simply done in Julia:
```julia
scc_year = 2020

update_param!(m, :climatedynamics, :climatesensitivity, 4.5)

mm = MimiFUND.get_marginal_model(m, year = scc_year)   # The additional emissions pulse will be added in the specified year
```

## Social Cost of Carbon

```julia
MimiFUND.compute_scc(m, year = scc_year, eta = 1., prtp = 0.) * 1.68 # +68% inflation between 1995 and 2020
``` 
Which gives:
```
51.32718736191957
```