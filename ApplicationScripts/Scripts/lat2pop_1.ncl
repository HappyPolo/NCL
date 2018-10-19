;*********************************************
; latlon2pop_1.ncl
;
; Concepts illustrated:
;   - Converting a lat/lon grid to a POP grid
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Drawing color filled contours using a selected color map
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"   
;*********************************************

begin
  in        = addfile ("pcmdi_sst_ccm_bc1x1_1976-1996.nc", "r")
  ice       = in->ice_cov
;*************************************************
; remap file to pop grid
;*************************************************
  remap=PopLatLon(ice,"1x1d","gx1v3","bilin","da","010808")      
;*************************************************
; create plot
;*************************************************
  wks  = gsn_open_wks("ps","lat2pop")     ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")     ; choose colormap

  res                      = True     ; plot mods desired

  res@cnFillOn             = True     ; turn on color fill
  res@cnLineLabelsOn       = False    ; turn off line labels
  res@cnLinesOn            = False    ; turn of contour lines
  res@cnMissingValPerimOn  = True     ; outline missing values
  res@cnInfoLabelOn        = False    ; turn off info label
  res@tmLabelAutoStride    = True     ; nice stride on labels
  res@lbLabelAutoStride    = True     ; nice label bar labels
  res@gsnSpreadColors      = True     ; use full colormap
 
  plot = gsn_csm_contour(wks,remap(0,:,:),res)    ; contour the variable
end

