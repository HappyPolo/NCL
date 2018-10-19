;**************************************
;  ave_2.ncl
;
; Concepts illustrated:
;   - Calculating a hemispheric average
;   - Calculating a weighted average
;   - Copying attributes from one variable to another
;   - Drawing an XY plot with multiple curves
;   - Drawing a legend inside an XY plot
;   - Moving an XY plot legend
;   - Changing the width and height of an XY plot legend
;   - Adding line labels to an XY plot legend
;
;**************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
begin
;****************************************
  in = addfile("b003_TS_200-299.nc","r")
  ts = in->TS                            ; read in data
  gw = in->gw                            ; get gaussian weights for ave
;****************************************
; calculate averages
;****************************************
; arguments:
; data
; weights in y direction
; weights in x direction (we just use 1.0 since there are none)
; option (0 means use missing values, 1 means the ave will be missing if
;    ANY data in the array is missing.

  globav  = wgt_areaave(ts,gw,1.0,0)
  copy_VarAtts(ts,globav)

  nh = wgt_areaave(ts(:,{0:90},:),gw({0:90}),1.0,0)
  copy_VarAtts(ts,nh)

  sh  = wgt_areaave(ts(:,{-90:0},:),gw({-90:0}),1.0,0)
  copy_VarAtts(ts,sh)
;****************************************
; Create new y-variable
;****************************************
  ncols=3
  nrows=dimsizes(sh)
  yall  = new( (/ncols,nrows/),float)
  yall(0,:)=globav(:)
  yall(1,:)=nh(:)
  yall(2,:)=sh(:)
;****************************************
; Create plot
;****************************************
 wks = gsn_open_wks("png","ave")           ; send graphics to PNG file
 res = True
 res@tiYAxisString  = globav@long_name + " (" + globav@units + ")"
 res@tiXAxisString  = "Time Steps"
 res@tiMainString   = "Averages by Hemisphere"
 res@xyLineColors   = (/"black","red","green"/)   ; choose line colors

 res@pmLegendDisplayMode    = "Always"     ; turn on legend bar
 res@pmLegendSide           = "Bottom"     ; orient with bottom
 res@pmLegendParallelPosF   = .15          ; move legend                      
 res@pmLegendOrthogonalPosF = -0.36                
 res@lgPerimFillColor       = "white"      ; fill with white
 res@lgPerimFill            = "SolidFill"
 res@pmLegendWidthF         = 0.05         ; size
 res@pmLegendHeightF        = 0.08
 res@lgLabelFontHeightF     = 0.015 
 res@xyExplicitLegendLabels = (/"Global ","North_H  ","South_H  "/) 
 res@xyLineThicknesses      = (/2.,2.,2./)
 x = ispan(0,dimsizes(globav)-1,1)                      ; create default x-axis
 plot = gsn_csm_xy(wks,x,yall,res); create plot
end


