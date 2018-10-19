;*******************************************
; remo_3.ncl
;
; Concepts illustrated:
;   - Read  3D and 4D variables from a REMO GRIB formatted file
;     for which a warning message was issued.
;   - Illustrate manually setting attributes after table lookup
;   - Interpolate multilevel variable to user specified pressure level
;   - Plotting the variable
;   - Using different color palettes 
;********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;=================================================================
;                  MAIN
;=================================================================

;*****************************************************************
; vinth2p requires the lev_p to be expressed in mb [hPa]
;*****************************************************************

  lev_p           = (/  10, 20, 30, 50, 70,100,150,200,250 \
                     , 300,400,500,600,700,850,925,1000    /)
  lev_p!0         = "lev_p"                  ; variable/dim name 
  lev_p&lev_p     =  lev_p                   ; create coordinate variable
  lev_p@long_name = "pressure"               ; attach some attributes
  lev_p@units     = "hPa"
  lev_p@positive  = "down"

;*****************************************************************
; Read hybrid coefficients; make REMO coefficients like CAM coefficients
;*****************************************************************

   dir_coef = "./"
   fil_coef = "REMO2.coeficients" 
   coef     = readAsciiTable(dir_coef+fil_coef, 3, "float", 2)     
   hyam     = coef(:,1)
   hybm     = coef(:,2)

   P0       = 100000.        ; make like CAM 
   hyam     = hyam/P0        ; This is hoe NCL want 'a' hybrid coefficients

  ;print("---")
  ;print(sprintf("%9.6f", hyam)+"   "+sprintf("%9.6f", hybm))

;*****************************************************************
; Read REMO file(s)
;*****************************************************************

   dir_remo = "./"
   fil_remo =  "REMO1_data.grb"

;*****************************************************************
; Specify REMO variables to be interpolated
; ( initial_time0_hours, lv_HYBY3, g0_lat_1, g0_lon_2 )
;
; NCL does not have the full REMO GRIB tables built in; manually add information
;*****************************************************************
; Force GRIB files with a single time step, to have an explicit 'time' dimension.
;*****************************************************************

   setfileoption("grb","SingleElementDimensions","Initial_time") 
   intyp = 1                                             ; 1 = LINEAR, 2 = LOG, 3 = LOG LOG 
   fg    = addfile(dir_remo+fil_remo, "r")

;*****************************************************************
; read from sfc pres  from GRIB; see table .... 134=>sfc_pres 
;*****************************************************************

   ps   = fg->VAR_134_GDS0_SFC                           ; sfc pres (Pa) 
   ps@long_name = "Surface Pressure"
   ps@units     = "Pa"

   printVarSummary(ps)
      
;*****************************************************************
; Interpolate multi-level variable(s) to constant pressure levels
;*****************************************************************
   x   = fg->$"VAR_130_GDS0_HYBY"$
   
   P0mb= P0*0.01                                       ; reference pressure [mb]
   xp  = vinth2p(x, hyam, hybm, lev_p, ps, intyp, P0mb, 1, False ) ; interpolate
   xp@long_name = "Temperature"
   xp@units     = "degK"        

   printVarSummary(xp)

;********************************
; plot
;********************************
   nt   = 0                                  ; time index
   plvl = 850                                ; pressure level
   time_str = fg->initial_time0(nt)

   wks = gsn_open_wks("ps","remo")       
 ;;gsn_define_colormap(wks,"default")       ; choose colormap

   res                 = True               
   res@gsnMaximize     = True
   res@cnFillOn        = True               ; color plot desired
   res@cnLinesOn       = False
   res@cnLineLabelsOn  = False              ; turn off contour lines
   res@gsnAddCyclic    = False              ; regional grid ... not global

   res@mpMinLatF       = min(x&g0_lat_1)   ; region to zoom in on
   res@mpMaxLatF       = max(x&g0_lat_1)
   res@mpMinLonF       = min(x&g0_lon_2)
   res@mpMaxLonF       = max(x&g0_lon_2)
   res@mpCenterLonF    = 0.5*(res@mpMinLonF + res@mpMaxLonF)
   res@mpFillOn        = False              ; don't prefill land with gray

   res@tiMainString    = fil_remo+": "+time_str 

   res@cnFillPalette   = "GMT_wysiwygcont"            ; 6.2.0   
   plot = gsn_csm_contour_map(wks,ps(nt,:,:),res)
   
   res@gsnCenterString = plvl+" hPa"
   res@cnFillPalette   = "amwg256"                    ; 6.2.0   
   plot = gsn_csm_contour_map(wks,xp(nt,{plvl},:,:),res)   ; coordinate subscripting
