;-----------------------------------------------------------
; Description:
;
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
  ; Table for Fields:
  ;
  ; The small set of fields. For detailed info see,
  ; http://badc.nerc.ac.uk/data/link/model_runs.html
  ; http://badc.nerc.ac.uk/help/formats/pp-format/files/stash_field.txt 
  ;---------------------------------------------------------

  table = (/\
  (/ "8" , "pstar", "Surface Pressure"     , "millibar" /),\
  (/ "19", "theta", "Potential Temperature", "kelvin"   /),\
  (/ "56", "u"    , "Westerly Wind"        , "m s-1"    /),\
  (/ "57", "v"    , "Southerly Wind"       , "m s-1"    /),\
  (/ "95", "shum" , "Specific Humidity"    , "kg kg-1"  /) /)

  ;---------------------------------------------------------
  ; Create file list and open files 
  ;---------------------------------------------------------

  itable = dimsizes(table(:,0)) 
  fout = new((/ itable /), "string")
  first = new((/ itable /), "logical")

  do i = 0, itable-1
    fout(i) = "output_"+table(i,1)+".nc"
    system("/bin/rm -f "+fout(i))
  end do

  nc = addfiles(fout, "c")

  do i = 0, itable-1
    ;--- enable define mode ---
    setfileoption(nc[i], "DefineMode", True)
  end do

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

  k = 0
  itime = -1
  flag = True
  first = True
  lbfc_pre = 0
  str_time_pre = ""
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

    ;--- date string ---
    str_epoc = "days since "+sprinti("%d", lbyrd)+"-"+sprinti("%2.2d", lbmond)+\
               "-"+sprinti("%2.2d", lbdatd)+" "+sprinti("%2.2d", lbhrd)+\
               ":"+sprinti("%2.2d", lbmind)+":00"

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

    ;--- bug fix, see http://www.ncl.ucar.edu/known_bugs.shtml ---
    dum_time = 17522904
    dum_time@units = "hours since 1-1-1 00:00:0.0"
    dum_date = cd_calendar(dum_time, 0)

    ;--- calculate date ---
    option = 0
    option@calendar = "360_day"
    str_time = cd_inv_calendar(lbyr, lbmon, lbdat, lbhr, lbmin, 0, str_epoc, option)

    ;--- set date index ---
    if (str_time .ne. str_time_pre) then
      itime = itime+1
      str_time_pre = str_time
      print("Date: "+sprinti("%d", lbyr)+"-"+sprinti("%2.2d", lbmon)+\
            "-"+sprinti("%2.2d", lbdat)+"_"+sprinti("%2.2d", lbhr)+\
            ":"+sprinti("%2.2d", lbmin)+" "+sprintf("%8.2f", str_time))
    end if

    ;--- get index of variable
    ivar = ind(table(:,0) .eq. sprinti("%d", lbfc))  
    nc_single = nc[ivar]

    ;--- store ak and bk coefficents (if it is not surface variable) ---
    if (lbvc .ne. 129) then
      if (lbfc .ne. lbfc_pre) then
        ilev = 0
      else
        ilev = ilev+1
      end if

      ak(ilev) = bhlev
      bk(ilev) = blev
    end if

    if (first(ivar)) then
      if (lbvc .eq. 9) then
        ;--- predefine coordinate variables ---
        dimNames = (/ "time", "lev", "lat", "lon" /)
        dimSizes = (/ -1, nlev, lbrow, lbnpt /) 
        dimUnlim = (/ True , False, False, False /)
        filedimdef(nc_single, dimNames, dimSizes, dimUnlim) 

        ;--- predefine dimension of variables ---
        filevardef(nc_single, "time", "double", (/ "time" /))
        filevardef(nc_single, "lev", "float", (/ "lev" /))
        filevardef(nc_single, "lat", "float", (/ "lat" /))
        filevardef(nc_single, "lon", "float", (/ "lon" /))

        ;--- add attributes ---
        attr = True
        attr@positive = "up"
        attr@units = "level"
        attr@long_name = "Hybrid Pressure Level"
        filevarattdef(nc_single, "lev", attr)
        delete(attr)
      else
        ;--- predefine coordinate variables ---
        dimNames = (/ "time", "lat", "lon" /)
        dimSizes = (/ -1, lbrow, lbnpt /)
        dimUnlim = (/ True , False, False /)
        filedimdef(nc_single, dimNames, dimSizes, dimUnlim)

        ;--- predefine dimension of variables ---
        filevardef(nc_single, "time", "double", (/ "time" /))
        filevardef(nc_single, "lat", "float", (/ "lat" /))
        filevardef(nc_single, "lon", "float", (/ "lon" /))
      end if

      attr = True
      attr@units = "degrees_north"
      attr@long_name = "Latitude"
      filevarattdef(nc_single, "lat", attr)
      delete(attr)

      attr = True
      attr@units = "degrees_east"
      attr@long_name = "Longitude"
      filevarattdef(nc_single, "lon", attr)
      delete(attr)

      attr = True
      attr@units = str_epoc
      attr@long_name = "Validity Time"
      attr@calendar = "360_day"
      filevarattdef(nc_single, "time", attr)
      delete(attr)

      ;--- exit define mode ---
      setfileoption(nc_single, "DefineMode", False)      

      ;--- fill data ---
      nc_single->lon = fspan(bzx+bdx, bzx+lbnpt*bdx, lbnpt)-360.0 
      nc_single->lat = fspan(bzy+lbrow*bdy, bzy+bdy, lbrow) ; reverse lat

      ;--- delete tmp varables ---
      delete(dimNames)
      delete(dimSizes)
      delete(dimUnlim)

      first(ivar) = False
    end if

    ;--- check variable is defined or not ---
    if (.not. isfilevar(nc_single, table(ivar,1))) then
      ;--- define variable ---
      if (lbvc .eq. 9) then
        filevardef(nc_single, table(ivar,1), "float", (/ "time", "lev", "lat", "lon" /))
      else
        filevardef(nc_single, table(ivar,1), "float", (/ "time", "lat", "lon" /))
      end if

      ;--- add attributes to variables ---
      attr = True
      attr@units = table(ivar,3) 
      attr@long_name = table(ivar,2)
      filevarattdef(nc_single, table(ivar,1), attr)
      delete(attr)
    end if

    ;--- add data ---
    nc_single->time(itime) = (/ str_time /)
    if (lbvc .eq. 9) then
      ;nc_single->$table(ivar,1)$(itime,(nlev-(ilev+1)),:,:) = (/ rec3(::-1,:) /) 
      ;print("-- "+ilev+" "+ak(ilev)+" "+bk(ilev)+" "+ivar)
      nc_single->lev = (ak/1e5)+bk
      nc_single->$table(ivar,1)$(itime,ilev,:,:) = (/ rec3(::-1,:) /) 
    else
      nc_single->$table(ivar,1)$(itime,:,:) = (/ rec3(::-1,:) /)
    end if

    ;--- assign new value to indices ---
    k = k+2
    lbfc_pre = lbfc

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
