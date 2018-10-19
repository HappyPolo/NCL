;======================================================================
; mpas_3.ncl
;
; Concepts illustrated:
;   - Drawing raster contours on a 2,621,442 cell MPAS grid
;   - Setting 254 contour levels so we can use the full color map 
;   - Labeling only the ends of a labelbar
;======================================================================
; This code takes about 66 CPU seconds on a Mac using NCL V6.1.2.
; It takes about 12 seconds using NCL V6.2.0.
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    code_start = get_cpu_time() 

;---Open MPAS file
    mpas_file = "x1.2621442.output.2010-10-23_00.00.00.nc"
    mfile     = addfile(mpas_file,"r")

;---Read a timestep of "t2m" 
    nt      = 3                   ; nt=0 is a constant field for t2m
    varname = "t2m"
    t2m     = mfile->$varname$(nt,:)

;---Read lat/lon and convert to degrees
    lonCell   = mfile->lonCell
    latCell   = mfile->latCell
    r2d       = get_r2d("double")
    lonCell   = lonCell*r2d
    latCell   = latCell*r2d

    read_end  = get_cpu_time() 
    print("===> Reading data elapsed time = " + (read_end-code_start))

;---Debug prints
    nCells = dimsizes(latCell)
    print("===> This MPAS file has " + nCells + " cells.")

    printMinMax(t2m,0)
    printMinMax(latCell,0)
    printMinMax(lonCell,0)
;
; Use "nice" values for the begin/end so we can get "nice"
; labels on the labelbar.
;
    min_level = ceil(min(t2m))
    max_level = floor(max(t2m))
    nlevels   = 253
    levels    = fspan(min_level,max_level,nlevels)

;---Labels for labelbar. Do just the end labels.
    labels            = new(nlevels,string)
    labels            = ""
    labels(0)         = "" + min_level
    labels(nlevels-1) = "" + max_level

;---Start the graphics
    graphics_start = get_cpu_time()

;---Open PS image to write graphics to.
    wks = gsn_open_wks("ps","mpas")

;---Settings for graphics options
    res                     = True              ; Plot modes desired.

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; turn on contour fill
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
;
; It is necessary to use RasterFill here.
; The default AreaFill is too slow and will
; run out of memory easily.
;
    res@cnFillMode           = "RasterFill"    ; can be faster than "AreaFill"
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = levels

    res@lbLabelStrings       = labels
    res@lbBoxLinesOn         = False       ; turn off labelbar boxes
    res@lbLabelAutoStride    = False       ; make sure we see end labels
    res@lbLabelStride        = 1
    res@pmLabelBarWidthF     = 0.8         ; default is too short

    res@sfXArray            = lonCell      ; where to overlay contours
    res@sfYArray            = latCell
    res@gsnAddCyclic        = False        ; don't add lon cyclic pt

    res@mpFillOn            = False

;---Various titles
    res@tiMainString        = mpas_file
    res@tiMainOffsetYF      = -0.03      ; Move main title towards plot
    res@gsnLeftString       = varname
    res@gsnCenterString     = str_strip(tostring(mfile->xtime(nt,:)))
    res@gsnRightString      = nCells + " cells"

    res@pmTickMarkDisplayMode = "Always"   ; Nicer tickmark labels

    plot = gsn_csm_contour_map(wks,t2m,res)

;---Print CPU timings
    graphics_end = get_cpu_time()
    print("===> graphics elapsed time  = " + (graphics_end-graphics_start))
    print("===> full code elapsed time = " + (graphics_end-code_start))
end
