module RoadValue
#After you push “Foo.jl” to github, others can install your package with
#sh> julia -e 'using Pkg; Pkg.add("https://github.com/your/Foo.jl")'
using DataFrames, Query
using CSV
using LightGraphs
using PyCall

function greet()
    println("------")
    println("Hello this is the RoadValue package!")
    println("before running install geopandas and shapely using conda...")
    println("using PyCall")
    println("pyimport_conda(\"geopandas\", \"geopandas\")")
    println("pyimport_conda(\"shapely\", \"shapely\")")
    println("------")
end

include("utils.jl")
include("reduced_network.jl")
include("value_assignment.jl")
include("full_to_gpkg.jl")
include("reduced_to_gpkg.jl")
include("odm_to_gpkg.jl")
include("writeGML.jl")

export reduced_network, value_assignment, full_to_gpkg, reduced_to_gpkg, odm_to_gpkg

end # module
