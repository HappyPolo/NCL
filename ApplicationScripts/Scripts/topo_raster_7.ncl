;----------------------------------------------------------------------
; topo_raster_7.ncl
;
; Concepts illustrated:
;   - Drawing a topographic map using 2' data
;   - Zooming in on a topographic map
;   - Creating a greyscale color map
;   - Overlaying WRF "dbz" on a topographic map
;   - Using "MeshFill" and "RasterFill" for faster contouring
;   - Using cnFillPalette to assign a color palette to contours
;   - Making a contour fill color transparent
;   - Setting land fill to transparent
;   - Creating animations
;----------------------------------------------------------------------
; This example is identical to topo_7.ncl, except the reflectivity
; values are drawn as raster filled contours instead of smooth 
; contours. The point of this example is to illustrate a quirk of
; using raster fill with transparency. See "cmap_r" below.
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;
; If you set ANIMATE to True, can convert the "topo.ps" to an
; mpeg animated file using ImageMagick's "convert" tool:
;
;    system("convert topo.ps topo.mpg")
;
; There are many options for looping, delay, image quality, etc.
;
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; This function returns a greyscale color map
;----------------------------------------------------------------------
function gist_gray()
local cmap1d
begin
  cmap1d = (/1.000000,0.000000,0.003922,0.011765,0.019608,0.027451,\
             0.035294,0.043137,0.050980,0.058824,0.066667,0.070588,\
             0.082353,0.086275,0.098039,0.101961,0.113725,0.117647,\
             0.129412,0.137255,0.141176,0.152941,0.160784,0.168627,\
             0.172549,0.184314,0.192157,0.200000,0.203922,0.215686,\
             0.223529,0.231373,0.235294,0.247059,0.254902,0.262745,\
             0.270588,0.278431,0.286275,0.290196,0.301961,0.309804,\
             0.317647,0.325490,0.333333,0.341176,0.349020,0.352941,\
             0.364706,0.372549,0.380392,0.388235,0.396078,0.403922,\
             0.411765,0.415686,0.427451,0.435294,0.443137,0.450980,\
             0.458824,0.466667,0.474510,0.478431,0.490196,0.498039,\
             0.505882,0.513725,0.521569,0.529412,0.537255,0.545098,\
             0.552941,0.560784,0.568627,0.576471,0.584314,0.588235,\
             0.600000,0.607843,0.615686,0.623529,0.631373,0.639216,\
             0.647059,0.654902,0.662745,0.670588,0.678431,0.686275,\
             0.694118,0.701961,0.709804,0.713725,0.725490,0.733333,\
             0.741176,0.749020,0.756863,0.764706,0.772549,0.780392,\
             0.788235,0.796078,0.803922,0.811765,0.819608,0.827451,\
             0.835294,0.839216,0.850980,0.858824,0.866667,0.874510,\
             0.882353,0.890196,0.898039,0.905882,0.913725,0.921569,\
             0.929412,0.937255,0.945098,0.952941,0.960784,0.964706,\
             0.976471,0.984314,0.992157,1.000000/)
  ncolors = dimsizes(cmap1d)

;---Greyscale maps are RGB triplets with the same values
  cmap2d        = new((/ncolors,4/),typeof(cmap1d))
  cmap2d(:,0:2) = conform_dims((/ncolors,3/),cmap1d,0)
  cmap2d(:,3)   = 1.000000    ; make all colors fully opaque
  return(cmap2d)
end

;----------------------------------------------------------------------
; This function creates a topo map using a 2' topographic file read in
; from a NetCDF file, and map limits read in from a WRF output file.
;----------------------------------------------------------------------
undef("create_topo_map")
function create_topo_map(wfile,wks,lat,lon)
local topo_file, a, elev, cmap, res
begin
;---Subsetting the data is not necessary, but it will make plotting go much faster.
  topo_file = "ETOPO2_GLOBAL_2_ELEVATION.nc"
  a         = addfile(topo_file,"r")
  elev      = short2flt(a->ELEV({min(lat):max(lat)},{min(lon):max(lon)}))
;
; Set all values below -50 to missing, hence removing all
; the ocean elevation values. The ocean will be filled in
; a light blue (see mpOceanFillColor below).
;
  elev = where(elev.lt.-50.,elev@_FillValue,elev)

;---Will use this later for coloring the contours
  cmap = read_colormap_file("OceanLakeLandSnow")

;---Set some resources for contouring and mapping
  res                    = True

  res@gsnMaximize        = True         ; maximize plot in frame

  res@gsnDraw            = False
  res@gsnFrame           = False

  res@cnFillOn           = True         ; turn on contour fill
  res@cnFillMode         = "MeshFill"   ; for faster draw
  res@cnFillPalette      = cmap(2:,:)
 
  res@cnLinesOn          = False        ; turn off contour lines
  res@cnLineLabelsOn     = False        ; turn off line labels
  res@cnInfoLabelOn      = False        ; turn off info label
  res@lbBoxLinesOn       = False        ; turn off labelbar box lines

;---Pick "nice" contour levels
  mnmxint = nice_mnmxintvl( min(elev), max(elev), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 
  res@lbLabelBarOn         = False
                                             ; by choosing a smaller spacing.
;---Zoom in on map
  res = wrf_map_resources(wfile,res)
  delete(res@start_lat)
  delete(res@start_lon)
  delete(res@end_lat)
  delete(res@end_lon)
  delete(res@mpNestTime)

;---Change some resources set by wrf_map_resources
  res@mpUSStateLineThicknessF     = 1.5
  res@mpNationalLineThicknessF    = 1.5
  res@mpLimbLineThicknessF        = 1.5
  res@mpGeophysicalLineThicknessF = 1.5
  res@mpUSStateLineColor          = "black"
  res@mpPerimLineColor            = "black"
  res@mpNationalLineColor         = "black"
  res@mpLimbLineColor             = "black"
  res@mpGridLineColor             = "black"
  res@mpGeophysicalLineColor      = "black"

;--Add some map fill to make sure we only see terrain over land.
  res@mpFillOn             = True
  res@mpLandFillColor      = "transparent"
  res@mpOceanFillColor     = "lightblue"

;---Make sure map fill is drawn after contour fill and map outlines are drawn last
  res@mpFillDrawOrder      = "Draw"
  res@cnFillDrawOrder      = "PreDraw"
  res@mpOutlineDrawOrder   = "PostDraw"

  res@gsnAddCyclic         = False           ; don't add longitude cyclic point

  res@gsnLeftString         = ""       ; turn off subtitles
  res@gsnRightString        = ""

;---Create map and return it.
  plot = gsn_csm_contour_map(wks,elev,res)
  return(plot)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  ANIMATE = False    ; Whether to animate across levels, or create one plot

;---Open file. You may need to include ".nc" at the end.
  wfile = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")

;---Read variables directly (can also use "wrf_user_getvar")
  lat = wfile->XLAT(0,:,:)                ; latitude
  lon = wfile->XLONG(0,:,:)               ; longitude
  znu = wfile->ZNU                        ; eta values
  dbz = wrf_user_getvar(wfile,"dbz",0)    ; reflectivity
  nlev = dimsizes(znu(0,:))

;---Debug information
  print("------------------------------------------")
  printMinMax(dbz,0)

  wks = gsn_open_wks("png","topo_raster")         ; send graphics to PNG file

;
; Get a greyscale color map to use for dbz, and set the first color 
; to transparent. Note that when doing raster fill, there's a 
; quirk with using transparent colors. It's not enough to just set
; the alpha value of the color map to transparent. You must set the
; color to black (rgb=0.,0.,0.) *and* set the alpha value to 0.0
;
  cmap_r              = gist_gray()
  cmap_r(0,:)         = 0.0             ; Set to black and make fully transparent

;---Set some contour resources
  res                       = True
  res@gsnDraw               = False         ; turn off draw
  res@gsnFrame              = False         ; turn off frame

  res@cnFillOn              = True          ; turn on contour fill
  res@cnLinesOn             = False         ; turn off contour lines
  res@cnLineLabelsOn        = False         ; turn off contour line labels
  res@cnFillDrawOrder       = "PostDraw"
  res@cnFillMode            = "RasterFill"

;---turn off subtitles
  res@gsnLeftString         = ""       
  res@gsnRightString        = ""
  res@gsnCenterString       = ""
  res@tiMainFontHeightF     = 0.02

;---labelbar stuff
  res@lbLabelFontHeightF       = 0.010    ; make labels smaller
  res@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
  res@pmLabelBarHeightF        =  0.10    ; make labelbar thinner

;---Necessary to overlay data on map correctly.
  res@sfXArray              = lon
  res@sfYArray              = lat
  res@gsnAddCyclic          = False

;---Define contour levels and the color map to use for them
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = ispan(-28,40,2)
  res@cnFillPalette         = cmap_r
  res@cnLabelBarEndStyle    = "ExcludeOuterBoxes"

  if(ANIMATE) then
    nl = nlev-1
    print("There are " + nlev + " levels.")
  else
    nl = 0
  end if

  do n=0,nl
    topo_map = create_topo_map(wfile,wks,lat,lon)   ; Create a topo map 
    if(min(dbz(n,:,:)).eq.max(dbz(n,:,:)))then
      print("Skipping level(" + n + ") = " + znu(0,n) + "...values are constant.")
      continue
    end if
    print("Creating plot for level(" + n + ") = " + znu(0,n))

    res@tiMainString = "Reflectivity (dBZ) at level = " + znu(0,n)

;---Create the contour plot and overlay it on topo map
    dbz_plot = gsn_csm_contour(wks,dbz(n,:,:),res)
    overlay(topo_map,dbz_plot)

;---Drawing the topo map will also draw the contours
    maximize_output(wks,True)
  end do
;
; Here's the conversion to an mpeg file, if desired.
;
  if(ANIMATE) then
    delete(wks)   ; close the topo.ps file
    system("convert topo.ps topo.mpg")
  end if
end
