#!/bin/bash
cd TESTS
tar -xfFortran_C_tests.tar
ls
gfortran TEST_1_fortran_only_fixed.f && ./a.out
gfortran TEST_2_fortran_only_free.f90 && ./a.out
gcc TEST_3_c_only.c && ./a.out
gcc -c -m64 TEST_4_fortran+c_c.c
gfortran -c -m64 TEST_4_fortran+c_f.f90
gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
./a.out
./TEST_csh.csh
./TEST_perl.pl
./TEST_sh.sh
sudo apt install csh 
./TEST_csh.csh
exit 0