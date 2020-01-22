# time
using NCDatasets

filename = tempname()

for (timeunit,factor) in [("days",1),("hours",24),("minutes",24*60),("seconds",24*60*60)]

    NCDatasets.NCDataset(filename,"c") do ds
        NCDatasets.defDim(ds,"time",3)
        v = NCDatasets.defVar(ds,"time",Float64,("time",), attrib = [
            "units" => "$(timeunit) since 2000-01-01 00:00:00"])
        v[:] = [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)]
        #v.var[:] = [1.,2.,3.]

        # write "scalar" value
        v[3] = DateTime(2000,1,5)
        @test v[3] == DateTime(2000,1,5)

        # time origin
        v[3] = 0
        @test v[3] == DateTime(2000,1,1)
    end

    NCDatasets.NCDataset(filename,"r") do ds
        v2 = ds["time"].var[:]
        @test v2[1] == 1. * factor

        v2 = ds["time"][:]
        @test v2[1] == DateTime(2000,1,2)
    end

    rm(filename)
end

NCDatasets.NCDataset(filename,"c") do ds
    NCDatasets.defDim(ds,"time",3)

    v2 = NCDatasets.defVar(ds,"time2",
                           [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)],("time",), attrib = [
                               "units" => NCDatasets.CFTime.DEFAULT_TIME_UNITS
                           ])

    @test v2[:] == [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)]
    @test v2.attrib["units"] == NCDatasets.CFTime.DEFAULT_TIME_UNITS
end


# test fill-value in time axis
filename = tempname()
NCDatasets.NCDataset(filename,"c") do ds
    NCDatasets.defDim(ds,"time",3)
    v = NCDatasets.defVar(ds,"time",Float64,("time",), attrib = [
        "units" => "days since 2000-01-01 00:00:00",
        "_FillValue" => -99999.])
    v[:] = [DateTime(2000,1,2), DateTime(2000,1,3), missing]
    # load a "scalar" value
    @test v[1] == DateTime(2000,1,2)
end
rm(filename)

# test time axis with no explicit unit
filename = tempname()
NCDataset(filename,"c") do ds
    defDim(ds,"time",3)
    v = defVar(ds,"time",Float64,("time",))
    v[:] = [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)]
    # re-load
    v = ds["time"]
    @test v[1] == DateTime(2000,1,2)
    @test haskey(v.attrib,"units")
end
rm(filename)


# test fill-value in time axis
filename = tempname()
NCDatasets.NCDataset(filename,"c") do ds
    NCDatasets.defDim(ds,"time",3)
    v = NCDatasets.defVar(ds,"time",Float64,("time",), attrib = [
        "units" => "days since 2000-01-01 00:00:00",
        "_FillValue" => -99999.])
    v[:] = [1.,2.,3.]
    # load a "scalar" value
    @test v[1] == DateTime(2000,1,2)
end
rm(filename)
