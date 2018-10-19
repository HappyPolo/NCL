;================================================
;  gfed_1.ncl
;================================================
; Concepts illustrated:
;   - Creating a GFED classification plot using raster contours
;   - Customizing a labelbar for a contour plot
;   - Centering labels with respect to labelbar boxes
;   - Changing the width and height of a labelbar
;   - Centering the labels inside each box in a labelbar
;   - Changing the labelbar labels
;   - Drawing text on the frame using NDC coordinates
;================================================
; Requires 6.4.0
;================================================

  diri  = "./"                          ; input directory
  fili  = "GFED4.1s_1997.hdf5"    
  f     = addfile (diri+fili, "r")

  x     = f->basis_regions              ; note: type ubyte
  printVarSummary(x)

  lat2d = f->lat
  lat2d@units = "degrees_north"
  lon2d = f->lon
  lon2d@units = "degrees_east"

  x@lat2d = lat2d
  x@lon2d = lon2d
                                       ; manually specify levels
  info     = (/"Ocean","BONA","TENA","CEAM","NHSA","SHSA","EURO","MIDE" \
              , "NHAF","SHAF","BOAS","CEAS","SEAS","EQAS","AUST" /)

;;class_0 :	Ocean
;;class_1 :	BONA (Boreal North America)
;;class_2 :	TENA (Temperate North America
;;class_3 :	CEAM (Central America)
;;class_4 :	NHSA (Northern Hemisphere South America)
;;class_5 :	SHSA (Southern Hemisphere South America)
;;class_6 :	EURO (Europe)
;;class_7 :	MIDE (Middle East)
;;class_8 :	NHAF (Northern Hemisphere Africa)
;;class_9 :	SHAF (Southern Hemisphere Africa)
;;class_10 :	BOAS (Boreal Asia)
;;class_11 :	CEAS (Central Asia)
;;class_12 :	SEAS (Southeast Asia)
;;class_13 :	EQAS (Equatorial Asia)
;;class_14 :	AUST (Australia and New Zealand)

  ninfo    = dimsizes(info)    ; =15
;************************************************
; create plot
;************************************************

  wks = gsn_open_wks("x11","gfed_1")        ; send graphics to PNG file
  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette    = "default"
  res@cnSpanFillPalette= False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels
  res@cnLevelSelectionMode = "ExplicitLevels"                ; set explict contour levels
  res@cnLevels         = integertobyte( ispan(1,ninfo,1) )   

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(0,ninfo,1)  

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

  res@gsnRightString   = fili
  plot = gsn_csm_contour_map_ce(wks, x, res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 3 rows x 5 columns of text
  n  = -1
  xx = 0.290                ; arbitrary
  do ncol=0,4
     yy = 0.210
    do nrow=0,2
       n = n+1
       label = n+": "+info(n)
       gsn_text_ndc (wks,label,xx,yy,rtxt)
       yy = yy - 1.75*rtxt@txFontHeightF
    end do
     xx = xx + 0.100 
  end do
  draw(plot)
  frame(wks)
