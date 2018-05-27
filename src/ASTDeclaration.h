#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/IR/PassManager.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/CallingConv.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/Support/TargetSelect.h>
//#include <llvm/ExecutionEngine/GenericValue.h>
//#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/Support/raw_ostream.h>
#include <bits/stdc++.h>
#include <string>
#include <utility>

using namespace std;
using namespace llvm;

typedef std::vector<class NVariableDeclaration *> NVariableDeclarations;
typedef std::vector<class NStatement *> NStatements;
typedef std::vector<class NExpression *> NExpressions;

void generateCode(NStatements *root);

class NVariableDeclaration;

class NIdentifier;

class NExpression;

class NStatement;

class NBlock;

class NFunctionDeclaration;

class NPrintStmt;

class NReadStmt;

class NReturnStmt;

class NAssignmentStmt;

class NForStmt;

class NWhileStmt;

class NIfElseStmt;

class NFunctionCall;

union Node {
    int num;
    char *val;
    NVariableDeclarations *variableDeclarations;
    NStatements *statements;
    NExpressions *expressions;
    NVariableDeclaration *variableDeclaration;
    NFunctionDeclaration *functionDeclaration;
    NIdentifier *identifier;
    NExpression *expression;
    NStatement *statement;
    NBlock *block;
    NFunctionCall *functionCall;
    NPrintStmt *printStmt;
    NReadStmt *readStmt;
    NReturnStmt *returnStmt;
    NAssignmentStmt *assignmentStmt;
    NForStmt *forStmt;
    NWhileStmt *whileStmt;
    NIfElseStmt *ifElseStmt;

    Node() {
        num = 0;
        val = nullptr;
    }

    ~Node() {};
};

typedef union Node YYSTYPE;

class reportError {
public:
    static llvm::Value *ErrorV(const string &str) {
        cout << str << endl;
        return nullptr;
    }
};

class NodeAst {
public:
    virtual Value *codegen(NFunctionDeclaration *) { return nullptr; }
};

class NStatement : public NodeAst {
};

class NFunctionDeclaration : public NStatement {
public:
    std::map<std::string, AllocaInst *> *variables;
    NVariableDeclarations *args;
    NBlock *block;
    std::string name;
    Function *function;

    NFunctionDeclaration(std::string name) :
            name(std::move(name)), args(nullptr), block(nullptr), variables(nullptr),
            function(nullptr) {};

    NFunctionDeclaration(std::string name, NVariableDeclarations *args, NBlock *block) :
            name(std::move(name)), args(args), block(block), function(nullptr),
            variables(new std::map<std::string, AllocaInst *>()) {};

    Value *getVarAlloca(std::string);

    Value *codegen(NFunctionDeclaration *);
};

class NVariableDeclaration : public NStatement {
public:
    int length;
    std::string name;
    std::string type;

    NVariableDeclaration(std::string type, std::string name, int length) :
            type(std::move(type)), name(std::move(name)), length(length) {};

    Value *codegen(NFunctionDeclaration *);
};


class NIdentifier : public NodeAst {
public:
    std::string name;
    NExpression *expression;
    int value;

    NIdentifier(std::string name) :
            name(std::move(name)), value(0), expression(nullptr) {};

    NIdentifier(int value) :
            value(value), name(""), expression(nullptr) {};

    NIdentifier(std::string name, NExpression *expression) :
            name(std::move(name)), expression(expression), value(0) {};

    Value *getAllocation(NFunctionDeclaration *);

    Value *codegen(NFunctionDeclaration *);
};


class NExpression : public NodeAst {
public:
    NExpression *lhs;
    NExpression *rhs;
    NIdentifier *identifier;
    NFunctionCall *functionCall;
    std::string operand;

    NExpression(NExpression *lhs, const string &operand, NExpression *rhs) :
            lhs(lhs), rhs(rhs), identifier(nullptr), functionCall(nullptr), operand(operand) {};

    NExpression(NFunctionCall *functionCall) :
            lhs(nullptr), rhs(nullptr), identifier(identifier), functionCall(functionCall), operand("") {};

    NExpression(NIdentifier *identifier) :
            lhs(nullptr), rhs(nullptr), identifier(identifier), functionCall(nullptr), operand("") {};

    Value *codegen(NFunctionDeclaration *);
};


class NAssignmentStmt : public NStatement {
public:
    NExpression *expression;
    NIdentifier *identifier;

    NAssignmentStmt(NIdentifier *identifier, NExpression *expression) :
            identifier(identifier), expression(expression) {};

    Value *codegen(NFunctionDeclaration *);
};


class NWhileStmt : public NStatement {
public:
    NExpression *condition;
    NBlock *block;

    NWhileStmt(NExpression *condition, NBlock *block) :
            condition(condition), block(block) {};

    Value *codegen(NFunctionDeclaration *);
};

//http://serdis.dis.ulpgc.es/~ii-pl/ftp/enunc/ex-ii-pl-2015-01-19.pdf
class NForStmt : public NStatement {
public:
    NIdentifier *index;
    NExpression *first, *last, *step;
    NBlock *block;

    NForStmt(NIdentifier *index, NExpression *first, NExpression *last, NBlock *block) :
            index(index), first(first), last(last), step(nullptr), block(block) {};


    NForStmt(NIdentifier *index, NExpression *first, NExpression *last, NExpression *step, NBlock *block) :
            index(index), first(first), last(last), step(step), block(block) {};

    Value *codegen(NFunctionDeclaration *);
};


class NIfElseStmt : public NStatement {
private:
    NExpression *condition;
    NBlock *then_block;
    NBlock *else_block;
public:
    NIfElseStmt(NExpression *condition, NBlock *if_block) :
            condition(condition), then_block(if_block), else_block(nullptr) {};

    NIfElseStmt(NExpression *condition, NBlock *if_block, NBlock *else_block) :
            condition(condition), then_block(if_block), else_block(else_block) {};

    Value *codegen(NFunctionDeclaration *);
};


class NBlock : public NStatement {
public:
    NStatements *statements;

    NBlock(NStatements *statements) :
            statements(statements) {};

    Value *codegen(NFunctionDeclaration *);
};


class NPrintStmt : public NStatement {
public:
    std::string text;
    NExpression *value;

    NPrintStmt(std::string text, NExpression *value) :
            text(std::move(text)), value(value) {};

    Value *codegen(NFunctionDeclaration *);
};


class NReadStmt : public NStatement {
public:
    NIdentifier *value;

    NReadStmt(NIdentifier *value) :
            value(value) {};

    Value *codegen(NFunctionDeclaration *);
};


class NFunctionCall : public NodeAst {
public:
    std::string name;
    NExpressions *args;

    NFunctionCall(NIdentifier *name, NExpressions *args) :
            name(name->name), args(args) {};

    Value *codegen(NFunctionDeclaration *);
};

class NReturnStmt : public NStatement {
public:
    NExpression *value;

    NReturnStmt(NExpression *value) :
            value(value) {};

    Value *codegen(NFunctionDeclaration *);
};

