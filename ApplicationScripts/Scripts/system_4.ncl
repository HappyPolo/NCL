load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

  diri = "/datalocal/ccpd/xxxxxxx/growing_season/Interp_to_T42/A1B/"
  diro = "/project/cas/yyyy/XXXXXXX/"

  fili = systemfunc("cd "+diri+" ; ls *regridT42.nc")
  nfil = dimsizes(fili)
  print("nfil="+nfil)

  do nf=0,nfil-1
     print("=======================")

     sfx   = get_file_suffix(fili(nf),0)  
     filo  = sfx@fBase + ".detrend.nc"

     pathi = diri+fili(nf)
     patho = diro+filo
     system("/bin/rm -f "+patho)   ; remove any pre-existing file

     cmd   = "cdo detrend "+pathi+" "+patho
     print(cmd)
     system( cmd )
  end do

