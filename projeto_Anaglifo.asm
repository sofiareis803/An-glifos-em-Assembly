;fc59880
extern terminate 
extern printStrLn
extern readImageFile
extern writeImageFile

section.data 
Mensagem: db "Numero de parametros invalido", 10, 0

section .bss
imagemcriada: resb 1048576
imagemesq: resb 1048576
imagemdir: resb 1048576
section .text
global _start
_start:
    mov rdx, [rsp]
    cmp rdx, 5                  ;se o numero de agumentos nao for o pretendido mostrar mensagem de erro
    jne erro1
    mov rdi, [rsp+24]            ;obter endereço onde está guardado nome da imagem esquerda
    mov rsi, imagemesq           ;colocar em rsi endereço do buffer
    call readImageFile           ;ler imagem para buffer
    
    mov rdi, [rsp+32]            ;obter endereço onde está guardado nome da imagem direita
    mov rsi, imagemdir           ;colocar em rsi endereço do buffer
    call readImageFile           ;ler imagem para buffer
    
    mov rdx, [imagemdir+10]      ;colocar offset em rdx
    mov rcx, 0x00000000ffffffff
    and rdx, rcx
    
    xor rbx, rbx
cabecalho:
    mov rcx, [imagemdir+rbx]
    mov [imagemcriada+rbx], cl
    inc rbx
    cmp rdx, rbx
    jne cabecalho
    
    mov rsi, [rsp+16]            ;obter endereço do parâmtro correspondente ao algortimo a utilizar
    mov bl, [rsi]                ;obter caracter que representa algoritmo a utilizar
    mov cl, 'C'                  ;selecionar algoritmo
    cmp bl, cl
    mov rbx, rdx                 ;colocar em rbx o offset
    je C
    mov bl, [rsi]                ;obter caracter que representa algoritmo a utilizar
    mov cl, 'M'                  ;selecionar algoritmo
    cmp bl, cl
    mov rbx, rdx                 ;colocar em rbx o offset
    je M
    jmp erro1
    
C:
    cmp rax, rbx
    jae cicloC
    mov rdi, [rsp+40]
    mov rsi, imagemcriada
    mov rdx, rax
    call writeImageFile
    jmp end 
    
cicloC:
    mov rcx, [imagemdir+rbx]      ;preencher os bits da imagem criada de acordo com o algoritmo C
    mov [imagemcriada+rbx], cl
    inc rbx
    mov [imagemcriada+rbx], ch
    inc rbx
    mov rcx, [imagemesq+rbx]
    mov [imagemcriada+rbx], cl
    inc rbx
    mov Byte [imagemcriada+rbx], 0xff
    inc rbx
    
    jmp C
    
M:
    cmp rax, rbx
    jae cicloM
    mov rdi, [rsp+40]
    mov rsi, imagemcriada
    mov rdx, rax
    call writeImageFile
    jmp end
    
cicloM:
    push rax                        ;preencher os bits da imagem criada de acordo com o algoritmo C
    mov rax, [imagemdir+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 144
    mul rdx
    mov rcx, rax
    
    inc rbx
    mov rax, [imagemdir+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 587
    mul rdx
    add rcx, rax
    
    inc rbx
    mov rax, [imagemdir+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 299
    mul rdx
    add rcx, rax
    
    mov rax, rcx
    mov rcx, 1000
    div rcx
    sub rbx, 2
    mov [imagemcriada+rbx], al
    inc rbx
    mov [imagemcriada+rbx], al
    
    dec rbx                        ;preencg«jer 
    mov rax, [imagemesq+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 114
    mul rdx
    mov rcx, rax
    
    inc rbx                         ;preencher bit da cor verde 
    mov rax, [imagemesq+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 587
    mul rdx
    add rcx, rax
    
    inc rbx                         ;preencher bit da cor vermelha 
    mov rax, [imagemesq+rbx]
    mov rdx, 0x00000000000000ff
    and rax, rdx
    mov rdx, 299
    mul rdx
    add rcx, rax
    
    mov rax, rcx                    ;preencher transparencia 
    mov rcx, 1000
    div rcx
    mov [imagemcriada+rbx], al
    inc rbx
    mov Byte [imagemcriada+rbx], 0xff
    inc rbx
    
    pop rax
    jmp M
    
erro1: 
    mov rdi, Mensagem
    call printStrLn
    jmp end
end:
    call terminate
