;***********************************************************
; time_3.ncl
;***********************************************************
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
     tstart = 2000
     tend   = 2006
     yyyymm = yyyymm_time(tstart, tend, "integer")

     yyyyfrac = yyyymm_to_yyyyfrac(yyyymm,0)      ; create fractional years for plotting purposes

     arr = random_uniform(-5.,10.,(tend-tstart+1)*12)	; create random 1D array
     

     wks = gsn_open_wks("png","time")
	
     res = True
     res@trXMinF = tstart         ; starting point along X axis
     res@trXMaxF = tend+1         ; ending point along X-axis
     res@vpWidthF  = .7           ; stretch the plot to be wider (in NDC units)
     res@vpHeightF = .25          ; and not as tall 
     res@vpXF      = .15          ; set the start point along the X-axis in NDC units
     res@gsnDraw   = False        ; do not draw the plot (plots will be paneled)
     res@gsnFrame  = False        ; do not advance the frame (plots will be paneled)
	
     plot = new(3,graphic)	
     plot(0) = gsn_csm_xy(wks,yyyyfrac,arr,res)
	
     res@tmXBPrecision = 4        ; change formatting of XB tickmarks to only plot 4 significant digits
     plot(1) = gsn_csm_xy(wks,yyyyfrac,arr,res)
     delete(res@tmXBPrecision)

     res@trXMaxF = 2001
     res@tmXBMode = "Explicit"
     res@tmXBValues = yyyyfrac(:12)     ; choose first 13 timesteps
	
     res@tmXBLabels = (/" Jan ~C~2000"," Feb ~C~2000"," Mar ~C~2000"," Apr ~C~2000", \
	                " May ~C~2000"," Jun ~C~2000"," Jul ~C~2000"," Aug ~C~2000", \
		        " Sep ~C~2000"," Oct ~C~2000"," Nov ~C~2000"," Dec ~C~2000", \
                        " Jan ~C~2001"/)
				    
     plot(2) = gsn_csm_xy(wks,yyyyfrac(:12),arr(:12),res)			    
     gsn_panel(wks,plot,(/3,1/),False)
end

	
	
