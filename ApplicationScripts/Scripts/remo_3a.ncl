load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("renameDim")
procedure renameDim(z:numeric)
; Convenience only:
;     Utility to make better named dimensions for netCDF file
;     *not* required ...just looks nicer
begin
  dimz  = dimsizes(z)
  rankz = dimsizes(dimz)
  if (rankz.eq.3) then
      z!0 = "time" 
      z!1 = "lat"
      z!2 = "lon"
  else if (rankz.eq.4) then
           z!0 = "time" 
           z!1 = "lev_p" 
           z!2 = "lat"
           z!3 = "lon"
       end if
  end if
end

;=================================================================
;                  MAIN
;=================================================================
; netCDF 
  dir_nc          = "./"                     ; output netCDF
;*****************************************************************
; vinth2p requires the lev_p to be expressed in mb [hPa]
;*****************************************************************

  lev_p           = (/  10, 20, 30, 50, 70,100,150,200,250 \
                     , 300,400,500,600,700,850,925,1000 /)                
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

   print("---")
   print(sprintf("%9.6f", hyam)+"   "+sprintf("%9.6f", hybm))

;*****************************************************************
; Read REMO file(s); Loop over each file
;*****************************************************************

   dir_remo = "./"
   fil_remo = systemfunc("cd "+dir_remo+" ; ls REMO*grb")  ; file names
   nfil     = dimsizes(fil_remo)
   print("---")
   print(fil_remo)

;*****************************************************************
; Specify REMO variables to be interpolated
; ( initial_time0_hours, lv_HYBY3, g0_lat_4, g0_lon_5 )
;
; NCL does not have the full GRIB table built in; manually add information
;                      0             1              2                r3
;                     GRIB           NC         long_name          units
;*****************************************************************
  varName = (/ (/"SNO_C_GDS0_HYBY"  ,"SNOW" , "Convective snow" , "kg/m^2" /)  \
             , (/"VAR_130_GDS0_HYBY","T"    , "Temperature"     , "degK"   /)  /)

  dimvar  = dimsizes(varName)
  nvar    = dimvar(0)

;*****************************************************************
; Force GRIB files with a single time step, to have an explicit 'time' dimension.
; Loop over files
;*****************************************************************

   setfileoption("grb","SingleElementDimensions","Initial_time") 
   intyp = 1                                             ; 1 = LINEAR, 2 = LOG, 3 = LOG LOG 
   P0mb  = P0*0.01                                       ; reference pressure [mb]

   do nf=0,nfil-1  

;*****************************************************************
; For each grib file create a nc file
;*****************************************************************

      fil_nc = str_get_field(fil_remo(nf), 1, ".") +".nc"
      pth_nc = dir_nc + fil_nc
      system("/bin/rm -f "+ pth_nc)                      ; rm pre-existing file
      ncdf   = addfile(pth_nc, "c")
      ncdf@creation_date = systemfunc("date")
      ncdf@source_file   = fil_remo(nf)

;*****************************************************************
; read from sfc pres  from GRIB; see table .... 134=>sfc_pres 
;*****************************************************************

      fg   = addfile(dir_remo+fil_remo(nf), "r")
      ps   = fg->VAR_134_GDS0_SFC                                    ; sfc pres (Pa) 
      renameDim(ps)
      ps@long_name = "Surface Pressure"
      ps@units     = "Pa"
      
      printVarSummary(ps)
      print("ps: min="+min(ps)+"   max="+max(ps))

      ncdf->PSFC = ps                                                ; write to nc
      
;*****************************************************************
; Loop over specified variables
; Interpolate multi-level variables to constant pressure levels
; Write variables to netCDF
;*****************************************************************
      do nv=0,nvar-1
         x  := fg->$varName(nv,0)$                                    ; read from GRIB
       ;;print(varName(nv,0)+": min="+min(x)+"   max="+max(x))

         xp := vinth2p(x, hyam, hybm, lev_p, ps, intyp, P0mb, 1, False ) ; interpolate
         renameDim(xp)
         xp@long_name = varName(nv,2)
         xp@units     = varName(nv,3)
         printVarSummary(xp)
         print(varName(nv,0)+": min="+min(xp)+"   max="+max(xp))

         ncdf->$varName(nv,1)$ = xp                                    ; write to nc

      end do      ; end 'nv'
   end do         ; end 'nf'
