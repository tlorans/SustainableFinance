using LinearAlgebra

function Jacobian(func, x₀, h = 0.001)
    # Numerical Jacobian of f:R^m -> R^n 
    m = length(x₀); # Domain dimension 
    f₀ = func(x₀);
    n = length(f₀); # Range dimension

    if m == 1 # f:R -> R^n 
        return (func(x₀ .+ h) .- func(x₀ .- h)) ./ (2 * h)
    else
        Im = Matrix(1.0I, m, m); # Create standard basis for I_m 
        A = zeros(n, m); # Create Jacobian matrix 
        # Compute and fill in the columns of the Jacobian using central difference 

        for i  = 1:m 
            ei = Im[:, i:i]
            A[:,i] = (func(x₀ + h * ei) - func(x₀ - h * ei)) / (2*h);
        end
        return A
    end
end

# example 

function f3(x)
    return [x[1]*x[2]*x[3]; log(2+cos(x[1])) + x[2]^x[1]; (x[1]*x[3] / (1+x[2]^2))]
end

x₀ = [π; 1.0; 2.0] # initial guess 
A = Jacobian(f3, x₀)
