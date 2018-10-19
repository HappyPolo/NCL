;************************************
; unique_6.ncl
;
; Concepts illustrated:
;   - Paneling ten plots in two columns on a page
;   - Drawing three custom legends outside a plot
;   - Changing the line dash pattern in an XY plot
;   - Attaching markers to an XY plot
;************************************
;
; The script for this plot was written by Jeff Yin of the Climate
; and Global Dynamics Division of the National Center for Atmospheric
; Research.
;
; The 2081-2100 minus 1981-2000 zonal mean for each model of (a,b) 2-8
; day EKE vertically integrated from the surface to 200 hPa, units 10^4
; J m-2; (c,d) 2-8 day meridional momentum flux convergence vertically
; integrated from the surface to 200 hPa, units Pa; (e,f) surface zonal
; wind stress, units Pa; (g,h) sea level pressure, units hPa; (i,j)
; precipitation, units mm day-1.  The thick black line indicates the
; multi-model ensemble mean.  The left column is DJF, and the right
; column is JJA.  The dots on each line indicate the latitude of the
; maximum for each variable (except for sea level pressure) for
; 1981-2000; when the dot is at a latitude where the 2081-2100 minus
; 1981-2000 difference is increasing towards the pole, there has been a
; poleward shift in that quantity.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;
; Set the seasons for the plots.
;
  seas_name = (/"DJF","JJA"/)
;
; Set up some strings and bounds for plots.
;
  exp_name_1  = "20C"
  exp_name_2  = "A1B"
  var_name    = (/"EKE","dVU/dy","Wind Stress","SLP","Precip"/)
  var_units   = (/"10~S~4~N~ J m~S~-2~N~","Pa","Pa","hPa","mm d~S~-1~N~"/)
  ps_var_name = "multipanel"
  ymax        = (/ 8., 0.05, 0.08, 5., 0.8/)
  ymin        = (/-4.,-0.04,-0.05,-9.,-0.6/)
  nseas       = dimsizes(seas_name)
  nvars       = dimsizes(var_name)
  nvars_nseas = nvars*nseas
;
; Input file that contains values to be plotted.
;
  in_file_name = "IPCC_multipanel_shift_plot_all_models_zonav_simple_input.nc"
;
; Set up workstation and change color map.
;
  wks = gsn_open_wks("png","unique")      ; send graphics to PNG file
  gsn_define_colormap(wks,"amwg")

;
; Read in variables to be plotted.
;
  f = addfile(in_file_name,"r")
  T42_1_output = f->T42_1_output
  T42_2_output = f->T42_2_output
  T21_1_output = f->T21_1_output
  T21_2_output = f->T21_2_output
  num_T42      = dimsizes(f->model_T42)
  num_T21      = dimsizes(f->model_T21)
  num_mods     = num_T42 + num_T21

;
; Set up interpolation.
;
  lat_T42  = f->lat_T42
  lat_T21  = f->lat_T21
  nlat_T42 = dimsizes(lat_T42)
  nlat_T21 = dimsizes(lat_T21)

;
; Create arrays to hold plots.
;
  plot1 = new(nvars_nseas,graphic)
  plot2 = new(nvars_nseas,graphic)
  plot0 = new(nvars_nseas,graphic)
  dum   = new((/num_mods,nvars_nseas/),graphic)
  dum0  = new((/nvars_nseas/),graphic)

;
; Set up plotting labels and line attributes.
;
  llabels =(/"MIROC3.2(hires)","CCSM3","ECHAM5/MPI-OM","GFDL-CM2.0", \
             "GFDL-CM2.1","CNRM-CM3","MIROC3.2(medres)","MRI-CGCM2.3.2", \
             "FGOALS-g1.0","IPSL-CM4","CGCM3.1(T47)","ECHO-G","GISS-AOM", \
             "GISS-ER","INM-CM3.0"/)

  lcolors = (/"maroon","maroon","maroon","orange","orange","orange","green",\
              "green","green","blue","blue","blue","purple","purple","purple"/)
  ldash   = (/0,1,11,0,1,11,0,1,11,0,1,11,0,1,11/)


;
; Create resources for T42 xy plot.
;
  xyres1                        = True
  xyres1@gsnDraw                = False
  xyres1@gsnFrame               = False
  xyres1@gsnYRefLine            = 0.0

  xyres1@vpHeightF              = 0.2
  xyres1@vpWidthF               = 0.5

  xyres1@trXMinF                = -90.
  xyres1@trXMaxF                =  90.

  xyres1@txFontHeightF          = .015

  xyres1@xyMonoDashPattern      = False
  xyres1@xyMonoLineColor        = False
  xyres1@xyDashPatterns         = ldash(0:num_T42-1)
  xyres1@xyLineColors           = lcolors(0:num_T42-1)
  xyres1@xyExplicitLegendLabels = llabels(0:num_T42-1)

  xyres1@xyCurveDrawOrder       = "PreDraw"
  xyres1@tfPolyDrawOrder        = "Draw"

  xyres1@lgLabelFontHeightF     = 0.02

  xyres1@tmXBLabelsOn           = False
  xyres1@tmYRLabelsOn           = False
  xyres1@tmYLLabelsOn           = False

;
; Create resources for T21 xy plot to be overlaid on T42 xy plot.
;
  xyres2                        = True

  xyres2@gsnDraw                = False
  xyres2@gsnFrame               = False
  xyres2@gsnYRefLine            = 0.0

  xyres2@lgLabelFontHeightF     = 0.02

  xyres2@tmXBLabelsOn           = False
  xyres2@tmYLLabelsOn           = False
  xyres2@tmYRLabelsOn           = False

  xyres2@trXMaxF                =  90.
  xyres2@trXMinF                = -90.

  xyres2@txFontHeightF          = .015

  xyres2@vpHeightF              = 0.2
  xyres2@vpWidthF               = 0.5

  xyres2@tfPolyDrawOrder        = "Draw"
  xyres2@xyCurveDrawOrder       = "PreDraw"

  xyres2@xyDashPatterns         = ldash(num_T42:num_mods-1)
  xyres2@xyLineColors           = lcolors(num_T42:num_mods-1)
  xyres2@xyMonoDashPattern      = False
  xyres2@xyMonoLineColor        = False
  xyres2@xyExplicitLegendLabels = llabels(num_T42:num_mods-1)

;
; Create resources for multi-model mean plot, to be overlaid on T42 plot.
;
  xyres0                     = True

  xyres0@gsnDraw                = False
  xyres0@gsnFrame               = False
  xyres0@gsnYRefLine            = 0.0

  xyres0@lgLabelFontHeightF     = 0.02

  xyres0@tmXBLabelsOn           = False
  xyres0@tmYLLabelsOn           = False
  xyres0@tmYRLabelsOn           = False

  xyres0@trXMaxF                =  90.
  xyres0@trXMinF                = -90.

  xyres0@txFontHeightF          = .015

  xyres0@vpHeightF              = 0.2
  xyres0@vpWidthF               = 0.5

  xyres0@tfPolyDrawOrder        = "PostDraw"
  xyres0@xyCurveDrawOrder       = "PostDraw"

  xyres0@xyDashPatterns         = 0
  xyres0@xyLineColors           = "black"
  xyres0@xyLineThicknesses      = 2.
  xyres0@xyMonoDashPattern      = False
  xyres0@xyMonoLineColor        = False
  xyres0@xyMonoLineThickness    = False
  xyres0@xyExplicitLegendLabels = llabels(0:num_T42-1)

  do v = 0,nvars-1      ; Loop over variables.
    if (v .eq. nvars-1) then
      xyres1@tmXBLabelsOn = True      ; Turn on labels for bottom plot.
    end if
    xyres1@trYMinF = ymin(v)
    xyres1@trYMaxF = ymax(v)

    do s = 0,nseas-1   ;  Loop over seasons.
      if (s .eq. nseas-1) then
        xyres1@tmYRLabelsOn = True    ; Turn on labels for right plot.
      else
        xyres0@tmYRLabelsOn = False   ; Turn on labels for right plot.
        xyres1@tmYRLabelsOn = False   ; Turn on labels for right plot.
        xyres2@tmYRLabelsOn = False   ; Turn on labels for right plot.
      end if
;
; Set plot number.
;
      p = v*nseas + s
;
; Set up arrays for current plot
;
      X_1_T42 = T42_1_output(v,s,:,:)
      X_2_T42 = T42_2_output(v,s,:,:)
      X_1_T21 = T21_1_output(v,s,:,:)
      X_2_T21 = T21_2_output(v,s,:,:)
;
; Interpolate T21 to T42.
;
      X_1_T21_interp = linint1_Wrap(lat_T21,X_1_T21,False,lat_T42,0)
      X_2_T21_interp = linint1_Wrap(lat_T21,X_2_T21,False,lat_T42,0)
;
; Calculate multi-model ensemble mean.
;
      X_1_mn = X_1_T42(0,:)
      X_1_mn = (/(dim_sum(X_1_T42(lat_T42|:,model_T42|:)) + \
                  dim_sum(X_1_T21_interp(lat_T42|:,model_T21|:)))/num_mods/)
      X_2_mn = X_2_T42(0,:)
      X_2_mn = (/(dim_sum(X_2_T42(lat_T42|:,model_T42|:)) + \
                  dim_sum(X_2_T21_interp(lat_T42|:,model_T21|:)))/num_mods/)
;
; Calculate differences between first period and second period.
;
      X_mn  = X_1_mn
      X_mn  = X_1_mn - X_2_mn
      X_T42 = X_1_T42
      X_T42 = X_1_T42 - X_2_T42
      X_T21 = X_1_T21
      X_T21 = X_1_T21 - X_2_T21
      if (s .eq. 0) then
        X_T42@long_name = var_name(v)+" ("+var_units(v)+")"
        X_T21@long_name = var_name(v)+" ("+var_units(v)+")"
        X_mn@long_name  = var_name(v)+" ("+var_units(v)+")"
      else
        delete(X_T42@long_name)
        delete(X_T21@long_name)
        delete(X_mn@long_name)
      end if
      plot1(p) = gsn_csm_xy(wks,X_T42&lat_T42,X_T42,xyres1)

;
; Add polymarkers for NH and SH maxima, except for SLP, for T42 and T21.
;
      if (var_name(v) .ne. "SLP") then
        do m = 0,num_T42-1
          SHind = maxind(X_2_T42(m,0:5*nlat_T42/16-1))
          NHind = maxind(X_2_T42(m,11*nlat_T42/16:nlat_T42-1))+11*nlat_T42/16
          if (.not. any(ismissing((/SHind,NHind/)))) then
            pmx = (/X_T42&lat_T42(SHind),X_T42&lat_T42(NHind)/)
            pmy = (/X_T42(m,SHind),X_T42(m,NHind)/)
            pmres = True
            pmres@gsMarkerColor = lcolors(m)
            pmres@gsMarkerIndex = 16
            pmres@gsMarkerSizeF = 0.006
            dum(m,p) = gsn_add_polymarker(wks,plot1(p),pmx,pmy,pmres)
          end if
        end do
        do m = 0,num_T21-1
          SHind = maxind(X_2_T21(m,0:5*nlat_T21/16-1))
          NHind = maxind(X_2_T21(m,11*nlat_T21/16:nlat_T21-1))+11*nlat_T21/16
          if (.not. any(ismissing((/SHind,NHind/)))) then
            pmx = (/X_T21&lat_T21(SHind),X_T21&lat_T21(NHind)/)
            pmy = (/X_T21(m,SHind),X_T21(m,NHind)/)
            pmres = True
            pmres@gsMarkerColor = lcolors(num_T42+m)
            pmres@gsMarkerIndex = 16
            pmres@gsMarkerSizeF = 0.006
            dum(num_T42+m,p) = gsn_add_polymarker(wks,plot1(p),pmx,pmy,pmres)
          end if
        end do
      end if

      plot2(p) = gsn_csm_xy(wks, X_T21&lat_T21, X_T21, xyres2)
      plot0(p) = gsn_csm_xy(wks, X_mn&lat_T42,  X_mn,  xyres0)

;
; Add polymarkers for NH and SH maxima, except for SLP, for multi-model mean.
;
      if (var_name(v) .ne. "SLP") then
        SHind = maxind(X_2_mn(0:5*nlat_T42/16-1))
        NHind = maxind(X_2_mn(11*nlat_T42/16:nlat_T42-1))+11*nlat_T42/16
        pmx   = (/X_mn&lat_T42(SHind),X_mn&lat_T42(NHind)/)
        pmy   = (/X_mn(SHind),X_mn(NHind)/)
        pmres = True
        pmres@gsMarkerColor = "black"
        pmres@gsMarkerIndex = 16
        pmres@gsMarkerSizeF = 0.009
        dum0(p) = gsn_add_polymarker(wks,plot0(p),pmx,pmy,pmres)
      end if
;
; Overlay T21 lines (plot2) on T42 lines (plot1).
;
      overlay(plot1(p),plot2(p))
      overlay(plot1(p),plot0(p))

    end do     ; Loop over seasons.
  end do       ; Loop over variables.
;
; Resources for panel plot and labels.
;
  pres                              = True
  pres@gsnFrame                     = False
  pres@gsnPanelBottom               = 0.16
  pres@gsnPanelTop                  = 0.98
  pres@gsnPanelFigureStrings        = (/"a","b","c","d","e","f","g","h",\
                                        "i","j"/)
  pres@gsnPanelFigureStringsPerimOn = False

  gsn_panel(wks, plot1, (/nvars,nseas/), pres)
;
; Add season labels to top of plot.
;
  txres               = True
  txres@txFontHeightF = 0.015
  gsn_text_ndc(wks,seas_name(0),0.305,0.99,txres)
  gsn_text_ndc(wks,seas_name(1),0.715,0.99,txres)

;
; Create legend at bottom.
;
; Reverse everything to be plotted in legend so it comes out 
; in desired order.
;
  lcolors = lcolors(::-1)
  ldash   = ldash(::-1)
  llabels = llabels(::-1)
;
; Set general legend resources.
;
  lgres                          =  True
  lgres@vpWidthF                 = 0.2                ; width
  lgres@vpHeightF                = 0.12               ; height

  lgres@lgAutoManage             = False

  lgres@lgPerimOn                = False              ; no perimeter
  lgres@lgItemCount              = 5                  ; how many
  lgres@lgLabelsOn               = True               ; no default lables
  lgres@lgLabelFontHeightF       = 0.06               ; font height
  lgres@lgLabelJust              = "CenterLeft"       ; label justification
  lgres@lgMonoLineLabelFontColor = True               ; one label color

;
; Set specific values for each of 3 parts of legend.
;
  lgres@lgDashIndexes = ldash(0:12:3)             ; line patterns
  lgres@lgLineColors  = lcolors(0:12:3)
  gsn_legend_ndc(wks,5,llabels(0:12:3),0.63,0.14,lgres)

  lgres@lgDashIndexes = ldash(1:13:3)             ; line patterns
  lgres@lgLineColors  = lcolors(1:13:3)
  gsn_legend_ndc(wks,5,llabels(1:13:3),0.39,0.14,lgres)

  lgres@lgDashIndexes = ldash(2:14:3)             ; line patterns
  lgres@lgLineColors  = lcolors(2:14:3)
  gsn_legend_ndc(wks,5,llabels(2:14:3),0.15,0.14,lgres)

  frame(wks)
end


