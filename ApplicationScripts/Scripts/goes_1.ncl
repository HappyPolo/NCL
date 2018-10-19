;----------------------------------------------------------------------
; goes_1.ncl
;
; Concepts illustrated:
;   - Reading a GOES-11 file
;   - Drawing a plot over a region
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;*********************************
; open; lines = 871 ; elems = 1912 ; bands = 1 
; read variable
;*********************************
   diri = "./"
   fili = "goes11.2010.003.200014.BAND_01.nc"
   f    = addfile(diri+fili,"r")
   d    = f->data          ; data(bands, lines, elems)
                           ; data@type = "GVAR"

   d@lat2d = f->latitude   ; (lines, elems)
   d@lon2d = f->longitude  

   print("min(lat)="+min(d@lat2d)+"   max(lat)="+max(d@lat2d))
   print("min(lon)="+min(d@lon2d)+"   max(lon)="+max(d@lon2d))
    
;*********************************
; create plot
;*********************************
   wks = gsn_open_wks("png", "goes")         ; send graphics to PNG file

   res                     = True
   res@cnFillOn            = True            ; turn on color
   res@cnFillPalette       = "amwg"          ; set color map
   res@cnFillMode          = "RasterFill"    ; raster mode
  ;res@cnFillMode          = "CellFill"      ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@gsnAddCyclic        = False           ; data not cyclic
   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar

   res@mpMinLatF           = min(d@lat2d)    ; region to zoom in on
   res@mpMaxLatF           = max(d@lat2d)
   res@mpMinLonF           = min(d@lon2d)
   res@mpMaxLonF           = max(d@lon2d)
   res@mpFillOn            = False
   res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries

   res@gsnLeftString       = d@type
   res@tiMainString        = fili
   band = 0
   plot = gsn_csm_contour_map(wks,d(band,:,:), res)

