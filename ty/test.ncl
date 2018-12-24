load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    dir = "/home/yangsong3/data-observation/ERA-interim/pressure/"
    year = ispan(1979, 2008, 1)


    t = new((30,15,37,121,240), double)
    u = new((30,15,37,121,240), double)
    v = new((30,15,37,121,240), double)
    q = new((30,15,37,121,240), double)
    h = new((30,15,37,121,240), double)

    do i = 0,29
        ft := addfile(dir+"air/air.interim."+year(i)+".nc", "r")
        fu := addfile(dir+"u/u.interim."+year(i)+".nc", "r")
        fv := addfile(dir+"v/v.interim."+year(i)+".nc", "r")
        fq := addfile(dir+"shum/shum.interim."+year(i)+".nc", "r")
        fh := addfile(dir+"hgt/hgt.interim."+year(i)+".nc", "r")

        ui = short2flt(fu->u)
        vi = short2flt(fv->v)
        ti = short2flt(ft->t)
        qi = short2flt(fq->q)
        hi = short2flt(fh->z)

        time = cd_calendar(ui&time,-5)

        id = ind(time(2).le.15.and.time(1).and.3)

        t(i,:,:,:,:) = ti(id,:,:,:)
        u(i,:,:,:,:) = ui(id,:,:,:)
        v(i,:,:,:,:) = vi(id,:,:,:)
        h(i,:,:,:,:) = hi(id,:,:,:)
        q(i,:,:,:,:) = qi(id,:,:,:)
    end do 

    day = ispan(1, 15, 1)
    level = ui&level
    lat = ti&latitude
    lon = ti&longitude
    t!0 = "year"
    t!1 = "day"
    t!2 = "level"
    t!3 = "lat"
    t!4 = "lon"
    t&year = year
    t&day = day
    t&level = level
    t&lat = lat
    t&lon = lon
copy_VarCoords(t, u)
copy_VarCoords(t, v)
copy_VarCoords(t, q)
copy_VarCoords(t, h)
    
    f1 = addfile("/home/ys-ug/data/era-interim/air_79_08.nc", "c")
    f2 = addfile("/home/ys-ug/data/era-interim/u_79_08.nc", "c")
    f3 = addfile("/home/ys-ug/data/era-interim/v_79_08.nc", "c")
    f4 = addfile("/home/ys-ug/data/era-interim/h_79_08.nc", "c")
    f5 = addfile("/home/ys-ug/data/era-interim/q_79_08.nc", "c")

    f1->air = t
    f2->u = u
    f3->v = v
    f4->z = h
    f5->q = q











    ; time = cd_calendar(t&time, -3)
    ; print(time)
    td = new(12, vartype, parameter)

end