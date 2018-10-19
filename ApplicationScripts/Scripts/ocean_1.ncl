;************************************
;
; CSM_Graphics: ocean_1.ncl
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
 T=in->T(0,0,:,{0:360})              ; get rid of cyclic points (req to plt)
;************************************
 wks = gsn_open_wks("ncgm","ocean")  ; open a ncgm file
 res=True
 res@cnFillOn             = True     ; turn on color fill
 res@mpFillOn             = False    ; turn off gray continents
 res@mpOutlineOn          = False    ; turn off continental outline
 res@gsnDraw              = False    ; do not draw picture
 res@gsnFrame             = False    ; do not advance frame

 plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
 genCmapMnMxSpan (wks, plot, "Blue" , "Red")  ; create color map
 draw(plot)
 frame(wks)
;************************************
 
end


