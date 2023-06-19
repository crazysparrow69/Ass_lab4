hashPassword macro  ; hashing password macros
    xor al, key[bx] ;; hidden - hashing password
endm

comparePasswords macro  ; comparing passwords macros													
	      cld 
            mov bx, 0
            mov cx, 0
            mov esi, offset entered_passwd
            counting:
               cmp byte ptr [esi], 0
               je stop_counting
               inc esi
               inc cx
               jmp counting
            stop_counting:
               cmp cx, correct_passwd_length
               jne invalid
            comparing:              
               cmp bx, correct_passwd_length    ;; hidden - comparing passwords
               je valid
               mov al, entered_passwd[bx]
               mov ah, correct_passwd[bx]
               hashPassword
               cmp al, ah
               jne invalid
               inc bx
               jmp comparing
	      valid:														
	         printInfo data_name
               printInfo data_birth
               printInfo data_znumber
               invoke ExitProcess, NULL
               ret
	      invalid:													
	         printInfo invalid_text
               invoke ExitProcess, NULL
               ret
endm

printInfo macro message ; printing info macros
           local next, exit
           push MB_OKCANCEL
           push offset data_title
           push offset message
           push NULL
           call MessageBox  ;; hidden - calling MessageBox
           cmp eax, IDOK
           jne exit
           jmp next
           exit:
                invoke ExitProcess, NULL
           next:
endm
