format ELF64 executable


include "util.inc"


SYS_brk = 0x0c


segment readable executable
entry main
main:
        mov         rsi, example
        mov         rdi, example_len
        call        solution
        int3
        exit 0


solution:
        call        parse_game_id
        push        rax
        mov         r8, 1              ; Set r8 to True
.next_draw:
        cmp         rdi, 0
        je          .done

        ; Preserve r8 register
        push        r8

        ; Fast-forward to next number
        mov         rdx, parse_is_number
        int3
        call        parse_until
        int3

        ; Determine if draw is valid
        call        parse_valid

        ; Combine draw results
        pop         r8
        imul        r8, rax            ; Multiply by 1 or 0
        jmp         .next_draw
.done:
        pop         rax                ; Game ID
        imul        rax, r8            ; Flag * ID
        ret


parse_valid:
        ; Parse N color
        call        parse_number
        push        rax
        call        parse_maximum
        push        rax

        ; Check valid statement
        pop         r8
        pop         r9
        cmp         r9, r8
        jg          .fail
        jmp         .pass

.fail:
        mov         rax, 0 
        ret
.pass:
        mov         rax, 1
        ret


; Always returns true
always:
        mov         rax, 1
        ret


; Detect number in string
;
; @returns 1 - succeed and 0 - fail
parse_is_number:
        push        rsi               ; Save address
        push        rdi               ; Save length
        call        parse_number
        mov         r9, rdi           ; Parsed length
        pop         rdi               ; Restore length
        pop         rsi               ; Restore address
        cmp         rdi, r9           ; Fail if no change
        je          .fail
        jmp         .success
.fail:
        mov rax, 0
        ret
.success:
        mov rax, 1
        ret


; Move to first successful parse
;
; @param rsi - Address of string
; @param rdi - Length of string
; @param rdx - Parser
; @returns rsi, rdi - position of string
parse_until:
.next:
        ; Break if string empty
        cmp rdi, 0
        je .done

        ; Save sub-parser address
        push rdx
        call    rdx
        pop rdx
        cmp     rax, 1
        je      .done

        ; If no match move to the next character
        inc     rsi
        dec     rdi
        jmp     .next
.done:
        ret


head:
        mov rsi, input
        mov rdi, input_len
        xor r12, r12
.loop:
        cmp rdx, 0
        je .exit

        ; Measure line
        push rdx
        call get_line
        push rax

        ; Score current line
        ; mov rsi, ???
        ; mov rdi, ???
        push rsi
        push rdi
        mov rdi, rax
        call score_line
        add r12, rax
        pop rdi
        pop rsi

        ; Print current line
        pop r9
        mov r8, rsi
        push rsi
        push rdi
        print r8, r9
        pop rdi
        pop rsi
        pop rdx

        ; Move to next line
        add rsi, r9
        sub rdi, r9

        dec rdx        ; Decrement line counter
        jmp .loop

.exit:
        push rsi
        push rdi
        mov rsi, r12
        call print_register
        pop rdi
        pop rsi
        ret


score_line:
        xor rax, rax
        call parse_game_id

        ; TODO: analyze line
.next:
        cmp rdi, 0
        je .done


        inc rdi
        jmp .next
.done:
        ret




; @param rsi - Address
; @param rdi - Length
; @returns 1 - allowed; 0 - not allowed
color_allowed:
        push rsi
        push rdi
        call parse_number
        pop rdi
        pop rsi
        push rax

        ; Move head of string
        push rsi
        push rdi
        call number_length
        pop rdi
        pop rsi

        mov r10, rax
        add rsi, r10
        sub rdi, r10

        call parse_maximum
        mov r9, rax

        pop r8
        cmp r8, r9        ; number > max(color)
        jg .fail

        mov rax, 1
        ret
.fail:
        mov rax, 0
        ret


; @param rsi - Address
; @param rdi - Length
parse_maximum:
        ; Reset registers
        xor         r8, r8
        xor         r9, r9
        xor         r10, r10
        xor         rax, rax

        ; Red
        push        rsi
        push        rdi
        mov         rdx, red
        mov         rcx, red_len
        push        r9
        call        parse_prefix
        pop         r9
        pop         rdi
        pop         rsi

        ; Compute length
        mov         r8, red_len
        imul        r8, rax
        add         r10, r8

        ; Compute value
        mov         r8, 12
        imul        r8, rax
        add         r9, r8

        ; Green
        push        rsi
        push        rdi
        mov         rdx, green
        mov         rcx, green_len
        push        r9
        call        parse_prefix
        pop         r9
        pop         rdi
        pop         rsi

        ; Compute length
        mov         r8, green_len
        imul        r8, rax
        add         r10, r8

        ; Compute value
        mov         r8, 13
        imul        r8, rax
        add         r9, r8

        ; Blue
        push        rsi
        push        rdi
        mov         rdx, blue
        mov         rcx, blue_len
        push        r9
        call        parse_prefix
        pop         r9
        pop         rdi
        pop         rsi

        ; Compute length
        mov         r8, blue_len
        imul        r8, rax
        add         r10, r8

        ; Compute value
        mov         r8, 14
        imul        r8, rax
        add         r9, r8

        ; Truncate str and set return
        add         rsi, r10
        sub         rdi, r10
        mov         rax, r9
        ret
        

; @param rsi - Address
; @param rdi - Length
parse_blue:
        mov rdx, blue
        mov rcx, blue_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
parse_red:
        mov rdx, red
        mov rcx, red_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
parse_green:
        mov rdx, green
        mov rcx, green_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
; @param rdx - Keyword
; @param rcx - Length
parse_color:
        push    rsi
        call    parse_number
        pop     r8             ; Restore str pointer
        push    rax            ; Save number
        cmp     rsi, r8        ; Check number parsed
        je      .fail

        push    rdx
        push    rcx
        call    parse_prefix
        pop     rcx
        pop     rdx
        cmp     rax, 0
        je      .fail

        pop     rax
        ret

.fail:
        pop     rax
        mov     rax, -1
        ret


; @param rsi - Address
; @param rdi - Length
parse_game_id:
        mov rdx, game
        mov rcx, game_len
        push rdi
        push rsi
        push rcx
        call parse_prefix
        pop rcx
        pop rsi
        pop rdi
        cmp rax, 1
        je .id
        mov rax, -1
        ret
.id:
        add rsi, rcx
        sub rdi, rcx
        call parse_number
        ret


; Parse a number and move string pointer
; @param rsi - Address
; @param rdi - Length
parse_number:
        push rsi
        push rdi
        call number_length
        pop rdi
        pop rsi
        push rax

        ; Accumulate number
        mov         r9, rax
        mov         r8, rsi
        xor         r10, r10
        mov         r11, 1

        ; Save str properties
        push        rsi
        push        rdi
.loop:
        cmp         r9, 0
        je .done

        lea         rsi, [r8 + r9 - 1] ; Address of next digit
        call        parse_digit
        imul        rax, r11   ; Multiply digit by 10**N
        add         r10, rax   ; Add to total
        imul        r11, 0x0a  ; Next power of 10
        dec         r9         ; Move pointer left
        jmp .loop
.done:
        pop         rdi        ; Length
        pop         rsi        ; Str pointer
        pop         rax        ; N digits
        add         rsi, rax   ; Move str pointer
        sub         rdi, rax   ; Reduce length
        mov         rax, r10   ; Mov value to return register
        ret


number_length:
        xor r8, r8
.next:
        cmp rdi, 0
        je .done

        call parse_digit
        cmp rax, -1
        je .done

        inc r8         ; Digit counter
        inc rsi        ; String
        dec rdi        ; Length
        jmp .next
.done:
        mov rax, r8
        ret



; @param rsi - Address
parse_digit:
        mov al, byte [rsi]

        cmp al, 48
        jl .fail

        cmp al, 57
        jg .fail

        sub al, 48
        ret

.fail:
        mov rax, -1
        ret


; Allocator
; @param rsi - size in bytes
; @returns rax - address of memory block
alloc:
        ; Get breakpoint address
        mov rax, SYS_brk
        mov rdi, 0
        syscall

        mov [heap_start], qword rax

        ; TODO: implement an allocation algorithm

        ; Increase breakpoint address
        lea rdi, [rax + rsi]
        mov rax, SYS_brk
        syscall

        mov [heap_end], qword rax

        ret


segment readable writable
input file "input-2"
input_len = $ - input

valid db "12 red"
valid_len = $ - valid
invalid db "13 red"
invalid_len = $ - invalid

example db "Game 64: 13 red, 1 blue, 1 green"
example_len = $ - example

game db "Game "
game_len = $ - game
red db " red"
red_len = $ - red
blue db " blue"
blue_len = $ - blue
green db " green"
green_len = $ - green

newline db 0x0a

; Allocator private data
heap_start dq 0
heap_end dq 0
