;*****************************************************
; prism_1.ncl
;
; Concepts illustrated:
;   - Reading a flat binary file via cbinread (or, fbindirread)
;   - Using information on the PRISM header file to construct
;     parameters (variables) to read the file.
;
;*****************************************************************
; The following loads need *NOT* be performed from NCL v6.2.0 onward
;****************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;----------------------------------------------------------------------------
; The downloaded file:  PRISM_ppt_early_4kmD1_MTD_20141016_bil.zip 
; contains multiple files. The header file [PRISM_ppt_early_4kmD1_MTD_20141016_bil.hdr]
; contains the following
;
;          BYTEORDER      I 
;          LAYOUT         BIL
;          NROWS          621
;          NCOLS          1405
;          NBANDS         1
;          NBITS          32
;          BANDROWBYTES   5620
;          TOTALROWBYTES  5620
;          PIXELTYPE      FLOAT
;          ULXMAP         -125
;          ULYMAP         49.9166666666687
;          XDIM           0.04166666666667
;          YDIM           0.04166666666667
;          NODATA         -9999
;
;----------------------------------------------------------------------------
; The .BIL extension means 'Band-Interleaved-Format"
; This is a 'flat' binary file containing numeric values as specified by 
; PIXELTYPE (here, FLOAT). The size (number of values) is BxNROWSxNCOLS, 
; where B is the number of bands (here, NBANDS=1), NROWS=621 and NCOLS=1405.
;----------------------------------------------------------------------------
; The functions 'cbinread' or 'fbindirread' work well. The data are little
; endian (BYTEORDER=I),so no byte swapping is needed *if* you are on a 
; little-endian machine. The data is written from north to south, so the 
; Y (latitude) axis needs to be reversed to plot in NCL using the 'tfDoNDCOverlay' 
; resource and the native projection which is basic lat/lon (cylindrical equidistant).
;----------------------------------------------------------------------------

  NBANDS =    1
  NROWS  =  621
  NCOLS  = 1405

  ORDER  = "I"                   ; I => Intel order or little endian format
 
  TYPE   = "float"
  NODATA = -9999.0

  ULXMAP = -125.0d0              ; make map values double (not necessary)
  ULYMAP = 49.9166666666687d0    ; more precise

  XDIM   = 0.04166666666667d0
  YDIM   = 0.04166666666667d0
  
  diri  = "./"
  fili  = "PRISM_ppt_early_4kmD1_MTD_20141016_bil.bil"

  if (ORDER.ne."I") then
      setfileoption("bin","ReadByteOrder","LittleEndian") ; perform byte swapping
  end if

;----------------------------------------------------------------------------
; For illustration: parse the file name
;----------------------------------------------------------------------------

  varName  = str_get_field(fili, 2, "_.")
  yyyymmdd = toint( str_get_field(fili, 6, "_.") )
 ;print(varName+"  "+yyyymmdd)

;----------------------------------------------------------------------------
; Loop over each band and Plot
; NOTE: *all* bands could be read via a single read using: 
;       DAT = fbindirread(diri+fili,0, (/NBANDS,NROWS,NCOLS/), TYPE) 
;----------------------------------------------------------------------------
  pltType = "png"      ; "png", "pdf", "eps", "x11"
  pltDir  = "./"

  res = True
  res@gsnMaximize = True
  res@cnFillOn    = True
  res@cnLinesOn   = False
  res@cnLineLabelsOn = False
  res@cnFillMode  = "Rasterfill"
  
  res@mpMaxLatF   = ULYMAP         
  res@mpMinLatF   = res@mpMaxLatF - (YDIM*NROWS)
  res@mpMinLonF   = ULXMAP
  res@mpMaxLonF   = res@mpMinLonF + (XDIM*NCOLS)
  res@mpLimitMode = "latlon"

  res@tfDoNDCOverlay = True

  do NB=0,NBANDS-1
     dat   = fbindirread(diri+fili,NB, (/NROWS,NCOLS/), TYPE)
     dat@_FillValue = NODATA                                ; manually assign

    ;dat@long_name = varName
    ;dat@units     = "???"

    ;pltName = "prism_band_"+ sprinti("%0.2i", (NB+1))+"."+varName+"_"+date      
     pltName = "prism"      

     pltPath = pltDir+pltName
     wks = gsn_open_wks(pltType, pltPath)
    ;gsn_define_colormap(wks,"BlAqGrYeOrRe")           ; optional, specify a colormap  

     res@tiMainString = fili
     plot = gsn_csm_contour_map(wks,dat(::-1,:),res)   ; ::-1 is syntax to reverse order
  end do
