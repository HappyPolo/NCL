  diro   = "/project/cas/DATA/JRA25/6HR_DSS_GRIB/UV_6HR/"

  diri   = "/project/cas/DATA/JRA25/6HR_DSS_GRIB/"
  syscmd = "cd "+diri+" ; ls *tar"
  print(""+syscmd)                         ; echo command sent to system
  ftar   = systemfunc(syscmd)
  print(ftar)
  print("=====================================")

  ntar   = dimsizes(ftar)
                                     
  quote = str_get_dq()                    ; used for string creation below
                                          ; http://www.ncl.ucar.edu/FAQ/#core_lang_006

  do nt=0,ntar-1                          ; loop over all the tar files

     syscmd = "tar -xvf "+diri+ftar(nt)   ; untar the file [new dir] 
     print(""+syscmd)                  
     system(syscmd)                    

     yyyymm = str_get_cols(ftar(nt), 0, 5); extract from tar file
     syscmd = "cd "+yyyymm+" ; ls anl_p25."+yyyymm+"*"
     print(""+syscmd)                  
     system(syscmd)                    
     fgrb   = systemfunc(syscmd)               ; eg: anl_p25.1979010100
    ;print(fgrb)

     ngrb   = dimsizes(fgrb)                    ; no. of grib files for the yyyymm

    do ng=0,ngrb-1                              ; loop over each grib file       

       grib_in  = diri+yyyymm+"/"+fgrb(ng)
       ymdh     = str_get_cols(fgrb(ng), 8,17)  ; extract yyyymmddhh
       grib_out = diro+"uv_"+ymdh    
      ;print(""+grib_in+"  "+grib_out)

       syscmd = "wgrib -s "+grib_in+" | " \
              + "egrep "+quote+"(:UGRD:200 mb|:VGRD:200 mb|:UGRD:850 mb|:VGRD:850 mb)"+quote+" | " \
              + "wgrib -i -grib "+grib_in+" -o "+grib_out
       print(""+syscmd)                  
       system(syscmd)                    
    end do

    syscmd = "/bin/rm -r "+yyyymm
    print(""+syscmd)                  
    system(syscmd)                    

    delete(fgrb)

  end do
  
; The command line version
;wgrib -s anl_p25.1990010100 | egrep "(:UGRD:200 mb|:VGRD:200 mb|:UGRD:850 mb|:VGRD:850 mb)" | wgrib -i -grib anl_p25.1990010100 -o FOO.grb

