subroutine read_wnd(id,stat,lon,lat,h,wnd_input,yyyy,mm,dd)
    implicit none
	real :: lon(937152),lat(937152),h(937152),wnd(937152)
	real :: wnd_input(349,4748)
	integer yy(937152),mm(937152),dd(937152),yyyy(937152)
	integer i,num,j,sta,ns,nt,n
	character(20) id(937152) ,date,stat(349)
	open(3001,file='/mnt/f/wnd.csv')
	open(3002,file='/mnt/f/wnd_date.csv')
	num=937152
	sta=0
	wnd_input=9999
!========================================================================
!                        read data from csv
!========================================================================
	do i=1,num
		!print*,i
		read(3001,*)id(i),lon(i),lat(i),h(i),wnd(i) !"(A4,F7.3,F6.3,F7.1,F4.1,A10)"
		!write(*,*) id(i),lon(i),lat(i),h(i),wnd(i)
		read(3002,"(A8)") date
		!write(*,"(A8)") date
    	do j=1,len_trim(date)
    		if(index('/-:',date(j:j))>0) date(j:j)=' '
    	end do
    	read(date,*) mm(i),dd(i),yy(i)
    	yyyy(i) = yy(i) +2000
    	!write(*,*) yy(i),mm(i),dd(i)
    end do 
!=========================================================================
!
!========================================================================+
	do i=1,num-1
		if (id(i) /= id(i+1)) then
			sta=sta+1
			stat(sta)=id(i)
		endif
	end do 
	write(*,*) "Number of stations is " ,sta
	n=0
	do ns = 1, sta
		nt=1
		do while (.true.)
			if (stat(ns) /= id(i)) exit
			wnd_input(ns,nt)=wnd(n)
			nt=nt+1
			n=n+1
		end do 
	end do  
	return   
end subroutine read_wnd
program p
	implicit none
	real :: lon(937152),lat(937152),h(937152),wnd(937152)
	real :: wnd_input(349,4748)
	integer yy(937152),mm(937152),dd(937152),yyyy(937152)
	integer i,num,j,sta,ns,nt,n
	character(20) id(937152) ,date,stat(349)
	call  read_wnd(id,stat,lon,lat,h,wnd_input,yyyy,mm,dd)
end program p