.386
SHOWSTR MACRO X
        LEA DX,X
        MOV AH,9
        INT 21H
        ENDM
GETINPUT MACRO
         MOV AH,1
         INT 21H
         ENDM
CLEAR    MACRO
         MOV AX,3
         INT 10H 
         ENDM

DATA SEGMENT
INFO DW 200 DUP(20H)
STU  DW 10 DUP(0)
WELCOME DB 0AH,0DH,' ===================================='
        DB 0AH,0DH,'||            Main  Menu            ||'
        DB 0AH,0DH,'||                                  ||'
        DB 0AH,0DH,'||       Press  1  to  input        ||'
        DB 0AH,0DH,'||       Press  2  to  query        ||'
        DB 0AH,0DH,'||       Press  q  to  quit         ||'
        DB 0AH,0DH,' ===================================='
        DB 0AH,0DH,'$'
SCR1    DB 0AH,0DH,' ================================================'
        DB 0AH,0DH,'||             Input   Instructions             ||'
        DB 0AH,0DH,'||                                              ||'
        DB 0AH,0DH,'||      Input by the order "Id Grade Rank "     ||'
        DB 0AH,0DH,'||      Press SPACE to confirm every input      ||'
        DB 0AH,0DH,'||    Press ENTER when completing all inputs    ||'
        DB 0AH,0DH,' ================================================'
        DB 0AH,0DH,'$'
SCR2    DB 0AH,0DH,' ==============================================='
        DB 0AH,0DH,'||             Query   Instructions            ||'
        DB 0AH,0DH,'||                                             ||'
        DB 0AH,0DH,'||       Press SPACE to excute every query     ||'
        DB 0AH,0DH,'||   Press ENTER when completing all queries   ||'
        DB 0AH,0DH,' ==============================================='
        DB 0AH,0DH,'Id         Grade        Rank'
        DB 0AH,0DH,'$'
GAP     DB '        $'
FULL_INPUT DB 0AH,0DH,'You  have  completed  30  inputs'
           DB 0AH,0DH,'$'
QUERY_FAIL DB 20H,'       NOT         FOUND'
           DB 0AH,0DH,'$'
DATA ENDS

STACK SEGMENT STACK
    DB 100 DUP(0)
STACK ENDS

CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK
START: MOV AX,DATA
       MOV DS,AX
       CLEAR   
       SHOWSTR WELCOME
       GETINPUT
       CMP AL,'q'
       JE JEXIT
       CMP AL,'Q'
       JE JEXIT
       AND AL,0FH
       CMP AL,1
       JE D1
       CMP AL,2
       JE D2
       JMP START

D1:    CALL R1       ;跳转到输入成绩
       JMP START

D2:    CALL R2       ;跳转到查询成绩
       JMP START 

JEXIT:  JMP EXIT

R1 PROC              
       CLEAR 
       SHOWSTR SCR1
       LEA SI,STU
       LEA BP,INFO
       MOV CX,10     ;设定寄存器,CX用来计算成绩和名次有几个数字
       MOV DI,0      ;DI用来计算数据是学号还是成绩和名次
  LOPA1:
       MOV AX,0 
       MOV [SI],AX   ;SI用来传递结果
  LOPR1:  
       GETINPUT
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT              ;读取完输入，并且确保不是退出
       CMP AL,20H
       JE SPACE             ;确保输入不是空格
       CMP AL,0DH
       JE START             ;确保输入不是回车
       CMP AL,'0'
       JB LOPA1
       CMP AL,'9'
       JA LOPA1             ;确保输入合法                   
       AND AL,0FH
       MOV AH,0             ;AX里面现在是输入的十进制数
       PUSH AX
       MOV AX,DI
       MOV BL,3
       DIV BL               ;判断输入的数据是学号还是成绩和名次
       CMP AH,0
       JNE DO_GR
       ;处理学号，用到了AX,BX,DX,SI。原理：将SI里面的数乘10再加上AX里面的数
       POP AX
       MOV BX,[SI]
       ADD BX,BX
       MOV DX,BX
       ADD BX,BX
       ADD BX,BX
       ADD BX,DX
       MOV [SI],BX
       ADD [SI],AX
       ;处理学号完成
       JMP LOPR1
   DO_GR: 
       ;处理成绩和名次
       POP AX
       MOV DS:[BP],AX             ;BP前面必须加上DS，否则默认存到SS之中
       ADD BP,2
       DEC CX
       JMP LOPR1
       ;处理成绩和名次完成
       RET
R1 ENDP

EXIT:  MOV AH,4CH
       INT 21H

JSTART: JMP START

R2 PROC    
       CLEAR 
       SHOWSTR SCR2
       MOV DI,0             ;用来存放输入的数据
   LOPR2:
       GETINPUT
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT              ;读取完输入，并且确保不是退出
       CMP AL,20H
       JE QUERY             ;确保输入不是空格  
       CMP AL,0DH              
       JE JSTART             ;确保输入不是回车
       AND AL,0FH
       MOV AH,0
       ;处理数据，用到了AX,BX,DX,DI，原理和处理输入的学号相同
       MOV BX,DI
       ADD BX,BX
       MOV DX,BX
       ADD BX,BX
       ADD BX,BX
       ADD BX,DX
       MOV DI,BX
       ADD DI,AX
       ;处理数据完成
       JMP LOPR2
       RET
R2 ENDP



SPACE: MOV AX,DI            ;DI是输入的结果
       MOV BL,3
       DIV BL
       CMP AH,0             ;判断输入的是学号还是成绩和名次
       JE  DO_ID
   LOPGR:                    ;如果输入的是成绩和名次 
       ADD BP,2
       LOOP LOPGR
       INC DI
       MOV CX,10
       CMP DI,30
       JE  WARNING
       JMP LOPR1  
   DO_ID:                     ;如果输入的是学号   
       ADD SI,2
       INC DI
       JMP LOPA1
   WARNING:   
       SHOWSTR FULL_INPUT
       JMP START

QUERY: MOV CX,10
       LEA SI,STU
       MOV AX,0
    LOPQ: 
       CMP DI,[SI]
       JE  QSUCCESS
       ADD SI,2
       INC AL
       LOOP LOPQ
       JMP QFAIL

QSUCCESS:SHOWSTR GAP
         LEA BP,INFO
         MOV AH,40
         MUL AH
         ADD BP,AX
         MOV CX,10
    LOP_GRADE:  
         MOV AL,DS:[BP]
         CMP AL,20H    
         JE FIN_GRADE
         ADD AL,48 
         MOV DL,AL
         MOV AH,2
         INT 21H
         ADD BP,2
         DEC CX
         JMP LOP_GRADE
    FIN_GRADE:
         SHOWSTR GAP
         ADD BP,CX
	  ADD BP,CX
         MOV CX,0
    LOP_RANK:  
         MOV AL,DS:[BP]
         CMP AL,20H
         JE FIN_RANK 
         ADD AL,48 
         MOV DL,AL
         MOV AH,2
         INT 21H
         ADD BP,2
         JMP LOP_RANK
    FIN_RANK:
         MOV DL,10
         MOV AH,2
         INT 21H
         MOV DL,13
         MOV AH,2
         INT 21H
	  MOV DI,0
         JMP LOPR2                

QFAIL: SHOWSTR QUERY_FAIL
       MOV DI,0
       JMP LOPR2 

CODE ENDS
END START