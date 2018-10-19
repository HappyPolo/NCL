; ==============================================================
; eof_0_640.ncl
;
; Concepts illustrated:
;   - Reading a simple ascii file
;   - Pretty printing
;   - Rearranging data order via named dimension     
;   - Calculating EOFs and Principal Components (ie: time series)
;   - Reconstructing the original array from EOFs and PCs
;   - Calculating 'sum-of-square' to verify normalization
;   - Calculating cross correlations to verify that each is zero.
;     This verifies that they are orthogonal.
; =============================================================
; This script shows how to use the new eofunc_n function added
; in NCL V6.4.0 to avoid having to reorder the data before
; calculating the EOFs.
; =============================================================
; John C Davis
; Statistics and Data Analysis in Geology
; Wiley, 2nd Edition, 1986
; Source Data: page 524 , EOF results: page537
; =============================================================
; No weighting is performed
; =============================================================
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; not needed after 6.0.0

; ================================>  ; PARAMETERS
  ncol   = 7                           ; # columns (stations or grid points)
  nrow   = 25                          ; # time steps   
  neval  = 7                           ; # EOFs to calculate (max=ncol)
  xmsg   = -999.9                      ; missing value (_FillValue)
   
  ntim   = nrow                        ; # time steps   
  nsta   = ncol                        ; # stations ( or grid points)
; ================================>  ; READ THE ASCII FILE
  dir    = "./"
  fname  = "eoftest.davis_data"        ; test data from Davis text book
                                       ; open "data " as 2-dim array
  data   = asciiread (dir+fname,(/ntim,nsta/), "float")
  data!0 = "time"                      ; name the dimensions for subsequent use
  data!1 = "sta"
  data@_FillValue = xmsg

; ================================>   ; PRETTY PRINT INPUT DATA

  opt = True
  opt@tspace = 5 
  opt@title  = "Davis Input Data"
  write_matrix (data, (nsta+"f9.3"), opt)
   
  printVarSummary(data)

  print ("==========> EOFUNC_N <==========")
  evecv    = eofunc_n_Wrap  (data,neval,False,0)
  evecv_ts = eofunc_ts_n_Wrap (data,evecv,False,0) 

  print("")
  printVarSummary(evecv)
  print("")
  printVarSummary(evecv_ts)
  print("")

; ================================>   ; PRETTY PRINT OUTPUT EOF RESULTS

  opt@title  = "Eigenvector components: evecv"
  write_matrix (evecv(sta|:,evn|:), (ncol+"f9.3"), opt) ; reorder to match book
  print("")

  opt@title  = "Eigenvector time series: evecv_ts"
  write_matrix (evecv_ts(time|:,evn|:), (ncol+"f9.3"), opt)
  print(" ")

  print("evecv_ts@ts_mean="+evecv_ts@ts_mean)
  print(" ")

; ================================>   ; SUM OF THE SQUARES
                                      ; IF NORMALIZED, THEY SHOULD BE 1
  sumsqr = dim_sum(evecv^2)
  print("sum of squares:     " + sumsqr)
  print(" ")

; ================================>   ; RECONSTRUCT DATA  
                                      ; NCL WORKS ON ANOMALIES
  do n=0,neval-1                        
     evecv_ts(n,:) = evecv_ts(n,:) + evecv_ts@ts_mean(n)  ; add time series mean
  end do                 

  xRecon = eof2data_n (evecv,evecv_ts,0)  ; RECONSTRUCTED DATA
  copy_VarCoords(data, xRecon)

  printVarSummary(xRecon)
  print(" ")

  opt@title  = "Reconstructed data via NCL: default mode: constant offset"
  write_matrix (xRecon, (nsta+"f9.3"), opt)
  print(" ")

; ================================>   ; MAX ABSOLUTE DIFFERENCE
  
  mxDiff     = max(abs(xRecon-data))
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

