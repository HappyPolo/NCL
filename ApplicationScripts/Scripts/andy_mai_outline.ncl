;*************************************************
; CSM Advanced Graphics: latlon63_v0.ncl
;
; Description: reads in data from a netCDF file
;     and creates a simple default plot.
;
; Notes:
;  ** the /nclGSUN/ scripts loaded below are
;     required to use Mary Haley's simplified
;     plot interfaces.
;
;  ** addfile can be used to open netCDF, GRIB,
;     HDF, and CCM history tape (cray only) in 
;     just one line.
;                  
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    ; plot. Include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  ; begin
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  ; begin
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("ps","mai")          ; open a ncgm file

  res=True
  res@mpFillOn             = False
  res@mpDataBaseVersion    = "MediumRes"
  res@mpDataSetName        = "./Cont_Only"
  res@mpGeophysicalLineDashPattern = 14
  res@mpGeophysicalLineThicknessF  = 2
  res@mpGeophysicalLineDashSegLenF = 0.008 
  contour = gsn_csm_contour_map_ce(wks,u,res)  ; create the plot
end
