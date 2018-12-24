load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fo = addfile("/mnt/e/data/ty/omega.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    ft = addfile("/mnt/e/data/ty/air.nc", "r")
    T = short2flt(ft->t)
    u = short2flt(fu->u(:,:,:,:))
    T0 = T
    T0 = 273.15
    t = T-T0
    copy_VarCoords(T, t)

    pt = pot_temp(t&level, t, 1, False)
printVarSummary(t)
    v = short2flt(fv->v)
    w = short2flt(fo->w)

 wAve   = avg(w(0,:,:,{113}))           ; used for scaling
 vAve   = avg(v(0,:,:,{113}))
 scale  = fabs(vAve/wAve)
 wscale = w*scale                       ; now scale

 copy_VarCoords(w, wscale)              ; copy coordinate variables 

;---Create plot
    wks = gsn_open_wks("png", "/mnt/e/scripts/ncl/ty/w/w")     ; send graphics to PNG file

 res                 = True                     ; plot mods desired
 ; res@tiMainString    = "Pressure/Height Vector" ; title
res@cnLinesOn = False
 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 res@cnFillPalette   = "MPL_Reds"  ; choose color map

res@cnLevelSelectionMode = "ManualLevels"
res@cnMaxLevelValF = 30
res@cnMinLevelValF = -30
res@cnLevelSpacingF = 2
 res@lbLabelStride   = 2                    ; every other color


    res@vcGlyphStyle = "CurlyVector"
    res@vcLineArrowColor          ="black"
    res@vcLineArrowThicknessF     = 2.5
    ; ; res@vcRefAnnoPerimOn 
    res@vcRefAnnoOn               =True
    res@vcRefAnnoBackgroundColor  ="white"
    res@vcRefAnnoFontHeightF      =0.008
    res@vcRefAnnoOrthogonalPosF   =-0.13
    res@vcRefAnnoParallelPosF     =1.
    res@vcRefAnnoPerimOn          =True
    res@vcRefAnnoArrowUseVecColor = False
    res@vcRefAnnoArrowLineColor   ="Black"
    res@vcRefAnnoSide             ="Bottom"
    res@vcRefAnnoString1On        =False ;参考箭头上方字符
    res@vcRefAnnoString2On        =True ;参考箭头下方字符

    res@vcRefMagnitudeF = 60
    res@vcRefLengthF = 0.03
    res@vcMinDistanceF = 0.025

    ; res@vcMinDistanceF = 0.03

    res@vcRefAnnoString2          ="30 m/s"   

        res@pmTickMarkDisplayMode="Always"
    
    res@pmLabelBarWidthF         =0.6 
    res@pmLabelBarHeightF        =0.06 
    
    res@lbLabelOffsetF           =0.1 
    res@lbLabelFontHeightF       =0.026
    res@lbLabelFontColor         ="black"
    res@lbLabelFontThicknessF    =2
    res@lbLabelStride            =1 
    ; res@pmLabelBarOrthogonalPosF =0.25
    res@lbBoxEndCapStyle         = "TriangleBothEnds"
; res@vcLineArrowColor = "green"

;---Draw plot from pole to pole at 170E
time:=cd_calendar(v&time, -5)

do i = 0,15
           res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"
 plot  = gsn_csm_pres_hgt_vector(wks,pt(i,{1000:300},{0:90},{170}),v(i,{1000:300},{0:90},{170}),\
                                wscale(i,{1000:300},{0:90},{170}),res ) 
end do 

end