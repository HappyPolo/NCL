;----------------------------------------------------------------------
; vector_5.ncl
;
; Concepts illustrated:
;   - Drawing pressure/height vectors over filled contours
;   - Using "vinth2p" to interpolate to user specified pressure levels
;   - Drawing curly vectors
;   - Thinning vectors using a minimum distance resource
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;---File handling
   fn  = "atmos.nc" ; define filename
   in  = addfile(fn,"r")                         ; open netcdf file

;---Read needed variables from file
   T = in->T                                    ; select variable to ave
   W = in->OMEGA
   V = in->V
   P0mb = 1000.
   hyam = in->hyam                              ; get a coefficiants
   hybm = in->hybm                              ; get b coefficiants
   PS   = in->PS                                ; get pressure

;---Define other arguments required by vinth2p
   interp = 2 
   pnew   = (/ 900,850,800,750,700,650,600,550,500,450,400,350,300,250,200/)
   pnew@units = "mb"          

;---Interpolate to pressure levels on pressure levels
  t = vinth2p(T,hyam,hybm,pnew,PS,interp,P0mb,1,False)
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

;---Create plot
 wks   = gsn_open_wks ("png", "vector" )        ; send graphics to PNG file

 res                 = True                     ; plot mods desired
 res@tiMainString    = "Pressure/Height Vector" ; title

 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 res@cnFillPalette   = "BlAqGrYeOrReVi200"  ; choose color map

 res@lbLabelStride   = 2                    ; every other color

 res@vcRefMagnitudeF = 3.0                ; define vector ref mag
 res@vcRefLengthF    = 0.045              ; define length of vec ref
 res@vcGlyphStyle    = "CurlyVector"      ; turn on curly vectors
 res@vcMinDistanceF  = 0.01               ; thin out vectors
 res@vcMapDirection  = False


;---Draw plot from pole to pole at 170E
 plot  = gsn_csm_pres_hgt_vector(wks,t(0,:,:,{170}),v(0,:,:,{170}),\
                                wscale(0,:,:,{170}),res )  

end
