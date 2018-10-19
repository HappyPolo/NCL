;***********************************************************
; climo_6.ncl
;
; Concepts illustrated:
;   - Calculating climatologies spanning user-specified years
;   - Getting the indices where data falls in a particular range
;   - Using "landsea_mask" to create a land/sea mask for your dataset
;   - Using "mask" to set land or ocean values in your data to missing
;   - Converting "string" time values using cd_calendar
;   - Converting "short" data to "float"
;   - Selecting a different color map
;   - Masking contour lines so they don't go through contour labels
;   - Paneling three plots vertically on a page
;   - Overlaying line contours on filled contours
;
;***********************************************************
; Generate Sample Climatologies as in Fig 1
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

begin
   plev    = 850                              ; 850hPa

   ymStrt  = 198001                           ; start yyyymm
   ymLast  = 199912                           ; last  
   yrStrt  = ymStrt/100
   yrLast  = ymLast/100

   wksType = "png"                            ; send graphics to PNG file
   wksName = "climo"                          ; ": "+yrStrt+"_"+yrLast
  
;  diri    = "/Users/shea/Data/AMWG/"         ; input directory   
   diri    = "./"                             ; new input directory

;***********************************************************
; Read year-month SST; Create climatology for desired period  
; ----
; This SST dataset has SST over land ... mask land using NCL's
; builtin mask. The landsea.nc file is distributed with NCL.
;***********************************************************

   fili    = "MODEL.SST.HAD187001-198110.OI198111-200803.nc"
   f       = addfile (diri+fili , "r")                          

   date    = f->date                          ; yyyymmdd (all times)
   yyyymm  = date/100                         ; yyyymm

   ntStrt  = ind(yyyymm.eq.ymStrt)            ; index start
   ntLast  = ind(yyyymm.eq.ymLast)            ; index last 
   sst     = f->SST(ntStrt:ntLast,:,:)        ; year-month
                                              ; Climatology 
   sstClm  = clmMonTLL( sst)                  ; (month,lat,lon)
                                              ; (12,lat,lon)
   delete(yyyymm)
   delete(date)
   delete(sst)
                     ; land-sea mask distributed with NCL
   fmsk    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   
   lsmask  = landsea_mask(fmsk->LSMASK,sstClm&lat,sstClm&lon)  
   sstClm  = mask(sstClm,lsmask.eq.1,False)  ; mask out land points

  ;printVarSummary( sstClm )
  ;printMinMax( sstClm, True )
;***********************************************************
; Read year-month PRC; Create climatology for desired period
;***********************************************************

   fili    = "precip.mon.mean.nc"
   f       = addfile (diri+fili , "r")                          

   time    = f->time                          ; days since ...
   yyyymm  = cd_calendar(time, -1)            ; convert to yyyymm

   ntStrt  = ind(yyyymm.eq.ymStrt)            ; index start
   ntLast  = ind(yyyymm.eq.ymLast)            ; index last 
   prc     = f->precip(ntStrt:ntLast,:,:)     ; year-month
                                              
   prcClm  = clmMonTLL( prc)                  ; Climatology
                                              ; (12,lat,lon)
   delete(yyyymm)
   delete(time)
   delete(prc)

   printVarSummary( prcClm )
   printMinMax( prcClm, True )

;***********************************************************
; Read year-month U  ; Create climatology for desired period
; Convert type short to float
;***********************************************************

   fili    = "uwnd.mon.mean.nc"
   f       = addfile (diri+fili , "r")                          

   time    = f->time                          ; days since ...
   yyyymm  = cd_calendar(time, -1)            ; convert to yyyymm

   ntStrt  = ind(yyyymm.eq.ymStrt)            ; index start
   ntLast  = ind(yyyymm.eq.ymLast)            ; index last 
   uwnd    = short2flt( f->uwnd(ntStrt:ntLast,{plev},:,:) ) 
                                              
   uwndClm = clmMonTLL( uwnd )                ; Climatology
                                              ; (12,lat,lon)
   delete(time)
   delete(yyyymm)
   delete(uwnd)

  ;printVarSummary( uwndClm )
  ;printMinMax( uwndClm, True )

;***********************************************************
; Read year-month OLR; Create climatology for desired period
; Convert type short to float
;***********************************************************

   fili    = "olr.mon.mean.nc"
   f       = addfile (diri+fili , "r")                          

   time    = f->time                          ; days since ...
   yyyymm  = cd_calendar(time, -1)            ; convert to yyyymm

   ntStrt  = ind(yyyymm.eq.ymStrt)            ; index start
   ntLast  = ind(yyyymm.eq.ymLast)            ; index last 
   olr     = short2flt( f->olr(ntStrt:ntLast,:,:) )  ; year-month
                                              
   olrClm  = clmMonTLL( olr )                 ; Climatology
                                              ; (12,lat,lon)
   delete(yyyymm)
   delete(time)
   delete(olr)

  ;printVarSummary( olrClm )
  ;printMinMax( olrClm, True )

;************************************************
; plots ; Compute 6-month climatologies
;************************************************
                                              ; (2,6)
  season   = (/ (/ 5, 6, 7, 8, 9,10/) \       ; May-Oct [summer]
              , (/ 1, 2, 3, 4,11,12/) /)      ; Nov-Apr [winter]
  i_season = season - 1                       ; NCL indices
  season_label = (/ "May-Oct Climatology", "Nov-Apr Climatology"/)

  plot = new ( 3, "graphic")
  wks = gsn_open_wks(wksType, wksName)        
  cmap = read_colormap_file("amwg")

;************************************************
; resource list for first (color) data array
;************************************************
  res1                      = True
  res1@gsnDraw              = False              ; don't draw
  res1@gsnFrame             = False              ; don't advance frame
  res1@gsnStringFontHeightF = 0.0125             ; make larger than default

  res1@lbOrientation        = "Vertical"         ; vertical label bar
  res1@lbLabelFontHeightF   = 0.01               ; make labels larger
  res1@pmLabelBarOrthogonalPosF = -0.025         ; move closer to plot

  res1@mpCenterLonF         = 180.               ; center plot at 180

  res1@mpMinLonF            =  30.               ; select a subregion
  res1@mpMaxLonF            = 300.
  res1@mpMinLatF            = -35. 
  res1@mpMaxLatF            =  35.

  res1@mpLandFillColor      = "background"       ; color of land
  res1@cnFillDrawOrder      = "Predraw"         

;************************************************
; resource list for second (contour only) data array
;************************************************
  res2                      = True
; res2@cnLevelSpacingF      =   2.              ; set contour spacing
  res2@cnLevelSpacingF      =   1.              ; set contour spacing
  res2@cnInfoLabelOn        = False             ; do not want
  res2@cnLineLabelsOn       = True
  res2@cnLabelMasking       = True

;************************************************
; resource list for panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnMaximize         = True                ; make large

  delete(sstClm@long_name)                       ; do not want
  res1@gsnRightString      = "SST (C): contour"

  res1@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels

  do ns=0,1                                     ; 2 seasons

     res1@cnLevels             := ispan(180,300,10)
     res1@cnFillPalette        := cmap               ; use full color map
     res1@gsnLeftString        = "OLR: ("+olrClm@units+")"
     
     olrSeaClm = dim_avg_Wrap( olrClm(lat|:,lon|:,month|i_season(ns,:)) )
     sstSeaClm = dim_avg_Wrap( sstClm(lat|:,lon|:,month|i_season(ns,:)) )
     plot(0)   = gsn_csm_contour_map_overlay(wks,olrSeaClm,sstSeaClm,res1,res2)

     res1@gsnLeftString        = "NCEP: U: ("+uwndClm@units+")"
     res1@cnLevels             := ispan(-10,16,2)
     uwndSeaClm= dim_avg_Wrap(uwndClm(lat|:,lon|:,month|i_season(ns,:)) )
     plot(1)   = gsn_csm_contour_map_overlay(wks,uwndSeaClm,sstSeaClm,res1,res2)

     res1@gsnLeftString        = "GPCP PRC: ("+prcClm@units+")"
     ;res1@cnLevels             = (/1,2,4,6,8,10,12,14/)
     res1@cnLevels             := ispan(2,13,1)             
     res1@cnFillPalette        := cmap(4:,:)        ; Skip first four colors
     prcSeaClm = dim_avg_Wrap( prcClm(lat|:,lon|:,month|i_season(ns,:)) )
     plot(2)   = gsn_csm_contour_map_overlay(wks, prcSeaClm,sstSeaClm,res1,res2)

     resP@txString  = season_label(ns) +": "+ yrStrt+"-"+yrLast
     gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end do
end
