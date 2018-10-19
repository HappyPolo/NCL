load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f=addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")
    ft=addfile("/mnt/f/data/NCEP/air.mon.mean.nc", "r")
    wks=gsn_open_wks("x11", "Ss")
    t=short2flt(f->hgt(0,:,:))
    a=short2flt(ft->air(0,0,:,:))
    print(t)
    res=True
    res@cnLinesOn=False
    res@cnFillOn=True
    res@cnLevelSelectionMode="ExplicitLevels"
    ;res@cnLevels=(/3000/)
    ;res@cnFillPattern=(/1,-1/)

    res@gsnDraw=False
    res@gsnFrame=False
    res2=res
        res2@mpMaxLatF=60
    res2@mpMinLatF=0
    res2@mpMaxLonF=140
    res2@mpMinLonF=60
        res2@cnLinesOn=True
    res2@cnFillOn=False
    base=gsn_csm_contour_map(wks, a, res2)
    plot=gsn_csm_contour(wks, t, res)
     opt                      = True
     opt@gsnShadeFillType     ="pattern"
  opt@gsnShadeHigh         = 17          ; cross hatch pattern
  opt@gsnShadeMid           = 0
  opt@gsnShdeLow           =0
  opt@gsnShadeFillType     = "pattern"


    plot=gsn_contour_shade(plot, 0, 100, opt)
overlay(base, plot)
draw(base)
frame(wks)
end