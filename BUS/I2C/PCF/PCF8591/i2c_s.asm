; Include I2c_S.asm
; 
; Dominique M. - 9/2003
;________________________________________________________________________________
;

;________________________________________________________________________________
;
; Routines g�n�rale I2c (mode Slave)     	    
;________________________________________________________________________________
;
;============================
; Lecture d'un octect sur le Bus.
; La donn�e lue sera dans s_i_byte.

I2c_Slave_In_Byte:
	;--------------
	clrf 	s_i_byte         	; on vide le tampon d'entr�e s_i_byte

	movlw 	8	       		; on initialise l'index � 8 bits
	movwf 	s_n_bit			; on charge dans s_n_bit

;--------------	
I2c_Slave_In_Bit:  
	;--------------
	btfsc 	_scl      		; on attend que _scl soit BAS
	goto 	I2c_Slave_In_Bit	; on boucle

;--------------
I2c_Slave_In_Bit_Wait:
	;--------------
	btfss 	_scl      		; on attend que _scl soit HAUT
	goto 	I2c_Slave_In_Bit_Wait   ; on boucle
 
	;--------------
	btfss 	_sda      		; on lit la donn�e pr�sente sur _sda en testant son �tat
	goto	I2c_Slave_In_Bit_0	
	goto	I2c_Slave_In_Bit_1

I2c_Slave_In_Bit_0:
	;--------------
	bcf 	STATUS,C      		; on met la retenue � z�ro
	rlf 	s_i_byte,f       	; on d�cale � gauche s_i_byte (le bit est � z�ro) 
 
	goto	I2c_Slave_In_Bit_Next

I2c_Slave_In_Bit_1:
	;--------------
	bcf 	STATUS,C      		; on met la retenue � z�ro
	rlf 	s_i_byte,f       	; on d�cale � gauche s_i_byte (le bit est � z�ro) 
	bsf 	s_i_byte,0       	; _sda est � un, on met le bit de poid faible � un

I2c_Slave_In_Bit_Next:
	;--------------
	decfsz 	s_n_bit,f          	; on d�cremente l'index
	goto 	I2c_Slave_In_Bit        ; on lit le bit suivant tant que l'index n'est pas 0

	;--------------
	return

;============================
; Envoi d'un octect sur le Bus.

I2c_Slave_Out_Byte:
	;--------------
	movwf	s_o_byte		; on charge W dans s_o_byte

	movlw 	8	        	; on initialise l'index � 8 bits
	movwf 	s_n_bit			; on charge dans s_n_bit

;--------------
I2c_Slave_Out_Bit:  
	;--------------
	btfsc 	_scl 			; on attend que _scl soit BAS
	goto 	I2c_Slave_Out_Bit	; on boucle

	nop
	nop

	;--------------
	; On configure _sda en entr�e

	bsf 	STATUS,RP0      	; bank 1
	bsf 	_statut_sda      	; _sda est une entr�e valant 5V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

;--------------
I2c_Slave_Out_Bit_Wait:

   	;--------------
	; On lit le bit suivant de s_o_byte et on le teste

	bcf 	STATUS,C   
	rlf 	s_o_byte,f	       	; on d�cale o_byte � gauche via la retenue

	btfsc 	STATUS,C        	; on teste la retenue
	goto	I2c_Slave_Out_Bit_Next	; c'est un 1 donc on ne touche pas � la ligne

	;--------------
	; C'est un z�ro, on configure _sda en sortie

	bcf 	_sda       		; et on force _sda � z�ro

	bsf 	STATUS,RP0      	; bank 1
	bcf 	_statut_sda      	; _sda est une sortie valant 0V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

;--------------
I2c_Slave_Out_Bit_Next:
	;--------------
	btfss 	_scl       		; on attend que _scl soit HAUT
	goto 	I2c_Slave_Out_Bit_Next  ; on boucle

	decfsz 	s_n_bit,f            	; on d�cremente l'index
	goto 	I2c_Slave_Out_Bit     	; on envoie le bit suivant tant que l'index n'est pas � 0

;--------------
I2c_Slave_Out_Byte_End:
	;--------------
	btfsc 	_scl 			; on attend que _scl soit BAS
	goto 	I2c_Slave_Out_Byte_End	; on boucle

	nop
	nop

	;--------------
	; On configure _sda en entr�e

	bsf 	STATUS,RP0      	; bank 1
	bsf 	_statut_sda      	; SDA est une entr�e valant 5V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

	;--------------
	return

;============================
; Envoi d'un ACK sur le Bus (sur le neuvi�me coup d'horloge)

I2c_Slave_Ack:
	;--------------
	btfsc 	_scl			; on attend que _scl soit BAS
	goto 	I2c_Slave_Ack   	; on boucle          	

;--------------	
I2c_Slave_Ack_Wait1:  
	;--------------
	; Le ma�tre a laisser _sda � l'�tat HAUT, on va donc le forcer � l'�tat BAS.

	bcf 	_sda       		; on met _sda � z�ro

	;--------------
	bsf 	STATUS,RP0      	; bank 1
	bcf 	_statut_sda      	; _sda est une sortie valant 0V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

;--------------	
I2c_Slave_Ack_Wait2:
	btfss 	_scl       		; on attend que _scl soit HAUT (neuvi�me coup d'horloge)
	goto 	I2c_Slave_Ack_Wait2	; on boucle

;--------------	
I2c_Slave_Ack_Wait3:  
	;--------------
	btfsc 	_scl			; on attend que _scl soit BAS	
	goto 	I2c_Slave_Ack_Wait3 	; on boucle
	
	nop
	nop

	;--------------		
	bsf 	STATUS,RP0      	; bank 1
	bsf 	_statut_sda      	; _sda est une entr�e valant 5V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

	;--------------
	return        

;============================
; N'envoie PAS de ACK sur le Bus (sur le neuvi�me coup d'horloge)


I2c_Slave_No_Ack:
	;--------------
	btfsc 	_scl			; on attend que _scl soit BAS
	goto 	I2c_Slave_No_Ack 	; on boucle

;--------------	
I2c_Slave_No_Ack_Wait1:  
	;--------------
	btfss 	_scl      		; on attend que _scl soit HAUT
	goto 	I2c_Slave_No_Ack_Wait1  ; on boucle

	; on laisse _sda au niveau HAUT

;--------------		
I2c_Slave_No_Ack_Wait2: 
	;-------------- 
	btfsc 	_scl			; on attent que _scl soit BAS
	goto 	I2c_Slave_No_Ack_Wait2	; on boucle

	;--------------
	return               

;============================
I2c_Slave_Fin_No_Ack:
	;--------------
	bsf 	STATUS,RP0      	; bank 1
	bsf 	_statut_sda      	; _sda est une entr�e valant 5V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

	call	I2c_Slave_No_Ack

	goto 	Interrupt_Reset_All    ; on termine en retournant au gestionnaire d'interruptions

;============================
I2c_Slave_Fin:
	;--------------
	bsf 	STATUS,RP0      	; bank 1
	bsf 	_statut_sda      	; _sda est une entr�e valant 5V (Pull Up sur _sda)
	bcf 	STATUS,RP0      	; bank 0

	nop

	goto 	Interrupt_Reset_All    ; on termine en retournant au gestionnaire d'interruptions

;________________________________________________________________________________
;
; Routines de d�but de trame
;________________________________________________________________________________

;============================
I2c_Slave:   
 	;--------------
	bcf 	STATUS,RP0     		; bank 0

	;--------------
	; lecture adresse

	call 	I2c_Slave_In_Byte    	; lecture de l'adresse

	movf	s_i_byte,W		; on charge s_i_byte dans W	
	subwf	mod_adr,W		; mod_add - s_i_byte -> W
	btfss	STATUS,Z		; test
	goto 	I2c_Slave_Fin_No_Ack	; la transmition actuelle ne nous concerne pas
	
	call 	I2c_Slave_Ack           ; Ok l'adresse est la bonne!

	; Ins�rer ici �ventuellement une sous adresse

	;--------------
	; lecture du num�ro de fonction demand�e et branchement

	call 	I2c_Slave_In_Byte       ; lecture du num�ro de fonction demand�e
	call 	I2c_Slave_Ack		; et on acquitte

	;--------------
	movlw 	1			; on teste si function X
	subwf	s_i_byte,W		; s_i_byte - Num function -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Function1	; c'est la fonction X

	;--------------
	movlw 	2			; on teste si function X
	subwf	s_i_byte,W		; s_i_byte - Num function -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Function2	; c'est la fonction X

	;--------------
	movlw 	3			; on teste si function X
	subwf	s_i_byte,W		; s_i_byte - Num function -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Function3	; c'est la fonction X

	;--------------
	movlw 	4			; on teste si function X
	subwf	s_i_byte,W		; s_i_byte - Num function -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Function4	; c'est la fonction X

	;--------------
	movlw 	5			; on teste si function X
	subwf	s_i_byte,W		; s_i_byte - Num function -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Function5	; c'est la fonction X

	; On peut rajouter jusqu'� 255 fonctions, apr�s ce n'est qu'un probl�me de place en m�moire programme!

	;--------------
	movlw 	0			; on teste si function (i_byte) = 0 (Identification)
	subwf	s_i_byte,W		; s_i_byte - 0 -> W
	btfsc	STATUS,Z		; test
	goto 	I2c_Slave_Ident		; c'est bien une demande d'identification

	;--------------
	goto 	I2c_Slave_Fin 

;============================
; Fonction 0: Renvoi de la trame d'identification
I2c_Slave_Ident:  
	;--------------
	movlw	1
	call	Read_EEPROM		; le caract�re d'identification est en EEPROM � l'adresse 1            
	call 	I2c_Slave_Out_Byte 	; envoi du caract�re d'identification
 	call	I2c_Slave_No_Ack

	;--------------
	movlw	2
	call	Read_EEPROM		; le caract�re d'identification est en EEPROM � l'adresse 2           
	call 	I2c_Slave_Out_Byte 	; envoi du caract�re d'identification
	call	I2c_Slave_No_Ack

	;--------------
	movlw	3
	call	Read_EEPROM		; le caract�re d'identification est en EEPROM � l'adresse 3            
	call 	I2c_Slave_Out_Byte 	; envoi du caract�re d'identification
	call	I2c_Slave_No_Ack

	;--------------
	movlw	0
	call	Read_EEPROM		; l'adresse du module est en EEPROM � l'adresse 0
	call 	I2c_Slave_Out_Byte 	; envoi l'adresse du module   
   	call	I2c_Slave_No_Ack

	;--------------
	goto 	I2c_Slave_Fin 

;________________________________________________________________________________
;
; Fin des routines de d�but de trame
;
; Rappel des principes utilis�s pour bien m'en souvenir plus tard!
;
; Principe de fonctionnement de la routine I2c en mode Slave:
;
; Principes �lectriques du Bus I2c.
;
; Les lignes _sda et _scl d'un Bus I2c sont reli�es via des r�sistances (Pull Up) 
; au niveau plus de l'alimentation.
; Pour �viter tout court-circuit, ni le ma�tre ni les esclaves ne peuvent forcer ces 
; lignes � l'�tat HAUT. On ne peut donc que maintenir � l'�tat BAS celles-ci. 
; (Cf. Bigonoff Cours 2 - Chapitre I2C)
;
; Bien respecter donc, pour les changement d'�tat de lignes, la proc�dure suivante:
;
; On veut _sda � 1, on ne fait rien (en mode Slave)
; On veut _sda � 0, on baisse _sda (bcf _sda), puis on passe en sortie (bcf _statut_sda).
; On veut _sda � 0 quand _sda �tait � 1, on passe directement en entr�e (bcf _statut_sda).
;
; Variables utilis�es par l'Include "I2c_S" devant �tre d�clar�es dans le programme principal
;
;	s_i_byte        : 1	; tampon octet lu sur le bus I2C
; 	s_o_byte        : 1	; tampon octet a envoyer sur le bus I2C
; 	s_n_bit         : 1	; index ( compteur de bits )
;
; Equivalents utilis�s par l'Include "I2c_S" devant �tre d�clar�es dans le programme principal
;
; #DEFINE _sda		PORTB,0     	; _sda sur RB0/INT
; #DEFINE _statut_sda	TRISB,0 	; configuration de _sda en entr�e ou sortie
;
; #DEFINE _scl   	PORTB,1     	; _scl sur RB1 
;
; Routines I2c Slave:
;
; I2c_Slave_In_Byte 	-> lecture d'un octet (8 coup d'horloge).
; I2c_Slave_Out_Byte	-> envoi d'un octet (8 coup d'horloge).
; I2c_Slave_Ack		-> Acquitte (sur le neuvi�me coup d'horloge).
; I2c_Slave_No_Ack	-> n'acquitte pas (sur le neuvi�me coup d'horloge).

;________________________________________________________________________________
;
; Routines de r�ception de trames I2c (mode Slave)
;________________________________________________________________________________
;
; Le protocole d'�change retenu ici est 100% compatible avec le langage I2c en ce sens qu'il
; s'ins�re sans probl�me dans un r�seau I2c standard.
;
; Chaque module a une et une seule adresse. Les modules fonctionnent en mode Slave uniquement.
;
; Le bit 0 de l'adresse I2c (R/W, Lecture / �criture) n'est pas ici utilis�. 
; Il est possible de combiner �criture et lecture dans une m�me trame.
;
; Format g�n�ral des trames retenues � partir de l'application principale (mode Master):
;
; 	[Start] 
;	[Adresse module] 
;	[Fonction x] 
;	[Read / Write data 1] 
;	[Read / Write data 2] 
;	......
;	[Read / Write data n] 
;	[Stop]
;
; Fonctionnement de ce module.
;
; Les interruptions sont valid�es pour RB0 dans le mode HAUT vers BAS.
; Lors d'un changement de RB0 (HAUT vers BAS), une interruption intervient. On teste alors le niveau _scl. 
; Si _scl est HAUT alors une condition de START est reconnue (changement de _sda de HAUT vers BAS QUAND _scl est HAUT).
; (Cf. Bigonoff Cours 2 - Chapitre I2C).
; On se branche alors sur la routine I2c_Slave de cet include qui traite la trame.	
;
; Organisation des interruptions (dans le programme principal)
;
;	;--------------
;	; test RB0
;	bsf	STATUS,RP0		; bank 1
;	btfsc	INTCON,INTE		; Test si interruptions RB0 autoris�es
;	btfss	INTCON,INTF		; Test si il s'agit d'une interruption RB0
;	goto	FIN_INTER		; NON on retourne au gestionnaire d'interruptions
;
;	;--------------
;	; test _scl			; OUI, on traite
;	bcf 	STATUS,RP0     		; bank 0
;	btfsc 	_scl      		; Test si _scl HAUT
;	goto 	I2c_Slave		; OUI, c'est un START
;
;
; Principe de traitement de la trame (I2c_Slave):
;
;	1 - Lecture de l'adresse I2c demand�e
;	2 - Test de l'adresse: si adresse est Ok on lit la suite sinon on retourne au gestionnaire d'interruptions
;	3 - Lecture de la fonction demand�e
;	4 - Branchement et traitement de la fonction demand�e (dans le corp principal du programme)
;	5 - Retour au gestionnaire d'interruptions
;
; Variables utilis�es par l'Include "I2c_S" devant �tre d�clar�es dans le programme principal
;
;	mod_adr		: 1	; adresse du module
;
;
; Eventuellement si on le souhaite, une extension d'adressage via une sous adresse est possible.
; Pr�voir alors la variable et modifier I2c_Slave en cons�quence.
;
;	s_sous_add	: 1
;
; De m�me, on peut si on le souhaite ne pas utiliser les fonctions et ne retenir que le bit 7 R/W.
; Modifier le code en cons�quence.)
;
;
; Interruptions utilis�es par l'Include "I2c_S" devant �tre d�clar�es dans le programme principal
; 
; Configuer les Pull Up sur PORTB actives (OPTION_REG,7 � 0)
; Configurer interruptions sur RB0 par passage de HAUT vers BAS (OPTION_REG,6 � 0)
; Autoriser les interruptions EXTERNES (INTCON,7 soit GIE � 1)
; Configurer _sda (RB0) et _scl (RB1) en ENTREES (TRISB,0 et TRISB,1 � 1)
;
; Particularit� de la fonction 0:
;
; Une fonction d'identification est pr�vue. Celle-ci permet le cas �ch�ant de s'assurer que le module
; est bien pr�sent sur le Bus et r�pond correctement (retours connus).
;
; La trame Master est alors:
;
; 	[Start] 
;	[Adresse module] 
;	[0] 
;	[Read data 1] -> Identifiant 1 du module
;	[Read data 2] -> Identifiant 2 du module
;	[Read data 1] -> Identifiant 3 du module
;	[Read data 2] -> Adresse du module
;	[Stop]
;
; Ici, ces identifiants sont entr�s au moment de la programmation dans quatre premi�res adresses de l'EEPROM du PIC.
;
; Exemple
;
;	org	0x2100
;
;	DE	34		; Variable 00 EEPROM	; Adresse du Module
;	DE	'L'		; Variable 01 EEPROM	; Identifiant 1 du Module
;	DE	'C'		; Variable 02 EEPROM	; Identifiant 2 du Module
;	DE	'D'		; Variable 03 EEPROM	; Identifiant 3 du Module
;
; Derni�re pr�caution avant emploi: ces routines se faisant sous interruptions, le programme ne fait rien d'autre
; pendant tout le temps de transmission vers le module (en particulier les interruptions TIMER et RB4.RB7 sont invalid�es). 
; Pr�voir donc le programme en cons�quence.
;________________________________________________________________________________
;
