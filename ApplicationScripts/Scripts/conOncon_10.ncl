;*************************************************
; conOncon_10.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;   - Overlaying WRF precipitation on terrain map using gsn_csm_xxx functions
;   - Changing the size of a PNG image
;   - Creating two contour plots with two sets of filled contours
;   - Creating a color map using RGB triplets
;   - Creating a color map using RGBA quadruplets
;   - Explicitly setting contour levels
;   - Adding a title to a labelbar
;   - Drawing fully transparent filled contours
;   - Creating horizontal and vertical labelbars
;   - Adding a vertical title to a labelbar
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; This function returns an earth color palette
;----------------------------------------------------------------------
function earth_pal()
local cmap
begin
  cmap = (/ (/ 25,  25, 255/), (/ 20, 170,  42/), (/ 28, 175,  35/), \
            (/ 36, 179,  29/), (/ 44, 184,  22/), (/ 51, 189,  16/), \
            (/ 59, 194,   9/), (/ 67, 198,   2/), (/ 70, 200,   0/), \
            (/ 71, 200,   1/), (/ 72, 199,   1/), (/ 73, 199,   2/), \
            (/ 75, 198,   2/), (/ 76, 198,   3/), (/ 77, 197,   3/), \
            (/ 78, 197,   4/), (/ 79, 197,   4/), (/ 80, 196,   5/), \
            (/ 82, 196,   5/), (/ 84, 195,   6/), (/ 85, 194,   7/), \
            (/ 86, 194,   7/), (/ 87, 194,   8/), (/ 89, 193,   8/), \
            (/ 90, 193,   9/), (/ 91, 192,   9/), (/ 92, 192,  10/), \
            (/ 93, 191,  10/), (/ 94, 191,  11/), (/ 95, 191,  11/), \
            (/ 97, 190,  12/), (/ 98, 190,  12/), (/ 99, 189,  13/), \
            (/100, 189,  13/), (/101, 188,  14/), (/102, 188,  14/), \
            (/104, 188,  15/), (/105, 187,  15/), (/106, 187,  16/), \
            (/107, 186,  16/), (/108, 186,  17/), (/109, 185,  17/), \
            (/111, 185,  18/), (/112, 185,  18/), (/113, 184,  19/), \
            (/114, 184,  19/), (/115, 183,  20/), (/116, 183,  20/), \
            (/118, 182,  21/), (/119, 182,  22/), (/120, 182,  22/), \
            (/121, 181,  23/), (/122, 181,  23/), (/123, 180,  24/), \
            (/124, 180,  24/), (/126, 180,  25/), (/127, 179,  25/), \
            (/128, 179,  26/), (/129, 178,  26/), (/130, 178,  27/), \
            (/131, 177,  27/), (/133, 177,  28/), (/134, 177,  28/), \
            (/135, 176,  29/), (/136, 176,  29/), (/137, 175,  30/), \
            (/138, 175,  30/), (/140, 174,  31/), (/141, 174,  31/), \
            (/142, 174,  32/), (/143, 173,  32/), (/144, 173,  33/), \
            (/145, 172,  33/), (/146, 172,  34/), (/148, 171,  34/), \
            (/149, 171,  35/), (/150, 171,  35/), (/151, 170,  36/), \
            (/152, 170,  36/), (/153, 169,  37/), (/155, 169,  37/), \
            (/156, 168,  38/), (/157, 168,  38/), (/158, 168,  39/), \
            (/159, 167,  39/), (/160, 167,  40/), (/162, 166,  40/), \
            (/163, 166,  41/), (/164, 165,  42/), (/165, 165,  42/), \
            (/165, 165,  43/), (/165, 165,  44/), (/166, 166,  45/), \
            (/166, 166,  46/), (/166, 166,  47/), (/166, 166,  48/), \
            (/166, 166,  49/), (/167, 167,  50/), (/167, 167,  51/), \
            (/167, 167,  52/), (/167, 167,  53/), (/168, 168,  54/), \
            (/168, 168,  55/), (/168, 168,  56/), (/168, 168,  57/), \
            (/169, 169,  58/), (/169, 169,  59/), (/169, 169,  60/), \
            (/169, 169,  61/), (/169, 169,  62/), (/170, 170,  63/), \
            (/170, 170,  64/), (/170, 170,  65/), (/170, 170,  66/), \
            (/171, 171,  67/), (/171, 171,  68/), (/171, 171,  69/), \
            (/171, 171,  70/), (/171, 171,  71/), (/172, 172,  72/), \
            (/172, 172,  73/), (/172, 172,  74/), (/172, 172,  75/), \
            (/172, 172,  76/), (/173, 173,  77/), (/173, 173,  78/), \
            (/173, 173,  79/), (/173, 173,  80/), (/174, 174,  81/), \
            (/174, 174,  82/), (/174, 174,  83/), (/174, 174,  84/), \
            (/175, 175,  85/), (/175, 175,  86/), (/175, 175,  87/), \
            (/175, 175,  88/), (/175, 175,  89/), (/176, 176,  90/), \
            (/176, 176,  91/), (/176, 176,  92/), (/176, 176,  93/), \
            (/177, 177,  94/), (/177, 177,  95/), (/177, 177,  96/), \
            (/177, 177,  97/), (/177, 177,  98/), (/178, 178,  99/), \
            (/178, 178, 100/), (/178, 178, 101/), (/178, 178, 102/), \
            (/178, 178, 103/), (/179, 179, 104/), (/179, 179, 105/), \
            (/179, 179, 106/), (/179, 179, 107/), (/180, 180, 108/), \
            (/180, 180, 109/), (/180, 180, 110/), (/180, 180, 111/), \
            (/181, 181, 112/), (/181, 181, 113/), (/181, 181, 114/), \
            (/181, 181, 115/), (/181, 181, 116/), (/182, 182, 117/), \
            (/182, 182, 118/), (/182, 182, 119/), (/182, 182, 120/), \
            (/183, 183, 121/), (/183, 183, 122/), (/183, 183, 123/), \
            (/183, 183, 124/), (/183, 183, 125/), (/184, 184, 126/), \
            (/184, 184, 127/), (/184, 184, 128/), (/184, 184, 129/), \
            (/184, 184, 130/), (/185, 185, 131/), (/185, 185, 132/), \
            (/185, 185, 133/), (/185, 185, 134/), (/185, 185, 135/), \
            (/186, 186, 135/), (/186, 186, 136/), (/186, 186, 137/), \
            (/186, 186, 138/), (/187, 187, 139/), (/187, 187, 140/), \
            (/187, 187, 141/), (/187, 187, 142/), (/187, 187, 143/), \
            (/188, 188, 144/), (/188, 188, 145/), (/188, 188, 146/), \
            (/188, 188, 147/), (/188, 188, 148/), (/189, 189, 149/), \
            (/189, 189, 150/), (/189, 189, 151/), (/189, 189, 152/), \
            (/190, 190, 153/), (/190, 190, 154/), (/190, 190, 155/), \
            (/190, 190, 156/), (/190, 190, 157/), (/191, 191, 158/), \
            (/191, 191, 159/), (/191, 191, 160/), (/191, 191, 161/), \
            (/191, 191, 162/), (/192, 192, 162/), (/192, 192, 163/), \
            (/192, 192, 164/), (/192, 192, 165/), (/193, 193, 166/), \
            (/193, 193, 167/), (/193, 193, 168/), (/193, 193, 169/), \
            (/193, 193, 170/), (/194, 194, 171/), (/194, 194, 172/), \
            (/194, 194, 173/), (/194, 194, 174/), (/194, 194, 175/), \
            (/195, 195, 176/), (/195, 195, 177/), (/195, 195, 178/), \
            (/195, 195, 179/), (/196, 196, 180/), (/196, 196, 181/), \
            (/196, 196, 182/), (/196, 196, 183/), (/196, 196, 184/), \
            (/197, 197, 185/), (/197, 197, 186/), (/197, 197, 187/), \
            (/197, 197, 188/), (/197, 197, 189/), (/198, 198, 189/), \
            (/198, 198, 190/), (/198, 198, 191/), (/198, 198, 192/), \
            (/199, 199, 193/), (/199, 199, 194/), (/199, 199, 195/), \
            (/199, 199, 196/), (/199, 199, 197/), (/200, 200, 198/), \
            (/200, 200, 199/), (/200, 200, 200/) /)/255.
  return(cmap)
end

;----------------------------------------------------------------------
; This function returns a precipitation color palette
;----------------------------------------------------------------------
function precip_pal()
local cmap, ncolors
begin
  cmap = (/ (/242, 242, 242/), (/154, 192, 205/), (/178, 223, 238/), \
            (/191, 239, 255/), (/  0, 235, 235/), (/  0, 163, 247/), \
            (/  0, 255,   0/), (/  0, 199,   0/), (/  0, 143,   0/), \
            (/  0,  63,   0/), (/255, 255,   0/), (/255, 143,   0/), \
            (/255,   0,   0/), (/215,   0,   0/), (/191,   0,   0/), \
            (/255,   0, 255/), (/155,  87, 203/), (/ 92,  52, 176/) /)

;---Create RGBA array from RGB array so we can set a couple colors to transparent 
   ncolors          = dimsizes(cmap(:,0))
   cmap_rgba        = new((/ncolors,4/),float)
   cmap_rgba(:,0:2) = cmap/255.
   cmap_rgba(:,3)   = 1.0     ; set all colors to fully opaque
   cmap_rgba(0:1,3) = 0.0     ; set first two colors to fully transparent
   return(cmap_rgba)
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;
; Open file and get variables.
;
  a = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")

;
; Terrain
;
  ter = wrf_user_getvar(a,"HGT",0)
  ter@description = "Terrain Height"
  ter@units       = "m"
;
; Get non-convective, convective
; Calculate total precipitation
;
  scale = 6.       ; Artificial scale factor to see all colors
  rain_exp = wrf_user_getvar(a,"RAINNC",-1) / 25.4
  rain_con = wrf_user_getvar(a,"RAINC", -1) / 25.4
  rain_tot = (rain_exp + rain_con) * scale
  rain_tot@description = "Total Precipitation (inches)"

;---Read the lat/lon values and attach to variables to be plotted.
  lat2d = a->XLAT(0,:,:)
  lon2d = a->XLONG(0,:,:)

  rain_tot@lat2d = lat2d   ; Attach to data so overlays
  rain_tot@lon2d = lon2d   ; will be done properly.
  ter@lat2d      = lat2d
  ter@lon2d      = lon2d

  nlat = dimsizes(lat2d(:,0))
  nlon = dimsizes(lon2d(0,:))


; Define contour levels here so we can determine up front
; what the merged color maps should be.

  precip_levels = (/ .01, 0.25, 0.50, 0.75, \
                    1.00, 1.25, 1.50, 1.75, \
                    2.00, 2.25, 2.50, 2.75, \
                    3.00, 3.25, 3.50, 3.75, \
                    4.00, 4.25, 4.50, 4.75, \
                    5.00 /)

  ter_levels = (/ .01, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, \
                   15, 16 /) * 100.

  wtype          = "png"
  wtype@wkWidth  = 1500     ; Increase size for a slightly
  wtype@wkHeight = 1500     ; better looking PNG.
  wks = gsn_open_wks(wtype,"conOncon")    ; Send graphics to PNG file

;
; Set up resource list that will be shared between the
; two wrf_contour calls.
;
  res                      = True

  res@vpXF                 = 0.03   ; Set X,Y location of upper left
  res@vpYF                 = 0.88   ; of plot
  res@vpWidthF             = 0.80   ; Set width

  res@gsnAddCyclic         = False    ; Don't add lon cyclic point

  res@gsnDraw              = False
  res@gsnFrame             = False
  res@gsnRightString       = ""
  res@gsnLeftString        = ""

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnFillOn             = True
  res@cnLinesOn            = False
;
; Generate plot of terrain for background.
;
; First set up resource list specific to terrain plot.
;
  opts_ter                        = res
  opts_ter@cnLevels               = ter_levels
  opts_ter@cnFillPalette          = earth_pal()

  opts_ter@lbTitleString          = "Terrain (m)"
  opts_ter@lbTitlePosition        = "Bottom"  
  opts_ter@lbTitleFontHeightF     = 0.01
  opts_ter@lbLabelFontHeightF     = 0.01
  opts_ter@pmLabelBarWidthF       = 0.6
  opts_ter@pmLabelBarHeightF      = 0.1

  opts_ter = wrf_map_resources(a,opts_ter)

;---If you want to see what wrf_map_resources does, then uncomment the next line.
;  print(opts_ter)

;---wrf_map_resources sets these to gray.
  opts_ter@mpOutlineBoundarySets       = "AllBoundaries"
  opts_ter@mpGeophysicalLineColor      = "Black"
  opts_ter@mpNationalLineColor         = "Black"
  opts_ter@mpUSStateLineColor          = "Black"
  opts_ter@mpGridLineColor             = "Black"
  opts_ter@mpLimbLineColor             = "Black"
  opts_ter@mpPerimLineColor            = "Black"

  map_terrain = gsn_csm_contour_map(wks,ter,opts_ter)

; Create terrain contours (no drawing done yet).

; Plotting options for precipitation
  opts_r                      = res

  opts_r@cnLevels             = precip_levels
  opts_r@cnFillPalette        = precip_pal()

  opts_r@cnSmoothingOn        = True
  opts_r@cnSmoothingDistanceF = .005

  opts_r@lbOrientation        = "vertical"
  opts_r@lbLabelFontHeightF   = 0.01

  opts_r@lbTitleString            = "Total Precipitation"
  opts_r@lbTitleDirection         = "Down"
  opts_r@lbTitleFontHeightF       = 0.01
  opts_r@lbTitleJust              = "CenterRight"
  opts_r@lbTitlePosition          = "Right"
  opts_r@lbTitleOffsetF           = 0.07

  opts_r@pmLabelBarWidthF     = 0.1
  opts_r@pmLabelBarHeightF    = 0.6
  opts_r@pmLabelBarOrthogonalPosF = 0.01

; Total Precipitation (color fill)
  contour_tot = gsn_csm_contour(wks, rain_tot(0,:,:), opts_r)

;---Overlay the two plots.
  overlay(map_terrain,contour_tot)

  draw(map_terrain)
  frame(wks)
end
