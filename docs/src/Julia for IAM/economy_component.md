
## The Economy Component

We describe here a really simple toy world economy, with gross output and capital evolving according to fixed parameters and exogeneous variables.

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $Y_t$  |  Gross output   | $Y_t = TFP_t * K_t^\beta * L_t^{(1-\beta)}$    |
| $K_t$   | Capital        |  $K_t = (1 - \delta) * K_{t-1} + Y_{t-1} * s_{t-1}$|

### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $\delta$  |  Depreciation rate on capital  | 
| $\beta$   | Capital share |

### Exogeneous Variables
| Notation      | Description |  
| ----------- | ----------- |
| $L_t$  |  Labor  | 
| $TFP_t$   | Total factor productivity |
| $s_t$   | Savings rate |

### Julia Implementation

Let's first implement the economy component:
```julia 
# gross economy component
@defcomp grosseconomy begin 
    Y = Variable(index = [time]) # Gross output 
    K = Variable(index = [time]) # Capital 
    L = Parameter(index = [time]) # Labor
    TFP = Parameter(index = [time]) # Total factor productivity 
    s = Parameter(index = [time]) # Savings rate
    δ = Parameter() # Depreciation rate on capital 
    k0 = Parameter() # Initial level of capital 
    β = Parameter() # Capital share

    function run_timestep(p, v, d, t)
        # Define an equation for K 
        if is_first(t)
            # Note the use of v. and p. to distinguish between variables 
            # and parameters 
            v.K[t] = p.k0 
        else
            v.K[t] = (1 - p.δ) * v.K[t-1] + v.Y[t-1] * p.s[t-1]
        end

        # Define an equation for YGROSS 
        v.Y[t] = p.TFP[t] * v.K[t]^p.β * p.L[t]^(1-p.β)
    end
end
```

