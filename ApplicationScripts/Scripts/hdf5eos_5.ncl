;***************************************************************
; hdf5sds_5.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 files
;   - Simple plotting
;   - Reverse latitude order to fix an issue
;     with the way the original data were written to the file
;***************************************************************
;
;************************************************
; ALWAYS look at file via "ncl_filedump" prior to processing
; http://www.ncl.ucar.edu/Document/Tools/ncl_filedump.shtml
;************************************************
diri = "./"                              ; input directory
fil1  = "OMI-Aura_L3-OMDOAO3e_2005m1214_v003-2008m0222t113750.he5"
fil2  = "OMI-Aura_L3-OMTO3e_2005m1214_v002-2006m0929t143855.he5"

vnam1 = "ColumnAmountO3_ColumnAmountO3"
vnam2 = "ColumnAmountO3_OMI_Column_Amount_O3"

pltType  = "png"                               ; send graphics to PNG file
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
    res@gsnDraw          = False
    res@gsnFrame         = False

    res@mpProjection      = "Mollweide"       ; choose projection
    res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
    res@mpPerimOn         = False             ; turn off box around plot
    res@mpGridLatSpacingF = 30.               ; spacing for lat lines
    res@mpGridLonSpacingF = 30.               ; spacing for lon lines
    res@mpFillOn          = False

    res@cnFillOn         = True
    res@cnFillPalette    = "amwg"             ; set color map
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False
    res@cnFillMode       = "RasterFill"      
   ;res@cnRasterSmoothingOn  = True

   ;res@lbOrientation    = "vertical"
    res@lbLabelBarOn     = False           ; turn off individual cb's


    resP                  = True                   ; modify the panel plot
    resP@gsnMaximize      = True                   ; make ps/eps/pdf large
    resP@gsnPanelLabelBar = True                   ; add common colorbar
    resP@gsnPaperOrientation = "portrait"          ; "landscape"
    resP@lbLabelFontHeightF  = 0.012               ; make labels smaller

    plot = new (2, "graphic")

;****************************************************
; open file
; get dates from file (global attributes)
;****************************************************
    f1 = addfile(diri + fil1, "r")
    f2 = addfile(diri + fil2, "r")

    doy1  = f1@GranuleDayOfYear_ColumnAmountO3
    day1  = f1@GranuleDay_ColumnAmountO3
    month1= f1@GranuleMonth_ColumnAmountO3
    year1 = f1@GranuleYear_ColumnAmountO3

    doy2  = f2@GranuleDayOfYear_OMI_Column_Amount_O3
    day2  = f2@GranuleDay_OMI_Column_Amount_O3
    month2= f2@GranuleMonth_OMI_Column_Amount_O3
    year2 = f2@GranuleYear_OMI_Column_Amount_O3

    if (.not.(year1.eq.year2 .and. doy1.eq.doy2)) then
        print("date mismatch: year1="+year1+" year2="+year2+" doy1="+doy1+" doy2="+doy2)
        exit
    end if
;************************* Read variable "data object"
    x1    = f1->$vnam1$  ; *automatically* associated with each are 
    x2    = f2->$vnam2$  ; the coordinates of the data
;****************************************************

    res@gsnCenterString = month1+"/"+day1+"/"+year1+" (doy="+doy1+")"

    res@tiMainString    = fil1
    plot(0)  = gsn_csm_contour_map(wks, x1, res)

    res@tiMainString    = fil2
    plot(1)  = gsn_csm_contour_map(wks, x2, res)

    resP@txString = "Original Data and Coordinates"
    gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
end
