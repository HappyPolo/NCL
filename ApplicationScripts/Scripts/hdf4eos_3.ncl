;******************************************************************
; hdf4eos_3.ncl
;
; Concepts illustrated:
;   - Plotting EOS-DIS data
;   - Reading HDF4 data
;   - Drawing color filled contours using a selected color map
;   - Spanning the full color map for contour fill
;   - Making the labelbar be vertical
;   - Adding titles to the X/Y axes
;   - Adding attributes to a variable
;   - Setting contour levels using a min/max contour level and a spacing
;   - Paneling three plots on a page
;
;******************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*********************************
begin 
;*********************************
; read in HDF file
;*********************************
   f = addfile("eos.hdf","r")
;*********************************
; read in first channel in EV_250_Aggr1km_RefSB (0.65 um)
;*********************************
   vz  = f->SensorZenith
   sz  = f->SolarZenith
   saz = f->SolarAzimuth

   sz_fl   = sz*0.01
   sz_fl@long_name = "Solar Zenith"

   saz_fl   = saz*0.01
   saz_fl@long_name = "Solar Azimuth"

   vz_fl       = vz*0.01
   vz_fl@long_name = "Viewing Zenith"
;*********************************
; create plot
;*********************************
   wks = gsn_open_wks("png", "hdf4eos")             ; send graphics to PNG file
   plot = new(3,graphic)                            ; create a graphical array

   res                     = True

   res@gsnDraw         = False                      ; do not draw  
   res@gsnFrame        = False                      ; do not advance frame
 
   res@cnFillOn            = True                   ; turn on color
   res@cnFillPalette       = "gui_default"          ; set color map

   res@lbOrientation       = "Vertical"             ; vertical label bar

   res@tiXAxisString       = "pixel"                ; x-axis title
   res@tiYAxisString       = "scanline"             ; y-axis title
;******************************************
; first plot
;******************************************
   plot(0) = gsn_csm_contour(wks,sz_fl,res)      ; contour the variable

   res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
   res@cnMinLevelValF = 140.                     ; min level
   res@cnMaxLevelValF = 170.                     ; max level
   res@cnLevelSpacingF = 5.                      ; contour interval
   plot(1) = gsn_csm_contour(wks,saz_fl,res)
;******************************************
; second plot
;******************************************
   delete(res@cnLevelSelectionMode)  
   plot(2) = gsn_csm_contour(wks,vz_fl,res)   
;******************************************
; panel
;******************************************
   pres          = True                         ; panel mods desired
   pres@gsnFrame = False                        ; don't advance frame so we
                                                ; can add text

   gsn_panel(wks,plot,(/2,2/),pres)             ; create panel plot 

   txres              = True                    ; text mods desired
   txres@txFontHeightF= 0.025                   ; text font height

   gsn_text_ndc(wks,"EOSDIS Quantities",0.5,0.95,txres) ; add text


   frame(wks)                                   ; now advance frame 
end
