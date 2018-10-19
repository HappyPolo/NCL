;******************************************************************
; godas_1.ncl
;
; Concepts illustrated:
;   - Reading GODAS GRIB data files
;   - Illustrating difference between "area fill" and "raster fill" contours
;
;************************************************
; Basic User input
;************************************************
diri = "./"
fili = "godas.M.200901.grb"

pltType  = "ps"
pltName  = "godasGrb"      ; can be anything   

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

    t    = f->POT_GDS0_DBSL_ave1m (:,{5},:,:)     ; global 5 meter temperature
    dzdt = f->DZDT_GDS0_DBSL_ave1m (:,:,{0},:)    ; vertical slice at the Eq. 

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
  i = NhlNewColor(wks,0.7,0.7,0.7)                ; medium grey  

;****************************************************
; Standard contour with a few simple options
;****************************************************

    res                  = True                   ; plot mods desired
    res@gsnMaximize      = True                   ; make ps, eps, pdf large
    res@gsnPaperOrientation = "portrait"          ; force portrait
    res@gsnSpreadColors  = True                   ; Use full color map
    res@gsnSpreadColorEnd= -2                     ; do not use gray for contours

    res@cnFillOn         = True                   ; color
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False
    res@mpLandFillColor  = "grey"                 ; color of land

    res@lbLabelAutoStride= True                   ; let NCL choose stride

    res@tiMainString     = fili

    nt   = 0
    plot = gsn_csm_contour_map(wks, t(nt,:,:), res)

    delete(res@mpLandFillColor)                   ; avoid annoying warning message

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = -16.               ; set min contour level
    res@cnMaxLevelValF       =  16.               ; set max contour level
    res@cnLevelSpacingF      =   2.               ; set contour spacing

    res@lbOrientation    = "Vertical"
    res@trYReverse       = True      
    res@gsnYAxisIrregular2Linear = True

    dzdt = dzdt*1e5      ; scale .... arbitrary  .... nicer values 
    dzdt@units = "1e5*( "+dzdt@units+" )"

    plot = gsn_csm_contour(wks, dzdt(nt,:,{120:285}), res)  ; Pacific

    res@cnFillMode       = "RasterFill"           ; option
    plot = gsn_csm_contour(wks, dzdt(nt,:,{120:285}), res)  ; Pacific
end
