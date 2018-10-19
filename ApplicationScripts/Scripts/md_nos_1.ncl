load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  


begin
  nhead = 4
  head  = readAsciiHead("2004021700.balt", nhead)

  site_char  = stringtocharacter(head(0))
  site       = charactertostring(site_char(27:))

  ncol  = 7
  data  = readAsciiTable("2004021700.balt", ncol, "float", nhead)
  tide  = data(:,6)
  year  = data(0,1)
  month = floattointeger(data(0,2)) ; make integer so we can use as subscript
  day   = data(:,3)
  hour  = data(:,4)

; create some arrays for the plot
  x = ispan(0,dimsizes(tide)-1,1)     ; create x array for xy plot
  xlabs = new(dimsizes(tide),string)  ; create special labels for xy plot
  do i = 0,dimsizes(tide)-1
    xlabs(i) = day(i) + "/" + hour(i)
  end do

  months = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct",\
              "Nov","Dec"/)
;****************************************************
; create xy plot of tidal information
;**************************************************** 
  wks   = gsn_open_wks ("ps","md_nos")                ; open workstation

  res                   = True                       ; plot mods desired
  res@tiMainString      = year + " "+months(month) +":"+site ; add title

  stride                = 12                         ; set stride for labels
  res@tmXBMode          = "Explicit"                 ; explicit labels
  res@tmXBValues        = x(::stride)                ; location of labels 
  res@tmXBLabels        = xlabs(::stride)

  res@tiXAxisString     = "Day/Hour"                 ; x-axis string
  res@tiYAxisString     = "Tide (m)"                 ; y-axis string
  plot  = gsn_csm_xy (wks,x,tide,res)                ; create plot
end

