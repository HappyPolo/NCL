;----------------------------------------------------------------------
; logo_4.ncl
;
; Concepts illustrated:
;   - Using ImageMagick's "composite" tool to attach a logo to a plot
;   - Using "system" to execute a UNIX command
;   - Changing the size of a PNG image
;----------------------------------------------------------------------
; You need to install ImageMagick in order to run this example.
;
; First, you can type:
;
;   which composite
; 
; to see if you already have this command. If you don't, then google
; "ImageMagick". It's a free software package that is relatively 
; easy to install.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in data
 f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
 u     = f->U                                    ; get u data
 
 wtype          = "png"
 wtype@wkWidth  = 700     ; Set the pixel size of PNG image.
 wtype@wkHeight = 700  
 wks   = gsn_open_wks (wtype,"logo")                ; open workstation

;
; Set plot parameters. Note that we are not setting gsnMaximize
; to True, because we purposely want to leave some room around the
; plot for a logo to be added.
;
 res                  = True                     ; plot mods desired
 res@tiMainString     = "Attaching a logo to lower right of plot"

 plot  = gsn_csm_xy (wks,u&lat,u(0,:,{82}),res) ; create plot

;---Properly close the PNG file before adding logo to it.
  delete(wks)

;
; Use ImageMagick's "composite" tool to attach a logo image
; ("ncar-logo.jpg") to the plot we just created ("logo.png").
;
; The "-geometry" option allows you to specify the size of the logo
; (100x100) and the location on the plot to place it (590+620).
;
; The PNG image size was set to 700x700 above, so a location of 
; 590+620 puts the logo in the lower right corner of the plot.
;
  cmd = "composite -geometry 100x100+590+620 NCAR_logo.jpg logo.png logo.png"
  system(cmd)
end
