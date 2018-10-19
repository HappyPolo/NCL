;********************************************************
; WRF: color height-x [west-east] cross-section
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
begin
;********************************************************
; open file 
;********************************************************
  f = addfile ("wrfout_squall_2d_x.nc", "r")

;********************************************************
; Read character variable Times 
; Convert to type string for plotting purposes
;********************************************************
  times   = chartostring(f->Times)     ; built-in function

;********************************************************
; Read W at Time=6, south_north=0, convert to cm/sec
;********************************************************
  w       = f->W(6,:,0,:)              ; import data + meta info
  w       = w*100.                     ; demo: convert to cm/s
  w@units = "cm/s"                     ; update units attribute

  dimw    = dimsizes(w)                ; get dimensions 
  mx      = dimw(1)

;********************************************************
; Associate vertical and horizontal coords to w
;********************************************************
  znw     = f->ZNW(6,:)                ; znw(bottom_top_stag)
  w!0     = "znw"
  w&znw   =  znw                       ; assign values to named dimensions

  dx      = f@DX/1000.                 ; dx in km
  west_east = ispan(0,mx-1,1)*dx       ; calculate x values
  west_east@long_name = "west_east"
  west_east@units = "km"
  w&west_east     = west_east          ; associate "x" values with w
  printVarSummary (w)

;********************************************************
; create plots  
;********************************************************
  wks = gsn_open_wks("ps" ,"WRF_2d")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlWhRe")           ; select color map

  res                       = True            ; plot mods desired
;;res@gsnMaximize           = True            ; uncomment to maximize size
  res@trYReverse            = True            ; reverse to go bot[1.0 to top [0.0]
  res@tiMainString          = times(6)        ; main title

  res@cnFillOn              = True            ; turn on color
;;res@cnLinesOn             = False           ; turn off contour lines
  res@gsnSpreadColors       = True            ; use entire color map
  res@lbOrientation         = "Vertical"      ; move label bar
  res@lbLabelAutoStride     = True            ; let NCL determine label spacing
  symMinMaxPlt(w, 14, False, res)             ; contributed.ncl

  plot                      = gsn_csm_contour(wks,w,res)
end

