;================================================
;  topo_1.ncl
;================================================
; Concepts illustrated:
;   - Drawing a topographic map using 5' data
;   - Drawing topographic data using the default color map
;   - Using "RasterFill" for faster contouring
;   - Reading binary data using "cbinread"
;   - Changing the byte order when reading binary data
;   - Adding 1D coordinate arrays to a variable
;----------------------------------------------------------------------
; This script draws the full 5' (now deprecated according to the
; website) topo grid downloaded from:
;
;  http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO5/TOPO/ETOPO5/
;
; Other topo files can be found at: http://www.ngdc.noaa.gov/mgg/topo/
;
; This TOPO file is a binary file. See below for details.
;----------------------------------------------------------------------
; The data file is formatted as 16-bit BINARY INTEGERS in two byte 
; order; the file ETOPO5.DAT is in "normal," or hi-byte-first 
; order, as used by Macintosh, Sun, and some other workstations. 
; There are 2160x4320 data values, one for each five minutes of latitude
; and longitude, for a total of 9,331,200 points or 18,662,400 bytes. 
; Data values are in whole meters, representing the elevation of the 
; CENTER of each cell.
; 
; Data Order in the Files:
; 
; The file may be thought of as having a logical record size of 
; 8640 bytes.  The data start at the North Pole (90 deg N, 0 deg 0' 
; E) and are arranged in bands of 360 degrees x 12 points/degree = 
; 4320 values (8640 bytes) ranging eastward from 0 deg 0' East 
; longitude to 359 deg 55' East longitude (since it represents the 
; North Pole, all possible longitudes still refer to a single 
; point, thus the first band has 4320 identical values of -4290 m). 
; The 8641st starts the latitude band for 89 deg 55' N, and so on. 
; There is NO record for the South Pole (elevation 2810 m.) 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function reads a binary file containing elevation data and
; generates the necessary lat/lon coordinate arrays for plotting later.
; The information on the binary file is provided at the beginning of
; this script.
;
; The binary file was downloaded from:
;     http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO5/TOPO/ETOPO5/
;----------------------------------------------------------------------
undef("read_elev_data")
function read_elev_data(topo_file)
local nlat, nlon, topo_file, lat, lon
begin
;---Read data as a straight binary file
  nlat = 2160
  nlon = 4320
  setfileoption("bin","ReadByteOrder","BigEndian")
  elev = cbinread(topo_file,(/nlat,nlon/),"short")

;---Create 1D coordinate arrays
  lat       = fspan(90,-90,nlat)
  lon       = fspan(0,360,nlon)
  lat!0     = "lat"
  lon!0     = "lon"
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  lat&lat   = lat
  lon&lon   = lon

;---Attach the coordinate arrays
  elev!0    = "lat"
  elev!1    = "lon"
  elev&lat  = lat
  elev&lon  = lon
 
  return(elev)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks = gsn_open_wks("png","topo")          ; send graphics to PNG file
  elev = read_elev_data("ETOPO5.DAT")

;---Set some plot options
  res                    = True
  res@gsnMaximize        = True             ; maximize plot in frame
  res@cnFillOn           = True             ; turn on contour fill
  res@cnLevelSpacingF    = 125              ; NCL picks 2000
  res@cnFillMode         = "RasterFill"     ; much faster than AreaFill
  res@cnLinesOn          = False            ; turn off contour lines
  res@cnLineLabelsOn     = False            ; turn off line labels
  res@cnInfoLabelOn      = False            ; turn off info label
  res@lbBoxLinesOn       = False            ; turn off labelbar box lines
  res@gsnAddCyclic       = False            ; don't add longitude cyclic point
  res@mpFillOn           = False            ; turn off map fill
  res@tiMainString       = "ETOPO5.DAT"     ; main title
  res@pmLabelBarWidthF   = 0.8              ; default is too short

  plot = gsn_csm_contour_map(wks,elev,res)
end
