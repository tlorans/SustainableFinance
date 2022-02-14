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

