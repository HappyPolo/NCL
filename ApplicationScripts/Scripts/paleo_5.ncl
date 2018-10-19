;************************************
; paleo_5.ncl
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in = addfile("surf1.0000-0009.nc","r")
 taux=in->TAUX(0,:,:)                ; read in data
 tauy=in->TAUY(0,:,:)     
 lat = in->lat                       ; read in lat and lon
 lon = in->lon
;************************************
; test new boundary function
;************************************
  oro=in->ORO(0,:,:)
  paleo_outline(oro,lat,lon,1.,"cretateous")
;***********************************
 wks = gsn_open_wks("ps","paleo")             ; open a ps file
 res                      = True
 res@mpOutlineOn          = True              ; turn off map outline
 res@mpCenterLonF         = 180               ; center map at 180
 res@mpDataBaseVersion    = "MediumRes"       ; change database
 res@mpDataSetName        = "./cretateous"    ; to cretateous

 res@vcRefMagnitudeF      = 0.1               ; mag of reference vector
 res@vcRefLengthF         = 0.050             ; size of reference vector
 res@vcGlyphStyle         = "CurlyVector"     ; turn on curly vectors

 res@tiMainString         = "Paleo Vector Plot"
 res@gsnLeftString        = "Wind Stress"
 plot=gsn_csm_vector_map_ce(wks,taux(::2,::2),tauy(::2,::2),res)
end



