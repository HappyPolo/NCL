;---------------------------------------------------------------------
; mask_15.ncl
;
; Concepts illustrated:
;   - Masking a data array by setting a rectangular lat/lon area to missing values.
;   - Masking out particular areas in a map
;   - Using functions for cleaner code
;;---------------------------------------------------------------------
;;
;; This script shows how to create two color contour plots in one
;; picture. This is useful when one area of the data is sparse. 
;;
;; This script uses the "overlay" procedure to overlay the two contour
;; plots, where the top plot has a rectangular "hole" in the middle,
;; allowing you to see the filled contours of the base plot.
;;
;; The original script was written by Yang Zhao and Yuhong Wang(CAMS) 
;; (Chinese Academy of Meteorological Sciences)
;;  email: 409360946@qq.com    Thank you! 
;;
;;  Mary Haley made some minor changes to the original script 
;;  modularize the code .
;;---------------------------------------------------------------------

function set_common_resources()
begin
        res                             = True
        res@gsnDraw                     = False  
        res@gsnFrame                    = False
        
        res@tmXTOn                      = False   ;; turn off top and
        res@tmYROn                      = False   ;; right tickmarks
        res@tmBorderThicknessF          = 5.0     ;; defaut is 1.0
        res@tmXBLabelFontHeightF        = 0.012
        res@tmYLLabelFontHeightF        = 0.012

        res@cnFillOn                    = True
        res@cnLinesOn                   = False
        res@cnInfoLabelOn               = False
        res@lbLabelFontHeightF          = 0.01

        return(res)
end

;----------------------------------------------------------------------
; Create filled contours with a rectangular "hole" in the middle,
; using a rainbow color map.
;----------------------------------------------------------------------
function create_mask_plot(wks,u,res)
local res_ovrly, plot
begin
        minlatF = 30      ; Rectangular lat/lon region
        maxlatF = 40      ; to set to missing values.
        minlonF = 105
        maxlonF = 115 
        
        umask = u
        umask@_FillValue  = 99999
        umask({minlatF:maxlatF},{minlonF:maxlonF}) = umask@_FillValue
        
;---The overlay plot is just a contour plot
        res_ovrly                            = res
        res_ovrly@cnFillPalette              = "BlAqGrYeOrReVi200"
        res_ovrly@lbOrientation              = "Vertical"
        res_ovrly@pmLabelBarWidthF           = 0.09
        res_ovrly@pmLabelBarHeightF          = 0.5
        res_ovrly@pmLabelBarOrthogonalPosF   = 0.03
        res_ovrly@gsnRightString             = ""
        res_ovrly@gsnLeftString              = ""

        plot = gsn_csm_contour(wks,umask,res_ovrly)

        return(plot)
end

;----------------------------------------------------------------------
; Create filled contours over a map using a purple/blue color map.
;----------------------------------------------------------------------
function create_base_plot(wks,u,res)
local res_base, plot
begin
;--The base plot is the map plot, so set a bunch of map resources.
        res_base                        = res
        res_base@mpFillOn                    = True 
        res_base@mpOutlineOn                 = False
        res_base@mpDataBaseVersion           = "MediumRes"
        res_base@mpDataSetName               = "Earth..4"
        res_base@mpGeophysicalLineThicknessF = 2
        res_base@mpNationalLineThicknessF    = 2
        res_base@mpOutlineSpecifiers         = (/"China:states","Taiwan"/) 
        res_base@mpFillDrawOrder             = "PostDraw"
        res_base@mpMaskAreaSpecifiers        = (/"China:states","Taiwan"/)
        res_base@mpOceanFillColor            = "background"
        res_base@mpInlandWaterFillColor      = "background"
        
        res_base@mpMinLatF                   = 20 
        res_base@mpMaxLatF                   = 55 
        res_base@mpMinLonF                   = 100 
        res_base@mpMaxLonF                   = 140

        res_base@cnFillPalette               = "MPL_PuBu"
        res_base@pmLabelBarHeightF           = 0.08
        res_base@pmLabelBarWidthF            = 0.5
        res_base@pmLabelBarOrthogonalPosF    = 0.07

        plot = gsn_csm_contour_map(wks,u,res_base)

        return(plot)
end

procedure draw_overlaid_plots(wks,plot_base,plot_ovrly)
begin
        overlay(plot_base,plot_ovrly) ; Overlay the rainbow contours on the blue contours.
        draw(plot_base)               ; This will draw both plots
        frame(wks)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
        dir   = "$NCARG_ROOT/lib/ncarg/data/cdf/"
        fname = "uv300.nc"
        uv    = addfile(dir + fname,"r")
        u     = uv->U(0,:,:)               ;; select first time step

        wks        = gsn_open_wks("png","mask") ; send graphics to PNG file
        res        = set_common_resources()
        plot_ovrly = create_mask_plot(wks,u,res)
        plot_base  = create_base_plot(wks,u,res)
        draw_overlaid_plots(wks,plot_base,plot_ovrly)
end
        
        
        
        
