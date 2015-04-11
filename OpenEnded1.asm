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
; �R���t�B�O���[�V�������W�X�^�i���P�j�@�������A�h���X0x2007
; �R�[�h�ی�@�\�I�t�ARB6/RB7/RA5/RA6/RA7�����I/O�[�q�Ƃ��Ďg�p
; �d���d���ቺ���Z�b�g�@�\�����A�d��ON�����Z�b�g�^�C�~���O�����@�\�L���A
; WDT�i�E�H�b�`�h�b�O�^�C�}�[�j�����APIC16F88����RC���U����N���b�N�Ƃ��Ďg�p
;
	__config	0x2008, 0x3ffc
;
; �R���t�B�O���[�V�������W�X�^�i���Q�j�@�������A�h���X0x2008
; �ً}�p�N���b�N�M�����؂�ւ��V�X�e������
; 
; memory address
; 0x20 - 0x6f �f�[�^�������i���R���p�F�o���N�O�j
; 0x70 - 0x7f �f�[�^�������i�S�o���N���A�N�Z�X�j
;
; �������o���N�iPIC16F88�ł�0,1,2,3�̂S�o���N�L�j
; �t�@�C�����W�X�^STATUS��RP0�r�b�g�y��RP1�r�b�g�Ńo���N�؂�ւ���ݒ�
; RP0 = 0, RP1 = 0 -> �o���N�O��I���@�i�f�t�H���g�j
; RP0 = 1, RP1 = 0 -> �o���N�P��I���@�i����@�\���W�X�^���g���ꍇ���ɐݒ�j
; �ʏ�̃v���O��������ł̓o���N�O��I�����A�K�v�Ȏ��������̃o���N�ɐ؂�ւ���
;�@�܂��A�o���N�P�`�R�ɐ؂�ւ����ꍇ�́A�K�v�ȏ������I��������ɕK���o���N�O�ɖ߂�
;
;
; ���荞�݃v���O�����p�f�[�^������
;
WSAVE		equ	0x70		; W���W�X�^�ۑ��p������
STATSAVE	equ	0x71		; STATUS���W�X�^�ۑ��p������
PCLATHSAVE	equ	0x72		; �v���O�����J�E���^��ʃr�b�g�ۑ��p������
FSRSAVE		equ	0x73		; �z�񃁃����A�N�Z�X�p���W�X�^�ۑ��p������
IntFlag		equ	0x74		; ���荞�݂����������Ƃ��L�^���郌�W�X�^
;
; A/D�R���o�[�^�p�f�[�^������
;
AD_Timer	equ	0x75 ; A/D�ϊ��p���[�N�G���A
AD_temp		equ	0x76 ; A/D�ϊ��p���[�N�G���A
ADL			equ	0x77 ;�@A/D�ϊ����ʁE���ʂQ�r�b�g�i���l�߁j
ADH			equ	0x78 ; A/D�ϊ����ʁE��ʂW�r�b�g
;
; A/D�ϊ��̗L�����x�͂P�O�r�b�g�Ȃ̂ŁA�W�r�b�g�̃��W�X�^�Q�iADH:ADL�j���g���ۂɂ�
; 6�r�b�g�����󔒂ɂȂ�B�����ł́u���l�߁Fleft-justified�v�Ƃ��邱�ƂŁAADH��
;�@��ʂW�r�b�g�����AADL�ɂ͉��ʂQ�r�b�g�����i�[���AADL��LSB����U�r�b�g���͈̔͂ɂ�
; �[�����������܂��d�l�ƂȂ��Ă���B
;
; �\�t�g�E�G�A�^�C�}�[�p���[�N�G���A
;
Var1		equ	0x79
Var2		equ 0x7a
Var3		equ	0x7b
;
; �n�[�h�E�G�A�V���A���ʐM�|�[�g�p���[�N�G���A
;
RXBuf		equ	0x7c
TXBuf		equ 0x7d
;
; �n�[�h�E�G�A�V���A���ʐM�|�[�g�p�ʐM���x�ݒ�l
;
Baud_096	equ D'25'		; 9600�r�b�g���b�ibps�j�ɂ���ۂ̐ݒ�l
Baud_192	equ	D'12'		; 19200bps�ɂ���ۂ̐ݒ�l
;
; ���R���p�E�f�[�^�������ix0 �`�@x9�j
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
;�K�v�ł���΁A���̐�0x2a�`0x6f�͈̔͂ŁA�K���ɕϐ���錾���Ă��ǂ�
;
; �z��^�f�[�^���������߂̃f�[�^�������̈�
array		equ 0x50	; �z��̊J�n�A�h���X��錾���Ă���
; 0x6f�܂Ń��������g�p�ł���̂ŁA0x50-0x6f��32�o�C�g���z��f�[�^�Ƃ��Ďg�p�ł���

	org	0x00			; �d��ON�i���Z�b�g�j�ł́A�������珈�����n�܂�
Reset
;	call	arraytest	; �z��f�[�^�A�N�Z�X�̃T���v���R�[�h��
	goto	Start		; �ʏ�v���O�����̐擪�֔��

	org	0x04			; ���荞�݂���������ƁA�������珈�����n�܂�
interrupt
	movwf	WSAVE		; W���W�X�^���ŏ��ɕۑ�����
	swapf	STATUS, 0	; STATUS���W�X�^�̒l��W���W�X�^�ɓ���
	clrf	STATUS		; �f�[�^�������o���N���O�ɃZ�b�g����
	movwf	STATSAVE	; ���荞�ݒ��O��STATUS���W�X�^�̒l��ۑ�����
	movf	PCLATH, 0	; �v���O�����J�E���^�̏�ʃr�b�g�i�W�r�b�g�j��W���W�X�^�ɓ]��
	movwf	PCLATHSAVE	; �v���O�����J�E���^�̏�ʃr�b�g��ۑ�����
	clrf	PCLATH		; ���荞�݃v���O�����̓������̍ŏ�ʕt�߂ɕK���u����Ă���
	movf	FSR, 0		; �z��f�[�^�A�N�Z�X�p�|�C���^�̒l��W���W�X�^�ɓ����
	movwf	FSRSAVE		; FSR�|�C���^�̒l��ۑ�����

	btfsc	PIR1, CCP1IF	; ���荞�݌�����CCP1�i�^�C�}���ݒ�l�ɓ��B�j�ł��邩�`�F�b�N
	goto	TMR1interrupt	; CCP1�������Ŋ��荞�݂���������

; CCP1IF�ł͂Ȃ������Ŋ��荞�݂��N�����ꍇ�ɏ��������v���O�����������ɏ���
; �Ⴆ�΁AINTF(RB0/INT���荞��)�������Ƃ��ē���ł���̂ł���΁A
;	bcf		INTCON, INTF
; �Ƃ��āAINTF���N���A����F�N���A���Ȃ��Ɖi���Ɋ��荞�ݑ�����

	goto	intend		; ���荞�݃v���O��������ʏ�v���O�����ւ̕��A�������s��

TMR1interrupt
	bcf		PIR1, CCP1IF	; CCP1IF�@�^�C�}���荞�݃t���O���O�ɂ���

	movlw	B'00000010'	; �r�b�g�P�������P�ɂȂ��Ă���f�[�^
	xorwf	PORTB, 1	; RB1�̒l��1/0���]���� -> LED�̓_���^�������t�]����

	movlw	0xff
	movwf	IntFlag		; �ϐ�IntFlag��0xff�������A���荞�ݔ�����`����

intend					; �ۑ����Ă��������荞�ݒ��O�̃��W�X�^�̒l�����ɖ߂�
	movf	FSRSAVE, 0
	movwf	FSR			; FSR���W�X�^�𕜋A
	movf	PCLATHSAVE, 0
	movwf	PCLATH		; PCLATH���W�X�^�𕜋A
	swapf	STATSAVE, 0
	movwf	STATUS		; STATUS���W�X�^�𕜋A
	swapf	WSAVE, 1
	swapf	WSAVE, 0	; W���W�X�^�𕜋A
	retfie				; retfie�ŁA���荞�݂������������_�̃v���O�������s�ʒu�ɖ߂�
;
; --------------------------------
;  �ʏ�v���O����
; --------------------------------
Start
;
	bsf	STATUS, RP0		; �f�[�^�������o���N�P�Ԃ�I��
;
;		TRISA, TRISB �M�������ݒ�		0 -> �o��	1 ->�@����
;
; PORTA ���o�͕����ݒ�
;
	movlw	B'10111100'
	movwf	TRISA		
					; RA0 for �o�� (���g�p)
					; RA1 for �o�� (���g�p)
					; RA2 for ���� (A/D�R���o�[�^ �����xZ��)
					; RA3 for�@���� (A/D�R���o�[�^�@�����x����)
					; RA4 for ���� (A/D�R���o�[�^�@�����x����)
					; RA5 for ���́i��p�j (���g�p)
					; RA6 for �o�́i��p�j�@(���g�p)
					; RA7 for ����(��p)�@(���g�p)

;RA5, RA6, RA7�̓��o�͕����́A�����ݒ�l����ύX�ł��Ȃ�

;
; PORTB ���o�͕����ݒ�
;
	movlw	B'00000001'
	movwf	TRISB
					; RB0 for ���� (�����{�^���X�C�b�`)
					; RB1 for �o�́@(LED1)
					; RB2 for �o�� (LED2)
					; RB3 for �o�́@(LED3)
					; RB4 for �o�́@(LED4)
					; RB5 for �o�́@(���g�p)
					; RB6 for �o�� (���g�p)
					; RB7 for �o�́@(���g�p)
;
; Option Register�@(���荞�݃s���@�\�ݒ蓙)
;
	movlw	B'10000111'	; RB0/INT�s���A1->0�ω��ɂ�INT���荞�݂����o
	movwf	OPTION_REG
; 

	bcf		STATUS, RP0	; �f�[�^�������o���N�O�Ԃ�I��
;
; PORTA & PORTB �����l�ݒ�
;
	movlw	B'00000000'
	movwf	PORTA
	movlw	B'00000001'	; RB0 = 1 (�����{�^���X�C�b�`�E�I�t�j
	movwf	PORTB
;
; A/D�R���o�[�^�@�����ݒ�
;
	bsf		STATUS, RP0	; �f�[�^�������o���N�P�Ԃ�I��
	movlw	B'00000000'	; �f�[�^�`�����̐ݒ���s��
;
	movwf	ADCON1		; ADCON1���W�X�^�ɐݒ�l����������

	movlw	B'00011100'	; AN2,AN3,AN4�s�����A�i���O���͂ɐݒ�
	movwf	ANSEL
	bcf		STATUS, RP0 ; �f�[�^�������o���N�O�Ԃ�I��
;
; PIC16F88�����N���b�N�M��������̐ݒ�
;
	bsf		STATUS, RP0	; �f�[�^�������o���N�P�Ԃ�I��
	movlw	B'01100000'	; �N���b�N���g����4MHz�ɐݒ�
	movwf	OSCCON
;
; �����N���b�N�M��������̎��g��������
; �i���Ԑ��x���K�v�ȏꍇ�Ɏg�p����j
;
;	movlw	B'00xxxxxx'	; �������l�����ʂU�r�b�g�Ŏw��
;						; 000000 = ���S�l�F�f�t�H���g
;						; 000001 ���g���P�X�e�b�v�A�b�v
;						; 111111 ���g���P�X�e�b�v�_�E��
;	movwf	OSCTUNE		; �������p�t�@�C�����W�X�^
;

OSCWAIT
	btfss	OSCCON, IOFS
	goto	OSCWAIT		; �N���b�N�M�������킪���肷��܂ő҂�
	bcf		STATUS, RP0	; �f�[�^�������o���N�O�Ԃ�I��
;
; --------------------------------
;  ���C������
; --------------------------------
StartSign
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  ���[�V�����Z���T�[����
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; �s�b�`��](X��)
AccChkX
	movlw	D'4'		; AN4�[�q�i�w���������x�j���w��
	call	ADconv 		; A/D�ϊ��ɂ������x���P�O�r�b�g�̐��l�ɕϊ�����
	btfsc	ADH, 7 		; �ϊ����ʂ̏�ʂW�r�b�g(ADH�j�̍ŏ�ʃr�b�g�𒲂ׂ�
	goto	HighAccX 	; �ŏ�ʃr�b�g���P�Ȃ�HighAccX�֔��
LowAccX 				; �ŏ�ʃr�b�g�͂O������
	bsf		PORTB, 1 	; ����LED��_��
	nop 				; �P�}�C�N���b�҂�
	bcf		PORTB, 4 	; �t��LED������
	goto	AccChkZ		; �����ă��[����]�𑪒�
HighAccX				; �ŏ�ʃr�b�g�͂P������
	bsf		PORTB, 4 	; �E��LED��_��
	nop 				; �P�}�C�N���b�҂�
	bcf		PORTB, 1 	; �t��LED������
	goto	AccChkZ		; �����ă��[����]�𑪒�
;
; ���[����](Z��)
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
; TMR1 �^�C�}�[�̏����ݒ���s��
;
; T1CON �R���g���[�����W�X�^�̍\��
; b7 b6 b5 b4 b3 b2 b1 b0 �̏�
;
; b5-b4 Prescaler select bits 11=1:8, 10=1:4, 01=1:2, 00=1:1
; b5��b4�̂Q�r�b�g�Ńv���X�P�[���̌���������߂�
; b0 TMR1ON Timer1 On bit (1 ... enables TMR1, 0 ... stops TMR1)
; b0���P�ɂȂ�ƃ^�C�}�[�P���N�����J�E���g���n�܂�i�O���ƃJ�E���g���~�܂�j
;
	clrf	TMR1H		; �^�C�}�[���W�X�^�̏�ʂW�r�b�g���O�Ƀ��Z�b�g
	clrf	TMR1L		; �^�C�}�[���W�X�^�̉��ʂW�r�b�g���O�Ƀ��Z�b�g
	movlw	B'00110100'	; �^�C�}�[�̏����ݒ�l (��L���W�X�^�ݒ�l���Q�Ɓj
						; �v���X�P�[���i������j��1:8�i8�����j�ɐݒ肳��Ă���
;	movlw	B'			; �v���X�P�[���̐ݒ��1:1�ɐݒ肷��ɂ́A���̒l��p����
	movwf	T1CON
;
; �^�C�}�[���W�X�^�̏���l�i���̒l�ɒB�����TMR1H, TMR1L���O�ɖ߂�j��ݒ肷��
;
; 0xf424 = 62,500�@���ݒ�l�����A�v���X�P�[����1:8�ɐݒ肳��Ă��邽��
; 62,500 x 8usec = 500,000usec = 0.5sec ���ݒ莞�ԂƂȂ�
;
	movlw	0xf4
	movwf	CCPR1H		; TMR1H�Ɣ�r����l
	movlw	0x24
	movwf	CCPR1L		; TMR1L�Ɣ�r����l
;
	movlw	B'00001011'	;�@�^�C�}�[���W�X�^�̏���l����@�\��L��������
	movwf	CCP1CON
;
;	�^�C�}�[���荞�݂̐ݒ���s��
;
	bcf		PIR1, CCP1IF	;�@�^�C�}�[���荞�݃t���O�����Z�b�g����
;
; RB0/INT�s���ɂĊ��荞�݂��g�p����ꍇ�́A
;	bcf		INTCON, INTF	; RB0/INT���荞�݃t���O�����Z�b�g����
;	bsf		INTCON, INTE	; RB0/INT���荞�݂�������
; ��ǉ�����

	bsf		INTCON, PEIE	;�@PE(Peripheral)���荞�݂�������
;
	bsf		STATUS, RP0		; �f�[�^�������o���N�P�Ԃ�I��
	bsf		PIE1, CCP1IE	; CCP1IE�i�^�C�}�[����l���B�j���荞�݂�������
	bcf		STATUS, RP0		; �f�[�^�������o���N�O�Ԃ�I��

	clrf	IntFlag			; ���荞�݂��N�������Ƃ��L�^����f�[�^���������N���A
	bsf		INTCON, GIE		; �S���荞�݋@�\��L��������
	bsf		T1CON, TMR1ON	; TMR1�J�E���g�J�n

;
WaitLoop
	btfss	IntFlag, 0		; ���荞�݂��N���Ȃ�����҂�������
	goto	WaitLoop

	clrf	IntFlag			; ���荞�݂��N�������Ƃ������f�[�^���������N���A

; �^�C�}�[���荞�݂��N�������Ɏ��s���ׂ��v���O�����������ɏ���

	goto	WaitLoop		; ���̊��荞�݂�҂�

;
; �z��^�ϐ��ɃA�N�Z�X����ۂ̃T���v���R�[�h
;
arraytest
;
	movlw	array			; array�̃A�h���X�i�W�r�b�g�j�����ɓǂݍ���
	movwf	FSR				; FSR���W�X�^�iC�ł����|�C���^�j�ɏ�������

	movlw	0x12
	movwf	INDF			; INDF�ɏ������ނƁCFSR�Ŏw������Ă���
							; �������Ƀf�[�^���������܂��
	incf	FSR, 1			; �|�C���^���P�i�߂�
	movlw	0x34
	movwf	INDF			; ���x��array+1�Ԓn�ɏ������܂��

	movlw	array
	movwf	FSR				; FSR�������l�ɖ߂�

	movf	INDF, 0			; INDF��ǂݏo���ƁCFSR�Ŏw������Ă���
							; ����������f�[�^���ǂݏo�����
	movwf	x0				; �f�[�^������x0�i�A�h���X0x20�j�ɏ����o���Ă݂�

	movlw	array+1			; �����������Ƃ��ł���
	movwf	FSR

	movf	INDF, 0
	movwf	x1				; �f�[�^������x1(�A�h���X0x21)�ɏ����o���Ă݂�

	nop

	return
;
; --------------------------------
;�@ ��������ȍ~��call���߂ɂ���ČĂяo���T�u���[�`���i�֐��j
; --------------------------------

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  Wait1S
;
;  �P�b�҂i�N���b�N���g�����S�l�g���̂Ƃ��j
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
;  A/D�ϊ����s���i�P��ɂ��A�P�̓��̓s���������j
;
;  input		�v���W�X�^��A/D�ϊ����̓s���̔ԍ��i0����7�܂Łj���w�肷��
;  output	ADH�@A/D�ϊ����ʂ̏�ʂW�r�b�g
;			ADL A/D�ϊ����ʂ̉��ʂQ�r�b�g�iMSB2�r�b�g�ɐ��l������A�c���0�ƂȂ�j
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADconv
	andlw	B'00000111'	; ���ʂR�r�b�g�i�`�����l���ԍ��j�𒊏o����
	movwf	AD_temp
	bcf		STATUS, C
	rlf		AD_temp, 1
	rlf		AD_temp, 1
	rlf		AD_temp, 0
	iorlw	B'01000001'	
	movwf	ADCON0		; A/D�ϊ���Ƀ`�����l����񓙂�`����

	movlw	D'5'
	movwf	AD_Timer
ADconv_waitA			; ��P�T�}�C�N���b�҂���A/D�ϊ���̃R���f���T���[�d
	decfsz	AD_Timer, 1
	goto	ADconv_waitA

	bcf		PIR1, ADIF
	bsf		ADCON0, GO	; �R���f���T�ɂ��܂����d�ׂ𐔒l�ɕϊ�����
ADconv_waitB
	btfss	PIR1, ADIF	; ���l�ϊ��̏I����҂�
	goto	ADconv_waitB
	bcf		PIR1, ADIF

	movf	ADRESH, 0	; �ϊ����ʂ̏�ʂW�r�b�g��ADH�ɓ����
	movwf	ADH

	bsf		STATUS, RP0	; select bank1
	movf	ADRESL, 0
	bcf		STATUS, RP0	; select bank0
	movwf	ADL			; �ϊ����ʂ̉��ʂW�r�b�g�i�������U�r�b�g���̓[���j��
						; ADL�ɓ����@�F�@B'xx000000'������
	return
;
; SerialEnable
;
; �n�[�h�E�G�A�V���A���ʐM�|�[�g�̋@�\��L��������
;
; input �Ȃ�
; output �Ȃ�
; �g�p�����@�N���b�N���g���S�l�g���ATXD�s���iRB5�s���j�y��RXD�s���iRB2�s���j��
; ���ꂼ�ꑗ�M�s���A��M�s���Ƃ��ĒʐM����ɐڑ�
;
SerialEnable
;
	movlw	B'10010000'
	movwf	RCSTA
;
	bsf		STATUS, RP0	; �f�[�^�������o���N�P�Ԃ�I��
	movlw	B'00100100'
	movwf	TXSTA
	movlw	Baud_096	; 9600bps��ݒ�
	movwf	SPBRG
	bcf		STATUS, RP0	; �f�[�^�������o���N���O�Ԃɖ߂�
;
	return
;
; receive
;
; �n�[�h�E�G�A�V���A���|�[�g�����M�f�[�^���P�o�C�g�ǂݍ���
;
; input		�Ȃ�
; output	RXBuf�i�t�@�C�����W�X�^�j�Ɏ�M�f�[�^������
; �f�[�^����M�����܂ŉi���ɑ҂d�l�ƂȂ��Ă���_�ɒ���
;
receive
	btfss	PIR1, RCIF
	goto	receive		; �f�[�^����M�����܂ő҂�

	btfsc 	RCSTA, FERR ; �t���[���G���[�̌��o
	goto	FrameError
	btfsc	RCSTA, OERR ; �I�[�o�[�����G���[�̌��o
	goto	OverrunError
	movf	RCREG, 0
skiperror
	movwf	RXBuf
	return				; RXBuf�Ɍ��ʂ����ă��^�[��
FrameError
	movf	RCREG, 0	; �G���[�t���O���N���A���邽�߂̃R�[�h
	movlw	0xaa		; �G���[��ʂ������f�[�^
	goto	skiperror
OverrunError
	bcf		RCSTA, CREN
	bsf		RCSTA, CREN
	movlw	0xbb		; �G���[��ʂ������f�[�^
	goto	skiperror
;
; transmit
;
; �n�[�h�E�G�A�V���A���|�[�g����P�o�C�g���M����
;
; input		w���W�X�^�̒l
; output	nothing
;
transmit
	movwf	TXBuf		; ��Uw���W�X�^�̒l��ۑ�
	bsf		STATUS, RP0 ; �f�[�^�������o���N�P�Ԃ�I��
transmit_loop
	btfss	TXSTA, TRMT ; �f�[�^���M�����n�j�H
	goto	transmit_loop	; ���̃f�[�^�𑗐M�ł����ԂɂȂ�܂ő҂�

	bcf		STATUS, RP0 ; �f�[�^�������o���N���O�Ԃɖ߂�
	movf	TXBuf, 0	; ���M�f�[�^��w���W�X�^�ɓ����
	movwf	TXREG		; ���̎��_�Ńf�[�^���M���J�n�����
						; �f�[�^���M����������O��return����
	return
;
	end
