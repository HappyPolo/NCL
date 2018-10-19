undef("station_stats")
procedure station_stats_prc(data[*][*]:numeric)
local id, yyyy, mm, dd, jday, prc, lat, lon, N, icrit, avg1, med1
begin
;---extract columns
   id   = toint( data(:,0) )
   yyyy = toint( data(:,1) )
   mm   = toint( data(:,2) )
   dd   = toint( data(:,3) )
   jday = data(:,4)
   prc  = data(:,5)
   lat  = data(:,6)
   lon  = data(:,7)
   N    = dimsizes(id)
                            ; current station
   ID   = id(0)             ; convenience

;---statistics

   pcrit   = 1.0
   n_pcrit = num(prc.ge.pcrit)
   n_pcrit@long_name = "number of events >= "+pcrit

   icrit   = ind(prc.ge.pcrit)    ; indices

   avg1    = dim_avg_n(prc(icrit), 0)
   avg1@long_name = "avg when prc >= "+pcrit

   med1    = dim_median_n(prc(icrit), 0)
   med1@long_name = "median when prc >= "+pcrit

;---add other statistics could be added

   print("n_pcrit="+n_pcrit+";  avg1="+avg1+";  med1="+med1)

end
;------------------------------------------------------------------------
;                       MAIN
;------------------------------------------------------------------------

;--- directory and name of file(s)

   diri = "./"
   fili = (/ "tAL.csv" /)   ; one or more file names; also use systemfunc
   pthi = diri+fili
   nfili= dimsizes(fili)

;--- read file; could contain multiple stations
;--- sample lines:
;---"StationID","Year","Month","Day","Julian Day","Precip","Lat","Long"
;---11084,1950,1,1,2433284.195625,0,31.0581,-87.0547
;--- .....
;---11084,2011,12,31,2455928.79375,0,31.0581,-87.0547
;---12813,1950,1,1,2433284.195625,0,30.5467,-87.8808       <=== new station ID
;--- .....

   ncol = 8
   nhd  = 1           ; number of header lines

;---Loop over each file

 do nf=0,nfili-1

    table := readAsciiTable(pthi(nf), ncol, "float", nhd)
    printVarSummary(table)
    print("-----")

    id    := toint( table(:,0) )                 ; 1st (0th) column; station id
    N      = dimsizes(id)                        ; number of lines in file
    print("N="+N)
 
;---Use NCL's 'ind' function to determine where the 'id' changes
;---https://www.ncl.ucar.edu/Document/Functions/Built-in/ind.shtml

    inew  := ind((id(0:N-2)-id(1:N-1)).ne.0)     ; detect index when station id changes
    if (ismissing(inew(0))) then
        nsta = 1                                 ; only one station on the file
    else
        nsta   = dimsizes(inew)+1                ; number of stations 
    end if

    print(inew)
    print("nsta="+nsta)
    print("-----")
 
;---Create start/end indices for each station in the current file
 
    iStrt := new(nsta, "integer", "No_FillValue") 
    iLast := new(nsta, "integer", "No_FillValue") 

    iStrt(0) = 0
    iLast(0) = inew(0)
    if (nsta.gt.1) then
       do ns=1,nsta-2
          iStrt(ns) = iLast(ns-1)+1
          iLast(ns) = inew(ns)
       end do
       iStrt(nsta-1) = iLast(nsta-2)+1
       iLast(nsta-1) = N-1
    end if

   ;print(iStrt+"   "+iLast)
   ;print("-----")

;---Loop over each station in the current file

   do ns=0,nsta-1         
      print("ns="+ns+"  iStrt(ns)="+iStrt(ns)+" iLast(ns)="+iLast(ns))
      station_stats_prc( table(iStrt(ns):iLast(ns),:) )
   end do   ; ns
 end do     ; nf
