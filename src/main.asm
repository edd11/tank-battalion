;===========================================================================
; TANK BATTALION - Sega SG-1000 Clone
; TASM x86 Real Mode for DOS/VGA Mode 13h
;===========================================================================
    .MODEL small
    .STACK 200h

;===========================================================================
; DATA SEGMENT
;===========================================================================
    .DATA

;----- GAME FEEL VARIABLES (Tunable speeds) -----
PLAYER_SPEED        dw 4
PLAYER_SHOT_DELAY   dw 2
BULLET_SPEED        dw 1
ENEMY_SPEED_NORMAL  dw 6
ENEMY_SPEED_FAST    dw 3
ENEMY_SPEED_HEAVY   dw 6
ENEMY_SPEED_RAINBOW dw 6
BULLET_SPEED_ENEMY  dw 2
BULLET_SPEED_FAST   dw 1
WALL_CRUMBLE_TIME   dw 70

;----- GAME STATE -----
GAME_STATE          db 0
CURRENT_LEVEL       db 1
LIVES               db 3
SCORE               dw 0
SCORE_EXTRA_LIFE    dw 0
HI_SCORE            dw 20000
ENEMIES_REMAINING   db 20
DIFFICULTY          db 0
FRAME_COUNTER       dw 0
TITLE_FLASH_TIMER   dw 0
TITLE_FLASH_STATE   db 0
GAME_OVER_TIMER     dw 0

;----- MAP ARRAY (13x12 = 156 bytes) -----
MAP_ARRAY           db 156 dup(0)

;----- WALL TIMERS -----
WALL_TIMER_COUNT    dw 0
WALL_TIMER_X        db 8 dup(0)
WALL_TIMER_Y        db 8 dup(0)
WALL_TIMER_TICKS    dw 8 dup(0)

;----- PLAYER ENTITY -----
PLAYER_GRID_X       db 4
PLAYER_GRID_Y       db 11
PLAYER_PIXEL_X      dw 64
PLAYER_PIXEL_Y      dw 184
PLAYER_DIR          db 0
PLAYER_COOLDOWN     dw 0
PLAYER_POWERUP      db 0
PLAYER_MAX_BULLETS  db 1
PLAYER_BULLET_COUNT db 0
PLAYER_LAST_DIR     db 0
PLAYER_HP           db 1
PLAYER_ALIVE        db 1

;----- EFFIGY -----
EFFIGY_GRID_X       db 6
EFFIGY_GRID_Y       db 11
EFFIGY_ALIVE        db 1

;----- ENEMY ENTITIES (Max 4 on screen) -----
MAX_ENEMIES         EQU 4
ENEMY_ACTIVE        db MAX_ENEMIES dup(0)
ENEMY_GRID_X        db MAX_ENEMIES dup(0)
ENEMY_GRID_Y        db MAX_ENEMIES dup(0)
ENEMY_PIXEL_X       dw MAX_ENEMIES dup(0)
ENEMY_PIXEL_Y       dw MAX_ENEMIES dup(0)
ENEMY_TYPE          db MAX_ENEMIES dup(0)
ENEMY_DIR           db MAX_ENEMIES dup(0)
ENEMY_COOLDOWN      dw MAX_ENEMIES dup(0)
ENEMY_HP            db MAX_ENEMIES dup(0)
ENEMY_LAST_DIR      db MAX_ENEMIES dup(0)
ENEMY_PREFERS       db MAX_ENEMIES dup(0)
ENEMY_BULLET_COUNT  db MAX_ENEMIES dup(0)
ENEMY_SPAWN_TICKS   dw 0
ENEMY_SPAWN_DELAY   dw 90
ENEMIES_SPAWNED     db 0
ENEMY_POOL_FROZEN   db 0

;----- BULLETS (Max 8 on screen) -----
MAX_BULLETS         EQU 8
BULLET_ACTIVE       db MAX_BULLETS dup(0)
BULLET_GRID_X       db MAX_BULLETS dup(0)
BULLET_GRID_Y       db MAX_BULLETS dup(0)
BULLET_PIXEL_X      dw MAX_BULLETS dup(0)
BULLET_PIXEL_Y      dw MAX_BULLETS dup(0)
BULLET_DIR          db MAX_BULLETS dup(0)
BULLET_OWNER        db MAX_BULLETS dup(0)
BULLET_COOLDOWN     dw MAX_BULLETS dup(0)

;----- KEYBOARD STATE -----
KEY_UP              db 0
KEY_DOWN            db 0
KEY_LEFT            db 0
KEY_RIGHT           db 0
KEY_SPACE           db 0
KEY_ENTER           db 0
KEY_ESC             db 0
OLD_INT09           dd 0

;----- RNG -----
RANDOM_SEED         db 42

;----- HUD TEXT BUFFERS -----
STR_HISCORE         db "HI-SCORE", 0
STR_SCORE           db "SCORE", 0
STR_LEVEL           db "LEVEL", 0
STR_LIVES           db "LIVES", 0
STR_ENEMIES         db "ENEMIES", 0
STR_PRESS_START     db "PRESS START", 0
STR_GAME_OVER       db "GAME OVER", 0
STR_PAUSED          db "PAUSED", 0
NUM_BUFFER          db 6 dup(0)
NUM_BUFFER_END      db 0

;----- TEMP VARIABLES -----
TEMP_X              dw 0
TEMP_Y              dw 0
TEMP_BYTE           db 0
TEMP_WORD           dw 0

;===========================================================================
; SPRITE DATA (16x16 pixels = 256 bytes each)
;===========================================================================

SPRITE_BLACK:
    db 256 dup(0)

SPRITE_PLAYER_UP:
    db 0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,2,10,10,2,0,0,0,0,0,0
    db 0,0,0,0,0,0,2,10,10,2,0,0,0,0,0,0
    db 0,0,0,0,0,2,2,10,10,2,2,0,0,0,0,0
    db 0,0,0,0,0,2,10,10,10,10,2,0,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,2,10,10,10,10,10,10,10,10,2,0,0,0
    db 0,0,0,2,10,10,10,10,10,10,10,10,2,0,0,0
    db 0,0,2,10,10,10,10,10,10,10,10,10,10,2,0,0
    db 0,0,2,10,10,10,10,10,10,10,10,10,10,2,0,0

SPRITE_PLAYER_DOWN:
    db 0,0,2,10,10,10,10,10,10,10,10,10,10,2,0,0
    db 0,0,2,10,10,10,10,10,10,10,10,10,10,2,0,0
    db 0,0,0,2,10,10,10,10,10,10,10,10,2,0,0,0
    db 0,0,0,2,10,10,10,10,10,10,10,10,2,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,2,10,10,10,10,10,10,2,0,0,0,0
    db 0,0,0,0,0,2,10,10,10,10,2,0,0,0,0,0
    db 0,0,0,0,0,2,2,10,10,2,2,0,0,0,0,0
    db 0,0,0,0,0,0,2,10,10,2,0,0,0,0,0,0
    db 0,0,0,0,0,0,2,10,10,2,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0

SPRITE_PLAYER_LEFT:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,2,10,10,2,2,2,2,2,2,2,2,2,2,0,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 2,10,10,10,10,10,10,10,10,10,10,10,10,10,2,0
    db 0,2,10,10,2,2,2,2,2,2,2,2,2,2,0,0
    db 0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SPRITE_PLAYER_RIGHT:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0
    db 0,0,2,2,2,2,2,2,2,2,2,2,10,10,2,0
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,2,10,10,10,10,10,10,10,10,10,10,10,10,10,2
    db 0,0,2,2,2,2,2,2,2,2,2,2,10,10,2,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SPRITE_ENEMY_NORMAL:
    db 0,0,0,0,0,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,1,1,1,1,1,1,9,9,0,0,0
    db 0,0,9,1,1,1,1,1,1,1,1,1,1,9,0,0
    db 0,9,1,1,1,15,15,15,15,15,15,1,1,1,9,0
    db 0,9,1,1,15,9,9,9,9,9,9,15,1,1,9,0
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 9,1,1,15,9,9,9,9,9,9,9,9,15,1,1,9
    db 0,9,1,1,15,9,9,9,9,9,9,15,1,1,9,0
    db 0,9,1,1,1,15,15,15,15,15,15,1,1,1,9,0
    db 0,0,9,1,1,1,9,9,9,9,1,1,1,9,0,0
    db 0,0,0,9,9,1,1,1,1,1,1,9,9,0,0,0
    db 0,0,0,0,0,9,9,9,9,9,9,0,0,0,0,0

SPRITE_ENEMY_FAST:
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0
    db 0,0,0,12,12,4,4,4,4,4,4,12,12,0,0,0
    db 0,0,12,4,4,4,4,4,4,4,4,4,4,12,0,0
    db 0,12,4,4,4,15,15,15,15,15,15,4,4,4,12,0
    db 0,12,4,4,15,12,12,12,12,12,12,15,4,4,12,0
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 0,12,4,4,15,12,12,12,12,12,12,15,4,4,12,0
    db 0,12,4,4,4,15,15,15,15,15,15,4,4,4,12,0
    db 0,0,12,4,4,4,4,4,4,4,4,4,4,12,0,0
    db 0,0,0,12,12,4,4,4,4,4,4,12,12,0,0,0
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0

SPRITE_ENEMY_FAST_DMG:
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0
    db 0,0,0,13,13,5,5,5,5,5,5,13,13,0,0,0
    db 0,0,13,5,5,5,5,5,5,5,5,5,5,13,0,0
    db 0,13,5,5,5,15,15,15,15,15,15,5,5,5,13,0
    db 0,13,5,5,15,13,13,13,13,13,13,15,5,5,13,0
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 0,13,5,5,15,13,13,13,13,13,13,15,5,5,13,0
    db 0,13,5,5,5,15,15,15,15,15,15,5,5,5,13,0
    db 0,0,13,5,5,5,5,5,5,5,5,5,5,13,0,0
    db 0,0,0,13,13,5,5,5,5,5,5,13,13,0,0,0
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0

SPRITE_ENEMY_RAINBOW:
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
    db 0,0,0,14,14,12,12,12,12,12,12,14,14,0,0,0
    db 0,0,14,12,12,9,9,9,9,9,9,12,12,14,0,0
    db 0,14,12,12,9,10,10,10,10,10,10,9,12,12,14,0
    db 0,14,12,9,10,15,15,15,15,15,15,10,9,12,14,0
    db 14,12,9,10,15,14,14,14,14,14,14,15,10,9,12,14
    db 14,12,9,10,15,14,14,14,14,14,14,15,10,9,12,14
    db 14,12,9,10,15,14,14,14,14,14,14,15,10,9,12,14
    db 14,12,9,10,15,14,14,14,14,14,14,15,10,9,12,14
    db 14,12,9,10,15,14,14,14,14,14,14,15,10,9,12,14
    db 0,14,12,9,10,15,14,14,14,14,14,15,10,9,12,14
    db 0,14,12,12,9,10,10,10,10,10,10,9,12,12,14,0
    db 0,0,14,12,12,9,9,9,9,9,9,12,12,14,0,0
    db 0,0,0,14,14,12,12,12,12,12,12,14,14,0,0,0
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0

SPRITE_ENEMY_HEAVY:
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
    db 0,0,0,14,14,6,6,6,6,6,6,14,14,0,0,0
    db 0,0,14,6,6,6,6,6,6,6,6,6,6,14,0,0
    db 0,14,6,6,6,15,15,15,15,15,15,6,6,6,14,0
    db 0,14,6,6,15,14,14,14,14,14,14,15,6,6,14,0
    db 14,6,6,15,14,14,14,14,14,14,14,14,15,6,6,14
    db 14,6,6,15,14,14,14,14,14,14,14,14,15,6,6,14
    db 14,6,6,15,14,14,14,14,14,14,14,14,15,6,6,14
    db 14,6,6,15,14,14,14,14,14,14,14,14,15,6,6,14
    db 14,6,6,15,14,14,14,14,14,14,14,14,15,6,6,14
    db 0,14,6,6,15,14,14,14,14,14,14,15,6,6,14,0
    db 0,14,6,6,6,15,15,15,15,15,15,6,6,6,14,0
    db 0,0,14,6,6,6,6,6,6,6,6,6,6,14,0,0
    db 0,0,0,14,14,6,6,6,6,6,6,14,14,0,0,0
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
    db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0

SPRITE_ENEMY_HEAVY_D1:
    db 0,0,0,0,0,7,7,7,7,7,7,0,0,0,0,0
    db 0,0,0,7,7,6,6,6,6,6,6,7,7,0,0,0
    db 0,0,7,6,6,6,6,6,6,6,6,6,6,7,0,0
    db 0,7,6,6,6,15,15,15,15,15,15,6,6,6,7,0
    db 0,7,6,6,15,7,7,7,7,7,7,15,6,6,7,0
    db 7,6,6,15,7,7,7,7,7,7,7,7,15,6,6,7
    db 7,6,6,15,7,7,7,7,7,7,7,7,15,6,6,7
    db 7,6,6,15,7,7,7,7,7,7,7,7,15,6,6,7
    db 7,6,6,15,7,7,7,7,7,7,7,7,15,6,6,7
    db 7,6,6,15,7,7,7,7,7,7,7,7,15,6,6,7
    db 0,7,6,6,15,7,7,7,7,7,7,15,6,6,7,0
    db 0,7,6,6,6,15,15,15,15,15,15,6,6,6,7,0
    db 0,0,7,6,6,6,6,6,6,6,6,6,6,7,0,0
    db 0,0,0,7,7,6,6,6,6,6,6,7,7,0,0,0
    db 0,0,0,0,0,7,7,7,7,7,7,0,0,0,0,0
    db 0,0,0,0,0,7,7,7,7,7,7,0,0,0,0,0

SPRITE_ENEMY_HEAVY_D2:
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0
    db 0,0,0,12,12,4,4,4,4,4,4,12,12,0,0,0
    db 0,0,12,4,4,4,4,4,4,4,4,4,4,12,0,0
    db 0,12,4,4,4,15,15,15,15,15,15,4,4,4,12,0
    db 0,12,4,4,15,12,12,12,12,12,12,15,4,4,12,0
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 12,4,4,15,12,12,12,12,12,12,12,12,15,4,4,12
    db 0,12,4,4,15,12,12,12,12,12,12,15,4,4,12,0
    db 0,12,4,4,4,15,15,15,15,15,15,4,4,4,12,0
    db 0,0,12,4,4,4,4,4,4,4,4,4,4,12,0,0
    db 0,0,0,12,12,4,4,4,4,4,4,12,12,0,0,0
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0
    db 0,0,0,0,0,12,12,12,12,12,12,0,0,0,0,0

SPRITE_ENEMY_HEAVY_D3:
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0
    db 0,0,0,13,13,5,5,5,5,5,5,13,13,0,0,0
    db 0,0,13,5,5,5,5,5,5,5,5,5,5,13,0,0
    db 0,13,5,5,5,15,15,15,15,15,15,5,5,5,13,0
    db 0,13,5,5,15,13,13,13,13,13,13,15,5,5,13,0
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 13,5,5,15,13,13,13,13,13,13,13,13,15,5,5,13
    db 0,13,5,5,15,13,13,13,13,13,13,15,5,5,13,0
    db 0,13,5,5,5,15,15,15,15,15,15,5,5,5,13,0
    db 0,0,13,5,5,5,5,5,5,5,5,5,5,13,0,0
    db 0,0,0,13,13,5,5,5,5,5,5,13,13,0,0,0
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0
    db 0,0,0,0,0,13,13,13,13,13,13,0,0,0,0,0

SPRITE_WALL:
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,8,8,6,8,8,6,8,6,8,8,6,8,6,6
    db 6,6,8,8,6,8,8,6,8,6,8,8,6,8,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,8,8,6,8,8,8,8,6,8,8,6,8,6,6
    db 6,6,8,8,6,8,8,8,8,6,8,8,6,8,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,8,8,6,8,6,6,8,6,8,8,6,8,6,6
    db 6,6,8,8,6,8,6,6,8,6,8,8,6,8,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6

SPRITE_WALL_CRUMBLE:
    db 6,6,0,6,6,6,0,6,6,6,0,6,6,6,0,6
    db 6,0,6,6,0,6,6,0,6,6,6,0,6,6,6,6
    db 6,8,8,6,8,8,6,8,6,8,8,6,8,6,6,6
    db 6,8,8,6,8,8,6,8,6,8,8,6,8,6,6,6
    db 6,6,6,6,0,6,6,6,0,6,6,6,6,0,6,6
    db 0,6,6,6,6,6,6,0,6,6,6,6,6,6,6,0
    db 6,6,8,8,6,8,8,8,8,6,8,8,6,8,6,6
    db 6,6,8,8,6,8,8,8,8,6,8,8,6,8,6,6
    db 6,0,6,6,6,6,6,6,0,6,6,6,6,6,0,6
    db 6,6,6,0,6,6,6,6,6,6,0,6,6,6,6,6
    db 6,8,8,6,8,6,6,8,6,8,8,6,8,0,6,6
    db 6,8,8,6,8,6,6,8,6,8,8,6,8,0,6,6
    db 6,6,6,6,6,0,6,6,0,6,6,6,6,6,6,6
    db 0,6,6,6,6,6,6,6,6,6,6,0,6,6,6,0
    db 6,6,0,6,6,6,0,6,6,6,0,6,6,6,6,6
    db 6,6,6,6,0,6,6,6,6,6,6,6,0,6,6,6

SPRITE_BULLET:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,15,15,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0
    db 0,0,0,0,0,15,15,15,15,15,15,0,0,0,0,0
    db 0,0,0,0,0,15,15,15,15,15,15,0,0,0,0,0
    db 0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,15,15,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SPRITE_EFFIGY:
    db 0,0,0,0,6,6,6,6,6,6,0,0,0,0,0,0
    db 0,0,0,6,6,14,14,14,14,6,6,0,0,0,0,0
    db 0,0,6,6,14,14,14,14,14,14,6,6,0,0,0,0
    db 0,0,6,14,14,15,15,15,15,14,14,6,0,0,0,0
    db 0,6,6,14,15,15,15,15,15,15,14,6,6,0,0,0
    db 0,6,14,14,15,15,14,14,15,15,14,14,6,0,0,0
    db 0,6,14,14,15,14,14,14,14,15,14,14,6,0,0,0
    db 0,6,14,14,15,14,14,14,14,15,14,14,6,0,0,0
    db 0,6,6,14,15,15,15,15,15,15,14,6,6,0,0,0
    db 0,6,14,14,14,14,14,14,14,14,14,14,6,0,0,0
    db 6,6,6,6,14,14,14,14,14,14,6,6,6,6,0,0
    db 6,6,6,6,6,14,14,14,14,6,6,6,6,6,0,0
    db 6,6,6,6,6,6,14,14,6,6,6,6,6,6,0,0
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0
    db 6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0

SPRITE_LIFE_ICON:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,10,10,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,10,10,10,10,0,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,0,10,10,10,10,10,10,0,0,0,0,0,0
    db 0,0,0,10,10,10,10,10,10,10,10,0,0,0,0,0
    db 0,0,0,10,10,10,10,10,10,10,10,0,0,0,0,0
    db 0,0,10,10,10,10,10,10,10,10,10,10,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SPRITE_ENEMY_ICON:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,9,9,9,9,0,0,0,0,0,0,0
    db 0,0,0,0,9,9,9,9,9,9,0,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0
    db 0,0,9,9,9,9,9,9,9,9,9,9,0,0,0,0
    db 0,0,9,9,9,9,9,9,9,9,9,9,0,0,0,0
    db 0,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;===========================================================================
; 8x8 BITMAP FONT DATA (64 bytes each)
;===========================================================================

FONT_0: db 0,15,15,15,15,15,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,15,15,0,15,0,0,15,0,0,15,0
        db 15,15,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0

FONT_1: db 0,0,15,15,0,0,0,0,0,15,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_2: db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 0,0,0,0,0,0,15,0,0,0,0,0,15,15,0,0
        db 0,0,15,15,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0

FONT_3: db 0,15,15,15,15,15,0,0,15,0,0,0,0,15,0,0
        db 0,0,0,15,15,0,0,0,15,0,0,0,0,15,0,0
        db 15,0,0,0,0,0,15,0,0,15,15,15,15,15,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_4: db 0,0,0,0,15,15,0,0,0,0,0,15,0,15,0,0
        db 0,0,15,0,0,15,0,0,15,0,0,0,0,15,0,0
        db 15,15,15,15,15,15,15,0,0,0,0,0,0,15,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_5: db 15,15,15,15,15,15,15,0,15,0,0,0,0,0,0,0
        db 15,15,15,15,15,15,0,0,0,0,0,0,0,0,15,0
        db 0,0,0,0,0,0,15,0,15,15,15,15,15,15,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_6: db 0,0,15,15,15,15,0,0,0,15,0,0,0,0,15,0
        db 15,0,0,0,0,0,0,0,15,15,15,15,15,15,0,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_7: db 15,15,15,15,15,15,15,0,0,0,0,0,0,0,15,0
        db 0,0,0,0,0,15,0,0,0,0,0,15,0,0,0,0
        db 0,0,15,0,0,0,0,0,0,0,15,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_8: db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_9: db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,0,15,15,15,15,15,15,0
        db 0,0,0,0,0,0,15,0,0,15,0,0,0,0,15,0
        db 0,0,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_A: db 0,0,15,15,15,15,0,0,0,15,0,0,0,0,15,0
        db 0,15,0,0,0,0,15,0,15,15,15,15,15,15,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0

FONT_C: db 0,0,15,15,15,15,0,0,0,15,0,0,0,0,15,0
        db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,0,0,0,0,0,0,0,0,15,0,0,0,0,15,0
        db 0,0,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_D: db 15,15,15,15,15,0,0,0,15,0,0,0,0,15,0,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,15,0,0
        db 15,15,15,15,15,0,0,0,0,0,0,0,0,0,0,0

FONT_E: db 15,15,15,15,15,15,15,0,15,0,0,0,0,0,0,0
        db 15,15,15,15,15,0,0,0,15,0,0,0,0,0,0,0
        db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0

FONT_G: db 0,0,15,15,15,15,0,0,0,15,0,0,0,0,15,0
        db 15,0,0,0,0,0,0,0,15,0,0,15,15,15,15,0
        db 15,0,0,0,0,0,15,0,0,15,0,0,0,0,15,0
        db 0,0,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_H: db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,15,15,15,15,15,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0

FONT_I: db 0,15,15,15,15,15,0,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_L: db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0

FONT_M: db 15,0,0,0,0,0,15,0,15,15,0,0,0,15,15,0
        db 15,0,15,0,15,0,15,0,15,0,0,15,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0

FONT_N: db 15,0,0,0,0,15,0,0,15,15,0,0,0,15,0,0
        db 15,0,15,0,0,15,0,0,15,0,0,15,0,15,0,0
        db 15,0,0,15,0,15,0,0,15,0,0,0,15,15,0,0
        db 15,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0

FONT_O: db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_P: db 15,15,15,15,15,0,0,0,15,0,0,0,0,15,0,0
        db 15,0,0,0,0,15,0,0,15,15,15,15,15,0,0,0
        db 15,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
        db 15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_R: db 15,15,15,15,15,0,0,0,15,0,0,0,0,15,0,0
        db 15,0,0,0,0,15,0,0,15,15,15,15,15,0,0,0
        db 15,0,0,15,0,0,0,0,15,0,0,0,15,0,0,0
        db 15,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0

FONT_S: db 0,15,15,15,15,15,0,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,0,0,0,0,0,0,0,0,15,0,0
        db 0,0,0,0,0,15,0,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_T: db 15,15,15,15,15,15,15,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0,0
        db 0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0

FONT_U: db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 0,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0

FONT_V: db 15,0,0,0,0,0,15,0,15,0,0,0,0,0,15,0
        db 15,0,0,0,0,0,15,0,0,15,0,0,0,15,0,0
        db 0,15,0,0,0,15,0,0,0,0,15,15,15,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_X: db 15,0,0,0,0,0,15,0,0,15,0,0,0,15,0,0
        db 0,0,15,0,15,0,0,0,0,0,0,15,0,0,0,0
        db 0,0,15,0,15,0,0,0,0,15,0,0,0,15,0,0
        db 15,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0

FONT_MINUS: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 15,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FONT_TABLE:
    dw FONT_0, FONT_1, FONT_2, FONT_3, FONT_4
    dw FONT_5, FONT_6, FONT_7, FONT_8, FONT_9
    dw FONT_A, 0, FONT_C, FONT_D, FONT_E, 0
    dw FONT_G, FONT_H, FONT_I, 0, 0, FONT_L
    dw FONT_M, FONT_N, FONT_O, FONT_P, 0, FONT_R
    dw FONT_S, FONT_T, FONT_U, FONT_V, 0, FONT_X
    dw 0, 0

;===========================================================================
; LEVEL DATA (8 levels, 156 bytes each)
;===========================================================================

LEVEL_1_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,01,00,01,00,01,00,01,01,00,00
    db 00,00,00,01,00,01,00,01,00,01,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,01,01,01,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,01,01,01,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_2_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,00,00,01,00,01,00,00,00,00,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,00,00,00,01,00,01,00,00,00,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_3_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,01,01,01,00,01,01,01,01,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,01,01,01,00,00,00,00,00
    db 00,00,00,00,00,01,00,01,00,00,00,00,00
    db 00,00,00,00,00,01,00,01,00,00,00,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_4_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,01,00,00,00,00,00,00,00,01,01,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,00,00,01,01,00,01,01,00,00,00,00
    db 00,00,00,01,00,00,00,00,00,01,00,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,00,01,00,00,00,00,00,01,00,00,00
    db 00,00,00,00,01,01,00,01,01,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,01,00,00,00,00,00,00,00,01,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_5_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,00,01,00,01,00,01,00,01,00,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 01,00,01,00,01,00,01,00,01,00,01,00,01
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 01,00,01,00,01,00,01,00,01,00,01,00,01
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,00,01,00,01,00,01,00,01,00,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_6_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,01,01,01,01,01,01,01,01,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,01,00,01,01,01,01,01,00,01,00,00
    db 00,00,01,00,01,00,00,00,01,00,01,00,00
    db 00,00,01,00,01,00,01,00,01,00,01,00,00
    db 00,00,01,00,01,00,00,00,01,00,01,00,00
    db 00,00,01,00,01,01,01,01,01,00,01,00,00
    db 00,00,01,00,00,00,00,00,00,00,01,00,00
    db 00,00,01,01,01,01,01,01,01,01,01,00,00
    db 00,00,01,01,01,01,01,01,01,01,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_7_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,01,01,00,00,01,00,00,01,01,00,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,01,01,01,01,01,01,01,01,01,01,01,00
    db 00,01,01,01,01,01,01,01,01,01,01,01,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,00,00,00,00,01,00,00,00,00,00,00
    db 00,00,01,01,00,00,01,00,00,01,01,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_8_DATA:
    db 00,00,00,00,00,00,00,00,00,00,00,00,00
    db 00,01,01,01,01,01,01,01,01,01,01,01,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,01,00,01,01,00,00,00,01,01,00,01,00
    db 00,01,00,01,00,00,00,00,00,01,00,01,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,01,00,00,00,00,01,00,00,00,00,01,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,01,00,01,00,00,00,00,00,01,00,01,00
    db 00,01,00,01,01,00,00,00,01,01,00,01,00
    db 00,01,00,00,00,00,00,00,00,00,00,01,00
    db 00,00,00,00,00,00,00,00,00,00,00,00,00

LEVEL_OFFSETS:
    dw LEVEL_1_DATA
    dw LEVEL_2_DATA
    dw LEVEL_3_DATA
    dw LEVEL_4_DATA
    dw LEVEL_5_DATA
    dw LEVEL_6_DATA
    dw LEVEL_7_DATA
    dw LEVEL_8_DATA

GRID_Y_MULT:
    dw 0, 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143

    .CODE
    .STARTUP

;===========================================================================
; GAME ENTRY POINT
;===========================================================================

    CALL GAME_INIT
    CALL GAME_MAIN_LOOP
    CALL GAME_EXIT
    MOV AX, 4C00h
    INT 21h

GAME_INIT PROC
    CALL SET_VIDEO_MODE
    CALL INSTALL_KEYBOARD
    CALL SEED_RNG
    CALL DRAW_TOP_BORDER
    CALL DRAW_HUD_STATIC
    MOV [GAME_STATE], 0
    RET
GAME_INIT ENDP

GAME_MAIN_LOOP PROC
MainLoop:
    CALL WAIT_VBLANK
    INC [FRAME_COUNTER]

    CMP [GAME_STATE], 0
    JE TitleLoop
    CMP [GAME_STATE], 1
    JE GameplayLoop
    CMP [GAME_STATE], 2
    JE GameOverLoop
    CMP [GAME_STATE], 3
    JE PauseLoop
    JMP MainLoop

TitleLoop:
    CALL UPDATE_TITLE
    JMP MainLoop

GameplayLoop:
    CALL DECREMENT_COOLDOWNS
    CALL DECREMENT_WALL_TIMERS
    CALL SPAWN_ENEMIES
    CALL UPDATE_PLAYER
    CALL UPDATE_ENEMIES
    CALL UPDATE_BULLETS
    CALL CHECK_WIN_CONDITION
    JMP MainLoop

GameOverLoop:
    CALL UPDATE_GAME_OVER
    JMP MainLoop

PauseLoop:
    CALL UPDATE_PAUSE
    JMP MainLoop
GAME_MAIN_LOOP ENDP

GAME_EXIT PROC
    CALL RESTORE_KEYBOARD
    MOV AX, 0003h
    INT 10h
    RET
GAME_EXIT ENDP

;===========================================================================
; VIDEO ROUTINES
;===========================================================================

SET_VIDEO_MODE PROC
    MOV AX, 0013h
    INT 10h
    RET
SET_VIDEO_MODE ENDP

WAIT_VBLANK PROC
    PUSH AX
    PUSH DX
    MOV DX, 3DAh
WaitVHigh:
    IN AL, DX
    TEST AL, 8
    JZ WaitVHigh
WaitVLow:
    IN AL, DX
    TEST AL, 8
    JNZ WaitVLow
    POP DX
    POP AX
    RET
WAIT_VBLANK ENDP

DRAW_TOP_BORDER PROC
    PUSH AX
    PUSH CX
    PUSH DI
    PUSH ES
    MOV AX, 0A000h
    MOV ES, AX
    XOR DI, DI
    MOV AL, 2
    MOV CX, 2560
    CLD
    REP STOSB
    POP ES
    POP DI
    POP CX
    POP AX
    RET
DRAW_TOP_BORDER ENDP

DRAW_SPRITE_SOLID PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV CX, 0A000h
    MOV ES, CX

    PUSH AX
    MOV AX, 320
    MUL BX
    POP DX
    ADD AX, DX
    MOV DI, AX

    MOV CX, 16
DrawSRow:
    PUSH CX
    MOV CX, 8
    CLD
    REP MOVSW
    ADD DI, 304
    POP CX
    LOOP DrawSRow

    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_SPRITE_SOLID ENDP

DRAW_SPRITE_TRANS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV CX, 0A000h
    MOV ES, CX

    PUSH AX
    MOV AX, 320
    MUL BX
    POP DX
    ADD AX, DX
    MOV DI, AX

    MOV CX, 16
DrawTRow:
    PUSH CX
    MOV CX, 16
DrawTCol:
    LODSB
    CMP AL, 0
    JE DrawTSkip
    MOV ES:[DI], AL
DrawTSkip:
    INC DI
    LOOP DrawTCol
    ADD DI, 304
    POP CX
    LOOP DrawTRow

    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_SPRITE_TRANS ENDP

DRAW_SPRITE_TRANS_8x8 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES

    MOV CX, 0A000h
    MOV ES, CX

    PUSH AX
    MOV AX, 320
    MUL BX
    POP DX
    ADD AX, DX
    MOV DI, AX

    MOV CX, 8
Draw8Row:
    PUSH CX
    MOV CX, 8
Draw8Col:
    LODSB
    CMP AL, 0
    JE Draw8Skip
    MOV ES:[DI], AL
Draw8Skip:
    INC DI
    LOOP Draw8Col
    ADD DI, 312
    POP CX
    LOOP Draw8Row

    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_SPRITE_TRANS_8x8 ENDP

ERASE_SPRITE PROC
    PUSH AX
    PUSH BX
    PUSH SI
    LEA SI, SPRITE_BLACK
    CALL DRAW_SPRITE_SOLID
    POP SI
    POP BX
    POP AX
    RET
ERASE_SPRITE ENDP

;===========================================================================
; GRID / COLLISION ROUTINES
;===========================================================================

GET_MAP_INDEX PROC
    PUSH AX
    PUSH SI
    XOR BH, BH
    SHL BX, 1
    MOV SI, BX
    MOV BL, AL
    XOR BH, BH
    MOV AX, [GRID_Y_MULT + SI]
    ADD BX, AX
    POP SI
    POP AX
    RET
GET_MAP_INDEX ENDP

GET_MAP_TILE PROC
    CALL GET_MAP_INDEX
    MOV AL, [MAP_ARRAY + BX]
    RET
GET_MAP_TILE ENDP

SET_MAP_TILE PROC
    PUSH AX
    PUSH DX
    CALL GET_MAP_INDEX
    POP DX
    MOV [MAP_ARRAY + BX], DL
    POP AX
    RET
SET_MAP_TILE ENDP

GRID_TO_PIXEL_X PROC
    PUSH BX
    MOV BL, 16
    MUL BL
    POP BX
    RET
GRID_TO_PIXEL_X ENDP

GRID_TO_PIXEL_Y PROC
    PUSH BX
    MOV BL, 16
    MUL BL
    ADD AX, 8
    POP BX
    RET
GRID_TO_PIXEL_Y ENDP

PIXEL_TO_GRID_X PROC
    SHR AX, 1
    SHR AX, 1
    SHR AX, 1
    SHR AX, 1
    RET
PIXEL_TO_GRID_X ENDP

PIXEL_TO_GRID_Y PROC
    SUB AX, 8
    SHR AX, 1
    SHR AX, 1
    SHR AX, 1
    SHR AX, 1
    RET
PIXEL_TO_GRID_Y ENDP

IS_POSITION_BLOCKED PROC
    PUSH BX
    CALL GET_MAP_TILE
    CMP AL, 0
    JE PosFree
    MOV AL, 1
    JMP PosDone
PosFree:
    MOV AL, 0
PosDone:
    POP BX
    RET
IS_POSITION_BLOCKED ENDP

;===========================================================================
; KEYBOARD HANDLING
;===========================================================================

INSTALL_KEYBOARD PROC
    PUSH AX
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    MOV AX, ES:[9*4]
    MOV WORD PTR [OLD_INT09], AX
    MOV AX, ES:[9*4+2]
    MOV WORD PTR [OLD_INT09+2], AX
    CLI
    MOV WORD PTR ES:[9*4], OFFSET KEYBOARD_HANDLER
    MOV WORD PTR ES:[9*4+2], CS
    STI
    MOV [KEY_UP], 0
    MOV [KEY_DOWN], 0
    MOV [KEY_LEFT], 0
    MOV [KEY_RIGHT], 0
    MOV [KEY_SPACE], 0
    MOV [KEY_ENTER], 0
    MOV [KEY_ESC], 0
    POP ES
    POP AX
    RET
INSTALL_KEYBOARD ENDP

RESTORE_KEYBOARD PROC
    PUSH AX
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    CLI
    MOV AX, WORD PTR [OLD_INT09]
    MOV ES:[9*4], AX
    MOV AX, WORD PTR [OLD_INT09+2]
    MOV ES:[9*4+2], AX
    STI
    POP ES
    POP AX
    RET
RESTORE_KEYBOARD ENDP

KEYBOARD_HANDLER PROC
    PUSH AX
    PUSH BX
    PUSH DS
    MOV AX, @DATA
    MOV DS, AX
    IN AL, 60h
    MOV BL, AL
    AND BL, 80h
    JZ KeyPress
    AND AL, 7Fh
    JMP CheckRelease
KeyPress:
    CMP AL, 48h
    JE SetKeyUp
    CMP AL, 50h
    JE SetKeyDown
    CMP AL, 4Bh
    JE SetKeyLeft
    CMP AL, 4Dh
    JE SetKeyRight
    CMP AL, 39h
    JE SetKeySpace
    CMP AL, 1Ch
    JE SetKeyEnter
    CMP AL, 01h
    JE SetKeyEsc
    JMP KeyIntDone

SetKeyUp:
    MOV [KEY_UP], 1
    JMP KeyIntDone
SetKeyDown:
    MOV [KEY_DOWN], 1
    JMP KeyIntDone
SetKeyLeft:
    MOV [KEY_LEFT], 1
    JMP KeyIntDone
SetKeyRight:
    MOV [KEY_RIGHT], 1
    JMP KeyIntDone
SetKeySpace:
    MOV [KEY_SPACE], 1
    JMP KeyIntDone
SetKeyEnter:
    MOV [KEY_ENTER], 1
    JMP KeyIntDone
SetKeyEsc:
    MOV [KEY_ESC], 1
    JMP KeyIntDone

CheckRelease:
    CMP AL, 48h
    JE ClrKeyUp
    CMP AL, 50h
    JE ClrKeyDown
    CMP AL, 4Bh
    JE ClrKeyLeft
    CMP AL, 4Dh
    JE ClrKeyRight
    CMP AL, 39h
    JE ClrKeySpace
    CMP AL, 1Ch
    JE ClrKeyEnter
    CMP AL, 01h
    JE ClrKeyEsc
    JMP KeyIntDone

ClrKeyUp:
    MOV [KEY_UP], 0
    JMP KeyIntDone
ClrKeyDown:
    MOV [KEY_DOWN], 0
    JMP KeyIntDone
ClrKeyLeft:
    MOV [KEY_LEFT], 0
    JMP KeyIntDone
ClrKeyRight:
    MOV [KEY_RIGHT], 0
    JMP KeyIntDone
ClrKeySpace:
    MOV [KEY_SPACE], 0
    JMP KeyIntDone
ClrKeyEnter:
    MOV [KEY_ENTER], 0
    JMP KeyIntDone
ClrKeyEsc:
    MOV [KEY_ESC], 0
    JMP KeyIntDone

KeyIntDone:
    MOV AL, 20h
    OUT 20h, AL
    POP DS
    POP BX
    POP AX
    IRET
KEYBOARD_HANDLER ENDP

;===========================================================================
; RNG
;===========================================================================

SEED_RNG PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 00h
    INT 1Ah
    MOV [RANDOM_SEED], DL
    POP DX
    POP CX
    POP AX
    RET
SEED_RNG ENDP

RNG_GET_BYTE PROC
    PUSH BX
    MOV AL, [RANDOM_SEED]
    MOV BL, 5
    MUL BL
    ADD AL, 3
    MOV [RANDOM_SEED], AL
    POP BX
    RET
RNG_GET_BYTE ENDP

;===========================================================================
; FONT AND HUD
;===========================================================================

GET_FONT_ADDR PROC
    PUSH AX
    PUSH BX
    CMP AL, '0'
    JB NotDigit
    CMP AL, '9'
    JA CheckLetter
    SUB AL, '0'
    JMP GotFontIdx
CheckLetter:
    CMP AL, 'A'
    JB NotFontLetter
    CMP AL, 'Z'
    JA NotFontLetter
    SUB AL, 'A'
    ADD AL, 10
    JMP GotFontIdx
NotFontLetter:
    CMP AL, '-'
    JNE UseDefaultFont
    MOV AL, 36
    JMP GotFontIdx
NotDigit:
UseDefaultFont:
    XOR AL, AL
GotFontIdx:
    XOR AH, AH
    SHL AX, 1
    MOV BX, AX
    MOV SI, [FONT_TABLE + BX]
    CMP SI, 0
    JNE FontAddrDone
    LEA SI, FONT_0
FontAddrDone:
    POP BX
    POP AX
    RET
GET_FONT_ADDR ENDP

DRAW_CHAR PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    MOV AL, DL
    CALL GET_FONT_ADDR
    CALL DRAW_SPRITE_TRANS_8x8
    POP SI
    POP DX
    POP BX
    POP AX
    RET
DRAW_CHAR ENDP

PRINT_STRING PROC
    PUSH AX
    PUSH BX
    PUSH SI
PrintLoop:
    MOV DL, [SI]
    CMP DL, 0
    JE PrintDone
    CALL DRAW_CHAR
    ADD AX, 8
    INC SI
    JMP PrintLoop
PrintDone:
    POP SI
    POP BX
    POP AX
    RET
PRINT_STRING ENDP

ITOA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    LEA SI, NUM_BUFFER_END
    DEC SI
    MOV BYTE PTR [SI], 0
    DEC SI
    MOV CX, 0
    MOV BX, 10
ITOA_DivLoop:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    MOV [SI], DL
    DEC SI
    INC CX
    CMP AX, 0
    JNE ITOA_DivLoop
    CMP CX, 5
    JGE ITOA_Done
ITOA_PadLoop:
    MOV BYTE PTR [SI], '0'
    DEC SI
    INC CX
    CMP CX, 5
    JL ITOA_PadLoop
ITOA_Done:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ITOA ENDP

CLEAR_GAME_AREA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH ES
    MOV AX, 0A000h
    MOV ES, AX
    XOR BX, BX
ClearRowOuter:
    CMP BX, 192
    JAE ClearDone
    MOV AX, 320
    MUL BX
    MOV DI, AX
    ADD DI, 8
    MOV AL, 0
    MOV CX, 208
    CLD
    REP STOSB
    INC BX
    JMP ClearRowOuter
ClearDone:
    POP ES
    POP DI
    POP CX
    POP BX
    POP AX
    RET
CLEAR_GAME_AREA ENDP

DRAW_HUD_STATIC PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV AX, 216
    MOV BX, 12
    LEA SI, STR_HISCORE
    CALL PRINT_STRING
    MOV AX, 216
    MOV BX, 44
    LEA SI, STR_SCORE
    CALL PRINT_STRING
    MOV AX, 216
    MOV BX, 76
    LEA SI, STR_LEVEL
    CALL PRINT_STRING
    MOV AX, 216
    MOV BX, 108
    LEA SI, STR_LIVES
    CALL PRINT_STRING
    MOV AX, 216
    MOV BX, 140
    LEA SI, STR_ENEMIES
    CALL PRINT_STRING
    POP SI
    POP BX
    POP AX
    RET
DRAW_HUD_STATIC ENDP

UPDATE_HUD_SCORE PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV AX, [SCORE]
    CALL ITOA
    LEA SI, NUM_BUFFER
    MOV CX, 5
Skip0:
    CMP BYTE PTR [SI], '0'
    JNE PrintS
    INC SI
    LOOP Skip0
PrintS:
    MOV AX, 216
    MOV BX, 20
    CALL PRINT_STRING
    POP SI
    POP BX
    POP AX
    RET
UPDATE_HUD_SCORE ENDP

UPDATE_HUD_HISCORE PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV AX, [HI_SCORE]
    CALL ITOA
    LEA SI, NUM_BUFFER
    MOV CX, 5
SkipH0:
    CMP BYTE PTR [SI], '0'
    JNE PrintHS
    INC SI
    LOOP SkipH0
PrintHS:
    MOV AX, 216
    MOV BX, 28
    CALL PRINT_STRING
    POP SI
    POP BX
    POP AX
    RET
UPDATE_HUD_HISCORE ENDP

UPDATE_HUD_LIVES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV AX, 216
    MOV BX, 116
    XOR CX, CX
    MOV CL, [LIVES]
    CMP CL, 0
    JE LivesDn
    LEA SI, SPRITE_LIFE_ICON
LivesLp:
    CALL DRAW_SPRITE_TRANS
    ADD AX, 18
    LOOP LivesLp
LivesDn:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
UPDATE_HUD_LIVES ENDP

UPDATE_HUD_ENEMIES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV AX, 216
    MOV BX, 148
    XOR CX, CX
    MOV CL, [ENEMIES_REMAINING]
    CMP CL, 0
    JE EnemDn
    LEA SI, SPRITE_ENEMY_ICON
EnemLp:
    PUSH CX
    CALL DRAW_SPRITE_TRANS
    ADD AX, 18
    CMP AX, 290
    JL EnemNR
    MOV AX, 216
    ADD BX, 18
EnemNR:
    POP CX
    LOOP EnemLp
EnemDn:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
UPDATE_HUD_ENEMIES ENDP

UPDATE_HUD_LEVEL PROC
    PUSH AX
    PUSH BX
    PUSH SI
    XOR AH, AH
    MOV AL, [CURRENT_LEVEL]
    CALL ITOA
    LEA SI, NUM_BUFFER
    MOV CX, 5
SkipL0:
    CMP BYTE PTR [SI], '0'
    JNE PrintLvl
    INC SI
    LOOP SkipL0
PrintLvl:
    MOV AX, 216
    MOV BX, 84
    CALL PRINT_STRING
    POP SI
    POP BX
    POP AX
    RET
UPDATE_HUD_LEVEL ENDP

UPDATE_FULL_HUD PROC
    CALL UPDATE_HUD_SCORE
    CALL UPDATE_HUD_HISCORE
    CALL UPDATE_HUD_LIVES
    CALL UPDATE_HUD_ENEMIES
    CALL UPDATE_HUD_LEVEL
    RET
UPDATE_FULL_HUD ENDP

;===========================================================================
; LEVEL LOADING
;===========================================================================

LOAD_LEVEL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH ES
    XOR AH, AH
    MOV AL, [CURRENT_LEVEL]
    DEC AL
    CMP AL, 8
    JB LvlOK
    AND AL, 7
LvlOK:
    SHL AX, 1
    MOV BX, AX
    MOV SI, [LEVEL_OFFSETS + BX]
    LEA DI, MAP_ARRAY
    MOV CX, 156
    PUSH DS
    POP ES
    CLD
    REP MOVSB
    POP ES
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
LOAD_LEVEL ENDP

;===========================================================================
; GAMEPLAY INIT
;===========================================================================

INIT_GAMEPLAY PROC
    CALL LOAD_LEVEL
    CALL INIT_PLAYER
    CALL INIT_ENEMIES
    CALL INIT_BULLETS
    CALL INIT_WALLS
    CALL DRAW_GAME_AREA
    CALL DRAW_INITIAL_MAP
    CALL DRAW_EFFIGY
    CALL DRAW_PLAYER_TANK
    CALL UPDATE_FULL_HUD
    MOV [EFFIGY_ALIVE], 1
    MOV [GAME_STATE], 1
    RET
INIT_GAMEPLAY ENDP

DRAW_GAME_AREA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH ES
    MOV AX, 0A000h
    MOV ES, AX
    MOV BX, 8
DrawGARow:
    MOV DI, BX
    MOV CX, 208
    MOV AL, 0
    CLD
    REP STOSB
    ADD BX, 320
    CMP BX, 64000
    JL DrawGARow
    POP ES
    POP DI
    POP CX
    POP BX
    POP AX
    RET
DRAW_GAME_AREA ENDP

INIT_PLAYER PROC
    MOV [PLAYER_GRID_X], 6
    MOV [PLAYER_GRID_Y], 11
    MOV [PLAYER_PIXEL_X], 96
    MOV [PLAYER_PIXEL_Y], 184
    MOV [PLAYER_DIR], 0
    MOV [PLAYER_COOLDOWN], 0
    MOV [PLAYER_POWERUP], 0
    MOV [PLAYER_MAX_BULLETS], 1
    MOV [PLAYER_BULLET_COUNT], 0
    MOV [PLAYER_ALIVE], 1
    MOV [PLAYER_HP], 1
    RET
INIT_PLAYER ENDP

INIT_ENEMIES PROC
    PUSH CX
    MOV CX, MAX_ENEMIES
    XOR BX, BX
InitELp:
    MOV [ENEMY_ACTIVE + BX], 0
    MOV [ENEMY_BULLET_COUNT + BX], 0
    INC BX
    LOOP InitELp
    MOV [ENEMIES_SPAWNED], 0
    MOV [ENEMY_SPAWN_TICKS], 60
    MOV [ENEMY_POOL_FROZEN], 0
    MOV AL, [CURRENT_LEVEL]
    DEC AL
    CMP AL, 4
    JB SetDiff
    MOV AL, 4
SetDiff:
    MOV [DIFFICULTY], AL
    MOV [ENEMIES_REMAINING], 20
    POP CX
    RET
INIT_ENEMIES ENDP

INIT_BULLETS PROC
    PUSH CX
    MOV CX, MAX_BULLETS
    XOR BX, BX
InitBLp:
    MOV [BULLET_ACTIVE + BX], 0
    INC BX
    LOOP InitBLp
    POP CX
    RET
INIT_BULLETS ENDP

INIT_WALLS PROC
    MOV [WALL_TIMER_COUNT], 0
    RET
INIT_WALLS ENDP

DRAW_INITIAL_MAP PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    MOV CX, 156
    LEA SI, MAP_ARRAY
    XOR BX, BX
DrawMapLp:
    MOV AL, [SI]
    CMP AL, 1
    JNE NotWallTile
    PUSH CX
    PUSH SI
    PUSH BX
    MOV AX, BX
    MOV CL, 13
    DIV CL
    MOV BL, AH
    XOR AH, AH
    MOV AL, BL
    CALL GRID_TO_PIXEL_X
    MOV [TEMP_X], AX
    POP BX
    PUSH BX
    MOV AX, BX
    MOV CL, 13
    DIV CL
    MOV BL, AL
    XOR AH, AH
    MOV AL, BL
    CALL GRID_TO_PIXEL_Y
    MOV [TEMP_Y], AX
    MOV AX, [TEMP_X]
    MOV BX, [TEMP_Y]
    LEA SI, SPRITE_WALL
    CALL DRAW_SPRITE_SOLID
    POP BX
    POP SI
    POP CX
NotWallTile:
    INC SI
    INC BX
    LOOP DrawMapLp
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
DRAW_INITIAL_MAP ENDP

DRAW_EFFIGY PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV AL, [EFFIGY_GRID_X]
    CALL GRID_TO_PIXEL_X
    MOV [TEMP_X], AX
    MOV AL, [EFFIGY_GRID_Y]
    CALL GRID_TO_PIXEL_Y
    MOV [TEMP_Y], AX
    MOV AX, [TEMP_X]
    MOV BX, [TEMP_Y]
    LEA SI, SPRITE_EFFIGY
    CALL DRAW_SPRITE_SOLID
    POP SI
    POP BX
    POP AX
    RET
DRAW_EFFIGY ENDP

;===========================================================================
; PLAYER LOGIC
;===========================================================================

DRAW_PLAYER_TANK PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV AX, [PLAYER_PIXEL_X]
    MOV BX, [PLAYER_PIXEL_Y]
    CALL GET_PLAYER_SPRITE
    CALL DRAW_SPRITE_SOLID
    POP SI
    POP BX
    POP AX
    RET
DRAW_PLAYER_TANK ENDP

GET_PLAYER_SPRITE PROC
    CMP BYTE PTR [PLAYER_DIR], 0
    JE PSprUp
    CMP BYTE PTR [PLAYER_DIR], 1
    JE PSprRight
    CMP BYTE PTR [PLAYER_DIR], 2
    JE PSprDown
    LEA SI, SPRITE_PLAYER_LEFT
    RET
PSprUp:
    LEA SI, SPRITE_PLAYER_UP
    RET
PSprRight:
    LEA SI, SPRITE_PLAYER_RIGHT
    RET
PSprDown:
    LEA SI, SPRITE_PLAYER_DOWN
    RET
GET_PLAYER_SPRITE ENDP

GET_ENEMY_SPRITE PROC
    MOV AL, [ENEMY_TYPE + BX]
    CMP AL, 1
    JE ENorm
    CMP AL, 2
    JE EFast
    CMP AL, 3
    JE ERainb
    CMP AL, 4
    JE EHeavy
    LEA SI, SPRITE_ENEMY_NORMAL
    RET
ENorm:
    LEA SI, SPRITE_ENEMY_NORMAL
    RET
EFast:
    CMP BYTE PTR [ENEMY_HP + BX], 2
    JE EFastF
    LEA SI, SPRITE_ENEMY_FAST_DMG
    RET
EFastF:
    LEA SI, SPRITE_ENEMY_FAST
    RET
ERainb:
    LEA SI, SPRITE_ENEMY_RAINBOW
    RET
EHeavy:
    MOV AL, [ENEMY_HP + BX]
    CMP AL, 4
    JE EHFull
    CMP AL, 3
    JE EHD1
    CMP AL, 2
    JE EHD2
    LEA SI, SPRITE_ENEMY_HEAVY_D3
    RET
EHFull:
    LEA SI, SPRITE_ENEMY_HEAVY
    RET
EHD1:
    LEA SI, SPRITE_ENEMY_HEAVY_D1
    RET
EHD2:
    LEA SI, SPRITE_ENEMY_HEAVY_D2
    RET
GET_ENEMY_SPRITE ENDP

DECREMENT_COOLDOWNS PROC
    PUSH CX
    PUSH BX
    CMP [PLAYER_COOLDOWN], 0
    JE TickEnemies
    DEC [PLAYER_COOLDOWN]
TickEnemies:
    MOV CX, MAX_ENEMIES
    XOR BX, BX
TickELp:
    CMP [ENEMY_ACTIVE + BX], 1
    JNE TickNextE
    CMP [ENEMY_COOLDOWN + BX], 0
    JE TickNextE
    DEC [ENEMY_COOLDOWN + BX]
TickNextE:
    ADD BX, 1
    LOOP TickELp
    MOV CX, MAX_BULLETS
    XOR BX, BX
TickBLp:
    CMP [BULLET_ACTIVE + BX], 1
    JNE TickNextB
    CMP [BULLET_COOLDOWN + BX], 0
    JE TickNextB
    DEC [BULLET_COOLDOWN + BX]
TickNextB:
    ADD BX, 1
    LOOP TickBLp
    POP BX
    POP CX
    RET
DECREMENT_COOLDOWNS ENDP

UPDATE_PLAYER PROC
    CMP BYTE PTR [PLAYER_ALIVE], 1
    JNE NoPlayerUpdate
    CMP [PLAYER_COOLDOWN], 0
    JNE NoPlayerUpdate

    CMP [KEY_ENTER], 1
    JNE NotPausing
    MOV [KEY_ENTER], 0
    MOV [GAME_STATE], 3
    RET
NotPausing:
    MOV AX, [PLAYER_SPEED]
    MOV [PLAYER_COOLDOWN], AX

    CALL TRY_PLAYER_SHOOT

    MOV [TEMP_BYTE], 0

    CMP [KEY_UP], 1
    JNE TryPDown
    MOV [PLAYER_DIR], 0
    MOV [TEMP_BYTE], 1
    MOV AL, [PLAYER_GRID_Y]
    DEC AL
    MOV BL, AL
    MOV AL, [PLAYER_GRID_X]
    JMP DoPlayerMove

TryPDown:
    CMP [KEY_DOWN], 1
    JNE TryPLeft
    MOV [PLAYER_DIR], 2
    MOV [TEMP_BYTE], 1
    MOV AL, [PLAYER_GRID_Y]
    INC AL
    MOV BL, AL
    MOV AL, [PLAYER_GRID_X]
    JMP DoPlayerMove

TryPLeft:
    CMP [KEY_LEFT], 1
    JNE TryPRight
    MOV [PLAYER_DIR], 3
    MOV [TEMP_BYTE], 1
    MOV BL, [PLAYER_GRID_Y]
    MOV AL, [PLAYER_GRID_X]
    DEC AL
    JMP DoPlayerMove

TryPRight:
    CMP [KEY_RIGHT], 1
    JNE PlayerMoveDone
    MOV [PLAYER_DIR], 1
    MOV [TEMP_BYTE], 1
    MOV BL, [PLAYER_GRID_Y]
    MOV AL, [PLAYER_GRID_X]
    INC AL

DoPlayerMove:
    PUSH AX
    PUSH BX
    CALL IS_POSITION_BLOCKED
    POP BX
    POP CX
    CMP AL, 1
    JE PlayerMoveDone

    MOV [PLAYER_GRID_X], CL
    MOV [PLAYER_GRID_Y], BL

    MOV AX, [PLAYER_PIXEL_X]
    MOV BX, [PLAYER_PIXEL_Y]
    CALL ERASE_SPRITE

    XOR AH, AH
    MOV AL, [PLAYER_GRID_X]
    CALL GRID_TO_PIXEL_X
    MOV [PLAYER_PIXEL_X], AX

    XOR AH, AH
    MOV AL, [PLAYER_GRID_Y]
    CALL GRID_TO_PIXEL_Y
    MOV [PLAYER_PIXEL_Y], AX

    CALL DRAW_PLAYER_TANK

PlayerMoveDone:
NoPlayerUpdate:
    RET
UPDATE_PLAYER ENDP

TRY_PLAYER_SHOOT PROC
    CMP [KEY_SPACE], 1
    JNE NoPShoot

    XOR CX, CX
    MOV CL, [PLAYER_BULLET_COUNT]
    XOR CH, CH
    MOV AL, [PLAYER_MAX_BULLETS]
    CMP CL, AL
    JAE NoPShoot

    XOR BX, BX
FindBulletSlot:
    CMP [BULLET_ACTIVE + BX], 0
    JE GotBulletSlot
    INC BX
    CMP BX, MAX_BULLETS
    JL FindBulletSlot
    JMP NoPShoot

GotBulletSlot:
    MOV [BULLET_ACTIVE + BX], 1
    MOV AL, [PLAYER_GRID_X]
    MOV [BULLET_GRID_X + BX], AL
    MOV AL, [PLAYER_GRID_Y]
    MOV [BULLET_GRID_Y + BX], AL
    MOV AX, [PLAYER_PIXEL_X]
    MOV [BULLET_PIXEL_X + BX], AX
    MOV AX, [PLAYER_PIXEL_Y]
    MOV [BULLET_PIXEL_Y + BX], AX
    MOV AL, [PLAYER_DIR]
    MOV [BULLET_DIR + BX], AL
    MOV BYTE PTR [BULLET_OWNER + BX], 0
    MOV AX, [BULLET_SPEED]
    MOV [BULLET_COOLDOWN + BX], AX
    INC [PLAYER_BULLET_COUNT]
    MOV [KEY_SPACE], 0

NoPShoot:
    RET
TRY_PLAYER_SHOOT ENDP

;===========================================================================
; ENEMY SPAWNING AND AI
;===========================================================================

SPAWN_ENEMIES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    CMP [ENEMY_SPAWN_TICKS], 0
    JE TryEnemySpawn
    DEC [ENEMY_SPAWN_TICKS]
    JMP SpawnDone
TryEnemySpawn:
    CMP BYTE PTR [ENEMIES_REMAINING], 0
    JE SpawnDone
    MOV CX, 0
    XOR BX, BX
CntActive:
    CMP [ENEMY_ACTIVE + BX], 1
    JNE CntNext
    INC CX
CntNext:
    INC BX
    CMP BX, MAX_ENEMIES
    JL CntActive
    CMP CX, MAX_ENEMIES
    JAE SpawnDone
    XOR BX, BX
FindSlotE:
    CMP [ENEMY_ACTIVE + BX], 0
    JE DoSpawnE
    INC BX
    CMP BX, MAX_ENEMIES
    JL FindSlotE
    JMP SpawnDone
DoSpawnE:
    MOV [ENEMY_ACTIVE + BX], 1
    CALL RNG_GET_BYTE
    AND AL, 0Ch
    CMP AL, 0
    JE SpawnAt0
    CMP AL, 4
    JE SpawnAt4
    CMP AL, 8
    JE SpawnAt8
    MOV BYTE PTR [ENEMY_GRID_X + BX], 12
    JMP SpawnPosDone
SpawnAt0:
    MOV BYTE PTR [ENEMY_GRID_X + BX], 0
    JMP SpawnPosDone
SpawnAt4:
    MOV BYTE PTR [ENEMY_GRID_X + BX], 4
    JMP SpawnPosDone
SpawnAt8:
    MOV BYTE PTR [ENEMY_GRID_X + BX], 8
SpawnPosDone:
    MOV BYTE PTR [ENEMY_GRID_Y + BX], 0
    XOR AH, AH
    MOV AL, [ENEMY_GRID_X + BX]
    CALL GRID_TO_PIXEL_X
    MOV [ENEMY_PIXEL_X + BX], AX
    XOR AH, AH
    MOV AL, [ENEMY_GRID_Y + BX]
    CALL GRID_TO_PIXEL_Y
    MOV [ENEMY_PIXEL_Y + BX], AX
    CALL PICK_ENEMY_TYPE
    MOV [ENEMY_TYPE + BX], AL
    MOV BYTE PTR [ENEMY_DIR + BX], 2
    MOV [ENEMY_COOLDOWN + BX], 10
    MOV BYTE PTR [ENEMY_LAST_DIR + BX], 2
    CMP AL, 2
    JE SetHP2
    CMP AL, 4
    JE SetHP4
    MOV BYTE PTR [ENEMY_HP + BX], 1
    JMP SetEpref
SetHP2:
    MOV BYTE PTR [ENEMY_HP + BX], 2
    JMP SetEpref
SetHP4:
    MOV BYTE PTR [ENEMY_HP + BX], 4
SetEpref:
    CMP AL, 2
    JE SetPrefEffigy
    CMP AL, 4
    JE SetPrefEffigy
    MOV BYTE PTR [ENEMY_PREFERS + BX], 0
    JMP EnemySpawned
SetPrefEffigy:
    MOV BYTE PTR [ENEMY_PREFERS + BX], 1
EnemySpawned:
    DEC [ENEMIES_REMAINING]
    INC [ENEMIES_SPAWNED]
    MOV [ENEMY_SPAWN_TICKS], 90
SpawnDone:
    POP CX
    POP BX
    POP AX
    RET
SPAWN_ENEMIES ENDP

PICK_ENEMY_TYPE PROC
    CALL RNG_GET_BYTE
    MOV AH, 0
    MOV BL, 4
    DIV BL
    CMP AH, 0
    JE PickN
    CMP AH, 1
    JE PickF
    CMP AH, 2
    JE PickR
    MOV AL, 4
    RET
PickN:
    MOV AL, 1
    RET
PickF:
    MOV AL, 2
    RET
PickR:
    MOV AL, 3
    RET
PICK_ENEMY_TYPE ENDP

GET_ENEMY_SPEED PROC
    CMP BYTE PTR [ENEMY_TYPE + BX], 1
    JE SpdN
    CMP BYTE PTR [ENEMY_TYPE + BX], 2
    JE SpdF
    CMP BYTE PTR [ENEMY_TYPE + BX], 3
    JE SpdR
    MOV AX, [ENEMY_SPEED_HEAVY]
    RET
SpdN:
    MOV AX, [ENEMY_SPEED_NORMAL]
    RET
SpdF:
    MOV AX, [ENEMY_SPEED_FAST]
    RET
SpdR:
    MOV AX, [ENEMY_SPEED_RAINBOW]
    RET
GET_ENEMY_SPEED ENDP

UPDATE_ENEMIES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    MOV CX, MAX_ENEMIES
    XOR BX, BX
UpdELp:
    CMP [ENEMY_ACTIVE + BX], 1
    JNE NextEUpd
    CMP [ENEMY_COOLDOWN + BX], 0
    JNE NextEUpd
    PUSH CX
    PUSH BX
    CALL UPDATE_SINGLE_ENEMY
    POP BX
    POP CX
NextEUpd:
    INC BX
    LOOP UpdELp
    POP CX
    POP BX
    POP AX
    RET
UPDATE_ENEMIES ENDP

UPDATE_SINGLE_ENEMY PROC
    CALL GET_ENEMY_SPEED
    MOV [ENEMY_COOLDOWN + BX], AX

    MOV SI, BX
    MOV AX, [ENEMY_PIXEL_X + SI]
    MOV [TEMP_X], AX
    MOV AX, [ENEMY_PIXEL_Y + SI]
    MOV [TEMP_Y], AX

    MOV AX, [TEMP_X]
    MOV BX, [TEMP_Y]
    CALL ERASE_SPRITE

    MOV BX, SI
    CALL AI_DECIDE_DIRECTION

    MOV BX, SI
    CALL TRY_ENEMY_SHOOT

    MOV BX, SI
    CALL GET_ENEMY_SPRITE
    MOV AX, [ENEMY_PIXEL_X + BX]
    MOV BX, [ENEMY_PIXEL_Y + BX]
    CALL DRAW_SPRITE_SOLID
    RET
UPDATE_SINGLE_ENEMY ENDP

AI_DECIDE_DIRECTION PROC
    PUSH AX
    PUSH BX
    PUSH CX

    CALL CHECK_EFFIGY_ALIGNMENT
    CMP AL, 0FFh
    JE NoEffigyTarget
    CMP BYTE PTR [ENEMY_PREFERS + BX], 1
    JNE NoEffigyTarget
    CALL RNG_GET_BYTE
    CMP AL, 128
    JAE NoEffigyTarget
    CALL MOVE_TOWARD_EFFIGY
    JMP AIDone

NoEffigyTarget:
    MOV AL, [ENEMY_DIR + BX]
    CALL CHECK_PATH_CLEAR
    CMP AL, 1
    JNE DoDirEval
    CALL RNG_GET_BYTE
    CMP AL, 205
    JB KeepDir

DoDirEval:
    CALL EVALUATE_DIRECTIONS
    JMP AIDone

KeepDir:
    CALL TRY_MOVE_CURRENT_DIR

AIDone:
    POP CX
    POP BX
    POP AX
    RET
AI_DECIDE_DIRECTION ENDP

CHECK_EFFIGY_ALIGNMENT PROC
    MOV AL, [ENEMY_GRID_X + BX]
    CMP AL, [EFFIGY_GRID_X]
    JNE EffigyYChk
    MOV AL, [ENEMY_GRID_Y + BX]
    CMP AL, [EFFIGY_GRID_Y]
    JA EffigyUpDir
    MOV AL, 2
    RET
EffigyUpDir:
    MOV AL, 0
    RET
EffigyYChk:
    MOV AL, [ENEMY_GRID_Y + BX]
    CMP AL, [EFFIGY_GRID_Y]
    JNE EffigyNone
    MOV AL, [ENEMY_GRID_X + BX]
    CMP AL, [EFFIGY_GRID_X]
    JA EffigyLft
    MOV AL, 1
    RET
EffigyLft:
    MOV AL, 3
    RET
EffigyNone:
    MOV AL, 0FFh
    RET
CHECK_EFFIGY_ALIGNMENT ENDP

MOVE_TOWARD_EFFIGY PROC
    CALL CHECK_EFFIGY_ALIGNMENT
    MOV [ENEMY_DIR + BX], AL
    CALL TRY_MOVE_CURRENT_DIR
    RET
MOVE_TOWARD_EFFIGY ENDP

CHECK_PATH_CLEAR PROC
    PUSH AX
    PUSH BX
    CMP AL, 0
    JE ChkUp
    CMP AL, 1
    JE ChkRight
    CMP AL, 2
    JE ChkDown
    MOV AL, [ENEMY_GRID_X + BX]
    DEC AL
    CMP AL, 13
    JAE PathBlocked
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    JMP PathDone

ChkUp:
    MOV AL, [ENEMY_GRID_Y + BX]
    DEC AL
    CMP AL, 12
    JAE PathBlocked
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    CALL IS_POSITION_BLOCKED
    JMP PathDone

ChkRight:
    MOV AL, [ENEMY_GRID_X + BX]
    INC AL
    CMP AL, 13
    JAE PathBlocked
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    JMP PathDone

ChkDown:
    MOV AL, [ENEMY_GRID_Y + BX]
    INC AL
    CMP AL, 12
    JAE PathBlocked
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    CALL IS_POSITION_BLOCKED
    JMP PathDone

PathBlocked:
    XOR AL, AL
    JMP PathRet

PathDone:
PathRet:
    POP BX
    POP AX
    RET
CHECK_PATH_CLEAR ENDP

EVALUATE_DIRECTIONS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BYTE PTR [TEMP_BYTE], 0FFh

    MOV AL, [ENEMY_GRID_Y + BX]
    INC AL
    CMP AL, 12
    JAE TryRight
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    PUSH BX
    CALL IS_POSITION_BLOCKED
    POP BX
    CMP AL, 1
    JE TryRight
    MOV BYTE PTR [TEMP_BYTE], 2
    CALL RNG_GET_BYTE
    CMP AL, 76
    JB UseDown

TryRight:
    MOV AL, [ENEMY_GRID_X + BX]
    INC AL
    CMP AL, 13
    JAE TryLeft
    MOV BL, [ENEMY_GRID_Y + BX]
    PUSH BX
    CALL IS_POSITION_BLOCKED
    POP BX
    CMP AL, 1
    JE TryLeft
    MOV BYTE PTR [TEMP_BYTE], 1
    CALL RNG_GET_BYTE
    CMP AL, 76
    JB UseRight

TryLeft:
    MOV AL, [ENEMY_GRID_X + BX]
    DEC AL
    CMP AL, 13
    JAE TryUp
    MOV BL, [ENEMY_GRID_Y + BX]
    PUSH BX
    CALL IS_POSITION_BLOCKED
    POP BX
    CMP AL, 1
    JE TryUp
    MOV BYTE PTR [TEMP_BYTE], 3
    CALL RNG_GET_BYTE
    CMP AL, 76
    JB UseLeft

TryUp:
    MOV AL, [ENEMY_GRID_Y + BX]
    DEC AL
    CMP AL, 12
    JAE FallbackDir
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    PUSH BX
    CALL IS_POSITION_BLOCKED
    POP BX
    CMP AL, 1
    JE FallbackDir
    MOV BYTE PTR [TEMP_BYTE], 0
    CALL RNG_GET_BYTE
    CMP AL, 76
    JB UseUp

FallbackDir:
    MOV AL, [TEMP_BYTE]
    CMP AL, 0FFh
    JNE UseFallback
    MOV BYTE PTR [TEMP_BYTE], 0FFh
    MOV AL, [ENEMY_GRID_Y + BX]
    INC AL
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 0
    JE UseFallbackD
    MOV AL, [ENEMY_GRID_X + BX]
    INC AL
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 0
    JE UseFallbackR
    MOV AL, [ENEMY_GRID_X + BX]
    DEC AL
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 0
    JE UseFallbackL
    MOV BYTE PTR [TEMP_BYTE], 0
    JMP UseFallback

UseFallbackD:
    MOV BYTE PTR [TEMP_BYTE], 2
    JMP UseFallback
UseFallbackR:
    MOV BYTE PTR [TEMP_BYTE], 1
    JMP UseFallback
UseFallbackL:
    MOV BYTE PTR [TEMP_BYTE], 3
    JMP UseFallback

UseDown:
    MOV BYTE PTR [TEMP_BYTE], 2
    JMP ApplyDir
UseRight:
    MOV BYTE PTR [TEMP_BYTE], 1
    JMP ApplyDir
UseLeft:
    MOV BYTE PTR [TEMP_BYTE], 3
    JMP ApplyDir
UseUp:
    MOV BYTE PTR [TEMP_BYTE], 0
    JMP ApplyDir

UseFallback:
ApplyDir:
    MOV AL, [TEMP_BYTE]
    CMP AL, 0FFh
    JE NoValidDir
    MOV [ENEMY_DIR + BX], AL
    CALL TRY_MOVE_CURRENT_DIR

NoValidDir:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
EVALUATE_DIRECTIONS ENDP

TRY_MOVE_CURRENT_DIR PROC
    PUSH AX
    PUSH BX

    MOV AL, [ENEMY_DIR + BX]
    CMP AL, 0
    JE MoveUp
    CMP AL, 1
    JE MoveRight
    CMP AL, 2
    JE MoveDown

    MOV AL, [ENEMY_GRID_X + BX]
    DEC AL
    CMP AL, 13
    JAE CMDone
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 1
    JE CMDone
    DEC [ENEMY_GRID_X + BX]
    JMP UpdateEpos

MoveUp:
    MOV AL, [ENEMY_GRID_Y + BX]
    DEC AL
    CMP AL, 12
    JAE CMDone
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 1
    JE CMDone
    DEC [ENEMY_GRID_Y + BX]
    JMP UpdateEpos

MoveRight:
    MOV AL, [ENEMY_GRID_X + BX]
    INC AL
    CMP AL, 13
    JAE CMDone
    MOV BL, [ENEMY_GRID_Y + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 1
    JE CMDone
    INC [ENEMY_GRID_X + BX]
    JMP UpdateEpos

MoveDown:
    MOV AL, [ENEMY_GRID_Y + BX]
    INC AL
    CMP AL, 12
    JAE CMDone
    MOV BL, AL
    MOV AL, [ENEMY_GRID_X + BX]
    CALL IS_POSITION_BLOCKED
    CMP AL, 1
    JE CMDone
    INC [ENEMY_GRID_Y + BX]

UpdateEpos:
    XOR AH, AH
    MOV AL, [ENEMY_GRID_X + BX]
    CALL GRID_TO_PIXEL_X
    MOV [ENEMY_PIXEL_X + BX], AX
    XOR AH, AH
    MOV AL, [ENEMY_GRID_Y + BX]
    CALL GRID_TO_PIXEL_Y
    MOV [ENEMY_PIXEL_Y + BX], AX
    MOV AL, [ENEMY_DIR + BX]
    MOV [ENEMY_LAST_DIR + BX], AL

CMDone:
    POP BX
    POP AX
    RET
TRY_MOVE_CURRENT_DIR ENDP

;===========================================================================
; ENEMY SHOOTING
;===========================================================================

TRY_ENEMY_SHOOT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP [ENEMY_BULLET_COUNT + BX], 2
    JAE NoEShoot

    CMP BYTE PTR [PLAYER_ALIVE], 1
    JNE NoEShoot

    MOV AL, [ENEMY_GRID_X + BX]
    CMP AL, [PLAYER_GRID_X]
    JNE EShootYChk
    MOV AL, [ENEMY_GRID_Y + BX]
    CMP AL, [PLAYER_GRID_Y]
    JA EShootUp
    MOV DL, 2
    JMP EShootFound
EShootUp:
    MOV DL, 0
    JMP EShootFound

EShootYChk:
    MOV AL, [ENEMY_GRID_Y + BX]
    CMP AL, [PLAYER_GRID_Y]
    JNE NoEShoot
    MOV AL, [ENEMY_GRID_X + BX]
    CMP AL, [PLAYER_GRID_X]
    JA EShootLeft
    MOV DL, 1
    JMP EShootFound
EShootLeft:
    MOV DL, 3

EShootFound:
    CALL RNG_GET_BYTE
    CMP AL, 128
    JB NoEShoot

    PUSH BX
    XOR CX, CX
FindEBullet:
    CMP [BULLET_ACTIVE + CX], 0
    JE GotEBullet
    INC CX
    CMP CX, MAX_BULLETS
    JL FindEBullet
    POP BX
    JMP NoEShoot

GotEBullet:
    MOV [BULLET_ACTIVE + CX], 1
    MOV AL, [ENEMY_GRID_X + BX]
    MOV [BULLET_GRID_X + CX], AL
    MOV AL, [ENEMY_GRID_Y + BX]
    MOV [BULLET_GRID_Y + CX], AL
    MOV AX, [ENEMY_PIXEL_X + BX]
    MOV [BULLET_PIXEL_X + CX], AX
    MOV AX, [ENEMY_PIXEL_Y + BX]
    MOV [BULLET_PIXEL_Y + CX], AX
    MOV [BULLET_DIR + CX], DL
    MOV BYTE PTR [BULLET_OWNER + CX], 1
    MOV AX, [BULLET_SPEED_ENEMY]
    MOV [BULLET_COOLDOWN + CX], AX
    MOV SI, BX
    POP BX
    INC [ENEMY_BULLET_COUNT + SI]

NoEShoot:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TRY_ENEMY_SHOOT ENDP

;===========================================================================
; BULLET SYSTEM
;===========================================================================

UPDATE_BULLETS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX, MAX_BULLETS
    XOR BX, BX
UpdBLp:
    CMP [BULLET_ACTIVE + BX], 1
    JNE NextBUpd
    CMP [BULLET_COOLDOWN + BX], 0
    JNE NextBUpd
    PUSH CX
    PUSH BX
    CALL UPDATE_SINGLE_BULLET
    POP BX
    POP CX
NextBUpd:
    INC BX
    LOOP UpdBLp
    POP DX
    POP CX
    POP BX
    POP AX
    RET
UPDATE_BULLETS ENDP

UPDATE_SINGLE_BULLET PROC
    PUSH AX
    PUSH BX
    PUSH CX

    MOV AX, [BULLET_SPEED]
    MOV [BULLET_COOLDOWN + BX], AX

    MOV AX, [BULLET_PIXEL_X + BX]
    MOV BX, [BULLET_PIXEL_Y + BX]
    PUSH BX
    CALL ERASE_SPRITE
    POP BX
    MOV AX, BX
    POP BX
    PUSH BX

    MOV AL, [BULLET_GRID_X + BX]
    XOR AH, AH
    MOV [TEMP_X], AX
    MOV AL, [BULLET_GRID_Y + BX]
    XOR AH, AH
    MOV [TEMP_Y], AX

    MOV AL, [BULLET_DIR + BX]
    CMP AL, 0
    JE BulletUp
    CMP AL, 1
    JE BulletRight
    CMP AL, 2
    JE BulletDown

    DEC WORD PTR [TEMP_X]
    JMP BulletCalc

BulletUp:
    DEC WORD PTR [TEMP_Y]
    JMP BulletCalc

BulletRight:
    INC WORD PTR [TEMP_X]
    JMP BulletCalc

BulletDown:
    INC WORD PTR [TEMP_Y]

BulletCalc:
    MOV AX, [TEMP_X]
    CMP AX, 13
    JAE DeactB
    MOV AX, [TEMP_Y]
    CMP AX, 12
    JAE DeactB

    PUSH BX
    MOV AL, BYTE PTR [TEMP_X]
    MOV BL, BYTE PTR [TEMP_Y]
    CALL GET_MAP_TILE
    POP BX
    MOV [TEMP_BYTE], AL

    CMP AL, 1
    JE BHitWall
    CMP AL, 80h
    JE BHitWall
    CMP AL, 0
    JE BMoving

    CMP BYTE PTR [BULLET_OWNER + BX], 1
    JNE NotEnemyBullet
    MOV AX, [TEMP_X]
    CMP AL, [PLAYER_GRID_X]
    JNE NotEnemyBullet
    MOV AX, [TEMP_Y]
    CMP AL, [PLAYER_GRID_Y]
    JNE NotEnemyBullet
    CMP BYTE PTR [PLAYER_ALIVE], 1
    JNE NotEnemyBullet
    MOV [PLAYER_ALIVE], 0
    JMP DeactB
NotEnemyBullet:

    MOV AX, [TEMP_X]
    CMP AL, [EFFIGY_GRID_X]
    JNE BHitEnemy
    MOV AX, [TEMP_Y]
    CMP AL, [EFFIGY_GRID_Y]
    JNE BHitEnemy
    MOV [EFFIGY_ALIVE], 0
    MOV [GAME_STATE], 2
    MOV [GAME_OVER_TIMER], 210
    JMP DeactB

BHitWall:
    PUSH BX
    CALL DAMAGE_WALL
    POP BX
    JMP DeactB

BHitEnemy:
    MOV [TEMP_WORD], BX
    PUSH BX
    MOV AL, BYTE PTR [TEMP_X]
    MOV BL, BYTE PTR [TEMP_Y]
    CALL DAMAGE_ENEMY
    POP BX
    JMP DeactB

BMoving:
    PUSH BX
    MOV AL, BYTE PTR [TEMP_X]
    MOV BL, BYTE PTR [TEMP_Y]
    CALL CHECK_BULLET_COLLISION
    POP BX
    CMP AL, 1
    JE DeactB

    MOV AX, [TEMP_X]
    MOV [BULLET_GRID_X + BX], AL
    MOV AX, [TEMP_Y]
    MOV [BULLET_GRID_Y + BX], AL

    MOV AL, BYTE PTR [TEMP_X]
    CALL GRID_TO_PIXEL_X
    MOV [BULLET_PIXEL_X + BX], AX

    MOV AL, BYTE PTR [TEMP_Y]
    CALL GRID_TO_PIXEL_Y
    MOV [BULLET_PIXEL_Y + BX], AX

    POP BX
    PUSH BX
    LEA SI, SPRITE_BULLET
    MOV AX, [BULLET_PIXEL_X + BX]
    MOV BX, [BULLET_PIXEL_Y + BX]
    CALL DRAW_SPRITE_TRANS
    POP BX

    JMP BulletDone

DeactB:
    CMP BYTE PTR [BULLET_OWNER + BX], 0
    JNE DeactEnemyB
    DEC [PLAYER_BULLET_COUNT]
    JMP MarkInactive
DeactEnemyB:
    MOV SI, BX
    XOR SI, SI
    MOV CX, MAX_ENEMIES
DeactFindEnemy:
    MOV AL, [ENEMY_GRID_X + SI]
    CMP AL, [BULLET_GRID_X + BX]
    JNE DEnextE
    MOV AL, [ENEMY_GRID_Y + SI]
    CMP AL, [BULLET_GRID_Y + BX]
    JNE DEnextE
    CMP [ENEMY_ACTIVE + SI], 1
    JNE DEnextE
    DEC [ENEMY_BULLET_COUNT + SI]
    JMP MarkInactive
DEnextE:
    INC SI
    LOOP DEactFindEnemy
MarkInactive:
    MOV [BULLET_ACTIVE + BX], 0

BulletDone:
    POP CX
    POP BX
    POP AX
    RET
UPDATE_SINGLE_BULLET ENDP

CHECK_BULLET_COLLISION PROC
    PUSH BX
    PUSH CX
    MOV CX, MAX_BULLETS
    XOR SI, SI
BulletColLp:
    CMP SI, BX
    JE BulletColNext
    CMP [BULLET_ACTIVE + SI], 1
    JNE BulletColNext
    MOV AL, [BULLET_GRID_X + SI]
    CMP AL, BYTE PTR [TEMP_X]
    JNE BulletColNext
    MOV AL, [BULLET_GRID_Y + SI]
    CMP AL, BYTE PTR [TEMP_Y]
    JNE BulletColNext
    MOV [BULLET_ACTIVE + SI], 0
    CMP BYTE PTR [BULLET_OWNER + SI], 0
    JNE BulletColHit
    DEC [PLAYER_BULLET_COUNT]
BulletColHit:
    MOV AL, 1
    JMP BulletColDone
BulletColNext:
    INC SI
    LOOP BulletColLp
    XOR AL, AL
BulletColDone:
    POP CX
    POP BX
    RET
CHECK_BULLET_COLLISION ENDP

DAMAGE_ENEMY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    MOV CX, MAX_ENEMIES
    XOR SI, SI
FindEnemyLp:
    CMP [ENEMY_ACTIVE + SI], 1
    JNE DmgNext
    MOV DI, [TEMP_WORD]
    CMP BYTE PTR [BULLET_OWNER + DI], 1
    JNE DmgCheckPos
    JMP DmgNext
DmgCheckPos:
    MOV AX, [TEMP_X]
    CMP AL, [ENEMY_GRID_X + SI]
    JNE DmgNext
    MOV AX, [TEMP_Y]
    CMP AL, [ENEMY_GRID_Y + SI]
    JNE DmgNext

    DEC BYTE PTR [ENEMY_HP + SI]
    JZ DmgKill
    JMP DmgDone

DmgKill:
    MOV [ENEMY_ACTIVE + SI], 0
    MOV AX, [ENEMY_PIXEL_X + SI]
    MOV BX, [ENEMY_PIXEL_Y + SI]
    PUSH SI
    CALL ERASE_SPRITE
    POP SI

    MOV AL, [ENEMY_TYPE + SI]
    CMP AL, 3
    JNE DmgAddScore
    CALL RNG_GET_BYTE
    CMP AL, 128
    JB DmgAddScore
    CMP BYTE PTR [PLAYER_POWERUP], 2
    JAE DmgAddScore
    INC BYTE PTR [PLAYER_POWERUP]
    MOV BYTE PTR [PLAYER_MAX_BULLETS], 2
    JMP DmgAddScore

DmgAddScore:
    MOV AL, [ENEMY_TYPE + SI]
    CMP AL, 2
    JE Score1000
    CMP AL, 4
    JE Score1000
    CMP AL, 3
    JE Score500
    ADD [SCORE], 300
    JMP CheckExtraLife
Score1000:
    ADD [SCORE], 1000
    JMP CheckExtraLife
Score500:
    ADD [SCORE], 500

CheckExtraLife:
    MOV AX, [SCORE]
    CMP AX, [SCORE_EXTRA_LIFE]
    JB DmgDone
    ADD WORD PTR [SCORE_EXTRA_LIFE], 20000
    INC BYTE PTR [LIVES]
    CALL UPDATE_HUD_SCORE
    CALL UPDATE_HUD_LIVES
    JMP DmgDone

DmgNext:
    INC SI
    LOOP FindEnemyLp
DmgDone:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
DAMAGE_ENEMY ENDP

;===========================================================================
; WALL SYSTEM
;===========================================================================

DECREMENT_WALL_TIMERS PROC
    PUSH CX
    MOV CX, [WALL_TIMER_COUNT]
    CMP CX, 0
    JE WallTickDone
    XOR SI, SI
WallTickLp:
    CMP [WALL_TIMER_TICKS + SI], 0
    JE WTNext
    DEC WORD PTR [WALL_TIMER_TICKS + SI]
    JNZ WTNext
    MOV AL, [WALL_TIMER_X + SI]
    MOV BL, [WALL_TIMER_Y + SI]
    MOV DL, 0
    CALL SET_MAP_TILE
    CALL GRID_TO_PIXEL_X
    MOV [TEMP_X], AX
    MOV AL, [WALL_TIMER_Y + SI]
    CALL GRID_TO_PIXEL_Y
    MOV BX, AX
    MOV AX, [TEMP_X]
    PUSH SI
    CALL ERASE_SPRITE
    POP SI
    DEC [WALL_TIMER_COUNT]
WTNext:
    ADD SI, 1
    LOOP WallTickLp
WallTickDone:
    POP CX
    RET
DECREMENT_WALL_TIMERS ENDP

DAMAGE_WALL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

    MOV AL, BYTE PTR [TEMP_X]
    MOV BL, BYTE PTR [TEMP_Y]
    CALL GET_MAP_TILE
    CMP AL, 1
    JNE DmgWallDone

    MOV DL, 80h
    MOV AL, BYTE PTR [TEMP_X]
    MOV BL, BYTE PTR [TEMP_Y]
    CALL SET_MAP_TILE

    MOV AL, BYTE PTR [TEMP_X]
    CALL GRID_TO_PIXEL_X
    MOV [TEMP_X], AX
    MOV AL, BYTE PTR [TEMP_Y]
    CALL GRID_TO_PIXEL_Y
    MOV BX, AX
    MOV AX, [TEMP_X]
    LEA SI, SPRITE_WALL_CRUMBLE
    CALL DRAW_SPRITE_SOLID

    MOV SI, [WALL_TIMER_COUNT]
    CMP SI, 8
    JAE DmgWallDone
    MOV AL, BYTE PTR [TEMP_X]
    MOV [WALL_TIMER_X + SI], AL
    MOV AL, BYTE PTR [TEMP_Y]
    MOV [WALL_TIMER_Y + SI], AL
    MOV AX, [WALL_CRUMBLE_TIME]
    MOV [WALL_TIMER_TICKS + SI], AX
    INC [WALL_TIMER_COUNT]

DmgWallDone:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
DAMAGE_WALL ENDP

;===========================================================================
; SCORING AND WIN/LOSE
;===========================================================================

CHECK_WIN_CONDITION PROC
    CMP [GAME_STATE], 2
    JE WinDone
    CMP BYTE PTR [EFFIGY_ALIVE], 0
    JE LoseGame
    CMP BYTE PTR [ENEMIES_REMAINING], 0
    JNE CheckAllDead
    XOR CX, CX
    XOR SI, SI
CntAlive:
    CMP [ENEMY_ACTIVE + SI], 1
    JNE CntNext2
    INC CX
CntNext2:
    INC SI
    CMP SI, MAX_ENEMIES
    JL CntAlive
    CMP CX, 0
    JNE WinDone
    INC BYTE PTR [CURRENT_LEVEL]
    CALL INIT_GAMEPLAY
    JMP WinDone

CheckAllDead:
WinDone:
    CMP BYTE PTR [PLAYER_ALIVE], 0
    JNE WRet
    DEC BYTE PTR [LIVES]
    CMP BYTE PTR [LIVES], 0
    JE LoseGame
    CALL RESPAWN_PLAYER
    JMP WRet

LoseGame:
    MOV [GAME_STATE], 2
    MOV [GAME_OVER_TIMER], 210
    MOV AX, [SCORE]
    CMP AX, [HI_SCORE]
    JBE WRet
    MOV [HI_SCORE], AX

WRet:
    RET
CHECK_WIN_CONDITION ENDP

RESPAWN_PLAYER PROC
    MOV [PLAYER_GRID_X], 6
    MOV [PLAYER_GRID_Y], 11
    MOV [PLAYER_PIXEL_X], 96
    MOV [PLAYER_PIXEL_Y], 184
    MOV [PLAYER_DIR], 0
    MOV [PLAYER_COOLDOWN], 60
    MOV [PLAYER_POWERUP], 0
    MOV [PLAYER_MAX_BULLETS], 1
    MOV [PLAYER_BULLET_COUNT], 0
    MOV [PLAYER_ALIVE], 1
    MOV [PLAYER_HP], 1
    RET
RESPAWN_PLAYER ENDP

;===========================================================================
; TITLE SCREEN
;===========================================================================

UPDATE_TITLE PROC
    PUSH AX
    PUSH BX
    PUSH SI

    INC [TITLE_FLASH_TIMER]
    CMP [TITLE_FLASH_TIMER], 35
    JB TitleInput
    MOV [TITLE_FLASH_TIMER], 0
    XOR BYTE PTR [TITLE_FLASH_STATE], 1

TitleInput:
    CMP [KEY_ENTER], 1
    JNE TitleNoStart
    MOV [KEY_ENTER], 0
    CALL INIT_GAMEPLAY
    JMP TitleDone

TitleNoStart:
    CMP [TITLE_FLASH_STATE], 1
    JE TitleDraw
    MOV AX, 80
    MOV BX, 100
    LEA SI, SPRITE_BLACK
    CALL DRAW_SPRITE_SOLID
    JMP TitleDone

TitleDraw:
    MOV AX, 80
    MOV BX, 100
    LEA SI, STR_PRESS_START
    CALL PRINT_STRING
    CALL UPDATE_HUD_HISCORE

TitleDone:
    POP SI
    POP BX
    POP AX
    RET
UPDATE_TITLE ENDP

;===========================================================================
; GAME OVER SCREEN
;===========================================================================

UPDATE_GAME_OVER PROC
    CMP [GAME_OVER_TIMER], 210
    JNE GODisplay

    CALL CLEAR_GAME_AREA
    CALL DRAW_HUD_STATIC

GODisplay:
    DEC [GAME_OVER_TIMER]
    JNZ GOWait

    MOV [CURRENT_LEVEL], 1
    MOV [SCORE], 0
    MOV [SCORE_EXTRA_LIFE], 20000
    MOV [GAME_STATE], 0
    CALL CLEAR_GAME_AREA
    CALL DRAW_HUD_STATIC
    CALL UPDATE_HUD_HISCORE
    RET

GOWait:
    MOV AX, 70
    MOV BX, 100
    LEA SI, STR_GAME_OVER
    CALL PRINT_STRING
    RET
UPDATE_GAME_OVER ENDP

;===========================================================================
; PAUSE SCREEN
;===========================================================================

UPDATE_PAUSE PROC
    CMP [KEY_ENTER], 1
    JNE PauseWait
    MOV [KEY_ENTER], 0
    CMP [GAME_STATE], 3
    JNE PauseWait
    MOV [GAME_STATE], 1
    RET

PauseWait:
    MOV AX, 80
    MOV BX, 100
    LEA SI, STR_PAUSED
    CALL PRINT_STRING
    RET
UPDATE_PAUSE ENDP

    END
