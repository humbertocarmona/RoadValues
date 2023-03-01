"""
    Creates the simplified undirected road network:
    only cities connected by straight roads

    Arguments:
        vfile::String (input file for vertices)
        # lon, lat, ibge, v(full network index)

        efile::String (input file for edges)
        # orig, dest, km, jur
        # km: distance from one city to another
        # jur: juristiction state≡0 federal≡1


    Returns:
        g::SimpleGraph
        distmax::Array{Float} (distance km, federal have 50% less weight)
"""
function reduced_network(vfile::String, efile::String)

    vs = CSV.read(vfile,DataFrame)
    es = CSV.read(efile,DataFrame) 

    nvs = size(vs, 1)  # number of vertices
    nes = size(es, 1)  # number od edges

    distmx = zeros(nvs, nvs) # distance matrix
    jurmx  = zeros(nvs, nvs) # juristiction matrix
    eidic = Dict() #need this dict because not all edges are added
    g = SimpleGraph(nvs)

    for i = 1:nes   
        o = es.orig[i]
        d = es.dest[i]
        if add_edge!(g, o, d)
            dist = (1 - 0.0*es.jur[i])*es.km[i]#  (1 - 0.5es.jur[i]) * federal have 50% less weight
            distmx[o, d] =  dist
            distmx[d, o] =  dist
            jurmx[o, d] = es.jur[i]
            jurmx[d, o] =  jurmx[o, d]
        end
    end

    # edges are not added in order...
    gedges = collect(edges(g))
    gedges = [(e.src, e.dst) for e in gedges]
    for i = 1:nes
        j = es.orig[i]
        k = es.dest[i]
        o = min(j,k)
        d = max(j,k)
        e = findall(x->x==(o,d), gedges)
        eidic[i] = e[1]
    end
    locations = collect(zip(vs.lat, vs.lon))
    return g, distmx, jurmx, eidic, locations
end
