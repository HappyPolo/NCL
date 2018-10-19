load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    f   =addfile("/mnt/f/data/For_Fortran/nc/1961_2010_temp_mean.nc", "r")
    t=f->T2
    wks=gsn_open_wks("pdf", "/mnt/f/data/For_Fortran/temp")
gsn_define_colormap(wks, "MPL_jet") 
    
    res=True
    res@mpMinLonF=72
    res@mpMaxLonF=136
    res@mpMinLatF=18
    res@mpMaxLatF=54
    res@gsnAddCyclic=False
    res@cnLinesOn=False
    res@cnFillOn=True
    res@cnLevelSelectionMode="ExplicitLevels"
    res@gsnLeftString="1961-2010 temp mean"
    res@gsnRightString="C"
    ;res@cnLevels =(/-40,-30,-20,-16,-12,-10,-8,-4,-3,-2,-1,0,1,2,3,4,8/)
    res@mpGeophysicalLineColor      ="black"
    res@mpOutlineBoundarySets       ="National"
    res@mpGeophysicalLineDashPattern=0
    res@mpGeophysicalLineDashSegLenF=0.2
    res@mpGeophysicalLineThicknessF =0.5
    res@mpOutlineMaskingOn          =True
    res@mpOutlineOn                 =True


    res@mpAreaMaskingOn             =True
    res@mpMaskAreaSpecifiers        =(/"China","Taiwan"/)

   plot=gsn_csm_contour_map(wks, t, res)
  end