//=============================================================================
// Program: Hello World
// X65 Modern 8-bit Microcomputer: https://x65.zone/
// Retro Assembler: https://enginedesigns.net/retroassembler/
//=============================================================================

            .target "65816"
            .format "xex"
            .encoding "screencodeatari", "mixed"

            .setting "LaunchCommand", "x65 {0}"

//=============================================================================

/*
    plane flags:
    0   - color 0 is transparent
    1-3 - [RESERVED]
    4   - double-width pixel
    5-7 - [RESERVED]
*/
PLANE_MASK_TRANSPARENT        .equ 0b00000001
PLANE_MASK_BORDER_TRANSPARENT .equ 0b00001000
PLANE_MASK_DOUBLE_WIDTH       .equ 0b00010000

CGIA_RASTER                   .equ $FF10
CGIA_PLANES                   .equ $FF30 ; [TTTTEEEE] EEEE - enable bits, TTTT - type (0 bckgnd, 1 sprite)
CGIA_BACK_COLOR               .equ $FF31
CGIA_OFFSET0                  .equ $FF38 ; 2 bytes
CGIA_OFFSET1                  .equ $FF3A ; 2 bytes
CGIA_OFFSET2                  .equ $FF3C ; 2 bytes
CGIA_OFFSET3                  .equ $FF3E ; 2 bytes
CGIA_PLANE0_FLAGS             .equ $FF40 ; R00
CGIA_PLANE0_BORDER_COLUMNS    .equ $FF41 ; R01
CGIA_PLANE0_ROW_HEIGHT        .equ $FF42 ; R02
CGIA_PLANE0_STRIDE            .equ $FF43 ; R03
CGIA_PLANE0_SCROLL_X          .equ $FF44 ; R04
CGIA_PLANE0_OFFSET_X          .equ $FF45 ; R05
CGIA_PLANE0_SCROLL_Y          .equ $FF46 ; R06
CGIA_PLANE0_OFFSET_Y          .equ $FF47 ; R07
CGIA_PLANE0_SHARED_COLOR1     .equ $FF48 ; R08
CGIA_PLANE0_SHARED_COLOR2     .equ $FF49 ; R09

//-----------------------------------------------------------------------------

LMS         .equ $4000     ; Memory address for character data (first text row)
LFS         .equ $5000     ; Memory address for character color data (first text row)
LBS         .equ $6000     ; Memory address for background color data (first text row)
LCG         .equ $a000     ; Character generator memory address (8x8 font, font file must include a header)
DL          .equ $b000     ; Display List memory address

BG_COLOR    .equ 145
FG_COLOR    .equ 150

//=============================================================================

            .segment "VECTORS"
            .org $FFE0
            .w 0, 0, 0, 0, 0, 0, 0, 0
            .w 0, 0, 0, 0, 0, 0, start, 0

//-----------------------------------------------------------------------------

            .segment "FONTS"
            .org LCG
            .incbin "data/amstrad.fnt" auto

//-----------------------------------------------------------------------------

            .data
            .org DL
            .b %11110011           ; LMS + LFS + LBS + LCG
            .w LMS, LFS, LBS, LCG
            .storage 30, $a        ; 30x MODE2
            .b %10000010           ; JMP to begin of DL and wait for Vertical BLank
            .w DL

//-----------------------------------------------------------------------------

            .segment "TEXT_HELLO"
            .org LMS
            .t "Hello world"

            .segment "TEXT_COLOR"
            .org LFS
            .storage 20, FG_COLOR

//=============================================================================
// MAIN segment of code
//=============================================================================

            .code
            .org $0200

//-----------------------------------------------------------------------------

start       sei                                 ; disable IRQ
            nat_mode()                          ; switch to native mode

            a8()
            sav(0, CGIA_PLANES)                 ; disable all planes, so CGIA does not go haywire during reconfiguration
            sav(0, CGIA_PLANE0_FLAGS)
            sav(0, CGIA_PLANE0_BORDER_COLUMNS)
            sav(7, CGIA_PLANE0_ROW_HEIGHT)      ; 8 rows per character
            sav(0, CGIA_PLANE0_STRIDE)
            sav(0, CGIA_PLANE0_SCROLL_X)
            sav(0, CGIA_PLANE0_OFFSET_X)
            sav(0, CGIA_PLANE0_SCROLL_Y)
            sav(0, CGIA_PLANE0_OFFSET_Y)
            sav(0, CGIA_PLANE0_SHARED_COLOR1)
            sav(0, CGIA_PLANE0_SHARED_COLOR2)

            a16()
            sav(DL, CGIA_OFFSET0)               ; point plane0 to DL

            a8()
            sav(%00000001, CGIA_PLANES)         ; activate plane0

            jmp *

//=============================================================================
// Macros
//=============================================================================

        .macro emu_mode()
            sec
            xce             ; switch to emulation mode
        .endmacro

//-----------------------------------------------------------------------------

        .macro nat_mode()
            clc
            xce             ; switch to native mode
        .endmacro

//-----------------------------------------------------------------------------

        .macro a8()
            sep #%00100000  ; 8-bit accumulator
        .endmacro

//-----------------------------------------------------------------------------

        .macro a16()
            rep #%00100000  ; 16-bit accumulator
        .endmacro

//-----------------------------------------------------------------------------

        .macro i8()
            sep #%00010000  ; 8-bit index
        .endmacro

//-----------------------------------------------------------------------------

        .macro i16()
            rep #%00010000  ; 16-bit index
        .endmacro

//-----------------------------------------------------------------------------

        .macro sav(val, mem)
            lda #val
            sta mem
        .endmacro

//=============================================================================