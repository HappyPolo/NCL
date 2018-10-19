;======================================================================
; mpas_1.ncl
;
; This script is identical to mpas_1.ncl, except it uses the special 
; lat1d/lon1d attributes added in V6.4.0 for contouring.
;======================================================================
; Concepts illustrated:
;   - Plotting MPAS data
;   - Using special lat1d / lon1d attributes
;   - Plotting unstructured data
;   - Plotting data with missing lat/lon coordinates
;   - Using cnFillPalette to assign a color palette to contours
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Read data from MPAS Grid
    f  = addfile("MPAS.nc","r")
    sp = f->surface_pressure(0,:)
    sp = sp/1000.   ; Not sure what the pressure units are, there's
                    ; not much metadata info on this file

;---Convert to degrees from radians
    RAD2DEG = get_r2d("double")      ; Radian to Degree
    sp@lon1d = f->lonCell*RAD2DEG
    sp@lat1d = f->latCell*RAD2DEG


;---Start the graphics
    wks = gsn_open_wks("png","mpas")
    cmap = read_colormap_file("WhiteBlueGreenYellowRed")

    res                      = True              ; Plot mods desired.

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnFillMode           = "RasterFill"      ; turn raster on      
    res@cnFillPalette        = cmap(48:208,:)       ; Don't use white
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = 55
    res@cnMaxLevelValF       = 100
    res@cnLevelSpacingF      = 2.5

    res@mpFillOn             = False

    res@gsnAddCyclic         = False      ; don't try to add longitude cyclic point

    res@tiMainString         = "Surface pressure on MPAS grid (" + \
                               dimsizes(sp) + " cells)"

    plot = gsn_csm_contour_map(wks,sp,res)  

end
