;----------------------------------------------------------------------
; stream_overlay_8.ncl 
;
; Concepts illustrated:
;   - Drawing streamlines over pressure/height contours
;   - Adding more arrows to streamlines
;   - Changing the color of streamlines
;   - Using "overlay" to overlay streamlines on a contour pres/hgt plot
;----------------------------------------------------------------------
; This example is identical to stream_8.ncl, except instead of using
; gsn_csm_pres_hgt_streamline to draw streamlines over a filled
; contour plot, it uses a multiple-step process:
;
;   1. Create filled contour plot
;   2. Create streamline plot
;   3. Call "overlay" to overlay the streamline plot on the contour plot
;   4. Call "draw" to draw both plots
;   5. Call "frame" to advance the frame.
;
; This requires more lines of code, but it can also allow you more
; flexibility, if you need it.
;----------------------------------------------------------------------
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---file handling
   fn  = "atmos.nc"   ; define filename
   in  = addfile(fn,"r")                         ; open netcdf file

;---read needed variables from file
   T = in->T                                    ; select variable to ave
   W = in->OMEGA
   V = in->V
   P0mb = 1000.
   hyam = in->hyam                              ; get a coefficiants
   hybm = in->hybm                              ; get b coefficiants
   PS   = in->PS                                ; get pressure

;---define other arguments required by vinth2p
   interp = 2 
   pnew   = ispan(200,900,10)*1.
   pnew   = pnew(::-1)            ; reverse the array
   pnew@units = "mb"          

;---interpolate to pressure levels on pressure levels
  t = vinth2p(T,hyam,hybm,pnew,PS,interp,P0mb,1,False)
  copy_VarAtts (T,t)                                    ; will use these
  v = vinth2p(V,hyam,hybm,pnew,PS,interp,P0mb,1,False)
  w = vinth2p(W,hyam,hybm,pnew,PS,interp,P0mb,1,False)
;
; Omega is significantly smaller than v, so we will
; scale it so that some vertical motion is visible
;
 wAve   = avg(w(0,:,:,{170}))           ; used for scaling
 vAve   = avg(v(0,:,:,{170}))
 scale  = fabs(vAve/wAve)
 wscale = w*scale                       ; now scale

 copy_VarCoords(w, wscale)              ; copy coordinate variables

;---create plot
 wks   = gsn_open_wks ("png", "stream_overlay" )  ; send graphics to PNG file

 cnres                   = True                   ; plot mods desired

 cnres@gsnDraw           = False
 cnres@gsnFrame          = False

 cnres@tiMainString      = "Pressure/Height Streamline" ; title
 cnres@gsnCenterString   = "At 170E"

 cnres@cnFillOn          = True                ; turn on color fill
 cnres@cnFillPalette     = "BlAqGrYeOrRevi200" ; choose color map
 cnres@cnLineLabelsOn    = False               ; turn off line labels
 cnres@lbLabelStride     = 2                   ; label every other box

 stres                    = True
 stres@gsnDraw            = False
 stres@gsnFrame           = False
 stres@stMinArrowSpacingF = 0.008             ; arrow spacing.
 stres@stArrowLengthF     = 0.008             ; arrow length

;---create filled contour and streamline plots
 contour_plot    = gsn_csm_pres_hgt(wks,t(0,:,:,{170}),cnres)
 streamline_plot = gsn_csm_streamline(wks,v(0,:,:,{170}),wscale(0,:,:,{170}),stres)

;
; Overlay streamline plot on contour plot and draw.
;
; Note: the Y axis of the contour plot will be reversed, because this is what
; gsn_csm_pres_hgt does by default.  The Y axis of the streamline plot was
; not reversed when gsn_csm_streamline was called, but when you call "overlay",
; this procedure will detect that the base plot (the contour plot) has a reversed
; Y axis, and will reverse the streamline's Y axis for you.
;
 overlay(contour_plot,streamline_plot)
 draw(contour_plot)
 frame(wks)
end
