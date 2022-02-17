using Plots


f(x) = 0.2*x^5+x^3+3*x+1 # our function 
f_2(x) = 0 # utility function to plot the zero line
plot(f, label = "")
plot!(f_2, label = "")