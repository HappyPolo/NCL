;*************************************************
; tdpack_2.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
;  Create the data array for the isosurface.
;
  rbig1 = 6.
  rbig2 = 6.
  rsml1 = 2.
  rsml2 = 2.
  nix = 21
  niy = 31
  niz = 19
  xi = ispan(1,nix,1)*1.
  yi = ispan(1,niy,1)*1.
  zi = ispan(1,niz,1)*1.
  ui = new((/nix,niy,niz/),float)

  jcent1 = niy*.5 - rbig1*.5
  jcent2 = niy*.5 + rbig2*.5
  do i=1,nix
    fimid = i-nix/2.
    do j=1,niy
      fjmid1 = j-jcent1
      fjmid2 = j-jcent2
      do k=1,niz
        fkmid = k-niz/2
        f1 = sqrt(rbig1*rbig1/(fjmid1*fjmid1+fkmid*fkmid+.1))
        f2 = sqrt(rbig2*rbig2/(fimid*fimid+fjmid2*fjmid2+.1))
        fip1 = (1.-f1)*fimid
        fip2 = (1.-f2)*fimid
        fjp1 = (1.-f1)*fjmid1
        fjp2 = (1.-f2)*fjmid2
        fkp1 = (1.-f1)*fkmid
        fkp2 = (1.-f2)*fkmid
        ui(i-1,j-1,k-1) = min((/fimid*fimid+fjp1*fjp1+fkp1*fkp1-rsml1*rsml1, \
                                fkmid*fkmid+fip2*fip2+fjp2*fjp2-rsml2*rsml2/))
      end do
    end do
  end do

;
; Open workstation, draw isosurface, and advance frame.
;
  wks = gsn_open_wks("png","tdpack")  ; send graphics to PNG file

  tdez3d(wks,xi,yi,zi,ui,0.,1.8,-45.,58.,-4)

  frame(wks)
end
