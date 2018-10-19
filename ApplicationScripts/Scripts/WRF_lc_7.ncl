;----------------------------------------------------------------------
; WRF_lc_7.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_vector_map to plot WRF-ARW data in its native projection
;----------------------------------------------------------------------
; WRF: simple wind vectors and wind barbs
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file and read U and V data
  f       = addfile ("wrfout_d01_000000_25time.nc","r")
  U       = f->U                    ; (Time, bottom_top, south_north, west_east_stag)
  V       = f->V                    ; (Time, bottom_top, south_north_stag, west_east)
  znu     = f->ZNU                     ; (Time, bottom_top)
  times   = wrf_user_getvar(f,"times",-1)
  ntim    = dimsizes(times)         ; # time steps
;
; U and V are on different grids. Use the wrf_user_unstagger
; function to "unstagger" them.
;
  u = wrf_user_unstagger(U,U@stagger)     ; (Time, bottom_top, south_north, west_east)
  v = wrf_user_unstagger(V,V@stagger)     ; (Time, bottom_top, south_north, west_east)

  wks = gsn_open_wks("png","WRF_lc")
  
  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; maximize plot size

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False            ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True             ; set True for native projections

;---Plot one time and level for demo
  nt = 12                                      ; arbitrary time
  kl = 5                                       ;   "   "   time

  res@tiMainString             = times(nt)
  res@gsnLeftString            = "Wind Vectors"
  res@gsnRightString           = "znu="+znu(nt,kl)
  res@vcRefMagnitudeF          = 5.0             ; define vector ref mag
  res@vcRefLengthF             = 0.008           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF  = -0.16           ; move ref vector into plot
  res@vcMinDistanceF           = 0.02            ; larger means sparser
  res@vcLineArrowHeadMaxSizeF  = 0.0075          ; default: 0.05 (LineArrow),
                                                 ;  0.012 (CurlyVector) 
  res@vcGlyphStyle             = "CurlyVector"   ; default: "LineArrow"  
    
  plot = gsn_csm_vector_map(wks, u(nt,kl,:,:), v(nt,kl,:,:), res) 
         
  res@vcGlyphStyle             = "WindBarb"
  res@vcRefLengthF             = 0.025           ; ref vec length
  res@vcMinDistanceF           = 0.025           ; larger means sparser
  res@vcRefAnnoOn              = False
  plot = gsn_csm_vector_map(wks, u(nt,kl,:,:), v(nt,kl,:,:), res) 
end
