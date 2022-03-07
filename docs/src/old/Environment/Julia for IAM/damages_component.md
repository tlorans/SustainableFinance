
## The Damages Component

The Damages Component use the Damage function formulated by Weitzman (2012), with a calibration such as the damages in percentage of gross output is equal to 50% when the increase in atmospheric temperature is at 6°C.

### Endogeneous Variables

| Notation      | Description | Equation | 
| ----------- | ----------- |----------- |
| $D_t$  | Damages (in % of Gross output) | $D_t = 1 - \frac{1}{1 + \eta_1 T_{AT_t} + \eta_2 * T_{AT_t}^2 + \eta_3 * T_{AT_t}^{6.754}}$ |
| $\Omega_t$  | Damages in USD | $\Omega_t = D_tY_t$ |


### Parameters
| Notation      | Description |  
| ----------- | ----------- |
| $\eta_1$  | Parameter of damage function | 
| $\eta_2$  | Parameter of damage function | 
| $\eta_3$  | Parameter of damage function | 


### Exogeneous Variables
| Notation      | Description |  
| ----------- | ----------- |
|  $T_{AT_t}$  |  Atmospheric temperature over pre-industrial levels (°C)|
|  $Y_t$  |  Gross output |

#### Julia Implementation 

Let's implement it in Julia:
```julia

# component for damages 
@defcomp damages begin
    D = Variable(index = [time]) # Damages (in % of gross output)
    Ω = Variable(index  = [time]) # Damages in USD

    η₁ = Parameter() # Parameter of damage function 
    η₂ = Parameter() # Parameter of damage function 
    η₃ = Parameter() # Parameter of damage function 

    T_AT = Parameter(index = [time]) # Atmospheric temperature increase 
    Y = Parameter(index = [time]) # Gross output 

    function run_timestep(p, v, d, t)

        v.D[t] = 1 - 1 / (1 + p.η₁ * p.T_AT[t] + p.η₂ * p.T_AT[t]^2 + p.η₃ * p.T_AT[t]^6.754)
        v.Ω[t] = v.D[t] * p.Y[t]
        
    end

end
```

