"""
    Arguments:
        erfile - contains reduced net edges - orig,dest,km,jur
        effile - contains full net edges - orig,dest,redge(reduced edge)
        vffile - contains full net vertices - lon,lat,ibge
        outfile: string - filename to write gpkg

    Returns:
        saves gpkg to outfile
        return DataFrame with o,d,val
"""
function full_to_gpkg(g::SimpleGraph, vffile::String, effile::String,
                   distmx::Array{Float64, 2}, jurmx, eidic::Dict{Any,Any};
                   outfile::String = "full.gpkg")


    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")
    
    #----------------------------------------------------
    ef = CSV.read(effile, DataFrame)
    vf = CSV.read(vffile, DataFrame)
    gedges = collect(edges(g))


    nef = size(ef,1)
    dist = []
    geometry = []
    jur = []
    # first need to be treated separetly
    rold = ef[1,:redge]
    o = ef[1,:orig]
    d = ef[1,:dest]
    dlat = vf[d,:lat]
    dlon = vf[d,:lon]
    olat = vf[o,:lat]
    olon = vf[o,:lon]
    linestr = [(olat, olon), (dlat, dlon)]
    for i = 2:nef
        o = ef[i,:orig]
        d = ef[i,:dest]
        r = ef[i,:redge]
        dlat = vf[d,:lat]
        dlon = vf[d,:lon]
        olat = vf[o,:lat]
        olon = vf[o,:lon]
        if r == rold
            push!(linestr, (dlat, dlon))
        else
            if haskey(eidic, rold)
                j = eidic[rold+1]
                ej = gedges[j]
                k = ej.src
                l = ej.dst
                push!(dist, distmx[k,l])
                push!(jur, jurmx[k,l])
                push!(geometry, geom.LineString(linestr))
            else
                push!(dist, -1.0)
            end
            # start new linestring
            linestr = [(olat, olon), (dlat, dlon)]
        end
        rold = r
    end
    data = Dict("dist" => dist, "jur"=> jur)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)
    println("saving $outfile")
    gdf.to_file(outfile, layer="full", driver="GPKG")


    df = DataFrame(id=Int[], orig=Int[], dest=Int[], val=Float64[])
    for i in 1:ne(g)
        j = eidic[i]
        # println("$i $j")
        ej = gedges[j]
        o = Int(ej.src)
        d = Int(ej.dst)
        val = distmx[o, d]
        push!(df, [j,o,d,val])
    end

    return df
end
