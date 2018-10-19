undef("histogram_interp")
function histogram_interp(MidBarLocs[*]:numeric, BinLocs[*]:numeric, xHstMarkVals[*]:numeric)
local nMid, nBinLocs, MidBarVals, xHstBinLocs
begin
  nMid        = dimsizes(MidBarLocs)
  nBinLocs    = dimsizes(BinLocs)
  if (nBinLocs.ne.(nMid+1)) then
      print("histogram_interp: size mismatch:  nMid="+nMid+" nBinLocs="+nBinLocs)
      exit
  end if
  MidBarVals  = 0.5*(BinLocs(0:nBinLocs-2)+BinLocs(1:nBinLocs-1))

              ; simple linear interpoaltion
  xHstLocs    = linint1(MidBarVals,MidBarLocs, False,xHstMarkVals , 0)
  xHstLocs@long_name = "NDC coordinates of marker location(s)"

  return (xHstLocs)               
end
;---
               ; USER LEVEL FUNCTION; this could also be histogram_LINE or histogram_TICKMARK
undef("histogram_mark")      
procedure histogram_mark(wks[1]:graphic, hst[1]:graphic, xHstMarkLocs[*]:numeric, yHstMarkLocs[*]:numeric, pmHst[1]:logical)
local xHstLocs, pnred, nMarkX, nMarkY
begin
  nMarkX = dimsizes(xHstMarkLocs)
  nMarkY = dimsizes(yHstMarkLocs)
  if (nMarkX.ne.nMarkY) then
      print("histogram_mark: nMarkX must equal nMarkY:  nMarkX="+nMarkX+" nMarkY="+nMarkY)
      exit
  end if
           ; interpolate along the 'x' NDC coords
  xHstLocs = histogram_interp(hst@MidBarLocs, hst@BinLocs, xHstMarkLocs)

; local default resource settings

  pmres                = True         ;-- local
  pmres@gsClipOn       = False        ;-- allow to extend beyond the view port
  pmres@gsMarkerColor  = "magenta"    ;-- default marker color
  pmres@gsMarkerSizeF  =  0.0125      ;-- default; set size of marker
  pmres@gsMarkerThicknessF = 3.0      ;-- default is 1.0
 ;pmres@gsMarkerIndex  =   8          ;-- down triangle
  pmres@gsMarkerIndex  =   0          ;-- default; asterisk

; allow users to over-ride the local bootstrap
            
  if (pmHst .and. isatt(pmHst,"gsMarkerColor")) then
      pmres@gsMarkerColor  = pmHst@gsMarkerColor
  end if

  if (pmHst .and. isatt(pmHst,"gsMarkerSizeF")) then
      pmres@gsMarkerSizeF  = pmHst@gsMarkerSizeF
  end if

  if (pmHst .and. isatt(pmHst,"gsMarkerIndex")) then
      pmres@gsMarkerIndex  = pmHst@gsMarkerIndex
  end if

  if (pmHst .and. isatt(pmHst,"gsMarkerThicknessF")) then
      pmres@gsMarkerThicknessF  = pmHst@gsMarkerThicknessF
  end if

  if (pmHst .and. isatt(pmHst,"gsClipOn")) then   ; NCL default is True
      pmres@gsClipOn = pmHst@gsClipOn
  end if

;-- Add the marker(s)
  
  do n=0,nMarkX-1
     hst@$unique_string("hstMark_")$ = gsn_add_polymarker(wks, hst, xHstLocs(n), yHstMarkLocs(n) , pmres)  
  end do

;-- No return since this is a procedure

end

