load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
wks:=gsn_open_wks("eps", "/mnt/e/scripts/ncl/ty/out/th_32")
    fo = addfile("/mnt/e/data/ty/omega.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    ft = addfile("/mnt/e/data/ty/t_2005.nc", "r")
    fh = addfile("/mnt/e/data/ty/h_2005.nc", "r")
    T = (ft->t)
    h0 = fh->h
    h = h0/9.8
    copy_VarCoords(h0, h)
    u = short2flt(fu->u(:,:,:,:))
    T0 = T
    T0 = 273.15
    t = T
    copy_VarCoords(T, t)

    pt = pot_temp(t&level, t, 1, False)
printVarSummary(t)
    v = short2flt(fv->v)
    omega = short2flt(fo->w)
    p = u&level 
    p0 = u
    p0 = 100
    P = conform(u, p, 1)
    P := P*p0
    P@units = "Pa"

    w = v


 wAve   = avg(w(0,:,:,{113}))           ; used for scaling
 vAve   = avg(v(0,:,:,{113}))
 scale  = fabs(vAve/wAve)
 wscale = w*scale                       ; now scale

 copy_VarCoords(w, wscale)              ; copy coordinate variables 

;---Create plot
    ; wks = gsn_open_wks("eps", "th")     ; send graphics to PNG file

 res                 = True                     ; plot mods desired
 ; res@tiMainString    = "Pressure/Height Vector" ; title
 res@gsnDraw = False
 res@gsnFrame = False
res@cnLinesOn = False
 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 res@cnFillPalette   = "MPL_bwr"  ; choose color map

res@cnLevelSelectionMode = "ManualLevels"
; res@cnLevels = ispan(30, 65, 2)
res@cnMaxLevelValF = 10
res@cnMinLevelValF = -10
res@cnLevelSpacingF = 1
 res@lbLabelStride   = 2                    ; every other color


    ; res@vcGlyphStyle = "CurlyVector"
    ; res@vcLineArrowColor          ="black"
    ; res@vcLineArrowThicknessF     = 3.5
    ; ; ; res@vcRefAnnoPerimOn 
    ; res@vcRefAnnoOn               =True
    ; res@vcRefAnnoBackgroundColor  ="white"
    ; res@vcRefAnnoFontHeightF      =0.008
    ; res@vcRefAnnoOrthogonalPosF   =-0.13
    ; res@vcRefAnnoParallelPosF     =1.
    ; res@vcRefAnnoPerimOn          =True
    ; res@vcRefAnnoArrowUseVecColor = False
    ; ; res@vcRefAnnoArrowLineColor   ="CadetBlue3"
    ; res@vcRefAnnoSide             ="Bottom"
    ; res@vcRefAnnoString1On        =False ;参考箭头上方字符
    ; res@vcRefAnnoString2On        =True ;参考箭头下方字符

    ; res@vcRefMagnitudeF = 60
    ; res@vcRefLengthF = 0.03
    ; res@vcMinDistanceF = 0.025

    ; ; res@vcMinDistanceF = 0.03

    ; res@vcRefAnnoString2          ="60 m/s"   

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

    ; res@cnFillOpacityF = 0.9
    res@gsnLeftString = ""
    res@gsnRightString = "K"

    rest = True
    rest@gsnDraw = False
    rest@gsnFrame = False
    rest@cnLinesOn = True
    rest@cnFillOn = False

    rest@cnInfoLabelOn = False
    rest@cnLineLabelsOn = True
    rest@cnLineLabelBackgroundColor = -1
    rest@cnLevelSelectionMode = "ManualLevels"



    ; rest@cnMaxLevelValF = 30
    ; rest@cnMinLevelValF = -90
    ; rest@cnLevelSpacingF = 5

    rest@gsnContourNegLineDashPattern =16 ;负值等值线线型为0
    rest@cnLineLabelDensityF = 1
    rest@cnLineLabelFontHeightF = 0.014
    rest@cnLineLabelAngleF = 0

    rest@cnLineThicknessF = 2.5

    rest@cnLineColor = "Black"





; res@vcLineArrowColor = "green"

;---Draw plot from pole to pole at 170E
time:=ispan(20050301, 20050315, 1)

do i = 5,5
           res@tiMainString=sprinti("%8i", time(i))
 plot  = gsn_csm_pres_hgt(wks,t(i,{1000:100},{0:90},{170}),res ) 
 plot2 = gsn_csm_pres_hgt(wks, h(i,{1000:100},{0:90},{170}), rest)
 overlay(plot, plot2)
 draw(plot)
 frame(wks)
end do 

end