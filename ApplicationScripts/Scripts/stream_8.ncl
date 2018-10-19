;----------------------------------------------------------------------
; stream_8.ncl 
;
; Concepts illustrated:
;   - Drawing streamlines over pressure/height contours
;   - Adding more arrows to streamlines
;   - Changing the color of streamlines
;----------------------------------------------------------------------
; This example is identical to stream_overlay_8.ncl, except instead of 
; using a five-step process to create the overlaid plots, it calls 
; the function gsn_csm_pres_hgt_streamline.  This is easier, but can
; be less flexible.
;----------------------------------------------------------------------
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
 wks   = gsn_open_wks ("png", "stream" )        ; send graphics to PNG file

 res                   = True                   ; plot mods desired

 res@tiMainString      = "Pressure/Height Streamline" ; title
 res@gsnCenterString   = "At 170E"

 res@cnFillOn          = True                ; turn on color fill
 res@cnFillPalette     = "BlAqGrYeOrReVi200" ; choose color map
 res@cnLineLabelsOn    = False               ; turn off line labels
 res@lbLabelStride     = 2                   ; label every other box

 res@stMinArrowSpacingF = 0.008             ; arrow spacing.
 res@stArrowLengthF     = 0.008             ; arrow length

;---draw plot from pole to pole at 170E
 plot  = gsn_csm_pres_hgt_streamline(wks,t(0,:,:,{170}),v(0,:,:,{170}),\
                                wscale(0,:,:,{170}),res )  

end
