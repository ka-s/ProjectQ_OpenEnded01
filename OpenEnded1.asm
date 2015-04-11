; ================================================================
;  ProjectQ Computer Interaction Design Class
;  PIC16LF88-I/P Sample Code
;
;  Apr. 2, 2014
;  Original codes & words by S.C.Matsushita
; ================================================================
	list	p=16f88
	include <p16f88.inc>
	__config	0x2007, 0x3f10
;
; コンフィグレーションレジスタ（＃１）　メモリアドレス0x2007
; コード保護機能オフ、RB6/RB7/RA5/RA6/RA7を一般I/O端子として使用
; 電源電圧低下リセット機能無効、電源ON時リセットタイミング発生機能有効、
; WDT（ウォッチドッグタイマー）無効、PIC16F88内蔵RC発振器をクロックとして使用
;
	__config	0x2008, 0x3ffc
;
; コンフィグレーションレジスタ（＃２）　メモリアドレス0x2008
; 緊急用クロック信号源切り替えシステム無効
; 
; memory address
; 0x20 - 0x6f データメモリ（自由利用可：バンク０）
; 0x70 - 0x7f データメモリ（全バンクよりアクセス可）
;
; メモリバンク（PIC16F88では0,1,2,3の４バンク有）
; ファイルレジスタSTATUSのRP0ビット及びRP1ビットでバンク切り替えを設定
; RP0 = 0, RP1 = 0 -> バンク０を選択　（デフォルト）
; RP0 = 1, RP1 = 0 -> バンク１を選択　（特殊機能レジスタを使う場合等に設定）
; 通常のプログラム動作ではバンク０を選択し、必要な時だけ他のバンクに切り替える
;　また、バンク１～３に切り替えた場合は、必要な処理が終了した後に必ずバンク０に戻す
;
;
; 割り込みプログラム用データメモリ
;
WSAVE		equ	0x70		; Wレジスタ保存用メモリ
STATSAVE	equ	0x71		; STATUSレジスタ保存用メモリ
PCLATHSAVE	equ	0x72		; プログラムカウンタ上位ビット保存用メモリ
FSRSAVE		equ	0x73		; 配列メモリアクセス用レジスタ保存用メモリ
IntFlag		equ	0x74		; 割り込みが生じたことを記録するレジスタ
;
; A/Dコンバータ用データメモリ
;
AD_Timer	equ	0x75 ; A/D変換用ワークエリア
AD_temp		equ	0x76 ; A/D変換用ワークエリア
ADL			equ	0x77 ;　A/D変換結果・下位２ビット（左詰め）
ADH			equ	0x78 ; A/D変換結果・上位８ビット
;
; A/D変換の有効精度は１０ビットなので、８ビットのレジスタ２つ（ADH:ADL）を使う際には
; 6ビット分が空白になる。ここでは「左詰め：left-justified」とすることで、ADHに
;　上位８ビット分を、ADLには下位２ビット分を格納し、ADLのLSBから６ビット分の範囲には
; ゼロが書き込まれる仕様となっている。
;
; ソフトウエアタイマー用ワークエリア
;
Var1		equ	0x79
Var2		equ 0x7a
Var3		equ	0x7b
;
; ハードウエアシリアル通信ポート用ワークエリア
;
RXBuf		equ	0x7c
TXBuf		equ 0x7d
;
; ハードウエアシリアル通信ポート用通信速度設定値
;
Baud_096	equ D'25'		; 9600ビット毎秒（bps）にする際の設定値
Baud_192	equ	D'12'		; 19200bpsにする際の設定値
;
; 自由利用可・データメモリ（x0 ～　x9）
;
x0			equ 0x20
x1			equ 0x21
x2			equ 0x22
x3			equ 0x23
x4			equ 0x24
x5			equ 0x25
x6			equ	0x26
x7			equ 0x27
x8			equ 0x28
x9			equ 0x29
;
;必要であれば、この先0x2a～0x6fの範囲で、適当に変数を宣言しても良い
;
; 配列型データを扱うためのデータメモリ領域
array		equ 0x50	; 配列の開始アドレスを宣言している
; 0x6fまでメモリを使用できるので、0x50-0x6fの32バイトが配列データとして使用できる

	org	0x00			; 電源ON（リセット）では、ここから処理が始まる
Reset
;	call	arraytest	; 配列データアクセスのサンプルコードへ
	goto	Start		; 通常プログラムの先頭へ飛ぶ

	org	0x04			; 割り込みが発生すると、ここから処理が始まる
interrupt
	movwf	WSAVE		; Wレジスタを最初に保存する
	swapf	STATUS, 0	; STATUSレジスタの値がWレジスタに入る
	clrf	STATUS		; データメモリバンクを０にセットする
	movwf	STATSAVE	; 割り込み直前のSTATUSレジスタの値を保存する
	movf	PCLATH, 0	; プログラムカウンタの上位ビット（８ビット）をWレジスタに転送
	movwf	PCLATHSAVE	; プログラムカウンタの上位ビットを保存する
	clrf	PCLATH		; 割り込みプログラムはメモリの最上位付近に必ず置かれている
	movf	FSR, 0		; 配列データアクセス用ポインタの値をWレジスタに入れる
	movwf	FSRSAVE		; FSRポインタの値を保存する

	btfsc	PIR1, CCP1IF	; 割り込み原因がCCP1（タイマが設定値に到達）であるかチェック
	goto	TMR1interrupt	; CCP1が原因で割り込みが発生した

; CCP1IFではない原因で割り込みが起きた場合に処理されるプログラムをここに書く
; 例えば、INTF(RB0/INT割り込み)が原因として特定できるのであれば、
;	bcf		INTCON, INTF
; として、INTFをクリアする：クリアしないと永遠に割り込み続ける

	goto	intend		; 割り込みプログラムから通常プログラムへの復帰処理を行う

TMR1interrupt
	bcf		PIR1, CCP1IF	; CCP1IF　タイマ割り込みフラグを０にする

	movlw	B'00000010'	; ビット１だけが１になっているデータ
	xorwf	PORTB, 1	; RB1の値が1/0反転する -> LEDの点灯／消灯が逆転する

	movlw	0xff
	movwf	IntFlag		; 変数IntFlagに0xffを代入し、割り込み発生を伝える

intend					; 保存しておいた割り込み直前のレジスタの値を元に戻す
	movf	FSRSAVE, 0
	movwf	FSR			; FSRレジスタを復帰
	movf	PCLATHSAVE, 0
	movwf	PCLATH		; PCLATHレジスタを復帰
	swapf	STATSAVE, 0
	movwf	STATUS		; STATUSレジスタを復帰
	swapf	WSAVE, 1
	swapf	WSAVE, 0	; Wレジスタを復帰
	retfie				; retfieで、割り込みが発生した時点のプログラム実行位置に戻る
;
; --------------------------------
;  通常プログラム
; --------------------------------
Start
;
	bsf	STATUS, RP0		; データメモリバンク１番を選択
;
;		TRISA, TRISB 信号方向設定		0 -> 出力	1 ->　入力
;
; PORTA 入出力方向設定
;
	movlw	B'10111100'
	movwf	TRISA		
					; RA0 for 出力 (未使用)
					; RA1 for 出力 (未使用)
					; RA2 for 入力 (A/Dコンバータ 加速度Z軸)
					; RA3 for　入力 (A/Dコンバータ　加速度ｙ軸)
					; RA4 for 入力 (A/Dコンバータ　加速度ｘ軸)
					; RA5 for 入力（専用） (未使用)
					; RA6 for 出力（専用）　(未使用)
					; RA7 for 入力(専用)　(未使用)

;RA5, RA6, RA7の入出力方向は、初期設定値から変更できない

;
; PORTB 入出力方向設定
;
	movlw	B'00000001'
	movwf	TRISB
					; RB0 for 入力 (押しボタンスイッチ)
					; RB1 for 出力　(LED1)
					; RB2 for 出力 (LED2)
					; RB3 for 出力　(LED3)
					; RB4 for 出力　(LED4)
					; RB5 for 出力　(未使用)
					; RB6 for 出力 (未使用)
					; RB7 for 出力　(未使用)
;
; Option Register　(割り込みピン機能設定等)
;
	movlw	B'10000111'	; RB0/INTピン、1->0変化にてINT割り込みを検出
	movwf	OPTION_REG
; 

	bcf		STATUS, RP0	; データメモリバンク０番を選択
;
; PORTA & PORTB 初期値設定
;
	movlw	B'00000000'
	movwf	PORTA
	movlw	B'00000001'	; RB0 = 1 (押しボタンスイッチ・オフ）
	movwf	PORTB
;
; A/Dコンバータ　初期設定
;
	bsf		STATUS, RP0	; データメモリバンク１番を選択
	movlw	B'00000000'	; データ形式等の設定を行う
;
	movwf	ADCON1		; ADCON1レジスタに設定値を書き込む

	movlw	B'00011100'	; AN2,AN3,AN4ピンをアナログ入力に設定
	movwf	ANSEL
	bcf		STATUS, RP0 ; データメモリバンク０番を選択
;
; PIC16F88内蔵クロック信号発生器の設定
;
	bsf		STATUS, RP0	; データメモリバンク１番を選択
	movlw	B'01100000'	; クロック周波数を4MHzに設定
	movwf	OSCCON
;
; 内蔵クロック信号発生器の周波数微調整
; （時間精度が必要な場合に使用する）
;
;	movlw	B'00xxxxxx'	; 微調整値を下位６ビットで指定
;						; 000000 = 中心値：デフォルト
;						; 000001 周波数１ステップアップ
;						; 111111 周波数１ステップダウン
;	movwf	OSCTUNE		; 微調整用ファイルレジスタ
;

OSCWAIT
	btfss	OSCCON, IOFS
	goto	OSCWAIT		; クロック信号発生器が安定するまで待つ
	bcf		STATUS, RP0	; データメモリバンク０番を選択
;
; --------------------------------
;  メイン部分
; --------------------------------
StartSign
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  モーションセンサー処理
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; ピッチ回転(X軸)
AccChkX
	movlw	D'4'		; AN4端子（Ｘ方向加速度）を指定
	call	ADconv 		; A/D変換により加速度を１０ビットの数値に変換する
	btfsc	ADH, 7 		; 変換結果の上位８ビット(ADH）の最上位ビットを調べる
	goto	HighAccX 	; 最上位ビットが１ならHighAccXへ飛ぶ
LowAccX 				; 最上位ビットは０だった
	bsf		PORTB, 1 	; 左のLEDを点灯
	nop 				; １マイクロ秒待つ
	bcf		PORTB, 4 	; 逆のLEDを消灯
	goto	AccChkZ		; 続いてロール回転を測定
HighAccX				; 最上位ビットは１だった
	bsf		PORTB, 4 	; 右のLEDを点灯
	nop 				; １マイクロ秒待つ
	bcf		PORTB, 1 	; 逆のLEDを消灯
	goto	AccChkZ		; 続いてロール回転を測定
;
; ロール回転(Z軸)
AccChkZ
	movlw	D'2'
	call	ADconv
	btfsc	ADH, 7
	goto	HighAccZ
LowAccZ
	bsf		PORTB, 2
	nop
	bcf		PORTB, 3
	goto	AccChkX
HighAccZ
	bsf		PORTB, 2
	nop
	bcf		PORTB, 3
	goto	AccChkX
;
; TMR1 タイマーの初期設定を行う
;
; T1CON コントロールレジスタの構成
; b7 b6 b5 b4 b3 b2 b1 b0 の順
;
; b5-b4 Prescaler select bits 11=1:8, 10=1:4, 01=1:2, 00=1:1
; b5とb4の２ビットでプリスケーラの減速比を決める
; b0 TMR1ON Timer1 On bit (1 ... enables TMR1, 0 ... stops TMR1)
; b0が１になるとタイマー１が起動しカウントが始まる（０だとカウントが止まる）
;
	clrf	TMR1H		; タイマーレジスタの上位８ビットを０にリセット
	clrf	TMR1L		; タイマーレジスタの下位８ビットを０にリセット
	movlw	B'00110100'	; タイマーの初期設定値 (上記レジスタ設定値を参照）
						; プリスケーラ（減速器）が1:8（8分周）に設定されている
;	movlw	B'			; プリスケーラの設定を1:1に設定するには、この値を用いる
	movwf	T1CON
;
; タイマーレジスタの上限値（この値に達するとTMR1H, TMR1Lが０に戻る）を設定する
;
; 0xf424 = 62,500　が設定値だが、プリスケーラが1:8に設定されているため
; 62,500 x 8usec = 500,000usec = 0.5sec が設定時間となる
;
	movlw	0xf4
	movwf	CCPR1H		; TMR1Hと比較する値
	movlw	0x24
	movwf	CCPR1L		; TMR1Lと比較する値
;
	movlw	B'00001011'	;　タイマーレジスタの上限値判定機能を有効化する
	movwf	CCP1CON
;
;	タイマー割り込みの設定を行う
;
	bcf		PIR1, CCP1IF	;　タイマー割り込みフラグをリセットする
;
; RB0/INTピンにて割り込みを使用する場合は、
;	bcf		INTCON, INTF	; RB0/INT割り込みフラグをリセットする
;	bsf		INTCON, INTE	; RB0/INT割り込みを許可する
; を追加する

	bsf		INTCON, PEIE	;　PE(Peripheral)割り込みを許可する
;
	bsf		STATUS, RP0		; データメモリバンク１番を選択
	bsf		PIE1, CCP1IE	; CCP1IE（タイマー上限値到達）割り込みを許可する
	bcf		STATUS, RP0		; データメモリバンク０番を選択

	clrf	IntFlag			; 割り込みが起きたことを記録するデータメモリをクリア
	bsf		INTCON, GIE		; 全割り込み機能を有効化する
	bsf		T1CON, TMR1ON	; TMR1カウント開始

;
WaitLoop
	btfss	IntFlag, 0		; 割り込みが起きない限り待ち続ける
	goto	WaitLoop

	clrf	IntFlag			; 割り込みが起きたことを示すデータメモリをクリア

; タイマー割り込みが起きた時に実行すべきプログラムをここに書く

	goto	WaitLoop		; 次の割り込みを待つ

;
; 配列型変数にアクセスする際のサンプルコード
;
arraytest
;
	movlw	array			; arrayのアドレス（８ビット）をｗに読み込む
	movwf	FSR				; FSRレジスタ（Cでいうポインタ）に書き込む

	movlw	0x12
	movwf	INDF			; INDFに書き込むと，FSRで指示されている
							; メモリにデータが書き込まれる
	incf	FSR, 1			; ポインタを１つ進める
	movlw	0x34
	movwf	INDF			; 今度はarray+1番地に書き込まれる

	movlw	array
	movwf	FSR				; FSRを初期値に戻す

	movf	INDF, 0			; INDFを読み出すと，FSRで指示されている
							; メモリからデータが読み出される
	movwf	x0				; データメモリx0（アドレス0x20）に書き出してみる

	movlw	array+1			; こういうこともできる
	movwf	FSR

	movf	INDF, 0
	movwf	x1				; データメモリx1(アドレス0x21)に書き出してみる

	nop

	return
;
; --------------------------------
;　 ここから以降はcall命令によって呼び出すサブルーチン（関数）
; --------------------------------

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  Wait1S
;
;  １秒待つ（クロック周波数＝４ＭＨｚのとき）
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Wait1S
	movlw	0x11
	movwf	Var1
TLoop0
	movlw	0x88
	movwf	Var2
TLoop1
	movlw	0x8f
	movwf	Var3
TLoop2
	decfsz	Var3, 1
	goto	TLoop2
	decfsz	Var2, 1
	goto	TLoop1
	decfsz	Var1, 1
	goto	TLoop0
	return
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  ADconv
;
;  A/D変換を行う（１回につき、１つの入力ピンを処理）
;
;  input		ＷレジスタでA/D変換入力ピンの番号（0から7まで）を指定する
;  output	ADH　A/D変換結果の上位８ビット
;			ADL A/D変換結果の下位２ビット（MSB2ビットに数値が入り、残りは0となる）
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADconv
	andlw	B'00000111'	; 下位３ビット（チャンネル番号）を抽出する
	movwf	AD_temp
	bcf		STATUS, C
	rlf		AD_temp, 1
	rlf		AD_temp, 1
	rlf		AD_temp, 0
	iorlw	B'01000001'	
	movwf	ADCON0		; A/D変換器にチャンネル情報等を伝える

	movlw	D'5'
	movwf	AD_Timer
ADconv_waitA			; 約１５マイクロ秒待ってA/D変換器のコンデンサを充電
	decfsz	AD_Timer, 1
	goto	ADconv_waitA

	bcf		PIR1, ADIF
	bsf		ADCON0, GO	; コンデンサにたまった電荷を数値に変換する
ADconv_waitB
	btfss	PIR1, ADIF	; 数値変換の終了を待つ
	goto	ADconv_waitB
	bcf		PIR1, ADIF

	movf	ADRESH, 0	; 変換結果の上位８ビットをADHに入れる
	movwf	ADH

	bsf		STATUS, RP0	; select bank1
	movf	ADRESL, 0
	bcf		STATUS, RP0	; select bank0
	movwf	ADL			; 変換結果の下位８ビット（ただし６ビット分はゼロ）を
						; ADLに入れる　：　B'xx000000'が入る
	return
;
; SerialEnable
;
; ハードウエアシリアル通信ポートの機能を有効化する
;
; input なし
; output なし
; 使用条件　クロック周波数４ＭＨｚ、TXDピン（RB5ピン）及びRXDピン（RB2ピン）を
; それぞれ送信ピン、受信ピンとして通信回線に接続
;
SerialEnable
;
	movlw	B'10010000'
	movwf	RCSTA
;
	bsf		STATUS, RP0	; データメモリバンク１番を選択
	movlw	B'00100100'
	movwf	TXSTA
	movlw	Baud_096	; 9600bpsを設定
	movwf	SPBRG
	bcf		STATUS, RP0	; データメモリバンクを０番に戻す
;
	return
;
; receive
;
; ハードウエアシリアルポートから受信データを１バイト読み込む
;
; input		なし
; output	RXBuf（ファイルレジスタ）に受信データが入る
; データが受信されるまで永遠に待つ仕様となっている点に注意
;
receive
	btfss	PIR1, RCIF
	goto	receive		; データが受信されるまで待つ

	btfsc 	RCSTA, FERR ; フレームエラーの検出
	goto	FrameError
	btfsc	RCSTA, OERR ; オーバーランエラーの検出
	goto	OverrunError
	movf	RCREG, 0
skiperror
	movwf	RXBuf
	return				; RXBufに結果を入れてリターン
FrameError
	movf	RCREG, 0	; エラーフラグをクリアするためのコード
	movlw	0xaa		; エラー種別を示すデータ
	goto	skiperror
OverrunError
	bcf		RCSTA, CREN
	bsf		RCSTA, CREN
	movlw	0xbb		; エラー種別を示すデータ
	goto	skiperror
;
; transmit
;
; ハードウエアシリアルポートから１バイト送信する
;
; input		wレジスタの値
; output	nothing
;
transmit
	movwf	TXBuf		; 一旦wレジスタの値を保存
	bsf		STATUS, RP0 ; データメモリバンク１番を選択
transmit_loop
	btfss	TXSTA, TRMT ; データ送信準備ＯＫ？
	goto	transmit_loop	; 次のデータを送信できる状態になるまで待つ

	bcf		STATUS, RP0 ; データメモリバンクを０番に戻す
	movf	TXBuf, 0	; 送信データをwレジスタに入れる
	movwf	TXREG		; この時点でデータ送信が開始される
						; データ送信が完了する前にreturnする
	return
;
	end
