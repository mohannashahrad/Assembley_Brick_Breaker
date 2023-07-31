.286
.model small
.stack 100h
.data
	studentID db "260972325$" ; change the content of the string to your studentID (do not remove the $ at the end)
	ball_x dw 160	 ; Default value: 160
	ball_y dw 144	 ; Default value: 144
	ball_x_vel dw 0	 ; Default value: 0
	ball_y_vel dw -1 ; Default value: -1 
	paddle_x dw 144  ; Default value: 144
	paddle_length dw 32 ; Default value: 32
	remaining_iterations dw 0
	last_score_activated dw 0
	laser_x dw -1
	laser_y dw -1

.code

; get the functions from the util_br.obj file (needs to be linked)
EXTRN setupGame:PROC, drawBricks:PROC, checkBrickCollision:PROC, sleep:PROC, decreaseLives:PROC, getScore:PROC, clearPaddleZone:PROC

; draw the pixel indicating the ball's position
drawBall: 

	push bp
	mov	bp, sp
	push ax

	; Erase the ball at current position
	push ball_y
	push ball_x
	push 00h
	call drawPixel

	; Updating the new coordinates based on velocity
	mov ax, ball_x
	add ax, ball_x_vel
	mov ball_x, ax

	mov ax, ball_y
	add ax, ball_y_vel
	mov ball_y, ax

	; Drawing the new place of the ball
	push ball_y
	push ball_x
	push 0Fh
	call drawPixel

	pop ax 
	mov sp, bp
	pop bp
	
	ret


; draw a single pixel specific to Mode 13h (320x200 with 1 byte per color)
drawPixel:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]

	push	bp
	mov	bp, sp

	push	bx
	push	cx
	push	dx
	push	es

	; set ES as segment of graphics frame buffer
	mov	ax, 0A000h
	mov	es, ax


	; BX = ( y1 * 320 ) + x1
	mov	bx, x1
	mov	cx, 320
	xor	dx, dx
	mov	ax, y1
	mul	cx
	add	bx, ax

	; DX = color
	mov	dx, color

	; plot the pixel in the graphics frame buffer
	mov	BYTE PTR es:[bx], dl

	pop	es
	pop	dx
	pop	cx
	pop	bx

	pop	bp

	ret	6	

checkPaddleLength:
	push bp
	mov	bp, sp
	push ax 

	mov ax, remaining_iterations
	cmp ax, 0
	je exitCheckPaddleLength

	dec ax
	mov remaining_iterations, ax
	cmp ax, 0
	jne exitCheckPaddleLength		; change of paddle is not needed
	mov ax, 32
	mov paddle_length, ax

exitCheckPaddleLength:	
	pop ax 
	mov sp, bp
	pop bp
	ret 

drawLaser:
	push bp
	mov	bp, sp

	; Erase the laser at current position
	push laser_y
	push laser_x
	push 00h
	call drawPixel

	; Updating the new coordinates based on velocity
	mov ax, laser_y
	dec ax
	mov laser_y, ax

	; Drawing the new place of the ball
	push laser_y
	push laser_x
	push 2Ch
	call drawPixel

	mov sp, bp
	pop bp
	ret 

handleLaserCollisions:
	push bp
	mov	bp, sp
	push bx

	; check brick collision
	push -1
	push 0
	push laser_y
	push laser_x
	call checkBrickCollision

	; the result of the previous call will be in ax
	cmp ax, 0
	jne handleCollide

	; if No brick collision, then check wall collision
	push laser_y
	push laser_x
	call checkWallCollision

	; the result of the previous call will be in AX and we return that
	cmp ax, 0
	jne handleCollide
	jmp returnTheValue
handleCollide: 
	; Erase the laser at current position
	push laser_y
	push laser_x
	push 00h
	call drawPixel

	; set laser coordinates to its original
	mov bx, -1	
	mov laser_x, bx
	mov laser_y, bx


returnTheValue:
	pop bx 
	mov sp, bp
	pop bp
	ret 


handleCollisions:
	push bp
	mov	bp, sp

	push ax
	push bx

	push ball_y_vel
	push ball_x_vel
	push ball_y
	push ball_x
	call checkBrickCollision

	; the result of the previous call will be in ax
	cmp ax, 1
	je invertXVel
	cmp ax, 2
	je  invertYVel
	cmp ax, 3
	je invertBoth

	call checkPaddleCollision

	cmp ax, 0
	je moveToWallCollisionHandler

	cmp ax, 1
	je handlePaddleCollisionLeft

	cmp ax, 2
	je handlePaddleCollisionMiddle

	cmp ax, 3
	je handlePaddleCollisionRight

handlePaddleCollisionLeft:	
	mov bx, -1
	mov ball_x_vel, bx
	mov ball_y_vel, bx
	jmp ExitHandleCollisions
handlePaddleCollisionMiddle:	
	mov bx, 0
	mov ball_x_vel, bx
	mov bx, -1
	mov ball_y_vel, bx
	jmp ExitHandleCollisions
handlePaddleCollisionRight:	
	mov bx, 1
	mov ball_x_vel, bx
	mov bx, -1
	mov ball_y_vel, bx	
	jmp ExitHandleCollisions	


moveToWallCollisionHandler:
	push ball_y
	push ball_x
	call checkWallCollision

	; the result of the previous call will be in ax
	cmp ax, 1
	je invertXVel
	cmp ax, 2
	je  invertYVel
	cmp ax, 3
	je invertBoth
	jmp ExitHandleCollisions

invertXVel:
	neg ball_x_vel
	jmp ExitHandleCollisions
invertYVel:
	neg ball_y_vel
	jmp ExitHandleCollisions
invertBoth:
	neg ball_x_vel
	neg ball_y_vel
ExitHandleCollisions:
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret 


checkWallCollision: 

	x EQU ss:[bp+4]
	y EQU ss:[bp+6]

	push bp
	mov	bp, sp
	push bx

	mov bx, x
	cmp bx, 16
	je leftWall
	cmp bx, 303
	je rightWall
	mov bx, y
	cmp bx, 32
	je topWall
	; if none of the above branches -> return 0
	jmp other

leftWall:
	mov bx, y
	cmp bx, 33
	jge leftWallHandler
	cmp bx, 32
	je nextToCornerHandler
leftWallHandler:
	; the function returns 1
	mov ax, 1	
	jmp exitWallCollision
rightWall:
	mov bx, y
	cmp bx, 33
	jge rightWallHandler
	cmp bx, 32
	je nextToCornerHandler
rightWallHandler:
	; the function returns 1
	mov ax, 1
	jmp exitWallCollision	
nextToCornerHandler:
	; the function returns 3
	mov ax, 3	
	jmp exitWallCollision
topWall:
	mov bx, x
	cmp bx, 17
	jl other
	cmp bx, 302
	jg other 
	mov ax, 2
	jmp exitWallCollision	
other:
	; if none of the above branches -> return 0
	mov ax, 0
exitWallCollision:
	pop bx

	mov sp, bp
	pop bp
	ret 4

; returns number of lives in register ax
resetAfterBallLoss:
	push bp
	mov	bp, sp
	push bx

	; reset values
	mov ball_x, 160
	mov ball_y, 144
	mov ball_x_vel, 0
	mov ball_y_vel, -1
	mov paddle_x, 144
	mov paddle_length, 32

	; draw pixel at new locations
	push ball_y
	push ball_x
	push 0Fh
	call drawPixel

	; decrease life -> stores the remaining lives in AX
	call decreaseLives

	; draw paddle again
	call drawPaddle

	; updating the remaining_iterations if it was changed
	mov remaining_iterations, 0

	; if laser was there
	cmp laser_x, -1
	je exitReset
	; Erase the laser at current position
	push laser_y
	push laser_x
	push 00h
	call drawPixel

	; set the laser coordinates to its defaults
	mov bx, -1
	mov laser_x, -1
	mov laser_y, -1

exitReset:
	pop bx
	mov sp, bp
	pop bp
	ret

drawLine_h:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y EQU ss:[bp+8]
	x2 EQU ss:[bp+10]

	push	bp
	mov	bp, sp
	push ax

hlineLoop:
	mov ax, x1
	cmp ax, x2
	jg drawHLineEnd

	push	y	; input y 
	push	x1	; input x1
	push	color	; input color
	call	drawPixel	

	inc x1
	jmp hlineLoop

drawHLineEnd:
	pop ax
	mov bp, sp
	pop bp

	ret 8

drawLine_v:
	color EQU ss:[bp+4]
	x EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	y2 EQU ss:[bp+10]

	push	bp
	mov	bp, sp
	push ax

vlineLoop:
	mov ax, y1
	cmp ax, y2
	jg drawVLineEnd

	push	y1	; input y 
	push	x	; input x1
	push	color	; input color
	call	drawPixel	

	inc y1
	jmp vlineLoop

drawVLineEnd:
	pop ax
	mov bp, sp
	pop bp

	ret 8

drawPaddle:

	push bp
	mov	bp, sp
	
	push ax
	push bx
	push cx

	; clear the paddle zone 
	call clearPaddleZone

	; draw the left rectangle
	push	187			; y2
	push	184			; y1
	push	paddle_x	; x
	push	2Ch			; color 
	call	drawLine_v

	mov ax, paddle_length	; ax = paddle_length
	mov bx, 4
	sub ax, bx				; ax = paddle_length - 4
	mov bx, 2
	xor dx,dx
	div bx					; ax = (paddle_length - 4)/2
	mov bx, paddle_x
	add ax, bx				; ax = paddle_x + (paddle_length - 4)/2

	push	187			; y2
	push	184			; y1
	push	ax			; x
	push	2Ch			; color 
	call	drawLine_v

	push	ax			; x2 
	push	184			; y 
	push	paddle_x	; x1 
	push	2Ch			; color
	call	drawLine_h

	push	ax			; x2 
	push	187			; y 
	push	paddle_x	; x1 
	push	2Ch			; color
	call	drawLine_h

	; draw the middle rectangle
	add ax, 1
	mov bx, ax
	add bx, 4

	push	187			; y2
	push	184			; y1
	push	ax			; x
	push	2Dh			; color 
	call	drawLine_v

	push	187			; y2
	push	184			; y1
	push	bx			; x
	push	2Dh			; color 
	call	drawLine_v

	push	bx			; x2 
	push	184			; y 
	push	ax	; x1 
	push	2Dh			; color
	call	drawLine_h

	push	bx			; x2 
	push	187			; y 
	push	ax	; x1 
	push	2Dh			; color
	call	drawLine_h

	; draw the right rectangle
	add bx, 1
	mov cx, bx 				; cx : the start position

	mov ax, paddle_length	; ax = paddle_length
	mov bx, 4
	sub ax, bx				; ax = paddle_length - 4
	mov bx, 2			
	xor dx,dx
	div bx					; ax = (paddle_length - 4)/2
	mov bx, cx				; bx = start_position 				
	add ax, cx 				; ax = start_position + (paddle_length - 4)/2

	push	187			; y2
	push	184			; y1
	push	ax			; x
	push	2Eh			; color 
	call	drawLine_v

	push	187			; y2
	push	184			; y1
	push	bx			; x
	push	2Eh			; color 
	call	drawLine_v

	push	ax			; x2 
	push	184			; y 
	push	bx			; x1 
	push	2Eh			; color
	call	drawLine_h

	push	ax			; x2 
	push	187			; y 
	push	bx			; x1 
	push	2Eh			; color
	call	drawLine_h

	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret

get_pixel: 				; Returns the color of a specific pixel in AX
	x1 EQU ss:[bp+4]
	y1 EQU ss:[bp+6]

	push bp
	mov bp, sp

	push bx
	push cx 
	push dx
	push es

	mov ax, 0A000h 
	mov es, ax

	; BX = ( y1 * 320 ) + x1
	mov	bx, x1
	mov	cx, 320
	xor	dx, dx
	mov	ax, y1
	mul	cx
	add	bx, ax


	mov	al, BYTE PTR es:[bx]
	xor ah, ah

	pop es
	pop dx
	pop cx
	pop bx

	mov sp, bp
	pop bp
	ret 4 

; return values are stored in ax
checkPaddleCollision:
	push bp
	mov	bp, sp

	push bx

	mov bx, ball_y
	cmp bx, 183
	je handlePaddleCollision
	jmp OtherPaddleHandler

handlePaddleCollision: 
	mov bx, ball_y
	add bx, 1		; bx = ball_y + 1

	push bx
	push ball_x
	call get_pixel	; ax = color of that pixel

	cmp ax , 0
	je OtherPaddleHandler

	cmp ax, 2Ch
	je aboveLeftSection

	cmp ax, 2Dh
	je aboveMiddleSection

	cmp ax, 2Eh
	je aboveRightSection

aboveLeftSection:
	mov ax, 1
	jmp exitPaddleCollision

aboveMiddleSection:
	mov ax, 2
	jmp exitPaddleCollision

aboveRightSection:
	mov ax, 3
	jmp exitPaddleCollision	

OtherPaddleHandler:
	mov ax, 0	; return value is 0
	
exitPaddleCollision:
	pop bx

	mov sp, bp
	pop bp
	ret 

pushUpOne:
	push bp
	mov	bp, sp
	push bx

	mov bx, 64
	mov paddle_length, bx
	mov bx, 500
	mov remaining_iterations, bx

	; updating the "last_score_activated" for next power-ups
	call getScore
	mov last_score_activated, ax

	pop bx 
	mov sp, bp
	pop bp
	ret 

pushUpTwo:
	push bp
	mov	bp, sp
	push ax 
	push bx

	mov ax, paddle_length
	mov bx, 2
	xor dx,dx
	div bx			; ax = paddle_length/2
	mov bx, paddle_x
	add ax, bx 		; ax = paddle_length/2 + paddle_x
	mov laser_x, ax
	mov bx, 183
	mov laser_y, bx

	; updating the "last_score_activated" for next power-ups
	call getScore
	mov last_score_activated, ax

	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 

start:
        mov ax, @data
        mov ds, ax
	
	push OFFSET studentID ; do not change this, change the string in the data section only
	push ds
	call setupGame ; change video mode, draw walls & write score, studentID and lives
	call drawBricks

main_loop:
	call sleep
	call checkPaddleLength
	call drawPaddle
	call drawBall
	cmp laser_x, -1
	je continue
	call drawLaser
continue:
	call handleCollisions
	call handleLaserCollisions

	mov ax, ball_y
	cmp ax, 199
	jl keypressCheck		; if ball_y < 199						
	call resetAfterBallLoss	; if ball_y > 199 ; ax = remaining lives 
	cmp ax, 0
	jg keyboardInput
keypressCheck:
	mov ah, 01h ; check if keyboard is being pressed
	int 16h ; zero flag (zf) is set to 1 if no key pressed
	jz main_loop ; if zero flag set to 1 (no key pressed), loop back
keyboardInput:
	; else get the keyboard input
	mov ah, 00h
	int 16h

	cmp al, 1bh
	jne keyboardHandler
	jmp exit
	
keyboardHandler:
	cmp al, 61h		; "a"
	je paddleLeft

	cmp al, 41h		; "A"
	je paddleLeft

	cmp al, 64h		; "d"
	je paddleRight

	cmp al, 44h		; "D"
	je paddleRight

	cmp al, 31h		; "1"
	je checkScoreEligibilityOne

	cmp al, 32h		; "2"
	je checkScoreEligibilityTwo
	jmp main_loop

checkScoreEligibilityOne: 
	call getScore	; returns score in AX
	mov bx, last_score_activated
	add bx, 50
	cmp ax, bx		; compare curr score and last_score_activated+50
	jl main_loop	; if not enough score got back to main loop
	call pushUpOne
	jmp main_loop	
checkScoreEligibilityTwo: 
	call getScore	; returns score in AX
	mov bx, last_score_activated
	add bx, 50
	cmp ax, bx		; compare curr score and last_score_activated+50
	jge ToFunction	; if not enough score got back to main loop
	jmp main_loop
ToFunction:	
	call pushUpTwo
	jmp main_loop		
paddleLeft: 
	; subtract 8 from paddle_x
	mov ax, paddle_x
	sub ax, 8
	mov paddle_x, ax	
	cmp ax , 0
	jle handlePaddleLeft
	jmp main_loop
handlePaddleLeft:	
	mov ax, 0
	mov paddle_x, ax
	jmp main_loop
paddleRight:	
	; add 8 to paddle_x
	mov ax, paddle_x
	add ax, 8
	mov paddle_x, ax	
	add ax, paddle_length
	cmp ax , 320
	jge handlePaddleRight
	jmp main_loop
handlePaddleRight:	
	mov ax, 320
	sub ax, paddle_length
	mov paddle_x, ax
	jmp main_loop
exit:
        mov ax, 4f02h	; change video mode back to text
        mov bx, 3
        int 10h

        mov ax, 4c00h	; exit
        int 21h

END start

