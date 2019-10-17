.386
DATA SEGMENT USE16
BUF DB 0AH,0DH,'Welcome to the Student Management System'
    DB 0AH,0DH,'Choose 1 to input , 2 to search , q to quit'
    DB 0AH,0DH,'$'
BUF1 DB 0AH,0DH,'Please input by the order:Number   Score   Rank'
     DB 0AH,0DH,'$'
BUF2 DB 0AH,0DH,'Number   Score   Rank'
     DB 0AH,0DH,'$'
BUF3 DB 0AH,0DH,'You have completed 30 inputs'
     DB 0AH,0DH,'$'
STU  DW 30 DUP(0)
DATA ENDS
STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS
CODE SEGMENT USE16
ASSUME CS:CODE,DS:DATA,SS:STACK
START: MOV AX,DATA
       MOV DS,AX    
       LEA DX,BUF   ;显示字符串
       MOV AH,9
       INT 21H
       MOV AH,1
       INT 21H
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT
       AND AL,0FH
       CMP AL,1
       JE D1
       CMP AL,2
       JE D2
       JMP START
D1:    CALL R1
       JMP START
D2:    CALL R2
       JMP START 
R1 PROC
       LEA DX,BUF1   ;显示字符串
       MOV AH,9
       INT 21H 
       ;设定寄存器
       LEA SI,STU
       MOV DI,0
    LOPA:  MOV AH,1
       INT 21H
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT
       ;读取完输入，并且确保不是退出
       CMP AL,20H
       JE SPACE
       ;确保输入不是空格
       CMP AL,0DH
       JE START
       ;确保输入不是回车
       AND AL,0FH
       MOV AH,0
       ;处理数据，用到了AX,BX,DX,SI
       MOV BX,[SI]
       ADD BX,BX
       MOV DX,BX
       ADD BX,BX
       ADD BX,BX
       ADD BX,DX
       MOV [SI],BX
       ADD [SI],AX
       ;处理数据完成
       JMP LOPA
       ;处理循环体
       RET
R1 ENDP

R2 PROC    
       LEA DX,BUF2   ;显示字符串
       MOV AH,9
       INT 21H  
       RET
R2 ENDP
SPACE: ADD SI,2
       INC DI
       CMP DI,30
       JE  WARNING  
       JMP LOPA
    WARNING: LEA DX,BUF3   ;显示字符串
             MOV AH,9
             INT 21H
             JMP START   
EXIT:  MOV AH,4CH
       INT 21H
CODE ENDS
END START