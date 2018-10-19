;----------------------------------------------------------------------
; daymet_3.ncl
;
; Concepts illustrated:
;   - Reading a Daymet netCDF file containg one 2x2 tile with 1km x 1km data
;   - Exploring the tile's data values using min, max and stat_dispersion
;   - Use ESMF to interpolate to a rectilinear grd
;   - Write netCDF of regridded variable
;   - Plot on a cylindrical equidistant projection
;
;   - Assumes v6.1.0 or newer
;----------------------------------------------------------------------
; The file used was obtained via:
; wget --limit-rate=3m http://daymet.ornl.gov/thredds/fileServer/allcf/2010/12100_2010/prcp.nc -O prcp.2010_12100.nc 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;======================================================================
; The main code
;======================================================================

;--- User settings
    vname = "prcp"                               ; Daymet variable name 
    year  =  2010                                ; year
    tile  =  12296                               ; tile number

    method = "conserve"                         ;--- ESMF regrid method 
                                                ; "conserve", "bilinear", "patch"

    netCDF = True                               ; create netCDF of variable
    PLOT   = True                               ; plot variable: original+regrid

;---Input data (Daymet) file containing the tile data and grid description
    DataDirName  = "./"
    DataFileName = vname+"."+year+"_"+tile+".nc"
    DataPathName = DataDirName + DataFileName

;---netCDF file to contain the 'SCRIP style' description of the source grid
    srcDirName   = "./"
    srcGridName  = "DaymetGridInfo."+tile+".nc"
    srcPathName  = srcDirName+srcGridName

;---netCDF file to contain the 'SCRIP style' description of the destination grid
    dstDirName   = "./"
    dstGridName  = "RegridGridInfo."+tile+".nc"
    dstPathName  = dstDirName+dstGridName

;---Options
    Opt                = True
    Opt@SrcTitle       = "Daymet 2x2 Tile ("+tile+") to rectlinear"   ; optional
    Opt@WgtFileName    = "Wgt.Daymet."+tile+"_to_Rect.nc"

    Opt@ForceOverwrite = True
  ;;Opt@PrintTimings   = True

;---Open data source file
    sfile          = addfile(DataPathName,"r")

;---Get the source file data (Daymet) lat/lon grid: used for src grid description
    lat2d = sfile->lat
    lon2d = sfile->lon

    dim2d = dimsizes(lat2d)
    nlat  = dim2d(0)
    mlon  = dim2d(1)

;---Get the Daymet source variable
    var   = sfile->$vname$         ; (time, y, x)

;---Define assorted source grid (Daymet) options
   ;Opt@SrcGridType  = "curvilinear"
    Opt@SrcGridLat   = lat2d
    Opt@SrcGridLon   = lon2d
    Opt@SrcRegional  = True
    Opt@SrcFileName  = srcPathName              ; grid description of source tile 

    Opt@SrcMask2D    = where(.not.ismissing(var(0,:,:)),1,0)  ; identify valid data

;---Create the destination lat/lon grid
    dll = 0.1                                   ; tenth of degree spacing
    kpts= toint(2.0/dll)+1                      ; 2 deg is Daymet grid spacing
    lat = fspan( min(lat2d),max(lat2d), kpts )  
    lon = fspan( min(lon2d),max(lon2d), kpts ) 

    Opt@DstGridType  = "rectilinear"
    Opt@DstGridLat   = lat
    Opt@DstGridLon   = lon
    Opt@DstRegional  = True
    Opt@DstFileName  = dstPathName        ; grid description of source tile 

;---Set method
    Opt@InterpMethod = method     

    var_regrid = ESMF_regrid(var,Opt)     ; Do the regridding for 'var'
    printVarSummary(var_regrid)

;---Info needed if 'netCDF' and/or 'PLOT' is True
    dimv = dimsizes(var)
    ntim = dimv(0)
    nlat = dimv(1)
    mlon = dimv(2)

    dimvr = dimsizes(var_regrid)
    NLAT  = dimvr(1)
    MLON  = dimvr(2)

    delete(var_regrid@grid_mapping)       ; not for regridded variable

if (netCDF) then
;----------------------------------------------------------------------
; Write regridded variable to netCDF
;----------------------------------------------------------------------
    RegridDirName  = "./"
    RegridFileName = vname+"."+year+"_"+tile+".regrid.nc"
    RegridPathName = RegridDirName + RegridFileName

;---Assign original 'time' to regridded variable
    var_regrid!0   = "time"
    var_regrid&time= var&time                  

;---Create auxilary time variable for user convenience
    yyyyddd        = year + ispan(1,ntim,1)
    yyyyddd@long_name = "year and day of current year (YYYYDDD)"
    yyyyddd!0      = "time"
    yyyyddd&time   =  var&time

    yyyymmdd       = yyyymmdd_time(year, year, "integer")
    delete(yyyymmdd&time)                    ; type integer ... will be changed
    delete(yyyymmdd@units)                   ; non-standard
    yyyymmdd@long_name = "current date (YYYYMMDD)" 
    yyyymmdd&time      = var&time            ; type double
  
;---Write regridded variable and auxilary time variables to file 
    system("/bin/rm -f "+RegridPathName)     ; delete any pre-existing file
    rgrd_nc   = addfile(RegridPathName, "c") ; open for writing

    global    = True
    global@creation_date = systemfunc("date")
    global@remap_method  = method
    global@remap         = "NCL: ESMF_regrid"
    global@title         = "REMAPPED Daymet: "+vname
    fileattdef( rgrd_nc, global )         ; copy file attributes

    filedimdef( rgrd_nc,"time",-1,True)   ; force an unlimited dimension

    rgrd_nc->yyyyddd   = yyyyddd

    rgrd_nc->yyyymmdd  = yyyymmdd 
    rgrd_nc->$vname$   = var_regrid
end if

if (PLOT) then
;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    pltType = "png"                              ; ps,pdf,png,x11,ncgm,eps
    pltDir  = "./"                               ; directory to which plots sent
    pltName = "daymet"                           ; Daymet.ESMF_"+method+"."+vname+"_"+year+"_"+tile
    pltPath = pltDir+pltName

    dimv  = dimsizes(var)
    ntim  = dimv(0)
    nlat  = dimv(1)
    mlon  = dimv(2)

    nt    = ntim/2                                ; arbitrary time 
    ymd   = cd_calendar(var&time(nt), -2) 

    dimvr = dimsizes(var_regrid)
    NLAT  = dimvr(1)
    MLON  = dimvr(2)

    var@lat2d = lat2d
    var@lon2d = lon2d

    wks  = gsn_open_wks(pltType, pltPath)

;---Resources to share between both plots
    res                      = True              ; Plot modes desired.

    res@gsnDraw              = False
    res@gsnFrame             = False
    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
   ;res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@lbLabelBarOn         = False             ; Turn off in labelbar

    res@mpFillOn             = True 

    res@gsnLeftString        = var@long_name
    res@gsnAddCyclic         = False

    res@pmTickMarkDisplayMode= "Always"          ; turn on tickmarks

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  1.0
    res@cnMaxLevelValF       = 10.0
    res@cnLevelSpacingF      =  1.0

    res@mpMinLatF            = min(lat2d)
    res@mpMaxLatF            = max(lat2d)
    res@mpMinLonF            = min(lon2d)
    res@mpMaxLonF            = max(lon2d)

    res@mpOutlineBoundarySets= "GeophysicalAndUSStates" ; state boundaries
    res@mpDataBaseVersion    = "MediumRes"

    res@tiMainString         = "ESMF regrid: ("+NLAT+"x"+MLON+"): "+method 
    plot_regrid = gsn_csm_contour_map(wks,var_regrid(nt,:,:),res)

    res@tiMainString         = "Original grid: ("+nlat+"x"+mlon+")" 
    plot_orig = gsn_csm_contour_map(wks,var(nt,:,:),res)  

;---Draw both plots in a panel
    pres                     = True
    pres@gsnMaximize         = True
    pres@gsnPanelLabelBar    = True
    pres@txString            = "DAYMET: "+ymd+": tile="+tile

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end if
