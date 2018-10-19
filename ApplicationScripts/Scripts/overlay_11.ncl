;----------------------------------------------------------------------
; overlay_11.ncl
;
; Concepts illustrated:
;   - Overlaying vectors and filled contours on a map
;   - Masking out particular areas in a map
;   - Subsetting a color map
;----------------------------------------------------------------------
; This script shows how to overlay contours and vectors on a map,
; but with the contours limited to specific areas, and the 
; vectors not limited.
;
; The point of this script is to show how to mask contours against a
;geographical boundary, but in a way that allows them to be drawn up to
; the boundary location. This is unlike the shapefile masking examples,
;where grid points are set to missing if they fall outside a boundary,
; and hence you can get blocky features close to the boundary.
;
; The uvt.nc data file can be downloaded from:
;
; http://www.ncl.ucar.edu/Applications/Data/
;
;; This script was written by Yang Zhao (CAMS) 
;; (Chinese Academy of Meteorological Sciences) 
;;  email: 409360946@qq.com    Thanks you!
;;----------------------------------------------------------------------
;;Main Code;;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;;read u,v,t from the data at 500hPa 
        f = addfile("./uvt.nc","r")
        level = f->lev
        u = f->U(0,{500},:,:)
        v = f->V(0,{500},:,:)
        t = f->T(0,{500},:,:)
;;create plots;;
        wks = gsn_open_wks("png","overlay") ; send graphics to PNG file
;       gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
        res                = True
        res@gsnDraw        = False
        res@gsnFrame       = False 
        res@gsnMaximize    = True 
        res@tmXTOn         = False
        res@tmYROn         = False
        res@gsnLeftString  = ""
        res@gsnRightString = ""
        
;;set map;;
        mpres                             = res
        mpres@mpDataSetName               = "Earth..4"
        mpres@mpDataBaseVersion           = "MediumRes"
        mpres@mpOutlineOn                 = True
        mpres@mpOutlineSpecifiers         = (/"China:states","Taiwan"/)
        mpres@mpGeophysicalLineThicknessF = 2
        mpres@mpNationalLineThicknessF    = 2
        mpres@mpFillDrawOrder             = "PostDraw"
        mpres@mpFillOn                    = True
        mpres@mpFillAreaSpecifiers        = (/"water",       "land" /)
        mpres@mpSpecifiedFillColors       = (/"deepskyblue2","white"/)
;       mpres@mpSpecifiedFillColors      = (/100,0/)
        mpres@mpMaskAreaSpecifiers        = (/"China:states","Taiwan"/)

;;set area;;
        mpres@mpMinLatF                   = 15
        mpres@mpMaxLatF                   = 55 
        mpres@mpMinLonF                   = 100
        mpres@mpMaxLonF                   = 145

;;set contour;;
        cnres                             = res
        cnres@cnFillDrawOrder             = "PreDraw"
        cnres@cnFillOn                    = True
        cnres@cnLinesOn                   = False
        cnres@pmLabelBarWidthF            = 0.4
        cnres@pmLabelBarHeightF           = 0.05
        cnres@pmLabelBarOrthogonalPosF    = 0.1
        cnres@lbLabelFontHeightF          = 0.006 
        cnres@lbLabelAngleF               = 45
; Older way to subset a color map
;       cnres@cnFillPalette               = "BkBlAqGrYeOrReViWh200"
;       cnres@gsnSpreadColorStart         = 50
;       cnres@gsnSpreadColorEnd           = 120

; Newer way to subset a color map
        cmap = read_colormap_file("BkBlAqGrYeOrReViWh200")
        cnres@cnFillPalette               = cmap(25:120,:)
 
        cnres@gsnLeftString               = "Temp"
        
;;set vector;;
        res_vc                            = res
        res_vc@vcGlyphStyle               = "LineArrow"
        res_vc@vcLineArrowThicknessF      = 5
        res_vc@vcMinDistanceF             = 0.01
        res_vc@vcRefLengthF               = 0.03

;;wind barb resources don't apply
;;      res_vc@vcGlyphStyle               = "WindBarb"
;;      res_vc@vcWindBarbLineThicknessF   = 5
;;      res_vc@vcWindBarbColor            = "Gray40"

        res_vc@vcRefAnnoOn               = True
        res_vc@vcRefMagnitudeF           = 30 
        res_vc@vcRefAnnoString1          = "30"
        res_vc@vcRefAnnoSide             = "Top"
        res_vc@vcRefAnnoString2On        = False
        res_vc@vcRefAnnoPerimOn          = False
        res_vc@vcRefAnnoOrthogonalPosF   = -0.12
        res_vc@vcRefAnnoParallelPosF     = 0.999
        res_vc@vcRefAnnoBackgroundColor  = "Purple"
        res_vc@vcVectorDrawOrder         = "PostDraw"
        res_vc@gsnRightString            = "Wind"
        
;;plot;;
        map     = gsn_csm_map(wks,mpres)
        contour = gsn_csm_contour(wks,t,cnres)
        vector  = gsn_csm_vector(wks,u,v,res_vc)

;;overlay filled contours and vectors on the map;;
        overlay(map,contour)
        overlay(map,vector)

;;add text;;
        txres                       = True
        txres@txFontHeightF         = 0.02
        txres@txFontColor           = "Purple"
        txres@txBackgroundFillColor = "White"
        txres@txFontOpacityF        = 0.8
        txres@txFontThicknessF      = 4.0
        dum = gsn_add_text(wks,(/vector/),"500hPa",105,52.7,txres)

;;drawing "map" will draw everything: map, contours, vectors, and text;;
        draw(map)
        frame(wks)
end

        
        
         
