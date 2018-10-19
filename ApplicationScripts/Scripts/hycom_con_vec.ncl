;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
external SUBS "./pixel.so"
load "./pixel_interp.ncl"
;*****************************************************
begin

;*****************************************************
; User's parameters
;*****************************************************
date       = "0021_016_00"           ; date
file_name  = "3ds"                   ; variable in file name
var_name   = "layer_salinity"        ; scalar field to plot vectors over
colormap   = "BlGrYeOrReVi200"
orient     = "horizontal"            ; style of label bar
LinesOn    = False                   ; turn on contour lines
level      = 0                       ; level to plot for 3D data. Keep 0 for 2D
refvec     = 20                      ; value of reference vector
veccolor   = "white"                 ; choose vector color
refUD      = -0.17                   ; location of ref vector up/down coord
refLR      = 0.1                     ; location of ref vector left/right coord
output     = "ps"                   ; can be "ps","eps","epsi","x11",or "ncgm"
zoom       = False                   ; select sub region?
;*****************************************************
; contour ranges a -1 indicates that NCL will determine the contour range
; these values should be float
;*****************************************************
mincn      = 31                     ; min contour
maxcn      = -1.                     ; max contour
cnint      = 0.1                     ; contour interval
;*****************************************************
; zoom in on region
;*****************************************************
minlat   =  16.
maxlat   =  25.
minlon   = 270.
maxlon   = 290.
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
;*****************************************************
f1    = addfile("./archv."+date+"_"+file_name+".nc","r")
var_x = f1->$var_name$

f2    = addfile("./archv."+date+"_3du.nc","r")
u     = f2->u_velocity

f3    = addfile("./archv."+date+"_3dv.nc","r")
v     = f3->v_velocity
;*****************************************************
;   Create plot
;*****************************************************
 wks  = gsn_open_wks(output, var_name+"_"+date)
 
 gsn_define_colormap(wks,colormap)                  ; choose colormap 
 i = NhlNewColor(wks,0.82,0.82,0.82)                ; add gray to colormap

 res                             = True             ; plot mods desired

 res@cnFillOn                    = True             ; turn on color 
 res@cnLinesOn                   = LinesOn          ; no contour lines
 res@cnFillMode                  = "RasterFill"     ; turn on raster mode
 res@gsnAddCyclic                = False            ; regional data
 res@cnFillDrawOrder             = "PreDraw"        ; draw fill first

 res@cnLevelSelectionMode        = "ManualLevels"   ; set manual contour levels
 if(mincn.ne.-1)then 
   res@cnMinLevelValF            = mincn            ; set min contour level
 end if
 if(maxcn.ne.-1)then
    res@cnMaxLevelValF           = maxcn            ; set max contour level
 end if
 if(cnint.ne.-1)then
   res@cnLevelSpacingF           = cnint            ; contour interval
 end if

 res@gsnSpreadColors             = True             ; use full color map
 res@gsnSpreadColorEnd           = -3               ; don't use added gray
 res@lbOrientation               = orient           ; where draw label bar
 res@lbLabelStride               = 2                ; set default stride
 res@gsnMaximize                 = True             ; maximize plot size
;*****************************************************
 if(zoom.eq.False)then
    minlat                  = min(var_x&Latitude)   ; default dimensions
    minlon                  = min(var_x&Longitude)
    maxlat                  = max(var_x&Latitude)
    maxlon                  = max(var_x&Longitude)
 end if
 res@mpMinLatF              = minlat                ; user provides dimensions
 res@mpMaxLatF              = maxlat
 res@mpMinLonF              = minlon
 res@mpMaxLonF              = maxlon
;*****************************************************
; vector resources
;*****************************************************
 res@gsnScalarContour          = True                ; contours desired
 res@vcGlyphStyle              = "CurlyVector"       ; turn on curley vectors
 res@vcRefMagnitudeF           = refvec              ; define vector ref mag
 res@vcRefLengthF              = 0.045               ; define length of vec ref
 res@vcRefAnnoOrthogonalPosF   = refUD               ; move ref vector
 res@vcRefAnnoParallelPosF     = refLR               ; move ref vector
 res@vcMinDistanceF            = 0.017               ; thin vectors
 res@vcRefAnnoString2          = u@units             ; unit string
 res@vcRefAnnoString2On        = True                ; turn on second string
 res@vcLineArrowColor          = veccolor            ; vector color
 if(veccolor.eq."white")then
    res@vcRefAnnoArrowLineColor   = "black"          ; change ref vector color
    res@vcRefAnnoArrowUseVecColor = False            ; don't vec color for ref
 end if
 if(refUD.ne.1)then
    res@pmLabelBarOrthogonalPosF       = .035        ; move color bar down
 end if
;*****************************************************
; plot labeling
;*****************************************************
 if(isatt(f1,"experiment").eq.True)then                  ; check for experiment
    tmp                          = stringtochar(date)    ; get year from date
    year                         = chartostring(tmp(0:3))
    date                         = f1->date
    res@tiMainString             = f1@experiment+" "+date+" "+ year
 end if
;*****************************************************
; conduct interpolation to finer grid. Although data is originally on a native
; mercator projection, the interpolation is best displayed using a cylindrical
; equidistant projection.
;*****************************************************
  if(dimsizes(dimsizes(var_x)).eq.4)then
     int_x = pixel_interp(var_x(0,level,{minlat:maxlat},\
                                        {minlon:maxlon}))
  else
     int_x = pixel_interp(var_x(0,{minlat:maxlat},\
                                  {minlon:maxlon}))
  end if
  res@mpDataBaseVersion           = int_x@coast  ; set coastline database
;*****************************************************
; adjust colorbar appearance depending on size.
;*****************************************************
 if(maxcn.eq.-1)then
    maxcn = max(int_x)
 end if
 if(mincn.eq.-1)then
    mincn = min(int_x)
 end if
 ncolors = (maxcn-mincn)/cnint
 if(ncolors.gt.50)then
    res@lbBoxLinesOn             = False           ; turn off label bar lines
    res@lbLabelStride            = 10              ; stride on label bar
 end if
;*****************************************************
; note, the gsn_csm templates were originally designed for a global domain.
; when you zoom in too close, the labels become small. we must add some
; resources to adjust for this.
;****************************************************
 if(int_x@labels.eq."blowup")then
     res@txFontHeightF      = 0.014                ; blow up labels 
     res@lbLabelFontHeightF = 0.011                ; label bar label font
 end if

 res@gsnLeftString  = int_x@long_name
 res@gsnRightString = int_x@units
 plot  = gsn_csm_vector_scalar_map_ce(wks,u(level,:,:),v(level,:,:),int_x,res)


end 



