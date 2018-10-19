;----------------------------------------------------------------------
; dataonmap_nonnative_4.ncl
;
; Concepts illustrated:
;   - Drawing contours and vectors over a map using something other than the native projection
;   - Making the first color in a color map partially transparent
;   - Explicitly setting contour levels
;   - Zooming in on a particular area on a map
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
;    http://www.ncl.ucar.edu/Applications/Data/#grb
;
; wget http://www.ncl.ucar.edu/Applications/Data/ruc2.bgrb.20020418.i12.f00.grb
;----------------------------------------------------------------------
; See example dataonmap_native_4.ncl for plotting this data in its
; native map projection.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;-Open file and read data
  fname = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fname, "r")

  u   = f->U_GRD_252_HTGL
  v   = f->V_GRD_252_HTGL
  hgt = f->HGT_252_HYBL(1,:,:)

;---The lat/lon arrays are required for plotting data in non-native projection
  hgt@lat2d = f->gridlat_252
  hgt@lon2d = f->gridlon_252
  u@lat2d   = hgt@lat2d
  u@lon2d   = hgt@lon2d
  v@lat2d   = hgt@lat2d
  v@lon2d   = hgt@lon2d

  printVarSummary(hgt)
  printVarSummary(u)
  printVarSummary(v)

;---Create plot
  wks = gsn_open_wks("png","dataonmap_nonnative")      ; open a workstation

;--Read color map and make the first color (blue) slightly transparent
  cmap      = read_colormap_file("OceanLakeLandSnow")
  cmap(:,3) = 0.5     ; half transparency

;---Set resources for contour/map plot
  res                       =  True              ; plot mods desired
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@gsnMaximize           = True

  res@cnFillOn              = True            ; color plot desired
  res@cnFillPalette         = cmap
  res@cnLinesOn             = False           ; turn off contour lines
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = (/22,25,50,75,100,150,200,250,300,350,400,\
                                450,500,550,600,650,700,750,800,850,900,\
                                950,1000,1250,1500,1750,2000,2250,2500,\
                                2750,3000,3250/)

  res@lbOrientation         = "Vertical"

  res@gsnAddCyclic          = False       ; regional data 

  res@mpMinLatF             = min(hgt@lat2d)-1    ; Give it a little bit of
  res@mpMaxLatF             = max(hgt@lat2d)+1    ; margin
  res@mpMinLonF             = min(hgt@lon2d)-1
  res@mpMaxLonF             = max(hgt@lon2d)+1

  res@mpDataBaseVersion     = "MediumRes"
  res@pmTickMarkDisplayMode = "Always"
 
  res@tiMainString   = "GRIB data on a non-native projection"
  res@pmTitleZone    = 2   ; move main title down.
  res@gsnLeftString  = ""
  res@gsnRightString = ""

  map = gsn_csm_contour_map(wks,hgt,res)
  
;---Set resources for vector plot
  vcres                 = True
  vcres@gsnDraw         = False
  vcres@gsnFrame        = False

  vcres@vcRefMagnitudeF = 10.0             ; define vector ref mag
  vcres@vcRefLengthF    = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle    = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF  = 0.017            ; thin vectors
  vcres@vcLineArrowThicknessF = 2.0

  vcres@gsnLeftString   = ""
  vcres@gsnRightString  = ""

  vectors = gsn_csm_vector(wks,u,v,vcres)

;---Overlay vectors on contour/map plot and draw everything
  overlay(map,vectors)
  draw(map)
  frame(wks)
end
