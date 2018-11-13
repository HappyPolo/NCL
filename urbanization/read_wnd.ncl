load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    data1=asciiread("/home/ys-ug/data/Station/tmax.csv", -1, "string")
    ncols     = dimsizes(str_split(data1(0),","))
    nrows     = dimsizes(data1)
    data01=onedtond(data1, (/npts,ncol/))
    printVarSummary(data010)
    end 
