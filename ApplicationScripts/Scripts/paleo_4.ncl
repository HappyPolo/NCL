;************************************
; CSM_Graphics: paleo_4.ncl
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in = addfile("surf1.0000-0009.nc","r")
 T=in->TS(0,:,:)                     ; read in data
 lat = in->lat                       ; read in lat and lon
 lon = in->lon
;************************************
; test new boundary function
;************************************
  oro=in->ORO(0,:,:)
  paleo_outline(oro,lat,lon,1.,"cretateous")
;***********************************
 wks = gsn_open_wks("ps","paleo")          ; open a ncgm file
 gsn_define_colormap(wks,"BlAqGrYeOrReVi200")    ; choose colormap 

 res                             = True     ; plot mods desired
 res@cnFillOn                    = True     ; turn on color
 res@cnLinesOn                   = False    ; no contour lines
 res@cnLevelSpacingF             = 4        ; contour spacing

 res@gsnSpreadColors             = True     ; use full colormap
 res@gsnSpreadColorStart         = 10       ; start at color 10
 res@gsnSpreadColorEnd           = 192      ; end at color 96

 res@mpFillOn                    = False    ; turn off map fill
 res@mpGeophysicalLineThicknessF = 2.0      ; make outlines thicker

 res@gsnZonalMean                = True     ; turn on zonal average side plot

 res@lbLabelAutoStride           = True     ; automatically skip labels as nec.

 res@mpDataBaseVersion           = "MediumRes"    ; choose new outline database
 res@mpDataSetName               = "./cretateous" ; data base we just created

 plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
end



