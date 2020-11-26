%option noyywrap
%top{
#include "common.h"

#define INT_TYPE 0;
#define BOOL_TYPE 1;
#define CHAR_TYPE 2;
#define STRING_TYPE 3;
#define VOID_TYPE 4;

using namespace std;

}
%{

// struct idKey //符号表key
// {
//     unsigned int zoneId;
//     string idName;
//     idKey(){}
//     idKey(unsigned int zoneId, string idName)
//     {
//         this->zoneId = zoneId;
//         this->idName = idName;
//     }
//     bool operator<(const idKey& key) const
//     {
//         if (this->zoneId < key.zoneId)
//             return true;
//         else if (this->zoneId > key.zoneId)
//             return false;
//         else if (this->idName < key.idName)
//             return true;
//         else
//             return false;
//     }
// };
// struct idValue //符号表value
// {
//     int type;//类型
//     unsigned int idNum;
//     bool isConst;
//     string value;
//     idValue(){}
//     idValue(int type, unsigned int idNum, bool isConst, string value = "0") 
//     {
//         this->type = type;
//         this->idNum = idNum;//编号
//         this->isConst = isConst;
//         this->value = value;
//     }
// };
// struct Zone  //作用域
// {
//     unsigned int id; //作用域编号
//     int father;//父作用域
//     Zone(unsigned int id, int father) 
//     {
//         this->id = id;
//         this->father = father;
//     }
// };

// vector<int> intVec;
// vector<Zone> zoneList; //作用域列表
// map<idKey, idValue> idMap;//id符号表

bool isDec = 0;//记录是否是声明
bool isFor = 0;
bool isAssign = 0;//记录是否遇到等号
bool constStates = 0;//记录是否是const常量
unsigned int typeStates;//记录当前类型状态
unsigned int idCount = 0;//记录id总数
unsigned int curZone = 0;//记录当前作用域编号
unsigned int zoneCount = 0;//记录作用域总数
unsigned int arrayCount = 0;//记录数组总数


%}

PLUS \+
MINUS \-
MUL \*
DIV \/
MODULO %
PLUSASSIGN \+=
MINUSASSIGN \-=
MULASSIGN \*=
DIVASSIGN \/=
MODULOASSIGN %=

ASSIGN =
EQ ==
NEQ !=
GT >
LT <
GTE >=
LTE <=

AND &&
OR \|\|
NOT !

SEMICOLON ;
COMMA ,
COLON :
LPAREN \(
RPAREN \)
LBRACE \{
RBRACE \}
LBRACKET \[
RBRACKET \]

VOID void
INT int
BOOL bool
CHAR char
STRING string
CONST const

COUT cout
CIN cin
COUTSYM <<
CINSYM >>
WHILE while
DO do
FOR for
CONTINUE continue
BREAK break
IF if
ELSE else
SWITCH switch
CASE case
RETURN return

TRUE True|true
FALSE False|false
INTNUM 0|[1-9][0-9]*
OCTNUM 0(0|[1-7][0-7]*)
HEXNUM (0x|0X)(0|[1-9A-Fa-f][0-9A-Fa-f]*)
ID [a-zA-Z][a-zA-Z0-9_]*
STR \"[^\"]+\"
CH \'.\'

line \n
char [^\n\t]
white [\t]

comment "//"[^\n]*

commentbegin "/*"
commentelement .|\n
commentend "*/"
%x COMMENT

%%
{PLUS} {}
{MINUS} {}
{MUL} {}
{DIV} {}
{MODULO} {}
{PLUSASSIGN} {}
{MINUSASSIGN} {}
{MULASSIGN} {}
{DIVASSIGN} {}
{MODULOASSIGN} {}

{ASSIGN} {isAssign=1;}
{EQ} {}
{NEQ} {}
{GT} {}
{LT} {}
{GTE} {}
{LTE} {}

{AND} {}
{OR} {}
{NOT} {}

{SEMICOLON} {isAssign=0; isDec=0; constStates=0;}
{COMMA} {isAssign=0;}
{COLON} {}
{LPAREN} {
    if (isFor == 1){
        zoneCount++;
        zoneList[curZone].children.push_back(zoneCount);
        Zone zone = Zone(zoneCount, curZone);
        curZone = zone.id;
        zoneList.push_back(zone);
    }
}
{RPAREN} {}
{LBRACE} {
    if (isFor){
        zoneCount++;
        zoneList[curZone].children.push_back(zoneCount);
        Zone zone = Zone(zoneCount, curZone);
        curZone = zone.id;
        zoneList.push_back(zone);
    }
}
{RBRACE} {
    curZone = zoneList[curZone].father;
    isFor = 0;
}
{LBRACKET} {}
{RBRACKET} {}

{INT} {isDec=1; typeStates=INT_TYPE;}
{BOOL} {isDec=1; typeStates=BOOL_TYPE;}
{CHAR} {isDec=1; typeStates=CHAR_TYPE;}
{STRING} {isDec=1; typeStates=STRING_TYPE;}
{VOID} {typeStates=VOID_TYPE;}
{CONST} {isDec=1; constStates=1;}

{COUT} {}
{CIN} {}
{COUTSYM} {}
{CINSYM} {}

{WHILE} {}
{DO} {}
{FOR} {isFor = 1;}
{CONTINUE} {}
{BREAK} {}

{IF} {}
{ELSE} {}
{SWITCH} {}
{CASE} {}

{RETURN} {}
{TRUE} {}
{FALSE} {}

{INTNUM} {
        int value = 0;
        for (int i = 0; i < strlen(yytext); i++)
        {
            value = value*10 + yytext[i] - 48;
        }
    }
{OCTNUM} {
        int value = 0;
        for (int i = 1; i < strlen(yytext); i++)
        {
            value = value*8 + yytext[i] - 48;
        }
    }
{HEXNUM} {
        int value = 0;
        for (int i = 2; i < strlen(yytext); i++)
        {
            if (yytext[i]>='0' && yytext[i]<='9')
                value = value*16 + yytext[i] - 48;
            else if (yytext[i]>='a' && yytext[i]<='f')
                value = value*16 + yytext[i] - 87;
            else 
                value = value*16 + yytext[i] - 55;
        }
    }

{STR} {}
{CH} {}

{ID} {
        idKey key = idKey(curZone, yytext);
        if(idMap.count(key) == 0) //符号表未找到
        {
            if (!isAssign && isDec) 
            {   //在声明语句中且不在赋值符之后
                idCount++;
                idValue value = idValue(typeStates, idCount, constStates);
                idMap[key] = value;
            } 
            else
            {   //在父作用域定义
                int tempZoneId = curZone;
                while(true) 
                {
                    tempZoneId = zoneList[tempZoneId].father;
                    key = idKey(tempZoneId, yytext);
                    if(idMap.count(key) != 0) 
                    {
                        break;
                    }
                }
            }
        }
    }


{line} {}
{char} {}
{white} {}

{comment} {}

{commentbegin} {BEGIN COMMENT;}
<COMMENT>{commentelement} {}
<COMMENT>{commentend} {BEGIN INITIAL;}

%%
// int main(int argc,char **argv) 
// { 
//     // Zone zone(0, -1);
//     // zoneList.push_back(zone);//起始作用域（全局）
//     yyFlexLexer lexer;
//     lexer.yylex();
//     return 0;
// }