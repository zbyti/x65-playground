const

PLANE_MASK_TRANSPARENT        = %00000001;
PLANE_MASK_BORDER_TRANSPARENT = %00001000;
PLANE_MASK_DOUBLE_WIDTH       = %00010000;

//-------------------------------------

SCR_W       = 48;
SCR_H       = 30;
SCR_SIZE    = SCR_W * SCR_H;

MAX_X   = SCR_W shr 1;
MAX_Y   = SCR_H shr 1;

//-------------------------------------

{$i 'inc/scanners_addr.inc'}

DL: array [0..41] of byte = (             // Display List memory address
  $f3,                                    // LMS + LFS + LBS + LCG
  lo(LMS),hi(LMS),                        // Memory address for character data (first text row)
  lo(LFS),hi(LFS),                        // Memory address for character color data (first text row)
  lo(LBS),hi(LBS),                        // Memory address for background color data (first text row)
  lo(LCG),hi(LCG),                        // Character generator memory address (8x8 font)
  $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE4
  $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE4
  $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE4
  $82,lo(word(@DL)),hi(word(@DL))         // JMP to begin of DL and wait for Vertical BLank
);

//-------------------------------------

COL_WIHTE   = %11111111;
COL_BLACK   = %00000000;
COL_GROUND  = %01111001;

//-------------------------------------

JOY_UP      = %11111110;
JOY_DOWN    = %11111101;
JOY_LEFT    = %11111011;
JOY_RIGHT   = %11110111;
JOY_SPACE   = %11011111;

JOY_DELAY   = 7;

//-------------------------------------

TXT_INFO_1  = 'game x65'~;