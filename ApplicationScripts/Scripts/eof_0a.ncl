; ==============================================================
; eof_0a.ncl
;
; Concepts illustrated:
;   - Reading a simple ascii file
;   - Pretty printing
;   - Rearranging data order via named dimension     
;   - Weighting the data
;   - Calculating EOFs and Principal Components (ie: time series)
;   - Reconstructing the original array from EOFs and PCsby unweighting
;   - Calculating 'sum-of-square' to verify normalization
;   - Calculating cross correlations to verify that each is zero.
;     This verifies that they are orthogonal.
; =============================================================
; John C Davis
; Statistics and Data Analysis in Geology
; Wiley, 2nd Edition, 1986
; Source Data: page 524 , EOF results: page537
; =============================================================
; Cosine  weighting is performed
; =============================================================
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; not needed after 6.0.0

; ================================>  ; PARAMETERS
  ncol   = 7                           ; # columns (stations or grid points)
  nrow   = 25                          ; # time steps   
  neval  = 7                           ; # EOFs to calculate (max=ncol)
  xmsg   = -999.9                      ; missing value (_FillValue)
   
  ntim   = nrow                        ; # time steps   
  nlat   = ncol                        ; # latitudes  
; ================================>  ; READ THE ASCII FILE
  dir    = "./"
  fname  = "eoftest.davis_data"        ; test data from Davis text book
                                       ; open "data " as 2-dim array
  data   = asciiread (dir+fname,(/ntim,nlat/), "float")
  data!0 = "time"                      ; name the dimensions for subsequent use
  data!1 = "lat"
  data@_FillValue = xmsg

; ================================>   ; CREATE BOGUS LATITUDES & COSINE WEIGHTING
  lat    = ispan(-60, 60, 20)*1.0   
  lat!0  = "lat"
  lat@units = "degrees_north"
  data&lat  =  lat
  printVarSummary(lat)
  
  clat   = sqrt(cos(lat*0.01745329))  ; [*]; cosine weighting    

; ================================>   ; PRETTY PRINT INPUT DATA

  opt = True
  opt@tspace = 5 
  opt@title  = "Davis Input Data"
  write_matrix (data, (nlat+"f9.3"), opt)
   
; ================================>   ; REORDER TO WHAT EOFUNC EXPECTS
   
  x        = data(lat | :,time | :)   ; reorder ... eofunc want 'time' as rightmost dimension
  printVarSummary(x)
  print("")

  CLAT     = conform(x, clat, 0)      ; create explicit array (not needed; done for illustration)
  printVarSummary(CLAT)
  print("")
   
; ================================>   ; REORDER TO WHAT EOFUNC EXPECTS

  xw       = x*CLAT                   ; weight the observations; xw -> weighted
  copy_VarCoords(x, xw)
  printVarSummary(xw)
  print("")
   
; ================================>   ; EOFs on weighted observationsS

  evecv    = eofunc_Wrap    (xw,neval,False)
  evecv_ts = eofunc_ts_Wrap (xw,evecv,False) 

  print("")
  printVarSummary(evecv)
  print("")
  printVarSummary(evecv_ts)
  print("")

; ================================>   ; PRETTY PRINT OUTPUT EOF RESULTS

  opt@title  = "Eigenvector components from weighted values: evecv"
  write_matrix (evecv(lat|:,evn|:), (nlat+"f9.3"), opt) ; reorder to match book
  print("")

  opt@title  = "Eigenvector time series from weighted values: evecv_ts"
  write_matrix (evecv_ts(time|:,evn|:), (nlat+"f9.3"), opt)
  print(" ")

  print("evecv_ts@ts_mean="+evecv_ts@ts_mean)
  print(" ")

; ================================>   ; SUM OF THE SQUARES
                                      ; IF NORMALIZED, THEY SHOULD BE 1
  sumsqr = dim_sum(evecv^2)
  print("sum of squares: " + sumsqr)
  print(" ")

; ================================>   ; RECONSTRUCT DATA: 
                                      ; NCL WORKS ON ANOMALIES
  do n=0,neval-1                        
     evecv_ts(n,:) = evecv_ts(n,:) + evecv_ts@ts_mean(n)  ; add weighted means    
  end do                 

  xRecon = eof2data (evecv,evecv_ts)  ; RECONSTRUCTED WEIGHTED DATA
  copy_VarCoords(x, xRecon)

  xRecon = xRecon/CLAT

  printVarSummary(xRecon)
  print(" ")

  opt@title  = "Reconstructed data via NCL: default mode: constant offset"
  write_matrix (xRecon(time|:,lat|:), (nlat+"f9.3"), opt)
  print(" ")

; ================================>   ; MAX ABSOLUTE DIFFERENCE
  
  mxDiff     = max(abs(xRecon-x))
  print("mxDiff="+mxDiff)
  print(" ")

; ================================>   ; ORTHOGONALITY: DOT PRODUCT
                                      ; 0=>orthogonal
  do ne=0,neval-1
     EVECV = conform(evecv, evecv(ne,:), 1 )

     print("=====> dotp for col "+ne+"  <=====")
    do nn = 0, neval - 1
     dotp = dim_sum(evecv*EVECV)
     print("dotp patterns: " + dotp)
     print(" ")
    end do
  end do

; ================================>   ; CORRELATION 
                                                  
  do ne = 0, neval - 1
     corr = escorc(evecv_ts(ne,:),evecv_ts)
     print("corr patterns: " + corr)
     print(" ")
  end do

