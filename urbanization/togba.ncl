load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f = addfile("/home/ys-ug/data/guangdong/tt2m_daily_prd.nc", "r") 
    t = f->tt
    lon = f->lon
    lat = f->lat
    sta =f->stat
    d = readAsciiTable("/home/ys-ug/data/guangdong/prd_gba.txt", 1, "integer", 0)
    

end