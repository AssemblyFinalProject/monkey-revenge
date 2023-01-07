INCLUDE Irvine32.inc

main	EQU start@0

.stack 4096

DetectMove proto								;偵測移動 直接使用 呼叫MovRight,MovLeft。
MovRight proto									;右移。
MovLeft proto									;左移。
AllyRevive proto								;猴子復活。
EnemyMove proto, enemyP:coord					;佛祖移動。
WriteHP proto                                   ;顯示血量。
WriteScore proto                                ;顯示分數。
enemyDisappear proto, enemyP:coord              ;消去佛祖。
EnemyCrush proto, enemyP:coord					;撞到佛祖扣血。
bulletMove proto								;banana移動
allyAttack proto, enemyP:COORD					;偵測banana打到與否
CheckHP proto									;偵測生命值是否歸零
HPBagDisappear proto, HPBagP:COORD				;消去HPBag
BagMove proto, HPBagP:COORD						;HPBag移動
BagCrush proto, HPBagP:COORD					;偵測是否

.data
titleStr byte "Monkey Revenge",0         ;主控台視窗標題。

startLogo0 byte  "             _      `-._     `-.     `.   \      :      /   .'     .-'     _.-'      _             "
startLogo1 byte  "              `--._     `-._    `-.    `.  `.    :    .'  .'    .-'    _.-'     _.--'              "
startLogo2 byte  "                   `--._    `-._   `-.   `.  \   :   /  .'   .-'   _.-'    _.--'                   "
startLogo3 byte  "             `--.__     `--._   `-._  `-.  `. `. : .' .'  .-'  _.-'   _.--'     __.--'             "
startLogo4 byte  "             __    `--.__    `--._  `-._ `-. `. \:/ .' .-' _.-'  _.--'    __.--'    __             "
startLogo5 byte  "               `--..__   `--.__   `--._ `-._`-.`_=_'.-'_.-' _.--'   __.--'   __..--'               "
startLogo6 byte  "             --..__   `--..__  `--.__  `--._`-q(-_-)p-'_.--'  __.--'  __..--'   __..--             "
startLogo7 byte  "                   ``--..__  `--..__ `--.__ `-'_) (_`-' __.--' __..--'  __..--''                   "
startLogo8 byte  "             ...___        ``--..__ `--..__`--/__/  \--'__..--' __..--''        ___...             "
startLogo9 byte  "                   ```---...___    ``--..__`_(<_   _/)_'__..--''    ___...---'''                   "
startLogo10 byte "             ```-----....._____```---...___(__\_\_|_/__)___...---'''_____.....-----'''             "
startLogo11 byte "   ___ ___   ___   ____   __  _    ___  __ __      ____     ___  __ __    ___  ____    ____    ___ "
startLogo12 byte "  |   |   | /   \ |    \ |  |/ ]  /  _]|  |  |    |    \   /  _]|  |  |  /  _]|    \  /    |  /  _]"
startLogo13 byte "  | _   _ ||     ||  _  ||  ' /  /  [_ |  |  |    |  D  ) /  [_ |  |  | /  [_ |  _  ||   __| /  [_ "
startLogo14 byte "  |  \_/  ||  O  ||  |  ||    \ |    _]|  ~  |    |    / |    _]|  |  ||    _]|  |  ||  |  ||    _]"
startLogo15 byte "  |   |   ||     ||  |  ||     \|   [_ |___, |    |    \ |   [_ |  :  ||   [_ |  |  ||  |_ ||   [_ "
startLogo16 byte "  |   |   ||     ||  |  ||  .  ||     ||     |    |  .  \|     | \   / |     ||  |  ||     ||     |"
startLogo17 byte "  |___|___| \___/ |__|__||__|\_||_____||____/     |__|\_||_____|  \_/  |_____||__|__||___,_||_____|"
startLogo18 byte "                                                                                                   "
startLogo19 byte "                               準備報復佛祖了嗎? Please press 's'                                  "
startColor word lengthof startLogo0 DUP (0Eh)       							;初始畫面顏色。
startColor2 word lengthof startLogo0 DUP (0Bh)       							;初始字體顏色。
startPos COORD <10,5>    													    ;初始畫面初期繪製座標。;初始畫面變數 monkey revenge
score word 1              														;用以佛祖在移動第幾次時再出現。

;猴子樣式。
allyPlaneUp BYTE    "     __      "
allyPlaneMid1 BYTE  "w  c(..)o    " 
allyPlaneMid2 BYTE  " \__(-)      "
allyPlaneDown BYTE  "    /(_)__)  "
allyPlaneBlank BYTE "             "												;猴子消失字元
allyAttr WORD 15 DUP(0Bh)														;猴子顏色。
allyDisAttr WORD 15 DUP (00h)													;猴子消失顏色。
allyPosition COORD <3Ch,25>														;猴子初始位置。
allyCondition byte 1															;猴子狀態 1為活著,0為死掉復活中。
allyHP dword 500 		    													;猴子血量。
allyScore Dword 0																;猴子得分。
bullet byte '('																	;banana樣式。
bulletPos COORD <?,?>															;banana位置。
bulletAttr word 0Eh																;banana顏色。
bulletDisappearAttr word 00h													;banana消失顏色。
bulletshot BYTE 0																;banana有沒有射中，0 = 0， 1 = 有喔

;佛祖樣式。
enemyTop BYTE "  _=_  "
enemyBody BYTE "q(-_-)p"
enemyBottom BYTE "'_\|/_`"
enemyBlank BYTE "       "							;佛祖消失字元
enemyAttr word 7 DUP(0Ch)							;佛祖顏色。
enemyDisappearAttr word 7 DUP(00h)					;佛祖消失顏色。
enemyPosition COORD <60,0>							;佛祖初始位置。
enemy1Position COORD <60,0>
enemy2Position COORD <40,0>
enemy3Position COORD <30,0>
enemy4Position COORD <80,0>
enemy5Position COORD <70,0>
enemy6Position COORD <50,0>
enemyCondition byte 1							;佛祖狀態 1為活著,0為被擊落。


outputHandle DWORD 0 							;CONSOLE 控制ID。
bytesWritten DWORD ?							;回傳值。
count DWORD 0									;回傳值。
cellsWritten DWORD ?							

input byte ?									;變數偵測是否按s。
inputMov byte ?									;變數偵測是否按i或p。
inputQuit byte ?								;變數偵測是否按ESC。

hp BYTE 'HP:'
hpPosition COORD <1,1>                          ;HP位置。
allyhpPosition COORD <4,1>                      ;血量值位置。
hpAttr word 3 DUP(0Ah)                          ;血量顯示顏色。

Scorew BYTE "SCORE:"
ScorePosition COORD <1,2>                       ;SCORE位置。
allyScorePosition COORD <7,2>                   ;分數值位置。
ScoreAttr word 6 DUP(0Ah)                       ;分數顯示顏色。

HPBag BYTE "+HP+"								;醫療包樣式
HPBagPos COORD <60,0>							;醫療包位置
HPBagAttr WORD 4 DUP (0Ah)						;醫療包顏色
HPBagDis BYTE "    "							;醫療包消失樣式
HPBagDisappearAttr WORD 4 DUP (00h)				;醫療包消失顏色
PutHPBag BYTE 00h								;當 PutHPBag == 05h 時落下(每五回合)
Healed BYTE 00h									;是否吃到HPBag


endLogo0 byte "                                  _"
endLogo1 byte "                               _ooOoo_"
endLogo2 byte "                              o8888888o"
endLogo3 byte "                              88"" . ""88"
endLogo4 byte "                              (| -_- |)"
endLogo5 byte "                              O\  =  /O"
endLogo6 byte "                           ____/`---'\____"
endLogo7 byte "                         .'  \\|     |//  `."
endLogo8 byte "                        /  \\|||  :  |||//  \"
endLogo9 byte "                       /  _||||| -:- |||||_  \"
endlogo10 byte "                       |   | \\\  -  /'| |   |"
endlogo11 byte "                       | \_|  `\`---'//  |_/ |"
endlogo12 byte "                       \  .-\__ `-. -'__/-.  /"
endlogo13 byte "                     ___`. .'  /--.--\  `. .'___"
endlogo14 byte "       _           ."""" '<  `.___\_<|>_/___.' _> \""""."
endlogo15 byte "     c  ""}          | | :  `- \`. ;`. _/; .'/ /  .' ; |"
endlogo16 byte "\_    /  \/        \  \ `-.   \_\_`. _.'_/_/  -' _.' /"
endlogo17 byte "==\_|   |=========`-.`___`-.__\ \___  /__.-'_.'_.-'================"
endlogo18 byte " "
endlogo19 byte "                     你被佛祖抓到了! God bless you."
endColor word lengthof endLogo17 DUP (0eh)
endPos COORD <20,5>

.code
main proc
	call Randomize
	INVOKE SetConsoleTitle, offset titleStr        ;設定主控台視窗標題。
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE         
    mov outputHandle, eax
	
	;繪製Startlogo(初始畫面)。
   ;==============================================================================================
	;繪製Startlogo(初始畫面)。 Line 132-274
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
		offset bytesWritten ;Line 132-274
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo11,
		lengthof startLogo11,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo12,
		lengthof startLogo12,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo13,
		lengthof startLogo13,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo14,
		lengthof startLogo14,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo15,
		lengthof startLogo15,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo16,
		lengthof startLogo16,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo17,
		lengthof startLogo17,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo18,
		lengthof startLogo18,
		startPos,
		offset bytesWritten
	inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor2,
		lengthof startColor2,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo19,
		lengthof startLogo19,
		startPos,
		offset bytesWritten
;==============================================================================================
p:
    call ReadChar                			   ;偵測要不要開始遊戲。
    .if al=='s'
		call Clrscr
    .else
        jmp p
    .endif
	
start:

	;繪製初始友軍。
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

	sub allyPosition.Y, 3                	  ;y軸調回初始位置。

	;繪製初始血量。
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

	;繪製初始分數。
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

SetBullet:

	;設定banana初始位置
	mov ax, allyPosition.X
	;add ax, 03h
	mov bulletPos.X, ax
	mov bx, allyPosition.Y
	sub bx, 01h
	mov bulletPos.Y, bx

control:
	
    .if allyScore>=0
		;若佛祖到最下方，佛祖消失並從任意最上方位置重新出現。
		.if enemy1Position.Y>24						  ;佛祖碰到最下方後
			INVOKE enemyDisappear, enemy1Position     ;下方佛祖消失。
            call WriteScore
			mov eax, 100
			call RandomRange
            add ax,12                                 ;防止佛祖從分數、HP的位置出現。
            mov enemy1Position.X,ax                   ;佛祖X座標設隨機位置。
            mov enemy1Position.Y,0                    ;佛祖移到最上方。
			inc PutHPBag
        .endif

		.IF HPBagPos.Y > 24
			INVOKE HPBagDisappear, HPBagPos
			mov eax, 100
			call RandomRange
			add ax,12                           ;防止醫療包從分數、HP的位置出現。
			mov HPBagPos.X,ax                   ;醫療包X座標設隨機位置。
			mov HPBagPos.Y,0                    ;醫療包移到最上方。
			mov PutHPBag, 00h
		.ENDIF

		.IF PutHPBag == 05h
			INVOKE WriteConsoleOutputAttribute,
				outputHandle,
				offset HPBagAttr,
				lengthof HPBagAttr,
				HPBagPos,
				offset bytesWritten
			INVOKE WriteConsoleOutputCharacter,
				outputHandle,
				offset HPBag,
				lengthof HPBag,
				HPBagPos,
				offset count
			INVOKE BagMove, HPBagPos
			INVOKE BagCrush, HPBagPos
			.IF Healed == 01h
				mov eax,100
				call RandomRange
				add ax,12                           ;防止醫療包從分數、HP的位置出現。
				mov HPBagPos.X,ax                   ;醫療包X座標設隨機位置。
				mov HPBagPos.Y,0                    ;醫療包移到最上方。
				mov PutHPBag, 00h
				mov Healed, 00h
			.ENDIF
		.ENDIF

		INVOKE EnemyMove,enemy1Position             ;佛祖移動。
		INVOKE EnemyCrush,enemy1Position            ;判斷有沒有撞擊到。
		INVOKE allyAttack, enemy1Position			;判斷有沒有被banana打到
		.IF bulletshot == 1							;如果打到，重設XY
			mov eax,100
			call RandomRange
            add ax,12                                 ;防止佛祖從分數、HP的位置出現。
            mov enemy1Position.X,ax                   ;佛祖X座標設隨機位置。
            mov enemy1Position.Y,0                    ;佛祖移到最上方。
			mov bulletshot, 0
		.ENDIF
		.IF allyCondition == 0
			mov eax,100
			call RandomRange
            add ax,12                                 ;防止佛祖從分數、HP的位置出現。
            mov enemy1Position.X,ax                   ;佛祖X座標設隨機位置。
            mov enemy1Position.Y,0                    ;佛祖移到最上方。
			mov allyCondition, 1					  ;解除無敵狀態
		.ENDIF
        inc enemy1Position.Y
    .endif
    .if allyScore>=10000
        .if enemy2Position.Y>24
			INVOKE enemyDisappear, enemy2Position
            call WriteScore
            mov eax, 100
            call RandomRange
            add ax,12
            mov enemy2Position.X,ax
            mov enemy2Position.Y,0
        .endif
		INVOKE EnemyMove,enemy2Position
		INVOKE EnemyCrush,enemy2Position            ;判斷有沒有撞擊到。
		INVOKE allyAttack, enemy2Position			;判斷有沒有被banana打到
		.IF bulletshot == 1							;如果打到，重設Y
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy2Position.X,ax
            mov enemy2Position.Y,0
			mov bulletshot, 0
		.ENDIF
		.IF allyCondition == 0
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy2Position.X,ax
            mov enemy2Position.Y,0
			mov allyCondition, 1								;解除無敵狀態
		.ENDIF
        inc enemy2Position.Y
    .endif
    .if allyScore>=25000
        .if enemy3Position.Y>24
            INVOKE enemyDisappear, enemy3Position
            call WriteScore
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy3Position.X,ax
            mov enemy3Position.Y,0
        .endif
		INVOKE EnemyMove,enemy3Position
		INVOKE EnemyCrush,enemy3Position            ;判斷有沒有撞擊到。
		INVOKE allyAttack, enemy3Position			;判斷有沒有被banana打到
		.IF bulletshot == 1							;如果打到，重設Y
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy3Position.X,ax
            mov enemy3Position.Y,0
			mov bulletshot, 0
		.ENDIF
		.IF allyCondition == 0
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy3Position.X,ax
            mov enemy3Position.Y,0
			mov allyCondition, 1								;解除無敵狀態
		.ENDIF
		inc enemy3Position.Y
    .endif
    .if allyScore>=50000
        .if enemy4Position.Y>24
            INVOKE enemyDisappear, enemy4Position
            call WriteScore
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy4Position.X,ax
            mov enemy4Position.Y, 0
		.endif
		INVOKE EnemyMove,enemy4Position
		INVOKE EnemyCrush,enemy4Position            ;判斷有沒有撞擊到。
		INVOKE allyAttack, enemy4Position			;判斷有沒有被banana打到
		.IF bulletshot == 1							;如果打到，重設Y
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy4Position.X,ax
            mov enemy4Position.Y, 0
			mov bulletshot, 0
		.ENDIF
		.IF allyCondition == 0
			mov eax, 100
            call RandomRange
            add ax,12
            mov enemy4Position.X,ax
            mov enemy4Position.Y, 0
			mov allyCondition, 1								;解除無敵狀態
		.ENDIF
        inc enemy4Position.Y
    .endif
	invoke DetectMove								   ;偵測移動。

	.IF bulletPos.Y == 00h
	INVOKE bulletMove
	jmp SetBullet
	.ELSE
	INVOKE bulletMove
	.ENDIF

	dec bulletPos.Y									;banana上移

	jmp control								    	;迴圈讓佛祖下移。

main endp

;顯示血量。
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



enemyDisappear proc,
        enemyP:coord
    ;add allyScore,1000
    call WriteScore
	
	;若被射中，enemy消失。
	.IF allyCondition == 1		;沒被打中才執行 dec ，不然擦不掉
	dec enemyP.Y
	.ENDIF
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBlank,
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
		offset enemyBlank,
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
		offset enemyBlank,
		sizeof enemyBottom,
		enemyP,
		offset count
        mov enemyP.Y,00h
        mov enemyP.X,23h
	ret
enemyDisappear endp

;角色復活閃爍，無法射擊移動。
AllyRevive proc uses ecx
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    ;call Clrscr

    mov allyCondition,0;				;猴子是否為無敵狀態。
	mov ecx,3

blink:
	push ecx
	
    ;猴子繪製。
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

	sub allyPosition.Y,3				;y軸調回初始位置。
	invoke Sleep,300					;延遲閃爍。

	;猴子結束擦除。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y軸調回初始位置。

	invoke DetectMove

    invoke Sleep,300
       pop ecx
       dec ecx
    .IF ecx!=0
        jmp blink						;閃爍迴圈三次。
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

	sub allyPosition.Y,3				;y軸調回初始位置。

    mov allyCondition,1					;設定猴子無敵狀態。
					
    ret

AllyRevive endp

;判斷HP是否為0，若是則繪製結束畫面。
CheckHP PROC
.if allyHP == 0

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
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo10,
		lengthof endLogo10,
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
		offset endLogo11,
		lengthof endLogo11,
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
		offset endLogo12,
		lengthof endLogo12,
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
		offset endLogo13,
		lengthof endLogo13,
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
		offset endLogo14,
		lengthof endLogo14,
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
		offset endLogo15,
		lengthof endLogo15,
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
		offset endLogo16,
		lengthof endLogo16,
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
		offset endLogo17,
		lengthof endLogo17,
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
		offset endLogo18,
		lengthof endLogo18,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo19,
		lengthof endLogo19,
		endPos,
		offset bytesWritten
	call WaitMsg
	exit
	.endif
CheckHP ENDP

;偵測玩家移動。
DetectMove proc
    INVOKE Sleep,10
    call ReadKey
    mov inputMov,al

	.if inputMov=='i'
		INVOKE MovLeft
	.elseif inputMov=='p'
		INVOKE MovRight
	.elseif inputMov=='n'
		add allyScore, 10000
	.endif
    ret
DetectMove endp

;向右移動。
MovRight proc

	;擦掉原處。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
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
		offset allyPlaneBlank,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	add allyPosition.X,2
	.IF allyPosition.X == 6eh	;如果向右到邊界，則留在原地
	sub allyPosition.X,2
	.ENDIF

	;重新繪製。
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

;向左移動。
MovLeft proc

	;擦掉原處。
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
	sub allyPosition.X,2
	.IF allyPosition.X == 0ah	;如果向左到邊界，則留在原地
	add allyPosition.X,2
	.ENDIF

	;重新繪製。
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

;佛祖移動。
EnemyMove proc USES eax ebx ecx edx,
    enemyP:coord
    add score,1

	INVOKE Sleep,70
    
	;擦掉佛祖。
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBlank,
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
		offset enemyBlank,
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
		offset enemyBlank,
		sizeof enemyBottom,
		enemyP,
		offset count

    dec enemyP.Y               			;佛祖Y座標回正確位置。
	
	;繪製佛祖。
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

	sub enemyP.Y, 2                      ;佛祖Y座標回正確位置。
    ret
EnemyMove endp

;判斷佛祖是否有碰到猴子
EnemyCrush proc ,enemyP:COORD
	mov cx, allyPosition.X
	sub cx, enemyP.X
	add cx, 07d
	.IF enemyP.Y >= 16h					;佛祖到可以碰到猴子的範圍
		jmp LOO							;判斷x軸是否有碰到
	.ELSE
		jmp endCrush
	.ENDIF
LOO:									 ;判斷banana是否擊中佛祖X軸。
	.if cx == 05h
		jmp enddd
	.endif
	.if cx == 08h
		jmp enddd
	.endif
	.if cx == 09h
		jmp enddd
	.endif
	.if cx == 09h
		jmp enddd
	.endif
	.if cx == 0ah
		jmp enddd
	.endif
	.if cx == 0bh
		jmp enddd
	.endif
	.if cx == 0ch
		jmp enddd
	.endif
	.if cx == 07h
		jmp enddd
	.endif
	.if cx == 04h
		jmp enddd
	.endif
	.if cx == 03h
		jmp enddd
	.endif
	.if cx == 02h
		jmp enddd
	.endif
	.if cx == 01h
		jmp enddd
	.endif
	.if cx == 00h
		jmp enddd
	.endif
	.if cx == 06h
		jmp enddd
	.else
		jmp endCrush
	.endif
enddd:
		.if allyCondition==1			;進一步判斷猴子是否處於無敵狀態。
		invoke AllyRevive				;呼叫被擊中閃爍。
		sub allyHP,100         			;擊中，減少血量。
		INVOKE CheckHP					;確認HP不為零
		INVOKE WriteHP          		;顯示血量。
		mov allyCondition, 0			;無敵狀態
		INVOKE enemyDisappear, enemyP	;佛祖消失
		
		jmp endCrush
		.endif
endCrush:
    ret
EnemyCrush ENDP

;banana移動
bulletMove PROC
	;上移bananaY，擦除舊banana
	inc bulletPos.Y
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
	;下移bananaY，劃出新banana
	dec bulletPos.Y
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
	.IF bulletPos.Y == 00h
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
	.ENDIF
	ret
bulletMove ENDP

;banana是否打到佛祖
allyAttack PROC USES eax ebx ecx, enemyP:COORD
	mov cx, bulletPos.X
	sub cx, enemyP.X
	mov ax, enemyP.Y
	mov bx, bulletPos.Y
	.IF ax == bx
		jmp LOO
	.ENDIF
	dec bx
	.IF ax == bx
		jmp LOO							;判斷Y軸是否有碰到
	.ENDIF
	inc bx
	inc bx
	.IF ax == bx
		jmp LOO
	.ELSE
		jmp endAllyAttack
	.ENDIF
LOO:									 ;判斷banana是否擊中佛祖X軸。
	.if cx == 05h
		jmp enddd
	.endif
	.if cx == 04h
		jmp enddd
	.endif
	.if cx == 03h
		jmp enddd
	.endif
	.if cx == 02h
		jmp enddd
	.endif
	.if cx == 01h
		jmp enddd
	.endif
	.if cx == 00h
		jmp enddd
	.else
		jmp endAllyAttack
	.endif
enddd:
		add allyScore,1000         	;擊中，加分。
		INVOKE WriteScore
		inc enemyP.Y
		INVOKE enemyDisappear, enemyP	;佛祖消失
		mov bulletshot, 01h
		jmp endAllyAttack
endAllyAttack:
    ret
allyAttack ENDP

;HP包消失
HPBagDisappear PROC, HPBagP:COORD
	
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset HPBagDisappearAttr,
		sizeof HPBag,
		HPBagP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset HPBagDis,
		sizeof HPBag,
		HPBagP,
		offset count

	ret
HPBagDisappear ENDP

;HP包移動
BagMove PROC USES eax ebx ecx edx, HPBagP:COORD
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset HPBagDisappearAttr,
		sizeof HPBag,
		HPBagP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset HPBagDis,
		sizeof HPBag,
		HPBagP,
		offset count
	inc HPBagPos.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset HPBagAttr,
		lengthof HPBagAttr,
		HPBagPos,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset HPBag,
		lengthof HPBag,
		HPBagPos,
		offset count
	ret
BagMove ENDP

;判斷HP包是否接觸到猴子
BagCrush PROC, HPBagP:COORD
	mov cx, allyPosition.X
	sub cx, HPBagP.X
	add cx, 07d
	.IF HPBagP.Y >= 16h					;HPBag到可以碰到猴子的範圍
		jmp LOO							;判斷x軸是否有碰到
	.ELSE
		jmp endCrush
	.ENDIF
	LOO:									 ;判斷HPBag是否擊中猴子X軸。
		.if cx == 05h
			jmp enddd
		.endif
		.if cx == 08h
			jmp enddd
		.endif
		.if cx == 09h
			jmp enddd
		.endif
		.if cx == 09h
			jmp enddd
		.endif
		.if cx == 0ah
			jmp enddd
		.endif
		.if cx == 0bh
			jmp enddd
		.endif
		.if cx == 07h
			jmp enddd
		.endif
		.if cx == 04h
			jmp enddd
		.endif
		.if cx == 03h
			jmp enddd
		.endif
		.if cx == 02h
			jmp enddd
		.endif
		.if cx == 01h
			jmp enddd
		.endif
		.if cx == 00h
			jmp enddd
		.endif
		.if cx == 06h
			jmp enddd
		.else
			jmp endCrush
		.endif
	enddd:
			add allyHP,100         			;吃到，增加血量。
			INVOKE WriteHP          		;顯示血量。
			mov Healed, 01h					;無敵狀態
			INVOKE HPBagDisappear, HPBagP	;佛祖消失
		
			jmp endCrush
	endCrush:
		ret
BagCrush  ENDP
end main
