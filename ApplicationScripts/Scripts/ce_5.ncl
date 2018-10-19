;*************************************************
; ce_5.ncl
;
; Concepts illustrated:
;   - Drawing zonal average plots
;   - Drawing two plots on the same page using gsn_panel
;   - Changing the background color of the contour line labels
;   - Turning off the contour informational label
;   - Controlling how contour labels are drawn
;   - Turning off the gray-filled continents
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create default plot
;************************************************
  wks  = gsn_open_wks("png","ce")  ; send graphics to PNG file
  plot = new(2,graphic)            ; create plot array


  res                            = True                ; plot mods desired
  res@gsnZonalMean               = True                ; turn on zonal ave plot
  res@mpFillOn                   = False               ; turn off gray map
  res@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first

  res@cnInfoLabelOn              = False               ; turn off info label
  res@cnLineLabelBackgroundColor = "white"             ; background for labels

  res@gsnDraw                    = False               ; don't draw yet
  res@gsnFrame                   = False               ; don't advance frame


  res@gsnCenterString            = "Label Placement: Random (default)"
  plot(0) = gsn_csm_contour_map(wks,u,res)          ; create plot


  res@gsnCenterString            = "Label Placement: Computed"
  res@cnLineLabelPlacementMode   = "computed"          ; how line labels placed
  plot(1) = gsn_csm_contour_map_ce(wks,u,res)          ; create plot

  gsn_panel(wks,plot,(/2,1/),False)
end



