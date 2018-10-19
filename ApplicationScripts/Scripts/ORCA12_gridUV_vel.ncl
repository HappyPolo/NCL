load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  ufile = "PSY4V2R1_1dAV_20110531_20110601_gridU_R20110601.nc"
  vfile = "PSY4V2R1_1dAV_20110531_20110601_gridV_R20110601.nc"

  fu    = addfile (ufile, "r")
  fv    = addfile (vfile, "r")

  uvarname = "vozocrtx"
  vvarname = "vomecrty"

  nt    = 0                            ; time index
  nd    = 0                            ; depth index
  step  = 10
  u     = fu->$uvarname$(nt,nd,::step,::step) ; (time_counter,deptht,y,x)
  v     = fv->$vvarname$(nt,nd,::step,::step) ; (1,50,3059,4322)

;---Make sure lat/lon are subscripted in the same fashion as u/v
  u@lat2d = fu->nav_lat(::step,::step)
  u@lon2d = fu->nav_lon(::step,::step)
  v@lat2d = u@lat2d
  v@lon2d = u@lon2d

;---Start the graphics
  wks = gsn_open_wks("png","ORCA12_gridUV_vel")
  gsn_define_colormap(wks,"gui_default")        ; choose colormap

;---Set some resources
  res               = True
  res@gsnMaximize   = True               ; Maximize size of plot

  res@tiMainString  = uvarname + " / " + vvarname
  res@gsnLeftString = "Surface currents"

  res@mpLandFillColor   = "Tan"
  res@mpDataBaseVersion = "MediumRes"

;---Zoom in on map
  res@mpMinLatF =  10
  res@mpMaxLatF =  70
  res@mpMinLonF = -50
  res@mpMaxLonF =  10

  res@vcRefMagnitudeF      = 0.11
  res@vcRefLengthF         = 0.02
  res@vcGlyphStyle         = "CurlyVector"
  res@vcMonoLineArrowColor = False        ; create color vectors
  res@vcLevelSpacingF      = 0.1          ; NCL is picking 0.2

  res@vcRefAnnoOrthogonalPosF  = -0.12    ; Move this up into plot

;---Mostly just for fun
  res@lbOrientation         = "Vertical"    ; default is horizontal
  res@pmTickMarkDisplayMode =  "Always"     ; nicer tickmarks
  res@tiMainOffsetYF        = -0.04         ; move title closer to plot

  plot = gsn_csm_vector_map(wks,u,v,res)
end

