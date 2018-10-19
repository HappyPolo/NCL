;----------------------------------------------------------------------
; Read the CSV gauge file and return the list of station names,
; lats, and lons.
;----------------------------------------------------------------------
function read_gauge_stations(csv_filename)
begin
  lines        = asciiread(csv_filename,-1,"string")
  csv_lines    = str_split_csv(lines,",",0)

;---Read each field
  fid  = toint(csv_lines(1:,0))
  name = csv_lines(1:,1)
  lat  = tofloat(csv_lines(1:,2))
  lon  = tofloat(csv_lines(1:,3))
  return([/name,lat,lon/])
end

;----------------------------------------------------------------------
; This procedure takes an existing XY plot, retrieves the viewport 
; coordinates, and fills that area in the desired color.
;----------------------------------------------------------------------
procedure fill_xy_plot_area(wks,plot)
begin
  getvalues plot
    "trXMinF"   : xmin
    "trYMinF"   : ymin
    "trXMaxF"   : xmax
    "trYMaxF"   : ymax
  end getvalues

  xbox = (/xmin,xmax,xmax,xmin,xmin/)
  ybox = (/ymin,ymin,ymax,ymax,ymin/)
  gnres = True
  gnres@gsFillColor     = "LightGray"
  gnres@tfPolyDrawOrder = "PreDraw"
  plot@$unique_string("box")$ = gsn_add_polygon(wks,plot,xbox,ybox,gnres)
end

;----------------------------------------------------------------------
; Main driver code
;----------------------------------------------------------------------
begin
;----------------------------------------------------------------------
; Read station gauge data
;----------------------------------------------------------------------
  csv_filename = "EstHidro_OK.csv"
  csv_list = read_gauge_stations(csv_filename)
  stn_name = csv_list[0]
  stn_lat  = csv_list[1]
  stn_lon  = csv_list[2]
  nstn     = dimsizes(stn_name)

;----------------------------------------------------------------------
; Get list of CHRTOUT filenames
;----------------------------------------------------------------------
  times = ispan(3,6,1)
  ntim = dimsizes(times)

  filenames = "201003010" + times + "00.CHRTOUT_DOMAIN3"
  filenames = filenames + ".nc"

;----------------------------------------------------------------------
; Open file for sending graphics to.
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","streamflow_table")

  plots = new(nstn,graphic)

;----------------------------------------------------------------------
; Set plot options for XY plots
;----------------------------------------------------------------------
  res = True

;---Turn these off because we plan to panel later.
  res@gsnDraw        = False
  res@gsnFrame       = False

;---Change aspect ratio of plot
  res@vpWidthF       = 0.7 
  res@vpHeightF      = 0.5

;---Customize the markers
  res@xyMarkLineMode = "Markers"      ; default is line
  res@xyMarker       = 16             ; filled dot
  res@xyMarkerSizeF  = 20.0           ; default is a little small
  res@xyMarkerColor  = "darkorange4"

;---Set the X and Y axis limits
  res@trYMinF        = -0.04
  res@trYMaxF        = 0.75
  res@trXMinF        = min(times)-0.1
  res@trXMaxF        = max(times)+0.1

  res@tmGridDrawOrder = "predraw"    ; new resource added in NCL V6.5.0

;---Customize the X tickmarks and add some grid lines
  res@tmXBMode        = "Explicit"      ; Change labels on X axis.
  res@tmXBValues      = times
  res@tmXBMinorValues = ispan(min(times)*10,max(times)*10,5)*0.1
  res@tmXBLabels      = sprinti("%0.2i",times) + ":00"

  res@tmXTOn                  = False
  res@tmXMajorGrid            = True
  res@tmXMinorGrid            = True
  res@tmXMajorGridLineColor   = "White" ; "LightGray"
  res@tmXMinorGridLineColor   = "White" ; "LightGray"
  res@tmXBMinorPerMajor       = 1
  res@tmXBMinorOutwardLengthF = 0.0
  res@tmXBMinorLengthF        = 0.0

;---Customize the Y tickmarks and add some grid lines
  res@tmYMajorGrid            = True
  res@tmYMinorGrid            = True
  res@tmYMajorGridLineColor   = "White" ; "LightGray"
  res@tmYMinorGridLineColor   = "White" ; "LightGray"
  res@tmYLTickSpacingF        = 0.2
  res@tmYLMinorPerMajor       = 1
  res@tmYLFormat              = "0@;*.1f"
  res@tmYROn                  = False
  res@tmYLMinorOutwardLengthF = 0.0
  res@tmYLMinorLengthF        = 0.0
  res@tmXBMajorOutwardLengthF = 0.0
  res@tmXBMajorLengthF        = 0.0
  res@tmXBMinorOutwardLengthF = 0.0
  res@tmXBMinorLengthF        = 0.0

  res@tiYAxisString           = ""
  res@tiMainFontHeightF       = 0.025
   

;----------------------------------------------------------------------
; Loop across each station and create an XY plot for paneling later.
;----------------------------------------------------------------------
  flow = new(ntim,float)
  do ns=0,nstn-1
;
; The lat/lon are the same across all files, so only need to 
; calculate min distance for one of the files.
;
    a    = addfile(filenames(0),"r")
    lat  = a->latitude
    lon  = a->longitude

;---Find lat,lon index that is the closest to this station's lat/lon
    dist = sqrt(((lat-stn_lat(ns))^2) + ((lon-stn_lon(ns))^2))
    imin = minind(dist)

    print("==================================================")
    print("Station '" + stn_name(ns) + "'")
    print("Lat = " + stn_lat(ns) + ", Lon = " + stn_lon(ns))
    print("Closest Lat/Lon is at index " + imin)
    print("Lat = " + lat(imin) + ", Lon = " + lon(imin))

;----------------------------------------------------------------------
; Find the streamflow for each time for this station and store in the
; "flow" array.
;----------------------------------------------------------------------
    do nt=0,ntim-1
      a = addfile(filenames(nt),"r")
      flow(nt) = a->streamflow(imin)
      print("Flow at time " + times(nt) + " = " + flow(nt))
    end do

;----------------------------------------------------------------------
; Set additional resources to turn off various tickmarks and labels
; depending on which plots we're drawing
;----------------------------------------------------------------------
    if(ns.eq.1.or.ns.eq.3) then      ; The rightmost plots; turn off left labels
      res@tmYLLabelsOn = False
      res@tmYLMajorOutwardLengthF = 0.0
      res@tmYLMajorLengthF        = 0.0
      res@tmYLMinorOutwardLengthF = 0.0
      res@tmYLMinorLengthF        = 0.0
    else
      res@tmYLLabelsOn = True
      delete_attr(res,"tmYLMinorOutwardLengthF")
      delete_attr(res,"tmYLMinorLengthF")
      delete_attr(res,"tmYLMajorOutwardLengthF")
      delete_attr(res,"tmYLMajorLengthF")
    end if
    if(ns.eq.0.or.ns.eq.1) then      ; The topmost plots; turn off bottom labels
      res@tmXBLabelsOn = False
    else
      res@tmXBLabelsOn = True
    end if

;----------------------------------------------------------------------
; Create the XY plot for this station.
;----------------------------------------------------------------------
    res@tiMainString = stn_name(ns)
    plots(ns) = gsn_csm_xy(wks,times,flow,res)
    fill_xy_plot_area(wks,plots(ns))
  end do
;----------------------------------------------------------------------
; Panel the four plots.
;----------------------------------------------------------------------
  pres             = True
  pres@gsnMaximize = True
  pres@gsnPanelXF  = (/0.08,0.54,0.08,0.54/)  ; slightly adjust X location of each plot
  pres@gsnFrame    = False
  gsn_panel(wks,plots,(/2,2/),pres)

;----------------------------------------------------------------------
; Add a sideways text string on left sidel.
;----------------------------------------------------------------------
  txres               = True
  txres@txFontHeightF = 0.02
  txres@txAngleF      = 90    ; rotate 90 degrees
  gsn_text_ndc(wks,"streamflow",0.015,0.5,txres)

;----------------------------------------------------------------------
; Advance frame once we are done drawing to this page.
;----------------------------------------------------------------------
  frame(wks)
end
