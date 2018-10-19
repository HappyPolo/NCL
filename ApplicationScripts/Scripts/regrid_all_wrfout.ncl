load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;----------------------------------------------------------------------
; This function checks what type of grid the given WRF variable
; is on, based on the "coordinates" attribute. If none is present,
; then a missing string is returned.
;----------------------------------------------------------------------
undef("get_grid_type")
function get_grid_type(f,vname)
local vatts,smsg, s
begin
  smsg = new(1,string)
  vatts = getfilevaratts(f,vname)
  if(.not.all(ismissing(vatts)).and.any(vatts.eq."coordinates")) then
    s = str_split(f->$vname$@coordinates," ")
    if(any(ismissing(s)))
      return(smsg)
    end if
  else
    return(smsg)
  end if
  if(     any(s.eq."XLAT")  .and.any(s.eq."XLONG")) then
    return("")
  else if(any(s.eq."XLAT_U").and.any(s.eq."XLONG_U")) then
    return("_u")
  else if(any(s.eq."XLAT_V").and.any(s.eq."XLONG_V")) then
    return("_v")
  end if
  end if
  end if
  return(smsg)
end

;----------------------------------------------------------------------
; This procedure creates a weights file based on the given 
; variable, its lat/lon grid, and a string indicating what
; to regrid to.  Setting the DstXXCorner options is not required,
; but can make the weights file creation go faster because
; it's not travsering the whole globe.
;----------------------------------------------------------------------
undef("create_weights_file")
procedure create_weights_file(var,wname,lat,lon,interp_method,regrid_deg,\
                              minlat,maxlat,minlon,maxlon)
local Opt, var_regrid
begin
;---Set some regridding options
  Opt                   = True

  Opt@InterpMethod      = interp_method     ; "patch", "conserve", "neareststod"

  Opt@SrcRegional       = True

  Opt@DstRegional       = True
  Opt@DstLLCorner       = (/ minlat,minlon /)
  Opt@DstURCorner       = (/ maxlat,maxlon /)

; 
; If you don't want to do the regridding based on something like
; "1deg", then instead of setting "DstGridType", you can set
; "DstGridLat" and "DstGridLon" to the lat/lon grid of interest.
;
  Opt@DstGridType       = regrid_deg

  Opt@ForceOverwrite    = True
  Opt@PrintTimings      = True
  Opt@Debug             = True

  Opt@WgtFileName       = wname  ; The name of the weights file to create.

  Opt@SrcGridLat        = lat
  Opt@SrcGridLon        = lon
  var_regrid            = ESMF_regrid(var,Opt)
end

;----------------------------------------------------------------------
; This function regrids the given variable using the given weights
; file.
;----------------------------------------------------------------------
undef("regrid_wrf_var")
function regrid_wrf_var(var,vname,wname)
local opt
begin
  print("Regridding '" + vname + "' using " + wname + ".nc")
  opt = True
  var_regrid = ESMF_regrid_with_weights(var,wname,opt)
  printMinMax(var,0)
  printMinMax(var_regrid,0)
  printVarSummary(var_regrid)
  return(var_regrid)
end


;----------------------------------------------------------------------
; Function to set some contour/map plotting options.
;----------------------------------------------------------------------
undef("set_plotting_options")
function set_plotting_options(minlat,maxlat,minlon,maxlon)
begin
  res                        = True
  res@gsnDraw                = False   ; Will panel later
  res@gsnFrame               = False

  res@cnFillOn               = True  
  res@cnLinesOn              = False
  res@cnLineLabelsOn         = False

  res@lbLabelBarOn           = False

  res@pmTitleZone            = 4
  res@pmTickMarkDisplayMode  = "Always"
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates"
  res@mpGeophysicalLineColor = "gray"
  res@mpUSStateLineColor     = "gray"
  res@mpNationalLineColor    = "gray"

  res@mpDataBaseVersion      = "MediumRes"
  res@mpLandFillColor        = "transparent"

  res@mpMinLonF              = minlon
  res@mpMinLatF              = minlat
  res@mpMaxLonF              = maxlon
  res@mpMaxLatF              = maxlat

  res@gsnAddCyclic           = False
  res@gsnRightString         = ""

  return(res)
end

;----------------------------------------------------------------------
; Function to set some panel plotting options
;----------------------------------------------------------------------
undef("set_panel_options")
function set_panel_options()
begin
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  pres@pmLabelBarWidthF = 0.7
  return(pres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Open WRF output file
  filename = "wrfout_d03_2014-10-30_00_00_00"
  a        = addfile(filename,"r")

;---Read the three possible types of lat/lon grids off the WRF file
  lat2d    = a->XLAT(0,:,:)
  lon2d    = a->XLONG(0,:,:)
  lat2d_u  = a->XLAT_U(0,:,:)
  lon2d_u  = a->XLONG_U(0,:,:)
  lat2d_v  = a->XLAT_V(0,:,:)
  lon2d_v  = a->XLONG_V(0,:,:)

;---This is to make regridding go faster later (also for plotting)
  minlat  = min((/min(lat2d),min(lat2d_u),min(lat2d_v)/))-1    ; margin for regridding
  minlon  = min((/min(lon2d),min(lon2d_u),min(lon2d_v)/))-1    ; add a little bit of a 
  maxlat  = max((/max(lat2d),max(lat2d_u),max(lat2d_v)/))+1
  maxlon  = max((/max(lon2d),max(lon2d_u),max(lon2d_v)/))+1

;---Set regridding options
  interp_method         = "bilinear"
  regrid_deg            = "0.10deg"

;---Three lat/lon grids will require three different weights files.
  wgt_file_pfx          = "wrf_to_" + regrid_deg
  wgt_file_name         = wgt_file_pfx
  wgt_file_name_u       = wgt_file_pfx + "_u"
  wgt_file_name_v       = wgt_file_pfx + "_v"

;---Create a weights file for each possible grid type
  create_weights_file(a->T,wgt_file_name,lat2d,lon2d,interp_method,\
                      regrid_deg,minlat,maxlat,minlon,maxlon)
  create_weights_file(a->U,wgt_file_name_u,lat2d_u,lon2d_u,interp_method,\
                      regrid_deg,minlat,maxlat,minlon,maxlon)
  create_weights_file(a->V,wgt_file_name_v,lat2d_v,lon2d_v,interp_method,\
                      regrid_deg,minlat,maxlat,minlon,maxlon)

;----------------------------------------------------------------------
; Individual variable regridding and graphics section.
;----------------------------------------------------------------------
  wks = gsn_open_wks("pdf","regrid_all_wrfout")
  res  = set_plotting_options(minlat,maxlat,minlon,maxlon)
  pres = set_panel_options()

;----------------------------------------------------------------------
; Loop through each variable on the file and only regrid 
; the ones that have more than two dimensions. Plot
; the ones that are 3D or 4D.
;----------------------------------------------------------------------
  vnames = getfilevarnames(a)
  do n=0,dimsizes(vnames)-1
    rank = dimsizes(getfilevardimsizes(a,vnames(n)))
    gtype = get_grid_type(a,vnames(n))
    if(ismissing(gtype)) then
      continue
    end if 
    x := a->$vnames(n)$    ; Read the variable to regrid

;---Here's the regridding call, based on the appropriate weights file
    wname    = wgt_file_pfx + gtype
    x_regrid := regrid_wrf_var(x,vnames(n),wname)

;---Set the proper lat/lon coordinates for plotting over a map
    if(gtype.eq."") then
      x@lat2d = lat2d
      x@lon2d = lon2d
    else if(gtype.eq."_u") then
      x@lat2d = lat2d_u
      x@lon2d = lon2d_u
    else
      x@lat2d = lat2d_v
      x@lon2d = lon2d_v
    end if
    end if
    if(rank.eq.2) then
      x_subset  := x
      xr_subset := x_regrid
    else if(rank.eq.3) then
      x_subset  := x(0,:,:)
      xr_subset := x_regrid(0,:,:)
    else if(rank.eq.4) then
      x_subset  := x(0,0,:,:)
      xr_subset := x_regrid(0,0,:,:)
    else
      print("Not plotting variable '" + vnames(n) + "'")
    end if
    end if
    end if
    mnmxint = nice_mnmxintvl( min(x_subset), max(x_subset), 18, False)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = mnmxint(0)
    res@cnMaxLevelValF       = mnmxint(1)
    res@cnLevelSpacingF      = mnmxint(2)

;---Create plots of original and regridded data and compare in a panel plot
    res@gsnLeftString        = "Original data"
    plot_orig = gsn_csm_contour_map(wks,x_subset,res)

    res@gsnLeftString        = "Regridded to " + regrid_deg
    plot_regrid  = gsn_csm_contour_map(wks,xr_subset,res)

    pres@txString   = "Regridded variable '" + vnames(n) + \
                      "' using '" + wname + "' weights file"
    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
  end do
end

