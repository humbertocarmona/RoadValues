using Test
using RoadValue
using CSV,DataFrames
using LightGraphs
# using Test
RoadValue.greet()
println(" working path = ", pwd())
##


vrfile = "../dados/vertices_reduced.csv"
erfile = "../dados/edges_reduced.csv"
vffile = "../dados/vertices_full.csv"
effile = "../dados/edges_full.csv"
odfile = "../dados/od_2019-07-26_2020-07-25.csv" #have been checked, ok

outfull = "full.gpkg"
outreduced = "reduced.gpkg"

g, distmx, jurmx, eidic, location = reduced_network(vrfile, erfile)
valuemx = RoadValue.value_assignment(g, distmx, odfile)
df = full_to_gpkg(g,vffile, effile, valuemx, jurmx, eidic, outfile=outfull)

@testset "reduced_network" begin
    println("typeof(g) = ",typeof(g))
    @test typeof(g) == SimpleGraph{Int64} 
end

@testset "value_assignment" begin
    @test size(valuemx) == size(distmx)
end

@testset "full_to_gpkg" begin
    @test size(df, 1) > 0
    @test isfile(outfull)
end

@testset "reduced_to_gpkg" begin
    @test reduced_to_gpkg(g, location, valuemx, jurmx, eidic, outfile=outreduced)
    @test isfile(outreduced)
end

@testset "odm_to_gpkg" begin
    @test odm_to_gpkg(odfile, vrfile; outfile="od.gpkg")
    @test isfile("od.gpkg")
end




#= RoadValue.odm2gpkg(odfile, vrfile; outfile="results/od.gpkg") =#
