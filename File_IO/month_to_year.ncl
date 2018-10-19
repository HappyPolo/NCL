load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f1=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.jan.cfsv2.data.nc", "r")
    f2=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.feb.cfsv2.data.nc", "r")
    f3=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.mar.cfsv2.data.nc", "r")
    f4=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.apr.cfsv2.data.nc", "r")
    f5=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.may.cfsv2.data.nc", "r")
    f6=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.jun.cfsv2.data.nc", "r")
    f7=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.jul.cfsv2.data.nc", "r")
    f8=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.aug.cfsv2.data.nc", "r")
    f9=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.sep.cfsv2.data.nc", "r")
    f10=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.oct.cfsv2.data.nc", "r")
    f11=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.nov.cfsv2.data.nc", "r")
    f12=addfile("/mnt/f/data/cfsv2_output/t200/tmp200.ensm.dec.cfsv2.data.nc", "r")
    f0=addfile("/mnt/f/data/cfsv2_output/t2m/t2m.em24.out.nc", "r")

    f=addfile("/mnt/f/data/cfsv2_output/t200/t200.ensm.out.nc", "c")
    t2m        =f0->t2m
    tm         =g2fsh(t2m, (/181,360/))
    printVarSummary(tm)
    tmp        =new((/336,10,181,360/), typeof(t2m), getFillValue(t2m))
    tmp!0      ="time"
    tmp!1      ="lead"
    tmp!2      ="lat"
    tmp!3      ="lon"
    lat        =fspan(90, -90, 181)
    lon        =fspan(0, 359, 360)
    lat@units  ="degrees_north"
    lon@units  ="degrees_east"
    lead       =fspan(0, 9, 10)
    lead@units ="month"
    time       =t2m&time
    tmp&time   =time
    tmp&lead   =lead
    tmp&lat    =lat
    tmp&lon    =lon
    
    
    printVarSummary(tmp)
    
    t1         =f1->TMP_P8_L100_GLL0_avg1m
    t2         =f2->TMP_P8_L100_GLL0_avg1m
    t3         =f3->TMP_P8_L100_GLL0_avg1m
    t4         =f4->TMP_P8_L100_GLL0_avg1m
    t5         =f5->TMP_P8_L100_GLL0_avg1m
    t6         =f6->TMP_P8_L100_GLL0_avg1m
    t7         =f7->TMP_P8_L100_GLL0_avg1m
    t8         =f8->TMP_P8_L100_GLL0_avg1m
    t9         =f9->TMP_P8_L100_GLL0_avg1m
    t10        =f10->TMP_P8_L100_GLL0_avg1m
    t11        =f11->TMP_P8_L100_GLL0_avg1m
    t12        =f12->TMP_P8_L100_GLL0_avg1m
    t=new((/12,28,10,181,360/), typeof(t2m))
    month=fspan(0, 11, 12)
    month@units="month"
    year=fspan(0, 27, 28)
    year@units="year"
    t!0="month"
    t!1="initial_time0_hours"
    t!2="forecast_time0"
    t!3="lat_0"
    t!4="lon_0"
    t&month=month
    t&initial_time0_hours=t1&initial_time0_hours
    t&forecast_time0=t1&forecast_time0
    t&lat_0=t1&lat_0
    t&lon_0=t1&lon_0
    t(0,:,:,:,:)=t1
    t(1,:,:,:,:)=t2
    t(2,:,:,:,:)=t3
    t(3,:,:,:,:)=t4
    t(4,:,:,:,:)=t5
    t(5,:,:,:,:)=t6
    t(6,:,:,:,:)=t7
    t(7,:,:,:,:)=t8
    t(8,:,:,:,:)=t9
    t(9,:,:,:,:)=t10
    t(10,:,:,:,:)=t11
    t(11,:,:,:,:)=t12
    printVarSummary(tmp)
    printVarSummary(t(0,0,0,0,0))
    tmp(0,0,0,0)=t(0,0,0,0,0)
    do l=0,9
       do y=0,27
            do m=0,11
                do i=0,181
                    do j=0,360
                        t=y*12+m
                        tmp(t,l,i,j)=t(m,y,l,i,j)
                    end do
                end do 
            end do 
        end do
    end do
    f->tmp =tmp

end