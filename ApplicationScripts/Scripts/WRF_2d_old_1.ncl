;********************************************************
; WRF: simple height-x [west-east] cross-section
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
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
  mx      = dimw(1)                    ; # west-east values 

;********************************************************
; Associate vertical and horizontal coords to w for nicer plot
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

  res                       = True            ; plot mods desired
;;res@gsnMaximize           = True            ; uncomment to maximize size
  res@trYReverse            = True            ; reverse to go bot[1.0 to top [0.0]
  res@tiMainString          = times(6)        ; main title
  plot                      = gsn_csm_contour(wks,w,res)

  res@gsnDraw               = False           ; do not draw 
  res@gsnFrame              = False           ; do not advance
  res@cnInfoLabelOrthogonalPosF = -0.13       ; move label box 
  plot                      = gsn_csm_contour(wks,w,res)
  plot = ZeroNegDashLineContour(plot)         ; adjust contour lones
  draw (plot)                                 ; draw the contour object
  frame (wks)                                 ; advance frame
end

