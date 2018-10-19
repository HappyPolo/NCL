;----------------------------------------------------------------------
; write_csv_1.ncl
;
; Concepts illustrated:
;   - Writing a CSV file
;   - Using sprinti and asciiwrite to write integers to a CSV file
;   - Using write_table to write integers to a CSV file
;----------------------------------------------------------------------
begin
  filename = "example1a.csv"
  system("rm -rf " + filename)

;---Arrays to write to a CSV file, each in their own column
  x1 = (/34,36,31,29,54,42/)
  x2 = (/67,87,56,67,71,65/)
  x3 = (/56,78,88,92,68,82/)

;----------------------------------------------------------------------
; One way to write the CSV file, using sprinti and asciiwrite.
;----------------------------------------------------------------------
  lines = sprinti("%2i",x1) + "," + sprinti("%2i",x2) + "," + sprinti("%2i",x3)
  asciiwrite(filename,lines)

  print("==================== " + filename + " ====================")
  system("cat " + filename)

;----------------------------------------------------------------------
; Another way to write the CSV file, using write_table.
;----------------------------------------------------------------------
  filename = "example1b.csv"
  system("rm -rf " + filename)
  write_table(filename,"w",[/x1,x2,x3/],"%2i,%2i,%2i")

  print("`==================== " + filename + " ====================")
  system("cat " + filename)

end
