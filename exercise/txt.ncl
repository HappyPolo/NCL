;读取txt数据
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    f=addfile("/mnt/e/data/NCEP/tmax.1979.nc", "r")
    tmax=f->tmax(:,{33:48},{73:105})
    nlat=31
    nlon=65
    ntime=600
    lat10=fspan(250., 400, 31)
    olat10=fspan(250., 400, 32)
    ;print(lat10)
    lon10=fspan(730., 1050., 65)
    olon10=fspan(730., 1055., 66)
    ;print(lon10)
    mlat=lat10/10
    mlon=lon10/10
    olat=olat10/10
    olon=olon10/10
    print(mlat)
    j=0
    t=new(600, integer)
    do yyyy=1961,2010,1
        do mm=01,12,1
            t(j)=yyyy*100+mm
            j=j+1
        end do
    end do
    ;print(t)
    prc=asciiread("/mnt/e/data/For_Fortran/precip_tp.txt", (/ntime,nlat,nlon/), "float")
    ;mlat=asciiread("/mnt/e/lat.txt", (/31/), "float")
    ;mlon=asciiread("/mnt/e/lon.txt", (/65/), "float")
    prc@_FillValue= -9999.0
    prc!0="time"
    prc!1="lat"
    prc!2="lon"

     ;olon!0          = "lon"
     ;olon@long_name  = "lon"
     ;olon@units      = "degrees-east"
     ;olon&lon        = olon

    


    prc&time=t
    prc&lat=mlat
    prc&lon=mlon
    prc&lat@long_name="Latitude"
    prc&lon@long_name="Longitude"
    prc&lat@coordinate_defines="point"
    prc&lon@coordinate_defines="point"
    prc&lat@actual_range=(/33,48/)
    prc&lon@actual_range=(/77,105/)
    prc&lat@units="degrees_north"
    prc&lon@axis="X"
    prc&lon@units="degrees_east"
    prc&lat@axis="Y"

    prc@units="mm/day"

    print(prc&lat(0))
    ;final=obj_anal_ic_deprecated(olon, olat, z, lon, lat, rscan, option)
    ;print(prc(1,0:1,:))
    ;print(max(prc))
    ;print(min(prc))
    ;print(prc&lon)
    prc_avg=dim_avg_n_Wrap(prc, 0)
    ;prc_a_lat=dim_avg_n_Wrap(prc, 2)
    ;prc_a_lon=dim_avg_n_Wrap(prc_a_lat, 1)
    t_avg=dim_avg_n_Wrap(tmax, 0)
    ;copy_VarCoords(t, prc_avg)
    wks=gsn_open_wks("pdf", "/mnt/e/ff")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")
    res =True
    res@cnFillOn   =True
    res@cnLinesOn  =False
    ;res@mpMaxLonF  =105
    ;res@mpMinLonF  =0
    ;res@mpMaxLatF  =48
    ;res@mpMinLatF  =3
    ;res@gsnMaximize=True

    
    res@sfXArray   =olon
    res@sfYArray   =olat
    ;res@trXLog     =True
    ;res@trXMinF    =70
    ;res@trXMaxF    =110
    ;res@tiXAxisString=True
    ;res@tiXAxisString="lon"
    ;res@trYLog     =True
    ;res@trYMaxF    =50
    ;res@trYMinF    =0
    plot=gsn_csm_contour_map(wks, prc_avg(:,:), res)
    ;plot1=gsn_csm_xy(wks, prc&time, prc_a_lon, res)
end

    
