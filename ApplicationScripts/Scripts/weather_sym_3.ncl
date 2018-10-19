;*******************************************
; weather_sym_3.ncl
;
; Concepts illustrated:
;   - Creating dummy data
;   - Drawing wind barbs
;   - Setting parameters for weather routines
;*******************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,"default")  ; "Default" is the NCL default colormap.

;
;  Draw an orthographic map centered at lat/lon = (70.,-10.).
;  Don't advance the frame, since we want to add wind barbs.
;
  mpres              = True
  mpres@gsnFrame     = False
  mpres@gsnMaximize  = True
  mpres@mpProjection = "Orthographic"
  mpres@mpLimitMode  = "LatLon"
  mpres@mpMinLonF    = -40.
  mpres@mpMaxLonF    =  20.
  mpres@mpMinLatF    =  55.
  mpres@mpMaxLatF    =  85.
  mpres@mpCenterLatF =  70.
  mpres@mpCenterLonF = -10.

  map = gsn_csm_map(wks,mpres)

;
;  Draw an array of vertical wind barbs over the above map.
;
  lat = new((/3,2,5/),float)
  lon = new((/3,2,5/),float)
  u   = new((/3,2,5/),float)
  v   = new((/3,2,5/),float)

  lat(0,:,:) = 65
  lat(1,:,:) = 70
  lat(2,:,:) = 75

  do i=0,4
    lon(:,0,i) = -40.+i*5.
    lon(:,1,i) = -15.+i*5.
  end do

  u(:,:,:) =  0.
  v(:,:,:) = 90.

  wmsetp("col", 2)    ; Draw in red.
  wmsetp("wbs", .06)  ; Increase the size of the barb.
  wmbarbmap(wks, lat, lon,  u, v)  ; Plot barbs.
  frame(wks)          ; Advance the frame.
end
