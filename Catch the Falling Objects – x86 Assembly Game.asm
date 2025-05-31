.model small
.stack 100h
.data
    x_pos db 40
    y_pos db 0
    karakter db '*'
    renk db 07h
    ekran_genisligi db 80
    ekran_yuksekligi db 25
    seed dw 12345

    platform_uzunluk db 10
    platform_y db 23
    platform_x db 35
    platform_karakter db '-'
    platform_renk db 0Ah

    oyun_bitti db 0
    hiz db 1
    skor dw 0

    baslama_mesaji db 'oyuna baslamak icin 0 tusuna basin..$'
    oyun_bitti_mesaj db 'oyun bitti skorun: $'
    yeniden_basla_mesaj db 13, 10, 'yeniden denemek icin 0, cikmak icin esc basin..$'
    
    bekle_sayac dw 25000    

.code
main proc
    mov ax, @data
    mov ds, ax


    mov ax, 0003h
    int 10h

oyun_yeniden_basla:
   
    call oyun_degiskenlerini_sifirla
    
    call ekrani_temizle
    call oyun_baslat_mesaji
    call tus_bekle_0
    call ekrani_temizle

    call rastgele_pozisyon
    call platformu_ciz

ana_dongu:
    cmp [oyun_bitti], 1
    je oyun_bitir

    call nesneyi_ciz
    call bekleme
    call pozisyonu_temizle

    mov al, [hiz]
    add [y_pos], al

  
    mov al, [y_pos]
    cmp al, [ekran_yuksekligi]
    jl carp_kontrol

  
    mov [oyun_bitti], 1
    jmp ana_dongu

carp_kontrol:
   
    mov al, [y_pos]
    cmp al, [platform_y]
    jne devam_et

    mov al, [x_pos]
    mov bl, [platform_x]
    cmp al, bl
    jl platform_miss

    mov al, [platform_x]
    add al, [platform_uzunluk]
    cmp [x_pos], al
    jge platform_miss

    mov [y_pos], 0
    inc [skor]
    call rastgele_pozisyon
    
    call klavye_buffer_temizle
    
    jmp devam_et

platform_miss:
    cmp [y_pos], 23
    jl devam_et
    mov [oyun_bitti], 1
    jmp ana_dongu

devam_et:
    mov ah, 01h
    int 16h
    jz ana_dongu

    mov ah, 00h
    int 16h

    cmp al, 27
    je programi_bitir

    cmp ah, 4Bh
    je sol_ok
    
    cmp ah, 4Dh
    je sag_ok
    jmp ana_dongu

sol_ok:
    call platformu_temizle
    mov al, [platform_x]
    cmp al, 2            
    jb platform_hareketi_bitti
    sub [platform_x], 3
    jmp platform_hareketi_bitti


sag_ok:
    call platformu_temizle
    mov al, [platform_x]
    add al, [platform_uzunluk]
    add al, 1                 
    cmp al, [ekran_genisligi]
    jae platform_hareketi_bitti
    add [platform_x], 3       


platform_hareketi_bitti:
    call platformu_ciz
    jmp ana_dongu

oyun_bitir:
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 20
    int 10h

    mov ah, 09h
    lea dx, oyun_bitti_mesaj
    int 21h

    mov ax, [skor]
    call goster_skor

    mov ah, 09h
    lea dx, yeniden_basla_mesaj
    int 21h

yeniden_basla_bekle:
    mov ah, 00h
    int 16h
    
    cmp al, '0'
    je oyun_yeniden_basla
    
    cmp al, 27
    je programi_bitir
    
    jmp yeniden_basla_bekle

programi_bitir:
    mov ax, 4C00h
    int 21h
main endp

klavye_buffer_temizle proc
    push ax
    
temizle_loop:
    mov ah, 01h
    int 16h
    jz temizle_bitti    
    
    mov ah, 00h
    int 16h
    
    jmp temizle_loop

temizle_bitti:
    pop ax
    ret
klavye_buffer_temizle endp

oyun_degiskenlerini_sifirla proc
    push ax
    
    mov [y_pos], 0
    mov [x_pos], 40
    mov [platform_x], 35
    mov [oyun_bitti], 0
    mov [skor], 0
    
    mov ax, [seed]
    add ax, 1234
    mov [seed], ax
    
    pop ax
    ret
oyun_degiskenlerini_sifirla endp

oyun_baslat_mesaji proc
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 20
    int 10h

    mov ah, 09h
    lea dx, baslama_mesaji
    int 21h
    ret
oyun_baslat_mesaji endp

tus_bekle_0 proc
bekle:
    mov ah, 00h
    int 16h
    cmp al, '0'
    jne bekle
    ret
tus_bekle_0 endp

rastgele_sayi_uret proc
    push ax
    push dx
    
    mov ax, [seed]
    mov dx, 8405h
    mul dx
    add ax, 17549
    mov [seed], ax
    
    pop dx
    pop ax
    ret
rastgele_sayi_uret endp

rastgele_pozisyon proc
    push ax
    push dx
    
    call rastgele_sayi_uret
    mov ax, [seed]
    xor dx, dx
    mov cx, 80
    div cx
    mov [x_pos], dl
    
    pop dx
    pop ax
    ret
rastgele_pozisyon endp

nesneyi_ciz proc
    push ax
    push bx
    
    mov ah, 02h      
    mov bh, 0        
    mov dh, [y_pos] 
    mov dl, [x_pos]  
    int 10h
    
    mov ah, 09h      
    mov al, [karakter]
    mov bh, 0        
    mov bl, [renk]   
    mov cx, 1        
    int 10h
    
    pop bx
    pop ax
    ret
nesneyi_ciz endp

pozisyonu_temizle proc
    push ax
    push bx
    
    mov ah, 02h      
    mov bh, 0       
    mov dh, [y_pos] 
    mov dl, [x_pos]  
    int 10h
    
    mov ah, 09h      
    mov al, ' '
    mov bh, 0       
    mov bl, [renk]   
    mov cx, 1       
    int 10h
    
    pop bx
    pop ax
    ret
pozisyonu_temizle endp

platformu_ciz proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 02h      
    mov bh, 0      
    mov dh, [platform_y]  
    mov dl, [platform_x]  
    int 10h
    
    mov ah, 09h     
    mov al, [platform_karakter]
    mov bh, 0       
    mov bl, [platform_renk]   
    mov cl, [platform_uzunluk]  
    mov ch, 0
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
platformu_ciz endp

platformu_temizle proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 02h      
    mov bh, 0       
    mov dh, [platform_y]  
    mov dl, [platform_x] 
    int 10h
    
    mov ah, 09h      
    mov al, ' '
    mov bh, 0       
    mov bl, [platform_renk]   
    mov cl, [platform_uzunluk] 
    mov ch, 0
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
platformu_temizle endp

ekrani_temizle proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 06h     
    mov al, 0      
    mov bh, 07h      
    mov ch, 0        
    mov cl, 0        
    mov dh, 24       
    mov dl, 79       
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ekrani_temizle endp

bekleme proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 1   
dis_loop:
    mov dx, 1   
inner_loop:
    nop
    dec dx
    jnz inner_loop
    loop dis_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
bekleme endp

goster_skor proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    mov cx, 0

donustur:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne donustur

yazdir:
    pop dx
    mov ah, 02h
    mov dl, dl
    int 21h
    loop yazdir
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
goster_skor endp

end main