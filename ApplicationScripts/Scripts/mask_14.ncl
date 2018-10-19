;---------------------------------------------------------------------
; mask_14.ncl
;
; Concepts illustrated:
;   - Masking a data array based on topographic data read from a binary file
;   - Regridding data using local area averaging
;   - Adding shading or color fill to areas on a contour plot with missing data
;;---------------------------------------------------------------------
;; This script is used for vertical section with terrain.
;; The functions "conform" and "mask" are used to mask the data
;; based on terrain.
;;
;; A "high-pressure" formula is used to convert "m" to "hPa".
;;
;; This script uses terrain data  (ETOPO5.DAT) and from a NOAA website:
;; http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO5/TOPO/ETOPO5/ETOPO5.DAT
;;
;; The temp data came from a GRIB file from an NCEP website.
;;
;; This script was written by Yang Zhao (CAMS) 
;; (Chinese Academy of Meteorological Sciences) 
;;  email: 409360946@qq.com   10/01/2015 Thank you!
;;---------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;;---------------------------------------------------------------------
;; This function reads topographic data off a binary file as "short"
;; and converts it to float.  It also attaches lat/lon coordinate
;; variables.
;;---------------------------------------------------------------------
	undef("read_height_data")
	function read_height_data(topo_file)
	local nlat,nlon,topo_file,lat,lon
begin
	nlat = 2160
	nlon = 4320
	setfileoption("bin","ReadByteOrder","BigEndian")
	elev = tofloat(cbinread(topo_file,(/nlat,nlon/),"short"))
	
	lat = fspan(90,-90,nlat)
	lon = fspan(0,360,nlon)
	lat!0 = "lat"
	lon!0 = "lon"
        lat@units = "degrees_north"
	lon@units = "degrees_east"
	lat&lat = lat
	lon&lon = lon

        elev!0 = "lat"
	elev!1 = "lon"
	elev&lat = lat
	elev&lon = lon
	
	return(elev)
end

;;---------------------------------------------------------------------
;; Main code
;;---------------------------------------------------------------------

begin
	stdlat = 28  ;section angle 
        levt   = 100
        levb   = 1000

;; Read data
        fname   = "grib2004060212.grb"
        f       = addfile(fname,"r")
	temp    = f->TMP_3_ISBL({levt:levb},{stdlat},:)

;; Read terrain data from a C binary file
	elev = read_height_data("ETOPO5.DAT")

;; Convert terrain data from units "m" to "hPa", it is described as a high pressure formula
	elev = 1013.25*(1-elev*0.0065/288.15)^5.25145

;; The purpose of the interpolation is to make terrain data and variable data have the same resolution    
	lat  = fspan(90,-90,181)
	lon  = fspan(0,359,360)
	geog = area_hi2lores_Wrap(elev&lon,elev&lat,elev,True,1,lon,lat,False) 

	geogsection = geog({stdlat},:)

;; Determine the terrain
	topo2d = conform(temp,geogsection,1)
	high2d = conform(temp,temp&lv_ISBL3,0)
	tMask  = temp
	tMask@_FillValue = 99999
	tMask = (/mask(temp,topo2d.lt.high2d,False)/)

;; Draw map
	wks = gsn_open_wks("png","mask")      ; send graphics to PNG file
 
	res                          = True
        res@gsnMaximize              = True

	res@tmBorderThicknessF       = 6.0    ; border 6x as thick
	res@tmXTOn                   = False  ; Turn off top and right
	res@tmYROn                   = False  ; tickmarks

	res@trXMinF                  = 60     ; Set min/max of X axis
	res@trXMaxF                  = 135
	res@trYReverse               = True   ; Reverse Y axis
	
	res@cnFillOn                 = True
	res@cnLinesOn                = False
	res@cnInfoLabelOn            = False
	res@cnMissingValFillColor    = "gray30" ; set color for missing areas

	res@tiYAxisString            = ""    ; turn off Y axis string
	res@gsnLeftString            = "Temperature"
	res@gsnLeftStringFontHeightF = 0.015
	res@gsnRightString           = "K"

	res@pmLabelBarWidthF         = 0.6     ; Change size of labelbar
	res@pmLabelBarHeightF        = 0.05
	res@pmLabelBarOrthogonalPosF = 0.05
	res@lbLabelFontHeightF       = 0.010
		
	plot = gsn_csm_contour(wks,tMask,res)
end
