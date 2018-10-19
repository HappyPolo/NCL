;----------------------------------------------------------------------
;  maponly_11.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Drawing three different resolutions for map outlines
;----------------------------------------------------------------------
; Note: in order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
; 
; http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks  = gsn_open_wks("png","maponly")              ; send graphics to PNG file

  res                = True              ; plot mods desired

  res@mpMinLatF      = 34.			 ; select region to be plotted
  res@mpMaxLatF      = 43.		      ; (Greece)
  res@mpMinLonF      = 19.
  res@mpMaxLonF      = 28.
  res@gsnDraw        = False             ; don't draw the plots
  res@gsnFrame       = False             ; don't advance the frame
  res@tmYROn         = False
  res@tmXTOn         = False
  
  yres = True                            ; panel resource list
  yres@gsnMaximize = True                ; maximize the plots
  yres@gsnPanelYWhiteSpacePercent = 5.0  ; increase white space between panels in y-direction
  
  map = new(3,graphic)
  res@mpDataBaseVersion = "LowRes"       ; select the low resolution database
  res@gsnCenterString = "LowRes Database"
  map(0) = gsn_csm_map_ce(wks,res)
  
  res@mpDataBaseVersion = "MediumRes"     ; select the medium resolution database
  res@gsnCenterString = "MediumRes Database"
  map(1) = gsn_csm_map_ce(wks,res)
  
;
; The high-res map database has several different resolutions.
; Use mpDataResolution to control this. It can take
; values of "Coarsest", "Coarse", "Medium", "Fine", and "Finest".
;
; The default is to figure this value dynamically, depending on 
; on the size of the plot, and the range of the map.
;
; Be careful with the values "Fine" and "Finest" as they
; take awhile to draw.
;
; res@mpDataResolution = "Medium".
;
  res@mpDataBaseVersion = "HighRes"       ; select the high resolution database
  res@gsnCenterString = "RANGS (HighRes) Database"
  map(2) = gsn_csm_map_ce(wks,res)
  gsn_panel(wks,map,(/2,2/),yres)
end 
  
