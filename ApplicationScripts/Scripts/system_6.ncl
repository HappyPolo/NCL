;-----------------------------------------------------
; Take all variables of rank >= 2 and of type 'double'
; and convert these variables to type 'float'
;-----------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

 wcStrt = systemfunc("date")

 diri  = "./"
 fili  = "err09.cam2.r.2009-01-03-43200.nc"           ; 10+GB

 diro  = "./"
 filo  = "err09.cam2.r.2009-01-03-43200.float.nc"     ;  5GB

 f     = addfile(diri+fili,"r")
 vnam  = getfilevarnames(f)                           ; all variable names
 vtyp  = getfilevartypes(f, vnam)                     ; type of each variable
 print(vnam+"   "+vtyp) 

 nvar  = dimsizes(vnam)                               ; # of variables

 NCAP2 = "ncap2 -O " 

 do nv=0,nvar-1                                       ; loop over each variable
    rankv = dimsizes( getfilevardimsizes(f, vnam(nv)) )
   ;print("nv="+nv+"  rankv="+rankv)

    if (vtyp(nv).eq."double" .and. rankv.ge.2) then
        vopt  = " -s '"+vnam(nv)+"=float("+vnam(nv)+")'"
        NCAP2 = NCAP2 + vopt
    end if
 end do

 pathi = diri+fili
 patho = diro+filo

 NCAP2 = NCAP2 +" "+pathi+" "+patho  
 print(NCAP2) 

 system(NCAP2)

 wallClockElapseTime(wcStrt, "NCAP2 file creation", 0)
