

## Computing Present-Day Values of Damages

So, now that we have our estimated model, we need to convert future damages into their present-day values and sum to determine total damages:
```julia
# STEP 5 PRESENT VALUE OF DAMAGES IN BASELINE SCENARIO
discount_rate = 0.035 # value recommended by the VBA
discount_factors = [(1/(1 + discount_rate))^((t-1)) for t in 1:86] 
damages_usd = getdataframe(m, :damages, :Ω)
present_value_damages = sum(discount_factors .* damages_usd[:,:Ω])
```
Which outputs:
```
35.86557996740484
```
That means a 35.8 trillion USD present-value of expected damages in our baseline scenario!

## Marginal Model and SCC

Now, we just need to repeat the process by including an increase of 1 ton of $CO_2$ emitted (what we call the marginal model), compute the present-value of damages and the differential with the baseline model. This differential is the SCC!

```julia 
# STEP 6 RUN THE MARGINAL MODEL AND COMPUTE THE SCC

m2 = construct_model(marginal = true) # now we see the use of the marginal keyword!
run(m2)

damages_usd_m2 = getdataframe(m2, :damages, :Ω)
present_value_damages_m2 = sum(discount_factors .* damages_usd_m2[:,:Ω])

scc = (present_value_damages_m2 - present_value_damages) * 10^12 # to express in USD per ton rather than trillion USD
``` 
Which gives the following SCC:
```
445.346870492358
```