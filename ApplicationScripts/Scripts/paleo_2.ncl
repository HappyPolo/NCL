;************************************
; CSM_Graphics: paleo_2.ncl
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
; create paleo outline database
;************************************
  oro=in->ORO(0,:,:)
  paleo_outline(oro,lat,lon,1.,"cretateous")
;***********************************
 wks = gsn_open_wks("ps","paleo")   ; open a ncgm file
 res                      = True
 res@mpOutlineOn          = True              ; turn off map outline
 res@mpCenterLonF         = 180
 res@mpDataBaseVersion    = "MediumRes"
 res@mpDataSetName        = "./cretateous"
 plot = gsn_csm_contour_map_ce(wks,T,res)
end



