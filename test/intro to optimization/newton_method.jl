function f(x)
    return (x-1)^2 - 4
end

x₀ = 2; h = 0.01/2; # initial guess x₀ and step size h 
delta = 1e-9; # set a convergence threshold

# set a max iteration so we don't get stuck in the loop 
MAX_ITER = 100;
N = 1; # counter for iteration 
while N < MAX_ITER
    # evaluate f at current guess 
    f₀ = f(x₀ - h); # f(xₙ - h)
    f₁ = f(x₀); # f(xₙ)
    f₂ = f(x₀ + h); # f(xₙ + h)
    df = f₂ - f₀ # approximate the derivative with finite difference
    if abs(df) < delta 
        println("Newton's method did not converge; derivative is near zero.")
        break 
    else
        dx = -2*h * (f₁ / (f₂ - f₀)); # finite difference approximation
    end
    if abs(dx) < delta
        println("Converged at iteration: N = ", N)
        break 
    else
        x₀ = x₀ + dx; # find next xₙ
    end
    N += 1;
end

print("root: ", x₀, "\n")
print("f(root): ", f(x₀), "\n")

