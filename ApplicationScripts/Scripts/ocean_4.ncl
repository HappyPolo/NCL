;************************************
;
; CSM_Graphics: ocean_4.ncl
;
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;************************************
begin
;************************************
 in = addfile("h_avg_Y0191_D000.00.nc","r")
 T=in->T(0,:,{25},{270:350})   
 lon_t = in->lon_t({270:350})
 z_t   = in->z_t
;************************************
; required to get oceanic data to plot
;************************************
 T!0 = "lev"                         
;************************************
 wks = gsn_open_wks("ncgm","ocean")  ; open a ncgm file
 res=True

 res@cnFillOn             = True     ; turn on color fill
 res@cnLineLabelsOn       = False    ; turns off contour line labels
 res@cnInfoLabelOn        = False    ; turns off contour info label
 res@sfXArray             = lon_t    ; uses lon_t as plot x-axis
 res@sfYArray             = z_t/100  ; convert cm to m
 res@gsnYAxisIrregular2Linear = True ; converts irreg depth to linear 
 res@trYReverse=True                 ; reverses y-axis
 res@pmLabelBarDisplayMode = "Always"; turn on label bar (not for use with
                                     ; gsn_csm_*() interfaces)

 res@tiXAxisString = "longitude"                    ; x-axis title
 res@tiYAxisString = "depth (m)"                    ; y-axis title
 res@tiMainString  = "Potential Temperature at 25N" ; main title

 res@gsnDraw              = False    ; do not draw picture
 res@gsnFrame             = False    ; do not advance frame

 plot = gsn_contour(wks,T,res)                ; create plot
 genCmapMnMxSpan (wks, plot, "Blue" , "Red")  ; choose color map
 draw(plot)                                   ; draw plot
 frame(wks)                                   ; advance frame
;************************************
 
end


