format ELF64 executable


include "util.inc"
include "parsers.asm"


SYS_brk = 0x0c
NEWLINE = 0x0a


segment readable executable
entry main
main:
        ; Load puzzle input
        mov        rsi, input
        mov        rdi, input_len
        xor         r8, r8
        mov         r9, 100        ; Line count
.line:
        cmp         r9, 0
        je          .done
        
        ; solve line
        push        r8
        push        r9
        call        solution_2
        pop         r9
        pop         r8

        ; sum value
        add         r8, rax
        dec         r9
        jmp         .line

.done:
        mov         rsi, r8
        call        print_register


solution_2:
        ; Use reserved data to track red, green, blue minima
        mov        [minima + 0], 0
        mov        [minima + 1], 0
        mov        [minima + 2], 0

        ; Consume "Game N:" prefix
        call       parse_game_id

.next_draw:
        ; Break if end-of-file
        cmp         rdi, 0
        je          .done

        ; Break if end-of-line
        mov         r10b, [rsi]
        cmp         r10b, NEWLINE
        je          .newline

        ; Fast-forward to next number
        mov         rdx, parse_is_number
        call        parse_until

        ; Parse number and color
        call        parse_number
        push        rax

        ; Parse color index: red - 0, green - 1, blue - 2
        call        parse_color_index
        mov         r8, rax

        ; Save maximum of color
        pop         r9                ; number
        push        rsi               ; save address
        push        rdi               ; save length
        movzx       rsi, byte [minima + r8]
        mov         rdi, r9
        call        maximum
        mov         [minima + r8], byte al
        pop         rdi               ; restore length
        pop         rsi               ; restore address

        jmp         .next_draw

.newline:
        inc         rsi
        dec         rdi

.done:
        ; Multiply each minimum color together
        xor         r8, r8
        mov         rax, 1
        movzx       r8, byte [minima + 0]
        imul        rax, r8
        movzx       r8, byte [minima + 1]
        imul        rax, r8
        movzx       r8, byte [minima + 2]
        imul        rax, r8
        ret



parse_color_index:
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
        mov         r8, 0
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
        mov         r8, 1
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
        mov         r8, 2
        imul        r8, rax
        add         r9, r8

        ; Truncate str and set return
        add         rsi, r10
        sub         rdi, r10
        mov         rax, r9
        ret


; max(rsi, rdi) -> rax
maximum:
        cmp        rsi, rdi
        jg         .left
        mov        rax, rdi
        ret
.left:
        mov        rax, rsi
        ret


; Solution to Day 2 part 1
part_one:
        mov         rsi, input
        mov         rdi, input_len

        xor         r8, r8
        mov         r9, 100        ; Line count
.line:
        cmp         r9, 0
        je          .done
        
        ; solve line
        push        r8
        push        r9
        call        solution
        pop         r9
        pop         r8

        ; sum value
        add         r8, rax
        dec         r9
        jmp         .line

.done:
        mov         rsi, r8
        call        print_register


solution:
        call        parse_game_id
        push        rax
        mov         r8, 1              ; Set r8 to True
.next_draw:
        ; Break if end-of-file
        cmp         rdi, 0
        je          .done

        ; Break if end-of-line
        mov         r10b, [rsi]
        cmp         r10b, NEWLINE
        je          .newline

        ; Preserve r8 register
        push        r8

        ; Fast-forward to next number
        mov         rdx, parse_is_number
        call        parse_until

        ; Determine if draw is valid
        call        parse_valid

        ; Combine draw results
        pop         r8
        imul        r8, rax            ; Multiply by 1 or 0
        jmp         .next_draw

.newline:
        inc         rsi
        dec         rdi

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
        call parse_prefix
        ret


; @param rsi - Address
; @param rdi - Length
parse_red:
        mov rdx, red
        mov rcx, red_len
        call parse_prefix
        ret


; @param rsi - Address
; @param rdi - Length
parse_green:
        mov rdx, green
        mov rcx, green_len
        call parse_prefix
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


segment readable writable
input file "input-2"
input_len = $ - input

example db "Game 64: 12 red, 14 blue, 13 green; 5 red"
example_len = $ - example

; Minimum colors
minima rb 3        ; Reserve 4 bytes

; Helpful prefixes
game db "Game "
game_len = $ - game
red db " red"
red_len = $ - red
blue db " blue"
blue_len = $ - blue
green db " green"
green_len = $ - green
