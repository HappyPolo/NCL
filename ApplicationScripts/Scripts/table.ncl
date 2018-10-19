;*****************************************************
procedure means_table (case1,case2,vars,means,title,tablename)
; mark stevens  stevens@ucar.edu


; INPUT ARGUMENTS
; case1:     case1 name (string)
; case2:     case2 name (string)
; vars:      1d array (/nvar/) of variable names (strings)
; means:     2d array (/nvar,ncols/) of table values (floats)
; title:     table title (string)
; tablename: table output filename (string)

; FUNCTION
;   makes a 4 column table
;   column 1 contains the variable names  
;   columns 2-4 contain the table values
;***************************************************
begin
 nvars    = dimsizes (vars)           ; number of variables
 spaces   = integertochar(32)         ; space character
 nheaders = 8                         ; number of header lines
 nrows    = nvars+nheaders            ; total numbers of lines
 maxchar  = 20                        ; max number of chars in case names
;**************************************************
; calculate number of spaces needed to approximately
; center case1 name at top of column 2
;**************************************************
 chr1    = stringtochar(case1)
 nchr1   = dimsizes(chr1)-1
 nsp1    = (maxchar-nchr1)/2
 sp1     = new(nsp1,"character")
 sp1     = spaces 
 spaces1 = chartostring(sp1)
;***************************************************
; calculate number of spaces needed to approximately
; center case2 name at top of column 3
;***************************************************
 chr2    = stringtochar(case2)
 nchr2   = dimsizes(chr2)-1
 nsp2    = (maxchar-nchr2)/2
 sp2     = new(nsp2,"character")
 sp2     = spaces 
 spaces2 = chartostring(sp2)
;***************************************************
; calculate number of spaces needed to approximately
; center case1-case2 name at top of column 4
;***************************************************
 nchr3   = nchr1+1 
 nsp3    = (maxchar-nchr3)/2
 sp3     = new(nsp3,"character")
 sp3     = spaces 
 spaces3 = chartostring(sp3)

 nsp     = 11+nsp1+nchr1+nsp1+nsp2+nchr2+nsp2+nsp3
 sp4     = new(nsp,"character")
 sp4     = spaces
;***************************************************
; the lines of the header
;***************************************************
 table    = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE: "+case1
 table(3) = " "
 table(4) = "REFERENCE CASE: "+case2
 table(5) = " "
 table(6) = "Variable   "+spaces1+case1+spaces1+spaces2+case2+spaces2+ \
            spaces3+case1
 table(7) = sp4+"-"+case2
;***************************************************
; fill in table values
;***************************************************
 do n = 0, nvars-1
   varchr  = stringtochar(vars(n))
   nchar   = dimsizes(varchr)-1
   nspaces = 24-nchar
   if (vars(n).eq."AAM" .or. vars(n).eq."PME") then  ; use e notation for these
     fmt = "%"+nspaces+".3e"                        
     table(nheaders+n) = vars(n)+sprintf(fmt,means(n,0))+ \
                                 sprintf("%20.3e",means(n,1))+\
                                 sprintf("%18.3e",means(n,2))
   else
     fmt = "%"+nspaces+".3f"
     table(nheaders+n) = vars(n)+sprintf(fmt,means(n,0))+ \
                                 sprintf("%20.3f",means(n,1))+\
                                 sprintf("%18.3f",means(n,2))
   end if
   delete(varchr)
 end do
;***************************************************
; write out whole table all at once
;***************************************************
 asciiwrite(tablename,table)       ; write out table to file
end

