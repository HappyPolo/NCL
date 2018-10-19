;----------------------------------------------------------
;        MAIN: Requires 6.4.0 or higher
;----------------------------------------------------------
   diri  = "./"
   fili  = "wrfout_d01_2013-05-17_12"

   a     = addfile(diri+fili ,"r")             ;[Time|1] x [bottom_top|40] x [south_north|324] x [west_east|414]
                                               ;     0            1                2                  3

   th    = wrf_user_getvar(a,"theta",-1)      ; potential temperature (degK)
   z     = wrf_user_getvar(a,"z",-1)          ; model height
   ua    = wrf_user_getvar(a,"ua"   ,-1)      ; u at mass grid points
   va    = wrf_user_getvar(a,"va"   ,-1)      ; v at mass grid points

   dim   = dimsizes(th)
   ntim  = dim(0)
   klvl  = dim(1)
   nlat  = dim(2)
   mlon  = dim(3)

;--- Use explict function to calculate the Brunt-Vaisala frequency

   brunt = brunt_vaisala_atm(th, z, 0, 1)     ; use function

   printVarSummary(brunt)
   printMinMax(brunt, 0)
   print("-----------------------------------------")

;--- Use explict function to calculate the Richardson number

   rin  = rigrad_bruntv_atm(th, ua, va, z, 0, 1 )

   printVarSummary(rin)
   printMinMax(rin, 0)
   print("-----------------------------------------")

;--- Read latitudes. The 'eady_growth_rate' function requires that 'lat' and 'th' agree
;    Use 'conform' the propogate the lat values

   xlat = a->XLAT                          ; [Time|1] x [south_north|324] x [west_east|414] 
   XLAT = conform(th, xlat, (/0,2,3/))     ; (1,40,324,414) => dim number (0,1,2,3)

;--- Compute Eady growth rate

   egr  = eady_growth_rate(th, ua, z, XLAT, 0, 1)

   printVarSummary(egr)
   printMinMax(egr, 0)
   print("-----------------------------------------")

;****************************************************
;--- plot
;****************************************************

   lat2d = xlat(0,:,:)            ; commonly used variable names 
   lon2d = a->XLONG(0,:,:)
   znu   = a->ZNU                 ; used for plot label

   wks = gsn_open_wks("png","BrRiEgr")              ; send graphics to PNG file

;---Set some basic plot options

   res               = True
   res@gsnMaximize   = True       ; maximize plot in frame
   res@gsnAddCyclic  = False
   res@tiMainString  = fili

   res@cnFillOn      = True  
   res@cnLinesOn     = False
  ;res@cnFillMode    = "RasterFill"                 ; slow here
   res@cnFillMode    = "CellFill"                   ; faster

   res@mpProjection  = "CylindricalEquidistant" 

   res@mpMinLatF     = min(lat2d)          
   res@mpMaxLatF     = max(lat2d)
   res@mpMinLonF     = min(lon2d)
   res@mpMaxLonF     = max(lon2d)
   res@mpFillOn      = False

   res@sfXArray      = lon2d
   res@sfYArray      = lat2d

; specify a level or levels ... within boundary layer

   klStrt = 5
   klLast = 5
   nt     = 0

;--- Eady growth rate (1/day)

   egr        = egr*86400
   egr@units  = "1/day"

   res@cnFillPalette        = "precip2_17lev"
   res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
   res@cnMinLevelValF       =  0.5               ; set min contour level
   res@cnMaxLevelValF       =  4.0               ; set max contour level
   res@cnLevelSpacingF      =  0.25              ; set contour spacing

   do kl=klStrt,klLast
      res@gsnCenterString = "znu="+znu(nt,kl)
      res@gsnRightString  =  egr@units
      contour = gsn_csm_contour_map(wks,  egr(nt,kl,:,:),res)
   end do

;--- Brunt-Vaisala (scaled); for 'fun' reverse color Pallette

   brunt  = brunt*1e2
   res@cnMinLevelValF       =  0.00              ; set min contour level
   res@cnMaxLevelValF       =  3.00              ; set max contour level
   res@cnLevelSpacingF      =  0.20              ; set contour spacing

   cmap = read_colormap_file( res@cnFillPalette ) 
   res@cnFillPalette := cmap(::-1,:)     ; reverse color map

   do kl=klStrt,klLast
      res@gsnCenterString = "znu="+znu(nt,kl)
      res@gsnRightString  = "1e2 x "+brunt@units
      contour = gsn_csm_contour_map(wks,brunt(nt,kl,:,:),res)
   end do

;--- Gradient Richardson number

   res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
   res@cnMinLevelValF       = -1.5               ; set min contour level
   res@cnMaxLevelValF       =  1.5               ; set max contour level
   res@cnLevelSpacingF      =  0.25              ; set contour spacing

   rin@_FillValue = 1e20
   rin = where(abs(rin).gt.res@cnMaxLevelValF, rin@_FillValue, rin)  

   do kl=klStrt,klLast
      res@gsnCenterString = "znu="+znu(nt,kl)
      res@gsnRightString  = ""
      contour = gsn_csm_contour_map(wks,  rin(nt,kl,:,:),res)
   end do
