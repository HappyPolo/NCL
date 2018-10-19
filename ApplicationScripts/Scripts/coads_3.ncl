;***********************************************
; coads_3.ncl
;
; Concepts illustrated:
;   - Plotting COADS (Comprehensive Ocean-Atmosphere Data Set) data
;   - Converting "short" data to "float"
;   - Using a blue-white-red color map
;   - Adding a color to an existing color map
;   - Setting contour levels using a min/max contour level and a spacing
;   - Spanning part of a color map for contour fill
;   - Calculating monthly climatologies
;   - Using "mask" to set a range of values in your data to missing
;   - Drawing subtitles at the top of a plot
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;*****************************************************
; get data
;*****************************************************
  fa     = addfile("air.mean.nc","r")
  fb     = addfile("air.nobs.nc","r")
 
  air  = short2flt( fa->air)                           ; air temp        
  nobs = short2flt( fb->air)                           ; # obs for air
; filter out geographic locations that have < nMin observations
  nMin   = 2                                           ; min # obs
  air    = mask(air,nobs.ge.nMin,True)
;************************************************
; Compute the climatology using a function in contributed.ncl
;************************************************
  yrStrt = 1950
  yrLast = 1979
  moStrt = (yrStrt-1800)*12              ; start subscript
  moLast = (yrLast-1800)*12 + 11         ; last  subscript
  clm = clmMonTLL (air(moStrt:moLast,:,:)) ; monthly climatology
;************************************************
; Compute the anomalies from the climatology just computed
;************************************************
  xAnom = calcMonAnomTLL (air,clm)
;************************************************
; Graphics
;*************************************************
  wks = gsn_open_wks("png","coads")               ; send graphics to PNG file  
  cmap = read_colormap_file("BlWhRe")             ; choose colormap 

  res                      = True                 ; plot options desired
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = cmap(30:70,:)        ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@cnLineLabelsOn       = False                ; turn off line labels

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =  -3.               ; set min contour level
  res@cnMaxLevelValF       =   3.               ; set max contour level
  res@cnLevelSpacingF      =   0.5              ; set contour spacing

  res@gsnMaximize          = True                 ; blow up plot
      
  nt                       = 2200   
  res@gsnRightString       = "time="+xAnom&time(nt)  
  plot  = gsn_csm_contour_map_ce(wks,xAnom(nt,:,:),res) 
end



