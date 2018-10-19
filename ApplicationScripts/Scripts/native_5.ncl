; ***********************************************
; native_5.ncl
;
; Concepts illustrated:
;   - Plotting satellite data
;   - Calculating lat/lon values associated with geoscientific data
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Increasing the workspace for plotting large datasets.
;   - Drawing filled contours over a Lambert Conformal map
;   - Drawing filled contours over an orthographic map
;   - Improving the resolution of map outlines
;   - Zooming in on a particular area on a Lambert Equal Area map
;   - Zooming in on a particular area on an orthographic projection
;   - Changing the thickness of map outlines
;
;----------------------------------------------------------------------
; This script shows how to take data that's measured in a known map
; projection, retrieve the lat/lon values, and then use this information
; to plot the data on a different map projection.
;----------------------------------------------------------------------
;
; Set some global variables.
;
FILENAME1  = "091732115_vis.nc"
FIELDNAME1 = "image"
TIME1      = 0
TITLE1     = ""+FILENAME1+" "+FIELDNAME1+""

;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; Open output file and define color table
  wks = gsn_open_wks("png", "native")   ; send graphics to PNG file

; Increase the workspace to avoid an error message.
  setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 671088640
  end setvalues

; Open NetCDF file and read variable.
  file1  = addfile(FILENAME1,"r")
  field1 = file1->$FIELDNAME1$(TIME1,::-1,:)

  numx = 1 ; make these into integers instead of shorts
  numy = 1
  numx = file1->Nx
  numy = file1->Ny

;
; Set up plot resources.
;
  res = True

  res@gsnMaximize                       = True

; Plot first field

  res@cnFillOn                          = True
  res@cnFillMode                        = "RasterFill"
  res@cnFillPalette                     = "gui_default"
  res@cnLinesOn                         = False
  res@cnLineLabelsOn                    = False
  res@pmLabelBarOrthogonalPosF          = -0.03  ; Move labelbar up

  res@tfDoNDCOverlay                    = True   ; This is native data, so
                                                 ; no transformation needs
                                                 ; to happen.

  res@mpDataBaseVersion                 = "MediumRes"
  res@mpDataSetName                     = "Earth..4"
  res@mpDataResolution                  = "FinestResolution"

  res@mpProjection                      = "LambertConformal"
  res@mpLambertParallel1F               = file1->Latin
  res@mpLambertParallel2F               = file1->Latin
  res@mpLambertMeridianF                = file1->Lov

  res@mpLimitMode                       = "Corners"
  res@mpLeftCornerLatF                  = file1->La1
  res@mpLeftCornerLonF                  = file1->Lo1
  res@mpRightCornerLatF                 = 55.481804
  res@mpRightCornerLonF                 = -57.379398

  res@mpOutlineBoundarySets             = "GeophysicalAndUSStates"
  res@mpGridAndLimbOn                   = True
  res@mpUSStateLineThicknessF           = 2.0
  res@mpNationalLineThicknessF          = 2.0
  res@mpGeophysicalLineThicknessF       = 2.0
  res@mpPerimOn                         = True

  res@tiMainString                      = "Plotting data in native projection"
  res@tiMainFontHeightF                 = 0.015

  plot = gsn_csm_contour_map(wks, field1, res)

;
; Retrieve width and height so we can use these to convert
; NDC coordinates to lat/lon coordinates.
;
  getvalues plot
    "vpXF" : x
    "vpYF" : y
    "vpWidthF" : w
    "vpHeightF" : h
  end getvalues
  print("x: " + x + " y: " + y + " w: " + w + " h: " + h)

;
; Calculate some equally-spaced NDC values starting at one corner
; of the plot, and going to the other end.
;
  ndcx = fspan(x, x + w,numx)
  ndcy = fspan(y-h,y,numy)

;
; Nudge the end points just a bit to ensure they are inside the boundary
;
  eps          = 5e-7
  ndcx(0)      = ndcx(0) + eps
  ndcx(numx-1) = ndcx(numx -1) - eps
  ndcy(0)      = ndcy(0) + eps
  ndcy(numy-1) = ndcy(numy -1) - eps

;
; Create some arrays to hold the lat/lon values we want to calculate.
;
  print( "calculating lat/lon fields")
  tndcy  = new(numx, float)
  outlat = new((/numy,numx/), float)
  outlon = new((/numy,numx/), float)

;
; For each latitude value, calculate the latitude values for that row.
;
  do i = 0, numy-1
     tndcy = ndcy(i)
     ndctodata(plot,ndcx,tndcy,outlon(i,:),outlat(i,:))
  end do
;
;  print("min/max calculated longitude values: " + min(outlon) +  \
;        " " + max(outlon))
;  print("min/max calculated latitude values: " + min(outlat) + \
;        " " + max(outlat))
;  print("left corner lat/lon " + file1->La1 + " " + file1->Lo1)
;  print("right corner lat/lon " + res@mpRightCornerLatF + " " + \
;        res@mpRightCornerLonF)

;
; Now plot using the newly calculated 2D coordinates in another projection,
; in order to demonstrate their correctness.
;
  res@mpProjection                    = "Orthographic"
  res@mpCenterLonF                    = -100
  res@mpCenterLatF                    = 40

  res@mpLimitMode                     = "Corners"
  res@mpLeftCornerLatF                = 0
  res@mpLeftCornerLonF                = -135
  res@mpRightCornerLatF               = 50
  res@mpRightCornerLonF               = -5

  res@trGridType                      = "TriangularMesh"
  res@tfDoNDCOverlay                  = False ; Use lat/lon arrays to do
                                              ; the transformation on the map.

  res@gsnAddCyclic = False
  res@sfXArray = outlon    ; Here are the coordinate arrays.
  res@sfYArray = outlat

  res@tiMainString            = "Plotting data in non-native projection"

  plot = gsn_csm_contour_map(wks, field1, res)
  
;
; Write to NetCDF file if desired.
;
;  system("rm -f latlon.nc")
;  out = addfile("latlon.nc","c")
;  outlon@long_name = "longitude"
;  outlon@units = "degrees_east"
;  outlat@long_name = "latitude"
;  outlat@units = "degrees_north" 
;  out->lon = outlon
;  out->lat = outlat

end
