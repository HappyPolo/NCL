;======================================================================
; ESMF_wgts_30.ncl
;
; Concepts illustrated:
;   - Generate ESMF weight files:
;     (a)  NARR to Rectilinear
;     (b)  Rectilinear to NARR
;     (c)  Create a difference plot showing the difference
;          between the the grid generated in (b) and the source NARR grid.
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;======================================================================
; Part A: Generate NARR to Rectilinear regrid weights 
;         Note: The NARR has grid points with missing values
;======================================================================

    InterpMethod = "bilinear"                           ; "bilinear", "conserve"

    plvl         = 700                                  ; arbitrary pressure level
                                    
;---Input file
    srcDirName   = "./"
    srcFileName  = "merged_AWIP32.1979010100.3D.NARR.grb"
    srcFilePath  =  srcDirName + srcFileName

;---Get the variable to be regridded;  only need one level to generate the weight
;---Also, the grid coordinates

    sfile =  addfile(srcFilePath,"r")    
    x     = sfile->TMP_221_ISBL({plvl},:,:)    ;  ( gridx_221, gridy_221) ; (   277,349)
    lat2d = sfile->gridlat_221                 ; (gridx_221, gridy_221)
    lon2d = sfile->gridlon_221

    nmsg  = num(ismissing(x))                   ; # of msg values
    printVarSummary(x)
    print("x: min="+min(x)+"   max="+max(x)+"    nmsg="+nmsg)
    print(" ")
    print("lat2d: min="+min(lat2d)+"   max="+max(lat2d))
    print("lon2d: min="+min(lon2d)+"   max="+max(lon2d))

    lon2d   = where(lon2d.lt.0, lon2d+360, lon2d) ; graphical convenience
    print("lon2d: min="+min(lon2d)+"   max="+max(lon2d))

    x@lat2d = lat2d                            ; These attributes will be used by
    x@lon2d = lon2d                            ; ESMF_regrid for the source grid
    
;---Create the destination rectilinear lat[*]/lon[*] arrays. 
;---Here, roughly the same resolution as the source grid at 45N.
;---This is arbitrary. It can be whatever the user desires.
;---For example, it could be just the area of the USA.
;---Create rectilinear coordinates; monotonically increasing 

    nlat  = 337
    nlon  = 831
    lat   = fspan(   1.0, 85.0 ,nlat)
    lon   = fspan( 150.0,358.5 ,nlon)  

;---Create regrid options

    Opt                = True
    Opt@SrcTitle       = "NARR grid"   ; optional
    Opt@WgtFileName    = "NARR_to_Rect.WgtFile_"+InterpMethod+".nc"

;---Generate the names of the files containing the source and destination grid descriptions
;---Remove after Part A is complete

    Opt@SrcFileName    = "NARR.SCRIP_grid_description.nc"         ; Name of source and
    Opt@SrcRegional    = True
    
;---If source data contains missing values, set the 
;---special SrcMask2D option to indicate the missing values 

    Opt@SrcMask2D  = where(ismissing(x),0,1)

    DstDirName         = "./"
    Opt@DstFileName    = DstDirName + "Rectilinear.SCRIP_grid_description.nc" 
    Opt@DstGridType    = "rectilinear"
    Opt@DstGridLat     = lat
    Opt@DstGridLon     = lon
    Opt@DstRegional    = True

;---Specify other options  

    Opt@ForceOverwrite = True
    Opt@InterpMethod   = InterpMethod
    Opt@RemoveSrcFile  = True                  ; remove SCRIP grid destination files
    Opt@RemoveDstFile  = True 
    Opt@NoPETLog       = True                  ; 6.2.1 onward

;---Perform the regrid: NARR ==> rectilinear (_reclin)

    x_reclin = ESMF_regrid(x, Opt)             ; Do the regridding for x  
     
    mmsg  = num(ismissing(x_reclin))           ; # of msg values
    printVarSummary(x_reclin)
    print("x_reclin: min="+min(x_reclin)+"   max="+max(x_reclin)+"    mmsg="+mmsg)
     
;======================================================================
; Part B: Generate Rectilinear to NARR regrid weights 
;         This interpolates the above grid to the NARR Grid.
;======================================================================

;---For clarity, delete the above options and start again.
    delete(Opt)

;---Options for regridding rectilinear to NARR (curvilinear) grid

    Opt                 = True
    Opt@ForceOverwrite  = True

    Opt@SrcTitle        = srcFileName                  ; source grid
    Opt@SrcRegional     = True
    Opt@SrcFileName     = "Rectilinear.SCRIP_grid_description.nc"  ; destination files
    Opt@SrcMask2D       = where(ismissing(x_reclin),0,1)

    Opt@DstTitle        = "Rectilinear_to_NARR"
    Opt@DstGridLat      = lat2d
    Opt@DstGridLon      = lon2d
    Opt@DstRegional     = True
    Opt@DstGridType     = "curvilinear"
    Opt@DstFileName     = "NARR.SCRIP_grid_description.nc"         
    Opt@DstMask2D       = where(ismissing(x),0,1)

    Opt@InterpMethod    = InterpMethod
    Opt@WgtFileName     = "Rect_to_NARR.WgtFile_"+InterpMethod+".nc"

    Opt@RemoveSrcFile  = True                  ; remove SCRIP grid destination files
    Opt@RemoveDstFile  = True 
    Opt@NoPETLog       = True                  ; 6.2.1 onward

    x_regrid           = ESMF_regrid(x_reclin,Opt)

;---Print regridded NARR variable information
    nmsgrl = num(ismissing(x_regrid))
    printVarSummary(x_regrid)
    print("x_regrid: min="+min(x_regrid)+"   max="+max(x_regrid)+"   nmsgrl="+nmsgrl)

;************************************************
; create plots
;************************************************  
    wks = gsn_open_wks("png","ESMF_wgts")      ; send graphics to PNG file
    plot = new(3,graphic)                      ; create a plot array
    
    res                      = True
    res@gsnDraw              = False           ; don't draw
    res@gsnFrame             = False           ; don't advance frame
    res@gsnAddCyclic         = False           ; regional data
  
    res@cnInfoLabelOn        = False           ; turn off cn info label
    res@cnFillOn             = True            ; turn on color
   ;res@cnFillMode           = "RasterFill"
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
    res@lbLabelBarOn         = False           ; turn off individual cb's
  
    res@mpMinLatF            = min(lat2d)      ; range to zoom in on
    res@mpMaxLatF            = max(lat2d)
    res@mpMinLonF            = min(lon2d)
    res@mpMaxLonF            = max(lon2d)
    res@mpCenterLonF         = -107.0          ; from file (253-360)
    res@mpFillOn             = False
   ;res@mpGridAndLimbOn      = True
   ;res@mpGridLineDashPattern= 10                 ; lat/lon lines as dashed
    
    res@gsnLeftString = ""
    res@gsnRightString= ""
      
    res@gsnCenterString= "Source NARR"
    plot(0) = gsn_csm_contour_map(wks,x        ,res) 
    res@gsnCenterString= "NARR => 0.25 Rectilinear Grid"
    plot(1) = gsn_csm_contour_map(wks,x_regrid ,res) 
    res@gsnCenterString= "0.25 Rectilinear Grid => NARR"
    plot(2) = gsn_csm_contour_map(wks,x_reclin ,res) 

;************************************************
; create panel
;************************************************
    resP                     = True                ; modify the panel plot
    resP@txString            = x@long_name+": "+plvl+"hPa: "+InterpMethod
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@gsnMaximize         = True  
    gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

;************************************************
; Calculate difference
;************************************************

    diff = x
    diff = x_regrid-x 
    diff@long_name = "Difference (Regrid-Source): "+plvl+"hPa" 

    res@gsnDraw              = True
    res@gsnFrame             = True
    res@lbLabelBarOn         = True 
    delete(res@gsnCenterString)

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = -0.1               ; set min contour level
    res@cnMaxLevelValF       =  0.1               ; set max contour level
    res@cnLevelSpacingF      =  0.025             ; set contour spacing

    res@tiMainString         = diff@long_name+": "+InterpMethod          
    plt  = gsn_csm_contour_map(wks,diff     ,res)
