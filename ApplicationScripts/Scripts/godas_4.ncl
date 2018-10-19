;
; godas_4.ncl
;
; Concepts illustrated:
;   - Reading multiple GODAS netCDF files
;   - Dealing with the issue of different 
;     missing_value and _FillValue attributes
;   - Paneling basic vector/scalar figures
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
;             MAIN
;************************************************
begin

    diri = "./"
    f1 = "dzdt.1998.nc"
    f2 = "ucur.1998.nc"
    f3 = "vcur.1998.nc"  

    pltType  = "png"                              ; send graphics to PNG file
    pltName  = "godas"

;****************************************************
; Open netCDF file:  For illustration
; (1) Use 'coordinate subscripting' to import data at specific coords
;****************************************************
    a    = addfile(diri + f1, "r")
    b    = addfile(diri + f2, "r")
    c    = addfile(diri + f3, "r")

    us   = b->ucur(:,{5},:,:)                     ; type "short"
    vs   = c->vcur(:,{5},:,:)
    dzdts= a->dzdt(:,{10},:,:)

    printVarSummary(us)                           ; exploratory look
    printVarSummary(dzdts)
                                                  ; Use missing_vale
    us@_FillValue    = us@missing_value           ; Force over write
    vs@_FillValue    = vs@missing_value
    dzdts@_FillValue = dzdts@missing_value

    u    = short2flt(us)                          ; convert to float
    v    = short2flt(vs)    
    dzdt = short2flt(dzdts)

    delete(us)                                    ; no longer needed
    delete(vs)
    delete(dzdts)

    date = a->date                                ; used for panel plot

 ;************************************************
    wks  = gsn_open_wks (pltType,pltName)         ; open workstation

;****************************************************
; Regional Grids
;****************************************************
    minLon                   =  40.               ; select a subregion
    maxLon                   =  130.
    minLat                   =  -10.
    maxLat                   =  40.

    res                      = True               ; plot mods desired
    res@gsnDraw              = False              ; don't draw
    res@gsnFrame             = False              ; don't advance frame
    res@mpLandFillColor      = "grey"             ; color of land
    res@lbLabelBarOn         = False              ; turn off individual cb 
    res@cnFillOn             = True               ; turn on color for contours
    res@cnFillPalette        = "nrl_sirkes"       ; set color map
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels
    res@gsnScalarContour     = True               ; contours desired
    res@gsnAddCyclic         = False              ; regional plot
    res@mpMinLonF            = minLon             ; specify a subregion
    res@mpMaxLonF            = maxLon
    res@mpMinLatF            = minLat
    res@mpMaxLatF            = maxLat
    res@lbLabelFontHeightF   = 0.018
    res@vcRefMagnitudeF      = 0.5                ; define vector ref mag
    res@vcMinDistanceF       = 0.0185             ; thin out vectors
    res@vcMonoLineArrowColor = "True"
    res@vcLineArrowColor     = "black"
    res@vcRefLengthF         = 0.045              ; define length of vec ref
    res@vcGlyphStyle         = "CurlyVector"      ; turn on curley vectors
    res@vcRefAnnoOrthogonalPosF = -1.00           ; move ref vector
    res@cnLevelSelectionMode =  "ManualLevels"
    res@cnMinLevelValF       =  -2
    res@cnMaxLevelValF       =  2
    res@cnLevelSpacingF      =  0.5
;    res@cnFillColors    = (/4,5,6,7,9,11,14,16,17,18,19,21/)
    res@cnFillColors    = (/3,4,5,6,8,10,13,15,16,17,18,20/)

    dzdt = dzdt*1e5      ; scale .... arbitrary  .... nicer values
    dzdt@units = "1e5*( "+dzdt@units+" )"
                       
    plot = new (4, "graphic")
    do nt=0,3
        res@gsnCenterString = date(nt)
        plot(nt)= gsn_csm_vector_scalar_map_ce(wks \
                  ,u(nt,{minLat:maxLat},{minLon:maxLon}) \
                  ,v(nt,{minLat:maxLat},{minLon:maxLon}) \
                  ,dzdt(nt,{minLat:maxLat},{minLon:maxLon}) , res)
    end do

;************************************************
; create panel
;************************************************
  resP                  = True            ; modify the panel plot


  resP@gsnMaximize      = True            ; fill up the page
  resP@gsnPanelLabelBar = True            ; add common colorbar
 ;resP@lbLabelStride    =   2             ; default is one
 ;resP@gsnPaperOrientation  = "portrait"  ; force portrait
  gsn_panel(wks,plot,(/2,2/),resP)        ; now draw as one plot
end 
