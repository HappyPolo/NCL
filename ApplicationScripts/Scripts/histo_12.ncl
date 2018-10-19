;*************************************************
; histo_12.ncl
;
; Concepts illustrated:
;   - Drawing histograms of World Series wins and losses
;   - Labeling the top of histogram bars with a text string
;   - Turning off the top and left tickmarks in a histogram
;   - Customizing the Y axis tickmarks
;   - Comparing two sets of histograms
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   

;************************************************    
; Plot number of times baseball teams have won or lost
; the World Series. The point of this example is to show
; how to place text above the bars, using information returned
; from the gsn_histogram routine.
;
begin
;
; Define long and short name of baseball teams, along with their 
; colors in RGB percentages. Note that some of these teams became
; other teams, but the original and the new names are both included.
;
  teams = (/ \
            (/"Anaheim Angels",           "AA",  "73",  "0", "13"/), \
            (/"Arizona Diamondbacks",     "AD",  "39", "21", "63"/), \
            (/"Atlanta Braves",           "AB",  "69",  "1", "22"/), \
            (/"Baltimore Orioles",        "BO",  "82", "35",  "4"/), \
            (/"Boston Braves",            "BB",  "66", "13", "24"/), \
            (/"Boston Red Sox",           "BRS", "73", "19", "24"/), \
            (/"Brooklyn Dodgers",         "BD",   "5", "18", "52"/), \
            (/"Brooklyn Robins",          "BR",   "3", "16", "52"/), \
            (/"Chicago Cubs",             "CC",   "6", "20", "53"/), \
            (/"Chicago White Sox",        "CWS",  "0",  "0",  "0"/), \
            (/"Cincinnati Reds",          "CRe", "78",  "0", "12"/), \
            (/"Cleveland Indians",        "CI",   "1", "20", "40"/), \
            (/"Colorado Rockies",         "CRo", "20", "20", "40"/), \
            (/"Detroit Tigers",           "DT",  "92", "49", "22"/), \
            (/"Florida Marlins",          "FM",  "14", "62", "64"/), \
            (/"Houston Astros",           "HA",  "58", "20", "17"/), \  
            (/"Kansas City Royals",       "KCR",  "0",  "2", "45"/), \
            (/"Los Angeles Dodgers",      "LAD",  "3", "24", "42"/), \
            (/"Milwaukee Braves",         "MBa", "93",  "9", "12"/), \
            (/"Milwaukee Brewers",        "MBe",  "4", "13", "32"/), \
            (/"Minnesota Twins",          "MT",  "74",  "0", "20"/), \
            (/"New York Giants",          "NYG",  "2",  "6", "26"/), \
            (/"New York Mets",            "NYM",  "1", "17", "40"/), \
            (/"New York Yankees",         "NYY", "11", "16", "26"/), \
            (/"Oakland Athletics",        "OA",   "0", "22", "19"/), \
            (/"Philadelphia Athletics",   "PA",   "7",  "0", "55"/), \
            (/"Philadelphia Phillies",    "PPh", "91",  "9", "16"/), \
            (/"Pittsburgh Pirates",       "PPi", "46", "38", "13"/), \
            (/"San Diego Padres",         "SDP",  "2",  "8", "25"/), \
            (/"San Francisco Giants",     "SFG","100", "35", "12"/), \
            (/"Seattle Mariners",         "SM",   "5", "17", "34"/), \
            (/"St. Louis Browns",         "SLB", "81", "32", "14"/), \
            (/"St. Louis Cardinals",      "SLC", "77", "12", "23"/), \
            (/"Tampa Bay Rays",           "TBR",  "0", "43", "24"/), \
            (/"Texas Rangers",            "TR",   "0", "20", "48"/), \
            (/"Toronto Blue Jays",        "TBJ",  "0", "20", "60"/), \
            (/"Washington Senators",      "WS",   "0",  "4", "25"/), \
            (/"Washington Nationals",     "WN",   "7", "13", "36"/)  \
          /)
;
; Special notes: 
;
;  - No world series in 1904 (boycotted by New York Giants) 
;    or 1994 (strike).
;
;  - Boston Red Sox first won their first WS as the Boston Americans.
;    I didn't include a separate entry for the Americans because the
;    bars were getting too thin.
;
;  - Brooklyn Robins became the Brooklyn Dodgers became the LA Dodgers.
;
;  - Boston Braves became the Milwaukee Braves became the Atlanta Braves.
;
;  - St. Louis Browns became the Baltimore Orioles.
;
;  - Washington Senators became the Minnesota Twins.
;
;  - New York Giants became the San Francisco Giants.
;
;  - Philadelphia Athletics became the Oakland Athletics.

;---List each world series results as year, winning team, losing team.
  world_series = (/ \
                   (/"1903", "BRS", "PPi"/) ,\
                   (/"1904", "missing", "missing"/), \
                   (/"1905", "NYG", "PA"/),  \
                   (/"1906", "CWS", "CC"/),  \
                   (/"1907", "CC",  "DT"/),  \
                   (/"1908", "CC",  "DT"/),  \
                   (/"1909", "PPi", "DT"/),  \
                   (/"1910", "PA",  "CC"/),  \
                   (/"1911", "PA",  "NYG"/), \
                   (/"1912", "BRS", "NYG"/), \
                   (/"1913", "PA",  "NYG"/), \
                   (/"1914", "BB",  "PA"/),  \
                   (/"1915", "BRS", "PPh"/), \
                   (/"1916", "BRS", "BR"/),  \
                   (/"1917", "CWS", "NYG"/), \
                   (/"1918", "BRS", "CC"/),  \
                   (/"1919", "CRe", "CWS"/), \
                   (/"1920", "CI",  "BR"/),  \
                   (/"1921", "NYG", "NYY"/), \
                   (/"1922", "NYG", "NYY"/), \
                   (/"1923", "NYY", "NYG"/), \
                   (/"1924", "WS",  "NYG"/), \
                   (/"1925", "PPi", "WS"/),  \
                   (/"1926", "SLC", "NYY"/), \
                   (/"1927", "NYY", "PPi"/), \
                   (/"1928", "NYY", "SLC"/), \
                   (/"1929", "PA",  "CC"/),  \
                   (/"1930", "PA",  "SLC"/), \
                   (/"1931", "SLC", "PA"/),  \
                   (/"1932", "NYY", "CC"/),  \
                   (/"1933", "NYG", "WS"/),  \
                   (/"1934", "SLC", "DT"/),  \
                   (/"1935", "DT",  "CC"/),  \
                   (/"1936", "NYY", "NYG"/), \
                   (/"1937", "NYY", "NYG"/), \
                   (/"1938", "NYY", "CC"/),  \
                   (/"1939", "NYY", "CRe"/), \
                   (/"1940", "CRe", "DT"/),  \
                   (/"1941", "NYY", "BD"/),  \
                   (/"1942", "SLC", "NYY"/), \
                   (/"1943", "NYY", "SLC"/), \
                   (/"1944", "SLC", "SLB"/), \
                   (/"1945", "DT",  "CC"/),  \
                   (/"1946", "SLC", "BRS"/), \
                   (/"1947", "NYY", "BD"/),  \
                   (/"1948", "CI",  "BB"/),  \
                   (/"1949", "NYY", "BD"/),  \
                   (/"1950", "NYY", "PPh"/), \
                   (/"1951", "NYY", "NYG"/), \
                   (/"1952", "NYY", "BD"/),  \
                   (/"1953", "NYY", "BD"/),  \
                   (/"1954", "NYG", "CI"/),  \
                   (/"1955", "BD",  "NYY"/), \
                   (/"1956", "NYY", "BD"/),  \
                   (/"1957", "MBa", "NYY"/), \
                   (/"1958", "NYY", "MBa"/), \
                   (/"1959", "LAD", "CWS"/), \
                   (/"1960", "PPi", "NYY"/), \
                   (/"1961", "NYY", "CRe"/), \
                   (/"1962", "NYY", "SFG"/), \
                   (/"1963", "LAD", "NYY"/), \
                   (/"1964", "SLC", "NYY"/), \
                   (/"1965", "LAD", "MT"/),  \
                   (/"1966", "BO",  "LAD"/), \
                   (/"1967", "SLC", "BRS"/), \
                   (/"1968", "DT",  "SLC"/), \
                   (/"1969", "NYM", "BO"/),  \
                   (/"1970", "BO",  "CRe"/), \
                   (/"1971", "PPi", "BO"/),  \
                   (/"1972", "OA",  "CRe"/), \
                   (/"1973", "OA",  "NYM"/), \
                   (/"1974", "OA",  "LAD"/), \
                   (/"1975", "CRe", "BRS"/), \
                   (/"1976", "CRe", "NYY"/), \
                   (/"1977", "NYY", "LAD"/), \
                   (/"1978", "NYY", "LAD"/), \
                   (/"1979", "PPi", "BO"/),  \
                   (/"1980", "PPh", "KCR"/), \
                   (/"1981", "LAD", "NYY"/), \
                   (/"1982", "SLC", "MBe"/), \
                   (/"1983", "BO",  "PPh"/), \
                   (/"1984", "DT",  "SDP"/), \
                   (/"1985", "KCR", "SLC"/), \
                   (/"1986", "NYM", "BRS"/), \
                   (/"1987", "MT",  "SLC"/), \
                   (/"1988", "LAD", "OA"/),  \
                   (/"1989", "OA",  "SFG"/), \
                   (/"1990", "CRe", "OA"/),  \
                   (/"1991", "MT",  "AB"/),  \
                   (/"1992", "TBJ", "AB"/),  \
                   (/"1993", "TBJ", "PPh"/), \
                   (/"1994", "missing", "missing"/), \
                   (/"1995", "AB",  "CI"/),  \
                   (/"1996", "NYY", "AB"/),  \
                   (/"1997", "FM",  "CI"/),  \
                   (/"1998", "NYY", "SDP"/), \
                   (/"1999", "NYY", "AB"/),  \
                   (/"2000", "NYY", "NYM"/), \
                   (/"2001", "AD",  "NYY"/), \
                   (/"2002", "AA",  "SFG"/), \
                   (/"2003", "FM",  "NYY"/), \
                   (/"2004", "BRS", "SLC"/), \
                   (/"2005", "CWS", "HA"/),  \
                   (/"2006", "SLC", "DT"/),  \
                   (/"2007", "BRS", "CRo"/), \
                   (/"2008", "PPh", "TBR"/), \
                   (/"2009", "NYY", "PPh"/), \
                   (/"2010", "SFG", "TR"/),  \
                   (/"2011", "SLC", "TR"/),  \
                   (/"2012", "SFG", "DT"/),  \
                   (/"2013", "BRS", "SLC"/), \
                   (/"2014", "SFG", "KCR"/), \
                   (/"2015", "KCR", "NYM"/), \
                   (/"2016", "CC",  "CI"/)  \
             /)

  nteams = dimsizes(teams(:,0))
  num_ws = dimsizes(world_series(:,0))

  world_series_compare = new((/2,2*num_ws/),string,"missing")
  world_series_compare(0,0:num_ws-1) = world_series(:,1)
  world_series_compare(0,num_ws:)    = world_series(:,2)
  world_series_compare(1,0:num_ws-1) = world_series(:,1)

;
; Create arrays to hold only the teams that actually won/lost, and
; their corresponding colors.
;
  teams2 = new((/nteams,2/),string)
  colors = new(nteams,integer,-999)

;
; Define the colormap using colors that are 
; close to the actual team colors.
; 
  cmap = new((/nteams+2,3/),float)
  cmap(0,:)  = (/1.,1.,1./)
  cmap(1,:)  = (/0.,0.,0./)
  cmap(2:,:) = tofloat(teams(:,2:4))/100.

  wks = gsn_open_wks("png","histo")        ; Open workstation and
  gsn_define_colormap(wks,cmap)            ; change colormap.

  res               = True
  res@gsnDraw       = False     ; Don't draw.
  res@gsnFrame      = False     ; Don't advance frame.
  res@gsnMaximize   = True      ; Maximize plot in frame.
  res@tmXBLabelsOn  = False     ; Turn off bottom labels
  res@tmXBOn        = False     ; Turn off bottom tickmarks
  res@tiYAxisString = ""        ; No title on Y axis.
  res@gsnPaperOrientation = "portrait"

  txres               = True                     ; Text resources

  plot  = new(3,graphic)        ; Wins, losses, comparison

;---Do histograms for both teams that won and lost. 1=won, 2=lost
  wl_str = (/"won","lost","compare"/)
  do wl=1,3

    if(wl.le.2) then
;---Collect the names of teams that either won or lost.
      nteams2 = 0
      do i=0,nteams-1
        if(any(teams(i,1).eq.world_series(:,wl))) then
          teams2(nteams2,:) = teams(i,0:1)
          colors(nteams2) = i+2     ; add 2 because of back/foreground colors
          nteams2 = nteams2 + 1
        end if
      end do
      new_teams := teams2(0:nteams2-1,:)
  
;---Specify list of teams to count, and their corresponding colors.
      res@gsnHistogramDiscreteBinValues  = new_teams(:,1)
      res@gsFillColor                    = colors    ; Set colors for each bar

      title = "# times teams " + wl_str(wl-1) + " the World Series"
      res@tiMainString = title
;
; Generate histogram. It won't get drawn at this point because we
; set gsnDraw to False.  We want to add text to it first.
;
      plot(wl-1) = gsn_histogram(wks,world_series(:,wl),res)

;---Print debug information.
     print("Number of World Series = " + num_ws)
     print("" + title)
     print("-----------------------------------------------")
     print(new_teams(:,0) + " " + wl_str(wl-1) + " " + plot@NumInBins + \
           " World Series.")
     print("")

;---Get index that contains the max wins/losses.
      nib := plot@NumInBins
      mbl :=  plot@MidBarLocs
    else
;---This is the section that draws the comparison plot
      title = "# times teams in W.S. versus winning it"
      new_teams := teams

      res@gsFillColor                   = ispan(2,2+nteams-1,1)
      res@gsnHistogramCompare           = True
      res@gsnHistogramDiscreteBinValues = teams(:,1)

      res@tiMainString                  = title
      res@tiMainFontHeightF             = 0.02
      res@tiYAxisOn                     = False ; This completely removes
                                                ;  the title and improves 
                                                ; plot maximization

;---Lots of changes to tickmark resources here
      res@tmYMajorGrid                  = True
      res@tmYMajorGridLineDashPattern   = 2  ; short dash lines
      res@tmYMajorGridLineColor         = "gray25"
      res@tmYMajorGridThicknessF        = 0.5
      res@tmYROn                        = False
      res@tmYLLabelFontHeightF          = 0.015
      res@tmYLMode                      = "Manual"

      plot(wl-1) = gsn_histogram(wks,world_series_compare,res)

;
; Get index that contains the max times in W.S. Have to do 
; the "tmp" thing because you can't subscript attribute 
; arrays directly.
;
      tmp1 = plot@NumInBins
      tmp2 = plot@MidBarLocs
      nib  := tmp1(0,:)
      mbl  := tmp2(0,:)
    end if
;
; Put names of teams vertically above the bar. Have to treat the team
; with the most wins or losses (NY Yankees as of 2011) special because
; they screw up the histogram with their high number of W.S.
; appearances compared to everybody else.
;
    imax = maxind(nib)

    txres@txJust        = "BottomCenter"
    txres@txAngleF      = 90.                  ; Vertical text.
    txres@txFontHeightF = 0.015
;
; plot@NumInBins contains the count for each bar. MidBarLocs contains the
; X position (in plot coordinates) of the midpoint of each bar.
;
; They are not used here, but BeginBarLocs and EndBarLocs return the
; begin and end positions of each bar in the X direction.
;
    dumstr = unique_string("dum")
    plot@$dumstr$ = gsn_add_text(wks,plot(wl-1)," " + \
                                 new_teams(0:imax-1,0), \
                                 mbl(0:imax-1), \
                                 nib(0:imax-1),txres)
    dumstr = unique_string("dum")
    plot@$dumstr$ = gsn_add_text(wks,plot(wl-1)," " + \
                                 new_teams(imax+1:,0), \
                                 mbl(imax+1:), \
                                 nib(imax+1:),txres)

    dumstr = unique_string("imax")
    txres@txAngleF = 0.                  ; Horizontal text.
    plot@$dumstr$ = gsn_add_text(wks,plot(wl-1),new_teams(imax,0), \
                                 mbl(imax), \
                                 nib(imax)+0.1,txres)
;---Now draw plot and advance frame.
    draw(plot(wl-1))
    frame(wks)

;---Clean up before next time through the loop.
    colors = -999
    delete([/res@gsnHistogramDiscreteBinValues,res@gsFillColor/])
  end do

end
