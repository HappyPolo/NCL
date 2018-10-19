program p
	implicit none
	integer i,j,k
	real :: lon(128),lat(72),prc(128*72)
	open(12,file="e:\data\For_Fortran\Precip\SURF_CLI_CHN_PRE_MON_GRID_0.5-196101.txt",status="old")
	open(11,file="e:\1.txt")
	k=1
	do i=1,72
		read(12,"(72(f8.1))") (prc(j),j=i+(i-1)*128）
	end do
	do i=1,128
		lon(i)=71.5+i*0.5
	end do
	do i=1,72
		lat(i)=17.5+i*0.5
	end do
	do i=1,72
		do j=1,128
			k=(i-1)*128+j
			write(11,"(3(f8.1))") lat(i),lon(j),prc(k)
		end do
	end do
end 




    
