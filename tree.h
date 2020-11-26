#ifndef TREE_H
#define TREE_H
#include "pch.h"
#include "type.h"

using std::cerr;
using std::cout;
using std::endl;
using std::string;

enum NodeType{
    NODE_CONST,//常量（常量名）
    NODE_VAR,//变量（变量名）
    NODE_VALUE,//数值或字符串等，如123456、"I love NKU."
    //NODE_BOOL,//？
    NODE_EXPR,//表达式
    NODE_TYPE,//int a = 1里的int等
    NODE_STMT,//语句
    NODE_PROG,//根节点
    NODE_OP//运算符+-*/
};

enum StmtType{
    STMT_IF,
    STMT_WHILE,
    STMT_FOR,
    STMT_DECL,
    STMT_ASSIGN,
    STMT_PRINTF,
    STMT_SCANF,//break,continue
    STMT_BREAK,
    STMT_CONTINUE
};

enum OpType{
    OP_ASSIGN,
    OP_EQUAL,
    OP_NOT_EQUAL,
    OP_GREATER,
    OP_LESS,
    OP_GREATER_EQUAL,
    OP_LESS_EQUAL,
    OP_NOT,
    OP_OR,
    OP_AND,
    OP_ADD,
    OP_MINUS,
    OP_MUL,
    OP_DIV,
    OP_MODULO,
    OP_PLUS_ASSIGN,
    OP_MINUS_ASSIGN,
    OP_MUL_ASSIGN,
    OP_DIV_ASSIGN,
    OP_MODULO_ASSIGN
};

// enum VarType{
//     VAR_INTEGER,//
//     VAR_CHAR,//
//     VAR_BOOL,
//     VAR_VOID,//
//     VALUE_STRING,
//     COMPOSE_STRUCT,
//     COMPOSE_UNION,
//     COMPOSE_FUNCTION
// };

struct TreeNode {
    int nodeID;
    int lineno;//行号
    NodeType nodeType;

    TreeNode *child = nullptr;
    TreeNode *sibling = nullptr;

    void addChild(TreeNode *);
    void addSibling(TreeNode *);

    void genNodeId();//从根节点开始逐个赋Id 实现方式同学们可以自行修改

    void printAST();//打印语法树结点
    /***
     * 以下的几个函数皆为在printAST过程中辅助输出使用
     * 同学们可以根据需要自己使用其他方法
    ***/
    void printNodeInfo();
    void printNodeConnection();
    string nodeTypeInfo();
    string stmtInfo();
    string OPInfo();
    string ValInfo(bool isConst);

    int int_val;
    bool bool_val;
    char ch_val;
    string str_val;
    StmtType stmtType;
    OpType opType;
    VarType varType;
    string var_name;
    Type* type;  // 变量、类型、表达式结点，有类型
    
    std::ofstream outfile;

    TreeNode(int lineno, NodeType type);
};
#endif