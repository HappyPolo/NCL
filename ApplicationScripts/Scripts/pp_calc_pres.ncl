;-----------------------------------------------------------
; Description:
;
; This script basicaly calculates the pressure field in hybrid
; sigma coordinate of Hadley Center HadCM model output. The
; input file is in special binary format PP. 
;-----------------------------------------------------------
;-----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;-----------------------------------------------------------
begin

  ;---------------------------------------------------------
  ; User Defined Parameters:
  ;---------------------------------------------------------
  
  fin = "./aenwha.1.1.96.73.pit9410.ext.pp" ; input file (PP)
  nlev = 19 ; number of layers in file
 
  ;---------------------------------------------------------

  ;---------------------------------------------------------
  ; Table for Field Codes:
  ;
  ; The small set of field codes. For detailed info see,
  ; http://badc.nerc.ac.uk/data/link/model_runs.html
  ; http://badc.nerc.ac.uk/help/formats/pp-format/files/stash_field.txt 
  ;---------------------------------------------------------

  fields = new((/ 100 /), "string")

  fields(8)  = "Pstar (Pressure)"
  fields(19) = "Theta (Potential Temperature)"
  fields(56) = "Westerly Wind"
  fields(57) = "Southerly Wind"
  fields(95) = "Specific Humidity"

  ;---------------------------------------------------------

  ;---------------------------------------------------------
  ; Parameters: 
  ;---------------------------------------------------------

  fout = "output_pres.nc"
  system("/bin/rm -f "+fout)
  nc = addfile(fout, "c")

  ;--- enable define mode ---
  setfileoption(nc, "DefineMode", True)

  ;---------------------------------------------------------
  ; Read binary file in Hadley PP format
  ;
  ; For detailed info, see Appendix E in the following document
  ; http://precis.metoffice.com/docs/tech_man.pdf
  ;---------------------------------------------------------

  ;--- create arrays to store hybrid level coefficents ---
  ak = new((/ nlev /), "float")
  bk = new((/ nlev /), "float")

  ;--- get number of records in binary file ---
  nrec = fbinnumrec(fin)

  j = 0
  k = 0
  flag = True
  first = True
  lbfc_old = 0 
  do while (flag) 
    ;--- read header part (for integer ignore 46-64) ---
    rec1 = fbinrecread(fin, k, 64, "integer")
    ;print(rec1(0:44))

    lbyr   = rec1(0)  ; time of field (year)
    lbmon  = rec1(1)  ; time of field (month)
    lbdat  = rec1(2)  ; time of field (day)
    lbhr   = rec1(3)  ; time of field (hour)
    lbmin  = rec1(4)  ; time of field (minute)
    lbyrd  = rec1(6)  ; data time or epoc (year)
    lbmond = rec1(7)  ; data time or epoc (month)
    lbdatd = rec1(8)  ; data time or epoc (day)
    lbhrd  = rec1(9)  ; data time or epoc (hour)
    lbmind = rec1(10) ; data time or epoc (minute)
    lblrec = rec1(14) ; length of data record in words
    lbrow  = rec1(17) ; number of rows in field (latitude)
    lbnpt  = rec1(18) ; number of grid points in each row (longitude)
    lbfc   = rec1(22) ; field code
    lbvc   = rec1(25) ; vertical coordinate type

    ;--- read header part (for float ignore 1-45) ---
    rec2 = fbinrecread("./aenwha.1.1.96.73.pit9410.ext.pp", k, 64, "float")
    ;print(rec2(45:))

    brsvd1 = rec2(45) ; higher boundary of layer (b value, lbvc == 9) 
    brsvd2 = rec2(46) ; higher boundary of layer (a value, lbvc == 9)
    bdatum = rec2(49) ; constant value subtracted from each value in field
    blev   = rec2(51) ; b-value of level 
    brlev  = rec2(52) ; lower boundary of layer (b value, lbvc == 9)
    bhlev  = rec2(53) ; a-value of level
    bhrlev = rec2(54) ; lower boundary of layer (a value, lbvc == 9) 
    bzy    = rec2(58) ; latitude of ’zeroth’ row in degrees
    bdy    = rec2(59) ; latitude interval between rows in degrees
    bzx    = rec2(60) ; longitude of ’zeroth’ point in row in degrees
    bdx    = rec2(61) ; longitude spacing of points in each row in degrees
    bmdi   = rec2(62) ; value used in the field to indicate missing data points
    bmks   = rec2(63) ; scaling factor

    ;--- read data ---
    rec3 = fbinrecread("./aenwha.1.1.96.73.pit9410.ext.pp", k+1, (/ lbrow,lbnpt /), "float")
    ;print(rec3)

    ;--- store ak and bk coefficents (if it is not surface variable) ---    
    if (lbvc .ne. 129) then
      if (lbfc .ne. lbfc_old) then
        ind_lev = 0
      else
        ind_lev = ind_lev+1
      end if

      ak(ind_lev) = bhlev
      bk(ind_lev) = blev
    end if
     
    ;--- calculate pressure field (millibar) in hybrid levels ---
    ;--- surfece pressure (field code == 8, STASH code == 1) ---
    if (lbfc .eq. 8) then
      ;--- print out date ---
      print("Date: "+sprinti("%d", lbyr)+"-"+sprinti("%2.2d", lbmon)+\
            "-"+sprinti("%2.2d", lbdat)+"_"+sprinti("%2.2d", lbhr)+\
            ":"+sprinti("%2.2d", lbmin)+" "+k+" "+nrec)
      
      ;--- create pressure array ---
      pres = new((/ dimsizes(ak),lbrow,lbnpt /), "float")

      ;--- convert hybrid to pressure ---
      
      do i = 0, nlev-1
        ;--- reverse levels (it is in wrong order) ---
        ;--- convert Pascal to millibar ---
        ;pres(nlev-1-i,::-1,:) = (ak(i)+(bk(i)*rec3))*0.01
        pres(i,::-1,:) = (ak(i)+(bk(i)*rec3))*0.01
      end do

      ;--- write pressure field to file ---
      if (first) then
        ;--- predefine coordinate variables ---
        dimNames = (/ "time", "lev", "lat", "lon" /)
        dimSizes = (/ -1, nlev, lbrow, lbnpt /)
        dimUnlim = (/ True , False, False, False /)
        filedimdef(nc, dimNames, dimSizes, dimUnlim)
        
        ;--- predefine dimension of variables ---
        filevardef(nc, "time", "double", (/ "time" /))
        filevardef(nc, "lev", "float", (/ "lev" /))
        filevardef(nc, "lat", "float", (/ "lat" /))
        filevardef(nc, "lon", "float", (/ "lon" /))
        filevardef(nc, "pres", "float", (/ "time", "lev", "lat", "lon" /))

        ;--- add attributes to variables ---
        attr = True
        attr@units = "millibar"  
        attr@long_name = "Pressure"
        filevarattdef(nc, "pres", attr)
        delete(attr)

        attr = True
        attr@positive = "up"
        attr@units = "level"
        attr@long_name = "Hybrid Pressure Level"
        filevarattdef(nc, "lev", attr)
        delete(attr)

        attr = True
        attr@units = "degrees_north"
        attr@long_name = "Latitude"
        filevarattdef(nc, "lat", attr)
        delete(attr)

        attr = True
        attr@units = "degrees_east"
        attr@long_name = "Longitude"
        filevarattdef(nc, "lon", attr)
        delete(attr)

        attr = True
        str_epoc = "days since "+sprinti("%d", lbyrd)+"-"+sprinti("%2.2d", lbmond)+\
                   "-"+sprinti("%2.2d", lbdatd)+" "+sprinti("%2.2d", lbhrd)+\
                   ":"+sprinti("%2.2d", lbmind)+":00"
        attr@units = str_epoc
        attr@long_name = "Validity Time"
        attr@calendar = "360_day"
        filevarattdef(nc, "time", attr)
        delete(attr)

        ;--- exit define mode ---
        setfileoption(nc, "DefineMode", False)

        ;--- fill data ---
        nc->lev = (ak/1e5)+bk
        nc->lon = fspan(bzx+bdx, bzx+lbnpt*bdx, lbnpt)-360.0 
        nc->lat = fspan(bzy+lbrow*bdy, bzy+bdy, lbrow) ; reverse lat

        first = False
      end if

      ;--- bug fix, see http://www.ncl.ucar.edu/known_bugs.shtml ---
      dum_time = 17522904
      dum_time@units = "hours since 1-1-1 00:00:0.0"
      dum_date = cd_calendar(dum_time, 0)

      option = 0
      option@calendar = "360_day"
      str_time = cd_inv_calendar(lbyr, lbmon, lbdat, lbhr, lbmin, 0, str_epoc, option)
      nc->time(j) = (/ str_time /)

      nc->pres(j,:,:,:) = (/ pres /)

      j = j+1
    end if

    ;--- assign new value to indices ---
    k = k+2
    lbfc_old = lbfc

    ;--- check end of file ---
    if (k .eq. nrec) then
      flag = False
    end if 

    ;--- delete temporary variables ---
    ;--- the dimension is not same for all variables ---
    delete (rec3)
  end do

  ;---------------------------------------------------------
end
