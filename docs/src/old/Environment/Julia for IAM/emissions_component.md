
## The Emissions Component 

The emissions component is also really simplistic. The energy consumption is modelled as a function of the energy to output ratio and the gross output. Then the emissions are driven by the carbon intensity of the energy mix and the energy consumption. 

Note that the gross output is treated as an exogenous variable here.

### Endogeneous Variable

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $M_t$  |  Energy necessary for the production of output | $M_t = \epsilon_t * Y_t$    |
| $E_t$  |  Total greenhouse gas emissions | $E_t = \omega_t * M_t$    |

### Exogeneous Variables
| Notation      | Description |  
| ----------- | ----------- |
| $\epsilon_t$  | Energy to output ratio (EJ/trillion USD)  |
| $\omega_t$  | $CO_2$ intensity (Gt/EJ)  | 
| $Y_t$   | Gross output |

### Julia Implementation
Let's implement it in Julia:
```julia

# component for greenhouse gas emissions 
@defcomp emissions begin 
    E = Variable(index = [time]) # Total greenhouse gas emissions 
    M = Variable(index = [time]) # Energy consumption

    ω = Parameter(index = [time]) # CO2 intensity of energy mix
    ϵ = Parameter(index = [time]) # energy intensity of output
    Y = Parameter(index = [time]) # Gross output - now a Parameter

    function run_timestep(p, v, d, t)
        # equation for M 
        v.M[t] = p.ϵ[t] * p.Y[t] # note the p. in front of gross 
        # Define an equation for E 
        v.E[t] = p.ω[t] * v.M[t]
    end
end
```