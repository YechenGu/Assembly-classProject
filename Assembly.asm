.386
DATA SEGMENT USE16
BUF DB 0AH,0DH,'Welcome to the Student Management System'
    DB 0AH,0DH,'Choose 1 to input , 2 to search , q to quit'
    DB 0AH,0DH,'$'
BUF1 DB 0AH,0DH,'Please input by the order:Number   Score   Rank'
     DB 0AH,0DH,'$'
BUF2 DB 0AH,0DH,'Number     Score     Rank'
     DB 0AH,0DH,'$'
BUF3 DB 0AH,0DH,'You have completed 30 inputs'
     DB 0AH,0DH,'$'
BUF4 DB 0AH,0DH,'NOT FOUND'
     DB 0AH,0DH,'$'
SHOW2 DB 20 DUP(0)
SHOW3 DB 20 DUP(0)
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
    LOPA1: MOV [SI],0
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
       ;设定寄存器
       MOV DI,0;存放输入的数据
    LOPB:  MOV AH,1
       INT 21H
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT
       ;读取完输入，并且确保不是退出
       CMP AL,20H
       JE QUERY
       ;确保输入不是空格
       CMP AL,0DH
       JE START
       ;确保输入不是回车
       AND AL,0FH
       MOV AH,0
       ;处理数据，用到了AX,BX,DX,DI
       MOV BX,DI
       ADD BX,BX
       MOV DX,BX
       ADD BX,BX
       ADD BX,BX
       ADD BX,DX
       MOV DI,BX
       ADD DI,AX
       ;处理数据完成
       JMP LOPB
       ;处理循环体  
       RET
R2 ENDP
SPACE: ADD SI,2
       INC DI
       CMP DI,30
       JE  WARNING  
       JMP LOPA1
    WARNING: LEA DX,BUF3   ;显示字符串
             MOV AH,9
             INT 21H
             JMP START
QUERY: MOV CX,10
       LEA SI,STU
  Q:   CMP DI,[SI]
       JE  QSUCCESS
       ADD SI,6
       LOOP Q
       JMP QFAIL
QSUCCESS:MOV AX,[SI+2]
         PUSH SI
         LEA SI,SHOW2
         MOV CX,0
         MOV BL,10
  LOP1:  DIV BL
         CMP AL,0;商
         JE EQU0
         INC CX
         ADD AL,48;ASCII
         MOV [SI],AL;商
         INC SI
         MOV AL,AH
         MOV AH,0
         JMP LOP1
EQU0:    INC CX
         ADD AH,48
         MOV [SI],AH
         LEA SI,SHOW2
  SH2:   MOV DL,[SI]
         MOV AH,2
         INT 21H
         INC SI
         LOOP SH2
         ;--------
         MOV DL,32
         MOV AH,2
         INT 21H
         POP SI
         MOV AX,[SI+4]
         LEA SI,SHOW3
         MOV CX,0
         MOV BL,10
  LOP2:  DIV BL
         CMP AL,0;商
         JE EQU10
         INC CX
         ADD AL,48;ASCII
         MOV [SI],AL;商
         INC SI
         MOV AL,AH
         MOV AH,0
         JMP LOP2
EQU10:   INC CX
         ADD AH,48
         MOV [SI],AH
         LEA SI,SHOW3
  SH3:   MOV DL,[SI]
         MOV AH,2
         INT 21H
         INC SI
         LOOP SH3
         ;--------
         MOV DI,0
         MOV DL,10
         MOV AH,2
         INT 21H
         JMP LOPB
QFAIL: LEA DX,BUF4   ;显示字符串
       MOV AH,9
       INT 21H
       MOV DI,0
       JMP LOPB 
EXIT:  MOV AH,4CH
       INT 21H
CODE ENDS
END START