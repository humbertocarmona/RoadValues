using SparseArrays

function writeGML(odfile, vrfile; outfile="od.gml")
    
    println(vrfile)
    vertices = CSV.read(vrfile, DataFrame) 
    odmatrix = CSV.read(odfile, DataFrame) 
    nvertices = size(vertices,1)
    nedges = size(odmatrix,1)


    s = open(outfile, "w") do file
        write(file,"graph\n")
        write(file,"[\n")
        write(file,"  Creator \"Gephi\"\n")
        write(file,"  directed 1\n")
        for i in 1:nvertices
            x = vertices.lon[i]
            y = vertices.lat[i]
            write(file,"  node\n")
            write(file,"  [\n")
            write(file,"    id $(i)\n")
            write(file,"    label \"$(i)\"\n")
            write(file,"    graphics\n")
            write(file,"    [\n")
            write(file,"      x $x\n")
            write(file,"      y $y\n")
            write(file,"      z 0.0\n")
            write(file,"      w 10.0\n")
            write(file,"      h 10.0\n")
            write(file,"      d 10.0\n")
            write(file,"      c 1,0\n")
            write(file,"    ]\n")
            write(file,"  ]\n")
        end

        for n in 1:nedges
            s = odmatrix.orig[n]
            d = odmatrix.dest[n]
            w = odmatrix.val[n]
            write(file,"  edge\n")
            write(file,"  [\n")
            write(file,"    id $n\n")
            write(file,"    source $(s)\n")
            write(file,"    target $(d)\n")
            write(file,"    weight $w\n")
            write(file,"    Label $n\n")
            write(file,"    nr $n\n")
            write(file,"  ]\n")
        end

        write(file,"]")
    end
    odmatrix
end

function writeNodes(vrfile, odfile; outfile="vod")
    vertices = CSV.read(vrfile, DataFrame) 
    odtable = CSV.read(odfile, DataFrame)
    loc = collect(zip(vertices.lat, vertices.lon))

    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")
    coords = [geom.Point(c) for c in loc]


    N = size(vertices,1)
    g = DiGraph(N)
    odmatrix = spzeros(N,N)
    for l in 1:size(odtable,1)
        i = odtable.orig[l]
        j = odtable.dest[l]
        w = odtable.val[l]
        if add_edge!(g,i,j)
            odmatrix[i,j] = w
        end
    end

    links = collect(edges(g))
    vals  = []
    geometry = []
    for e in links
        i = e.src
        j = e.dst
        push!(geometry, geom.LineString([coords[i],coords[j]]))
        push!(vals, odmatrix[i,j])
    end

    println(100*ne(g)/(N*(N-1)))

    df = DataFrame(lon=[], lat=[], kout=[], sout=[], nome=[])
    for i in 1:nv(g)
        lon = loc[i][1]
        lat = loc[i][2]
        neig = neighbors(g, i)
        kout = length(neig)
        nome = vertices.cname[i]
        if kout > 0
            sout = 0.0
            for j in neig
                sout +=  odmatrix[i,j]
            end
            push!(df, [lon,lat,kout,sout,nome])
        end
    end

    df.koutn = log10.(df.kout)
    df.soutn = log10.(df.sout)
    CSV.write("$(outfile).csv", df)


    data = Dict("val" => vals)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)

    gdf.to_file("$(outfile).gpkg", layer=outfile, driver="GPKG")

    df
end