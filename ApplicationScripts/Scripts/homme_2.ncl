;****************************************************
; homme_2.ncl
;****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 


   dirc   = "./"                        ; input directory
   filc   = "camrun.cam2.h0.1995-01-01-00000.nc"

   fc     = addfile(dirc+filc, "r")
   latc   = fc->lat                     ; (ncol)  ... 48602
   lonc   = fc->lon                     ;

   varc   = (/ "PSL", "T" /)            ; variables to be plotted
   nvarc  = dimsizes( varc )

   wks = gsn_open_wks("png" ,"homme")   ; send graphics to PNG file

   res                       = True     ; plot mods desired
   res@gsnMaximize           = True     

  ;res@gsnAddCyclic          = False     
   res@cnFillOn              = True     ; turn on color fill
   res@cnFillPalette         = "amwg"   ; set color map
   res@cnLinesOn             = False    ; turn of contour lines
   res@cnLineLabelsOn        = False    ; turn of contour line labels
   res@mpFillOn              = False
   res@mpCenterLonF          = 210      
   res@sfXArray              = lonc 
   res@sfYArray              = latc
   res@tiMainString          = "HOMME: "+filc

   nt     = 0                           ; arbitrary
   kl     = 13

   do nv=0,nvarc-1
      xc   = fc->$varc(nv)$             ; (time, ncol) or (time, lev, ncol)
      rank = dimsizes( dimsizes(xc) )

      if (rank.eq.2) then
          plot = gsn_csm_contour_map_ce(wks,xc(nt,:), res)     ; make 1D array
      else
          plot = gsn_csm_contour_map_ce(wks,xc(nt,kl,:), res)
      end if

      delete(xc)                        ; may change size next iteration
   end do
