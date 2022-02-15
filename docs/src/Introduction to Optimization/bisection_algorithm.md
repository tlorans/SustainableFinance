# Bisection Algorithm

Bisection method is a root-finding method that applies to any continuous functions for which one knows two values with opposite signs.

The method consists of repeatedly bisecting the interval defined by these values and then selecting the subinterval in which the function changes sign, and therefore must contain a root. 

## Iteration tasks 

The input for the method is a continuous function $f$, an interval $[a,b]$, and the function values $f(a)$ and $f(b)$.

The function values are of opposite sign (there is at least one zero crossing whitin the interval). 

Each iteration perfoms these steps:

1. Calculate $c$, the midpoint of the interval, $c = \frac{a+b}{2}$.
2. Calculate the function value at the midpoint, $f(c)$.
3. If converge is satisfactory (that is, $c-a$ is sufficiently small, or $|f(c)|$ is sufficiently small), return $c$ and stop iterating.
4. Examine the sign of $f(c)$ and replace either $(a, f(a))$ or $(b,f(b))$ with $(c, f(c))$ so that there is a zero crossing within the new interval.

## Example

Let's start with an easy problem: Consider $f(x) = (x-1)^2 - 4. 

We know $f(3) = 0$ ; hence $x = 3$ is a root of $f(x)$. 

Let's implement it in Julia:
```julia
function f(x)
    return (x-1)^2 - 4 
end


a = 0; b = 5; # The interval 
delta = 1e-9; # the convergence threshold

# Set a max iteration so we don't get stuck in the loop forever 
MAX_ITER = 100;
N = 1; # counter for iteration 

while N < MAX_ITER
    # Step 1: calculate c, the midpoint of the interval 
    c = (a + b) / 2;
    # Step 2: calculate the function value at the midpoint c
    fc = f(c);
    # Step 3: if converge is satisfactory (c-a sufficiently small or absolute function value sufficiently small), return C and stop
    if abs(c-a) < delta || abs(fc) < delta 
        println("Converged at iteration: N = ", N)
        break 
    end
    N += 1
    # Step 4: examine the sign of f(c) and replace either (a, f(a)) or (b, f(b)) with (c, f(c)) so that there is a zero crossing the new interval
    if sign(fc) == sign(f(a)) # update the search interval 
        a = c;
    else
        b = c;
    end
end

c = (a + b) / 2
print("c:", c, "\n")
print("f(c):", f(c), "\n")
```

The output will be:
```
Converged at iteration: N = 33
c:2.9999999998835847
f(c):-4.656612873077393e-10
```
