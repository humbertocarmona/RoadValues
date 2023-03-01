function maptorange(y; r::Tuple =(0,1))
    ymax = maximum(y)
    ymin = minimum(y)
    y = map(x-> r[1] + (x-ymin)/(ymax-ymin)*r[2], y)
end
