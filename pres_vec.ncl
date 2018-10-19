load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fv=addfile("/mnt/e/software/adaptor.mars.vwnd.nc", "r")
    fw=addfile("/mnt/e/software/adaptor.mars.omega.nc", "r")

    v=short2flt(fv->v(:,:,:,{110}))
    wnd=short2flt(fw->w(:,:,:,{110}))
    w=10000*wnd
    copy_VarCoords(wnd, w)
    wks=gsn_open_wks("pdf", "v-w")
do i=0,0
    resv=True
    resv@cnFillOn                       =True
    resv@cnLinesOn                      =False
    resv@vcMapDirection            =False ;绘制垂直剖面图时设为False
    resv@vcGlyphStyle              ="LineArrow"
    resv@vcRefAnnoOn               =True
    resv@vcRefAnnoBackgroundColor  ="White"

    plot=gsn_csm_pres_hgt_vector(wks, wnd(i,{1000:200},:), v(i,{1000:200},:), w(i,{1000:200},:), resv)
end do
end