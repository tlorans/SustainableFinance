# Derivatives & Jacobian 

- The input is a vector such as $x \in \mathbb{R}^m$. If we use the standard basis of $\mathbb{R}^m$, we have:

$x = x_1 e_1 + x_2 e_2 + \cdots + x_n e_m = \sum^m_{i=1}x_ie_i$

- Then we can use a finite difference approximation to compute each column of $A = [a^{col}_1 \cdots a^{col}_m]$ as 

$a^{col}_i = \frac{\partial f(x_0)}{ \partial x_i} = \frac{f(x_0 + he_i) - f(x_0 - he_i)}{2h}$

- For the general case of $f : \mathbb{R}^m \rightarrow \mathbb{R}^n$, $A$ is an $n*m$ matrix and called the Jacobian of $f$, i.e.,

$A_{n*m} = [a^{col}_1 \cdots  a^{col}_m] = \frac{\partial f(x)}{\partial x}$

- Each column of the Jacobian $a^{col}_i = \frac{\partial f(x)}{ \partial x_i} \in \mathbb{R}^n$ shows the rate of change of $f$ along $e_i$.

Let's implement the function in Julia:
```julia
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
```

# Example 

For the function

$$f(x_1, x_2, x_3) := \left[
\begin{array}{c}
x_1 x_2 x_3 \\
\log(2+\cos(x_1)) + x_2^{x_1}  \\
 \frac{x_1 x_3}{1+ x_2^2}
\end{array}
\right]$$

we want to compute its Jacobian at the point:

$$x_0 = \left[
\begin{array}{c}
\pi \\
1.0  \\
2.0
\end{array}
\right]$$

Let's test our function with Julia:
```julia

function f3(x)
    return [x[1]*x[2]*x[3]; log(2+cos(x[1])) + x[2]^x[1]; (x[1]*x[3] / (1+x[2]^2))]
end

x₀ = [π; 1.0; 2.0] # initial guess 
A = Jacobian(f3, x₀)
```

Which gives us the Jacobian:
```
3×3 Matrix{Float64}:
 2.0   6.28319  3.14159
 0.0   3.14159  0.0
 1.0  -3.14159  1.5708
```