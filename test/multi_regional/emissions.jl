using Mimi 

@defcomp emissions begin 
    regions = Index() # regions index must be specified 

    E = Variable(index = [time, regions]) # Total greenhouse gas emissions
    E_Global = Variable(index = [time]) # Global emissions (sum of regional emissions)
    sigma = Parameter(index = [time, regions]) # Emissions output ratio
    YGROSS = Parameter(index = [time, regions]) # Gross output 

    function run_timestep(p,v,d,t)
        # Define an equation for E 
        for r in d.regions 
            v.E[t,r] = p.YGROSS[t,r] * p.sigma[t,r]
        end

        # Define an equation for E_Global
        for r in d.regions 
            v.E_Global[t] = sum(v.E[t,:])
        end
    end
end