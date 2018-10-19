begin                                
    a = addfile("./EASE.nc","r")
    yyyymm    = 200502
    date      = a->date
    nt        = ind(date.eq.yyyymm)          
    
    snow       = a->SWE(nt,:,:)                 ; snow is type short
    snow@lat2d = a->latitude
    snow@lon2d = a->longitude

    
    wks = gsn_open_wks("x11","ease")            ; send graphics to PNG file

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
    res@cnLevels            = (/-300,-250,-200,-150,-100,   \
                                0,1,5,10,25,100,200,300,400/)
    
;---Plot original data.
    res@gsnAddCyclic = False
    res@trGridType = "TriangularMesh"        ; allow missing coordinates

    res@gsnPolar   = "NH"                          ; specify the hemisphere
    res@mpMinLatF  = 35

    plot = gsn_csm_contour_map_polar(wks,snow,res)   
end
