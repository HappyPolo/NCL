;*************************************************
; table_2.ncl
;
; Concepts illustrated:
;   - Drawing a table with headers using gsn_table
;   - Filling table cells with a given color
;   - Specifying the NDC position of individual tables
;
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
; Header
  ncr1  = (/1,1/)               ; 1 row, 1 column
  x1    = (/0.005,0.335/)       ; Start and end X
  y1    = (/0.900,0.995/)       ; Start and end Y
  text1 = "CAM METRICS"

; Sub header
  ncr2  = (/2,2/)               ; 2 rows, 2 columns
  x2    = (/0.335,0.995/)       ; Start and end X
  y2    = (/0.900,0.995/)       ; Start and end Y
  text2 = (/ (/"Case A","Case B"/),(/"ANN","ANN"/)/)

; Main table body
  ncr3  = (/16,3/)              ; 16 rows, 3 columns
  x3    = (/0.005,0.995/)       ; Start and end X
  y3    = (/0.005,0.900/)       ; Start and end Y

  text3 = (/ (/"SLP_ERA40",        "1.230", "1.129"/), \
             (/"Tsfc_ERA40",       "0.988", "0.996"/), \
             (/"Prc_GPCP",         "1.092", "1.016"/), \
             (/"Prc 30S-30N_GPCP", "1.172", "1.134"/), \
             (/"LW_ERS",           "1.064", "1.023"/), \
             (/"SW_ERS",           "0.966", "0.962"/), \
             (/"U300_ERA40",       "1.079", "1.048"/), \
             (/"Guess_BOGUS",      "0.781", "0.852"/), \
             (/"RH_NCEP",          "1.122", "0.911"/), \
             (/"LHFLX_ERA40",      "1.000", "0.835"/), \
             (/"TWP_ERA40",        "0.998", "0.712"/), \
             (/"CLDTOT_NCEP",      "1.321", "1.122"/), \
             (/"O3_NASA",          "0.842", "0.956"/), \
             (/"Q_JMA",            "0.978", "0.832"/), \
             (/"PBLH_JMA",         "0.998", "0.900"/), \
             (/"Omega_CAS",        "0.811", "1.311"/)/)


  wks = gsn_open_wks("png","table")  ; send graphics to PNG file

;
; Main header.
;
  res1               = True
  res1@txFontHeightF = 0.03
  res1@gsFillColor   = "CornFlowerBlue"

  gsn_table(wks,ncr1,x1,y1,text1,res1)

;
; Sub header
;
  res2               = True
  res2@txFontHeightF = 0.02
  res2@gsFillColor   = "Gray"

  gsn_table(wks,ncr2,x2,y2,text2,res2)

;
; Main body of table.
;
  res3 = True             ; Set up resource list

;  res3@gsnDebug = True     ; Useful to print NDC row,col values used.

  res3@txFontHeightF = 0.02

  res3@gsFillColor = (/ (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","hotpink"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","hotpink"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","hotpink"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","palegreen"/), \
                       (/"gray","transparent","hotpink"/)/)

  gsn_table(wks,ncr3,x3,y3,text3,res3)

  frame(wks)      ; Advance the frame.

end


