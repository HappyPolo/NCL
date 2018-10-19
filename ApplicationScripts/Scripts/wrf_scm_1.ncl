;********************************************************
; SCM: Single Column Model
; WRF SCM: time-eta cross section.
;********************************************************
; %> ncl_filedump wrfout_SCM.nc | less
; netcdf wrfout_CSM {
; dimensions:
;        Time = UNLIMITED ; // (60 currently)
;        DateStrLen = 19 ;
;        west_east = 2 ;
;        south_north = 2 ;
;        bottom_top = 59 ;
;        bottom_top_stag = 60 ;
;        soil_layers_stag = 4 ;
;        west_east_stag = 3 ;
;        force_layers = 8 ;
;        south_north_stag = 3 ;
; [SNIP]
; 2x2 west-east/south_north values
; 3x3 west_east_stag/south_north_stag values
; 60 time steps
; 59 or 60 vertical levels
;********************************************************
; Variables are on different spatial grids. 
;
; User *must* look!
;
; float U(Time, bottom_top, south_north, west_east_stag)
; float V(Time, bottom_top, south_north_stag, west_east)
; float W(Time, bottom_top_stag, south_north, west_east)
; float PH(Time, bottom_top_stag, south_north, west_east )
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl" ; WRF_Times2Udunits_c   

begin
  nl  = 1      ; arbitrary grid point index values
  ml  = 1

  nls = 1
  mls = 1
  
  pltType = "ps"
  pltName = "WRF_SCM_1"
  
;********************************************************
; open file 
;********************************************************
  diri    = "./"
  fili    = "wrfout_SCM.nc"
  f       = addfile (diri+fili, "r")

;********************************************************
; Read character variable Times 
; Convert to units of "hours since" for plotting purposes
;********************************************************
  Time   = WRF_Times2Udunits_c(f->Times, 0)  ; convert to "hours since"

;********************************************************
; Read W(bottom_top_stag,west_east) at nl,ml
; Read associated levels and longitudes
;********************************************************
  w       = f->W(:,:,nl,ml)             ; W(Time,bottom_top_stag)
  printVarSummary(w)                    ; information
  printMinMax(w, True)

;********************************************************
; simple array syntax [like f90, Matlab, IDL,...] to change units
; done for demo purposes only
;********************************************************
  w       = w*100.                      ; change m/s to cm/s
  w@units = "cm/s"                      ; note change on units attribute

;********************************************************
; assign the staggard eta values as a vertical "coordinate array" for w
;********************************************************
  znw     = f->ZNW(0,:)                 ; znw(bottom_top_stag)
  w&bottom_top_stag = znw               

  printVarSummary(w)

;********************************************************
; Read U and V and do similar things                        
;********************************************************
  u       = f->U(:,:,nl ,mls)           ; U(Time,bottom_top)
  v       = f->V(:,:,nls,ml )           ; V(Time,bottom_top)
  znu     = f->ZNU(0,:)                 ; znu(bottom_top)

  u&bottom_top = znu                    ; associate vertical coords
  v&bottom_top = znu

  printVarSummary(u)                    ; info
  printMinMax(u, True)
  printVarSummary(v)
  printMinMax(v, True)

;********************************************************
; Read  few perturbation variables and do similar things                        
;********************************************************
  ph      = f->PH(:,:,nl,ml)            ; PH(Time,bottom_top_stag)
  t       = f->T(:,:,nl,ml )            ; T(Time,bottom_top)

  ph&bottom_top_stag = znw              ; associate vertical coords
  t&bottom_top       = znu

  printVarSummary(ph)                    ; info
  printMinMax(ph, True)
  printVarSummary(t)
  printMinMax(t, True)

;********************************************************
; Get non-convective, convective; Calculate total precipitation
;********************************************************

  precip_exp = wrf_user_getvar(f,"RAINNC",-1)
  precip_con = wrf_user_getvar(f,"RAINC", -1)
  precip_tot = precip_exp + precip_con
  copy_VarMeta(precip_exp, precip_tot)
  precip_tot@description = "Total Precipitation"

  printVarSummary(precip_tot)
  printMinMax(precip_tot, True)

  delete(precip_exp)      ; no longer needed
  delete(precip_con)

;********************************************************
; For plot label purposes only, read the specific lat/lon point
;********************************************************
  lat       = f->XLAT(0,nl,ml)
  lon       = f->XLONG(0,nl,ml)
;********************************************************
; create plots  
; (1) A "BlWhRe" is often selected when plus/minus are of interest
; (2) The "symMinMaxPlt" procedure, located in contributed.ncl,
;     determines contour limits that are symmetric.
; (3) Use the "sprintf" function to format the title
; (4) Because the rightmost dimension will become the "x" axis
;     use NCL's "dimension reordering" to reshape
;********************************************************
  plot = new ( 5, "graphic" )
  wks = gsn_open_wks(pltType ,pltName)        ; ps,pdf,x11,ncgm,eps,png
  gsn_merge_colormaps(wks,"amwg","BlWhRe")    ; merge color maps 
 ;gsn_draw_colormap(wks)  

  res                       = True            ; plot mods desired
  res@gsnDraw               = False 
  res@gsnFrame              = False 
 ;res@gsnMaximize           = True            ; uncomment to maximize size
  res@gsnSpreadColors       = True            ; use entire color map
  res@cnFillOn              = True            ; turn on color
  res@cnLinesOn             = False           ; turn off contour lines
  res@lbLabelAutoStride     = True            ; let NCL determine label spacing
  res@lbOrientation         = "vertical"      ; vertical label bar
  res@trYReverse            = True            ; reverse y axis

  res@gsnSpreadColorStart   = 2               ; use the "amwg" portion
  res@gsnSpreadColorEnd     = 17              ; of the merged colormap

  plot(0)                   = gsn_csm_contour(wks, u(bottom_top|:,Time|:),res)
  plot(1)                   = gsn_csm_contour(wks, v(bottom_top|:,Time|:),res)
  plot(2)                   = gsn_csm_contour(wks, t(bottom_top|:,Time|:),res)
  plot(3)                   = gsn_csm_contour(wks,ph(bottom_top_stag|:,Time|:),res)

  res@gsnSpreadColorStart   = 18              ; user the "BlWhRe" colormap
  res@gsnSpreadColorEnd     = -1              ; for "w" ... easier for up/down
  res@tiXAxisString         = Time@units      ; label bottom axis with units attribute
  symMinMaxPlt(w, 14, False, res)             ; contributed.ncl
  plot(4)                   = gsn_csm_contour(wks,w(bottom_top_stag|:,Time|:),res)

  resP                      = True
  resP@gsnMaximize          = True            ; maximize size
  resP@gsnPanelBottom       = 0.05            ; extra space at botton for res@tiXAxisString  
  resP@txString             = "WRF-SCM: "     \
                            + sprintf("%4.2f", lat)+"N  " \
                            + sprintf("%4.2f", fabs(lon))+"W" 
  gsn_panel(wks,plot,(/3,2/),resP)

;********************************************************
; Only plot precip_tot if there are values > 0.0
;********************************************************
 
  if (max(precip_tot(:,nl,ml)).gt.0.0) then
      res_prc = True
      res_prc@gsnMaximize = True
      res_prc@tiMainString= resP@txString
      plt  = gsn_csm_xy(wks, Time, precip_tot(:,nl,ml), res_prc)
  end if
end
