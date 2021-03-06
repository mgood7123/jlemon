/*
** 2001 September 15
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
*************************************************************************
** This file contains SQLite's grammar for SQL.  Process this file
** using the lemon parser generator to generate C code that runs
** the parser.  Lemon will also generate a header file containing
** numeric codes for all of the tokens.
*/

// All token codes are small integers with #defines that begin with "TK_"
%token_prefix TK_

// The type of the data attached to each token is Token.  This is also the
// default type for non-terminals.
//
%token_type {Token}
%default_type {Token}

// The generated parser function takes a 4th argument as follows:
%extra_argument {Context context}

// This code runs whenever there is a syntax error
//
%syntax_error {
  context.sqlite3ErrorMsg("near \"%s\": syntax error", yyminor.text());
}
%stack_overflow {
  context.sqlite3ErrorMsg("parser stack overflow");
}

// The name of the generated procedure that implements the parser
// is as follows:
%name sqlite3Parser

// The following text is included near the beginning of the C source
// code file that implements the parser.
//
%include {
package org.sqlite.parser;

import java.util.List;
import org.sqlite.parser.ast.*;

import static org.sqlite.parser.Helper.append;

/*
** Disable all error recovery processing in the parser push-down
** automaton.
*/
#define YYNOERRORRECOVERY 1

/*
** Make yytestcase() the same as testcase()
*/
#define yytestcase(X)

} // end %include

// Input is a single SQL command
input ::= cmdlist.
cmdlist ::= cmdlist ecmd.
cmdlist ::= ecmd.
ecmd ::= SEMI.
ecmd ::= cmdx SEMI.
%ifndef SQLITE_OMIT_EXPLAIN
ecmd ::= explain cmdx.
explain ::= EXPLAIN.              { context.explain = ExplainKind.Explain; }
explain ::= EXPLAIN QUERY PLAN.   { context.explain = ExplainKind.QueryPlan; }
%endif  SQLITE_OMIT_EXPLAIN
cmdx ::= cmd.           { context.sqlite3FinishCoding(); }

///////////////////// Begin and end transactions. ////////////////////////////
//

cmd ::= BEGIN transtype(Y) trans_opt(X).  {context.stmt = new Begin(Y, X);}
%type trans_opt {String}
trans_opt(A) ::= .               {A = null;}
trans_opt(A) ::= TRANSACTION.       {A = null;}
trans_opt(A) ::= TRANSACTION nm(X). {A = X.text();}
%type transtype {TransactionType}
transtype(A) ::= .             {A = null;}
transtype(A) ::= DEFERRED(X).  {A = TransactionType.from(@X); /*A-overwrites-X*/}
transtype(A) ::= IMMEDIATE(X). {A = TransactionType.from(@X); /*A-overwrites-X*/}
transtype(A) ::= EXCLUSIVE(X). {A = TransactionType.from(@X); /*A-overwrites-X*/}
cmd ::= COMMIT|END trans_opt(X).      {context.stmt = new Commit(X);}
cmd ::= ROLLBACK trans_opt(X).    {context.stmt = new Rollback(X, null);}

savepoint_opt ::= SAVEPOINT.
savepoint_opt ::= .
cmd ::= SAVEPOINT nm(X). {
  context.stmt = new Savepoint(X.text());
}
cmd ::= RELEASE savepoint_opt nm(X). {
  context.stmt = new Release(X.text());
}
cmd ::= ROLLBACK trans_opt(Y) TO savepoint_opt nm(X). {
  context.stmt = new Rollback(Y, X.text());
}

///////////////////// The CREATE TABLE statement ////////////////////////////
//
cmd ::= createkw temp(T) TABLE ifnotexists(E) nm(Y) dbnm(Z) create_table_args(X). {
  QualifiedName tblName = QualifiedName.from(Y, Z);
  context.stmt = new CreateTable(T, E, tblName, X);
}
createkw(A) ::= CREATE(A).

%type ifnotexists {boolean}
ifnotexists(A) ::= .              {A = false;}
ifnotexists(A) ::= IF NOT EXISTS. {A = true;}
%type temp {boolean}
%ifndef SQLITE_OMIT_TEMPDB
temp(A) ::= TEMP.  {A = true;}
%endif  SQLITE_OMIT_TEMPDB
temp(A) ::= .      {A = false;}

%type create_table_args {CreateTableBody}
create_table_args(A) ::= LP columnlist(C) conslist_opt(X) RP table_options(F). {
  A = new ColumnsAndConstraints(C, X, F);
}
create_table_args(A) ::= AS select(S). {
  A = new AsSelect(S);
}
%type table_options {boolean}
table_options(A) ::= .    {A = false;}
table_options(A) ::= WITHOUT nm(X). {
  if( "rowid".equalsIgnoreCase(X.text()) ){
    A = true;
  }else{
    A = false;
    context.sqlite3ErrorMsg("unknown table option: %s", X.text());
  }
}
%type columnlist {List<ColumnDefinition>}
columnlist(A) ::= columnlist(A) COMMA columnname(X) carglist(Y). {
  A = append(A, new ColumnDefinition(X,Y)); // TODO check "too many columns on %s"
}
columnlist(A) ::= columnname(X) carglist(Y). {
  A = append(null, new ColumnDefinition(X,Y));
}
%type columnname {ColumnNameAndType}
columnname(A) ::= nm(X) typetoken(Y). {A = new ColumnNameAndType(X.text(), Y);}

// Declare some tokens early in order to influence their values, to
// improve performance and reduce the executable size.  The goal here is
// to get the "jump" operations in ISNULL through ESCAPE to have numeric
// values that are early enough so that all jump operations are clustered
// at the beginning, but also so that the comparison tokens NE through GE
// are as large as possible so that they are near to FUNCTION, which is a
// token synthesized by addopcodes.tcl.
//
%token ABORT ACTION AFTER ANALYZE ASC ATTACH BEFORE BEGIN BY CASCADE CAST.
%token CONFLICT DATABASE DEFERRED DESC DETACH EACH END EXCLUSIVE EXPLAIN FAIL.
%token OR AND NOT IS MATCH LIKE_KW BETWEEN IN ISNULL NOTNULL NE EQ.
%token GT LE LT GE ESCAPE.

// The following directive causes tokens ABORT, AFTER, ASC, etc. to
// fallback to ID if they will not parse as their original value.
// This obviates the need for the "id" nonterminal.
//
%fallback ID
  ABORT ACTION AFTER ANALYZE ASC ATTACH BEFORE BEGIN BY CASCADE CAST COLUMNKW
  CONFLICT DATABASE DEFERRED DESC DETACH DO
  EACH END EXCLUSIVE EXPLAIN FAIL FOR
  IGNORE IMMEDIATE INITIALLY INSTEAD LIKE_KW MATCH NO PLAN
  QUERY KEY OF OFFSET PRAGMA RAISE RECURSIVE RELEASE REPLACE RESTRICT ROW
  ROLLBACK SAVEPOINT TEMP TRIGGER VACUUM VIEW VIRTUAL WITH WITHOUT
%ifdef SQLITE_OMIT_COMPOUND_SELECT
  EXCEPT INTERSECT UNION
%endif SQLITE_OMIT_COMPOUND_SELECT
  REINDEX RENAME CTIME_KW IF
  .
%wildcard ANY.

// Define operator precedence early so that this is the first occurrence
// of the operator tokens in the grammer.  Keeping the operators together
// causes them to be assigned integer values that are close together,
// which keeps parser tables smaller.
//
// The token values assigned to these symbols is determined by the order
// in which lemon first sees them.  It must be the case that ISNULL/NOTNULL,
// NE/EQ, GT/LE, and GE/LT are separated by only a single value.  See
// the sqlite3ExprIfFalse() routine for additional information on this
// constraint.
//
%left OR.
%left AND.
%right NOT.
%left IS MATCH LIKE_KW BETWEEN IN ISNULL NOTNULL NE EQ.
%left GT LE LT GE.
%right ESCAPE.
%left BITAND BITOR LSHIFT RSHIFT.
%left PLUS MINUS.
%left STAR SLASH REM.
%left CONCAT.
%left COLLATE.
%right BITNOT.
%nonassoc ON.

// An IDENTIFIER can be a generic identifier, or one of several
// keywords.  Any non-standard keyword can also be an identifier.
//
%token_class id  ID|INDEXED.


// And "ids" is an identifer-or-string.
//
%token_class ids  ID|STRING.

// The name of a column or table can be any of the following:
//
%type nm {Token}
nm(A) ::= id(A).
nm(A) ::= STRING(A).
nm(A) ::= JOIN_KW(A).

// A typetoken is really zero or more tokens that form a type name such
// as can be found after the column name in a CREATE TABLE statement.
// Multiple tokens are concatenated to form the value of the typetoken.
//
%type typetoken {Type}
typetoken(A) ::= .   {A = null;}
typetoken(A) ::= typename(X). {A = new Type(X.text(), null);}
typetoken(A) ::= typename(X) LP signed(Y) RP. {
  A = new Type(X.text(), TypeSize.maxSize(Y));
}
typetoken(A) ::= typename(X) LP signed(Y) COMMA signed(Z) RP. {
  A = new Type(X.text(), TypeSize.couple(Y, Z));
}
%type typename {Token}
typename(A) ::= ids(A).
typename(A) ::= typename(A) ids(Y). {A.append(Y);}
%type signed {Expr}
signed ::= plus_num.
signed ::= minus_num.

// "carglist" is a list of additional constraints that come after the
// column name and column type in a CREATE TABLE statement.
//
%type carglist {List<ColumnConstraint>}
carglist(A) ::= carglist(A) ccons(X). {A=append(A,X);}
carglist(A) ::= .                     {A=null;}
%type ccons {ColumnConstraint}
ccons(A) ::= CONSTRAINT nm(X).           {context.constraintName(X.text()); A = null;}
ccons(A) ::= DEFAULT term(X).            {A = new DefaultColumnConstraint(context.constraintName(),X);}
ccons(A) ::= DEFAULT LP expr(X) RP.      {A = new DefaultColumnConstraint(context.constraintName(),new ParenthesizedExpr(X));}
ccons(A) ::= DEFAULT PLUS term(X).       {A = new DefaultColumnConstraint(context.constraintName(),new UnaryExpr(UnaryOperator.Positive, X));}
ccons(A) ::= DEFAULT MINUS term(X).      {
  UnaryExpr v;
  v = new UnaryExpr(UnaryOperator.Negative, X);
  A = new DefaultColumnConstraint(context.constraintName(),v);
}
ccons(A) ::= DEFAULT id(X).              {
  IdExpr v;
  v = new IdExpr(X.text());
  A = new DefaultColumnConstraint(context.constraintName(),v);
}

// In addition to the type name, we also care about the primary key and
// UNIQUE constraints.
//
ccons(A) ::= NULL onconf(R). {A = new NotNullColumnConstraint(context.constraintName(),true, R);}
ccons(A) ::= NOT NULL onconf(R).    {A = new NotNullColumnConstraint(context.constraintName(),false, R);}
ccons(A) ::= PRIMARY KEY sortorder(Z) onconf(R) autoinc(I).
                                 {A = new PrimaryKeyColumnConstraint(context.constraintName(),Z, R, I);}
ccons(A) ::= UNIQUE onconf(R).      {A = new UniqueColumnConstraint(context.constraintName(),R);}
ccons(A) ::= CHECK LP expr(X) RP.   {A = new CheckColumnConstraint(context.constraintName(),X);}
ccons(A) ::= REFERENCES nm(T) eidlist_opt(TA) refargs(R).
                                 {A = new ForeignKeyColumnConstraint(context.constraintName(),new ForeignKeyClause(T.text(),TA,R), null);}
ccons(A) ::= defer_subclause(D).    {A = D;}
ccons(A) ::= COLLATE ids(C).        {A = new CollateColumnConstraint(context.constraintName(),C.text());}

// The optional AUTOINCREMENT keyword
%type autoinc {boolean}
autoinc(X) ::= .          {X = false;}
autoinc(X) ::= AUTOINCR.  {X = true;}

// The next group of rules parses the arguments to a REFERENCES clause
// that determine if the referential integrity checking is deferred or
// or immediate and which determine what action to take if a ref-integ
// check fails.
//
%type refargs {List<RefArg>}
refargs(A) ::= .                  { A = null; /* EV: R-19803-45884 */}
refargs(A) ::= refargs(A) refarg(Y). { A = append(A, Y); }
%type refarg {RefArg}
refarg(A) ::= MATCH nm(X).              { A = new MatchRefArg(X.text()); }
refarg(A) ::= ON INSERT refact(X).      { A = new OnInsertRefArg(X); }
refarg(A) ::= ON DELETE refact(X).   { A = new OnDeleteRefArg(X); }
refarg(A) ::= ON UPDATE refact(X).   { A = new OnUpdateRefArg(X); }
%type refact {RefAct}
refact(A) ::= SET NULL.              { A = RefAct.SetNull;  /* EV: R-33326-45252 */}
refact(A) ::= SET DEFAULT.           { A = RefAct.SetDefault;  /* EV: R-33326-45252 */}
refact(A) ::= CASCADE.               { A = RefAct.Cascade;  /* EV: R-33326-45252 */}
refact(A) ::= RESTRICT.              { A = RefAct.Restrict; /* EV: R-33326-45252 */}
refact(A) ::= NO ACTION.             { A = RefAct.NoAction;     /* EV: R-33326-45252 */}
%type defer_subclause {DeferSubclause}
defer_subclause(A) ::= NOT DEFERRABLE init_deferred_pred_opt(X).     {A = new DeferSubclause(false, X);}
defer_subclause(A) ::= DEFERRABLE init_deferred_pred_opt(X).      {A = new DeferSubclause(true, X);}
%type init_deferred_pred_opt {InitDeferredPred}
init_deferred_pred_opt(A) ::= .                       {A = null;}
init_deferred_pred_opt(A) ::= INITIALLY DEFERRED.     {A = InitDeferredPred.InitiallyDeferred;}
init_deferred_pred_opt(A) ::= INITIALLY IMMEDIATE.    {A = InitDeferredPred.InitiallyImmediate;}

%type conslist_opt {List<TableConstraint>}
conslist_opt(A) ::= .                         {A = null;}
conslist_opt(A) ::= COMMA conslist(X).        {A = X;}
%type conslist {List<TableConstraint>}
conslist(A) ::= conslist(A) tconscomma tcons(X). {A = append(A,X);}
conslist(A) ::= tcons(X).                        {A = append(null,X);}
tconscomma ::= COMMA.            {context.constraintName(null);}
tconscomma ::= .
%type tcons {TableConstraint}
tcons(A) ::= CONSTRAINT nm(X).      {context.constraintName(X.text()); A = null;}
tcons(A) ::= PRIMARY KEY LP sortlist(X) autoinc(I) RP onconf(R).
                                 {A = new PrimaryKeyTableConstraint(context.constraintName(),X, I, R);}
tcons(A) ::= UNIQUE LP sortlist(X) RP onconf(R).
                                 {A = new UniqueTableConstraint(context.constraintName(),X, R
                                       );}
tcons(A) ::= CHECK LP expr(E) RP onconf.
                                 {A = new CheckTableConstraint(context.constraintName(),E);}
tcons(A) ::= FOREIGN KEY LP eidlist(FA) RP
           REFERENCES nm(T) eidlist_opt(TA) refargs(R) defer_subclause_opt(D). {
    A = new ForeignKeyTableConstraint(context.constraintName(),FA, new ForeignKeyClause(T.text(),TA,R), D);
}
%type defer_subclause_opt {DeferSubclause}
defer_subclause_opt(A) ::= .                    {A = null;}
defer_subclause_opt(A) ::= defer_subclause(A).

// The following is a non-standard extension that allows us to declare the
// default behavior when there is a constraint conflict.
//
%type onconf {ResolveType}
%type orconf {ResolveType}
%type resolvetype {ResolveType}
onconf(A) ::= .                              {A = null;}
onconf(A) ::= ON CONFLICT resolvetype(X).    {A = X;}
orconf(A) ::= .                              {A = null;}
orconf(A) ::= OR resolvetype(X).             {A = X;}
resolvetype(A) ::= raisetype(A).
resolvetype(A) ::= IGNORE.                   {A = ResolveType.Ignore;}
resolvetype(A) ::= REPLACE.                  {A = ResolveType.Replace;}

////////////////////////// The DROP TABLE /////////////////////////////////////
//
cmd ::= DROP TABLE ifexists(E) fullname(X). {
  context.stmt = new DropTable(E, X);
}
%type ifexists {boolean}
ifexists(A) ::= IF EXISTS.   {A = true;}
ifexists(A) ::= .            {A = false;}

///////////////////// The CREATE VIEW statement /////////////////////////////
//
%ifndef SQLITE_OMIT_VIEW
cmd ::= createkw temp(T) VIEW ifnotexists(E) nm(Y) dbnm(Z) eidlist_opt(C)
          AS select(S). {
  QualifiedName viewName = QualifiedName.from(Y, Z);
  context.stmt = new CreateView(T, E, viewName, C, S);
}
cmd ::= DROP VIEW ifexists(E) fullname(X). {
  context.stmt = new DropView(E, X);
}
%endif  SQLITE_OMIT_VIEW

//////////////////////// The SELECT statement /////////////////////////////////
//
cmd ::= select(S). {context.stmt = S;}

%type select {Select}
%type selectnowith {SelectBody}
%type oneselect {OneSelect}

%ifndef SQLITE_OMIT_CTE
select(A) ::= WITH wqlist(W) selectnowith(X) orderby_opt(Z) limit_opt(L). {
  A = new Select(new With(false, W), X, Z, L);
}
select(A) ::= WITH RECURSIVE wqlist(W) selectnowith(X) orderby_opt(Z) limit_opt(L). {
  A = new Select(new With(true, W), X, Z, L);
}
%endif /* SQLITE_OMIT_CTE */
select(A) ::= selectnowith(X) orderby_opt(Z) limit_opt(L). {
  A = new Select(null, X, Z, L); /*A-overwrites-X*/
}

selectnowith(A) ::= oneselect(X). {
  A = new SelectBody(X, new java.util.ArrayList<>());
}
%ifndef SQLITE_OMIT_COMPOUND_SELECT
selectnowith(A) ::= selectnowith(A) multiselect_op(Y) oneselect(Z).  {
  CompoundSelect cs = new CompoundSelect(Y, Z);
  A.compounds.add(cs);
}
%type multiselect_op {CompoundOperator}
multiselect_op(A) ::= UNION(OP).             {A = CompoundOperator.from(@OP); /*A-overwrites-OP*/}
multiselect_op(A) ::= UNION ALL.             {A = CompoundOperator.UnionAll;}
multiselect_op(A) ::= EXCEPT|INTERSECT(OP).  {A = CompoundOperator.from(@OP); /*A-overwrites-OP*/}
%endif SQLITE_OMIT_COMPOUND_SELECT
oneselect(A) ::= SELECT distinct(D) selcollist(W) from(X) where_opt(Y)
                 groupby_opt(P). {
  A = new OneSelect(D, W, X, Y, P);
}
oneselect(A) ::= values(A).

%type values {OneSelect}
values(A) ::= VALUES LP nexprlist(X) RP. {
  List<List<Expr>> values = new java.util.ArrayList<>();
  values.add(X);
  A = new OneSelect(values);
}
values(A) ::= values(A) COMMA LP exprlist(Y) RP. {
  A.values.add(Y);
}

// The "distinct" nonterminal is true (1) if the DISTINCT keyword is
// present and false (0) if it is not.
//
%type distinct {Distinctness}
distinct(A) ::= DISTINCT.   {A = Distinctness.Distinct;}
distinct(A) ::= ALL.        {A = Distinctness.All;}
distinct(A) ::= .           {A = null;}

// selcollist is a list of expressions that are to become the return
// values of the SELECT statement.  The "*" in statements like
// "SELECT * FROM ..." is encoded as a special expression with an
// opcode of TK_ASTERISK.
//
%type selcollist {List<ResultColumn>}
%type sclp {List<ResultColumn>}
sclp(A) ::= selcollist(A) COMMA.
sclp(A) ::= .                                {A = null;}
selcollist(A) ::= sclp(A) expr(X) as(Y).     {
   ResultColumn rc = ResultColumn.expr(X, Y);
   A = append(A, rc);
}
selcollist(A) ::= sclp(A) STAR. {
  ResultColumn rc = ResultColumn.star();
  A = append(A, rc);
}
selcollist(A) ::= sclp(A) nm(X) DOT STAR. {
  ResultColumn rc = ResultColumn.tableStar(X.text());
  A = append(A, rc);
}

// An option "AS <id>" phrase that can follow one of the expressions that
// define the result set, or one of the tables in the FROM clause.
//
%type as {As}
as(A) ::= AS nm(Y).    {A = As.as(Y.text());}
as(A) ::= ids(X).      {A = As.elided(X.text());}
as(A) ::= .            {A = null;}


%type seltablist {FromClause}
%type stl_prefix {FromClause}
%type from {FromClause}

// A complete FROM clause.
//
from(A) ::= .                {A = null;}
from(A) ::= FROM seltablist(X). {
  A = X;
}

// "seltablist" is a "Select Table List" - the content of the FROM clause
// in a SELECT statement.  "stl_prefix" is a prefix of this list.
//
stl_prefix(A) ::= seltablist(A) joinop(Y).    {
  FromClause.from(A, Y);
}
stl_prefix(A) ::= .                           {A = null;}
seltablist(A) ::= stl_prefix(A) nm(Y) dbnm(D) as(Z) indexed_opt(I)
                  on_opt(N) using_opt(U). {
  QualifiedName tblName = QualifiedName.from(Y, D);
  SelectTable st = SelectTable.table(tblName, Z, I);
  JoinConstraint jc = JoinConstraint.from(N, U);
  A = FromClause.from(A, st, jc);
}
seltablist(A) ::= stl_prefix(A) nm(Y) dbnm(D) LP exprlist(E) RP as(Z)
                  on_opt(N) using_opt(U). {
  QualifiedName tblName = QualifiedName.from(Y, D);
  SelectTable st = SelectTable.tableCall(tblName, E, Z);
  JoinConstraint jc = JoinConstraint.from(N, U);
  A = FromClause.from(A, st, jc);
}
%ifndef SQLITE_OMIT_SUBQUERY
  seltablist(A) ::= stl_prefix(A) LP select(S) RP
                    as(Z) on_opt(N) using_opt(U). {
    SelectTable st = SelectTable.select(S, Z);
    JoinConstraint jc = JoinConstraint.from(N, U);
    A = FromClause.from(A, st, jc);
  }
  seltablist(A) ::= stl_prefix(A) LP seltablist(F) RP
                    as(Z) on_opt(N) using_opt(U). {
    SelectTable st = SelectTable.sub(F, Z);
    JoinConstraint jc = JoinConstraint.from(N, U);
    A = FromClause.from(A, st, jc);
  }
%endif  SQLITE_OMIT_SUBQUERY

%type dbnm {String}
dbnm(A) ::= .          {A = null;}
dbnm(A) ::= DOT nm(X). {A = X.text();}

%type fullname {QualifiedName}
fullname(A) ::= nm(X).
   {A = QualifiedName.from(null, X, null); /*A-overwrites-X*/}
fullname(A) ::= nm(X) DOT nm(Y).
   {A = QualifiedName.from(X, Y, null); /*A-overwrites-X*/}

%type xfullname {QualifiedName}
xfullname(A) ::= nm(X).
   {A = QualifiedName.from(null, X, null); /*A-overwrites-X*/}
xfullname(A) ::= nm(X) DOT nm(Y).
   {A = QualifiedName.from(X, Y, null); /*A-overwrites-X*/}
xfullname(A) ::= nm(X) DOT nm(Y) AS nm(Z).  {
   A = QualifiedName.from(X, Y, Z); /*A-overwrites-X*/
}
xfullname(A) ::= nm(X) AS nm(Z). {
   A = QualifiedName.from(null, X, Z); /*A-overwrites-X*/
}

%type joinop {JoinOperator}
joinop(X) ::= COMMA|JOIN(A).              { X = JoinOperator.from(A, null, null); }
joinop(X) ::= JOIN_KW(A) JOIN.
                  {X = JoinOperator.from(A,null,null);  /*X-overwrites-A*/}
joinop(X) ::= JOIN_KW(A) nm(B) JOIN.
                  {X = JoinOperator.from(A,B,null); /*X-overwrites-A*/}
joinop(X) ::= JOIN_KW(A) nm(B) nm(C) JOIN.
                  {X = JoinOperator.from(A,B,C);/*X-overwrites-A*/}

// There is a parsing abiguity in an upsert statement that uses a
// SELECT on the RHS of a the INSERT:
//
//      INSERT INTO tab SELECT * FROM aaa JOIN bbb ON CONFLICT ...
//                                        here ----^^
//
// When the ON token is encountered, the parser does not know if it is
// the beginning of an ON CONFLICT clause, or the beginning of an ON
// clause associated with the JOIN.  The conflict is resolved in favor
// of the JOIN.  If an ON CONFLICT clause is intended, insert a dummy
// WHERE clause in between, like this:
//
//      INSERT INTO tab SELECT * FROM aaa JOIN bbb WHERE true ON CONFLICT ...
//
// The [AND] and [OR] precedence marks in the rules for on_opt cause the
// ON in this context to always be interpreted as belonging to the JOIN.
//
%type on_opt {Expr}
on_opt(N) ::= ON expr(E).  {N = E;}
on_opt(N) ::= .     [OR]   {N = null;}

// Note that this block abuses the Token type just a little. If there is
// no "INDEXED BY" clause, the returned token is empty (z==0 && n==0). If
// there is an INDEXED BY clause, then the token is populated as per normal,
// with z pointing to the token data and n containing the number of bytes
// in the token.
//
// If there is a "NOT INDEXED" clause, then (z==0 && n==1), which is 
// normally illegal. The sqlite3SrcListIndexedBy() function 
// recognizes and interprets this as a special case.
//
%type indexed_opt {Indexed}
indexed_opt(A) ::= .                 {A = null;}
indexed_opt(A) ::= INDEXED BY nm(X). {A = new Indexed(X.text());}
indexed_opt(A) ::= NOT INDEXED.      {A = new Indexed(null);}

%type using_opt {List<String>}
using_opt(U) ::= USING LP idlist(L) RP.  {U = L;}
using_opt(U) ::= .                        {U = null;}


%type orderby_opt {List<SortedColumn>}

// the sortlist non-terminal stores a list of expression where each
// expression is optionally followed by ASC or DESC to indicate the
// sort order.
//
%type sortlist {List<SortedColumn>}

orderby_opt(A) ::= .                          {A = null;}
orderby_opt(A) ::= ORDER BY sortlist(X).      {A = X;}
sortlist(A) ::= sortlist(A) COMMA expr(Y) sortorder(Z). {
  SortedColumn sc = new SortedColumn(Y, Z);
  A = append(A,sc);
}
sortlist(A) ::= expr(Y) sortorder(Z). {
  SortedColumn sc = new SortedColumn(Y, Z); /*A-overwrites-Y*/
  A = append(null,sc);
}

%type sortorder {SortOrder}

sortorder(A) ::= ASC.           {A = SortOrder.Asc;}
sortorder(A) ::= DESC.          {A = SortOrder.Desc;}
sortorder(A) ::= .              {A = null;}

%type groupby_opt {GroupBy}
groupby_opt(A) ::= .                      {A = null;}
groupby_opt(A) ::= GROUP BY nexprlist(X) having_opt(Y). {A = new GroupBy(X, Y);}

%type having_opt {Expr}
having_opt(A) ::= .                {A = null;}
having_opt(A) ::= HAVING expr(X).  {A = X;}

%type limit_opt {Limit}

// The destructor for limit_opt will never fire in the current grammar.
// The limit_opt non-terminal only occurs at the end of a single production
// rule for SELECT statements.  As soon as the rule that create the 
// limit_opt non-terminal reduces, the SELECT statement rule will also
// reduce.  So there is never a limit_opt non-terminal on the stack 
// except as a transient.  So there is never anything to destroy.
//
//%destructor limit_opt {
//  sqlite3ExprDelete(pParse->db, $$.pLimit);
//  sqlite3ExprDelete(pParse->db, $$.pOffset);
//}
limit_opt(A) ::= .                    {A = null;}
limit_opt(A) ::= LIMIT expr(X).       {A = new Limit(X, null);}
limit_opt(A) ::= LIMIT expr(X) OFFSET expr(Y). 
                                      {A = new Limit(X, Y);}
limit_opt(A) ::= LIMIT expr(X) COMMA expr(Y). 
                                      {A = new Limit(Y, X);}

/////////////////////////// The DELETE statement /////////////////////////////
//
%ifdef SQLITE_ENABLE_UPDATE_DELETE_LIMIT
cmd ::= with(C) DELETE FROM xfullname(X) indexed_opt(I) where_opt(W)
        orderby_opt(O) limit_opt(L). {
  context.stmt = new Delete(C, X, I, W, O, L);
}
%endif
%ifndef SQLITE_ENABLE_UPDATE_DELETE_LIMIT
cmd ::= with(C) DELETE FROM xfullname(X) indexed_opt(I) where_opt(W). {
  context.stmt = new Delete(C, X, I, W, null, null);
}
%endif

%type where_opt {Expr}

where_opt(A) ::= .                    {A = null;}
where_opt(A) ::= WHERE expr(X).       {A = X;}

////////////////////////// The UPDATE command ////////////////////////////////
//
%ifdef SQLITE_ENABLE_UPDATE_DELETE_LIMIT
cmd ::= with(C) UPDATE orconf(R) xfullname(X) indexed_opt(I) SET setlist(Y)
        where_opt(W) orderby_opt(O) limit_opt(L).  {
  context.stmt = new Update(C, R, X, I, Y, W, O, L);
}
%endif
%ifndef SQLITE_ENABLE_UPDATE_DELETE_LIMIT
cmd ::= with(C) UPDATE orconf(R) xfullname(X) indexed_opt(I) SET setlist(Y)
        where_opt(W).  {
  context.stmt = new Update(C, R, X, I, Y, W, null, null);
}
%endif

%type setlist {List<Set>}

setlist(A) ::= setlist(A) COMMA nm(X) EQ expr(Y). {
  Set s = new Set(X.text(), Y);
  A = append(A, s);
}
setlist(A) ::= setlist(A) COMMA LP idlist(X) RP EQ expr(Y). {
  Set s = new Set(X, Y);
  A = append(A, s);
}
setlist(A) ::= nm(X) EQ expr(Y). {
  Set s = new Set(X.text(), Y);
  A = append(null, s);
}
setlist(A) ::= LP idlist(X) RP EQ expr(Y). {
  Set s = new Set(X, Y);
  A = append(null, s);
}

////////////////////////// The INSERT command /////////////////////////////////
//
cmd ::= with(W) insert_cmd(R) INTO xfullname(X) idlist_opt(F) select(S)
        upsert(U). {
  context.stmt = new Insert(W, R, X, F, S, U);
}
cmd ::= with(W) insert_cmd(R) INTO xfullname(X) idlist_opt(F) DEFAULT VALUES.
{
  context.stmt = new Insert(W, R, X, F, null, null);
}

%type upsert {Upsert}
upsert(A) ::= . { A = null; }
upsert(A) ::= ON CONFLICT LP sortlist(T) RP where_opt(TW)
              DO UPDATE SET setlist(Z) where_opt(W).
              { A = new Upsert(T,TW,Z,W); }
upsert(A) ::= ON CONFLICT LP sortlist(T) RP where_opt(TW) DO NOTHING.
              { A = new Upsert(T,TW,null,null); }
upsert(A) ::= ON CONFLICT DO NOTHING.
              { A = new Upsert(null,null,null,null); }

%type insert_cmd {ResolveType}
insert_cmd(A) ::= INSERT orconf(R).   {A = R;}
insert_cmd(A) ::= REPLACE.            {A = ResolveType.Replace;}

%type idlist_opt {List<String>}
%type idlist {List<String>}

idlist_opt(A) ::= .                       {A = null;}
idlist_opt(A) ::= LP idlist(X) RP.    {A = X;}
idlist(A) ::= idlist(A) COMMA nm(Y).
    {A = append(A,Y.text());}
idlist(A) ::= nm(Y).
    {A = append(null,Y.text()); /*A-overwrites-Y*/}

/////////////////////////// Expression Processing /////////////////////////////
//

%type expr {Expr}
%type term {Expr}

expr(A) ::= term(A).
expr(A) ::= LP expr(X) RP.
            {A=new ParenthesizedExpr(X); /*A-overwrites-B*/}
expr(A) ::= id(X).          {A=new IdExpr(X.text()); /*A-overwrites-X*/}
expr(A) ::= JOIN_KW(X).     {A=new IdExpr(X.text()); /*A-overwrites-X*/}
expr(A) ::= nm(X) DOT nm(Y). {
  A = new QualifiedExpr(X.text(),Y.text()); /*A-overwrites-X*/
}
expr(A) ::= nm(X) DOT nm(Y) DOT nm(Z). {
  A = new DoublyQualifiedExpr(X.text(),Y.text(),Z.text()); /*A-overwrites-X*/
}
term(A) ::= NULL|FLOAT|BLOB(X). {A=LiteralExpr.from(X);/*A-overwrites-X*/}
term(A) ::= STRING(X).          {A=LiteralExpr.from(X);/*A-overwrites-X*/}
term(A) ::= INTEGER(X). {
  A=LiteralExpr.from(X);
}
expr(A) ::= VARIABLE(X).     {
  A = new VariableExpr(X.text());
}
expr(A) ::= expr(A) COLLATE ids(C). {
  A = new CollateExpr(A, C.text());
}
%ifndef SQLITE_OMIT_CAST
expr(A) ::= CAST LP expr(E) AS typetoken(T) RP. {
  A = new CastExpr(E,T);
}
%endif  SQLITE_OMIT_CAST
expr(A) ::= id(X) LP distinct(D) exprlist(Y) RP. {
  /*if( Y && Y->nExpr>pParse->db->aLimit[SQLITE_LIMIT_FUNCTION_ARG] ){
    context.sqlite3ErrorMsg("too many arguments on function %T", X);
  }*/
  A = new FunctionCallExpr(X.text(), D, Y);
}
expr(A) ::= id(X) LP STAR RP. {
  A = new FunctionCallStarExpr(X.text());
}
term(A) ::= CTIME_KW(OP). {
  A = new CurrentTimeExpr(OP.text());
}

expr(A) ::= LP nexprlist(X) COMMA expr(Y) RP. {
  append(X, Y);
  A = new ParenthesizedExpr(X);
}

expr(A) ::= expr(A) AND(OP) expr(Y).    {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) OR(OP) expr(Y).     {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) LT|GT|GE|LE(OP) expr(Y).
                                        {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) EQ|NE(OP) expr(Y).  {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) BITAND|BITOR|LSHIFT|RSHIFT(OP) expr(Y).
                                        {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) PLUS|MINUS(OP) expr(Y).
                                        {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) STAR|SLASH|REM(OP) expr(Y).
                                        {A = new BinaryExpr(A, Operator.from(@OP),Y);}
expr(A) ::= expr(A) CONCAT(OP) expr(Y). {A = new BinaryExpr(A, Operator.from(@OP),Y);}
%type likeop {NotLike}
likeop(A) ::= LIKE_KW|MATCH(X).     {A = new NotLike(false, LikeOperator.from(X));}
likeop(A) ::= NOT LIKE_KW|MATCH(X). {A = new NotLike(true, LikeOperator.from(X)); /*A-overwrite-X*/}
expr(A) ::= expr(A) likeop(OP) expr(Y).  [LIKE_KW]  {
  A = new LikeExpr(A, OP, Y, null);
}
expr(A) ::= expr(A) likeop(OP) expr(Y) ESCAPE expr(E).  [LIKE_KW]  {
  A = new LikeExpr(A, OP, Y, E);
}

expr(A) ::= expr(A) ISNULL|NOTNULL(E).   {A = IsNullExpr.from(A, @E);}
expr(A) ::= expr(A) NOT NULL. {A = new NotNullExpr(A);}

//    expr1 IS expr2
//    expr1 IS NOT expr2
//
// If expr2 is NULL then code as TK_ISNULL or TK_NOTNULL.  If expr2
// is any other expression, code as TK_IS or TK_ISNOT.
// 
expr(A) ::= expr(A) IS expr(Y).     {
  A = new BinaryExpr(A, Operator.Is, Y);
}
expr(A) ::= expr(A) IS NOT expr(Y). {
  A = new BinaryExpr(A, Operator.IsNot, Y);
}


expr(A) ::= NOT expr(X).
              {A = new UnaryExpr(UnaryOperator.Not,X);}
expr(A) ::= BITNOT expr(X).
              {A = new UnaryExpr(UnaryOperator.BitwiseNot,X);}
expr(A) ::= MINUS expr(X). [BITNOT]
              {A = new UnaryExpr(UnaryOperator.Negative,X);}
expr(A) ::= PLUS expr(X). [BITNOT]
              {A = new UnaryExpr(UnaryOperator.Positive,X);}

%type between_op {boolean}
between_op(A) ::= BETWEEN.     {A = false;}
between_op(A) ::= NOT BETWEEN. {A = true;}
expr(A) ::= expr(A) between_op(N) expr(X) AND expr(Y). [BETWEEN] {
  A = new BetweenExpr(A, N, X, Y);
}
%ifndef SQLITE_OMIT_SUBQUERY
  %type in_op {boolean}
  in_op(A) ::= IN.      {A = false;}
  in_op(A) ::= NOT IN.  {A = true;}
  expr(A) ::= expr(A) in_op(N) LP exprlist(Y) RP. [IN] {
    A = new InListExpr(A, N, Y);
  }
  expr(A) ::= LP select(X) RP. {
    A = new SubqueryExpr(X);
  }
  expr(A) ::= expr(A) in_op(N) LP select(Y) RP.  [IN] {
    A = new InSelectExpr(A, N, Y);
  }
  expr(A) ::= expr(A) in_op(N) nm(Y) dbnm(Z) paren_exprlist(E). [IN] {
    QualifiedName qn = QualifiedName.from(Y,Z);
    A = new InTableExpr(A, N, qn, E);
  }
  expr(A) ::= EXISTS LP select(Y) RP. {
    A = new ExistsExpr(Y); /*A-overwrites-B*/
  }
%endif SQLITE_OMIT_SUBQUERY

/* CASE expressions */
expr(A) ::= CASE case_operand(X) case_exprlist(Y) case_else(Z) END. {
  A = new CaseExpr(X, Y, Z);
}
%type case_exprlist {List<WhenThenPair>}
case_exprlist(A) ::= case_exprlist(A) WHEN expr(Y) THEN expr(Z). {
  WhenThenPair wtp = new WhenThenPair(Y, Z);
  A = append(A, wtp);
}
case_exprlist(A) ::= WHEN expr(Y) THEN expr(Z). {
  WhenThenPair wtp = new WhenThenPair(Y, Z);
  A = append(null, wtp);
}
%type case_else {Expr}
case_else(A) ::=  ELSE expr(X).         {A = X;}
case_else(A) ::=  .                     {A = null;}
%type case_operand {Expr}
case_operand(A) ::= expr(X).            {A = X; /*A-overwrites-X*/}
case_operand(A) ::= .                   {A = null;}

%type exprlist {List<Expr>}
%type nexprlist {List<Expr>}

exprlist(A) ::= nexprlist(A).
exprlist(A) ::= .                            {A = null;}
nexprlist(A) ::= nexprlist(A) COMMA expr(Y).
    {A = append(A,Y);}
nexprlist(A) ::= expr(Y).
    {A = append(null,Y); /*A-overwrites-Y*/}

%ifndef SQLITE_OMIT_SUBQUERY
/* A paren_exprlist is an optional expression list contained inside
** of parenthesis */
%type paren_exprlist {List<Expr>}
paren_exprlist(A) ::= .   {A = null;}
paren_exprlist(A) ::= LP exprlist(X) RP.  {A = X;}
%endif SQLITE_OMIT_SUBQUERY


///////////////////////////// The CREATE INDEX command ///////////////////////
//
cmd ::= createkw uniqueflag(U) INDEX ifnotexists(NE) nm(X) dbnm(D)
        ON nm(Y) LP sortlist(Z) RP where_opt(W). {
  QualifiedName idxName = QualifiedName.from(X, D);
  context.stmt = new CreateIndex(U, NE, idxName, Y.text(), Z, W);
}

%type uniqueflag {boolean}
uniqueflag(A) ::= UNIQUE.  {A = true;}
uniqueflag(A) ::= .        {A = false;}


// The eidlist non-terminal (Expression Id List) generates an ExprList
// from a list of identifiers.  The identifier names are in ExprList.a[].zName.
// This list is stored in an ExprList rather than an IdList so that it
// can be easily sent to sqlite3ColumnsExprList().
//
// eidlist is grouped with CREATE INDEX because it used to be the non-terminal
// used for the arguments to an index.  That is just an historical accident.
//
// IMPORTANT COMPATIBILITY NOTE:  Some prior versions of SQLite accepted
// COLLATE clauses and ASC or DESC keywords on ID lists in inappropriate
// places - places that might have been stored in the sqlite_master schema.
// Those extra features were ignored.  But because they might be in some
// (busted) old databases, we need to continue parsing them when loading
// historical schemas.
//
%type eidlist {List<IndexedColumn>}
%type eidlist_opt {List<IndexedColumn>}

eidlist_opt(A) ::= .                         {A = null;}
eidlist_opt(A) ::= LP eidlist(X) RP.         {A = X;}
eidlist(A) ::= eidlist(A) COMMA nm(Y) collate(C) sortorder(Z).  {
  IndexedColumn ic = new IndexedColumn(Y.text(), C, Z);
  A = append(A, ic);
}
eidlist(A) ::= nm(Y) collate(C) sortorder(Z). {
  IndexedColumn ic = new IndexedColumn(Y.text(), C, Z);
  A = append(null, ic); /*A-overwrites-Y*/
}

%type collate {String}
collate(C) ::= .              {C = null;}
collate(C) ::= COLLATE ids(X).   {C = X.text();}


///////////////////////////// The DROP INDEX command /////////////////////////
//
cmd ::= DROP INDEX ifexists(E) fullname(X).   {context.stmt = new DropIndex(E, X);}

///////////////////////////// The VACUUM command /////////////////////////////
//
%ifndef SQLITE_OMIT_VACUUM
%ifndef SQLITE_OMIT_ATTACH
cmd ::= VACUUM.                {context.stmt = new Vacuum(null);}
cmd ::= VACUUM nm(X).          {context.stmt = new Vacuum(X.text());}
%endif  SQLITE_OMIT_ATTACH
%endif  SQLITE_OMIT_VACUUM

///////////////////////////// The PRAGMA command /////////////////////////////
//
%ifndef SQLITE_OMIT_PRAGMA
cmd ::= PRAGMA nm(X) dbnm(Z).                {context.stmt = Pragma.from(X,Z,null);}
cmd ::= PRAGMA nm(X) dbnm(Z) EQ nmnum(Y).    {context.stmt = Pragma.from(X,Z,Y);}
cmd ::= PRAGMA nm(X) dbnm(Z) LP nmnum(Y) RP. {context.stmt = Pragma.from(X,Z,Y);}
cmd ::= PRAGMA nm(X) dbnm(Z) EQ minus_num(Y). 
                                             {context.stmt = Pragma.from(X,Z,Y);}
cmd ::= PRAGMA nm(X) dbnm(Z) LP minus_num(Y) RP.
                                             {context.stmt = Pragma.from(X,Z,Y);}

%type nmnum {Expr}
nmnum(A) ::= plus_num(A).
nmnum(A) ::= nm(X). {A = new IdExpr(X.text());}
nmnum(A) ::= ON(X). {A = LiteralExpr.from(X);}
nmnum(A) ::= DELETE(X). {A = LiteralExpr.from(X);}
nmnum(A) ::= DEFAULT(X). {A = LiteralExpr.from(X);}
%endif SQLITE_OMIT_PRAGMA
%token_class number INTEGER|FLOAT.
%type plus_num {Expr}
plus_num(A) ::= PLUS number(X).       {A = new UnaryExpr(UnaryOperator.Positive, LiteralExpr.from(X));}
plus_num(A) ::= number(X).            {A = LiteralExpr.from(X);}
%type minus_num {Expr}
minus_num(A) ::= MINUS number(X).     {A = new UnaryExpr(UnaryOperator.Negative, LiteralExpr.from(X));}
//////////////////////////// The CREATE TRIGGER command /////////////////////

%ifndef SQLITE_OMIT_TRIGGER

cmd ::= createkw trigger_decl(A) BEGIN trigger_cmd_list(S) END. {
  A.commands.addAll(S);
  context.stmt = A;
}

%type trigger_decl {CreateTrigger}
trigger_decl(A) ::= temp(T) TRIGGER ifnotexists(NOERR) nm(B) dbnm(Z) 
                    trigger_time(C) trigger_event(D)
                    ON fullname(E) foreach_clause(X) when_clause(G). {
  QualifiedName triggerName = QualifiedName.from(B, Z);
  A = new CreateTrigger(T, NOERR, triggerName, C, D, E, X, G); /*A-overwrites-T*/
}

%type trigger_time {TriggerTime}
trigger_time(A) ::= BEFORE.      { A = TriggerTime.Before; }
trigger_time(A) ::= AFTER.       { A = TriggerTime.After;  }
trigger_time(A) ::= INSTEAD OF.  { A = TriggerTime.InsteadOf;}
trigger_time(A) ::= .            { A = null; }

%type trigger_event {TriggerEvent}
trigger_event(A) ::= DELETE|INSERT(X).   {A = TriggerEvent.from(@X); /*A-overwrites-X*/}
trigger_event(A) ::= UPDATE(X).          {A = TriggerEvent.from(@X); /*A-overwrites-X*/}
trigger_event(A) ::= UPDATE OF idlist(X).{A = new TriggerEvent(TriggerEventType.UpdateOf, X);}

%type foreach_clause {boolean}
foreach_clause(X) ::= .          {X = false;}
foreach_clause(X) ::= FOR EACH ROW. {X = true;}

%type when_clause {Expr}
when_clause(A) ::= .             { A = null; }
when_clause(A) ::= WHEN expr(X). { A = X; }

%type trigger_cmd_list {List<TriggerCmd>}
trigger_cmd_list(A) ::= trigger_cmd_list(A) trigger_cmd(X) SEMI. {
  A = append(A, X);
}
trigger_cmd_list(A) ::= trigger_cmd(X) SEMI. {
  A = append(A, X);
}

// Disallow qualified table names on INSERT, UPDATE, and DELETE statements
// within a trigger.  The table to INSERT, UPDATE, or DELETE is always in 
// the same database as the table that the trigger fires on.
//
%type trnm {Token}
trnm(A) ::= nm(A).
trnm(A) ::= nm DOT nm(X). {
  A = X;
  context.sqlite3ErrorMsg(
        "qualified table names are not allowed on INSERT, UPDATE, and DELETE "+
        "statements within triggers");
}

// Disallow the INDEX BY and NOT INDEXED clauses on UPDATE and DELETE
// statements within triggers.  We make a specific error message for this
// since it is an exception to the default grammar rules.
//
tridxby ::= .
tridxby ::= INDEXED BY nm. {
  context.sqlite3ErrorMsg(
        "the INDEXED BY clause is not allowed on UPDATE or DELETE statements "+
        "within triggers");
}
tridxby ::= NOT INDEXED. {
  context.sqlite3ErrorMsg(
        "the NOT INDEXED clause is not allowed on UPDATE or DELETE statements "+
        "within triggers");
}



%type trigger_cmd {TriggerCmd}
// UPDATE 
trigger_cmd(A) ::=
   UPDATE orconf(R) trnm(X) tridxby SET setlist(Y) where_opt(Z).  
   {A = new UpdateTriggerCmd(R, X.text(), Y, Z);}

// INSERT
trigger_cmd(A) ::= insert_cmd(R) INTO trnm(X) idlist_opt(F) select(S) upsert(U).
   {A = new InsertTriggerCmd(R, X.text(), F, S, U);/*A-overwrites-R*/}

// DELETE
trigger_cmd(A) ::= DELETE FROM trnm(X) tridxby where_opt(Y).
   {A = new DeleteTriggerCmd(X.text(), Y);}

// SELECT
trigger_cmd(A) ::= select(X).
   {A = X; /*A-overwrites-X*/}

// The special RAISE expression that may occur in trigger programs
expr(A) ::= RAISE LP IGNORE RP.  {
  A = new RaiseExpr(ResolveType.Ignore, null);
}
expr(A) ::= RAISE LP raisetype(T) COMMA nm(Z) RP.  {
  A = new RaiseExpr(T,Z.text());
}
%endif  !SQLITE_OMIT_TRIGGER

%type raisetype {ResolveType}
raisetype(A) ::= ROLLBACK.  {A = ResolveType.Rollback;}
raisetype(A) ::= ABORT.     {A = ResolveType.Abort;}
raisetype(A) ::= FAIL.      {A = ResolveType.Fail;}


////////////////////////  DROP TRIGGER statement //////////////////////////////
%ifndef SQLITE_OMIT_TRIGGER
cmd ::= DROP TRIGGER ifexists(NOERR) fullname(X). {
  context.stmt = new DropTrigger(NOERR,X);
}
%endif  !SQLITE_OMIT_TRIGGER

//////////////////////// ATTACH DATABASE file AS name /////////////////////////
%ifndef SQLITE_OMIT_ATTACH
cmd ::= ATTACH database_kw_opt expr(F) AS expr(D) key_opt(K). {
  context.stmt = new Attach(F, D, K);
}
cmd ::= DETACH database_kw_opt expr(D). {
  context.stmt = new Detach(D);
}

%type key_opt {Expr}
key_opt(A) ::= .                     { A = null; }
key_opt(A) ::= KEY expr(X).          { A = X; }

database_kw_opt ::= DATABASE.
database_kw_opt ::= .
%endif SQLITE_OMIT_ATTACH

////////////////////////// REINDEX collation //////////////////////////////////
%ifndef SQLITE_OMIT_REINDEX
cmd ::= REINDEX.                {context.stmt = new ReIndex(null);}
cmd ::= REINDEX nm(X) dbnm(Y).  {context.stmt = new ReIndex(QualifiedName.from(X, Y));}
%endif  SQLITE_OMIT_REINDEX

/////////////////////////////////// ANALYZE ///////////////////////////////////
%ifndef SQLITE_OMIT_ANALYZE
cmd ::= ANALYZE.                {context.stmt = new Analyze(null);}
cmd ::= ANALYZE nm(X) dbnm(Y).  {context.stmt = new Analyze(QualifiedName.from(X, Y));}
%endif

//////////////////////// ALTER TABLE table ... ////////////////////////////////
%ifndef SQLITE_OMIT_ALTERTABLE
cmd ::= ALTER TABLE fullname(X) RENAME TO nm(Z). {
  context.stmt = new AlterTable(X,Z.text());
}
cmd ::= ALTER TABLE fullname(X)
        ADD kwcolumn_opt columnname(Y) carglist(C). {
  ColumnDefinition colDefinition = new ColumnDefinition(Y, C);
  context.stmt = new AlterTable(X, colDefinition);
}
kwcolumn_opt ::= .
kwcolumn_opt ::= COLUMNKW.
%endif  SQLITE_OMIT_ALTERTABLE

//////////////////////// CREATE VIRTUAL TABLE ... /////////////////////////////
%ifndef SQLITE_OMIT_VIRTUALTABLE
cmd ::= create_vtab(A).                       {context.stmt = A;}
cmd ::= create_vtab(A) LP vtabarglist(X) RP.  {A.args = X.text(); context.stmt = A;}
%type create_vtab {CreateVirtualTable}
create_vtab(A) ::= createkw VIRTUAL TABLE ifnotexists(E)
                nm(X) dbnm(Y) USING nm(Z). {
    QualifiedName tblName = QualifiedName.from(X, Y);
    A = new CreateVirtualTable(E, tblName, Z.text());
}
vtabarglist ::= vtabarg.
vtabarglist ::= vtabarglist COMMA vtabarg.
vtabarg ::= .                       {/*FIXME sqlite3VtabArgInit(pParse);*/}
vtabarg ::= vtabarg vtabargtoken.
vtabargtoken ::= ANY(X).            {/*FIXME sqlite3VtabArgExtend(pParse,X);*/}
vtabargtoken ::= lp anylist RP(X).  {/*FIXME sqlite3VtabArgExtend(pParse,X);*/}
lp ::= LP(X).                       {/*FIXME sqlite3VtabArgExtend(pParse,X);*/}
anylist ::= .
anylist ::= anylist LP anylist RP.
anylist ::= anylist ANY.
%endif  SQLITE_OMIT_VIRTUALTABLE


//////////////////////// COMMON TABLE EXPRESSIONS ////////////////////////////
%type with {With}
%type wqlist {List<CommonTableExpr>}

with(A) ::= . {A = null;}
%ifndef SQLITE_OMIT_CTE
with(A) ::= WITH wqlist(W).              { A = new With(false, W); }
with(A) ::= WITH RECURSIVE wqlist(W).    { A = new With(true, W); }

wqlist(A) ::= nm(X) eidlist_opt(Y) AS LP select(Z) RP. {
  A = append(null, new CommonTableExpr(X.text(), Y, Z)); /*A-overwrites-X*/
}
wqlist(A) ::= wqlist(A) COMMA nm(X) eidlist_opt(Y) AS LP select(Z) RP. {
  CommonTableExpr cte = new CommonTableExpr(X.text(), Y, Z);
  A = append(A, cte);
}
%endif  SQLITE_OMIT_CTE
