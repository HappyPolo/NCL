;*************************************************
; polyg_11.ncl
;
; Concepts illustrated:
;   - Drawing the political divisions of Brazil
;   - Changing the color and thickness of polylines
;   - Attaching polylines to a map plot
;   - Zooming in on South America on a cylindrical equidistant map
;   - Turning on map tickmark labels with degree symbols
;   - Reading lat/lon data from an ASCII file

;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

;-------------------------------------------------------------- 
;
; This script was contributed by Mateus da Silva Teixeira.
;
; NCL script that shows how to put political divisions of Brazil 
; The divisions are added with 'gsn_add_polyline' function. 
; This is script is an adaptation of the script 
; 
; http://www.ncl.ucar.edu/Applications/Scripts/polyg_9.ncl 
; 
; The greatest modification is the format of the boundary files. I simply 
; put only the lat/lon coordinates in the files, 
; 
; lat1 lon1 lat2 lon2 lat3 lon3 ... 
; 
; For more than one fields (or panels) you must add more variables to 
; add the polylines. Below, if you plot two panels, you must create a 
; second graphic variable, equal to poli variable, for instance: 
; 
; poli = new(narqs,"graphic") 
; poli2 = poli 
; 
;---------------------------------------------------------- 

begin 
     wks = gsn_open_wks("png","polyg") ; send graphics to PNG file 

     ; attributes of the graphics 
     res = True 
       res@mpDataBaseVersion = "MediumRes"	
       res@mpFillOn = False 
       res@mpOutlineBoundarySets = "National" 
       res@pmTickMarkDisplayMode = "Always" 

       res@mpMaxLatF = 15 ; 
       res@mpMinLatF = -55 ; South America limits 
       res@mpMaxLonF = 330 ; 
       res@mpMinLonF = 270 ; 

       res@gsnFrame = False 
       res@gsnDraw = False 

     plot = gsn_csm_map(wks,res) ; creates a blank map 

     ; attributes of the polylines 
     resp = True 
     resp@gsLineColor      = "blue" ; polylines color 
     resp@gsLineThicknessF = 1.5    ; polylines thickness 

     arquivos = systemfunc("ls *.boundary") ; boundary files list 
     narqs = dimsizes(arquivos) ; total number of files 

     poli = new(narqs,"graphic") ; variable with polylines 

     do i=0,narqs-1 ; loop to read boundary files 
        front = asciiread( arquivos(i), -1, "float" ) 
         
        nptos = dimsizes(front(0::2)) ; number of the lat/lon points 

        latlon = new((/2,nptos/),"float") ; array with lat/lon info 
        latlon(0,:) = (/front(1::2)/) ; latitudes 
        latlon(1,:) = (/front(0::2)/) ; longitudes 

        poli(i) = gsn_add_polyline(wks,plot,latlon(1,:),latlon(0,:),resp) ; adding polyline 

        delete(front) ; 
        delete(nptos) ; ==> deleting variables to 
        delete(latlon) ; 
     end do 

     gsn_panel(wks,plot,(/1,1/),False) ; plotting ... 
end 
