;----------------------------------------------------------------------
; Katrina_circle_hist.ncl
;
; Concepts illustrated:
;   - Using nggcog to create a great circle
;   - Using gc_inout to mask data inside a great circle
;   - Drawing a histogram to show the distribution of values.
;   - Using "cd_string" to produce a nice time label for a title
;   - Creating animations
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This script is based on Katrina_circle.ncl, which was contributed by 
; Jake Huff, a Masters student in the Climate Extremes Modeling Group 
; at Stony Brook University.
;
; The top image was created using nggcog and gc_inout to mask data 
; inside a great circle. The bottom image is a histogram, showing
; the disribution of the values for each contour level shown. This
; is useful for debug purposes.
;
; An animation is created using "convert" to convert from a PDF file
; to an animated GIF.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;----------------------------------------------------------------------
; Create a filled contour plot over a map.
;----------------------------------------------------------------------
function create_contour_plot(wks[1]:graphic,data:numeric,levels[*]:numeric,\
                             color_map[1]:string,minlat,maxlat,minlon,maxlon,\
                             title[1]:string)
local cres
begin
  cres                       = True
  cres@gsnMaximize           = True
  cres@gsnPaperOrientation   = "portrait"
  cres@gsnAddCyclic          = False
  cres@gsnDraw               = False  ; will panel later
  cres@gsnFrame              = False

  cres@mpDataBaseVersion     = "MediumRes"      ; higher map resolution  
  cres@mpOutlineBoundarySets = "GeophysicalAndUSStates"

  cres@mpMinLonF             = minlon
  cres@mpMaxLonF             = maxlon
  cres@mpMinLatF             = minlat
  cres@mpMaxLatF             = maxlat
  cres@mpCenterLonF          = (minlon+maxlon)/2

  cres@pmTickMarkDisplayMode = "Always"     ; nicer tickmarks for regional plots

  cres@cnFillOn              = True
  cres@cnLinesOn             = False
  cres@cnLineLabelsOn        = False
  cres@cnFillMode            = "RasterFill"
  cres@cnFillPalette         = color_map

  cres@lbLabelBarOn          = False         ; will add in panel
; cres@lbOrientation         = "Vertical"    ; will change in panel

  cres@cnLevelSelectionMode  = "ExplicitLevels"
  cres@cnLevels              = levels

  cres@pmTitleZone                  = 4      ; move main title down
  cres@gsnStringFontHeightF         = 0.015  ; make subtitles smaller
  cres@gsnRightStringOrthogonalPosF = 0.02   ; move subtitles down
  cres@gsnLeftStringOrthogonalPosF  = 0.02
  cres@tmXBLabelFontHeightF         = 0.015
  cres@tmYLLabelFontHeightF         = 0.015
  cres@tiMainString                 = title

  plot = gsn_csm_contour_map(wks,data,cres)
  return(plot)
end

;----------------------------------------------------------------------
; Given a data array and a list of *equally-spaced* levels, add an
; additional level at each end using the same spacing.
;----------------------------------------------------------------------
function get_hist_levels(data:numeric,levels[*]:numeric)
local nlevels, delta
begin
  nlevels = dimsizes(levels)
  hlevels = new(nlevels+2,typeof(data))
  delta = levels(1)-levels(0)
  hlevels(0)         = levels(0)-delta
  hlevels(nlevels+1) = levels(nlevels-1)+delta
  hlevels(1:nlevels) = levels
  return(hlevels)
end

;----------------------------------------------------------------------
; Create a histogram of the colors and levels used in a contour plot.
;----------------------------------------------------------------------
function create_histogram(wks[1]:graphic, contour_plot[1]:graphic, \
                          data:numeric,levels[*]:numeric)
local hres, colors, levels, hist_levels, nhlevels, tres,\
      xmin,xmax,ymin,ymax,xrange,yrange
begin
;---Retrieve colors and levels used, so we can produce a histogram
  getvalues contour_plot@contour
    "cnFillColors" : colors
    "vpWidthF"     : vpw
    "vpHeightF"    : vph
    "vpXF"         : vpx
    "vpYF"         : vpy
  end getvalues

;---For the histogram, we need 2 extra levels for the low/high end of the bins
  hist_levels = get_hist_levels(data,levels)

;---Create a histogram
  hres                             = True
  hres@gsnMaximize                 = True
;
; Make histogram same size as contour plot. This is so that when
; we panel the two together, they will be the same size.
;
  hres@vpWidthF                    = vpw
  hres@vpHeightF                   = vph
  hres@vpXF                        = vpx
  hres@vpYF                        = vpy

  hres@gsnDraw                     = False  ; will panel later
  hres@gsnFrame                    = False

  hres@trYMinF                     = 0
  hres@trYMaxF                     = 925   ; hard-coded; it would be better to compute this!

  hres@gsnHistogramClassIntervals  = hist_levels
  hres@gsnHistogramBarColors       = colors
  hres@gsnHistogramBarWidthPercent = 100.      ; make the bars the full 
                                               ; width of the interval
  hres@tiXAxisString               = ""
  hres@tiYAxisString               = ""

  hres@tmYMajorGrid                = True     ; turn on y grid lines
  hres@tmYMajorGridLineDashPattern = 2
  hres@tmGridDrawOrder             = "PreDraw"   ; only available in NCL 6.5.0
  hres@tmXBLabelFontHeightF        = 0.02
  hres@tmYLLabelFontHeightF        = 0.02
  hres@tmXBMinorOn                 = False
  hres@tmYLMinorOn                 = False
  hres@tmXTOn                      = False
  hres@tmYROn                      = False
  hres@tmXBOn                      = False
  hres@tmYLMajorOutwardLengthF     = 0.
  hres@tmYLMajorLengthF            = 0.
  hres@tmXBMajorOutwardLengthF     = 0.
  hres@tmXBMajorLengthF            = 0.
  
  plot = gsn_histogram(wks,ndtooned(data),hres)    

  getvalues plot
    "trXMinF" : xmin
    "trXMaxF" : xmax
    "trYMinF" : ymin
    "trYMaxF" : ymax
  end getvalues
  yrange = ymax-ymin
  xrange = xmax-xmin

;---Add text string in upper right corner of histogram.
  xpos = xmax - xrange*.05
  ypos = ymax - yrange*.05
  tres = True
  tres@txFontHeightF = 0.025
  tres@txJust        = "TopRight"
  plot@$unique_string("text")$ = gsn_add_text(wks,plot,"~C~Frequency",\
                                 xpos,ypos,tres)

  return(plot)
end

;----------------------------------------------------------------------
; Given a dataset and a set of levels, count how many values fall
; in each range:
;   # vals < levels(0)
;   # vals >= levels(0) and < levels(1)
;   # vals >= levels(1) and < levels(2)
;     . . .
;   # vals >= levels(nlevels-2) and < levels(nlevels-1)
;   # vals >= levels(nlevels-1)
;
; Also count number of valid values and missing values.
;
; This procedure is mainly for debug purposes.
;----------------------------------------------------------------------
procedure print_binned_info(data:numeric,levels[*]:numeric)
local total_binned, nlevels, count, scount, total_valid, total_msg
begin
  nlevels = dimsizes(levels)
  total_binned = 0
  do nl=0,nlevels
    if(nl.eq.0) then
      count = num(data.lt.levels(0))
      scount = sprinti("%4i",count)
      print("    " + scount + " values < " + levels(0))
    else if(nl.eq.nlevels) then
      count = num(data.ge.levels(nlevels-1))
      scount = sprinti("%4i",count)
      print("    " + scount + " values >= " + levels(nlevels-1))
    else
      count = num(data.ge.levels(nl-1).and.data.lt.levels(nl))
      scount = sprinti("%4i",count)
      print("    " + scount + " values >= " + levels(nl-1) + " and < " + levels(nl))
    end if
    end if
    total_binned = total_binned + count
  end do

  total_valid = num(.not.ismissing(data))
  total_msg   = num(ismissing(data))

  print("    There are " + total_valid + " valid values and " + \
        total_msg + " missing values.")
  print("    " + total_binned + " values were binned." + \
        " (This should be equal to the # of valid values.)")
end

;----------------------------------------------------------------------
; Panel both contour and histogram on the same page. It's assumed that
; both plots are the same size, or at least very close to the same size.
;----------------------------------------------------------------------
procedure panel_plots(wks,contour_plot,histogram)
local pres
begin
  pres                             = True
  pres@gsnMaximize                 = True
  pres@gsnPaperOrientation         = "portrait"
  pres@gsnPanelYWhiteSpacePercent  = 0.
  pres@gsnPanelYF                  = (/0.9,0.45/)
  pres@gsnPanelLabelBar            = True
  pres@lbOrientation               = "vertical"
  gsn_panel(wks,(/contour_plot,histogram/),(/2,1/),pres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  latS = 25
  latN = 45
  lonW = 260
  lonE = 290

  kat_ind = 6278    ; one of the indexes associated with Hurricane 
                    ; Katrina on the track file

  color_map = "WhiteBlueGreenYellowRed"

;---Read lat/lon data from Track file
  dir      = "./"
  obtracks = addfile(dir + "Allstorms.ibtracs_wmo.v03r05.nc","r")
  lat_wmo = short2flt(obtracks->lat_wmo)
  lon_wmo = short2flt(obtracks->lon_wmo)

;---Set all values outside the lat/lon box of interest to missing.
  lat_wmo@_FillValue = default_fillvalue("float")
  lon_wmo@_FillValue = default_fillvalue("float")
  lon_wmo = where( lon_wmo.lt.0,lon_wmo+360,lon_wmo)
  lat_wmo = where(lat_wmo .ge. latS .and. lat_wmo .le. latN,lat_wmo,lat_wmo@_FillValue)
  lon_wmo = where(lon_wmo .ge. lonW .and. lon_wmo .le. lonE,lon_wmo,lon_wmo@_FillValue)

;---Get indexes where we have valid lat/lon values for the Katrina index.
  ii   = ind(.not.ismissing(lat_wmo(kat_ind,:)).and..not.ismissing(lon_wmo(kat_ind,:)))
  nind = dimsizes(ii)

;---Convert time on the file to a nicely formatted string (for plotting)
  nice_date_str = cd_string(obtracks->time_wmo(kat_ind,:),"%D-%c %Y (%HH)")

;---Read in TRMM precipitation data that is a 5 day running average for just 2005 
  date_idx      = 7 ; Index where 2005 data starts
  datefile      = addfile("TRMMprecip.nc","r")
  AvgYearlyTRMM = datefile->AvgYearlyTRMM(date_idx,:,:)
  latTRMM       = datefile->lat
  lonTRMM       = datefile->lon

;---Start the graphics
  wks = gsn_open_wks("png","Katrina_circle_hist")

  clat = new(25,float)   ; arrays to hold great circle
  clon = new(25,float)
  radius = 5.0

  mnmxint = toint(nice_mnmxintvl( min(AvgYearlyTRMM), max(AvgYearlyTRMM), 25, False))
  levels  = ispan(mnmxint(0),mnmxint(1),mnmxint(2))

;
; Loop through non-missing lat/lon tracks for the storm and create a
; filled contour plot within the calculated lat/lon circle, and
; histogram showing the distribution of the values.
; 
  do ni=0,nind-1  
    j = ii(ni)
    lat_location = lat_wmo(kat_ind,j)  
    lon_location = lon_wmo(kat_ind,j)
    nggcog(lat_location,lon_location,radius,clat,clon)

    min_lat = min(clat)
    min_lon = min(clon)
    max_lat = max(clat)
    max_lon = max(clon)

;---Subset the desired rectagle of data 
    newTRMMyearly := AvgYearlyTRMM({min_lat:max_lat},{min_lon:max_lon})

;---Set points that are outside of the circle of data to missing
    lat2d := conform(newTRMMyearly,newTRMMyearly&lat,0)
    lon2d := conform(newTRMMyearly,newTRMMyearly&lon,1)
    in_circle := gc_inout(lat2d,lon2d,clat,clon)
    newTRMMyearly = where(in_circle,newTRMMyearly,newTRMMyearly@_FillValue)

;---Print some information about the data
    print("===========================================================")
    print("   Date:             " + nice_date_str(j))
    print("   Lat/Lon location: " + lat_location + "/" + lon_location)
    print("   Min/max of data:  " + min(newTRMMyearly) + "/" + \
                                    max(newTRMMyearly))
    print_binned_info(newTRMMyearly,levels)    ; Prints a lot of information

;---Create the filled contour plot
    contour_plot = create_contour_plot(wks,newTRMMyearly,levels,color_map,\
                                       latS,latN,lonW,lonE,nice_date_str(j))
;---Create the histogram.
    histogram = create_histogram(wks,contour_plot,newTRMMyearly,levels)

;---Panel both plots on the same page.
    panel_plots(wks,contour_plot,histogram)
  end do

;---Convert PDF to animated GIF.
  delete(wks)
  system("convert -delay 10 Katrina_circle_hist.pdf Katrina_circle_hist.gif")
end
