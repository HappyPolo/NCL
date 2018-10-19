;----------------------------------------------------------------------
; box_6.ncl
;
; Concepts illustrated:
;   - Drawing box plots using statistics calculated with stat_dispersion
;   - Using text function codes to generate accented characters
;----------------------------------------------------------------------
; This script was contributed by Guilherme Martins of the
; National Institute for Space Research.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
; O arquivo pr.djf.cx2.txt possui 4 colunas na ordem abaixo com valores de precipitação 
; (mm/dia) para o nordeste da Amazônia para os meses de DJF (1979 a 2005).
; Col1   Col2      Col3      Col4   
; GPCP ACCESS1-0 BCC-CSM1.1 CANESM2

atxt     = "pr.djf.cx2.txt"  ; Nome do arquivo no formato txt.
nlinhas  = numAsciiRow(atxt) ; Número de linhas do arquivo.
ncolunas = numAsciiCol(atxt) ; Número de colunas do arquivo.

f = asciiread(atxt,(/nlinhas,ncolunas/),"float") ; Abertura do arquivo texto. Esse arquivo
                                                 ; possui 78 linhas e 4 colunas.

opt           = True ; Habilita personalização da estatística.
opt@PrintStat = True ; Mostra na tela o resultado da estátistica da função stat_dispersion. 

; A linha abaixo imprime na tela o resultado da estatística para cada variável.

obs  = stat_dispersion(f(:,0),opt); f(:,0) = todas as linhas da primeira coluna (GPCP).
mod1 = stat_dispersion(f(:,1),opt); f(:,1) = todas as linhas da segunda coluna (ACCESS1-0).
mod2 = stat_dispersion(f(:,2),opt); f(:,2) = todas as linhas da terceira coluna (BCC-CSM1.1).
mod3 = stat_dispersion(f(:,3),opt); f(:,2) = todas as linhas da quarta coluna (CAESM2).

; Os valores (2), (7), (8), (11) e (14) abaixo correspondem à: valor mínimo, 
; primeiro quartil, mediana, terceiro quartil e o valor máximo da série, respectivamente.

yval      = new((/4,5/),"float",-999.)
yval(0,0) = obs(2)   ; Tamanho da haste inferior.
yval(0,1) = obs(7)   ; Primeiro quartil.
yval(0,2) = obs(8)   ; Mediana.
yval(0,3) = obs(11)  ; Terceiro quartil.
yval(0,4) = obs(14)  ; Tamanho da haste superior.

yval(1,0) = mod1(2)  ; Tamanho da haste inferior.
yval(1,1) = mod1(7)  ; Primeiro quartil.
yval(1,2) = mod1(8)  ; Mediana.
yval(1,3) = mod1(11) ; Terceiro quartil.
yval(1,4) = mod1(14) ; Tamanho da haste superior.

yval(2,0) = mod2(2)  ; Tamanho da haste inferior.
yval(2,1) = mod2(7)  ; Primeiro quartil.
yval(2,2) = mod2(8)  ; Mediana.
yval(2,3) = mod2(11) ; Terceiro quartil.
yval(2,4) = mod2(14) ; Tamanho da haste superior.

yval(3,0) = mod3(2)  ; Tamanho da haste inferior.
yval(3,1) = mod3(7)  ; Primeiro quartil.
yval(3,2) = mod3(8)  ; Mediana.
yval(3,3) = mod3(11) ; Terceiro quartil.
yval(3,4) = mod3(14) ; Tamanho da haste superior.

x = ispan(1,ncolunas,1) ; Valores para o eixo x.

wks = gsn_open_wks("png","box")

res                 = True
res@tmXBLabelAngleF = 45.                                           ; Inclinação do texto.
res@tmXBLabels      = (/"GPCP","ACCESS1-0","BCC-CSM1.1","CANESM2"/) ; Rótulos do eixo x.
res@tiMainString    = "Box plot default"                            ; Título da figura.

plot = boxplot(wks,x,yval,False,res,False) ; Geração do boxplot.

draw(wks)
frame(wks)

end
