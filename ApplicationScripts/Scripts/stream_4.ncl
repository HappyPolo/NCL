;----------------------------------------------------------------------
; stream_4.ncl 
;
; Concepts illustrated:
;   - Drawing single-color streamlines over a polar stereographic map
;   - Changing the color of streamlines
;   - Increasing the thickness of streamlines
;   - Changing the length of streamlines
;   - Thinning the number of streamlines
;   - Zooming in on a particular area on a map
;   - Adding more arrows to streamlines
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Read in atmospheric data
  a = addfile("atmos.nc","r")
  u = a->U(0,1,:,:)
  v = a->V(0,1,:,:)

;---Create plot
  wks = gsn_open_wks("png" ,"stream")           ; send graphics to PNG file

  res            = True                         ; plot mods desired
  res@gsnPolarNH = True                         ; specify the hemisphere
  res@mpMinLatF  = 20                           ; minimum lat to plot

  res@stArrowLengthF     = 0.008                ; default is dynamic
  res@stLengthCheckCount = 15                   ; default is 35
  res@stArrowStride      = 1
  res@stLineStartStride  = 1                    ; default is 2
  res@stMinArrowSpacingF = 0.035                ; default is 0.0             
  res@stStepSizeF        = 0.001                ; default is dynamic


  res@gsnLeftString       = "Streamlines on a polar projection"

  plot = gsn_csm_streamline_map_polar(wks,u({20.:90.},:),v({20.:90.},:),res)
end
