using MimiFUND

# Run FUND
m = MimiFUND.get_model()

run(m)

using Mimi

# Step 3 Access Results: Values
m[:socioeconomic, :income]
m[:socioeconomic, :income][100]

getdataframe(m, :socioeconomic => :income) # request one variable from one component
getdataframe(m, :socioeconomic => :income)[1:16,:] # results for all regions in first year


# Step 4: Access Results: PLots and Graphs 
explore(m)
p = Mimi.plot(m, :socioeconomic, :income)
save("test.svg", p)