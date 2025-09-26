program Sokoban;

//-----------------------------------------------------------------------------

{$librarypath 'lib'}

//-----------------------------------------------------------------------------

{$i 'inc/const.inc'}
{$i 'inc/registers.inc'}

//-----------------------------------------------------------------------------

var
  frame_counter    : byte absolute $ff;
  joy              : byte absolute $fe;
  moveTimer        : byte absolute $fd;

  tmp              : byte;

//-----------------------------------------------------------------------------

procedure vbl; assembler; interrupt; keep;
asm
  pha
  inc frame_counter
  mva GPIO_IN0 joy

  lda moveTimer
  beq *+4
  dec moveTimer
  pla

  sta CGIA_INT_STATUS
end;

//-----------------------------------------------------------------------------

procedure pause; assembler; overload; inline;
asm
  lda frame_counter
  cmp frame_counter
  beq *-2
end;

procedure pause(v: byte); assembler; register; overload;
asm
  lda v
  clc
  adc frame_counter
  cmp frame_counter
  bne *-2
end;

//-----------------------------------------------------------------------------

procedure Init;
begin

  asm
    sei       ; disable IRQ
    sec \ xce ; switch to emulation mode
    cld       ; turn off decimal mode
  end;

  CGIA_PLANES := 0;                        // disable all planes
  FillByte(pointer(CGIA_PLANE0), 10, 0);   // clear CGIA_PLANE0 registers

  CGIA_PLANE0_ROW_HEIGHT := 7;             // 8 rows per character
  CGIA_PLANE0_FLAGS := PLANE_MASK_DOUBLE_WIDTH;

  //CGIA_PLANE0_SHARED_COLOR1 := COL_BLACK;
  //CGIA_PLANE0_SHARED_COLOR2 := COL_WIHTE;

  FillByte(pointer(LMS), SCR_OFFSET, $20); // SPACE char code on C64
  FillByte(pointer(LFS), SCR_OFFSET, 0);   // foreground: black
  FillByte(pointer(LBS), SCR_OFFSET, 1);   // background: dark gray

  CGIA_OFFSET0 := word(@DL);               // point plane0 to DL
  CGIA_PLANES := 1;                        // activate plane0

  CGIA_INT_ENABLE := %10000000;            // trigger NMI on VBL
end;

//-----------------------------------------------------------------------------

begin
  Init;

  for tmp := 0 to 255 do begin
    poke(LMS + tmp, tmp);
    poke(LFS + tmp, tmp);
  end;

  repeat
    pause;

    if (joy <> %11111111) and (moveTimer = 0) then begin

      {
      if
        (joy = JOY_UP)   or
        (joy = JOY_DOWN) or
        (joy = JOY_LEFT) or
        (joy = JOY_RIGHT)
      then
        makeMove(joy);

        case joy of
          JOY_RIGHT and JOY_SPACE : begin end;
          JOY_LEFT  and JOY_SPACE : begin end;
        end;
      }

    end;

  until false;
end.

//-----------------------------------------------------------------------------