function reduced_to_gpkg(g::SimpleGraph, locations::Vector{Tuple{Float64,Float64}},
                      distmx::Array{Float64, 2}, jurmx, eidic;
                      outfile::String = "reduced.gpkg")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")
    coords = [geom.Point(c) for c in locations]
    links = collect(edges(g))

    dist  = []
    jur = []
    geometry = []
    for e in links
        s = e.src
        d = e.dst
        push!(geometry, geom.LineString([coords[s],coords[d]]))
        push!(dist, distmx[s,d])
        push!(jur, jurmx[s,d])
    end
    data = Dict("dist" => dist, "jur"=> jur)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)
    println("saving $outfile")

    gdf.to_file(outfile, layer="reduced", driver="GPKG")

    return true
end
