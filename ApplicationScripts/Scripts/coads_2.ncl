;***********************************************
; coads_2.ncl
;
; Concepts illustrated:
;   - Plotting COADS (Comprehensive Ocean-Atmosphere Data Set) data
;   - Converting "short" data to "float"
;   - Setting contour levels using a min/max contour level and a spacing
;   - Spanning part of a color map for contour fill
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Turning on map fill
;   - Using "mask" to set a range of values in your data to missing
;   - Writing data to a NetCDF file using the easy but inefficient method
;   - Paneling two plots on a page
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; this script demonstrates a way to create a user variable list that will 
; control a larger processing script. After creating a climatology, 
; options exist to create a plot or output a netCDF file.
;************************************************
; USER INPUT
;************************************************
  yrStrt = 1950                                 ; years for climatology
  yrLast = 1989
  nMin   = 2                                    ; min # obs
  
  vNam   = "air"                                ; variable
  vType  = "mean"                               ; statistic type

; create plots?
  plClm  = True                                 ; create plots?
  plType = "png"                                ; send graphics to PNG file
  plDir  = "./"                                 ; output dir for plots
  plFile = "coads"                              ; name for graphics file
; output netCDF? 
  ncClm  = False                                ; create netCDF?
  ncDir  = "./"                                 ; output dir for netCDF file
;************************************************
; NO USER INPUT AFTER THIS POINT
;************************************************
; Read the files
;************************************************
  print(" ")
  print("======> Reading:       "+systemfunc("date")+" <====== " )
  print(" ")
  
  
  moStrt = (yrStrt-1800)*12                      ; start subscript
  moLast = (yrLast-1800)*12 + 11                 ; last  subscript
  
  fila   = vNam+"."+vType+".nc"                  ; create file names
  filb   = vNam+".nobs.nc"
 
  fa     = addfile(fila,"r")                ; open file
  fb     = addfile(filb,"r")                ; open file
  
  a      = short2flt(fa->$vNam$(moStrt:moLast,:,:)) ; convert short-to-float 
  
; only read in variables that have when  nobs > 1
  if (nMin.gt.1) then
    nobs   = short2flt(fb->$vNam$(moStrt:moLast,:,:))
    a      = mask(a, nobs.ge.nMin, True)
  end if
;************************************************
; Compute the climatology using functions in contributed.ncl
;************************************************
  print(" ")
  print("======> Climatology: "+systemfunc("date")+" <====== " )
  print(" ")
  
  clm = clmMonTLL (a)            ; monthly climatology
  std = stdMonTLL (a)            ; monthly interannual variability
;************************************************
; Graphics
;*************************************************
  if (plClm) then
    print(" ")
    print("======> plClm:       "+systemfunc("date")+" <====== " )
    print(" ")
    months = (/"January", "February", "March", "April" ,"May", "June", \
    "July", "August","September", "October", "November","December" /)
    
    plot   = new (2, graphic)                     ; create graphical array
    
    wks = gsn_open_wks(plType,plDir+plFile)       ; open file to plot  
    cmap = read_colormap_file("rainbow")          ; select colormap

    res                      = True               ; plot options desired

    res@cnFillOn             = True               ; turn on color fill
    res@cnFillPalette        = cmap(48:,:)        ; set filtered color map
;    res@cnInfoLabelOn        = False              ; no contour info label
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off line labels


    res@gsnDraw              = False              ; don't draw yet
    res@gsnFrame             = False              ; don't advance frame yet
    
    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    
    res@mpFillOn             = True               ; turn on gray continents
    res@mpCenterLonF         = 180                ; Centers the plot at 180 
    
    resP                     = True               ; panel options
    resP@gsnMaximize         = True               ; maximize image
    resP@txString            = "COADS: "+yrStrt+"-"+yrLast+": nMin="+nMin 
    
; create an output file that contains multiple frames(pages) each with
; two plots on it.  If you wanted to make separate files of each panel
; plot, you would have to move the workstation specification above into
; the loop below.
    do i=0,0
      res@tiMainString      = months(i)+": Climatology"
      res@cnMinLevelValF    =   2.               ; set min contour level
      res@cnMaxLevelValF    =  30.               ; set max contour level
      res@cnLevelSpacingF   =   2.               ; set contour spacing
      plot(0) = gsn_csm_contour_map_ce(wks,clm(i,:,:), res)  ; create plot
      
      res@tiMainString      = months(i)+": Std. Deviation"
      res@cnMinLevelValF    =   0.5              ; set min contour level
      res@cnMaxLevelValF    =   2.0              ; set max contour level
      res@cnLevelSpacingF   =   0.25             ; set contour spacing
      plot(1) = gsn_csm_contour_map_ce(wks,std(i,:,:), res)  ; create plot
      
      gsn_panel(wks,plot,(/2,1/),resP)
    end do
  end if
;************************************************
; netCDF  
;*************************************************
  if (ncClm) then
    print(" ")
    print("======> netCDF:      "+systemfunc("date")+" <====== " )
    print(" ")
    
; new line character when outputing a netCDF file. Note that for a 
; carrage return in plot text, you should use ~C~
    nline  = inttochar(10)       
    
    globeAtt               = True       ; create global (file) attributes
    globeAtt@creation_date = systemfunc ("date" ) 
    globeAtt@NCL           = "http://www.ncl.ucar.edu/Applications/coads.shtml"
    globeAtt@story        = "In order to be used in the computation a grid box was" +nline+"           required to have "+nMin+" or more observations"
    globeAtt@source       = "http://www.cdc.noaa.gov/coads/coads_cdc_netcdf.shtml"
    globeAtt@Conventions  = "None"
    globeAtt@Period       = yrStrt+"-"+yrLast
    globeAtt@title        = "Climatology and Interannual Variability: "+vNam+"."+vType 


    ncFile = "clm."+yrStrt+"-"+yrLast+"."+vNam+"."+vType+".nc" ; output name
    NCFILE = ncDir+ncFile
    system ("/usr/bin/rm " +  NCFILE)             ; remove any pre-exist file 
    out   = addfile(NCFILE,"c")                   ; create the file reference 
    
    fileattdef(out,globeAtt)                      ; write global attributes
    out->CLM  = clm                               ; write data
    out->STD  = std
  end if
end
