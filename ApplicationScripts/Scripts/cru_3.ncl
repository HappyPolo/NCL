;*****************************************************
; cru_3.ncl
;
; Concepts illustrated:
;   - Plotting CRU (Climate Research Unit) data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Spanning the full color map for contour fill
;   - Turning off contour lines
;   - Turning off contour line labels
;   - Converting "short" data to "float"
;   - Paneling three plots with two labelbars
;   - Paneling three plots vertically on a page
;   - Changing the contour level spacing
;   - Creating a difference plot
;
;*****************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;*****************************************************
;begin                        ; optional for main driver
;*****************************************************
; Read Absolute temperatures for the base period 1961-90
; data are stored as type "short" ... convert to float
;***************************************************
  f  = addfile("absolute.nc","r")
  T  = short2flt( f->tem )                             ; contributed.ncl
  T@long_name = "Temperature" ; change default is too long

;***************************************
; Difference the February and August months
; NCL's standard subscripts start at 0, so Jan=0, Feb=1, ... 
;***************************************  
  tdif = T(7,:,:)                   ; trick to copy all meta data
  tdif = T(7,:,:) - T(1,:,:)        ; Aug-Feb
  tdif@long_name = "Difference"     ; assign new attribute 

;***************************************
; create plot
;***************************************  
  plot= new (2, graphic)                        ; create graphical array

  wks = gsn_open_wks("ps","cru")                ; open ps file
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") 

;***************************************
; first two individual plots
;***************************************  
  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; color contours
  res@cnLinesOn            = False              ; default is True
  res@cnLineLabelsOn       = False              ; default is True

;---This resource not needed in NCL V6.1.0
  res@gsnSpreadColors      = True               ; use full range of colormap

  res@lbLabelBarOn         = False              ; turn off individual lb's 

  res@cnLevelSpacingF      =  4.0               ; manually set contour spacing

  res@gsnDraw              = False              ; don't draw yet 
  res@gsnFrame             = False              ; don't advance frame yet

  res@mpCenterLonF         = 180                ; centers plot at 180 vs 0

  res@gsnCenterString        = "February"
  plot(0) = gsn_csm_contour_map_ce(wks,T(1,:,:),res)
  res@gsnCenterString        = "August"
  plot(1) = gsn_csm_contour_map_ce(wks,T(7,:,:),res)

;***************************************
; panel first two plots
;***************************************
  resP                     = True
  resP@gsnPanelLabelBar    = True       ; common label bar
  resP@gsnFrame            = False      ; don't advance frame yet
  resP@lbOrientation       = "vertical" ; vertical label bar

;---This resource defaults to True in NCL V6.1.0
  resP@lbLabelAutoStride   = True       ; nice label bar labels

; use PanelBottom to tell the plot to only draw in the top part of the 
; page. since there are two plots here, and we have limited the plot to the 
; upper 0.6 of the page, each plot will have a size 0.3.
  resP@gsnPanelBottom      = 0.4        ; move bottom up from 0.0 to 0.4

  gsn_panel(wks,plot,(/2,1/),resP)
;***************************************
; create difference plot
;***************************************
  res@gsnCenterString        = "AUG-FEB"
  res@cnLevelSpacingF        = 2.        ; contour interval
  plt2 = gsn_csm_contour_map_ce(wks,tdif,res)

;***************************************
; create panel of just third plot to keep aspect ratio the same as the panel 
; above
;***************************************
  resP2                     = True
  resP2@gsnPanelLabelBar    = True       ; common label bar
  resP2@gsnPanelTop         = 0.4        ; draw up to the bdry of upper plot
  resP2@gsnPanelBottom      = 0.1        ; move bottom up so size is 0.3
  resP2@gsnFrame            = False      ; don't advance frame yet
  resP2@lbOrientation       = "vertical" ; vertical label bar
  resP2@lbLabelAutoStride   = True       ; nice label bar labels

  gsn_panel(wks,plt2,(/1,1/),resP2)
  frame(wks)
;end                                     ; only if 'begin' is present

