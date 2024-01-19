format ELF64 executable


MAX_SEEDS = 20
MAX_MAP_SIZE = 256


include "util.inc"
include "parsers.asm"


segment readable executable
entry main
main:
        mov         r10, seeds        ; DEBUG: seeds
        call        load_seeds
        ; call        load_maps

        ; mov         rdi, 14
        ; call        seed_to_location
        int3
        exit        0


load_seeds:
        ;           Move to seeds: section
        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, seeds_label
        mov         rcx, seeds_label_len
        call        after_prefix

        ;           Load each seed
        mov         qword [seeds], 0
        xor         rcx, rcx
        jmp         .l2
.l1:
        ;           Parse seed
        push        rcx
        call        parse_number_safe
        pop         rcx
        int3
        mov         qword [seeds + rcx * 8 + 8], rax
        inc         qword [seeds]

        ;           Skip space
        inc         rdi
        dec         rsi

        ;           Index counter
        inc         rcx
.l2:
        push        rdi
        movzx       rdi, byte [rdi]
        call        is_digit
        pop         rdi
        cmp         rax, 1
        je          .l1

        ret


load_maps:
        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, seed_to_soil_label
        mov         rcx, seed_to_soil_label_len
        mov         r8, seed_to_soil_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, soil_to_fertilizer_label
        mov         rcx, soil_to_fertilizer_label_len
        mov         r8, soil_to_fertilizer_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, fertilizer_to_water_label
        mov         rcx, fertilizer_to_water_label_len
        mov         r8, fertilizer_to_water_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, water_to_light_label
        mov         rcx, water_to_light_label_len
        mov         r8, water_to_light_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, light_to_temperature_label
        mov         rcx, light_to_temperature_label_len
        mov         r8, light_to_temperature_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, temperature_to_humidity_label
        mov         rcx, temperature_to_humidity_label_len
        mov         r8, temperature_to_humidity_map
        call        load_map

        mov         rdi, input
        mov         rsi, input_len
        mov         rdx, humidity_to_location_label
        mov         rcx, humidity_to_location_label_len
        mov         r8, humidity_to_location_map
        call        load_map
        ret


; Load a map
;
; @param   {string} rdi - input string address
; @param   {int}    rsi - input string length
; @param   {string} rdx - label string address
; @param   {int}    rcx - label string length
; @param   {Map}    r8  - output memory address
; @returns {bool}   rax - flag indicating success
load_map:
        .str        equ rbp - 1 * 8
        .str_len    equ rbp - 2 * 8
        .label      equ rbp - 3 * 8
        .label_len  equ rbp - 4 * 8
        .map        equ rbp - 5 * 8
        .range      equ rbp - 6 * 8

        push        rbp
        mov         rbp, rsp
        sub         rsp, 6 * 8
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         qword [.label], rdx
        mov         qword [.label_len], rcx
        mov         qword [.map], r8

        ;           Pointer to Range[]
        add         r8, 8
        mov         qword [.range], r8

        ;           Move to start of Map data
        call        after_prefix
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi

        ;           Load range(s)
        mov         r8, qword [.map]
        mov         qword [r8], 0
        jmp         .l2
.l1:
        ;           Destination range start
        mov         rdi, qword [.str]
        mov         rsi, qword [.str_len]
        call        parse_number_safe
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         r8, qword [.range]
        mov         qword [r8], rax

        ;           Skip space
        inc         qword [.str]
        dec         qword [.str_len]

        ;           Source range start
        mov         rdi, qword [.str]
        mov         rsi, qword [.str_len]
        call        parse_number_safe
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         r8, qword [.range]
        mov         qword [r8 + 1 * 8], rax

        ;           Skip space
        inc         qword [.str]
        dec         qword [.str_len]

        ;           Range length
        mov         rdi, qword [.str]
        mov         rsi, qword [.str_len]
        call        parse_number_safe
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         r8, qword [.range]
        mov         qword [r8 + 2 * 8], rax

        ;           Skip newline
        inc         qword [.str]
        dec         qword [.str_len]

        ;           Increase Map length by 1
        mov         r8, qword [.map]
        inc         qword [r8]

        ;           Move Range pointer to next row
        add         qword [.range], 3 * 8
.l2:
        ;           Check next char is a digit
        mov         rdi, qword [.str]
        movzx       rdi, byte [rdi]
        call        is_digit
        cmp         rax, 1
        je          .l1

        mov         rsp, rbp
        pop         rbp
        ret


; Fast-forward to after prefix
;
; @param   {string} rdi - input string address
; @param   {int}    rsi - input string length
; @param   {string} rdx - prefix string address
; @param   {int}    rcx - prefix string length
after_prefix:
        .str     equ rbp - 1 * 8
        .str_len equ rbp - 2 * 8
        .pre     equ rbp - 3 * 8
        .pre_len equ rbp - 4 * 8

        push        rbp
        mov         rbp, rsp
        sub         rsp, 4 * 8
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         qword [.pre], rdx
        mov         qword [.pre_len], rcx

.l1:
        call        match_prefix
        cmp         rax, 1
        je          .found

        inc         rdi
        dec         rsi
        jmp         .l1

        ;           No match found, restore pointer(s)
        mov         rdi, qword [.str]
        mov         rsi, qword [.str_len]
        mov         rax, 0
.return:
        mov         rsp, rbp
        pop         rbp
        ret
.found:
        ;           Move pointer to after match
        add         rdi, qword [.pre_len]
        sub         rsi, qword [.pre_len]
        jmp         .return


match_prefix:
        .str     equ rbp - 1 * 8
        .str_len equ rbp - 2 * 8
        .pre     equ rbp - 3 * 8
        .pre_len equ rbp - 4 * 8

        push        rbp
        mov         rbp, rsp
        sub         rsp, 4 * 8
        mov         qword [.str], rdi
        mov         qword [.str_len], rsi
        mov         qword [.pre], rdx
        mov         qword [.pre_len], rcx

.l1:
        ;           End of prefix
        cmp         rcx, 0
        je          .found

        ;           End of string
        cmp         rsi, 0
        je          .fail

        ;           Compare bytes
        movzx       r8, byte [rdi]
        movzx       r9, byte [rdx]
        cmp         r8b, r9b
        jne         .fail

        ;           Next bytes
        inc         rdi
        dec         rsi
        inc         rdx
        dec         rcx
        jmp         .l1


.return:
        ;           Restore pointer(s)
        mov         rdi, qword [.str]
        mov         rsi, qword [.str_len]
        mov         rdx, qword [.pre]
        mov         rcx, qword [.pre_len]
        mov         rsp, rbp
        pop         rbp
        ret

.fail:
        mov         rax, 0
        jmp         .return

.found:
        mov         rax, 1
        jmp         .return


; @param rdi {string} - String address
; @param rsi {int}    - String length
parse_number_safe:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 4 * 8
        .str        equ rbp - 1 * 8
        .len        equ rbp - 2 * 8
        .i          equ rbp - 3 * 8
        .n          equ rbp - 4 * 8
        mov         qword [.str], rdi
        mov         qword [.len], rsi
        mov         qword [.i], 0
        mov         qword [.n], 0

        ;           Search left to right
        mov         rdx, qword [.str]
        mov         rcx, qword [.len]
.l1:
        cmp         rcx, 0
        je          .d2

        movzx       rdi, byte [rdx]
        call        is_digit
        cmp         al, 1
        jne         .d1

        inc         qword [.i]
        inc         rdx
        dec         rcx
        jmp         .l1
.d1:
        ;           Save length
        dec         qword [.i]
        mov         r8, qword [.i]
        mov         qword [.n], r8
        
        ;           Sum right to left
        xor         rax, rax
        xor         rcx, rcx
        mov         rdx, 1
.l2:
        cmp         qword [.i], 0
        jl          .d2

        mov         r8, qword [.str]
        add         r8, qword [.i]
        movzx       rdi, byte [r8]
        call        to_digit
        imul        rax, rdx        ; times power of 10
        add         rcx, rax        ; add to sum
        imul        rdx, 10

        dec         qword [.i]
        jmp         .l2
.d2:

        ;           Return value
        mov         rax, rcx

        ;           Align str to end of number
        inc         qword [.n]         ; TODO: understand why
        mov         rdi, qword [.str]
        add         rdi, qword [.n]
        mov         rsi, qword [.str_len]
        sub         rsi, qword [.n]

        mov         rsp, rbp
        pop         rbp
        ret


; @param rdi - ASCII character
is_digit:
        call       to_digit
        cmp        al, 9
        setna      al
        ret


; @param rdi - ASCII character [0-9]
to_digit:
        movzx      rax, dil
        sub        al, '0'
        ret


seed_to_location:
        call        seed_to_soil
        mov         rdi, rax
        call        soil_to_fertilizer
        mov         rdi, rax
        call        fertilizer_to_water
        mov         rdi, rax
        call        water_to_light
        mov         rdi, rax
        call        light_to_temperature
        mov         rdi, rax
        call        temperature_to_humidity
        mov         rdi, rax
        call        humidity_to_location
        ret


; @param {int}  rdi - Number
seed_to_soil:
        mov         rsi, seed_to_soil_map
        call        apply_map
        ret


; @param {int}  rdi - Number
soil_to_fertilizer:
        mov         rsi, soil_to_fertilizer_map
        call        apply_map
        ret

; @param {int}  rdi - Number
fertilizer_to_water:
        mov         rsi, fertilizer_to_water_map
        call        apply_map
        ret

; @param {int}  rdi - Number
water_to_light:
        mov         rsi, water_to_light_map
        call        apply_map
        ret

; @param {int}  rdi - Number
light_to_temperature:
        mov         rsi, light_to_temperature_map
        call        apply_map
        ret

; @param {int}  rdi - Number
temperature_to_humidity:
        mov         rsi, temperature_to_humidity_map
        call        apply_map
        ret

; @param {int}  rdi - Number
humidity_to_location:
        mov         rsi, humidity_to_location_map
        call        apply_map
        ret

; @param {int}  rdi - Number
; @param {*map} rsi - address of Map
apply_map:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 3 * 8
        .number equ rbp - 1 * 8
        .range  equ rbp - 2 * 8
        .length equ rbp - 3 * 8
        ;           Use the length of the Map to loop
        mov         qword [.number], rdi     ; Number
        mov         r8, qword [rsi]          ; Length of Map
        mov         qword [.length], r8      ; Length of Map
        add         rsi, 8
        mov         qword [.range], rsi      ; Range address

        mov         rcx, 0
.l1:
        ;           Range check
        mov         r8, qword [.range]       ; Range address
        mov         rdi, qword [.number]     ; Number
        mov         rsi, qword [r8 + 1 * 8]  ; Source range start
        mov         rdx, qword [r8 + 2 * 8]  ; Range length
        call        in_range
        cmp         al, 1
        je          .apply

        ;           Next range
        add         qword [.range], 24       ; Address += 24 bytes

        inc         rcx
        cmp         rcx, qword [.length]
        jb          .l1

        ;           Default case
        mov         rdi, qword [.number]     ; Number
        mov         rax, rdi                 ; Number

.return:
        mov         rsp, rbp
        pop         rbp
        ret

.apply:
        mov         r8, qword [.range]       ; Range address
        mov         rdi, qword [.number]     ; Number
        mov         rsi, qword [r8 + 8]      ; Source range start
        mov         rdx, qword [r8]          ; Destination range start
        call        apply_range
        jmp         .return



; Range start <= N < range start + length
;
; @param {int} rdi - number
; @param {int} rsi - source range start
; @param {int} rdx - range length
in_range:
        ;          range start <= N
        xor        rax, rax
        cmp        rdi, rsi
        setae      al

        ;          Number < range start + length
        xor        r8, r8
        add        rsi, rdx
        cmp        rdi, rsi
        setb       r8b

        ;          Range start <= N < range start + length
        and        al, r8b
        ret


; @param {int} rdi - number
; @param {int} rsi - source range start
; @param {int} rdx - destination range start
apply_range:
        mov        rax, rdi
        sub        rax, rsi
        add        rax, rdx
        ret


segment readable writable

seeds dq MAX_SEEDS
seeds_label db "seeds: "
seeds_label_len = $ - seeds_label

input file "example-5"  ; change to input-5 to solve puzzle
input_len = $ - input

; destination range start, source range start, range length
seed_to_soil_map rq MAX_MAP_SIZE
seed_to_soil_label db "seed-to-soil map:", 0xA
seed_to_soil_label_len = $ - seed_to_soil_label

soil_to_fertilizer_map rq MAX_MAP_SIZE
soil_to_fertilizer_label db "soil-to-fertilizer map:", 0xA
soil_to_fertilizer_label_len = $ - soil_to_fertilizer_label

fertilizer_to_water_map rq MAX_MAP_SIZE
fertilizer_to_water_label db "fertilizer-to-water map:", 0xA
fertilizer_to_water_label_len = $ - fertilizer_to_water_label

water_to_light_map rq MAX_MAP_SIZE
water_to_light_label db "water-to-light map:", 0xA
water_to_light_label_len = $ - water_to_light_label

light_to_temperature_map rq MAX_MAP_SIZE
light_to_temperature_label db "light-to-temperature map:", 0xA
light_to_temperature_label_len = $ - light_to_temperature_label

temperature_to_humidity_map rq MAX_MAP_SIZE
temperature_to_humidity_label db "temperature-to-humidity map:", 0xA
temperature_to_humidity_label_len = $ - temperature_to_humidity_label

humidity_to_location_map rq MAX_MAP_SIZE
humidity_to_location_label db "humidity-to-location map:", 0xA
humidity_to_location_label_len = $ - humidity_to_location_label
