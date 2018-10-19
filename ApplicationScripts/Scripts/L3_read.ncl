;----------------------------------------------------------------------
; The ASCII file used in this example was downloaded from:
;
;    ftp://toms.gsfc.nasa.gov/pub/nimbus7
; 
; [Select "data" -> "monthly_averages" -> "aerosol"]
;
; The mixture of text, integers and floats makes this 
; an 'unfriendly' file format. Further, the lack of delimiters
; (e.g. 99999999999...) inhibits generic automatic reading.
; Hence, a custom code must be developed.  
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

;----------------------------------------------------------------------

begin
   netCDF = True
   PLOT   = True

   diri   = "./"                  ; input directory with data
   fils   = systemfunc("cd "+diri+"; ls L3*txt")
   nfils  = dimsizes(fils)

   diro   = "./"                  ; netCDF file directory
   dirp   = "./"                  ; plot   file directory
   pltType= "x11"

   mlon   = 288
   nlat   = 180

   klJump = 12                    ; Each latitude group is 12 lines (rows)
   kint   = 3                     ; each integer is 3 characters

   xi     = new((/nlat,mlon/), "integer", 999)

   do nf=0,nfils-1
      xs = asciiread(diri+fils(nf), -1, "string")
     ;print(xs(0:10))             ; print first 11 lines (arbitrary)

      klStrt = 3                  ; NCL starts at line 0; klStrt is 1st data line
      klLast = klStrt+klJump-1
      
     do nl=0,nlat-1               ; loop over all latitudes
       ;print("------------------------------------------")
       ;print("nl="+nl+"  klStrt="+klStrt +"   klLast="+klLast)
       ;print(xs(klStrt:klLast))  ; print lines (rows) for this latitude

       klon = -1
       do kline=klStrt,klLast     ; loop over each line at this latitude
          if (kline.eq.klLast) then
              kcol = 13           ; number of columns with data values
          else
              kcol = 25
          end if
          kcStrt   = 1            ; characters start in column 1 [NCL is 0 based]
          kcLast   = kint*kcol
         ;print("nl="+nl+"  kline="+kline+"  kcStrt="+kcStrt +"   kcLast="+kcLast)
         ;print("kline="+kline+": "+xs(kline))

         do kc=kcStrt,kcLast,kint ; decode each individual value in this line
            klon = klon+1
            xi(nl,klon) = toint( str_get_cols(xs(kline), kc, kc+kint-1) ) 
           ;print("kc loop: nl="+nl+"  klon="+klon+"  kline="+kline+"  kc="+kc+"  "+(kc+kint-1)+"  "+xi(nl,klon))
         end do                   ; kc

       end do                     ; kline

       klStrt = klLast+1
       klLast = klStrt+klJump-1

     end do                       ; lat  (nl)

;---Add attributes and coordinates

     xc           = tochar(xs(0))
     xi@long_name = tostring(xc(47:64))
  
     lat          = fspan(-89.5, 89.5, nlat)
     lat@units    = "degrees_north"
  
     lon          = fspan(-179.375, 179.375, mlon)
     lon@units    = "degrees_east"
  
     xi!0   = "lat"
     xi!1   = "lon"
     xi&lat =  lat
     xi&lon =  lon
     printVarSummary(xi)
     printMinMax(xi, 0)

     sfx    = get_file_suffix(fils(nf), 0)
     fnam   = sfx@fBase
  
;---Write to NetCDF file
     if (netCDF) then
       
       system("/bin/rm -f "+diro+fnam+".nc") ; remove any pre-existing file
       ncdf = addfile(diro+fnam+".nc" ,"c")  ; open output netCDF file

       fAtt               = True             ; assign file attributes
       fAtt@title         = "TOMS"  
       fAtt@source_file   = fils(nf) 
       fAtt@Conventions   = "None"   
       fAtt@creation_date = systemfunc ("date")        
       fileattdef( ncdf, fAtt )              ; copy file attributes    

       ncdf->TAI = xi
     end if          

;---Plot variable
     if (PLOT) then
       wks     = gsn_open_wks(pltType, fnam)   
      ;gsn_define_colormap(wks,"WhViBlGrYeOrRe")
       gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

       res                  = True          
       res@gsnAddCyclic     = True
       res@gsnMaximize      = True
       res@gsnSpreadColors  = True

       res@cnFillOn         = True               ; color Fill 
       res@cnFillMode       = "RasterFill"       ; Raster Mode
       res@cnLinesOn        =  False             ; Turn off contour lines
       res@cnLineLabelsOn   =  False             ; Turn off contour lines

      ;res@mpCenterLonF     = 180                ; set map center at 180

       res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
       res@cnMinLevelValF       =   1                ; set min contour level
       res@cnMaxLevelValF       =  33                ; one less than max
       res@cnLevelSpacingF      =   1                ; set contour spacing

       res@trGridType           = "TriangularMesh"   ; *faster* graphic rendering

       res@lbLabelStrings       = ispan(0,34,1)   
       res@lbLabelPosition      = "Center"           ; label position
       res@lbLabelAlignment     = "BoxCenters"
       res@pmLegendWidthF       = 0.90

       res@tiMainString         = fnam
       plot = gsn_csm_contour_map_ce(wks, xi, res) ; create plot
     end if

   end do                       ; file (nf)
end
