;==========================================================================
; NCL driver to convert multiple GrADS ctl/binary files to netCDF.
;==========================================================================
 dctl   = "./"                     ; dir where ctl & bin file are located
 fctl   = systemfunc ("cd "+dctl+" ; ls *ctl")  ; get all ctl files
 nctl   = dimsizes(fctl)

 chr    = stringtochar("^")    ; dimsizes(chr)=2
 caratc = chr(0)               ; carat is start of the file name

 do nf=0,nctl-1
    CTL   = asciiread(dctl+fctl(nf) , -1, "string")  ; read the ascii .ctl file
    dsetc = stringtochar( CTL(0) )          ; get the file name
    dStrt = ind(dsetc.eq.caratc)+1          ; index after carat

    fbin  = chartostring( (/ dsetc(dStrt:) /) )  ; this is the file name [no carat]

    system("/bin/rm -f "+dctl+fbin+".nc")   ; remove any pre-existing netCDF file

    CDO   = "cdo -f nc import_binary "+dctl+fctl(nf) +" "+dctl+fbin+".nc"  ; create NCL cmd
    print("CDO: "+CDO)
    system(CDO)

    delete(CTL)                             ; may change next iteration
    delete(dsetc)
 end do
