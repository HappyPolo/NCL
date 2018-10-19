;******************************************************************
; hdf5eos_1.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 ['he5'] data
;   - Looping over variables and selecting all 2D variables for plotting
;   - Plotting HE5 data
;   - Drawing raster contours

;************************************************
; Basic User input
;************************************************
diri = "./"
fil1 = "OMI-Aura_L3-OMTO3e_2009m0101_v003-2009m0223t121826.he5"

pltType  = "png"                              ; send graphics to PNG file
pltName  = "hdf5eos"     

;************************************************
; Import Libraries
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

;************************************************
;             MAIN
;************************************************
begin

;************************************************
; plotting parameters
;************************************************
    wks   = gsn_open_wks (pltType,pltName)    ; open workstation

;****************************************************
; Standard contour with a few simple options
;****************************************************
    res                  = True               ; plot mods desired
    res@gsnMaximize      = True               ; make ps/eps/pdf large

    res@tiMainString     = fil1

    res@cnFillOn         = True
    res@cnFillPalette    = "amwg"             ; set color map
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False
    res@cnFillMode       = "RasterFill"       ; faster
   ;res@cnRasterSmoothingOn  = True
   ;res@lbLabelStride    = 2

;****************************************************
; open file, plot all 2D variables
;****************************************************
    f = addfile(diri + fil1, "r")

    vNam = getfilevarnames(f)                    ; all variables names on file
    print(vNam)
    

    nVar = dimsizes(vNam)                        ; number of variables

    do nv=0,nVar-1
       rank = dimsizes( getfilevardims(f, vNam(nv) ))
       if (rank.eq.2) then

           x  = f->$vNam(nv)$ 
           printVarSummary(x)
           printMinMax(x, True)

           plot  = gsn_csm_contour_map(wks, x, res)

           delete(x)      ; size may change on next iteration
       end if
    end do       ; nv loop
end
