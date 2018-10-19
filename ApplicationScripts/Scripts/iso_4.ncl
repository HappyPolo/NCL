;*************************************************
; NCL Graphics: iso_4.ncl
;
; Concepts illustrated: 
;   - Using "int2p_n_Wrap" to interpolate to user specified levels
;     where the level is different at each grid *and* where
;     the dimension shape arguments do not conform to those
;     currently handled by "int2p_n"
;   - Drawing contour plot over a map
;************************************************x
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************x
; ncl-talk question:
;
; I have several ocean variables on 4-d (t, lev, lat, lon). I want to:
;
; 1. Determine the depth at which the temperature (t, lev, lat, lon) 
;    equals half the value of SST (t, lat, lon). So the new variable have 
;    dimension (t, lat, lon) containing various depths from the grids.
;
; 2. Using the new variable from (1), I'd like to extract other variables 
;    corresponding to the depths and other dimensions in (1).
;
; From the examples, I know that linear interpolation is get the depth of 
; a particular value (http://www.ncl.ucar.edu/Applications/iso.shtml). 
; My problem is that the value I'm interested in (1/2 SST) will change 
; from grid point to grid point.
;************************************************
undef("getVar_depz")
function getVar_depz(var[*][*][*][*]:numeric,depth[*][*][*][*]:numeric \
                    ,depz[*][*][*]:numeric)
; LOCAL function
; interpolate the input variable to the depth specified vi 'depz'
;
local dimvar, ntim, klev, nlat, mlon, var_depz, nt, nl, ml
begin
  dimvar      = dimsizes(var)
  ntim        = dimvar(0)
  klev        = dimvar(1)
  nlat        = dimvar(2)
  mlon        = dimvar(3)

  var_depz    = new ( dimsizes(depz), typeof(depz) , getFillValue(depz)) 

  do nt=0,ntim-1
    do nl=0,nlat-1
      do ml=0,mlon-1
         if (.not.ismissing(var(nt,0,nl,ml))) then       ; avoid land
             it := ind(.not.ismissing(var(nt,:,nl,ml)))
             var_depz(nt,nl,ml) = int2p_n(depth(nt,it,nl,ml),var(nt,it,nl,ml), depz(nt,nl,ml), 0, 0)
         end if
        ; the following could replace the above 'if block' but yields many Warnings over lanf pts
        ;var_depz(nt,nl,ml) = int2p_n(depth(nt,:,nl,ml),var(nt,it,nl,ml),depz(nt,nl,ml), 0, 0)
      end do
    end do
  end do

  copy_VarCoords(depz, var_depz)
  var_depz@long_name  = var@long_name 
  var_depz@units      = var@units
  var_depz@info       =" NCL interpolation"
 
  return(var_depz)
end

;================================================
;                   MAIN                         
;================================================

begin
;************************************************
; read POP netCDF file
;************************************************
  b = addfile("gx1v3.210.pop.h.0001-01.nc","r")

;************************************************
; oceanic data to plot
;************************************************
  temp  = b->TEMP         ; (time,z_t,nlat,nlon) [deg C]
  z_t   = b->z_t

;************************************************
; calculate value of half the 'SST' [ <==> T(:,0,:,:)/2 ]
;************************************************
  SSTZ  = temp(:,0,:,:)   ; (time,nlat,nlon)
  printMinMax(SSTZ, True) 

  SSTZ  = SSTZ*0.5
  SSTZ@long_name  = "Half temp(:,0,:,) = temp(:,0,:,)/2 "
  printVarSummary(SSTZ)

;************************************************
; Interpolate to specific [constant] SST/2 levels
; Using faster 'array' approach leads to many warning messages
; for land grid points. Use 'if block' to avoid these.
;************************************************
  dimsstz = dimsizes(SSTZ)
  ntim    = dimsstz(0)
  nlat    = dimsstz(1)
  mlon    = dimsstz(2)

  depth   = conform(temp, z_t, 1)
  copy_VarCoords(temp, depth)
  printVarSummary(depth)
  
  depz    = new ( dimsstz, typeof(depth), getFillValue(temp)) 

  begTime = get_cpu_time()                                ; time triple do loop

  do nt=0,ntim-1
    do nl=0,nlat-1
      do ml=0,mlon-1
         if (.not.ismissing(temp(nt,0,nl,ml))) then       ; avoid land
             it := ind(.not.ismissing(temp(nt,:,nl,ml)))
             depz(nt,nl,ml) = int2p_n(temp(nt,it,nl,ml),depth(nt,it,nl,ml), SSTZ(nt,nl,ml), 0, 0)
         end if
        ;var_depz(nt,nl,ml) = int2p_n(depth(nt,:,nl,ml),var(nt,it,nl,ml),depz(nt,nl,ml), 0, 0)
        ;depz(nt,nl,ml) = int2p_n(temp(nt,:,nl,ml),depth(nt,:,nl,ml), SSTZ(nt,nl,ml), 0, 0)
      end do
    end do
  end do

  print("---")
  print("Loop CPU time: " + get_cpu_time())   
  print("---")

  copy_VarCoords(SSTZ, depz)
  depz@long_name  = "depth: SSTZ"
  depz@units      = z_t@units

  printVarSummary(depz) 
  printMinMax(depz, True) 

;************************************************ 
;  Interpolate specified variables to 'depz'
;************************************************

  salt_depz =  getVar_depz(b->SALT, depth, depz)
  printVarSummary(salt_depz)
  printMinMax(salt_depz, True) 

  temp_depz =  getVar_depz(b->TEMP, depth, depz)
  printVarSummary(temp_depz)
  printMinMax(temp_depz, True) 

  q_depz    =  getVar_depz(b->Q   , depth, depz)
  printVarSummary(q_depz)
  printMinMax(q_depz, True) 

;************************************************ 
; create plot
;************************************************
  lat2d      = b->TLAT         ; used in graphics
  lon2d      = b->TLONG

  nt = 0
  pltType    = "png"           ; send graphics to PNG file
  pltDir     = "./"
  pltName    = "iso"

  wks = gsn_open_wks(pltType,pltDir+pltName)  

  res                      = True                 ; plot mods desired
  res@gsnMaximize          = False
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@mpCenterLonF         = 210                  ; center map at 210  
  res@lbOrientation        = "vertical"
  res@gsnAddCyclic         = True                 

  depz@lat2d               = lat2d
  depz@lon2d               = lon2d
  plot = gsn_csm_contour_map_ce(wks,depz(nt,:,:),res)  

  delete( [/plot, res/] )                         ; convenience

  plot = new( 3, "graphic")

  res                      = True                 ; plot mods desired
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@mpCenterLonF         = 210                  
  res@lbOrientation        = "vertical"
  res@gsnAddCyclic         = True                 

  resP = True
  resP@gsnMaximize         = True                 ; make as large as possible   

  salt_depz@lat2d          = lat2d
  salt_depz@lon2d          = lon2d
  plot(0) = gsn_csm_contour_map_ce(wks,salt_depz(nt,:,:),res)  

  temp_depz@lat2d          = lat2d
  temp_depz@lon2d          = lon2d
  plot(1) = gsn_csm_contour_map_ce(wks,temp_depz(nt,:,:),res)  

  q_depz@lat2d             = lat2d
  q_depz@lon2d             = lon2d
  plot(2) = gsn_csm_contour_map_ce(wks,   q_depz(nt,:,:),res)  

  resP@txString            = "Variables at SST/2"
  gsn_panel(wks, plot, (/3,1/), resP)
end

