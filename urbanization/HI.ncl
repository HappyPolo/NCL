load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f=addfile("/home/ys-ug/data/guangdong/data_gba.nc", "r")
    T=f->tt
    RH=f->rh
    HI=-8.784695+1.61139411*T-2.338549*RH\
       -0.14611605*T*RH-1.2308094*10^-2*T^2\
       -1.6424828*10^-2*RH^2+2.211732*10^-3*T^2*RH\
       +7.2546*10^-4*T*RH^2+3.582*10^(-6)*T^2*RH^2
    print(HI)

end