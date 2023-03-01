function odm_to_gpkg(odfile::String, vfile::String; outfile::String="od.gpkg")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")

    odm = CSV.read(odfile, DataFrame)
    nod = size(odm,1)
    vs = CSV.read(vfile, DataFrame)
    println(first(vs,3))
    println(first(odm,3))
    geometry = []
    value  = []
    outfrom = []
    for i = 1:nod
        o = odm[i,:orig]
        d = odm[i,:dest]
        olat = vs[o,:lat]
        olon = vs[o,:lon]
        dlat = vs[d,:lat]
        dlon = vs[d,:lon]
        push!(geometry,geom.LineString([(olat, olon),(dlat, dlon)]))
        push!(value, odm[i,:val]/1e6)
        push!(outfrom, vs[o,:cname])
    end
    data = Dict("value" => value, "outfrom"=>outfrom)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)
    println("saving to $outfile")
    gdf.to_file(outfile, layer="reduced", driver="GPKG")
    return true
end
