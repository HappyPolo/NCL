;******************************************************************
; godas_2.ncl
;
; Concepts illustrated:
;   - Reading GODAS GRIB data files
;   - Plotting selected vector variables and vector over scalar
;   - Reordering grids to allow coordinate subscripting across Greenwich Meridion
;
;************************************************
; Basic User input
;************************************************
diri = "./"
fili = "godas.M.200901.grb"

pltType  = "ps"
pltName  = "godasGrb"

;************************************************
; Import Libraries
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
;************************************************
;             MAIN
;************************************************
begin

;****************************************************
; Open GRIB file:  For illustration
; (1) Force a time dimension [not required here]
; (2) Use 'coordinate subscripting' to import data at specific coords
;****************************************************
    setfileoption("grb","SingleElementDimensions","Initial_time") ; force degenerate dim
    f    = addfile(diri + fili, "r")

    u    = f->UOGRD_GDS0_DBSL_ave1m(:,{5},:,:)    ; global 5 meter u
    v    = f->VOGRD_GDS0_DBSL_ave1m(:,{5},:,:)    ; global 5 meter v
    s    = f->SALTY_GDS0_DBSL_ave1m(:,{5},:,:)    ; salinity

;************************************************
; plotting parameters
;************************************************
    wks   = gsn_open_wks (pltType,pltName)        ; open workstation
    gsn_define_colormap(wks,"amwg")               ; choose colormap

; add gray to colormap for continents  [optional]  
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.7,0.7,0.7)  

;****************************************************
; Standard contour with a few simple options
;****************************************************

    res                      = True               ; plot mods desired
    res@gsnMaximize          = True               ; make ps, eps, pdf large
   ;res@gsnPaperOrientation  = "portrait"         ; force portrait
    res@gsnSpreadColors      = True               ; Use full color map
    res@gsnSpreadColorEnd    = -2                 ; do not use gray for contours
    res@mpLandFillColor      = "grey"             ; color of land 
    
    res@vcRefMagnitudeF      = 0.5                ; define vector ref mag
    res@vcRefLengthF         = 0.045              ; define length of vec ref
    res@vcMinDistanceF       = 0.015              ; thin out vectors
    res@vcRefAnnoOrthogonalPosF = -1.00           ; move ref vector
    res@vcMonoLineArrowColor = False              ; create color vectors
  ;;res@vcGlyphStyle         = "CurlyVector"      ; turn on curley vectors

    res@lbLabelAutoStride    = True

    res@tiMainString         = "Vectors colored by their magnitude"
    res@gsnLeftString        = "Current at 5m"    ; change left string
    res@gsnCenterString      = fili

    nt  = 0
    plot = gsn_csm_vector_map_ce(wks,u(nt,:,:),v(nt,:,:),res)

;****************************************************
; Regional Grids
;****************************************************
    minLon                   =  65.               ; select a subregion
    maxLon                   =  95.
    minLat                   =   5. 
    maxLat                   =  25.

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels

    res@gsnScalarContour     = True               ; contours desired
    res@gsnAddCyclic         = False              ; regional plot

    res@mpMinLonF            =  minLon            ; select a subregion
    res@mpMaxLonF            =  maxLon
    res@mpMinLatF            =  minLat
    res@mpMaxLatF            =  maxLat

    res@lbOrientation        = "Vertical"         ; vertical label bar
    res@vcMonoLineArrowColor = True               ; default
    res@tiMainString         = "Vectors over Scalar"

    plot=gsn_csm_vector_scalar_map_ce(wks,u(nt,{minLat:maxLat},{minLon:maxLon}) \
                                         ,v(nt,{minLat:maxLat},{minLon:maxLon}) \
                                         ,s(nt,{minLat:maxLat},{minLon:maxLon}) , res)

;****************************************************
; Reorder to allow spanning Greenwich Meridion
;****************************************************
    u                        = lonFlip( u )       ; make -180 to 180
    v                        = lonFlip( v )
    s                        = lonFlip( s )

    minLon                   =  -20               ; select a subregion
    maxLon                   =   45
    minLat                   =   30 
    maxLat                   =   48.

    res@mpMinLonF            =  minLon            ; select a subregion
    res@mpMaxLonF            =  maxLon
    res@mpMinLatF            =  minLat
    res@mpMaxLatF            =  maxLat

    res@vcRefMagnitudeF      = 0.1                ; define vector ref mag
    res@vcMinDistanceF       = 0.0125             ; thin out vectors

    res@gsnLeftString        = "Current/Salinity [5m]"    ; change left string
    plot=gsn_csm_vector_scalar_map_ce(wks,u(nt,{minLat:maxLat},{minLon:maxLon}) \
                                         ,v(nt,{minLat:maxLat},{minLon:maxLon}) \
                                         ,s(nt,{minLat:maxLat},{minLon:maxLon}) , res)
end
