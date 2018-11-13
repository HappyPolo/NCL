external Rnd "./read_wnd.so"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    id_in=new((/937152/), string, 9999)
    stat_in=new((/348/), string, 9999)
    lon_in=new((/937152/), float, 9999)
    lat_in=new((/937152/), float, 9999)
    h_in=new((/937152/), float, 9999)
    wnd_in=new((/349,4748/), float, 9999)
    yyyy_in=new((/937152/), integer, 9999)
    mm_in=new((/937152/), integer, 9999)
    dd_in=new((/937152/), integer, 9999)
    Rnd::read_wnd(id_in,stat_in,lon_in,lat_in,\
            h_in,wnd_in,yyyy_in,mm_in,dd_in)
    printVar(wnd_in(0,1:10))

end