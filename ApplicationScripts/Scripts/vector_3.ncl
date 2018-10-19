;----------------------------------------------------------------------
; vector_3.ncl
;
; Concepts illustrated:
;   - Drawing a black-and-white vector plot over a cylindrical equidistant map
;   - Adding a time stamp to a plot
;   - Thinning vectors using a minimum distance resource
;   - Moving the vector reference annotation to the top right of the plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")

;---Read in zonal [u] and meridional [v] winds (July)
  u = a->U(1,:,:)                             
  v = a->V(1,:,:)

;---Create plot
  wks = gsn_open_wks("png","vector")               ; send graphics to PNG file

  vcres                         = True             ; plot mods desired
  vcres@gsnFrame                = False            ; so we can draw time stamp
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 10.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017

  vector = gsn_csm_vector_map(wks,u,v,vcres)

;---Add time stamp to plot
  infoTimeStamp(wks,0.025,"uv300.nc")      ; arguments are workstation
                                           ; size of text desired, and
                                           ; right string.         
  frame (wks)  
end
