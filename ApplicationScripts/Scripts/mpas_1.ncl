;======================================================================
; mpas_1.ncl
;
; Concepts illustrated:
;   - Plotting MPAS data
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
    lonCell = f->lonCell
    latCell = f->latCell

;---Convert to degrees from radians
    RAD2DEG = get_r2d("double")      ; Radian to Degree
    lonCell = lonCell*RAD2DEG
    latCell = latCell*RAD2DEG


;---Start the graphics
    wks = gsn_open_wks("ps","mpas")
    cmap = read_colormap_file("WhiteBlueGreenYellowRed")

    res                      = True              ; Plot mods desired.

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnFillMode           = "RasterFill"      ; turn raster on      
    res@cnFillPalette        = cmap(48:208,:)       ; Don't use white
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels

    res@trGridType           = "TriangularMesh"  ; This is required to allow
                                                 ; missing coordinates.

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = 55
    res@cnMaxLevelValF       = 100
    res@cnLevelSpacingF      = 2.5

    res@mpFillOn             = False

    res@gsnAddCyclic         = False

    res@sfXArray             = lonCell
    res@sfYArray             = latCell
    res@gsnAddCyclic         = False

    res@tiMainString         = "Surface pressure on MPAS grid (" + \
                               dimsizes(sp) + " cells)"

    plot = gsn_csm_contour_map(wks,sp,res)  

end
