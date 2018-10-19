******************************************************************
; gfed_4.ncl
;
; Concepts illustrated:
;   - Use NCL as a 'scripting language'
;   - Getting all file names of the form 'GFED4.1s_YYYY.nc'
;   - Get all possible variable names                      
;   - Looping over each variable and, if 3D, create a single variable
;     file with all time steps using the netCDF operator 'ncrcat' 
;
;**********************************************************
; Use NCO operator 'NCRCAT' to create a time series of a sinle variable 
;***********************************************************
    diri   = "./NC4/"           ; directory with files created by gfed_3.ncl
    diro   = "./NC4/VAR/"       ; directory to contain the newly create single variable files
     
    all_files = systemfunc ("cd "+diri+" ; ls GFED4.1s_*nc")       
    print(all_files)
    pthi   = diri+all_files     ;create file path
    nfil   = dimsizes(pthi)

    print(pthi)
    print("nfil="+nfil)
    print("---")

;---Use 1st file to get all possible variable names

    f = addfile(pthi(0),"r")
    var = getfilevarnames(f)
    print(var)
    print("---")
    nvar   = dimsizes(var)

;---loop over each variable; if rank.eq.3 create a file
;---always include yyyymm, BASIS_REGIONS, GRID_CELL_AREA

  do nv=0,nvar-1
     dimvar := getfilevardimsizes(f,var(nv))
     rank    = dimsizes(dimvar)
     if (rank.eq.3) then
         NCRCAT  = "ncrcat -O -h -v yyyymm,BASIS_REGIONS,GRID_CELL_AREA,"+var(nv) \
                              +" "+diri+"GFED4.1s_*nc "+ diro+"GFED4.1s_"+var(nv)+".nc"
         print("NCRCAT: "+NCRCAT)
         system(NCRCAT)
         print("---")
     end if
  end do    ; nv
    
