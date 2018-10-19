load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;---Read the data
   dirc   = "./"                        ; input directory
   filc   = "BBf130PLr2035.nc"

   fc     = addfile(dirc+filc, "r")
   latc   = fc->latitude                ; (rgrid)  ... 48602
   lonc   = fc->longitude               ;

;; print("latc: min="+min(latc)+"  max="+max(latc))
;; print("lonc: min="+min(lonc)+"  max="+max(lonc))

;---Start the graphics
   pltType = "ps"                       ; x11, ps, pdf, png
   pltName = "ARPEGE_BB"       
   pltCol  = "amwg"

   wks = gsn_open_wks(pltType, pltName) 
   gsn_define_colormap(wks,pltCol)      ; choose colormap

   res                       = True     ; plot mods desired
   res@gsnMaximize           = True    

;---This resource not needed in V6.1.0
;   res@gsnSpreadColors       = True     ; use full range of color map

   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn of contour lines
   res@cnLineLabelsOn        = False    ; turn of contour line labels
   res@mpFillOn              = False
  ;res@mpCenterLonF          = 210      
   res@lbLabelAutoStride     = True
   res@sfXArray              = lonc 
   res@sfYArray              = latc
   res@tiMainString          = filc

   varc   = (/ "psl", "pr" /)           ; variables to be plotted
   nvarc  = dimsizes( varc )
   nt     = 0                           ; arbitrary
   kl     = 13

;---Loop across variables chosen and create a plot of each.
   do nv=0,nvarc-1
      xc   = fc->$varc(nv)$             ; (time, ncol) or (time, lev, ncol)
      rank = dimsizes( dimsizes(xc) )

      if (varc(nv).eq."pr") then 
          xc@_FillValue = 1e20
          xc = where(xc.le.2e-05, xc@_FillValue, xc) 
          xc = xc*86400
          xc@units = "mm/day"
      end if

      printVarSummary(xc)
      printMinMax(xc,0)

      if (rank.eq.2) then
          plot = gsn_csm_contour_map_ce(wks,xc(nt,:), res)
      else
          plot = gsn_csm_contour_map_ce(wks,xc(nt,kl,:), res)
      end if

      delete(xc)                        ; may change size next iteration
   end do

end
