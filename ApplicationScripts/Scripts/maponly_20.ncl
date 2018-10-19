;================================================;
;  maponly_20.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing a map using the high resolution map outlines
;   - Drawing a map using different resolutions within the high-res map database
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
;================================================;

begin
;---Check if RANGS/GSHHS (HighRes) database is available.
  rangs_dir  = ncargpath("rangs")
  rangs_file = "gshhs(0).rim"
  if(.not.fileexists(rangs_dir + "/" + rangs_file)) then
     print("Sorry, this example only works with the high-res map database.")
     print("See http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml for")
     print("information on downloading this database.")
     exit
  end if

  wks = gsn_open_wks("png","maponly")  ; send graphics to PNG file

;
; Resolutions we can use with the HighRes map database.
;
; You should only use the Fine or Finest ones if you are
; zoomed in pretty far on the map. They can take a long
; time to draw!
;
;  resltn = (/"Coarsest","Coarse","Medium","Fine","Finest"/)
  resltn = (/"Coarsest","Medium","Fine"/)

;
; Set up some map resources.
;
  mpres                       = True
  mpres@gsnMaximize           = True
  mpres@mpFillOn              = False
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLonF             =   4
  mpres@mpMaxLonF             =  20
  mpres@mpMinLatF             =  55
  mpres@mpMaxLatF             =  70
  mpres@pmTickMarkDisplayMode = "Always"
  mpres@mpDataBaseVersion     = "HighRes"    

;
; Loop through the resolutions and draw a map with each one
; for  comparison.
;
  do i=0,dimsizes(resltn)-1
    if(any(resltn(i).eq.(/"Fine","Finest"/))) then
      print("Warning: this map may take awhile to draw.")
    end if
    mpres@tiMainString = "resolution: " + resltn(i)
    mpres@mpDataResolution = resltn(i)
    map = gsn_csm_map(wks,mpres)
  end do

end
