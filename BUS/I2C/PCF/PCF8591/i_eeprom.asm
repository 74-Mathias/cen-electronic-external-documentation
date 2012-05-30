;============================
; Lecture de l'emplacement d�sign� en EEPROM
; Adresse � lire dans W
; Retour de data lue dans W

Read_EEPROM:
	;--------------
	movwf	EEADR
	bsf	STATUS,RP0    	; bank 1
	bsf	EECON1,RD
	bcf	STATUS,RP0     	; bank 0
	movf	EEDATA,W

	;--------------
	return

;============================
; Ecriture data dans l'emplacement d�sign� en EEPROM
; Set_Write_EEPROM_Add (Add dans W pour d�signer l'adresse � �crite)
; Write_EEPROM (Data dans W)

Set_Write_EEPROM_Add:
	;--------------
	movwf	EEADR

	;--------------
	return

Write_EEPROM:
	;--------------
	movwf	EEDATA

	bcf	INTCON,GIE	; interruptions interdites

	bsf	STATUS,RP0    	; bank 1
	bcf	EECON1,EEIF	; effacer flag d'�criture
	bsf	EECON1,WREN	; autoriser acc�s �criture

	movlw	0x55
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2

	bsf	EECON1,WR	; �criture en EEPROM
	bcf	EECON1,WREN	; interdire acc�s �criture

	bsf	INTCON,GIE	; interruptions autoris�es

	bcf	STATUS,RP0     	; bank 0

	;--------------
	return


