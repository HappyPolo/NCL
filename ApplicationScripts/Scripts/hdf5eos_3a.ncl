;******************************************************************
; hdf5eos_3a.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 ['he5'] data
;   - Create a local function to facilitate handling variables
;     with different appended species names (eg: _O3, )
;   - Many 'print' statements to follow assoerted aspects of the script
;   - Use stat_dispersion to guide contour levels
;   - Plotting trajectories colored by value
;   - Drawing markers on a map
;   - Reversing the Y axis in a contour plot
;   - Using ESMF regridding to grid the trajectory data (data too sparse)
;   - Drawing raster contours
;************************************************
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;************************************************

undef("MLS_generic_dim_names")
function MLS_generic_dim_names(f[1]:file,varName[1]:string)
local q, dimq, rankq, dNames
;
; **utility** to remove the _??? from dimension name(s): eg,; nLevels_O3 ===> nLevels
; **reason**  on the MLS files there are multiple variables with _??? appended
; **facilitates** generic dimension names 
;
begin
   q = f->$varName$

   dimq   = dimsizes(q)
   rankq  = dimsizes(dimq)
   dNames = getvardims(q) 

   do i=0,rankq-1
      q!i = str_get_field(dNames(i),1,"_")  ; overwrite original dimension names
   end do

   return(q)
end

begin
;************************************************
;             MAIN
;************************************************

    pltType  = "png"          ; send graphics to PNG file
    pltName  = "hdf5eos"

    method   = "bilinear"     ; ESMF
    DstGridType  = "5x5"

    app      = "O3"           ; appended species id
    varName  = "L2gpValue"    ; key variable
    varScale = 1e5            ; use for plotting (1.0 means no scaling)

    plvl     = 0.05           ; arbitrary (for this example)

    diri     = "./"
    fili     = "MLS-Aura_L2GP-O3_v02-21-c01_2004d245.nc"
    f        = addfile(diri+fili, "r")

; read some data

    lat  = MLS_generic_dim_names(f,"Latitude" +"_"+app)
    lon  = MLS_generic_dim_names(f,"Longitude"+"_"+app)
    lev  = MLS_generic_dim_names(f,"Pressure" +"_"+app)  ; has _FillValue present but none present
    time = MLS_generic_dim_names(f,"Time"     +"_"+app)  ; has _FillValue for some times

    x    = MLS_generic_dim_names(f,varName    +"_"+app)  ; (nTimes,nLevels)
    x@long_name = app+"_"+x@long_name
    printVarSummary(x)
    printMinMax(x, True)
    print("==============")

; create coordinate variable and associate with the variable 'x'

    x&nLevels = lev
    printVarSummary(x)
    print("==============")
    print(x&nLevels)
    print("==============")

    opt  = True
    opt@PrintStat = True               ; all levels
    stat = stat_dispersion(x, opt )    ; *ALWAYS* look at satellite data 
                                       ; often outliers are present
    print("==============")

    if (varScale.ne.1.0) then
        x = (/ x*varScale /)           ; use for plotting
        print("==============> After scaling: varScale="+varScale)
        x@units = varScale +"*"+x@units
        printVarSummary(x)
        printMinMax(x, True)
        print("==============")
        stat = stat_dispersion(x, opt )  
        print("==============")
    end if

; time units: NCL does not have a function analogous
; to cd_calendar for TAI93 (International Atomic Time). 
; Create an "elapsed time" variable.
; Must account for time that are _FillValue .... unfortunately

    it                = ind(.not.ismissing(time)) 
    ntim              = dimsizes(it)                      ; non_missing times
    itStrt            = it(0)                             ; 1st  non-missing time
    itLast            = it(ntim-1)                        ; last non-missing time
    telapse           = (time(itStrt) - time(itLast))/60
    telapse@long_name = "Elapsed Time (minutes)"
    telapse@units     = "minutes since "+(time(0)/60)
    NTIM              = dimsizes(time)                    ; ALL time slots

;***************************************
; Regrid: Each level could be different
;         Due to sparse sampling, this will be crude 
;***************************************

 ;---Set up options for regridding
    Opt                 = True
    Opt@SrcGridLat      = lat               ; [*] unstructured
    Opt@SrcGridLon      = lon               ; [*]
    Opt@InterpMethod    = "bilinear"
 
;---If you don't set these two, the regridding will be VERY slow
    if (DstGridType.eq."1x1") then
        Opt@DstURCorner     =  (/ 89.5d,  179.5d/)    ; for 2x2
    end if
    if (DstGridType.eq."2x2") then
        Opt@DstURCorner     =  (/ 89d,  179d/)    ; for 2x2
    end if
    if (DstGridType.eq."5x5") then
        Opt@DstURCorner     = (/ 87.5d,  177.5d/)
    end if
    Opt@DstLLCorner     =  -Opt@DstURCorner

    Opt@DstGridType     = DstGridType ; destination grid
    Opt@SrcRegional     = False
    Opt@DstRegional     = False

    Opt@RemoveSrcFile   = True        ; remove SCRIP grid destination files
    Opt@RemoveDstFile   = True        ; remove SCRIP grid destination files

    Opt@ForceOverwrite  = True
    Opt@Debug           = True

;---Extract desired level for regridding

    xp                  = x(:,{plvl})
    stat_xp = stat_dispersion(xp, opt )    ; ALWAYS look at satellite data 
                                           ; Here, just 'xp'

    Opt@SrcGridMask     = where(ismissing(lat) .or. ismissing(xp) .or. \
                                abs(lat).gt.90 .or. abs(lon).gt.180, 0,1) 
    Opt@WgtFileName     = "MLS-Aura_L2GP-"+app+"."+Opt@DstGridType+".nc" 
      
    xp_regrid           = ESMF_regrid(xp,Opt)
    printVarSummary(xp_regrid)
    printMinMax(xp_regrid,0)
    print("==============")

;************************************************
; plot
;************************************************

    wks   = gsn_open_wks (pltType,pltName) ; open workstation
    colormap = "WhViBlGrYeOrRe"            ; assign colormap

;***************************************************
; cross-section: (1) all levels; (2) selected subset 
;***************************************************
 
    res   = True
    res@gsnMaximize          = True               ; make ps/eps/pdf
   ;res@gsnPaperOrientation  = "portrait"         ; force portrait

    res@tiMainString         = fili

    res@cnFillOn             = True
    res@cnFillPalette        = colormap           ; set color map
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
    res@cnFillMode           = "RasterFill"       ; faster
    res@cnRasterSmoothingOn  = True

    res@lbOrientation        = "Vertical"
                                                  ; stat_dispersion: ALL levels
    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = 0.02               ; set min contour level
    res@cnMaxLevelValF       = 1.00               ; set max contour level
    res@cnLevelSpacingF      = 0.02               ; set contour spacing

    res@trYReverse           = True               ; reverse y-axis
    x&nLevels                = lev                ; assign "pressure" coordinates
   ;x&nTimes                 = telapse            ; NOT possible; _FillValue present

    res@gsnYAxisIrregular2Linear = True
   ;res@gsnXAxisIrregular2Linear = True
    res@tmYLFormat           = "f"                ; force minimal precision 
    res@tiYAxisString        = "Pressure (hPa)"
    res@gsnLeftString        = x@Title

    plta  = gsn_csm_contour (wks,x(nLevels|:,nTimes|:) , res)     ; reorder; ALL levels
    pltb  = gsn_csm_contour (wks,x({nLevels|200:0},nTimes|:),res) ; reorder; upper levels only
    pltc  = gsn_csm_contour (wks,x({nLevels| 50:0},nTimes|:),res) ; reorder; upper levels only

;************************************************
; plot gridded data and trajectory
; specify plot limits; use stat_xp info as guide
;************************************************
    xp_lo   = -0.05   ; stat_xp(4) 
    xp_hi   =  0.15   ; stat_xp(12)             
    xp_inc  =  0.01    
    ninc    = toint( (xp_hi-xp_lo)/xp_inc ) + 1

    cmap     = gsn_retrieve_colormap(wks)  ; get  RGB array
    levels   = fspan(xp_lo, xp_hi, ninc)   ; individula contour levels
    nlevels  = dimsizes(levels)
   ;print(levels)
;
; Get a nice span of colors through the current color map, but
; skip the first three colors (0-2).
;
    colors = span_color_indexes(cmap(3:,:),dimsizes(levels)+1) + 3
   ;print(colors)                   ; one more color than levels

;*********************************
;---Plot regridded data
;*********************************
    resgrd                          = True
    resgrd@gsnDraw                  = False   ; will panel later
    resgrd@gsnFrame                 = False

    resgrd@cnLevelSelectionMode     = "ExplicitLevels"              
    resgrd@cnLevels                 = levels
    resgrd@cnFillColors             = colors

    resgrd@cnFillOn                 = True
    resgrd@cnLinesOn                = False
    resgrd@cnLineLabelsOn           = False
    resgrd@lbLabelBarOn             = False

    resgrd@mpFillOn                 = False

;---Turn off top and right tickmarks and their labels
   ;resgrd@tmXTOn                   = False
   ;resgrd@tmYROn                   = False
   ;resgrd@gsnAddCyclic             = False
    resgrd@tiMainFontHeightF        = 0.02

    resgrd@gsnCenterString          = DstGridType+": ESMF "+method 
    plot = gsn_csm_contour_map(wks,xp_regrid,resgrd)

;***************************************
; create trajectory plot; color by values
;***************************************

    mpres                    = True        ; Plot options desired.
    mpres@gsnDraw            = False       ; Don't draw
    mpres@gsnFrame           = False       ; Don't advance the frame
    mpres@mpLandFillColor    = "gray70"    ; color of land
    map_traj                 = gsn_csm_map(wks,mpres)       ; Draw map   

    gsres                    = True        ; "Graphic Style" resources
    gsres@gsMarkerSizeF      = 10.0        ; Marker size
    gsres@gsMarkerThicknessF = 1.0         ; Marker thickness
    gsres@gsMarkerIndex      = 1           ; Marker style

    markerid = new(nlevels+1,graphic)

    do i=0,nlevels
      if(i.eq.0) then                         ; first level
        ii := ind(xp.lt.levels(0))
      else if(i.eq.nlevels) then              ; middle levels
        ii := ind(xp.ge.levels(nlevels-1))
      else                                    ; last level
        ii := ind(xp.ge.levels(i-1).and.xp.lt.levels(i))
      end if
      end if    

      if(.not.any(ismissing(ii))) then
        gsres@gsMarkerColor = colors(i)
        markerid(i) = gsn_add_polymarker(wks,map_traj,lon(ii),lat(ii),gsres)
      end if
    end do

   ;draw(map_traj)   ; This will draw map and the attached markers
   ;frame(wks)

;---Panel two plots
    pres                     = True
    pres@txString            = fili
    pres@gsnMaximize         = True    ; The default for PS/PDF
    pres@gsnPanelLabelBar    = True
    gsn_panel(wks,(/plot,map_traj/),(/2,1/),pres)

end
