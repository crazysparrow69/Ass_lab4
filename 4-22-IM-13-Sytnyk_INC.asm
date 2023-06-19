.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\dialogs.inc
include \masm32\macros\macros.asm
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

include 4-22-IM-13-Sytnyk.inc

DialogProcess	PROTO :DWORD, :DWORD, :DWORD, :DWORD

hashPassword macro
    xor al, key[bx]
endm

comparePasswords macro													
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
               cmp bx, correct_passwd_length
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

printInfo macro message
           local next, exit
           push MB_OKCANCEL
           push offset data_title
           push offset message
           push NULL
           call MessageBox
           cmp eax, IDOK
           jne exit
           jmp next
           exit:
                invoke ExitProcess, NULL
           next:
endm

.data
      data_name             db "Person: Sytnyk Denys Oleksandrovych", NULL
      data_birth            db "Date of birth: 21.08.2003", NULL
      data_znumber          db "Zalikovyi number: IM-1326", NULL       
      data_title            db "Information", NULL
	invalid_text          db "invalid password", NULL
	entered_passwd        db 32 dup (0)
      correct_passwd        db "!!&>#7", 0 
      correct_passwd_length dw 6
      key                   db "pVCLWN", 0    
.code	
main:    
	;; Dialog window
	Dialog "4-22-IM-13-Sytnyk", "MS Times New Roman", 14, \            							    
        WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, \   							
        4, 7, 7, 155, 90, 1024                 							      
		DlgStatic "Password:", SS_CENTER,  7,   26, 35,  10, 1000	
		DlgEdit   WS_BORDER,               45,  25, 100, 11, 1001		
		DlgButton "Submit",    WS_TABSTOP, 80,  55, 30,  15, IDOK 				
		DlgButton "Cancel",    WS_TABSTOP, 115, 55, 30,  15, IDCANCEL 	

	CallModalDialog 0, 0, DialogProcess, NULL
      	
      DialogProcess proc hWindow:DWORD, userMessage:DWORD, wParam:DWORD, lParam:DWORD	
	      .IF userMessage == WM_INITDIALOG
            .ELSEIF userMessage == WM_COMMAND
            .IF wParam == IDOK 
	   	      invoke GetDlgItemText, hWindow, 1001, addr entered_passwd, 512
		      comparePasswords
            .ENDIF	   
            .IF wParam == IDCANCEL 
		      invoke ExitProcess, NULL
            .ENDIF
            .ELSEIF userMessage == WM_CLOSE 
                  invoke ExitProcess, NULL
            .ENDIF
            return 0 
      DialogProcess endp
end main