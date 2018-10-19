;============================================================================================
; Create time series files for each variable from (FV, Gaussian,...) and SE time slice files
;===========================================================================================
; This assumes all files are located on a readily accessible disk. Not the HPSS.
;===========================================================================================
; https://www.ncl.ucar.edu/Document/Functions/Built-in/setfileoption.shtml
;===========================================================================================
                                 ; see 'setfileoption' 
  ncFormat  = "NetCDF4Classic"   ; NetCDF4Classic, Classic, NetCDF4)
  compLevel = -1                 ; -1 => no compression (only: NetCDF4Classic, NetCDF4)
                                 ; compression level 1 is (generally) more than adequate

                                 ; input 
  varWant = (/"" /)              ; all variables
 ;varWant = (/"T","Q","PS"/)     ; user specified variables

  filikey= "b.e11.B1850C5CN.ne30_g16"
  diri   = "./                   ; input directory
  fili   = systemfunc("cd "+diri+" ; ls "+filikey+"*nc") ; all files beginning with 'filikey'

  diro   = "./                   ; output directory
  filo    = filikey   

;===========================================================================================
; End user settings
;===========================================================================================
  nfili  = dimsizes(fili)
  print("nfili="+nfili)

  nWant   = dimsizes(varWant)
  if (varWant(0).eq."") then
      nWant = 0                  ; all Variables will be created
  end if

  setfileoption("nc","Format",ncFormat)
  if (compLevel.ne.-1 .and.(ncFormat.eq."NetCDF4Classic" .or. \
                            ncFormat.eq."NetCDF4")       ) then
      setfileoption("nc", "CompressionLevel", compLevel)
  end if
  
  pthi   = diri+fili             ; convenience
  fi     = addfiles(pthi, "r")   ; open all files

                                 ; use 1st file to get assorted info
  vNames = getfilevarnames(fi[0]); get names of all variables on file 
  nNames = dimsizes (vNames)     ; number of variables on the file
  print (vNames)                 ; print all variable names on file

  dNames = getvardims(fi[0])      ; get file's named dimensions

  if (any(dNames.eq."ncol")) then ; Is this an SE grid?
      seGrid = True
  else
      seGrid = False
  end if
;===========================================================================================
; These files should contain numerous additional variables to facilitate use.
;===========================================================================================
                                 ; get generic non-time variables
  P0   = fi[0]->P0
  hyai = fi[0]->hyai
  hybi = fi[0]->hybi
  hyam = fi[0]->hyam
  hybm = fi[0]->hybm
  lev  = fi[0]->lev
  ilev = fi[0]->ilev

  if (seGrid) then
      area = fi[0]->area          ; (ncol) 
      lat  = fi[0]->lat
      lon  = fi[0]->lon
  else
      gwt  = fi[0]->gw            
      slat = fi[0]->slat          
      slon = fi[0]->slon          
  end if

  time     = fi[:]->time
  time_bnds= fi[:]->time_bnds
  date     = fi[:]->date
 ;datesec  = fi[:]->datesec

  filAtts = True
  copy_VarAtts( fi[0], filAtts)

;===========================================================================================
; Loop over all or desired variables
;===========================================================================================
  do nv=0,nNames-1               

     if (nWant.eq.0 .or. any(varWant.eq.vNames(nv))) then 

         rank = dimsizes( getfilevardimsizes(fi[0], vNames(nv)))
         if (rank.ge.2 .and. (vNames(nv).ne."time_bnds"     .and. \
                              vNames(nv).ne."date_written"  .and. \
                              vNames(nv).ne."time_written")) then
             var := fi[:]->$vNames(nv)$ ; read the variable to memory
          
              ptho    = diro+filo+"."+vNames(nv)+".nc"
      
              system("/bin/rm -f "+ptho)
              fo      = addfile(ptho, "c")
              filedimdef(fo,"time",-1,True)   ; make time an UNLIMITED dimension      
    
              filAtts@creation_date = systemfunc("date")
              fileattdef( fo, filAtts )       ; copy file attributes
    
              fo->time = time
              fo->time_bnds = time_bnds
              fo->date = date
             ;fo->datesec   = datesec
              fo->hyai = hyai
              fo->hybi = hybi
              fo->hyam = hyam
              fo->hybm = hybm
              fo->lev  = lev 
              fo->ilev = ilev 
              if (seGrid) then
                  fo->area = area  
                  fo->lat  = lat
                  fo->lon  = lon
              else
                  fo->gwt  = gwt  
                  fo->slat = slat 
                  fo->slon = slon 
              end if
              fo->P0   = P0   
    
              fo->$vNames(nv)$ = fi[:]->$vNames(nv)$    ; output variable
         end if   ; rank

     end if       ; nWant

  end do          ; nv
