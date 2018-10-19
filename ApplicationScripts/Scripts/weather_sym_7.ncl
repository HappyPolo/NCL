;**********************************************
; weather_sym_7.ncl
;
; Concepts illustrated:
;   - Drawing arrows
;   - Setting parameters for weather routines

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
; 
;  Examples of drawing arrows with different styles.
;  Draws eight arrows pointing in.
;  

;
;  Specify x/y coordinates for the eight arrow tips.
;
  d2r = 0.0174532925
  xcoord = new(8,float)
  ycoord = new(8,float)
  dpnt = 0.075
  do i=0,7
    xcoord(i) = 0.5+dpnt*cos(d2r*45.*i)
    ycoord(i) = 0.55+dpnt*sin(d2r*45.*i)
  end do

;
;  Color map.
;
  cmap = (/                         \  
            (/ 1.0, 1.0, 1.0 /),    \  ; color index 0 - white
            (/ 0.0, 0.0, 0.0 /),    \  ; color index 1 - black
            (/ 1.0, 0.0, 0.0 /),    \  ; color index 2 - red 
            (/ 0.0, 0.0, 1.0 /),    \  ; color index 3 - blue
            (/ 0.0, 1.0, 0.0 /),    \  ; color index 4 - green
            (/ 0.9, 0.9, 0.9 /),    \  ; color index 5 - gray
            (/ 1.0, 1.0, 1.0 /)     \
         /)
  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

;
;  Title.
;
  res = True
  res@txFontHeightF = 0.05
  gsn_text_ndc(wks,"~F26~Arrows",0.5,0.90,res)

;
;  Eight arrows pointing in.
;
  wmsetp("ARD - arrow direction",180.)      ; default size
  wmlabs(wks,xcoord(0),ycoord(0),"Arrow")
   
  size = 0.3         ;  applies to all subsequent arrows.
  wmsetp("ARS - arrow size",size)
  wmsetp("AWC - color index for interior of arrow",4)
  wmsetp("ARD - arrow direction",225.)
  wmsetp("AOC - color index for arrow outline",3)
  wmsetp("ARL - scale factor for length of arrow tail",0.5)
  wmlabs(wks, xcoord(1),ycoord(1),"Arrow")

  wmsetp("ARD - arrow direction",270.)
  wmsetp("ARL - scale factor for length of arrow tail",0.6)
  wmsetp("AWC - color index for interior of arrow",0)
  wmsetp("AOC - color index for arrow outline",3)
  wmlabs(wks, xcoord(2),ycoord(2),"Arrow")
 
  wmsetp("ARD - arrow direction",315.)
  wmsetp("AWC - color index for interior of arrow",2)
  wmlabs(wks, xcoord(3),ycoord(3),"Arrow")

  wmsetp("ARD - arrow direction",0.)
  wmsetp("AWC - color index for interior of arrow",5)
  wmsetp("AOC - color index for arrow outline",2)
  wmsetp("ASC - color index for arrow shadow",3)
  wmlabs(wks, xcoord(4),ycoord(4),"Arrow")
 
  wmsetp("ASC - turn off arrow shadow",-1)
  wmsetp("AOC - turn off arrow outline",-1)
  wmsetp("AWC - color index for interior of arrow",1)
  wmsetp("ARD - arrow direction",45.)
  wmsetp("ARL - scale factor for length of arrow tail",0.33)
  wmlabs(wks, xcoord(5),ycoord(5),"Arrow")

  wmsetp("AWC - color index for interior of arrow",1)
  wmsetp("ARD - arrow direction",90.)
  wmsetp("ARL - scale factor for length of arrow tail",1.4)
  wmlabs(wks, xcoord(6),ycoord(6),"Arrow")

  wmsetp("ARD - arrow direction",135.)
  wmsetp("ARL - scale factor for length of arrow tail",1.)
  wmsetp("AWC - color index for interior of arrow",2)
  wmlabs(wks,xcoord(7),ycoord(7),"Arrow")

  frame(wks)
end
