;----------------------------------------------------------------------
; This example reads an ASCII file that is formatted a specific way, and
; writes out the results to a netCDF file.
;
; The first line in the ASCII file must be a header, with each field
; separated by a single character delimiter (like a ","). The rest of
; the file must be such that each row contains all fields, each
; separated by the designated delimiter.
;
; The fields can be integer, float, double, character, or string.
; String fields cannot be written to a netCDF file. They have to
; be read in as character arrays and written out that way.
;
; To modify either one for your own data file, first search for the lines:
;
; ;============================================================
; ; Main code
; ;============================================================
;
; The lines you need to modify follow shortly:
;   filename  = "asc5.txt"                ; ASCII file to read.
;   nfields   = 6                         ; # of fields
;   delimiter = ","                       ; field delimiter
;   var_types      = new(nfields,string)
;   var_msg        = new(nfields,string)
;   var_strlens    = new(nfields,integer)   ; var to hold string lengths,
;                                           ; just in case.
;   .
;   .
;   .
;   var_msg        = ""              ; Default to no missing
;   var_msg(3)     = "-999"          ; Corresponds to field #4
;   var_types      = "integer"       ; Default to integer
;   var_types(1:2) = "float"         ; Second and third fields
;   var_types(4)   = "character"     ; Corresponds to field #5
; 
; Change "var_types" to whatever the types of your fields are, and
; "var_msg" to what the missing value should be (an empty string
; indicates no missing value).  The above code is defaulting all
; variable types to "integer", and then changing the 2nd and 3rd fields
; to type "float" and the fifth field to type "character" (which in this
; case is being used as a character array). The only field that will
; contain a missing value is the fourth field.
; 
; The allowable variable types are "integer", "float", "double",
; "string", or "character". Note that if you read in a variable as a
; string, it won't get written to the netCDF file because only character
; arrays can be written to a netCDF file.
;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function reads in a particular field from a string array,
; given the field number to read, the delimiter, and the type.
;
; It returns either an integer, float, double, character, or a string,
; depending on the input flag "return_type".
;
; Last input variable, wspace_opt, is only for strings or character arrays:
;   = 0 --> do nothing
;   = 1 --> whitespace at the beginning and end of string are trimmed
;           and rest converted to "_".
;   = 2 --> only whitespace at the beginning are removed
;   = 3 --> only whitespace at the end are removed
;
; This is needed for the variable names in the header that can't start
; or end with a space.
;----------------------------------------------------------------------
function read_field(strings:string,ifield:integer,delim[1]:string, \
                    return_type,msg_str[1]:string,msg_val[1]:string,\
                    wspace_opt:integer)
local carray, slen, tmpx
begin
;
; Set up array to return.
;
; For numeric fields, we have to check if there's some string
; that represents a missing value, for example "NA", or "---".
; If msg_str is set, then this is the string to compare, and
; if msg_val is set, this is the value to replace it with.
; If msg_str is set, but msg_val is not, then the default 
; missing value for that type will be used.
;
; For example, msg_str might be set to "NA" for an integer
; field, msg_val could be set to "-999". Or, you can set
; msg_str to "NA", and msg_val to just "", and the default
; missing value for an integer will be used.
;
  valid_numeric_types = (/"byte","short","integer","long","float","double"/)
  if(any(return_type.eq.valid_numeric_types)) then
    if(msg_str.ne."") then
      tmps = str_get_field(strings,ifield,delim)
      if(msg_val.eq."") then
        tmp_msg_val = tostring(default_fillvalue(return_type))
      else
        tmp_msg_val = msg_val
      end if
      tmps = where(tmps.eq.msg_str,tmp_msg_val,tmps)
      tmpx = totype(tmps,return_type)
      tmpx@_FillValue = totype(tmp_msg_val,return_type)
      delete(tmps)
      return(tmpx)
    else
      return(totype(str_get_field(strings,ifield,delim),return_type))
    end if
  end if
  if(any(return_type.eq.(/"string","character"/))) then
    return_array = str_get_field(strings,ifield,delim)
;
; Deal with white space
;
; Whitespace at the beginning and end of string are trimmed
;  and rest converted to "_".
;
    if(wspace_opt.eq.1) then
      return_array = str_strip(return_array)
      return_array = str_sub_str(return_array," ","_")
    end if

; Only whitespace at the beginning are removed.
    if(wspace_opt.eq.2) then
      return_array = str_left_strip(return_array)
    end if

; Only whitespace at the end are removed.
    if(wspace_opt.eq.3) then
      return_array = str_right_strip(return_array)
    end if
;---"tochar" doesn't return an end-of-string like stringtochar does.
    carray = tochar(return_array)
    if(msg_str.ne."") then
      carray@_FillValue = tochar(return_msg)
    end if
    return(carray)
  end if
end

;============================================================
; Main code
;============================================================
begin
;
; Set up defaults here.  We are hard-coding the field types here.
; You can set up this script to try to determine the field types 
; automatically, but this is a bit tedious. Maybe later.
;
  filename  = "asc5.txt"                ; ASCII file to read.
  cdf_file  = filename + ".nc"          ; netCDF file to write.
  delimiter = ","                       ; field delimiter

;
; Read in data as strings. This will create a string array that has the
; same number of strings as there are rows in the file. We will then need
; to parse each string later.
;
  read_data = asciiread("../Data/asc/" + filename,-1,"string")
;  read_data = asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  nrows     = dimsizes(data)      ; Number of rows.

  nfields   = str_fields_count(data(0),delimiter)
  print("nfields = " + nfields)
;
; In "asc5.txt", field #5 is type string, fields #2 and #3
; are float, and the rest are integers.
;
  var_types      = new(nfields,string)
  var_msg_str    = new(nfields,string)    ; var to hold string missing vals
                                          ; (for example, "NA")
  var_msg_val    = new(nfields,string)    ; var to hold numeric missing vals
                                          ; (for example, "-999")
  var_strlens    = new(nfields,integer)   ; var to hold strlens, just in case.

  var_msg_str    = ""                     ; Default to no missing
  var_msg_val    = ""                     ; If you don't set this, then the
                                          ; default missing value for the type 
                                          ; will be used. This is recommended.
  var_msg_val(3) = "-999"                 ; Corresponds to field #4 (integer)
  var_types      = "integer"              ; Default to int.
  var_types(4)   = "character"            ; Corresponds to field #5.
  var_types(1:2) = "float"

  if(isfilepresent(cdf_file))
    print("Warning: '" + cdf_file + "' exists.")
    print("Remove before running this script.")
    exit
;    print("Will remove it.")
;    system("/bin/rm " + cdf_file)
  end if

;
; Read in the field names which will become variable names on
; the netCDF file.
;
  var_names = new(nfields,string)
  do i=0,nfields-1
    var_names(i) = str_get_field(header,i+1,delimiter)
  end do
;
; Write out this netCDF file efficiently so it will be faster.
; Try to predefine everything before you write to it.
; 
  f = addfile(cdf_file,"c")
  setfileoption(f,"DefineMode",True)       ; Enter predefine phase.

;
; Write global attributes to file. It's okay to do this before 
; predefining the file's variables. We are still in "define" mode.
;
  fAtt               = True
  fAtt@description   = "Data read in from " + filename + " ASCII file."
  fAtt@creation_date = systemfunc ("date")        
  fileattdef( f, fAtt )        

;
; Write dimension names to file. If there are no character variables,
; then there's only one dimension name ("nvalues").
;
; Otherwise, we need to write a dimension name for every character
; variable, which will indicate the maximum string length for that
; variable.
;
  indc = ind(var_types.eq."character")
  if(.not.any(ismissing(indc))) then
;
; We have to treat the character arrays special here. We need to
; know their sizes so we can write the maximum size of each char
; array to the netCDF file as a dimension name. This means we
; need to read in the character variables once to get the string
; lengths, then we'll read them again later to get the actual values.
;
    do i=0,dimsizes(indc)-1
      var_strlens(indc(i)) = max(strlen(str_get_field(data,indc(i)+1, \
                                                      delimiter)))
    end do

    ndims    = dimsizes(indc) + 1
    dimNames = new(ndims,string)
    dimSizes = new(ndims,integer)
    dimUnlim = new(ndims,logical)

    dimUnlim            = False
    dimUnlim(0)         = True
    dimNames(0)         = "nvalues"
    dimNames(1:ndims-1) = var_names(indc) + "_StrLen"
    dimSizes(0)         = -1
    dimSizes(1:ndims-1) = var_strlens(indc)
    filedimdef(f,dimNames,dimSizes,dimUnlim)
  else
;
; No character variables, so just write the one dimension name.
;
    filedimdef(f,"nvalues",-1,True)
  end if

;
; Define each variable on the file.
;
; Don't deal with variables that are of type string.
;
  do i=0,nfields-1
    if(var_types(i).ne."string") then
      if(var_types(i).ne."character") then
        filevardef(f, var_names(i), var_types(i), "nvalues")
      else
        filevardef(f, var_names(i), var_types(i),  \
                   (/"nvalues",var_names(i)+"_StrLen"/))
      end if
    end if
  end do

;
; Loop through each field, read the values for that field, print 
; information about the variable, and then write it to the netCDF
; file.
;
  do i=0,nfields-1
    ifield = i+1           ; Fields start at #1, not #0.
;
; Note: you can't write strings to a netCDF file, so these have
; to be written out as character arrays.
;
    tmp_data = read_field(data,ifield,delimiter,var_types(i),\
                          var_msg_str(i),var_msg_val(i),0)

;
; Print some info about the variable.
;
    print("")
    print("Writing variable '" + var_names(i) + "' (field #" + ifield + ").")
    print("Type is " + var_types(i) + ".")
    if(var_types(i).ne."string".and.var_types(i).ne."character") then
      print("min/max = " + min(tmp_data) + "/" + max(tmp_data))
    end if

    if(any(ismissing(tmp_data))) then
      print("This variable does contain missing values.")
    else
      print("This variable doesn't contain missing values.")
    end if

    f->$var_names(i)$ = (/tmp_data/)       ; Write to netCDF file.

    delete(tmp_data)                   ; Delete for next round.
  end do
end
