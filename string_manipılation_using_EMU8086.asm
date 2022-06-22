; @author	<152120181032 Zeynep Ozdemir>
; @date		2022.05.15
; @brief	152120181032_BilMim-B-2122B_UYG3 (fill this part as well)

		mov si, offset inputCodded
		mov di, offset outputClean                        
		;call extractCleanText
			   
		lea si, inputCodded
		lea di, outputText                        
		call extractCoddedText
                
finish: hlt

proc extractCleanText 
    
start_clean:                   
        lodsb                   ; al' ye byte byte degerler ataniyor ve si birer birer arttiriliyor.
        cmp al, '$'             ; al' ye atanan deger, '$' a esit mi diye kontrol ediliyor.
        je  rt                  ; esit ise sonlandirilir, prosedur return edilir.
        cmp al, '<'             ; al degeri '<' isaretine esit mi diye kontrol ediliyor.
        je  while_loop          ; esit ise ozel islem yapilacagini belirtiyor ve bu islemi bastirmamak icin while_loop' a gonderiliyor.
        stosb                   ; al deki deger outpuText' e aktarliyor.
        jmp start_clean         ; bir sonraki byte degerini kontrol etmek icin ayni islemler tekrarlaniyor.
                                
                                
                                
while_loop:                     ; bu fonksiyon ile ozel komutun ekrana bastirilmasi engelleniyor, kodumuz komuttan arindiriliyor.                                                                                                                     
        lodsb                   ; bir sonraki karaktere geciliyor.                                                                                                                                                                                     
        cmp al, '>'             ; al deki deger '>' isartine esit mi diye kontrol ediliyor.                                                                                                                                                           
        je  start_clean         ; esit ise ozel komutun sonuna geldigini anliyor, islem sonlandiriliyor.                                                                                                                                                
        jmp while_loop          ; esit degilse, ozel komutun sonuna gelene kadar ayni islem tekrarlaniyor.                                                                                                                                                                                                               
                                                                                                                                                                                                                                                      
rt:     ret                     
                                
                                
                                
proc extractCoddedText          
                                
start_codded:                   
                                
        lodsb                   ; al' ye byte byte degerler ataniyor ve si birer birer arttiriliyor.  
        cmp al, '$'             ; al' ye atanan deger, '$' a esit mi diye kontrol ediliyor.           
        je  rt1                 ; esit ise sonlandirilir, prosedur return edilir.                     
                                             
        cmp al,'<'              ; al degeri '<' isaretine esit mi diye kontrol ediliyor. 
        je  is_codeCaseU        ; eger esit ise bu bir ozel komuttur, bu komut caseup komutu mu diye kontrol etmke icin ilgili fonksiyona gonderiliyor.
                                
        cmp al, '>'             ; al degeri '>' isaretine esit mi diye kontrol ediliyor.
        je  perform_the_case    ; eger esit ise ozel komutun sonuna gelmistir, ilgili komutu yerine getirmek icin ilgili fonksiyona gonderiliyor.
        jmp start_codded        ; esit degil ise komut kontrol islemi devam ettiriliyor.
                 

        
         
         
is_codeCaseU:                   ; bu fonksiyon ile ozel komutun upcase komutu olup olmadigi kontrol ediliyor.
        mov up_flag , 0         ; kontrol isleminden once up_flag, low_flag ve end_flag sifirlaniyor
        mov low_flag, 0
        mov end_flag, 0
                                 
        mov cx, 7               ; ozel kod kontrolu icin '<'ve '>' karakterini kontrol etmeye gerek yok.
        lea di, [codecaseU+1]   ; 
         
        repe cmpsb              ; karsilastirma islemi yapiliyor.
        jnz is_codeCaseL        ; karsilastirilan degerler esit degilse, bir sonraki komut karsilastirilmasina geciliyor.
        mov up_flag,1           ; up_flag degeri, bu komutun caseup komutu oldugunu belirtmek icin 1 e esitleniyor.
        jmp start_codded        ; inputText teki verilerin ilgili islemden gecirilmesi icin bu fonksiyona gonderiliyor. 
        
        
        
is_codeCaseL:                   ; bu fonksiyon ile ozel komutun upcase komutu olup olmadigi kontrol ediliyor.
        mov cx, 2               ; bu ozel komutun 6. ve 7. karakterlerinin kontrol edilmesi yeterlidir.
        lea di, [codecaseL+6]  
        repe cmpsb      
        jnz is_codeEnd  
        mov low_flag,1          ; low_flag degeri, bu komutun caselow komutu oldugunu belirtmek icin 1 e esitleniyor.
        jmp start_codded        ; inputText teki verilerin ilgili islemden gecirilmesi icin bu fonksiyona gonderiliyor. 
     
     
is_codeEnd:                     ; bu fonksiyon ile ozel komutun upcase komutu olup olmadigi kontrol ediliyor.
        mov cx, 5               ; bu ozel komutun 5., 6. ve 7. karakterlerinin kontrol edilmesi yeterlidir.         
        lea di, [codeEnd+3]  
        repe cmpsb       
        jnz start_codded         
        mov end_flag,1          ; low_flag degeri, bu komutun caselow komutu oldugunu belirtmek icin 1 e esitleniyor.   
        jmp start_codded        ; inputText teki verilerin ilgili islemden gecirilmesi icin bu fonksiyona gonderiliyor.  


perform_the_case:               ; bu fonksiyon ile ozel komut islemi gerceklestiriliyor. 
 
        lea di,[outputText+bx]  ; bx degeri di register inin sifirlanmasini engellemek icin kullanilmistir.
                                ; up_flag, low_flag ve end_flag degerlerine gore ilgili islem fonksiyonuna yonlendririliyor.
        cmp up_flag,1
        je  make_up_char 
        cmp low_flag,1
        je  make_low_char
        cmp end_flag,1
        je  endof
     
       
       
make_up_char:                   ; bu fonsiyon ile al' deki karakterin kucuk harf olup olmadigi kontrol ediliyor.
                                ; bu islem ascii karakterlerinin decimal degerlerinin karsilastirilmasi ile gerceklesektir. 

        lodsb
        cmp al, '<' 
        je  is_codeCaseU
        cmp al,97               ; 'a'=97
        jb  up_char
        cmp al,122              ; 'z'=122
        ja  up_char
        sub al,32               ; 'a'-32='A', 'z'-32='Z'
        stosb                   ; bu komut ile al deki deger di register' a aktariliyor.
        inc bx
        jmp make_up_char        

up_char:                        ; bu fonsiyonda karakter herhangi bir islem gormeden outputText' e aktariliyor.        

        stosb                   ; bu komut ile al deki deger di register' a aktariliyor.
        inc bx                  
        jmp make_up_char        ; islem tekrarlaniyor.
        
          
make_low_char:                  ; bu fonsiyon ile al' deki karakterin buyuk harf olup olmadigi kontrol ediliyor.              
                                ; bu islem ascii karakterlerinin decimal degerlerinin karsilastirilmasi ile gerceklesektir.
                                
        lodsb
        cmp al, '<' 
        je  is_codeCaseU
        cmp al,65               ; 'A'=65
        jb  low_char  
 
        cmp al,90               ; 'Z'=90
        ja  low_char
  
        add al,32               ; 'A'+32='a', 'Z'+32='z'
        stosb                   ; bu komut ile al deki deger di register' a aktariliyor.
        inc bx
        jmp make_low_char 
        

low_char:                       ; bu fonsiyonda karakter herhangi bir islem gormeden outputText' e aktariliyor. 
                                                                                                                
        stosb                   ; bu komut ile al deki deger di register' a aktariliyor.                        
        inc bx                                                                                                  
        jmp make_low_char       ; islem tekrarlaniyor.                                                           
        

endof:                          ; bu fonksiyon ozel komutun sonlandigini gosterir
        lodsb                   ; bir sonraki karakterin ozel komut baslangici olup olmadigi kontrol edilir.
        cmp al, '<' 
        je  is_codeCaseU
        cmp al, '$'             ; string degerin sonuna gelip gelmedigi kontrol edilir.
        je  rt1                 ; eger string degerin sonuna gelindiyse islem tamamlanir, prosedur return edilir.
        stosb                   ; bu komut ile al deki deger di register' a aktariliyor.
        inc bx
        jmp endof   
        
rt1:    ret        
        
        
        
        
    
codeCaseU       db '<caseUpp>' 
codeCaseL       db '<caseLow>' 
codeEnd         db '</endofc>'
 
inputCodded     db '<caseUpp>152116026 bIlGiSayAr miMARiSi</endofc> (A/B) 21/22 <caseUpp>bAHar</endofc> Hafta 12, Uygu<caseLow>lamali DeRS Haftasi 4, </endofc>UYG3: Str<caseLow>ING islemLERi</endofc>!','$'
outputClean     db '************************************************************************************************************'
outputText      db 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
                     
; ozel islem kodlari icin kullanilacak flag'ler tanimlanmistir.
up_flag         db 0   
low_flag        db 0 
end_flag        db 0 