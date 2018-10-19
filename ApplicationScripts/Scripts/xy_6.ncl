; ***********************************************
; xy_6.ncl
;
; Concepts illustrated:
;   - Changing the labels and tickmarks on the X axis in an XY plot
;   - Using "ind" to extract data where a particular condition is True
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; Read in data
;************************************************
  f     = addfile ("Jsst.nc","r")
  date  = f->date                                 ; access date
  sst   = (f->SST)*0.1                            ; scale sst anomalies 
;************************************************
; extract warm years from data
;************************************************
  warm_yrs  = (/1951,1953,1957,1963,1965,1969,1972,1976,1982,1987,1991/)
  warm_date_yrs = warm_yrs * 100 + 01             ; match format of date array
  nwarm     = dimsizes(warm_yrs)                  ; how many warm years
  ind_warm  = new(nwarm,integer)                  ; create array     

  do n=0,nwarm-1                                 
    ind_warm(n)  = ind(warm_date_yrs(n).eq.date)
  end do
  y       = sst(ind_warm)
  x     = ispan(0,nwarm-1,1)                           
;************************************************
; create plot
;************************************************
  wks   = gsn_open_wks ("png","xy")               ; send graphics to PNG file

  res               = True                        ; plot mods desired
  
  res@tmXBMode          = "Explicit"              ; explicit labels
  res@tmXBValues        = x                       ; location of labels 
  res@tmXBLabels        = warm_yrs                ; labels themselves
  res@tmLabelAutoStride = True                    ; nice stride on labels

  res@tiMainString      = "Explicit axis labeling"; title

  plot  = gsn_csm_xy(wks,x,y,res)       
end
