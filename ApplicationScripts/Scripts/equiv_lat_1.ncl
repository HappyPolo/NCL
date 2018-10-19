;*************************************************
; equiv_lat_1.ncl
;*************************************************
;
; Concepts illustrated:
;   - Contouring data located at "equivalent latitudes"
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; Read the input data
;************************************************
   diri = "./"
   fili = "PV_Eqlat_600K_22503_2403.nc"
   f    = addfile(diri+fili, "r")
   print(f)

;************************************************
; make a plot
;*******************************************
   pltType              = "png"    
   pltName              = "equiv_lat"    

   wks = gsn_open_wks(pltType, pltName)

   res                     = True            ; Plot mods desired.
   res@gsnDraw             = False           ; don't draw
   res@gsnFrame            = False           ; don't advance frame

   res@gsnMaximize         = True            ; Maximize plot
  ;res@cnLinesOn           = False           ; turn off contour lines
   res@cnFillOn            = True            ; color plot desired
   res@cnFillPalette       = "amwg"          ; set color map
   res@mpFillOn            = False
   res@lbLabelBarOn        = False           ; turn off individual cb's

   res@gsnPolar            = "NH"            ; specify the hemisphere
   res@mpMinLatF           =  40

;************************************************
; create panel resources
;************************************************
   plot = new (2, "graphic")
   resP                     = True                ; modify the panel plot
   resP@gsnPanelLabelBar    = True                ; add common colorbar
  ;resP@gsnPaperOrientation = "portrait"          ; force portrait
  ;resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

   do nt=0,1
      time = f->time(nt)
      resP@txString         = fili +":  t="+time

      x    = f->vortpot_0600K(nt,:,:)   ; (48,64)

    ;;symMinMaxPlt (x,18,False,res)     ; make symmetric

      res@gsnLeftString = "Conventional Latitudes"
      plot(0) = gsn_csm_contour_map_polar(wks, x, res)  ; standard lat

      elat = f->eqlat_0600K(nt,:,:)     ; (48,64)  
      elon = conform_dims(dimsizes(elat), x&lon, 1)

      if (nt.eq.0) then                 ; general information
          printVarSummary( x )
          printVarSummary( elat )
          printVarSummary( elon )
      end if

      res@sfXArray   = ndtooned(elon)
      res@sfYArray   = ndtooned(elat)
      x1d            = ndtooned(x)
     ;copy_VarAtts(x, x1d)

      res@gsnLeftString  = "Equivalent Latitudes"

      plot(1) = gsn_csm_contour_map_polar(wks,x1d,res)
      delete(res@sfXArray)  
      delete(res@sfYArray)
    end do  
      gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

;      delete(res@sfXArray)
;      delete(res@sfYArray)
end
