;*************************************************
; NCL tutorial script: vort_2.ncl
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;************************************************
; variable and file handling
;************************************************
  fn  = "80.nc"                                  ; define filename
  in  = addfile(fn,"r")                          ; open netcdf file
  u   = in->U                                    ; pull u off file
  v   = in->V                                    ; pull v off file
;************************************************
; calculate vorticity on a Gaussian Grid
;************************************************
  scale = 1.e05                                  ; for visual convenience
  vrt   = u                                      ; retain coordinates
  vrt   = uv2vrG_Wrap(u,v) * scale
  vrt@long_name = "vorticity"
  vrt@units     = " "
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks("ps","vort")               ; specifies a ps plot
  plot=gsn_csm_contour_map_ce(wks,vrt(0,2,:,:),False)  
;************************************************
end
