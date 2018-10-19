;********************************************************
; WRF: simple plane view of the pressure field
;      at a specific time and level. 
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
;********************************************************
; open file 
;********************************************************
  f = addfile ("wrfout_quarter_ss.nc", "r")
;********************************************************
; Read character variable Times 
; Convert to type string for plotting purposes
;********************************************************
  times   = chartostring(f->Times)     ; built-in function

;********************************************************
; Read Pressure at Time=12, level=0, convert to hPa 
;********************************************************
  p       = f->P(12,0,:,:)             ; import data + meta info
  p       = p*0.01                     ; demo: convert to hPa
  p@units = "hPa"                      ; update units attribute

;********************************************************
; create plots  
;********************************************************
  wks = gsn_open_wks("ps" ,"WRF_3d")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); select color map

  res                       = True            ; plot mods desired
;;res@gsnMaximize           = True            ; uncomment to maximize size
  res@tiMainString          = times(12)       ; main title
  plot                      = gsn_csm_contour(wks,p,res)

  res@cnFillOn              = True            ; turn on color
  res@cnLinesOn             = False           ; turn contour lines
  res@gsnSpreadColors       = True            ; use entire color map
  res@lbLabelAutoStride     = True            ; let NCL determine label spacing
  plot                      = gsn_csm_contour(wks,p,res)

  dimp    = dimsizes(p)   
  ny      = dimp(0)
  mx      = dimp(1)

  dx      = f@DX/1000.                 ; dx (km)
  west_east  = ispan(0,mx-1,1)*dx      ; calculate x values
  west_east@long_name = "west_east"
  west_east@units = "km"
  p&west_east     = west_east          ; associate "x" values with p

  dy      = f@DY/1000.                 ; dy (km)
  south_north = ispan(0,ny-1,1)*dy       ; calculate y values
  south_north@long_name = "south_north"
  south_north@units = "km"
  p&south_north     = south_north          ; associate "y" values with p
  printVarSummary(p)

  res@cnLinesOn             = True
  res@lbOrientation         = "Vertical"
  plot                      = gsn_csm_contour(wks,p,res)

end

