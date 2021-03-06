package org.sqlite.parser;

/**
 * Generated by jlemon.
 * But file must be renamed from `parser.h`to `TokenType.java`.
 * And package must be specified manually
 */
public interface TokenType {
  short TK_SEMI                           =   1;
  short TK_EXPLAIN                        =   2;
  short TK_QUERY                          =   3;
  short TK_PLAN                           =   4;
  short TK_BEGIN                          =   5;
  short TK_TRANSACTION                    =   6;
  short TK_DEFERRED                       =   7;
  short TK_IMMEDIATE                      =   8;
  short TK_EXCLUSIVE                      =   9;
  short TK_COMMIT                         =  10;
  short TK_END                            =  11;
  short TK_ROLLBACK                       =  12;
  short TK_SAVEPOINT                      =  13;
  short TK_RELEASE                        =  14;
  short TK_TO                             =  15;
  short TK_TABLE                          =  16;
  short TK_CREATE                         =  17;
  short TK_IF                             =  18;
  short TK_NOT                            =  19;
  short TK_EXISTS                         =  20;
  short TK_TEMP                           =  21;
  short TK_LP                             =  22;
  short TK_RP                             =  23;
  short TK_AS                             =  24;
  short TK_WITHOUT                        =  25;
  short TK_COMMA                          =  26;
  short TK_ABORT                          =  27;
  short TK_ACTION                         =  28;
  short TK_AFTER                          =  29;
  short TK_ANALYZE                        =  30;
  short TK_ASC                            =  31;
  short TK_ATTACH                         =  32;
  short TK_BEFORE                         =  33;
  short TK_BY                             =  34;
  short TK_CASCADE                        =  35;
  short TK_CAST                           =  36;
  short TK_CONFLICT                       =  37;
  short TK_DATABASE                       =  38;
  short TK_DESC                           =  39;
  short TK_DETACH                         =  40;
  short TK_EACH                           =  41;
  short TK_FAIL                           =  42;
  short TK_OR                             =  43;
  short TK_AND                            =  44;
  short TK_IS                             =  45;
  short TK_MATCH                          =  46;
  short TK_LIKE_KW                        =  47;
  short TK_BETWEEN                        =  48;
  short TK_IN                             =  49;
  short TK_ISNULL                         =  50;
  short TK_NOTNULL                        =  51;
  short TK_NE                             =  52;
  short TK_EQ                             =  53;
  short TK_GT                             =  54;
  short TK_LE                             =  55;
  short TK_LT                             =  56;
  short TK_GE                             =  57;
  short TK_ESCAPE                         =  58;
  short TK_ID                             =  59;
  short TK_COLUMNKW                       =  60;
  short TK_DO                             =  61;
  short TK_FOR                            =  62;
  short TK_IGNORE                         =  63;
  short TK_INITIALLY                      =  64;
  short TK_INSTEAD                        =  65;
  short TK_NO                             =  66;
  short TK_KEY                            =  67;
  short TK_OF                             =  68;
  short TK_OFFSET                         =  69;
  short TK_PRAGMA                         =  70;
  short TK_RAISE                          =  71;
  short TK_RECURSIVE                      =  72;
  short TK_REPLACE                        =  73;
  short TK_RESTRICT                       =  74;
  short TK_ROW                            =  75;
  short TK_TRIGGER                        =  76;
  short TK_VACUUM                         =  77;
  short TK_VIEW                           =  78;
  short TK_VIRTUAL                        =  79;
  short TK_WITH                           =  80;
  short TK_REINDEX                        =  81;
  short TK_RENAME                         =  82;
  short TK_CTIME_KW                       =  83;
  short TK_ANY                            =  84;
  short TK_BITAND                         =  85;
  short TK_BITOR                          =  86;
  short TK_LSHIFT                         =  87;
  short TK_RSHIFT                         =  88;
  short TK_PLUS                           =  89;
  short TK_MINUS                          =  90;
  short TK_STAR                           =  91;
  short TK_SLASH                          =  92;
  short TK_REM                            =  93;
  short TK_CONCAT                         =  94;
  short TK_COLLATE                        =  95;
  short TK_BITNOT                         =  96;
  short TK_ON                             =  97;
  short TK_INDEXED                        =  98;
  short TK_STRING                         =  99;
  short TK_JOIN_KW                        = 100;
  short TK_CONSTRAINT                     = 101;
  short TK_DEFAULT                        = 102;
  short TK_NULL                           = 103;
  short TK_PRIMARY                        = 104;
  short TK_UNIQUE                         = 105;
  short TK_CHECK                          = 106;
  short TK_REFERENCES                     = 107;
  short TK_AUTOINCR                       = 108;
  short TK_INSERT                         = 109;
  short TK_DELETE                         = 110;
  short TK_UPDATE                         = 111;
  short TK_SET                            = 112;
  short TK_DEFERRABLE                     = 113;
  short TK_FOREIGN                        = 114;
  short TK_DROP                           = 115;
  short TK_UNION                          = 116;
  short TK_ALL                            = 117;
  short TK_EXCEPT                         = 118;
  short TK_INTERSECT                      = 119;
  short TK_SELECT                         = 120;
  short TK_VALUES                         = 121;
  short TK_DISTINCT                       = 122;
  short TK_DOT                            = 123;
  short TK_FROM                           = 124;
  short TK_JOIN                           = 125;
  short TK_USING                          = 126;
  short TK_ORDER                          = 127;
  short TK_GROUP                          = 128;
  short TK_HAVING                         = 129;
  short TK_LIMIT                          = 130;
  short TK_WHERE                          = 131;
  short TK_INTO                           = 132;
  short TK_NOTHING                        = 133;
  short TK_FLOAT                          = 134;
  short TK_BLOB                           = 135;
  short TK_INTEGER                        = 136;
  short TK_VARIABLE                       = 137;
  short TK_CASE                           = 138;
  short TK_WHEN                           = 139;
  short TK_THEN                           = 140;
  short TK_ELSE                           = 141;
  short TK_INDEX                          = 142;
  short TK_ALTER                          = 143;
  short TK_ADD                            = 144;
  static String toString(short tokenType) {
    switch(tokenType) {
    case 1  : return "TK_SEMI";
    case 2  : return "TK_EXPLAIN";
    case 3  : return "TK_QUERY";
    case 4  : return "TK_PLAN";
    case 5  : return "TK_BEGIN";
    case 6  : return "TK_TRANSACTION";
    case 7  : return "TK_DEFERRED";
    case 8  : return "TK_IMMEDIATE";
    case 9  : return "TK_EXCLUSIVE";
    case 10 : return "TK_COMMIT";
    case 11 : return "TK_END";
    case 12 : return "TK_ROLLBACK";
    case 13 : return "TK_SAVEPOINT";
    case 14 : return "TK_RELEASE";
    case 15 : return "TK_TO";
    case 16 : return "TK_TABLE";
    case 17 : return "TK_CREATE";
    case 18 : return "TK_IF";
    case 19 : return "TK_NOT";
    case 20 : return "TK_EXISTS";
    case 21 : return "TK_TEMP";
    case 22 : return "TK_LP";
    case 23 : return "TK_RP";
    case 24 : return "TK_AS";
    case 25 : return "TK_WITHOUT";
    case 26 : return "TK_COMMA";
    case 27 : return "TK_ABORT";
    case 28 : return "TK_ACTION";
    case 29 : return "TK_AFTER";
    case 30 : return "TK_ANALYZE";
    case 31 : return "TK_ASC";
    case 32 : return "TK_ATTACH";
    case 33 : return "TK_BEFORE";
    case 34 : return "TK_BY";
    case 35 : return "TK_CASCADE";
    case 36 : return "TK_CAST";
    case 37 : return "TK_CONFLICT";
    case 38 : return "TK_DATABASE";
    case 39 : return "TK_DESC";
    case 40 : return "TK_DETACH";
    case 41 : return "TK_EACH";
    case 42 : return "TK_FAIL";
    case 43 : return "TK_OR";
    case 44 : return "TK_AND";
    case 45 : return "TK_IS";
    case 46 : return "TK_MATCH";
    case 47 : return "TK_LIKE_KW";
    case 48 : return "TK_BETWEEN";
    case 49 : return "TK_IN";
    case 50 : return "TK_ISNULL";
    case 51 : return "TK_NOTNULL";
    case 52 : return "TK_NE";
    case 53 : return "TK_EQ";
    case 54 : return "TK_GT";
    case 55 : return "TK_LE";
    case 56 : return "TK_LT";
    case 57 : return "TK_GE";
    case 58 : return "TK_ESCAPE";
    case 59 : return "TK_ID";
    case 60 : return "TK_COLUMNKW";
    case 61 : return "TK_DO";
    case 62 : return "TK_FOR";
    case 63 : return "TK_IGNORE";
    case 64 : return "TK_INITIALLY";
    case 65 : return "TK_INSTEAD";
    case 66 : return "TK_NO";
    case 67 : return "TK_KEY";
    case 68 : return "TK_OF";
    case 69 : return "TK_OFFSET";
    case 70 : return "TK_PRAGMA";
    case 71 : return "TK_RAISE";
    case 72 : return "TK_RECURSIVE";
    case 73 : return "TK_REPLACE";
    case 74 : return "TK_RESTRICT";
    case 75 : return "TK_ROW";
    case 76 : return "TK_TRIGGER";
    case 77 : return "TK_VACUUM";
    case 78 : return "TK_VIEW";
    case 79 : return "TK_VIRTUAL";
    case 80 : return "TK_WITH";
    case 81 : return "TK_REINDEX";
    case 82 : return "TK_RENAME";
    case 83 : return "TK_CTIME_KW";
    case 84 : return "TK_ANY";
    case 85 : return "TK_BITAND";
    case 86 : return "TK_BITOR";
    case 87 : return "TK_LSHIFT";
    case 88 : return "TK_RSHIFT";
    case 89 : return "TK_PLUS";
    case 90 : return "TK_MINUS";
    case 91 : return "TK_STAR";
    case 92 : return "TK_SLASH";
    case 93 : return "TK_REM";
    case 94 : return "TK_CONCAT";
    case 95 : return "TK_COLLATE";
    case 96 : return "TK_BITNOT";
    case 97 : return "TK_ON";
    case 98 : return "TK_INDEXED";
    case 99 : return "TK_STRING";
    case 100: return "TK_JOIN_KW";
    case 101: return "TK_CONSTRAINT";
    case 102: return "TK_DEFAULT";
    case 103: return "TK_NULL";
    case 104: return "TK_PRIMARY";
    case 105: return "TK_UNIQUE";
    case 106: return "TK_CHECK";
    case 107: return "TK_REFERENCES";
    case 108: return "TK_AUTOINCR";
    case 109: return "TK_INSERT";
    case 110: return "TK_DELETE";
    case 111: return "TK_UPDATE";
    case 112: return "TK_SET";
    case 113: return "TK_DEFERRABLE";
    case 114: return "TK_FOREIGN";
    case 115: return "TK_DROP";
    case 116: return "TK_UNION";
    case 117: return "TK_ALL";
    case 118: return "TK_EXCEPT";
    case 119: return "TK_INTERSECT";
    case 120: return "TK_SELECT";
    case 121: return "TK_VALUES";
    case 122: return "TK_DISTINCT";
    case 123: return "TK_DOT";
    case 124: return "TK_FROM";
    case 125: return "TK_JOIN";
    case 126: return "TK_USING";
    case 127: return "TK_ORDER";
    case 128: return "TK_GROUP";
    case 129: return "TK_HAVING";
    case 130: return "TK_LIMIT";
    case 131: return "TK_WHERE";
    case 132: return "TK_INTO";
    case 133: return "TK_NOTHING";
    case 134: return "TK_FLOAT";
    case 135: return "TK_BLOB";
    case 136: return "TK_INTEGER";
    case 137: return "TK_VARIABLE";
    case 138: return "TK_CASE";
    case 139: return "TK_WHEN";
    case 140: return "TK_THEN";
    case 141: return "TK_ELSE";
    case 142: return "TK_INDEX";
    case 143: return "TK_ALTER";
    case 144: return "TK_ADD";
    }
    throw new AssertionError(String.format("Unexpected token type: %d", tokenType));
  }
}
