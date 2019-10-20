.386
DATA SEGMENT USE16
INFO DB 200 DUP('a')
STU  DW 10 DUP(0)
WELCOME DB 0AH,0DH,'Welcome to the Student Management System'
        DB 0AH,0DH,'Choose 1 to input , 2 to search , q to quit'
        DB 0AH,0DH,'$'
SCR1 DB 0AH,0DH,'Please input by the order:Number     Score     Rank'
     DB 0AH,0DH,'$'
SCR2 DB 0AH,0DH,'Number      Score      Rank'
     DB 0AH,0DH,'$'
FULL_INPUT DB 0AH,0DH,'You  have  completed  30  inputs'
           DB 0AH,0DH,'$'
QUERY_FAIL DB 0AH,0DH,'NOT   FOUND'
           DB 0AH,0DH,'$'
DATA ENDS
STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS
CODE SEGMENT USE16
ASSUME CS:CODE,DS:DATA,SS:STACK
START: MOV AX,DATA
       MOV DS,AX    
       LEA DX,WELCOME   ;显示字符串
       MOV AH,9
       INT 21H
       MOV AH,1      ;读取输入
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

D1:    CALL R1       ;跳转到输入成绩
       JMP START

D2:    CALL R2       ;跳转到查询成绩
       JMP START 

R1 PROC              
       LEA DX,SCR1   
       MOV AH,9
       INT 21H       ;显示字符串
       LEA SI,STU
       LEA BP,INFO
       MOV CX,10     ;设定寄存器,CX用来计算成绩和名次有几个数字
       MOV DI,0      ;DI用来计数
    LOPA1:MOV AX,0 
          MOV [SI],AX
    LOPA:  MOV AH,1
       INT 21H
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
       DIV BL
       CMP AH,0
       JNE EXEC2
       ;处理数据，用到了AX,BX,DX,SI
       POP AX
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
EXEC2: POP AX
       MOV [BP],AX
       INC BP
       DEC CX
       JMP LOPA
       ;处理循环体
       RET
R1 ENDP

R2 PROC    
       LEA DX,SCR2   ;显示字符串
       MOV AH,9
       INT 21H
       ;设定寄存器
       MOV DI,0;存放输入的数据
 LOPB: MOV AH,1
       INT 21H
       CMP AL,'q'
       JE EXIT
       CMP AL,'Q'
       JE EXIT              ;读取完输入，并且确保不是退出
       CMP AL,20H
       JE QUERY             ;确保输入不是空格  
       CMP AL,0DH              
       JE START             ;确保输入不是回车
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

SPACE: MOV AX,DI
       MOV BL,3
       DIV BL
       CMP AH,0
       JE  SP1
 LOP3: INC BP
       LOOP LOP3
       INC DI
       MOV CX,10
       CMP DI,30
       JE  WARNING
       JMP LOPA  
SP1:   ADD SI,2
       INC DI
       JMP LOPA1
  WARNING: LEA DX,FULL_INPUT   ;显示字符串
             MOV AH,9
             INT 21H
             JMP START

QUERY: MOV CX,10
       LEA SI,STU
       MOV AX,0
  Q:   CMP DI,[SI]
       JE  QSUCCESS
       ADD SI,2
       INC AL
       LOOP Q
       JMP QFAIL

QSUCCESS:LEA BP,INFO
         MOV AH,20
         MUL AH
         ADD BP,AX
         MOV CX,10
  LOP4:  MOV AL,[BP]
         CMP AL,0    ;不知道为什么要和0比较
         JE FIN_OUP
         ADD AL,48 
         MOV DL,AL
         MOV AH,2
         INT 21H
         INC BP
         DEC CX
         JMP LOP4
 FIN_OUP:MOV DL,32
         MOV AH,2
         INT 21H
         ADD BP,CX
         MOV CX,0
  LOP5:  MOV AL,[BP];
         CMP AL,0
         JE FIN_OUT 
         ADD AL,48 
         MOV DL,AL
         MOV AH,2
         INT 21H
         INC BP
         JMP LOP5
 FIN_OUT:MOV DL,10
         MOV AH,2
         INT 21H
         JMP LOPB                

QFAIL: LEA DX,QUERY_FAIL   ;显示字符串
       MOV AH,9
       INT 21H
       MOV DI,0
       JMP LOPB 

EXIT:  MOV AH,4CH
       INT 21H
CODE ENDS
END START