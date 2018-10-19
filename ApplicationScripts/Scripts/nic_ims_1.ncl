;*************************************************
; NCL Graphics: nic_1.ncl
;
; Concepts illustrated:
;    - Plotting ice data
;    - Reading data from binary files
;    - Reading data from an ASCII file with headers
;    - Changing the labelbar labels
;    - Plotting categorical data
;
; This example shows how to plot data from the NIC (National Ice Center);
; specifically the 24 km IMS (Interactive Multisensor Snow and Ice Mapping System)
; Daily Northern Hemisphere Snow and Ice Analysis. The data in ascii format 
; is available from ftp://sidads.colorado.edu/pub/DATASETS/NOAA/G02156/24km. The
; lat/lon grids are in binary and may be found at 
; ftp://sidads.colorado.edu/pub/DATASETS/NOAA/G02156/metadata.
; The data are mapped into a polar stereographic projection centered at 90 degrees North,
; with a center longitude of 80 West. 
;
; According to the description of the data grid at 
; http://nsidc.org/data/docs/noaa/g02156_ims_snow_ice_analysis
; use of this data should be acknowledged and cited as follows:
;
; National Ice Center. 2008, updated daily. 
; IMS daily Northern Hemisphere snow and ice analysis at 4 km and 24 km resolution. 
; Boulder, CO: National Snow and Ice Data Center. Digital media.
;
; See comments interspersed with  the code for additional detail concerning 
; the techniques used to plot these data.
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  nrows = 1024
  ncols = 1024
;
; The lat/lon values are in binary format with the areas outside the projected space set to 
; the IEEE NaN (Not a Number) value. Since the graphics routines do not work well with NaN
; values, change them to the default fillvalue for the type of the data, which is float.
;

  setfileoption("bin","ReadByteOrder","LittleEndian")

  lat  = cbinread("imslat_24km.dat", (/nrows,ncols/), "float")
  lon  = cbinread("imslon_24km.dat", (/nrows,ncols/), "float")

  msg = default_fillvalue("float")
  lat = where(isnan_ieee(lat),msg,lat)
  lon = where(isnan_ieee(lon),msg,lon)

  lat@_FillValue = msg
  lon@_FillValue = msg

;
; The data file contains categorical data with values 0 - 5 where  each line represents a row of the the grid
; There is no delimiter between the data values which are all single digits. The value 0 represents areas
; outside the circular limits of the projection. To get this into a usable form in NCL read the data as
; strings and then use the function str_split_by_length to break the line length strings into strings of 1
; character each. Then convert to float.
;
  nhead   = 30
  filr    = "ims2008349"
  fili    = filr+"_header.txt"

;
; wrkc_2d will be nrows (1024 x 1)
; It is necessary to subscript the array to get rid of the right hand single element dimension
;
  wrkc_2d = readAsciiTable(fili, 1, "string", nhead )
  data = tofloat(str_split_by_length(wrkc_2d(:,0),1))
;
; Designate the value 0 as the fill value, but then change all the fill values to the default float
; fill value in order to satisfy the contouring code which does not accept 0 as a fill value.
;
  data@_FillValue = 0
  data@_FillValue = msg


;
; Print some statistics about the data
;
  print("Total number of points    = " + product(dimsizes(data)))
  print("num(ismissing(data))      = " + num(ismissing(data)))
  print("num(.not.ismissing(data)) = " + num(.not.ismissing(data)))  
  print("num(ismissing(lat))       = " + num(ismissing(lat)))
  print("num(.not.ismissing(lat))  = " + num(.not.ismissing(lat)))
  print("num(ismissing(lon))       = " + num(ismissing(lon)))
  print("num(.not.ismissing(lon))  = " + num(.not.ismissing(lon)))
  print("min/max data = " + min(data) + " / " + max(data))
  print("min/max lat  = " + min(lat) + " / " + max(lat))
  print("min/max lon  = " + min(lon) + " / " + max(lon))

;
; Plotting code
;
  wks = gsn_open_wks("png","nic_ims")     ; send graphics to PNG file

;
; Use triangular mesh gridding. It is much faster, but even more important it
; produces a plot that is correct. The standard "curvilinear" and "spherical" 
; methods have trouble with grids defined like this one.
;
  res = True
  res@cnFillOn = True
;  res@cnFillPalette = "default"           ; set color map
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@cnFillMode = "rasterfill"
  res@cnMissingValFillColor = "gray"

;
; Since the data is categorical, values between the categories need to be
; excluded. Use Explicit level selection to accomplish this. 
;

  res@cnLevelSelectionMode = "explicitlevels"
  res@cnLevels = (/ 0.99,1.99, 2.99, 3.99, 4.99 /)
  res@cnFillBackgroundColor = "gray"
  res@cnFillColors = (/"transparent", "blue", "darkgreen", "cyan", "white"/)
  res@lbLabelAlignment = "boxcenters"
  res@lbLabelStrings = (/ "water", "land", "ice", "snow" /)
  res@cnExplicitLabelBarLabelsOn = True
  res@cnLabelBarEndStyle = "excludeouterboxes"
  res@lbAutoManage = False
  res@lbLabelFontHeightF = 0.02
;
; extract the components of the date which is embedded in the file name in yyyyddd format
;
  date = str_split_by_length(tostring(yyyyddd_to_yyyymmdd(tointeger(str_sub_str(filr,"ims","")))),(/4,2,2/))
  res@gsnCenterString = "NIC IMS 24k product  - " + date(0) + "/" + date(1) + "/" + date(2)
  res@gsnCenterStringFontHeightF = 0.03
  res@gsnMaximize = True
;
; First draw the plot without projecting into map coordinates.
; This has the drawback that only index values are used as tick marks 
; but it is fast
;
plot = gsn_csm_contour(wks,data,res)

;
; The plot can also be draw quickly over a map in its the native projection 
; if we can duplicate the map projection in NCL. The following code does that.
; The trick here is that the grid as supplied has a border around it which
; would logically extend into the southern hemisphere. So one approach would
; be to try to set the map limits to a small value (-1 degree) for the minimum
; latitude. But this creates a plot where the map extends further than the data.
; A better approach is to eliminate the border from the data. This can be done
; by discovering how many rows and columns contain only the fill value. By
; the symmetrical appearance of the previous plot we assume that top and bottom
; and left and right have equal numbers of fill valued rows or columns.
;
  do i = 0, nrows - 1
   if (all(data(:,i) .eq. data@_FillValue)) then
       continue
   end if
   break
  end do
  do j = 0, ncols - 1
   if (all(data(j,:) .eq. data@_FillValue)) then
       continue
   end if
   break
  end do

  res@tfDoNDCOverlay = True
  res@cnMissingValFillColor = "white"
  res@mpCenterLonF = -80
  res@mpOutlineBoundarySets = "national"
  res@mpEllipticalBoundary = True
  res@mpPerimDrawOrder = "postdraw"
  res@gsnAddCyclic = False
  res@gsnPolar = "NH"

  plot = gsn_csm_contour_map_polar(wks,data(j:ncols-j-1,i:nrows-i-1),res) 

;
; Try a different projection
;
; Note that for the first 2 plots the coordinate data has not been
; necessary. But using the coordinates it is possible to map into
; other projections. Here is the data using an orthographic projection.
; Wher there are fill values in the coordinate data, the only method
; that works for NCL is to set the trGridType to "TriangularMesh".
; However, it is important that the data values also be set to fill values
; for the corresponding points in the data  grid. That is because 
; the triangular mesh plotting code throws away any triangles containing 
; points that have a missing value for the data, but it
; does not recognize missing values in the coordinates, and will try to project 
; them. Ususally this only causes a slight performance hit, but sometimes the
; projection succeeds in a bizarre manner causing glitches in the plot.
; Try uncommenting the following line to see this effect in action.
;
; delete(data@_FillValue)
;

  delete(res@gsnPolar)
  res@trGridType = "triangularmesh"
  res@tfDoNDCOverlay = False
  res@sfXArray = lon(:,::-1) - 180
  res@sfYArray = lat
  res@mpProjection = "orthographic"
  res@mpGridAndLimbOn = True
  res@mpGridLineDashPattern = 2
  res@mpCenterLatF = 90
  res@mpCenterLonF = -40
  plot = gsn_csm_contour_map(wks,data,res)
end
