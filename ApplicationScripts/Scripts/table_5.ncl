;*************************************************
; table_5.ncl
;
; Concepts illustrated:
;   - Drawing a monthly calendar using gsn_table
;   - Justifying text in a table cell
;   - Filling table cells with a given color
;   - Using "systemfunc" to execute a UNIX command
;   - Using "systemfunc" to get the current date
;   - Creating a color map using named colors
;   - Converting strings to integers
;   - Using command line options to set variables
;
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;---Procedure for drawing a monthly calendar, given a month and a year.
procedure make_monthly_calendar(wks,month,year)
local nrc1, nrc2, ncr3, x1, x2, y1, y2, x3, y3, text1, text2, text3, res
begin
  months = (/"","January", "February", "March", "April", "May", "June", \
             "July", "August", "September", "October", "November", "December"/)

; 
; To create a calendar, we draw three tables, one below the other.
;
; The first table is just the "Month Year" title.
; The second table is the days of the week.
; The third table is the days of the month.

;---First table: the "Month Year" header at the top.
  nrc1  = (/1,1/)                 ; 1 row by 1 col
  x1    = (/0.02,0.98/)
  y1    = (/0.95,0.98/)
  text1 = months(month) + " " + year

;---Second table: Sunday through Saturday
  nrc2  = (/1,7/)                 ; 1 row by 7 cols
  x2    = x1
  y2    = (/0.89,0.95/)
  text2 = (/"SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY", \
            "FRIDAY","SATURDAY"/)

;
; Get the number of days in the given month/year, and create
; a string array to hold the day of the month.
;
  dinm = days_in_month(year,month)
  days = ispan(1,dinm,1)
  diw  = day_of_week(year,month,1)  ; What day of week does the 1st start on?

;
; Third table: days of the month
;
; Are there 5 or 6 weeks in this month?
;
  x3 = x2
  if( (diw+dinm-1).le.34) then
    nrc3        = (/5,7/)                 ; 5 rows by 7 cols
    ybot        = 0.02
    cell_height = (y2(0)-ybot)/6.
    y3          = (/ybot+cell_height,y2(0)/)

    tmp_text3                 = new(35,string)
    tmp_text3(diw:diw+dinm-1) = days + " "
    text3                     = onedtond(tmp_text3,nrc3)
  else
    nrc3                      = (/6,7/)                 ; 6 rows by 7 cols
    y3                        = (/0.02,y2(0)/)
    tmp_text3                 = new(product(nrc3),string)
    tmp_text3(diw:diw+dinm-1) = days + " "
    text3                     = onedtond(tmp_text3,nrc3)
  end if

;---Create a resource list for the tables.
  res               = True

;---First table shouldn't have any grid lines.
  res@txFontHeightF = 0.02
  res@gsLineColor   = "transparent"
  res@txJust        = "TopCenter"

  gsn_table(wks,nrc1,x1,y1,text1,res)    ; Draw table

;---Fill the days of the week boxes in a color
  res@gsLineColor   = "Black"
  res@txFontHeightF = 0.015
  res@gsFillColor   = "tan2" ; "DarkOliveGreen1"
  delete(res@txJust)
  
  gsn_table(wks,nrc2,x2,y2,text2,res)    ; Draw table

;---Days of the month
  res@txJust        = "TopRight"
  res@gsFillColor   = "BlanchedAlmond"
  gsn_table(wks,nrc3,x3,y3,text3,res)    ; Draw table
end

;---Main code
begin
; 
; Allow user to generate calendars in various ways:
;
;   - Calendar for current month and year:
;
;     ncl table_5.ncl
;
;   - Calendar for a particular month:
;
;     ncl month=10 table_5.ncl
;
;   - Calendar for a particular month and year:
;
;     ncl month=9 year=2010 table_5.ncl
;
;   - All calendars for the current year:
;
;     ncl ALL_MONTHS=True table_5.ncl
;
;   - All calendars for a given year:
;  
;     ncl ALL_MONTHS=True year=2011 table_5.ncl
;
  cur_month = tointeger(systemfunc("date +%m"))
  cur_year  = tointeger(systemfunc("date +%Y"))

;---Generate all calendars for a given month?
  if(.not.isvar("ALL_MONTHS")) then
    ALL_MONTHS = False
  end if

;---What year?
  if(.not.isvar("year")) then
    year = cur_year
  end if

  if(.not.ALL_MONTHS) then
;---What month?
    if(.not.isvar("month")) then
      month = cur_month
    else
      if(month.lt.1.or.month.gt.12) then
        print("Invalid month (" + month + ") selected.")
        print("Current month will be used.")      
        month = cur_month
      end if
    end if
  end if

;---Open a workstation (PNG file)
  wks = gsn_open_wks("png","table")

;---Define a color map using named colors
  cmap = (/"white","black","red","green","blue","lightgray", \
           "blanchedalmond","darkolivegreen1","tan2"/)
  gsn_define_colormap(wks,cmap)

  if(.not.ALL_MONTHS) then
    make_monthly_calendar(wks,month,year)
    frame(wks)
  else
;---Draw all calendars for the given year.
    do i=1,12
      make_monthly_calendar(wks,i,year)
      frame(wks)
    end do
  end if
end
