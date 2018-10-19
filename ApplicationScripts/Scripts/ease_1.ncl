;******************************************************************
; ease_1.ncl
;
; Concepts illustrated:
;   - Plotting Ease data
;   - Explicitly setting contour levels to uneven levels
;   - Getting the indices where data falls at a particular date
;   - Drawing raster contours
;   - Changing the width and height of a labelbar
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Using triangular meshes to create contours
;   - Drawing the northern hemisphere of a polar stereographic map
;
;******************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
    
begin                                
    yyyymm = 200502

;*******************************************
;read netCDF file 
;*******************************************
    a = addfile("./ease_m200307-200503.nc","r")      
    
    date = a->date
    nt   = ind(date.eq.yyyymm)                  ; index for specific date
    if (ismissing(nt)) then
      ;;print("?? bad yyyymm="+yyyymm)
        exit
    end if

    snow       = a->SWE(nt,:,:)                 ; snow is type short
;*******************************************
; Create plots
;*******************************************
    
    wks = gsn_open_wks("png","ease")            ; send graphics to PNG file

    res                     = True              ; Plot modes desired.
    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnFillMode          = "RasterFill"      ; turn raster on       
    res@pmLabelBarWidthF    = 0.9               ; make wider
    res@pmLabelBarHeightF   = 0.1               ; default is taller
    res@lbLabelFontHeightF  = .018              ; default is HUGE

    res@cnLevelSelectionMode= "ExplicitLevels" ; set explicit contour levels
    res@cnLevels            = (/-300,-250,-200,-150,-100   \
                               ,0,1,5,10,25,100,200,300,400/)
    
;************************************************
;No georeferencing: simple contour. Draws faster
;************************************************
    res@tiMainString = "gsn_csm_contour"
    plot = gsn_csm_contour(wks,snow,res)    ; contour, no map

;*******************************************
; georeferencing: plot on polar projection
;*******************************************
                                             ; georeference
    snow@lat2d = a->latitude
    snow@lon2d = a->longitude

    res@trGridType = "TriangularMesh"        ; allow missing coordinates

    res@gsnPolar   = "NH"                          ; specify the hemisphere
    res@mpMinLatF  = 35
    res@tiMainString = "gsn_csm_contour_map_polar"

    plot = gsn_csm_contour_map_polar(wks,snow,res)   
end
