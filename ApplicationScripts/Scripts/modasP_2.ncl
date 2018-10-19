load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;********************************************
begin     
; this example reads in multiple files and puts them on one plot.


; read in header info and put into arrays
  nfiles = 3
  date = new(nfiles,"integer")
  lat  = new(nfiles,"float")
  lon  = new(nfiles,"float") ; memory must be preallocated when using loops
  npts  = new(nfiles,"integer") 

  do i = 0, nfiles-1
    ii      = i+1
    head     = readAsciiHead ("nodc_"+ ii +".flat", 1.)
    date(i)  = floattointeger(head(0))        
    lat(i)   = head(1)
    lon(i)   = head(2)
    npts(i)  = floattointeger(head(3))
    delete(head)
  end do

; determine file index of deepest profile for use in plotting
  deepest = 0
  do i = 0, nfiles-1
    if(npts(i).gt.deepest)then
      deepest = i
    end if
  end do
  print("profile "+deepest+" has "+npts(deepest)+" points")

; read in maxtrix and put into array: iiber of files by maximum number of pts
; must set array size to be size of largest profile
  depth = new((/nfiles,max(npts)/),"float") 
  temp  = new((/nfiles,max(npts)/),"float") 
  sal   = new((/nfiles,max(npts)/),"float")
  
  do i = 0, nfiles-1
    ii           = i+1
    data          = readAsciiTable("nodc_"+ ii +".flat",3,"float",1)
    depth(i,:)    = data(:,0)
    temp(i,:)     = data(:,1)
    sal(i,:)      = data(:,2)
    delete(data)
  end do
; assign meta data to arrays
  depth@long_name = "depth"
  depth@units     = "m"
  temp@long_name  = "temperature"
  temp@units      = "degC"
  sal@long_name   = "salinity"
  sal@units       = "ppm" 
;**************************
; create plot
;**************************                                    
  wks   = gsn_open_wks ("ps","modasP")               ; open workstation

  res                   = True                       ; plot mods desired 
  res@gsnCenterString   = date(0)                    ; add center string
  res@tiMainString      = lat(0) +"N "+lon(0)        ; add title
  res@trYReverse        = True                       ; reverse Y-axis

  res@xyLineThicknesses = 2.0                        ; make line thicker
  res@xyLineColors      = (/"blue","red","green"/)   ; change line color

  plot  = gsn_csm_xy (wks,temp,depth(deepest,:),res) ; create plot

  plot  = gsn_csm_xy (wks,sal,depth(deepest,:),res)  ; create plot
  
                                    
end   
                     
