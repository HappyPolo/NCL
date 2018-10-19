;*************************************************
; NCL tutorial script: vert_1.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; file handling
;************************************************
   fn  = "atmos.nc" ; define filename
   in  = addfile(fn,"r")                         ; open netcdf file
;************************************************
; read needed variables from file
;************************************************
   T = in->T                                    ; select variable to ave
   P0mb =1000.
   hyam = in->hyam                             ; get a coefficiants
   hybm = in->hybm                              ; get b coefficiants
   PS   = in->PS                                ; get pressure
;************************************************
; define other arguments required by vinth2p
;************************************************
; type of interpolation: 1 = linear, 2 = log, 3 = loglog
   interp = 2 

; is extrapolation desired if data is outside the range of PS
   extrap = False

; create an array of desired pressure levels:
   pnew = (/ 850.0,700.0,500.0,300.0,200.0 /)            
;************************************************
; calculate T on pressure levels
;************************************************
; note, the 7th argument is not used, and so is set to 1.
;************************************************
   TonP = vinth2p(T(0,:,:,:),hyam,hybm,pnew,PS(0,:,:),interp,P0mb,1,extrap)
;************************************************
; plot parameters that do not change
;************************************************
   wks  = gsn_open_wks("png","vert")              ; send graphics to PNG file
   plot = new(3,graphic)                          ; Define plot array 
   r    = True                                    ; plot mods desired
   r@gsnFrame = False                             ; required for panel plots
   r@gsnDraw  = False                             ; required for panel plots
;************************************************
; create individual contour plots
;************************************************
   r@tiMainString= "850 mb"                      ; plot title
   plot(0)=gsn_csm_contour_map(wks,TonP(0,:,:),r)  ; plot temp contours 

   r@tiMainString= "500 mb"                      ; plot title
   plot(1)=gsn_csm_contour_map(wks,TonP(2,:,:),r)  ; plot temp contours

   r@tiMainString= "200 mb"                      ; plot title
   plot(2)=gsn_csm_contour_map(wks,TonP(4,:,:),r)  ; plot temp contours
;***********************************************
   gsn_panel(wks,plot,(/3,1/),False)              ; create panel plots
end


