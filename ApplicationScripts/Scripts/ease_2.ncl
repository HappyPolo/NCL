;******************************************************************
; ease_2.ncl
;
; Concepts illustrated:
;   - Plotting Snow Exten on an Ease grid
;   - Explicitly setting contour levels to uneven levels
;   - Drawing raster contours
;   - Changing the width and height of a labelbar
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Using triangular meshes to create contours
;   - Drawing the northern hemisphere of a polar stereographic map
;
;******************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
    

;*******************************************
;read netCDF file 
;  merged_snow_cover_extent(time, rows, cols) ;
;  merged_snow_cover_extent:flag_values = 10b, 11b, 12b, 20b, 30b, 40b ;
;  merged_snow_cover_extent:_FillValue = -99b ;
;  merged_snow_cover_extent:comment = "10: Snow cover reported by weekly_cdr, passive_microwave
;                                      11: Snow cover reported by weekly_cdr only  
;                                      12: Snow cover reported by passive_microwave only
;                                      20: Snow free land
;                                      30: Permanent ice covered land
;                                      40: Ocean" 
;*******************************************
    nt   = 0                                                         ; 1st (only) time step
    diri = "./"
    fili = "nhtsw100e2_20121225_20121231"
    a    = addfile(diri+fili+".nc","r")      
    sne        = a->merged_snow_cover_extent(nt,:,:)                 ; sne is type byte
    sne@lat2d  = a->latitude                                         ; georeference
    sne@lon2d  = a->longitude

    info = (/ "10: Snow: cdr: passive microwave" \ 
            , "11: Snow: cdr only              " \ 
            , "12: Snow: passive microwave only" \ 
            , "20: Snow free land              " \ 
            , "30: Permanent ice covered land  " \ 
            , "40: Ocean                       " /)
    ninfo= dimsizes(info)

;*******************************************
; Create plots
; Georeferencing: plot on polar projection
;*******************************************
    
    wks = gsn_open_wks("png","ease")            ; send graphics to PNG file

    res                     = True              ; Plot modes desired.
    res@gsnDraw             = False
    res@gsnFrame            = False
    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@cnLevelSelectionMode= "ExplicitLevels"  ; set explicit contour levels
  ;;res@cnLevels            = tobyte( (/ 10, 11, 12, 20, 30    /) )          ; see above
    res@cnLevels            = tobyte( (/ 11, 12, 13, 21, 31    /) )          ; 'trick'   
    res@cnFillPalette       = (/"darkgreen", "chartreuse", "yellow"      \   ; 10, 11, 12
                               ,"burlywood3","mistyrose","lightsteelblue"/)  ; 20, 30, 40
    res@lbLabelStrings      = (/ "10", "11", "12", "20", "30", "40" /)       ; extra label

    res@lbLabelFontHeightF  = .015              ; default is HUGE
    res@lbLabelPosition     = "Center"          ; label position
    res@lbLabelAlignment    = "BoxCenters"
    res@lbLabelStride       = 1
    res@lbLabelAutoStride   = False 

   ;res@pmLabelBarWidthF    = 0.6
    res@pmLabelBarHeightF   = 0.060             ; default is taller
    res@pmLabelBarOrthogonalPosF = -0.005     

    res@mpFillOn            = False             ; turn off default land fill
    res@mpMinLatF           =  20.0
   ;res@mpCenterLonF        = -90.0
    
    res@trGridType          = "TriangularMesh"  ; allow missing coordinates
    res@gsnPolar            = "NH"              ; specify the hemisphere
    res@tiMainString        = "MEaSUREs: Weekly "+sne@long_name
    res@gsnLeftString       = ""
    res@gsnCenterString     = "file="+fili

; Add text: rows x columns of text (arbitrary)
; Usually must play with xx, yy and txFontHeightF

    res@vpHeightF           = 0.500             ; default 0.60
    res@vpWidthF            = 0.500             ;    "
    plot = gsn_csm_contour_map_polar(wks,sne,res)   

    nrow = 2       ; # rows
    ncol = 3       ; # columns

    rtxt = True
    rtxt@txJust        = "CenterLeft"
    rtxt@txFontHeightF = 0.0130
                            
    n  = -1        ; counter
    xx = 0.025     ; iterate to get right  
    do nc=0,ncol-1
       yy = 0.035  
      do nr=0,nrow-1
         n = n+1
         if (n.le.(ninfo-1)) then    ; handle less than ninfo
             gsn_text_ndc (wks,info(n),xx,yy,rtxt)
             yy = yy - 2*rtxt@txFontHeightF
         end if
      end do
       xx = xx + 0.325    ; iterate to get right 
    end do

    draw(plot)
    frame(wks)

