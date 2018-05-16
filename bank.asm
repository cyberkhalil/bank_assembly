dosseg
.model small

.data                              ; data for the program
greating_msg db "Hello in bank simulation",0Ah,"$"
;pass_in_msg db "Enter your password : ","$"
;password db "test","$"
;password_length dw $-password-1
invalid_pass_msg db "the password you've entered is incorrect",0Ah,"$"
main_menu_msg db "Main menu :-",0Ah,"(s) Show account balance ",0Ah,"(w) Withdraw money",0Ah,"(d) Deposit money",0Ah,"(q) Quit this program",0Ah,"$"
incorrect_letter_msg db 0Ah,"You've entered incorrect choice .",0Ah,"$"
show_balance_msg db " ) Your balance is : ","$"
withdraw_money_msg db " ) Enter number to withdraw : ","$"
deposit_money_msg db " ) Enter number to deposit : ","$"
done_successfully_msg db "Process done successfully ",0Ah,"$"
exit_program db " ) Quit the program","$"
balance db 10 DUP ('0')
input db 10 DUP('0')

.code                              ; program code
mov dx,@data                       ; move offsets to data segment
mov ds,dx

mov ah,9                           ; greating message
mov dx,offset greating_msg
int '!'

pass_main:
;call pass_in                      ; method to enter pass
;call check_pass                   ; method to check pass (if true return if false pass_in)
call main_menu                     ; method to get the menu of the bank (if (s) show account balance and return to menu else if (w) withdraw money and return to menu else if(d) deposit money and return to menu else if (q) quit the program else print invaild_letter)

mov ah,2
mov dl,0Ah                         ; print empty line
int '!'

quit:                              ; exit the program
mov ah,'L'
int '!'

; --------- program end up there but all of those down is the methods used in the program -----------

main_menu:
mov ah,9                           ; print menu list
mov dx,offset main_menu_msg
int '!'

mov ah,1                           ; to take input
int '!'
mov dl,al                          ; store in dh register because dl don't change with our operations

cmp dl,'Z'
jb check_menu_input
xor dl , 00100000b

check_menu_input:
cmp dl,'S'
je show_balance
cmp dl,'W'
je withdraw_money
cmp dl,'D'
je deposit_money
cmp dl,'Q'
je exit_menu
incorrect_letter_print:
mov ah,9
mov dx,offset incorrect_letter_msg ; print  incorrect letter msg
int '!'
jmp main_menu
exit_menu:
mov ah,9
mov dx,offset exit_program
int '!'
call quit


check_input_number:
mov bx,0
check_input_number_loop:
mov dl,input[bx]
cmp dl,'9'
ja incorrect_letter_print
cmp dl,'0'-1
jb incorrect_letter_print
inc bx
cmp bx,10
jne check_input_number_loop
ret


show_balance:
mov ah,9
mov dx,offset show_balance_msg
int '!'
mov bx,0
mov ah,2
show_balance_loop:
mov dl,balance[bx]
int '!'
inc bl
cmp bx,10
jne show_balance_loop
mov ah,2                           ; print empty line
mov dl,0Ah
int '!'
jmp done_successfully
ret


withdraw_money:
mov ah,9
mov dx,offset withdraw_money_msg
int '!'
call clearInput
xor dx,dx
call take_input
call check_input_number
call sub_balance_input

jmp done_successfully
ret


deposit_money:
mov ah,9
mov dx,offset deposit_money_msg
int '!'
call clearInput
mov dl,0
call take_input
call check_input_number
call add_input_to_balance
jmp done_successfully
ret


done_successfully:
mov ah,9                           ; print done successfully message
mov dx,offset done_successfully_msg
int '!'
mov ah,2                           ; print empty line
mov dl,0Ah
int '!'
jmp main_menu
ret


sub_balance_input:
mov si,9
mov bx,10
sub_balance_input_loop:
cmp bx,0
je sub_balance_input_end
dec bx
mov dh,input[bx]
mov dl,dh
sub dh,'0'
cmp dh,9
ja sub_balance_input_loop
cmp dh,0
jb sub_balance_input_loop

sub balance[si],dh
mov di,si
inc di
call check_borrow
dec si
jmp sub_balance_input_loop
sub_balance_input_end:
ret


take_input:                        ; loop to take input and print dl for each letter
mov ah,8
int '!'
mov cl,al
cmp cl,13                          ; 13 in decimal is the ascii for enter
je quit_take_input                 ; to stop looping
mov input[bx],cl
inc bx
cmp dl,0
jne print_dl_take_input
mov dl,cl
mov ah,2
int '!'
mov dl,0
jmp take_input
print_dl_take_input:
mov ah,2
int '!'
jmp take_input
quit_take_input:                   ; to stop the loop
mov ah,2
mov dl,0Ah
int '!'
ret


add_input_to_balance:
mov si,9
mov bx,10
add_input_to_balance_loop:
cmp bx,0
je add_input_to_balance_end
dec bx
mov dh,input[bx]
mov dl,dh
sub dh,'0'
cmp dh,9
ja add_input_to_balance_loop
cmp dh,0
jb add_input_to_balance_loop

add balance[si],dh                 ; now add at last
mov di,si
call check_carry
dec si
jmp add_input_to_balance_loop
add_input_to_balance_end:
ret


check_carry:                       ; to check if there is a carry
mov dl,balance[di]
cmp dl,'9'
jbe not_carry
carry:                             ; if we are here that's mean there is a carry
cmp di,0
jbe call_incorrect_letter_print
sub balance[di],10
inc balance[di-1]
dec di
jmp check_carry
not_carry:
ret


check_borrow:                      ; to check if there is a borrow in the bumber or not
mov dl,balance[di-1]
cmp dl,'0'
jae not_borrow
borrow:                            ; if we are here that's mean there is a borrow
cmp di,0
jbe call_incorrect_letter_print
add balance[di-1],10
dec balance[di-2]
dec di
jmp check_borrow
not_borrow:
ret


call_incorrect_letter_print:       ; there is incorrect letter entered
dec balance[di]
call incorrect_letter_print


clearInput:                        ; to clear input with 0-1 value (not entered yet)
mov bx,10
clearInput_loop:
mov al,'0'-1                       ; -1 for values not entered
mov input[bx],al
dec bx
cmp bx,0
jne clearInput_loop
ret

end