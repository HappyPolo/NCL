; ===========================================
; panel_attach_10.ncl
; ===========================================
; Concepts illustrated:
;   - Drawing Hovmueller plots
;   - Attaching plots along the Y axis
;   - Using a blue-white-red color map
;   - Drawing zonal average plots
;   - Paneling attached plots
;   - Using time_axis_labels to generate nice "time" labels on the Y axis.
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

; ===========================================
; Function to generate Hovmueller plot,
; given min/max longitude range.
; ===========================================
function create_hov_plot(wks,minlon,maxlon)
local dir, f, scale, chi, hres
begin
  dir   = ncargpath("data") + "/cdf/"
  f     = addfile (dir+"chi200_ud_smooth.nc","r")
  scale = 1.e6                                    ; scale factor
  chi   = f->CHI                                  ; get chi
  chi   = chi/scale                               ; scale for convenience

  hres                          = True             ; plot mods desired
  hres@gsnDraw                  = False            ; don't draw yet
  hres@gsnFrame                 = False            ; don't advance frame yet

  hres@cnFillOn                 = True             ; turn on color fill
  hres@cnFillPalette            = "BlWhRe"
  hres@cnInfoLabelOn            = False
  hres@cnLineLabelsOn           = False
  
  hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
  hres@cnMinLevelValF           = -10.             ; minimum level
  hres@cnMaxLevelValF           =  10.             ; maximum level
  hres@cnLevelSpacingF          =   2.             ; contour spacing
  hres@lbLabelBarOn             = False
;  hres@tiMainString             = "Longitude " + minlon + " to " + maxlon

;---Fix X axis labels so they don't run into each other.
  values = ispan(minlon,maxlon-30,30)
  labels = "" + values
  labels = where(values.lt.0,abs(values)+"W",labels)
  labels = where(values.gt.180,abs(values-360)+"W",labels)
  labels = where(values.gt.0.and.values.lt.180,labels+"E",labels)

  hres@tmXBMode                 = "Explicit"
  hres@tmXBValues               = values
  hres@tmXBLabels               = labels

;---Add nice time labels on Y axis.
  chi&time@units    = chi&time@short_name    ; Fix the time units
  chi&time@units = "days since 1950-12-1"
  restick           = True
  restick@ttmFormat = "%c %d %Y"
  restick@ttmAxis   = "YL"

  time_axis_labels(chi&time,hres,restick) ; call the formatting procedure

;---Create the plot and return
  plot = gsn_csm_hov(wks, chi(:,{minlon:maxlon}), hres)

 return(plot)
end

; ===========================================
; Function to generate zonal plot.
; ===========================================
function create_zonal_plot(wks)
local dir, f, scale, chi, x, y, xyres
begin
  dir   = ncargpath("data") + "/cdf/"
  f     = addfile (dir+"chi200_ud_smooth.nc","r")
  scale = 1.e6                                    ; scale factor
  chi   = f->CHI                                  ; get chi
  chi   = chi/scale                               ; scale for convenience

  x = dim_avg(chi)                    ; average chi across longitude

  xyres                 = True         ; xy plot mods desired
  xyres@vpWidthF        = .20          ; set width of second plot
  xyres@tmXBMinorOn     = False        ; no minor tickmarks
  xyres@tmXBLabelStride = 2            ; label stride

  xyres@gsnDraw         = False        ; don't draw yet
  xyres@gsnFrame        = False        ; don't advance frame yet

  xyres@trXMinF         = min(x)
  xyres@trXMaxF         = max(x)
  xyres@trYMinF         = min(chi&time)
  xyres@trYMaxF         = max(chi&time)

  xyres@gsnCenterString = "Zonal Ave"  ; add title
  xyres@txFontHeightF   = .015         ; change font height

;---Create the plot and return
  plot = gsn_csm_xy(wks, x,chi&time,xyres)

  return(plot)
end

; ===========================================
; Main code
; ===========================================
begin
 wks  = gsn_open_wks ("png", "panel_attach" ) ; send graphics to PNG file

 hov_plot1 = create_hov_plot(wks,0,90)
 hov_plot2 = create_hov_plot(wks,90,180)
 hov_plot3 = create_hov_plot(wks,180,270)
 hov_plot4 = create_hov_plot(wks,270,360)

;---Create four of these for attaching
 zonal_plot1 = create_zonal_plot(wks)
 zonal_plot2 = create_zonal_plot(wks)
 zonal_plot3 = create_zonal_plot(wks)
 zonal_plot4 = create_zonal_plot(wks)

;---Attach plots along Y axis
 attach_id1 = gsn_attach_plots(hov_plot1,(/zonal_plot1/),True,True)
 attach_id2 = gsn_attach_plots(hov_plot2,(/zonal_plot2/),True,True)
 attach_id3 = gsn_attach_plots(hov_plot3,(/zonal_plot3/),True,True)
 attach_id4 = gsn_attach_plots(hov_plot4,(/zonal_plot4/),True,True)

;---Panel all four plots
 pres                    = True
 pres@gsnMaximize        = True
 pres@gsnPanelLabelBar   = True
 pres@pmLabelBarWidthF   = 0.8
 pres@lbLabelFontHeightF = 0.008
 pres@gsnPanelMainString = "chi200_ud_smooth.nc"
 gsn_panel(wks,(/hov_plot1,hov_plot2,hov_plot3,hov_plot4/),(/2,2/),pres)
end
