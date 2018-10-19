;======================================================================
; binning_3.ncl
;
; Concepts illustrated:
;   - Read a region of the data using coordinate subscripting
;   - Bin the data into 0.5 degree regions
;======================================================================
; This example is generically similar to ESMF_all_4.ncl and regrid_13.ncl
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    latS  = 25    ; rough box that encloses the Tibet Plateau
    latN  = 42    ; this is larger than the 'final' Tibet region
    lonW  = 72    ; common TIBET region: 28N-40N and 75-104E
    lonE  = 108

    vNam  = "ELEV"

    srcFileDir  = "./"
    srcFileName = "ETOPO2_GLOBAL_2_ELEVATION.nc"
    sfile = addfile(srcFileName,"r")

    topo  = short2flt(sfile->$vNam$({latS:latN},{lonW:lonE}))

    zcrit = 1500  ; user specifed elevation boundary for Tibet 
    topo  = where(topo .lt.zcrit, topo@_FillValue , topo )
    printVarSummary(topo)

;----------------------------------------------------------------------
; This is a rectilinear grid woth LAT(LAT) and LON(LON)
; The 'bin_sum' function requires a triplet of observations.
; Replicate the LAT & LON for each grid point
;----------------------------------------------------------------------

    dim_topo = dimsizes(topo)
    nlt_topo = dim_topo(0)
    mln_topo = dim_topo(1)

    lat_topo = conform_dims( (/nlt_topo,mln_topo/), topo&LAT, 0)
    lon_topo = conform_dims( (/nlt_topo,mln_topo/), topo&LON, 1)

;*****************************************************************
; Variables to hold binned quantities
;*****************************************************************
    nlat  = 35
    mlon  = 73
    lat   = fspan(latS, latN, nlat)
    lon   = fspan(lonW, lonE, mlon)

    topo_bin  = new ( (/nlat,mlon/), float ) 
    topo_knt  = new ( (/nlat,mlon/), integer ) 

    topo_bin  = 0.0                      ; initialization
    topo_knt  = 0

    bin_sum(topo_bin,topo_knt,lon,lat   \
            ,ndtooned(lon_topo), ndtooned(lat_topo),ndtooned(topo) )

;*****************************************************************
; Perform averaging
;*****************************************************************
                                       ; avoid division by 0.0
    topo_knt     = where(topo_knt.eq.0 , topo_knt@_FillValue, topo_knt)
  
    topo_bin     = topo_bin/topo_knt   ; averaging

;*****************************************************************
; Meta Data
;*****************************************************************
   
    lat!0 = "lat"
    lon!0 = "lon"
    lat@units    = "degrees_north"
    lon@units    = "degrees_east"

    topo_bin!0   = "lat"
    topo_bin!1   = "lon"
    topo_bin&lat =  lat
    topo_bin&lon =  lon
  
    copy_VarCoords(topo_bin, topo_knt)        ; copy coords
  
    if (isfilevaratt(sfile, vNam, "long_name")) then
        topo_bin@long_name = "BINNED: "+vNam
        topo_knt@long_name = "BINNED COUNT: "+vNam
    end if
  
    if (isfilevaratt(sfile, vNam, "units")) then
        topo_bin@units     = sfile->$vNam$@units
    end if

    printVarSummary(topo_bin)
;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","binning")         ; send graphics to PNG file

    res                     = True              ; Plot mods desired.
    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot
    
    res@mpFillOn            = False
    res@mpMinLatF           = latS 
    res@mpMaxLatF           = latN
    res@mpMinLonF           = lonW
    res@mpMaxLonF           = lonE
    res@mpCenterLonF        = (lonW+lonE)*0.5

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
    res@cnFillMode          = "RasterFill"      
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
    res@cnMinLevelValF       = zcrit              ; set min contour level
    res@cnMaxLevelValF       = 5750               ; set max contour level
    res@cnLevelSpacingF      =  250 

    res@lbLabelBarOn        = False

    res@gsnAddCyclic        = False

    res@tiMainString = "TOPO: Original data " + \
                       str_join(tostring(dimsizes(topo))," x ")

    plot_orig = gsn_csm_contour_map(wks,topo,res) 

    res@gsnAddCyclic        = False
    res@tiMainString = "TOPO: Binned to 0.5 degree " + \
                       str_join(tostring(dimsizes(topo_bin))," x ") + \
                       " (bin_sum)"

    plot_bin = gsn_csm_contour_map(wks,topo_bin,res)     

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True

    gsn_panel(wks,(/plot_orig,plot_bin/),(/2,1/),pres)
end

