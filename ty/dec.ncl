load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fq1 = addfile("~/data/era-interim/q_79_08.nc_1", "r")
    fq2 = addfile("~/data/era-interim/q_79_08.nc_2", "r")
    ; fu = addfile("~/data/era-interim/u_79_08.nc", "r")
    ; fv = addfile("~/data/era-interim/v_79_08.nc", "r")
    ; ft = addfile("~/data/era-interim/air_79_08.nc", "r")
    ; fh = addfile("~/data/era-interim/h_79_08.nc", "r")

    q01 = fq1->q
    q02 = fq2->q
    ; u = fu->u
    ; v= fv->v 
    ; t = ft->t
    ; h = fh->h
    q = new((/30,15,37,121,240/), double)
    q(0:14,:,:,:,:) = q01
    q(15:29,:,:,:,:) = q02

    year = ispan(1979, 2008, 1)
    day = ispan(1, 15, 1)
    lat = q01&lat 
    lon = q01&lon
    lev = q01&level
    q!0 = "year"
    q!1 = "day"
    q!2 = "level"
    q!3 = "lat"
    q!4 = "lon"

    q&year = year
    q&day = day
    q&lev = lev
    q&lat = lat
    q&lon = lon



    q1 = conform(q, (dim_avg_n_Wrap(q, (/0,3/))), (/1,2/))
    q2 = conform(q, (dim_avg_n_Wrap(q, 0), (/1,2,3/)))-q1
    q3 = conform(q, (dim_avg_n_Wrap(q, 3), (/0,1,2/)))-q1
    q4 = q-q1-q2-q3

    ; u1 = conform(u, (dim_avg_n_Wrap(u, (/0,3/))), (/1,2/))
    ; u2 = conform(u, (dim_avg_n_Wrap(u, 0), (/1,2,3/)))-u1
    ; u3 = conform(u, (dim_avg_n_Wrap(u, 3), (/0,1,2/)))-u1
    ; u4 = u-u1-u2-u3
    ; v1 = conform(v, (dim_avg_n_Wrap(v, (/0,3/))), (/1,2/))
    ; v2 = conform(v, (dim_avg_n_Wrap(v, 0), (/1,2,3/)))-v1
    ; v3 = conform(v, (dim_avg_n_Wrap(v, 3), (/0,1,2/)))-v1
    ; v4 = v-v1-v2-v3
    ; h1 = conform(h, (dim_ahg_n_Wrap(h, (/0,3/))), (/1,2/))
    ; h2 = conform(h, (dim_ahg_n_Wrap(h, 0), (/1,2,3/)))-h1
    ; h3 = conform(h, (dim_ahg_n_Wrap(h, 3), (/0,1,2/)))-h1
    ; h4 = h-h1-h2-h3
    ; t1 = conform(t, (dim_atg_n_Wrap(t, (/0,3/))), (/1,2/))
    ; t2 = conform(t, (dim_atg_n_Wrap(t, 0), (/1,2,3/)))-t1
    ; t3 = conform(t, (dim_atg_n_Wrap(t, 3), (/0,1,2/)))-t1
    ; t4 = t-t1-t2-t3
    system("rm "+"/home/ys-ug/data/era-interim/"+"air_dec_79_08_1.nc")
    system("rm "+"/home/ys-ug/data/era-interim/"+"air_dec_79_08_2.nc")
    f11 = addfile("/home/ys-ug/data/era-interim/air_dec_79_08_1.nc", "c")
    f12 = addfile("/home/ys-ug/data/era-interim/air_dec_79_08_2.nc", "c")
    ; f2 = addfile("/home/ys-ug/data/era-interim/u_79_08.nc", "c")
    ; f3 = addfile("/home/ys-ug/data/era-interim/v_79_08.nc", "c")
    ; f4 = addfile("/home/ys-ug/data/era-interim/h_79_08.nc", "c")
    ; f5 = addfile("/home/ys-ug/data/era-interim/q_79_08.nc", "c")

    f11->q = q4(0:14,:,:,:,:)
    ; f11->year = year
    ; f11->day = day
    ; f11->lat = lat
    ; f11->lon = lon
    f12->q = q4(15:29,:,:,:,:)
    ; f12->year = year
    ; f12->day = day
    ; f12->lat = lat
    ; f12->lon = lon  


end