INCLUDE Irvine32.inc

main	EQU start@0

.stack 4096

DetectShoot proto								;�����O�_�g���A�I�sBulletShoot�C
BulletShoot proto,planeX:word,planeY:word		;���a�g���A�I�sBulletMove�C
BulletMove proto								;���a�l�u���ʡA�I�sDetectMove�C
DetectMove proto								;�������� �����ϥ� �I�sMovRight,MovLeft�C
MovRight proto									;�k���C
MovLeft proto									;�����C
AllyRevive proto								;���a�_���C
EnemyMove proto, enemyP:coord					;�Ĥ貾�ʡC
EnemyAttack proto,enemyX:word,enemyY:word 		;�Ĥ�g���A�I�sAttackMove�C
AttackMove proto 								;�Ĥ�l�u���ʡC
EnemyRevive proto								;�Ĥ�_���C
WriteHP proto                                   ;��ܦ�q�C
WriteScore proto                                ;��ܤ��ơC
enemyDisappear proto, enemyP:coord              ;���h�Ĥ譸���C
.data
titleStr byte "----- Plane War -----",0         ;�D���x�������D�C

;��l�e���C
startLogo0 byte " /$$$$$$$$  /$$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$  /$$$$$$$$          /$$$$$  /$$$$$$  /$$      /$$"
startLogo1 byte "| $$_____/ /$$__  $$| $$__  $$| $$_____/ /$$__  $$|__  $$__/         |__  $$ /$$__  $$| $$$    /$$$"
startLogo2 byte "| $$      | $$  \ $$| $$  \ $$| $$      | $$  \__/   | $$               | $$| $$  \ $$| $$$$  /$$$$"
startLogo3 byte "| $$$$$   | $$  | $$| $$$$$$$/| $$$$$   |  $$$$$$    | $$               | $$| $$$$$$$$| $$ $$/$$ $$"
startLogo4 byte "| $$__/   | $$  | $$| $$__  $$| $$__/    \____  $$   | $$          /$$  | $$| $$__  $$| $$  $$$| $$"
startLogo5 byte "| $$      | $$  | $$| $$  \ $$| $$       /$$  \ $$   | $$         | $$  | $$| $$  | $$| $$\  $ | $$"
startLogo6 byte "| $$      |  $$$$$$/| $$  | $$| $$$$$$$$|  $$$$$$/   | $$         |  $$$$$$/| $$  | $$| $$ \/  | $$"
startLogo7 byte "|__/       \______/ |__/  |__/|________/ \______/    |__/          \______/ |__/  |__/|__/     |__/"
startLogo8 byte "###################################################################################################"
startLogo9 byte "                          --press 'g' to start--                               "
startLogo10 byte "                      --press 'h' to introduction--                            "
startColor word lengthof startLogo0 DUP (0Dh)       							;��l�e���C��C
startPos COORD <20,10>    													    ;��l�e�����ø�s�y�СC

;�C�����еe���C
introduction1 byte "how to pilot the airplane:"
introduction2 byte "left->press 'i', right->press 'p'."
introduction3 byte "how to fire bullets:"
introduction4 byte "press 's' for firing bullets."
introduction5 byte "If you are hit by an enemy bullet, you will lose 100 HP."
introduction6 byte "please press 'g' to start."
introductionPos COORD <20,7>													;�C�����еe�����ø�s�y�СC
score word 1              														;�ΥH�Ĥ譸���b���ʲĴX���ɦA�X�{�U�@�x�C

;�����˦��C
allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
allyAttr WORD 11 DUP(0Bh)														;�����C��C
allyDisAttr WORD 11 DUP (00h)													;���������C��C
allyPosition COORD <40,25>														;������l��m�C
allyCondition byte 1															;�������A 1������,0�������_�����C
allyHP dword 500 		    													;������q�C
allyScore Dword 0																;�����o���C
bullet byte '8'																	;�l�u�˦��C
bulletPos COORD <?,?>															;�l�u��m�C
bulletAttr word 0Bh																;�l�u�C��C
bulletDisappearAttr word 00h													;�l�u�����C��C

;�ĤH�˦��C
enemyTop BYTE " ___ "
enemyBody BYTE "-\*/-"
enemyBottom BYTE "  *  "
enemyAttr word 5 DUP(0Ch)						;�ĤH�����C��C
enemyDisappearAttr word 5 DUP(00h)				;�ĤH���������C��C
enemyPosition COORD <60,0>						;�ĤH������l��m�C
enemy1Position COORD <60,0>
enemy2Position COORD <40,0>
enemy3Position COORD <30,0>
enemy4Position COORD <80,0>
enemy5Position COORD <70,0>
enemy6Position COORD <50,0>
enemyCondition byte 1							;�ĤH�������A 1������,0���Q�����C
Attack byte '.'									;�ĤH�l�u�˦��C
AttackPos COORD <?,?>							;�ĤH�l�u��m�C
AttackAttr word 0Ah								;�ĤH�l�u�C��C
AttackDisappearAttr word 0						;�ĤH�l�u�����C��C

outputHandle DWORD 0 							;CONSOLE ����ID�C
bytesWritten DWORD ?							;�^�ǭȡC
count DWORD 0									;�^�ǭȡC
cellsWritten DWORD ?							;�_�Ǫ��^�ǭȡC

input byte ?									;�ܼư����O�_��S�C
inputMov byte ?									;�ܼư����O�_��i��p�C
inputQuit byte ?								;�ܼư����O�_��ESC�C

hp BYTE 'HP:'
hpPosition COORD <1,1>                          ;HP��m�C
allyhpPosition COORD <4,1>                      ;��q�Ȧ�m�C
hpAttr word 3 DUP(0Ah)                          ;��q����C��C

Scorew BYTE "SCORE:"
ScorePosition COORD <1,2>                       ;SCORE��m�C
allyScorePosition COORD <7,2>                   ;���ƭȦ�m�C
ScoreAttr word 6 DUP(0Ah)                       ;��������C��C

;�����e���C
endLogo0 byte "###############################################################################"
endLogo1 byte "||==|        |=========|  |========|  |========|  |========|     |=========|  |"
endLogo2 byte "||  |        |  _____  |  |  ______|  |  ______|  |   __   |     |______   |  |"
endLogo3 byte "||  |        |  |   |  |  |  |_____   |  |_____   |  |  |  |         ___|  |  |"
endLogo4 byte "||  |        |  |   |  |  |_____   |  |   _____|  |  |__|  |        |   ___|  |"
endLogo5 byte "||  |______  |  |___|  |   _____|  |  |  |______  |  ____  |        |__|      |"
endLogo6 byte "||        |  |         |  |        |  |        |  |  |   \ \         __       |"
endLogo7 byte "||========|  |=========|  |========|  |========|  |==|    \=\       |__|      |"
endLogo8 byte "###############################################################################"
endLogo9 byte "                          --press 'anychar' to end--                           "
endColor word lengthof endLogo0 DUP (0Dh)
endPos COORD <20,10>

.code
main proc

	INVOKE SetConsoleTitle, offset titleStr        ;�]�w�D���x�������D�C
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE         
    mov outputHandle, eax
	
	;ø�sStartlogo(��l�e��)�C
    INVOKE WriteConsoleOutputAttribute,            
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo0,
		lengthof startLogo0,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo1,
		lengthof startLogo1,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo2,
		lengthof startLogo2,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo3,
		lengthof startLogo3,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo4,
		lengthof startLogo4,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo5,
		lengthof startLogo5,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo6,
		lengthof startLogo6,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo7,
		lengthof startLogo7,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo8,
		lengthof startLogo8,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo9,
		lengthof startLogo9,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo10,
		lengthof startLogo10,
		startPos,
		offset bytesWritten
q:
    call ReadChar                			 ;�����n�}�l�C���٬O�ݤ��СC
    .if al=='s'
		call Clrscr
    jmp start
    .elseif al=='h'
        jmp introduction
    .else
        jmp q
    .endif
	
	;ø�sIntroduction�C
    introduction:
        call Clrscr
        INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction1,
		lengthof introduction1,
		introductionPos,
		offset bytesWritten
    inc introductionPos.Y
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction2,
		lengthof introduction2,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 2
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction3,
		lengthof introduction3,
		introductionPos,
		offset bytesWritten
    inc introductionPos.Y
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction4,
		lengthof introduction4,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 2
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction5,
		lengthof introduction5,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 3
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction6,
		lengthof introduction6,
		introductionPos,
		offset bytesWritten
p:
    call ReadChar                			   ;�����n���n�}�l�C���C
    .if al=='g'
		call Clrscr
    .else
        jmp p
    .endif
	
start:

	;ø�s��l�ͭx�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y, 3                	  ;y�b�զ^��l��m�C

	;ø�s��l��q�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec

	;ø�s��l���ơC
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

control:

    .if score>0
		;�Y�ĭx��̤U��A�ĭx�����ñq���N�̤W���m���s�X�{�C
		.if enemy1Position.Y>22                       
			INVOKE enemyDisappear, enemy1Position     ;�U��ĭx�����C
            sub allyScore,1000                        ;�����ܦ^���T����(enemyDisappear�̷|��1000��)�C
            call WriteScore
			mov ax,100
			call RandomRange
            add ax,12                                 ;����ĭx�q���ơBHP����m�X�{�C
            mov enemy1Position.X,ax                   ;�ĭxX�y�г]�H����m�C
            mov enemy1Position.Y,0                    ;�ĭx����̤W��C
        .endif
		INVOKE EnemyMove,enemy1Position               ;�ĭx���ʡC
        inc enemy1Position.Y
    .endif
    .if score>4
        .if enemy2Position.Y>22
			INVOKE enemyDisappear, enemy2Position
            sub allyScore,1000
            call WriteScore
            mov ax, 100
            call RandomRange
            add ax,12
            mov enemy2Position.X,ax
            mov enemy2Position.Y,0
        .endif
		INVOKE EnemyMove,enemy2Position
        inc enemy2Position.Y
    .endif
    .if score>9
        .if enemy3Position.Y>22
            INVOKE enemyDisappear, enemy3Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy3Position.X,ax
            mov enemy3Position.Y,0
        .endif
		INVOKE EnemyMove,enemy3Position
		inc enemy3Position.Y
    .endif
    .if score>14
        .if enemy4Position.Y>22
            INVOKE enemyDisappear, enemy4Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy4Position.X,ax
            mov enemy4Position.Y, 0
		.endif
		INVOKE EnemyMove,enemy4Position
        inc enemy4Position.Y
    .endif
    .if score>19
        .if enemy5Position.Y>22
            INVOKE enemyDisappear, enemy5Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
			call RandomRange
            add ax,12
            mov enemy5Position.X,ax
            mov enemy5Position.Y,0
        .endif
		INVOKE EnemyMove,enemy5Position
        inc enemy5Position.Y
    .endif
    .if score>24
        .if enemy6Position.Y>22
            INVOKE enemyDisappear, enemy6Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy6Position.X,ax
            mov enemy6Position.Y,0
        .endif
		INVOKE EnemyMove,enemy6Position
        inc enemy6Position.Y
    .endif
	invoke DetectShoot	             				   ;�����g���C
	invoke DetectMove								   ;�������ʡC
	jmp control								    	   ;�j�����ĤH�U���C

main endp

;��ܦ�q�C
WriteHP proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec

	ret
WriteHP endp

WriteScore proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

	ret
WriteScore endp

;�ͤ谻���g���C
DetectShoot proc
    INVOKE Sleep,15
    call ReadKey
    mov input,al
.IF input=='s'
    INVOKE BulletShoot,allyPosition.X,allyPosition.Y
.endif
	ret
DetectShoot endp

;�ͤ�l�u�g���C
BulletShoot proc USES eax edx ecx ebx,
	planeX:word,
	planeY:word                							;�n��planeX,planeY�C

    mov ax,planeX
    mov dx,planeY
	add ax,5                 							;�y�о��^�l�u�ӥX�{����m�C
	sub dx,4                  							;�P�W�C
    mov bulletPos.X,ax
    mov bulletPos.Y,dx

bulletup:
	.if bulletPos.Y!=0
		INVOKE BulletMove      							;�l�u�V�W���ʡC
		jmp checkX
	.else
		jmp endshoot
	.endif
	
;�T�{�Ĥ観�S���Q�ڤ�l�u�g���C
checkX:
	mov cx, enemy1Position.X
	mov bx, enemy1Position.Y        					;enemy1Position�s�J�Ȧs���C
	inc bx
        sub cx, bulletPos.X         					;cx�Ω�P�_�l�u�����Ĥ�C
	.if cx==0
		jmp check1Y
	.elseif cx==-1
		jmp check1Y
	.elseif cx==-2
		jmp check1Y
	.elseif cx==-3
		jmp check1Y
	.elseif cx==-4
		jmp check1Y
	.endif
    mov cx, enemy2Position.X
	mov bx, enemy2Position.Y    						;enemy2Position�s�J�Ȧs���C
	inc bx
    sub cx, bulletPos.X          						;cx�Ω�P�_�l�u�����Ĥ�C
	.if cx==0
		jmp check2Y
	.elseif cx==-1
		jmp check2Y
	.elseif cx==-2
		jmp check2Y
	.elseif cx==-3
		jmp check2Y
	.elseif cx==-4
		jmp check2Y
	.endif
    mov cx, enemy3Position.X
	mov bx, enemy3Position.Y     						;enemy3Position�s�J�Ȧs���C
	inc bx
    sub cx, bulletPos.X          						;cx�Ω�P�_�l�u�����Ĥ�C
	.if cx==0
		jmp check3Y
	.elseif cx==-1
		jmp check3Y
	.elseif cx==-2
		jmp check3Y
	.elseif cx==-3
		jmp check3Y
	.elseif cx==-4
		jmp check3Y
	.endif
    mov cx, enemy4Position.X
	mov bx, enemy4Position.Y     						;enemy4Position�s�J�Ȧs���C
	inc bx
    sub cx, bulletPos.X          						;cx�Ω�P�_�l�u�����Ĥ�C
	.if cx==0
		jmp check4Y
	.elseif cx==-1
		jmp check4Y
	.elseif cx==-2
		jmp check4Y
	.elseif cx==-3
		jmp check4Y
	.elseif cx==-4
		jmp check4Y
	.endif
    mov cx, enemy5Position.X
	mov bx, enemy5Position.Y     						;enemy5Position�s�J�Ȧs���C
	inc bx
    sub cx, bulletPos.X         						;cx�Ω�P�_�l�u�����Ĥ�C
	.if cx==0
		jmp check5Y
	.elseif cx==-1
		jmp check5Y
	.elseif cx==-2
		jmp check5Y
	.elseif cx==-3
		jmp check5Y
	.elseif cx==-4
		jmp check5Y
	.endif
    mov cx, enemy6Position.X
	mov bx, enemy6Position.Y     						;enemy6Position�s�J�Ȧs���C
	inc bx
    sub cx, bulletPos.X          						;cx�Ω�P�_�l�u�����Ĥ�C
       	.if cx==0
		jmp check6Y
	.elseif cx==-1
		jmp check6Y
	.elseif cx==-2
		jmp check6Y
	.elseif cx==-3
		jmp check6Y
	.elseif cx==-4
		jmp check6Y
    .else
        jmp bulletup
	.endif
	
;�i�@�B�T�{Y�y�ЬO�_�ۦP�C
check1Y:                        
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy1Position
        mov enemy1Position.Y,31
	    jmp endshoot
    .else
        jmp bulletup
	.endif
check2Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy2Position
        mov enemy2Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check3Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy3Position
        mov enemy3Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check4Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy4Position
        mov enemy4Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check5Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy5Position
        mov enemy5Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check6Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy6Position
        mov enemy6Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif

endshoot:
    ret
BulletShoot endp

enemyDisappear proc,
        enemyP:coord
    add allyScore,1000
    call WriteScore
	
	;�Y�Q�g���Aenemy�����C
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count
        mov enemyP.Y,23
	INVOKE Sleep,8
	ret
enemyDisappear endp

;�ͤ�l�u���ʡC
BulletMove proc USES eax ebx ecx edx

	;�l�uø�s�C
	INVOKE WriteConsoleOutputAttribute,
       outputHandle,
       offset bulletAttr,
       lengthof bulletAttr,
       bulletPos,
	   offset count
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

	INVOKE Sleep,15
	INVOKE DetectMove					;�l�u�b�����P�ɡA�������ʡC

	;�l�u�����C
    INVOKE WriteConsoleOutputAttribute,
      outputHandle,
      offset bulletDisappearAttr,
      lengthof bulletDisappearAttr,
      bulletPos,
	  offset count
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

    dec bulletPos.Y						;�l�u�y�ФW���@��C
    ret
BulletMove endp

;����_���{�{�A�L�k�g�����ʡC
AllyRevive proc uses ecx
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    ;call Clrscr

    mov allyCondition,0;				;�����O�_���L�Ī��A�C
	mov ecx,3

blink:
	push ecx
	
    ;����ø�s�C
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y�b�զ^��l��m�C
	invoke Sleep,300					;����{�{�C

	;�������������C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y�b�զ^��l��m�C

	invoke DetectShoot
	invoke DetectMove

    invoke Sleep,300
       pop ecx
       dec ecx
    .IF ecx!=0
        jmp blink						;�{�{�j��T���C
    .ENDIF

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y�b�զ^��l��m�C

;�P�_HP�O�_��0�A�Y�O�hø�s�����e���C
.if allyHP==0
theend:

	call Clrscr

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo0,
		lengthof endLogo0,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo1,
		lengthof endLogo1,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo2,
		lengthof endLogo2,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo3,
		lengthof endLogo3,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo4,
		lengthof endLogo4,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo5,
		lengthof endLogo5,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo6,
		lengthof endLogo6,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo7,
		lengthof endLogo7,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo8,
		lengthof endLogo8,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo9,
		lengthof endLogo9,
		endPos,
		offset bytesWritten

call WaitMsg
exit
.else
keepgo:
    mov allyCondition,1					;�]�w�����L�Ī��A�C
.endif					
    ret

AllyRevive endp

;�������a���ʡC
DetectMove proc
    INVOKE Sleep,15
    call ReadKey
    mov inputMov,al

	.if inputMov=='i'
		INVOKE MovLeft
	.elseif inputMov=='p'
		INVOKE MovRight
	.endif
    ret
DetectMove endp

;�V�k���ʡC
MovRight proc

	;������B�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	INC allyPosition.X

	;���sø�s�C
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3

    ret
MovRight endp

;�V�����ʡC
MovLeft proc

	;������B�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	DEC allyPosition.X

	;���sø�s�C
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

    sub allyPosition.Y,3

	ret
MovLeft endp

;�Ĥ貾�ʡC
EnemyMove proc USES eax ebx ecx edx,
    enemyP:coord
    add score,1

	INVOKE Sleep,15
    
	;�����ĭx�C
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count
	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count
	inc enemyP.Y    
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count

    dec enemyP.Y               			;�ĭxY�y�о��^���T��m�C
	
	;ø�s�ĭx�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count
	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count
	inc enemyP.Y   
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count

	sub enemyP.Y, 2                      ;�ĭxY�y�о��^���T��m�C
	INVOKE EnemyAttack,enemyP.X,enemyP.Y ;�I�s�ĤH�g���C
    ret
EnemyMove endp

;�Ĥ�g���C
EnemyAttack proc USES eax edx ecx ebx ,enemyX:word,enemyY:word

    mov ax,enemyX
    mov dx,enemyY						 ;�ǤJenemyPosition�C
	add ax,2							 ;�y�в��ʨ�l�u�ӥX�{����m�C
	add dx,3
    mov AttackPos.X,ax
    mov AttackPos.Y,dx					 ;�l�u��m�s�JAttackPos�C

keep:
	.if AttackPos.Y==22
		mov bx,allyPosition.Y
		mov cx,allyPosition.X			 ;allyPosition�s�J�Ȧs���C
		sub cx,AttackPos.X				 ;cx�Ω�P�_�l�u���������C
	.endif
	.IF AttackPos.Y!=30				
		INVOKE AttackMove				 ;�Y�l�u�S��̲צ�m�A����I�s�l�u���ʡC
		jmp LOO
	.ELSE
		jmp endAttack
	.ENDIF
LOO:									 ;�P�_�l�u�O�_��������X�b�C
	.if cx == -1
		jmp enddd
	.elseif cx == -2
		jmp enddd
	.elseif cx == -3
		jmp enddd
	.elseif cx == -4
		jmp enddd
	.elseif cx == -5
		jmp enddd
	.elseif cx == -6
		jmp enddd
	.elseif cx == -7
		jmp enddd
	.elseif cx == -8
		jmp enddd
	.elseif cx == -9
		jmp enddd
	.elseif cx == -10
		jmp enddd
	.elseif cx == -11
		jmp enddd
	.elseif cx == 0
		jmp enddd
	.else
		jmp keep
	.endif
enddd:
	.if AttackPos.Y==bx					;�i�@�B�P�_�l�u�O�_��������Y�b�C
		sub allyHP,100         			;�����A��֦�q�C
		INVOKE WriteHP          		;��ܦ�q�C
		jmp endddd
	.else
		jmp keep
	.endif
endddd:
	.if allyCondition==1				;�i�@�B�P�_�����O�_�B��L�Ī��A�C
		invoke AllyRevive				;�I�s�Q�����{�{�C
		jmp endAttack
	.endif
endAttack:
    ret
EnemyAttack endp

;�ĤH�l�u���ʡC
AttackMove proc USES eax ebx ecx edx

	;ø�s�l�u�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset AttackAttr,
		1,
		AttackPos,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset Attack,
		1,
		AttackPos,
		offset count
	INVOKE DetectShoot
	INVOKE DetectMove
	INVOKE Sleep,10
	
	;�����l�u�C
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset AttackDisappearAttr,
		1,
		AttackPos,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset Attack,
		1,
		AttackPos,
		offset count

    inc AttackPos.Y				;�W�[�l�uY�b�A���U���C

    ret
AttackMove endp
end main