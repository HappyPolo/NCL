load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"		; needed for dim_avg_Wrap

begin
  a = addfile("z_tigge_c_egrr_20070512120000_0012_pl_glob_prod.grib2","r")
  sh = a->q_P1_L100_GLL0(:,{70000.},:,:)    ; grab 70000. Pa Q
  ensavg = dim_avg_Wrap(sh(lat_0|:,lon_0|:,ensemble0|:))  ; average across the ensemble dimension
                                                            ; to get an ensemble average
;=============================================================  
  wks = gsn_open_wks("ps","tigge_4")
  gsn_define_colormap(wks,"rainbow")
  
  eres = True
  eres@mpDataBaseVersion="MediumRes"
  eres@mpProjection = "LambertEqualArea"
  eres@mpLimitMode = "LatLon"
  eres@mpMinLatF = 7.                                       ; set the minimum latitude
  eres@mpMaxLatF = 90.                                      ; set the maximum latitude
  eres@mpMinLonF = 200.                                     ; set the minimum longitude
  eres@mpMaxLonF = 330.                                     ; set the maximum longitude
  eres@mpCenterLonF = (eres@mpMaxLonF + eres@mpMinLonF)/2.    ; set the longitude at the center of the plot
  eres@mpOutlineOn = True                                   ; turn the map outlines on
  eres@mpOutlineBoundarySets = "National"                   ; draw national boundaries
  eres@mpOutlineSpecifiers = (/"Canada : Provinces","United States : States"/)  ; draw US States, Canadian provinces
  eres@mpFillOn = False                                     ; do not fill the land
  eres@gsnMaximize = True                                   ; maximize the plot
  eres@gsnPaperOrientation  = "portrait"                    ; when maximizing, keep the orientation as portrait
  eres@cnLevelSelectionMode = "ManualLevels"                ; manually select the levels
  eres@cnMinLevelValF       = .0008                         ; set the minimum contour level
  eres@cnMaxLevelValF       = .008                        ; set the maximum contour level
  eres@cnLevelSpacingF      = .0008                         ; set the contour interval
  eres@cnFillOn = True                                      ; turn on contour shading     
  eres@cnFillColors = (/0,55,70,85,100,115,130,145,160,175,189/)    ; set the fill colors
  eres@cnLinesOn = False                         ; don't draw the contour lines
  eres@cnInfoLabelOn         = False             ; don't draw the info label
  eres@cnLineLabelsOn = False                    ; don't draw the contour line labels
  eres@tiMainFontHeightF = 0.012                 ; set the main title font height
  
  eres@gsnLeftString = ensavg@initial_time
  eres@gsnCenterString = ensavg@forecast_time+"hr forecast"
  eres@gsnRightString = ensavg@units
  eres@tiMainString = "UKMET Ensemble 700hPa Specific Humidity"
  
  plot_ens = gsn_csm_contour_map(wks,ensavg,eres)
end
