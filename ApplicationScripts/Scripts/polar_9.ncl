;*************************************************
; polar_9.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
;************************************************
; read in atmospheric data
;************************************************
  a = addfile("atmos.nc","r")
  u = a->U(0,1,:,:)
  v = a->V(0,1,:,:)
  t = a->TS(0,:,:)
;*************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")             ; send graphics to PNG file

  res               = True                      ; plot mods desired
  res@gsnPolarNH    = True                      ; specify the hemisphere
  res@mpMinLatF     = 20                        ; minimum lat to plot

  res@gsnLeftString       = "Streamlines on a polar projection"

  res@stArrowLengthF     = 0.008                ; default is dynamic
  res@stLengthCheckCount = 15                   ; default is 35
  res@stArrowStride      = 1
  res@stLineStartStride  = 1                    ; default is 2
  res@stMinArrowSpacingF = 0.035                ; default is 0.0             
  res@stStepSizeF        = 0.001                ; default is dynamic

; the following two resources on the ones that you will really have to
; tweak depending upon the field you are plotting.

  res@stMinDistanceF     = 0.03                 ; default is dynamic
  res@stMinLineSpacingF  = 0.007                ; default is dynamic

  plot = gsn_csm_streamline_map_polar(wks,u({21.:90.},:),v({21.:90.},:),res)


end
