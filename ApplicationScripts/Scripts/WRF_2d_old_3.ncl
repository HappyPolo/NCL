;********************************************************
; WRF: vector 
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

  dx      = f@DX/1000.                 ; dx (km)
  west_east = ispan(0,mx-1,1)*dx       ; calculate x values
  west_east@long_name = "west_east"
  west_east@units = "km"
  w&west_east     = west_east          ; associate "x" values with w
  printVarSummary (w)

;********************************************************
; create a bogus wind array with all values 0.0 
;********************************************************
  u = w
  u = 0.0
;********************************************************
; create plots  
;********************************************************
  wks = gsn_open_wks("ps" ,"WRF_2d")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlWhRe")           ; select color map

  res                       = True            ; plot mods desired
;;res@gsnMaximize           = True            ; uncomment to maximize size
  res@trYReverse            = True            ; reverse to go bot[1.0 to top [0.0]
  res@tiMainString          = times(6)        ; main title

  res@vcRefMagnitudeF          = 150.            ; define vector ref mag
  res@vcRefLengthF             = 0.0080          ; define length of vec ref
  res@vcLineArrowHeadMaxSizeF  = 0.0075          ; default: 0.05 (LineArrow), 0.012 (CurlyVector) 
  plot                      = gsn_csm_vector(wks,u(::2,::4),w(::2,::4),res)

  res@vcRefAnnoOrthogonalPosF  = -0.18           ; move ref vector
  res@vcMinDistanceF           = 0.02            ; larger means sparser
  plot                      = gsn_csm_vector(wks,u(::2,::4),w(::2,::4),res)
end

