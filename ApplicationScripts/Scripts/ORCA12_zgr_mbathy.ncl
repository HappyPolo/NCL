load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "ORCA12-T321.mesh_zgr.nc"
  f        = addfile (filename, "r")
  mb       = f->mbathy
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)

;---Start the graphics
  wks = gsn_open_wks("png" ,"ORCA12_zgr_mbathy")
  gsn_define_colormap(wks,"cmp_haxby")

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot
  res@tiMainString = filename + " (mbathy)"

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Data not global, don't add lon cyclic pt
  res@cnFillOn     = True
  res@cnLinesOn    = False

  res@cnFillMode   = "RasterFill"        ; Developer recommends doing these
  res@trGridType   = "TriangularMesh"    ; two together. 136 seconds versus
                                         ; 1476 seconds!

  plot = gsn_csm_contour_map(wks,mb(0,:,:),res)
end
