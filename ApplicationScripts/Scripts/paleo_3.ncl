;************************************
; CSM_Graphics: paleo_3.ncl
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
 wks = gsn_open_wks("ps","paleo")              ; open a ps file
 res                      = True
 res@mpOutlineOn          = False              ; turn off map outline
 res@cnInfoLabelOn        = False              ; turn off contour info label
 res@gsnPolar             = "NH"               ; specify the hemisphere
 res@mpMinLatF            = 40                 ; specify min lat

 res@mpDataBaseVersion    = "MediumRes"
 res@mpDataSetName        = "./cretateous"
 plot = gsn_csm_contour_map_polar(wks,T,res)
end



