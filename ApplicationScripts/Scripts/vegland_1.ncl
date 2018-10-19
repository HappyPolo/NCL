;================================================
;  vegland_1.ncl
;================================================
; Concepts illustrated:
;   - Creating a vegetation classification plot using raster contours
;   - Plotting "byte" data
;   - Customizing a labelbar for a contour plot
;   - Centering labels with respect to labelbar boxes
;   - Changing the width and height of a labelbar
;   - Centering the labels inside each box in a labelbar
;   - Changing the labelbar labels
;   - Drawing text on the frame using NDC coordinates
;   - Using the "where" function to create a land-sea mask
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

begin
  diri = "./"                          ; input directory
  fili = "IGBPa_1198.map.nc"
  f    = addfile (diri+fili, "r")

  x    = f->CLASS                      ; note: type byte
 ;printVarSummary(x)

  info     = (/ " 1  Evergreen Needleleaf", \  ; n=0
                " 2  Evergreen Broadleaf ", \
                " 3  Deciduous Needleleaf", \
                " 4  Deciduous Broadleaf ", \
                " 5  Mixed Forest        ", \
                " 6  Closed Shrublands   ", \
                " 7  Open Shrublands     ", \
                " 8  Woody Savannas      ", \
                " 9  Savannas            ", \
                "10  Grasslands          ", \
                "11  Permanent Wetlands  ", \
                "12  Croplands           ", \
                "13  Urban and Built-up  ", \
                "14  Cropland Mosaics    ", \
                "15  Snow and Ice        ", \
                "16  Bare Soil and Rocks ", \
                "17  Water Bodies        ", \
                "18  Tundra              "  /) ; n=17
  ninfo    = dimsizes(info)

;************************************************
; create plot
;************************************************

  wks = gsn_open_wks("png","vegland")        ; send graphics to PNG file

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "default"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
  res@cnLevels         = integertobyte( ispan(2,ninfo,1) ) ; one less than ninfo

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

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
                            ; 3 rows x 6 columns of text
  n  = -1
  xx = 0.05                 ; arbitrary
  do ncol=0,5
     yy = 0.22 
    do nrow=0,2
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.155 
  end do
  draw(plot)
  frame(wks)

;---------------------------------------------------------------------
; pure land/sea mask
;---------------------------------------------------------------------
  delete(res)
  res                  = True                ; plot mods desired
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        =  False             ; Turn off contour lines

  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@cnLevels             = (/0.5/)          ; Values are either 0 or 1, so use something in the middle
  res@cnFillColors         = (/"red","green"/)

  res@lbLabelPosition   = "Center"           ; label position
  res@lbLabelAlignment  = "BoxCenters"       ; label orientation
  res@lbLabelStrings    = (/ "0", "1"/)
  res@pmLabelBarHeightF = 0.07              ; default is a bit too thick

  res@mpCenterLonF     = 0                  ; set map center at 180
  res@mpFillOn         = False

  y = x                                     ; land sea mask
  y = where (y.eq.tobyte(17), tobyte(0), tobyte(1))
 ;y = where (y.eq.17, 0, 1)                 ; this works too!

  res@gsnLeftString  = "CERES: Land-Sea Mask"
  plot = gsn_csm_contour_map_ce(wks, y, res) ; create plot

end

