;----------------------------------------------------------------------
; stream_7.ncl 
;
; Concepts illustrated:
;   - Drawing streamlines over filled contours on a polar stereographic map
;   - Adding more arrows to streamlines
;   - Changing the color of streamlines
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

begin
;---read in atmospheric data
  a = addfile("atmos.nc","r")
  u = a->U(0,1,:,:)
  v = a->V(0,1,:,:)
  t = a->TS(0,:,:)
;
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;
  assignFillValue(v,u)      
  assignFillValue(u,v)

;---create plot
  wks = gsn_open_wks("png" ,"stream")           ; send graphics to PNG file
  gsn_define_colormap(wks,"wgne15")             ; choose colormap

  res            = True                         ; plot mods desired
  res@gsnPolarNH = True                         ; specify the hemisphere
  res@mpMinLatF  = 60                           ; minimum lat to plot
  res@mpFillOn   = False

  res@cnFillOn          = True                  ; color fill
  res@cnLevelSpacingF   = 3.                    ; interval spacing
  res@cnLinesOn         = False                 ; no contour lines

  res@stLineColor = "white"
;  res@stLineThicknessF = 1.5

  res@gsnSpreadColors     = True                ; use full colormap
  res@gsnSpreadColorStart = 2 
  res@gsnSpreadColorEnd   = -3 

  res@stArrowLengthF     = 0.008                ; default is dynamic
  res@stLengthCheckCount = 5                    ; default is 35
  res@stArrowStride      = 1
  res@stLineStartStride  = 1                    ; default is 2
  res@stMinArrowSpacingF = 0.03                 ; default is 0.0             
  res@stStepSizeF        = 0.001                ; default is dynamic

  res@stMinDistanceF     = 0.03                 ; distance between lines
  res@stMinLineSpacingF  = 0.005                

; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.

  plot = gsn_csm_streamline_contour_map_polar(wks,u({60.:90.},:),v({60.:90.},:), t({60.:90.},:),res)

end
