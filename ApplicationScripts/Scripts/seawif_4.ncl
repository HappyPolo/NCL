;***************************************************************
; seawif_4.ncl
;
; Concepts illustrated:
;   - Reading multiple files with data from SeaWIFS directory
;   - Using information in file attributes to create complete variable
;     Information was provided by 'ncl_filedump'
;   - Use 'stat_dispersion' to examine the variable distribution
;   - Create standard cylindrical equidistant plot
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;---------------------------------------------------------------------
;   %> ncl_filedump S19991821999212.L3m_MO_CHL_chlor_a_9km.hdf | less
;
;     [SNIP]
;     Latitude_Step : 0.08333334
;     Longitude_Step : 0.08333334
;     SW_Point_Latitude : -89.95834
;     SW_Point_Longitude : -179.9583
;     [SNIP]
;     Parameter : Chlorophyll a concentration
;     Units : mg m^-3
;
;      dimensions:
;          fakeDim0 = 2160
;          fakeDim1 = 4320
;       variables:
;          float l3m_data ( fakeDim0, fakeDim1 )
;             Fill :    -32767
;             Scaling :    linear
;             Scaling_Equation :    (Slope*l3m_data) + Intercept = Parameter value
;             Slope :     1
;             Intercept :     0
;             hdf_name :    l3m_data
;-----------------------------------------------------------------------    

   diri = "./"
   fili = systemfunc("cd "+diri+" ; ls S*9km")
   nfili= dimsizes(fili)

;--------------------------------------------------------
; Span all files
;--------------------------------------------------------

   f    = addfiles (diri+fili+".hdf" , "r")  ; read as hdf
   ListSetType (f, "join") 

   x    = f[:]->l3m_data
   printVarSummary(x)

;--------------------------------------------------------
; Add attributes
;--------------------------------------------------------

   x@long_name = "Chlorophyll a concentration"   ; =f[0]@Parameter
   x@units     = "mg/m^3"                        ; =f[0]@Units
   x@_FillValue= x@Fill

;--------------------------------------------------------
; Add coordinate information
;--------------------------------------------------------

   x!0  = "time"          ; name dimensions
   x!1  = "lat"
   x!2  = "lon"

   dimx = dimsizes(x)
   ntim = dimx(0)
   nlat = dimx(1)
   mlon = dimx(2)

   dlat = 0.08333334      ; = f[0]@Latitude_Step
   dlon = 0.08333334      ; = f[0]@Longitude_Step

   lat  =  89.95834 - ispan(0,nlat-1,1)*dlat
   lon  = -179.9583 + ispan(0,mlon-1,1)*dlon

   lat!0 = "lat"
   lon!0 = "lon"
   lat@units = "degrees_north"
   lon@units = "degrees_east"
   printVarSummary(lat)
   printVarSummary(lon)

   x&lat = lat
   x&lon = lon

   printVarSummary(x)
   print("x: min="+min(x)+"   max="+max(x))

;--------------------------------------------------------
; Look at the variable's distribution. Good to do for satellite data
; If 'x' is very large, this can be slow. However, it need only be done
; once. Then it can be removed or commented (as below)
;--------------------------------------------------------

  ;opt = True
  ;opt@PrintStat = True
  ;statb = stat_dispersion(x, opt )

;; (0)      [2]             Min=0.00075
;; (0)      [3]          LowDec=0.04312
;; (0)      [4]          LowOct=0.04836
;; (0)      [5]          LowSex=0.05716
;; (0)      [6]     LowQuartile=0.07647
;; (0)      [7]          LowTri=0.09768
;; (0)      [8]          Median=0.1455
;; (0)      [9]         HighTri=0.20626
;; (0)      [10]   HighQuartile=0.25756
;; (0)      [11]        HighSex=0.35286
;; (0)      [12]        HighOct=0.44192
;; (0)      [13]        HighDec=0.53347
;; (0)      [14]            Max=99.9897
;; (0)      [15]          Range=99.9889

;*********************************************************
; create plot
;*********************************************************
  wks = gsn_open_wks("png","seawifs")              ; send graphics to PNG file
   
  res                  = True                      ; plot mods desired
  res@gsnMaximize      = True
  
  res@cnFillOn         = True                      ; turn on color
  res@cnFillPalette    = "BlAqGrYeOrReVi200"       ; set color map
  res@cnLinesOn        = False                     ; Turn off contour lines
  res@cnFillMode       = "RasterFill"              ; Raster Mode

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 0.05               ; set min contour level
  res@cnMaxLevelValF       = 0.50               ; set max contour level
  res@cnLevelSpacingF      = 0.025              ; set contour spacing

  res@mpFillOn             = False              ; don't use gray over land

  do nf=0,0   ; nfili-1                         ; plot onlt 1st file for demo
     res@tiMainString     = fili(nf)      
     plot = gsn_csm_contour_map(wks,x(nf,:,:), res)  
  end do
