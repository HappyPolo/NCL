load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ; fn =addfile("/mnt/e/SYSU/data/South_China_DMSP_OLS.1992-2013.nc", "r")
    fs =addfile("/mnt/e/SYSU/data/guangdong/gba/t_daily_gba.nc", "r")
    ; nl=f->NL 
    s=(/45011,45005/)
    ; slat=fs->lat 
    ; slon=fs->lon 
    slat=(/22.2,22.3/)
    slon=(/113.6,114.2/)
    ; srad = (/5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15.,20.,25.,30/)
    srad = (/2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15.,20.,25.,30/)
    srad_unit = 1                            ; km
    N         = 180                         ; # of points; more points nicer 'circle'
    opt       = False
    nLoc = dimsizes(slat)                   ; # locations
    nRad = dimsizes(srad)
    circle    = geolocation_circle(slat, slon, srad, srad_unit, N, opt) ; circle is type list
print(circle)
    circle_lat = circle[0]                   ; clarity: explicitly extract list variables
    circle_lon = circle[1]
    printVarSummary(circle_lat)
    printVarSummary(circle_lon)
    system("rm /mnt/e/SYSU/data/guangdong/gba/incircle_HK_MC.nc")
    ncdf=addfile("/mnt/e/SYSU/data/guangdong/gba/incircle_HK_MC.nc", "c")
    ncdf->clat = circle_lat
    ncdf->clon = circle_lon
    ncdf->stat = s 
    




end
