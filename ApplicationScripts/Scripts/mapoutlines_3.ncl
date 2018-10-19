;----------------------------------------------------------------------
;  mapoutlines_3.ncl
;
; Concepts illustrated:
;   - Drawing three different resolutions for map outlines
;  
;----------------------------------------------------------------------
; In order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
; 
; http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;----------------------------------------------------------------------
; Read data
;----------------------------------------------------------------------
  minlon   =   4
  maxlon   =  25
  minlat   =  55
  maxlat   =  70
  filename = ncargpath("data") + "/cdf/uv300.nc"
  a        = addfile(filename,"r")
  u        = a->U(1,:,:)

  wks = gsn_open_wks("png","mapoutlines")  ; send graphics to PNG file

;----------------------------------------------------------------------
; Set some map resources
;----------------------------------------------------------------------
  res                       = True
  
  res@gsnMaximize           = True           ; maximize plot in frame

  res@cnFillOn              = True           ; turn on contour fill
  res@cnLinesOn             = False          ; turn off contour lines
  res@cnLineLabelsOn        = False          ; turn off contour labels
  res@lbLabelBarOn          = False          ; turn off labelbar

  res@mpFillDrawOrder       = "PostDraw"     ; draw map fill last

  res@gsnRightString        = ""             ; turn off special titles
  res@gsnLeftString         = ""

  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = minlat
  res@mpMaxLatF             = maxlat 
  res@mpMinLonF             = minlon
  res@mpMaxLonF             = maxlon

  res@pmTickMarkDisplayMode = "Always"      ; tickmarks for some maps
  res@gsnAddCyclic          = False         ; don't add longitude cyclic point

  dq          = str_get_dq()
  resolutions = (/"Low","Medium","High"/) + "Res"
  do i=0,dimsizes(resolutions)-1

;---Create the plot
    res@mpDataBaseVersion = resolutions(i)
    res@gsnCenterString = "res@mpDataBaseVersion = " + \
                           dq + resolutions(i) + dq
    plot = gsn_csm_contour_map(wks,u({minlat-2:maxlat+2},{minlon-2:maxlon+3}),res)

  end do
end
