;----------------------------------------------------------------------
; This script creates an animation of the temperature variable
; across every 24 timesteps (the first hour of every day).
;
; If first creates PostScript file, then converts this to an 
; animation using the "convert" tool from ImageMagick. 
; See the "system" call at the end of this script.
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"


begin
;---Open file and read data
  filename = "ForcT.DAT_france_0001.nc"
  f        = addfile (filename,"r")

; 
; The time values drop unexpectedly to 0 after about
; index 2991, so account for that here.
;
  ii = ind(f->time.ne.0)              ; 2992 valid values (out of 8760)
  t        = f->T(ii,:,:)             ; (2992, 134, 143)
  lat2d    = f->lat                   ; (y,x)
  lon2d    = f->lon                   ; (y,x)
  lc       = f->Lambert_Conformal     ; contains map projection information
  nlat     = dimsizes(lat2d(:,0))     ; Get lat dimension size
  mlon     = dimsizes(lon2d(0,:))     ; Get lon dimension size
  date     = cd_string(t&time, "%D-%c %Y (%HH)" )  ; 03-Oct 2000 (00H)
  ndate    = dimsizes(date)

;
; There appear to be a bunch of values equal to 0.0 which
; really should be missing?  Fix that here.
;
  printMinMax(t,0)      ; Before
  t = where(t.eq.0,t@_FillValue,t)
  printMinMax(t,0)      ; After

;---Start the graphics
  ps_filename_prefix = get_script_prefix_name()
  ps_filename        = ps_filename_prefix + ".ps"
  wks = gsn_open_wks("ps",ps_filename_prefix)

;---Retrieve a color table so we can subset it later
  cmap = read_colormap_file("WhiteBlueGreenYellowRed")   ; 254 x 4

  res              = True

  res@gsnMaximize  = True                      ; Maximize size of plot

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Data is not global, don't add lon cyclic pt

;---Use projection information on file
  res@mpProjection          = "LambertConformal"
  res@mpLambertParallel1F   = lc@standard_parallel(0)
  res@mpLambertParallel2F   = lc@standard_parallel(1)
  res@mpLambertMeridianF    = lc@longitude_of_central_meridian

;---Zoom in on map
  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)

  res@mpFillOn              = False             ; Turn off map fill
  res@mpDataBaseVersion     = "MediumRes"       ; default is "LowRes"
  res@mpOutlineBoundarySets = "AllBoundaries"   ; Draw countries
  res@mpDataSetName         = "Earth..4"        ; Better outlines
 
  res@cnFillOn              = True        ; Turn on contour fill
  res@cnLinesOn             = False       ; Turn off contour lines
  res@cnFillPalette         = cmap(23:,:)  ; Skip first 23 colors

  res@pmTickMarkDisplayMode = "Always"         ; turn on "nice" tickmarks
  res@lbOrientation         = "Vertical"       ; vertical labelbar
;
; Select nice contour levels to use across whole dataset.
; This is important if you are going to create an animation.
;
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 282
  res@cnMaxLevelValF       = 300
  res@cnLevelSpacingF      = 1
 
;---Loop across each 24 hours and create a plot.
  do nt=12,ndate-1,24
    print("date = " + date(nt))
    res@tiMainString = date(nt)
    plot = gsn_csm_contour_map(wks,t(nt,:,:),res)
  end do

;---Create an animated GIF using "convert"
  delete(wks)    ; Make sure PS file is closed
  print("Creating an animated GIF...")
  system("psplit " + ps_filename)
  system("convert -rotate -90 -delay 25 pict0*.ps " + \
          ps_filename_prefix + ".gif")
  system("/bin/rm pict0*.ps")

end
