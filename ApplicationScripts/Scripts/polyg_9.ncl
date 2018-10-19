;======================================================================
; polyg_9.ncl
;
; Concepts illustrated:
;   - Drawing the meteorological subdivisions of India using a ASCII file
;   - Reading an ascii (text) file
;   - Using str_xxxx functions to extract desired lat/lon locations
;   - Paneling two plots on a page
;   - Attaching polylines to a map plot
;   - Attaching filled polygons to a map plot
;   - Changing the color and thickness of polylines
;   - Zooming in on India on a cylindrical equidistant map
;   - Drawing the outlines of India using a shapefile
;======================================================================
; The ASCII file for this example can be downloaded from:
;   http://www.monsoondata.org/customize/india_polygons.asc
;======================================================================
; See example polyg_shp_9.ncl for an example that uses shapefiles
; to plot the meteorological subdivisions of India.
;======================================================================
; Important note: we found that the ASCII version of the meteorological
; sub divisions don't match with the India outlines very well. The
; shapefile version of this example produces a better match.
;======================================================================

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
     USE_SHAPEFILE_OUTLINES = True  ; whether to use shapefile outlines for India boundary

     wks  = gsn_open_wks("png","polyg")                   ; send graphics to PNG file
     gsn_define_colormap(wks,"amwg")

     res                             = True
     res@gsnFrame                    = False        ; will draw in panel later
     res@gsnDraw                     = False

     res@mpFillOn                    = False        ; turn off gray fill
     res@mpGeophysicalLineColor      = "Black"      ; color of cont. outlines
     res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines

     if(USE_SHAPEFILE_OUTLINES) then
       res@mpOutlineOn               = False
     else
       res@mpOutlineOn               = True
       res@mpDataBaseVersion         = "MediumRes"        ; higher resolution basemap
       res@mpDataSetName             = "Earth..4"         ; contains divisions for other countries
       res@mpOutlineSpecifiers       = "India:states"
     end if

     res@mpMaxLatF                   = 38           ; choose subregion to plot          
     res@mpMinLatF                   = 6
     res@mpMaxLonF                   = 100
     res@mpMinLonF                   = 65

     res@pmTickMarkDisplayMode       = "Always"     ; better tickmark labels

     plot    = new(2,graphic)
     plot(0) = gsn_csm_map(wks,res)                 ; create blank map for met division outlines
     plot(1) = gsn_csm_map(wks,res)                 ; create blank map for met division filling

     resp                  = True                   ; polyline mods desired
     resp@gsLineColor      = "red"                  ; color of lines
     resp@gsLineThicknessF = 2.0                    ; thickness of lines
;===========================================================================================
;     Read the ascii file containing the lat/lon coordinates for each Meteorological Subdivision (MSD, msd). 
;     Source:  http://www.monsoondata.org/customize/india_polygons.asc
;     
;     Each line corresponds to a different subdivision. The structure of each line is:
;
;     36 draw polyf 88.8499 27.2099 89 27.36 88.9499 27.4099 88.9499 27.51 88.9 27.6599 
;
;     NCL index to each of the above elements
;      0   1   2      3       4      5   6     7       8       9      10    11   12    .....
;
;     where the first number is the division number (36 in above snippet), the second
;     number is the longitude of the first data point (88.8499), the third number is the
;     latitude of the first data point (27.2099), the fourth number is the longitude of 
;     the second data point (89.), and so on...
;
;     Each subdivision has a different number of lat/lon locations.
;     Use NCL's  :=  syntax to overwrite arrays of different sizes.
;===========================================================================================
     msd_file = asciiread("india_polygons.asc", -1, "string")
     msd_num  = dimsizes(msd_file)                             ; number of meteorological subdivisions (msd, MSD))
                                                               ; each line is a separate MSD 

     colorarr = toint(random_uniform(2,14,msd_num))            ; set up some random colors for each MSD

     pgres    = True                                           ; used to fill the MSD for second panel
     dum      = True                                           ; dummy variable to hold graphic ids
                                                                        
     do i = 0,msd_num-1                                        ; loop thru each MSD (ie: each line)      
        nele   = str_fields_count(msd_file(i), " ")            ; number of elements in current line
        ele   := new( nele, "string")                          ; extract each element from current line 
                                                               ; different number of elemens ( := )
        do ne=0,nele-1                                         ; loop & extract each element
           ele(ne) = str_get_field(msd_file(i), (ne+1), " ")
        end do

        msd_id = toint(ele(0))                                 ; extract MSD ID; converion to integer not necessary
        nloc   = nele-3                                        ; # lon+lat elements
        lon   := tofloat(ele(3::2))                            ; := because each MSD is different size
        lat   := tofloat(ele(4::2))                            ; conversion to float is necessary
        npts   = dimsizes(lon)                                 ; # of lat/lon pairs 
      
                                                        ; draw polylines for 1st panel
        dum@$unique_string("msd")$ = gsn_add_polyline(wks,plot(0),lon,lat,resp)

        pgres@gsFillColor = colorarr(i)                 ; draw filled polygons for 2nd panel
        dum@$unique_string("MSD")$ = gsn_add_polygon(wks,plot(1),lon,lat,pgres)
     end do                                                     

;---Download shapefiles from http://www.gadm.org/country
     if(USE_SHAPEFILE_OUTLINES) then
       lnres                  = True
       lnres@gsLineThicknessF = 1.0
       lnres@gsLineColor      = "Black"
       ind_adm1 = gsn_add_shapefile_polylines(wks,plot(0),"IND_adm1.shp",lnres)
       ind_adm2 = gsn_add_shapefile_polylines(wks,plot(1),"IND_adm1.shp",lnres)
     end if

;---Panel both plots
     resP              = True
     resP@gsnMaximize  = True
     if(USE_SHAPEFILE_OUTLINES) then
       resP@txString   = "India meteorological subdivisions from ASCII file; map outlines from shapefile"
     else
       resP@txString   = "India meteorological subdivisions from ASCII file; map outlines from NCL"
     end if
     gsn_panel(wks,plot,(/1,2/),resP)
end                                             

