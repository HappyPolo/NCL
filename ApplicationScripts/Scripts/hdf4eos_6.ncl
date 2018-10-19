;************************************************
; hdf4eos_6.ncl
;
; Concepts illustrated:
;   - Reading AIRS HDF-EOS2 data
;   - Looping over variables and selecting all 2D variables for plotting
;   - Plotting data
;   - Drawing raster images   
;************************************************
; Basic user input 
; Read as hdfeos
; Use "ncl_filedump" to examine file a priori 
; Units *not* on file, must be manually specified
;************************************************
diri = "./"
fili = "AIRS.2008.07.01.L3.RetStd001.v5.2.2.0.G08185123729.hdf"
fili = fili+".hdfeos"    ; append so that file wil be read as hdfeos

vNam     = (/ "TotH2OVap_A_ascending" , "TotH2OVap_MW_A_ascending_MW_only"  \
            , "TotH2OVap_D_descending", "TotH2OVap_MW_D_descending_MW_only" \
            , "OLR_A_ascending"       , "OLR_D_descending"          /)
vUnits   = (/ "kg/m2", "kg/m2","kg/m2", "kg/m2", "W/m2", "W/m2"     /)

pltType  = "png"                              ; send graphics to PNG file
pltName  = "hdf4eos"     

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

    res@gsnDraw          = False              ; do not draw
    res@gsnAddCyclic     = False              ; grids are *not* cyclic
    res@gsnFrame         = False              ; do not advance the frame

    res@cnFillOn         = True
    res@cnFillPalette    = "amwg"             ; set color map
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False
    res@cnFillMode       = "RasterFill"       ; faster
    res@cnLevelSelectionMode = "ManualLevels"
    res@lbLabelBarOn     = False              ; turn off individual cb's
    res@mpCenterLonF     = 180.               ; place Date Line in middle
    res@gsnCenterString  = "GRID NOT CYCLIC"

    resP                  = True              ; modify the panel plot
    resP@txString         = fili
    resP@gsnMaximize      = True              ; make ps/eps/pdf large
    resP@gsnPanelLabelBar = True              ; add common colorbar

    plot = new (2, "graphic")

;****************************************************
; Open file, plot specified variables
; ---
; Use function "nice_mnmxintvl" to establish 
; contour resources for each pair of plots.
;****************************************************
    f = addfile(diri + fili, "r")

    nVar = dimsizes(vNam)                        ; number of variables

    do nv=0,nVar-1,2
       xa  = f->$vNam(nv)$ 
       xb  = f->$vNam(nv+1)$ 

       printVarSummary(xa)
       printMinMax(xa, True)
       printVarSummary(xb)
       printMinMax(xb, True)

       ab_min  = min((/min(xa), min(xb)/))
       ab_max  = max((/max(xa), max(xb)/))
       mnmxint = nice_mnmxintvl(ab_min,ab_max, 16, False)
       res@cnMinLevelValF = mnmxint(0)
       res@cnMaxLevelValF = mnmxint(1)
       res@cnLevelSpacingF= mnmxint(2) 

       res@gsnLeftString  = xa@hdfeos_name
       res@gsnRightString = vUnits(nv)
       plot(0)  = gsn_csm_contour_map(wks, xa, res)

       res@gsnLeftString = xb@hdfeos_name
       res@gsnRightString = vUnits(nv+1)
       plot(1)  = gsn_csm_contour_map(wks, xb, res)

       gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
    end do       ; nv loop
end
