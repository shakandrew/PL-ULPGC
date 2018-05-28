#include <bits/stdc++.h>
#include "ASTDeclaration.h"

using namespace std;
using namespace llvm;

extern int errors;
static LLVMContext Context;
static IRBuilder<> Builder(Context);
static Module *ModuleOb = new Module("xlang compiler", Context);
static NFunctionDeclaration *global;

BasicBlock *createBB(Function *foofunc, string Name) {
    return BasicBlock::Create(Context, Name, foofunc, 0);
}

static AllocaInst *CreateEntryBlockAlloca(Function *TheFunction,
                                          const std::string &VarName) {
    IRBuilder<> TmpB(&TheFunction->getEntryBlock(),
                     TheFunction->getEntryBlock().begin());
    return TmpB.CreateAlloca(Type::getInt32Ty(Context), nullptr, VarName);
}

void generateCode(NStatements *root) {
    global = new NFunctionDeclaration("global");
    for (auto i: *root) {
        i->codegen(global);
    }
    if (errors == 0)
        ModuleOb->dump();
    else
        cout << "Program has Error: " << errors << endl;
}

Value *NFunctionDeclaration::getVarAlloca(std::string var_name) {
    if (variables->find(var_name) == variables->end()) {
        //errors++;
        //return reportError::ErrorV("Unknown variable name: " + var_name);
        return nullptr;
    } else {
        return variables->find(var_name)->second;
    }
}

Value *NIdentifier::getAllocation(NFunctionDeclaration *parent) {
    Value *v = parent->getVarAlloca(name);
    if (v != nullptr) {
        return v;
    } else {
        v = ModuleOb->getNamedGlobal(name);
        if (v != nullptr) {
            if (expression == nullptr)
                return v;
            Value *v_index = expression->codegen(parent);
            if (v_index == nullptr) {
                errors++;
                return reportError::ErrorV("Unknown variable name: " + name + " , trying to load.");
            }
            vector<Value *> array_index;
            array_index.push_back(Builder.getInt32(0));
            array_index.push_back(v_index);
            return Builder.CreateGEP(v, array_index, name + "_Index");
        } else {
            errors++;
            return reportError::ErrorV("Unknown variable name: " + name + " , trying to load.");
        }
    }
}

Value *NFunctionDeclaration::codegen(NFunctionDeclaration *parent) {
    vector<Type *> argTypes;
    for (auto arg: *args) {
        argTypes.push_back(Type::getInt32Ty(Context));
    }
    FunctionType *funType = FunctionType::get(Type::getInt32Ty(Context), makeArrayRef(argTypes), false);

    Function *function = Function::Create(funType, Function::ExternalLinkage, name, ModuleOb);
    BasicBlock *entry = createBB(function, "entry");
    Builder.SetInsertPoint(entry);
    this->function = function;

    // work with args
    Function::arg_iterator iterator = function->arg_begin();
    for (auto i: *args) {
        i->codegen(this);
        Value *argValue = &*iterator++;
        //argValue->setName(i->name);
        Builder.CreateStore(argValue, getVarAlloca(i->name));
    }
    // work with body
    block->codegen(this);
}


Value *NVariableDeclaration::codegen(NFunctionDeclaration *parent) {
    if (parent == global) {
        GlobalVariable *global_var;
        Type *type = Type::getInt32Ty(Context);
        if (length == 0) {
            global_var = new GlobalVariable(*ModuleOb, type, false, GlobalValue::CommonLinkage,
                                            ConstantInt::get(Context, APInt(32, 0)), name);
            global_var->setAlignment(4);
        } else {
            ArrayType *arrType = ArrayType::get(type, length);
            global_var = new GlobalVariable(*ModuleOb, arrType, false,
                                            GlobalValue::CommonLinkage, nullptr, name);
            global_var->setInitializer(ConstantAggregateZero::get(arrType));
        }
    } else {
        AllocaInst *allocaInst = CreateEntryBlockAlloca(parent->function, name);
        parent->variables->insert(std::pair<std::string, AllocaInst *>(name, allocaInst));
    }
}

Value *NIdentifier::codegen(NFunctionDeclaration *parent) {
    if (name.empty()) {
        return ConstantInt::get(Context, APInt(32, value));
    } else {
        // is variable allocated in fun
        Value *var_alloc = getAllocation(parent);
        if (var_alloc != nullptr) {
            return Builder.CreateLoad(var_alloc);
        } else {
            errors++;
            return reportError::ErrorV("Unknown variable name: " + name + " , trying to load.");
        }
    }
}

Value *NExpression::codegen(NFunctionDeclaration *parent) {
    if (lhs == nullptr && rhs == nullptr) {
        if (functionCall == nullptr) {
            return identifier->codegen(parent);
        } else {
            return functionCall->codegen(parent);
        }
    } else {
        Value *left = lhs->codegen(parent);
        Value *right = rhs->codegen(parent);

        if (left == nullptr)
            return reportError::ErrorV("Error in left operand of " + operand);
        if (right == nullptr)
            return reportError::ErrorV("Error in right operand of " + operand);

        if (operand == "+")
            return Builder.CreateAdd(left, right, "addtmp");
        if (operand == "-")
            return Builder.CreateSub(left, right, "subtmp");
        if (operand == "*")
            return Builder.CreateMul(left, right, "multmp");
        if (operand == "/")
            return Builder.CreateSDiv(left, right, "divtmp");
        if (operand == "%")
            return Builder.CreateURem(left, right, "modtmp");
        if (operand == "<")
            return Builder.CreateICmpSLT(left, right, "ltcomparetmp");
        if (operand == ">")
            return Builder.CreateICmpSGT(left, right, "gtcomparetmp");
        if (operand == "<=")
            return Builder.CreateICmpSLE(left, right, "lecomparetmp");
        if (operand == ">=")
            return Builder.CreateICmpSGE(left, right, "gecomparetmp");
        if (operand == "==")
            return Builder.CreateICmpEQ(left, right, "equalcomparetmp");
        if (operand == "!=")
            return Builder.CreateICmpNE(left, right, "notequalcomparetmp");
    }

}

Value *NAssignmentStmt::codegen(NFunctionDeclaration *parent) {
    Value *var_alloca = identifier->getAllocation(parent);
    Value *var_new_value = expression->codegen(parent);
    if (var_alloca != nullptr && var_new_value != nullptr) {
        Builder.CreateStore(var_new_value, var_alloca);
    }
}

Value *NWhileStmt::codegen(NFunctionDeclaration *parent) {
    BasicBlock *loop = createBB(parent->function, "loop");
    BasicBlock *after = createBB(parent->function, "afterloop");

    Value *cond_gen = condition->codegen(parent);
    Value *loop_condition = Builder.CreateICmpNE(cond_gen, Builder.getInt1(false), "whilecon");
    Builder.CreateCondBr(loop_condition, loop, after);
    Builder.SetInsertPoint(loop);
    block->codegen(parent);
    cond_gen = condition->codegen(parent);
    Value *after_loop_condition = Builder.CreateICmpNE(cond_gen, Builder.getInt1(false), "whilecon");
    Builder.CreateCondBr(after_loop_condition, loop, after);
    Builder.SetInsertPoint(after);
}

Value *NForStmt::codegen(NFunctionDeclaration *parent) {
    BasicBlock *loopBB = createBB(parent->function, "loop");
    BasicBlock *afterLoopBB = createBB(parent->function, "afterLoop");

    Value *loop_variable_alloc = index->getAllocation(parent);

    Value *init_value = first->codegen(parent);
    Value *limit_value = last->codegen(parent);

    if (loop_variable_alloc == nullptr || init_value == nullptr || limit_value == nullptr) {
        errors++;
        reportError::ErrorV("loop variable not found: " + this->index->name);
    }

    Builder.CreateStore(init_value, loop_variable_alloc);

    Value *condition = Builder.CreateICmpULT(init_value, limit_value, "condition");
    Builder.CreateCondBr(condition, loopBB, afterLoopBB);
    Builder.SetInsertPoint(loopBB);

    block->codegen(parent);

    Value *inc;
    if (step == nullptr) {
        inc = Builder.getInt32(1);
    } else {
        inc = step->codegen(parent);
    }

    Value *loop_variable = Builder.CreateLoad(loop_variable_alloc);
    loop_variable = Builder.CreateAdd(loop_variable, inc, "next");
    Builder.CreateStore(loop_variable, loop_variable_alloc);

    condition = Builder.CreateICmpULT(loop_variable, limit_value, "loopCondition");
    Builder.CreateCondBr(condition, loopBB, afterLoopBB);
    Builder.SetInsertPoint(afterLoopBB);
}

Value *NIfElseStmt::codegen(NFunctionDeclaration *parent){
    BasicBlock *thenBB = createBB(parent->function, "then_block");
    BasicBlock *elseBB = createBB(parent->function, "else_block");
    BasicBlock *ifContinueBB = createBB(parent->function, "ifcont_block");

    Value *if_cond = condition->codegen(parent);
    Builder.CreateCondBr(if_cond, thenBB, elseBB);
    Builder.SetInsertPoint(thenBB);
    then_block->codegen(parent);
    Builder.CreateBr(ifContinueBB);

    thenBB = Builder.GetInsertBlock();
    Builder.SetInsertPoint(elseBB);
    if (else_block != nullptr) {
        else_block->codegen(parent);
    }
    Builder.CreateBr(ifContinueBB);

    elseBB = Builder.GetInsertBlock();

    Builder.SetInsertPoint(ifContinueBB);
}

Value *NBlock::codegen(NFunctionDeclaration *parent) {
    for (auto stmt: *statements) {
        stmt->codegen(parent);
    }
}

Value *NPrintStmt::codegen(NFunctionDeclaration *parent) {
    vector<Value *> args;
    vector<Type *> type;
    if (value == nullptr) {
        args.push_back(Builder.CreateGlobalStringPtr(text));
        type.push_back(args.back()->getType());
    } else {
        args.push_back(Builder.CreateGlobalStringPtr(text));
        type.push_back(args.back()->getType());

        args.push_back(value->codegen(parent));
        type.push_back(args.back()->getType());
    }

    FunctionType *FType = FunctionType::get(Type::getInt32Ty(Context), makeArrayRef(type), false);
    Constant *printFunc = ModuleOb->getOrInsertFunction("printf", FType);
    return Builder.CreateCall(printFunc, makeArrayRef(args));
}

Value *NReadStmt::codegen(NFunctionDeclaration *parent) {
    vector<Value *> args;
    vector<Type *> type;

    args.push_back(Builder.CreateGlobalStringPtr("%d"));
    type.push_back(args.back()->getType());

    args.push_back(value->getAllocation(parent));
    type.push_back(args.back()->getType());


    FunctionType *FType = FunctionType::get(Type::getInt32Ty(Context), makeArrayRef(type), false);
    Constant *readfunc = ModuleOb->getOrInsertFunction("scanf", FType);
    return Builder.CreateCall(readfunc, makeArrayRef(args));

}

Value *NFunctionCall::codegen(NFunctionDeclaration *parent) {
    Function *function = ModuleOb->getFunction(name);
    if (function == nullptr) {
        errors++;
        return reportError::ErrorV("Try to call not-existing function: " + name);
    }
    vector<Value *> function_args;
    for (auto i: *args) {
        function_args.push_back(i->codegen(parent));
    }
    return Builder.CreateCall(function, function_args);
}

Value *NReturnStmt::codegen(NFunctionDeclaration *parent) {
    Builder.CreateRet(value->codegen(parent));
}
