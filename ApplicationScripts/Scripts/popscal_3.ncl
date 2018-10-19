;================================================;
;  popscal_3.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  f         = addfile("TEMP.nc","r")

  t         = f->TEMP              ; (time, z_t, nlat, nlon)

  t@lon2d   = f->TLONG             ; associate 2D arrays containing
  t@lat2d   = f->TLAT              ; coordinates with variable
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("png","popscal")            ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data

  res                      = True                 ; plot mods desired
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@cnFillPalette        = cmap(8:94,:)         ; set color map
  res@gsnAddCyclic         = True                 ; add cyclic point

  plot = gsn_csm_contour_map(wks,t(0,0,:,:),res) ; time=0, z_t=0        
  end
