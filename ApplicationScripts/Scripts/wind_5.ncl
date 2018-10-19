;*************************************************
; wind_5.ncl
;
; Concepts illustrated:
;   - Read variables of type short and convert to float
;   - Reorder the input (N==>S) data orger to (S==>N) via NCL syntax
;   - Use uv2dvG_Wrap and uv2dv_cfd to compute divergence
;   - Plot both ressult on a panel plot. 
;   - Use raster mode to see results on a grid box level
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;*************************************************
begin
;*************************************************
; open file and read in data: data are on a gaussian grid
;*************************************************
  f    = addfile ("uwnd.2012.250hPa.nc", "r")
  u    = short2flt(f->uwnd)              ; (time,lev,lat,lon)

  f    = addfile ("vwnd.2012.250hPa.nc", "r")
  v    = short2flt(f->vwnd)
;*************************************************
; Reorder from N-S to S->N
;*************************************************
  u    = u(:,:,::-1,:)
  v    = v(:,:,::-1,:)
  printVarSummary(u)
  printVarSummary(v)
;*************************************************
; calculate divergence on a gaussian grid
; divs - spherical harmonics
; divf - finite difference
;*************************************************
  divs = uv2dvG_Wrap(u,v)                
  divs@long_name = "divergence: uv2dvG"
  print("divs: min="+min(divs)+"  max="+max(divs)) 
  
  divf = uv2dv_cfd (u,v,u&lat,u&lon, 3)
  copy_VarCoords(u,divf)
  divf@long_name = "divergence: uv2dv_cfd"
  print("divf: min="+min(divf)+"  max="+max(divf)) 
 
;*************************************************
; plot results
;*************************************************    
  wks  = gsn_open_wks("png","wind")             ; send graphics to PNG file

  plot = new(2,graphic)                         ; create a plot array

  res                      = True
  res@gsnDraw              = False              ; don't draw
  res@gsnFrame             = False              ; don't advance frame

  res@cnFillOn             = True               ; color on (default for 6.1.0 onward)  
  res@cnFillPalette        = "ncl_default"      ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@cnFillMode           = "RasterFill"       
  res@cnInfoLabelOn        = False              ; turn off cn info label
  res@lbLabelBarOn         = False             ; turn off individual cb's

; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
; Here, the levels are set manually
  
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -3e-05   
  res@cnMaxLevelValF       =  3e-05   
  res@cnLevelSpacingF      =  1e-06  

  nt      = 0                                        ; plot 1st time step only
  plev    = 250
  res@gsnCenterString = plev+"hPa"
  plot(0) = gsn_csm_contour_map(wks,divs(nt,{plev},:,:),res) 
  plot(1) = gsn_csm_contour_map(wks,divf(nt,{plev},:,:),res) 
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
 ;resP@txString            = ""
  resP@gsnMaximize         = True                ; make ps, eps, pdf large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

end

