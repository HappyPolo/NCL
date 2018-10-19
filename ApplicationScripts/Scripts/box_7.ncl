;----------------------------------------------------------------------
; box_7.ncl
;
; Concepts illustrated:
;   - Drawing box plots using statistics calculated with stat_dispersion
;   - Setting the color of individual boxes in a box plot
;   - Setting the width of individual boxes in a box plot
;   - Using text function codes to generate accented characters
;----------------------------------------------------------------------
; This script was contributed by Guilherme Martins of the
; National Institute for Space Research.
;----------------------------------------------------------------------
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
cedil   = "c~H-13F35~K~FH2~"
atilde  = "a~H-13V2F35~D~FV-2H3~"
ocirc   = "o~H-14V2F35~C~FV-2H3~"

; O arquivo pr.djf.cx2.txt possui 4 colunas na ordem abaixo com valores de precipitação 
; (mm/dia) para o nordeste da Amazônia para os meses de DJF (1979 a 2005).
; Col1   Col2      Col3      Col4   
; GPCP ACCESS1-0 BCC-CSM1.1 CANESM2

atxt     = "pr.djf.cx2.txt"  ; Nome do arquivo no formato txt.
nlinhas  = numAsciiRow(atxt) ; Número de linhas do arquivo.
ncolunas = numAsciiCol(atxt) ; Número de colunas do arquivo.

f = asciiread(atxt,(/nlinhas,ncolunas/),"float") ; Abertura do arquivo texto. Esse arquivo
                                                 ; possui 78 linhas e 4 colunas.

modelos = (/"GPCP","ACCESS1-0","BCC-CSM1.1","CANESM2"/) ; Nome dos rótulos.

opt           = True ; Habilita personalização da estatística.
opt@PrintStat = True ; Mostra na tela o resultado da estátistica da função stat_dispersion. 

; A linha abaixo imprime na tela o resultado da estatística para cada variável.

y = new((/dimsizes(modelos),nlinhas,ncolunas+1/),float)

x = ispan(1,ncolunas,1) ; Valores para o eixo x.

do j = 0,dimsizes(modelos)-1
   g = stat_dispersion(f(:,j),opt)
   y(j,:,0) = g(2)  ; Tamanho da haste inferior.
   y(j,:,1) = g(7)  ; Primeiro quartil.
   y(j,:,2) = g(8)  ; Mediana.
   y(j,:,3) = g(11) ; Terceiro quartil.
   y(j,:,4) = g(14) ; Tamanho da haste superior.
end do

wks = gsn_open_wks("png","box")

res                 = True         ; Personalização do boxplot.
res@tmXBLabels      = modelos      ; Rótulos do eixo x.
res@tiMainString    = "Precipita"+cedil+atilde+"o sobre o nordeste da Amaz"+ocirc+"nia"
res@trYMinF         = 0.0          ; Mínimo valor do eixo y.      
res@trYMaxF         = 12.0         ; Máximo valor do eixo y.
res@tmYLMode        = "Manual"	   ; Eixo y esquerdo (YL) de forma manual.
res@tmYLTickStartF  = res@trYMinF  ; Onde começam os valores do eixo y.
res@tmYLTickEndF    = res@trYMaxF  ; Onde terminam os valores do eixo y.
res@tmYLTickSpacingF= 1            ; Espaçamento entre os rótulos.
res@tmYLMinorOn     = False        ; Desliga o minortick do eixo y esquerdo.
res@tmYRBorderOn    = True         ; Habilita a borda do eixo y direito (YR). 
res@tmXTBorderOn    = True         ; Habilita a borda do eixo x superior (XB). 
res@tmXBLabelFontHeightF = 0.014   ; Tamanho da fonte do eixo x inferior (XB).
res@tiYAxisString   = "Precipita"+cedil+atilde+"o (mm/dia)" ; Título do eixo y.


llres                   = True     ; Personalização das linhas do boxplot.
llres@gsLineThicknessF  = 2.5      ; Espessura da linha.

opti           = True ; Habilita personalização da caixa.
opti@boxWidth  = 0.35 ; Largura da caixa. Quanto maior o valor, mais larga será a caixa.
opti@boxColors = (/"blue","red","green","orange"/) ; Cores de cada caixa.

plot = boxplot(wks,x,y(:,dimsizes(modelos),:),opti,res,llres) ; Geração do boxplot.

draw(wks)
frame(wks)

end
