;******************************************************************
; hdf5eos_2.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 ['he5'] data
;   - Looping over variables and selecting 2D variables for panel plot
;   - Checking the variable type on the file prior to reading
;   - Plotting HE5 data
;   - Drawing raster contours

;************************************************
; Basic User input
;************************************************
diri = "./"
fili = "OMI-Aura_L3-OMDOAO3e_2009m0427_v003-2009m0429t150548.he5"

pltType  = "png"                                  ; send graphics to PNG file
pltName  = "hdf5eos"   

         ; The following were obtained from "ncl_filedump"
varPlt   = (/ "CloudFraction_ColumnAmountO3"       \
            , "CloudPressure_ColumnAmountO3"       \
            , "ColumnAmountO3_ColumnAmountO3"      \
            , "EffectiveTemperature_ColumnAmountO3"\
            , "GhostColumnAmountO3_ColumnAmountO3" \
            , "TerrainReflectivity_ColumnAmountO3" /)

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
    wks   = gsn_open_wks (pltType,pltName)        ; open workstation

;****************************************************
; Standard contour with a few simple options
;****************************************************

    res                  = True                   ; plot mods desired
    res@gsnDraw          = False                 ; don't draw
    res@gsnFrame         = False                 ; don't advance frame

    res@cnFillOn         = True
    res@cnFillPalette    = "amwg"                ; set color map
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False
    res@cnFillMode       = "RasterFill"       ; faster
    res@cnRasterSmoothingOn = True

    res@pmLabelBarHeightF= 0.10                   ; slightly smaller than default
    res@pmLabelBarOrthogonalPosF =  0.075
    res@tiXAxisOffsetYF  = 0.15 

    nPlt = dimsizes(varPlt)
    plot = new (nPlt, "graphic")

    resP = True
    resP@gsnMaximize  = True
    resP@txString     = fili

;****************************************************
; Open file; plot user specified variables
;****************************************************
    f = addfile(diri + fili, "r")

    vNam = getfilevarnames(f)                    ; all variables names on the file
   ;print(vNam)
    
    nVar = dimsizes(vNam)

    np = -1
    do nv=0,nVar-1                               ; loop over all variables
       if (any(varPlt.eq.vNam(nv))) then
           vType = getfilevartypes(f,vNam(nv))
                                                 ; 'blind' handle data types
           if (vType.eq."float") then
               x = f->$vNam(nv)$
           else
               if (vType.eq."short") then
                   x = short2flt( f->$vNam(nv)$ )
               else
                   x = byte2flt ( f->$vNam(nv)$ )
               end if
           end if
               
           printVarSummary(x)
           printMinMax(x, True)

           np       = np+1
           plot(np) = gsn_csm_contour_map(wks, x, res)

           delete(x)    ; size may change next oteration
       end if
    end do

    gsn_panel(wks,plot,(/3,2/),resP)         ; now draw as one plot
end
