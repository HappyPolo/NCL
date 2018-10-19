; Create the JRA_climo files for the CAM processor.
;=====================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

 diri  = "/project/cas/xxxx/JRA"
 fili  = "JRA_MASTER.nc"    ; year-month data (time, lev,lat,lon)

 diro  = diri
; ===============================================================
 pathi = diri+"/"+fili 
 nmos  = 12

;---------                  ; monthly files
 do nmo=0,nmos-1 
    filo    = "JRA_"+sprinti("%0.2i", (nmo+1))+"_climo.nc"
    patho   = diro+"/"+filo 

    SYS_RM  = "/bin/rm -f "+patho 
    system( SYS_RM )
                            ; ,,12 mean to use a stride of 12
    SYS_NCO = "ncra -d time,"+nmo+",,12 "+pathi+" "+patho
    print ("SYS_NCO: "+SYS_NCO)
    system( SYS_NCO )
 end do

;---------                  ; JJA seasonal file 
 filo  = "JRA_JJA_climo.nc"
 patho = diro+"/"+filo 
 SYS_RM = "/bin/rm -f "+patho 
 system( SYS_RM )

 SYS_NCO = "ncea -p "+diro+" JRA_06_climo.nc" \
                          +" JRA_07_climo.nc" \
                          +" JRA_08_climo.nc" \
                          +" "+patho
 print ("SYS_NCO: "+SYS_NCO)
 system( SYS_NCO )

;-------                    ; DJF seasonal file
 filo  = "JRA_DJF_climo.nc"
 patho = diro+"/"+filo 
 SYS_RM = "/bin/rm -f "+patho 
 system( SYS_RM )

 SYS_NCO = "ncea -p "+diro+" JRA_01_climo.nc" \
                          +" JRA_02_climo.nc" \
                          +" JRA_12_climo.nc" \
                          +" "+patho
 print ("SYS_NCO: "+SYS_NCO)
 system( SYS_NCO )

;-------                 ; ANN file
 filo  = "JRA_ANN_climo.nc"
 patho = diro+"/"+filo 
 SYS_RM = "/bin/rm -f "+patho 
 system( SYS_RM )

 SYS_NCO = "ncea -p "+diro+" JRA_01_climo.nc" \
                          +" JRA_02_climo.nc" \
                          +" JRA_03_climo.nc" \
                          +" JRA_04_climo.nc" \
                          +" JRA_05_climo.nc" \
                          +" JRA_06_climo.nc" \
                          +" JRA_07_climo.nc" \
                          +" JRA_08_climo.nc" \
                          +" JRA_09_climo.nc" \
                          +" JRA_10_climo.nc" \
                          +" JRA_11_climo.nc" \
                          +" JRA_12_climo.nc" \
                          +" "+patho
 print ("SYS_NCO: "+SYS_NCO)
 system( SYS_NCO )
