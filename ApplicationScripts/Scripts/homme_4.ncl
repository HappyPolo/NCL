load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
      
;=========================================
                                       ; cubed sphere
   dirc   = "./"
   filc   = "camrun.cam2.h0.1995-01-01-00000.nc"
   fc     = addfile(dirc+filc, "r")
   PSL    = fc->PSL                     ; (time,ncol)
   printVarSummary(PSL)
   printMinMax(PSL, True)

   dirw   = "./"                        ; finite volume weight file
   filw   = "map_ne30np4_to_fv0.9x1.25_070727_native_110328.nc"
   fw     = addfile(dirw+filw, "r")
                                        ; interpolate to FV grid
   pslfv  = remap_elements(fw, fc, "PSL", False)  ; (time,lat,lon)

   printVarSummary(pslfv)
   printMinMax(pslfv, True)
                                       ; POP weight file
   dirp   = "./"
   filp   = "map_ne30np4_to_gx1v6_090205_native_110328.nc"
   fp     = addfile(dirp+filp, "r")
                                        ; interpolate to POP grid
   pslpop = remap_elements(fp, fc, "PSL", False)  ; (time,lat,lon)

   printVarSummary(pslpop)
   printMinMax(pslpop, True)

;--------------------------------------------------------
; Get the 2d lat/lon coordinates for the POP grid. Needed for graphics
;--------------------------------------------------------
   lat2d = remap_elements_2d(fp, "lat2d")
   lon2d = remap_elements_2d(fp, "lon2d")

;--------------------------------------------------------
; plot FV and POP interpolated grids
;--------------------------------------------------------

   wks = gsn_open_wks("ps", "homme") 
   gsn_define_colormap(wks,"amwg")      ; choose colormap

   res                       = True     ; plot mods desired
   res@gsnDraw               = False    ; don't draw
   res@gsnFrame              = False    ; don't advance frame
   res@gsnSpreadColors       = True     ; use full range of color map

   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn of contour lines
   res@cnLineLabelsOn        = False    ; turn of contour line labels
   res@mpFillOn              = False
   res@lbLabelBarOn          = False    ; turn off individual lb's
   res@mpCenterLonF          = 180      ; make dateline the center

   resP                      = True                ; modify the panel plot
   resP@txString             = "HOMME: "+filc
   resP@gsnMaximize          = True    
   resP@gsnPanelLabelBar     = True                ; add common colorbar
   resP@lbLabelAutoStride    = True

   nt      = 0                          ; arbitrary; used for plot selection
   plot    = new ( 2, "graphic")

;--- PSL 
   dimpfv  = dimsizes(pslfv)
   nlat    = dimpfv(1)
   mlon    = dimpfv(2)

   res@gsnCenterString = "HOMME:  FV: "+nlat+"x"+mlon
   plot(0) = gsn_csm_contour_map_ce(wks,pslfv(nt,:,:), res)

   dimpop  = dimsizes(pslpop)
   nlat    = dimpop(1)
   mlon    = dimpop(2)
   
   pslpop@lat2d = lat2d
   pslpop@lon2d = lon2d

   res@gsnAddCyclic    = True          ; force cyclic point
   res@gsnCenterString = "HOMME: POP: "+nlat+"x"+mlon
   plot(1) = gsn_csm_contour_map_ce(wks,pslpop(nt,:,:), res)
   gsn_panel(wks,plot,(/2,1/),resP)    ; now draw as one plot
