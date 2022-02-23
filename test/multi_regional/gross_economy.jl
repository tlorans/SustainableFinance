using Mimi 

@defcomp grosseconomy begin 
    regions = Index() # a regional index is defined here

    YGROSS = Variable(index = [time, regions]) # Gross output
    K = Variable(index = [time, regions]) # Capital 
    l = Parameter(index = [time, regions]) # Labor
    tfp = Parameter(index = [time, regions]) # TFP 
    s = Parameter(index = [time, regions]) # Savings rate
    depk = Parameter(index = [regions]) # Depreciation rate on capital 
    k0 = Parameter(index = [regions]) # Initial level of capital 
    share = Parameter() # Capital share 

    function run_timestep(p, v, d, t)
        # the regional dimension is defined in d and parameters and variables indexed

        # define an equation for K 
        for r in d.regions 
            if is_first(t)
                v.K[t,r] = p.k0[r]
            else
                v.K[t,r] = (1 - p.depk[r])^5 * v.K[t-1, r] + v.YGROSS[t-1, r] * p.s[t-1, r] * 5
            end
        end

        # Define an equation for YGROSS 
        for r in d.regions 
            v.YGROSS[t,r] = p.tfp[t,r] * v.K[t,r]^p.share * p.l[t,r]^(1-p.share)
        end
    end
end