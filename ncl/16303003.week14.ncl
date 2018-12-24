load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f = addfile("/mnt/e/scripts/ncl/ncl/week14/uwnd.mon.mean.week14.nc", "r")
    
    uwnd_in = f->uwnd
    
    t        = cd_calendar(uwnd_in&time,-1)
    t0       = ispan(200001, 200901, 100)
    id       = get1Dindex(t,t0)
    uwnd_out = uwnd_in(id,{250},{15:75},{60:180})
    
    lat      = uwnd_out&lat
    lon      = uwnd_out&lon 
    ; printVarSummary(lat)
    uwnd_avg = dim_avg_n_Wrap(uwnd_out, 0)
;;==============================================================================================
;;===                    plot 
;;==============================================================================================
    wks           = gsn_open_wks("png", "/mnt/e/scripts/ncl/ncl/16303003.week14")
    gsn_define_colormap(wks, "MPL_GnBu")
    
    res           = True
    
    res@cnFillOn  = True
    res@cnLinesOn = False
    
    res@mpMaxLonF = 180
    res@mpMinLonF = 60
    res@mpMaxLatF = 75
    res@mpMinLatF = 15
    ;;==============================================================================================
    ;;===                    Font 
    ;;==============================================================================================
    res@gsnAddCyclic                 = False
    res@gsnLeftString                = "Jan Mean uwnd"
    res@gsnLeftStringOrthogonalPosF  =0.03
    res@gsnRightStringOrthogonalPosF =0.03
    res@gsnMaximize                  = True
    res@tiMainString                 = "Chen Kangtai(16303003)"
    
    res@tmXBLabelFontHeightF         = 0.026
    res@tmYLLabelFontHeightF         = 0.026
    res@pmLabelBarOrthogonalPosF     = 0.2
    res@tiMainFontHeightF            = 0.045
    res@tiMainOffsetYF               =-0.06
    
    ;;==============================================================================================
    ;;===                  
    ;;==============================================================================================
    res@gsnMajorLatSpacing                       =30
    res@gsnMinorLatSpacing                       =5
    res@gsnMajorLonSpacing                       =30
    res@gsnMinorLonSpacing                       =5
    res@pmTickMarkDisplayMode="Always"
    
    res@pmLabelBarWidthF         =0.75 
    res@pmLabelBarHeightF        =0.09 
    
    res@lbLabelOffsetF           =0.1 
    res@lbLabelFontHeightF       =0.026
    res@lbLabelFontColor         ="black"
    res@lbLabelFontThicknessF    =2
    res@lbLabelStride            =2 
    res@pmLabelBarOrthogonalPosF =0.25
    res@lbBoxEndCapStyle         = "TriangleBothEnds"
    
    
    plot                         = gsn_csm_contour_map(wks, uwnd_avg, res)
;;==============================================================================================
;;===                  write to netcdf
;;==============================================================================================
    dir            = "/mnt/e/scripts/ncl/ncl/"
    filename       = "16303003.uwnd.clim.week14.nc"
    system("/bin/rm -f "+dir+filename)
    fout           = addfile(dir+filename, "c")
    
    ; setfileoption(fout,"DefineMode",True)
    
    fAtt           = True 
    fAtt@date      = systemfunc("date +%c")
    fAtt@studentID = "16303003"
    
    fileattdef(fout, fAtt)
    
    dimNames       = (/"lat","lon"/)
    dimSizes       = (/dimsizes(lat),dimsizes(lon)/)
    filedimdef(fout, dimNames, dimSizes, (/False,False/))
    ; printVarSummary(uwnd_avg)
    filevardef(fout, "lat", typeof(lat), getvardims(lat))
    filevardef(fout, "lon", typeof(lon), getvardims(lon))
    filevardef(fout, "uwnd_clim", typeof(uwnd_avg), getvardims(uwnd_avg))
    
    filevarattdef(fout, "lat", lat)
    filevarattdef(fout, "lon", lon)
    filevarattdef(fout, "uwnd_clim", uwnd_avg)
    
    fout ->lat       = (/lat/)
    fout ->lon       = (/lon/)
    fout ->uwnd_clim = (/uwnd_avg/)

    system("ncdump -h "+dir+filename)


end
