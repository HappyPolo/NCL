;----------------------------------------------------------------------
; This script shows how to use a "mask" on a file to mask out 
; another variable on the file before plotting.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;---Read the data
   dirc   = "./"                        ; input directory
   filc   = "BBf130PLr2035.nc"
   film   = "masks_t127_tbbr.nc"

   fc     = addfile(dirc+filc, "r")
   fm     = addfile(dirc+film, "r")

   psl    = fc->psl                     ; (time,rgrid)
   latc   = fc->latitude                ; (rgrid)  ... 24572
   lonc   = fc->longitude               ;
   lonc   = where(lonc.gt.180,lonc-360,lonc)
   amask  = fm->$"cbbr.msk"$(0,:)       ; mask, 1 x rgrid

;---Start the graphics
   pltType = "ps"                       ; x11, ps, pdf, png
   if(pltType.eq."png") then
     pltType@wkWidth  = 2000             ; for publication
     pltType@wkHeight = 2000
   end if

   wks = gsn_open_wks(pltType, "ARPEGE_BB_mask")

   res                       = True     ; plot mods desired
   res@gsnMaximize           = True    

   res@gsnDraw               = False    ; will panel plots
   res@gsnFrame              = False    ; later

;---This resource not needed in V6.1.0
;   res@gsnSpreadColors       = True    ; use full range of color map

   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn of contour lines
   res@cnLineLabelsOn        = False    ; turn of contour line labels
   res@cnMaxLevelCount       = 25       ; default is 16
   res@lbLabelBarOn          = False    ; will turn on in panel

   res@cnLevelSelectionMode  = "ManualLevels"

   res@sfXArray              = lonc 
   res@sfYArray              = latc

   res@gsnPolar              = "NH"     ; Northern Hemisphere
   res@mpFillOn              = False

   nt     = 0                           ; arbitrary
   kl     = 13

;---Set some panel resources, like a common labelbar
   pres                  = True
   pres@gsnMaximize      = True
   pres@gsnPanelLabelBar = True
   pres@pmLabelBarWidthF = 0.8

;---Set some "nice" contour levels
   mnmxint = nice_mnmxintvl( min(psl(nt,:)), max(psl(nt,:)), 25, False)
   res@cnMinLevelValF  = mnmxint(0)
   res@cnMaxLevelValF  = mnmxint(1)
   res@cnLevelSpacingF = mnmxint(2)/2.   ; twice as many

;---Create plot of original data
   res@tiMainString    = filc
   plot_orig = gsn_csm_contour_map_polar(wks,psl(nt,:), res)

;---Create plot of masked data
   if(.not.isatt(psl,"_FillValue")) then
     psl@_FillValue = default_fillvalue(typeof(psl))
   end if
   psl(nt,:) = where(amask.eq.0,psl(nt,:),psl@_FillValue)

   res@tiMainString    = filc + " (with mask applied)"
   plot_mask = gsn_csm_contour_map_polar(wks,psl(nt,:), res)

   gsn_panel(wks,(/plot_orig,plot_mask/),(/1,2/),pres)
end
