;**********************************************
all_files=systemfunc("ls /mnt/e/*.nc")
fall     =addfiles(all_files, "r")
ListSetType(fall, "join")
T =fall[:]->T2
fout=addfile("t.nc", "c")