;************************************************
; permafrost_1.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

  diri = "./"
  b    = fbindirread(diri+"nhipa.byte",0,(/1441,1441/),"byte")

  f    = addfile(diri+"EaseLatLon.1441x1441.nc", "r")
  b@lat2d = f->latitude
  b@lon2d = f->longitude

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png" ,"permafrost")             ; send graphics to PNG file
;  gsn_define_colormap(wks,"hlu_default")              ; choose colormap

  res              = True                             ; plot mods desired
  res@gsnMaximize  = True                             ; make ps, eps, pdf, ... large
  res@gsnPolar     = "NH"                             ; specify the hemisphere
  res@gsnPolarLabelFontHeightF = 0.0125               ; make labels a bit smaller

  res@cnLevelSelectionMode = "ExplicitLevels"   
  res@cnLevels         = (/    1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25/)
  res@cnFillColors     = (/"gray", "red", "green", "blue", \
  "yellow", "cyan", "magenta", "sienna4", "paleturquoise", "navyblue","khaki1", \
  "mediumpurple2","darkorange","cornflowerblue","chartreuse","darkorchid3", \
  "darkseagreen3","pink2","seagreen","slateblue3","deeppink","black", \
  "olivedrab4","white", "white", "white"/)
  res@lbLabelStrings   = \ 
        (/" 0    "," 1-chf"," 2-dhf"," 3-shf"," 4-ihf"," 5-cmf"," 6-dmf"," 7-smf"," 8-imf"," 9-clf" \
         ,"10-dlf","11-slf","12-ilf","13-chr","14-dhr","15-shr","16-ihr","17-clr","18-dlr","19-slr" \
         ,"20-ilr","21-g  ","22-r  ","23-l  ","24-o  ","25-ld "/)
  res@lbLabelAlignment = "BoxCenters"        ; label orientation
  res@lbOrientation    = "Vertical"

  res@pmLabelBarOrthogonalPosF =  0.075      ; move label bar to right
  res@trGridType     = "TriangularMesh"      ; allow missing coordinates

  res@cnFillOn       = True                  ; color fill
  res@cnFillPalette  = "default"             ; set color map
  res@cnLinesOn      = False                 ; no contour lines
  res@cnLineLabelsOn = False                 ; no contour lines
  res@cnFillMode     = "RasterFill"          ; turn raster on 

  res@mpPerimDrawOrder = "PostDraw"
  res@mpFillOn       = False
  res@mpMinLatF      = 25                    ; minimum lat to plot
  res@mpCenterLonF   = 180 
  res@tiMainString = "NSIDC: Circum-Arctic Permafrost"

  plot    = gsn_csm_contour_map_polar(wks,b,res)
