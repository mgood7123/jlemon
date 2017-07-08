package org.sqlite.parser;

import java.util.Map;
import java.util.TreeMap;

import static org.sqlite.parser.TokenType.*;

public abstract class Keyword {
	private final static Map<String, Integer> KEYWORDS = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);
	static {
		KEYWORDS.put("ABORT", TK_ABORT);
		KEYWORDS.put("ACTION", TK_ACTION);
		KEYWORDS.put("ADD", TK_ADD);
		KEYWORDS.put("AFTER", TK_AFTER);
		KEYWORDS.put("ALL", TK_ALL);
		KEYWORDS.put("ALTER", TK_ALTER);
		KEYWORDS.put("ANALYZE", TK_ANALYZE);
		KEYWORDS.put("AND", TK_AND);
		KEYWORDS.put("AS", TK_AS);
		KEYWORDS.put("ASC", TK_ASC);
		KEYWORDS.put("ATTACH", TK_ATTACH);
		KEYWORDS.put("AUTOINCREMENT", TK_AUTOINCR);
		KEYWORDS.put("BEFORE", TK_BEFORE);
		KEYWORDS.put("BEGIN", TK_BEGIN);
		KEYWORDS.put("BETWEEN", TK_BETWEEN);
		KEYWORDS.put("BY", TK_BY);
		KEYWORDS.put("CASCADE", TK_CASCADE);
		KEYWORDS.put("CASE", TK_CASE);
		KEYWORDS.put("CAST", TK_CAST);
		KEYWORDS.put("CHECK", TK_CHECK);
		KEYWORDS.put("COLLATE", TK_COLLATE);
		KEYWORDS.put("COLUMN", TK_COLUMNKW);
		KEYWORDS.put("COMMIT", TK_COMMIT);
		KEYWORDS.put("CONFLICT", TK_CONFLICT);
		KEYWORDS.put("CONSTRAINT", TK_CONSTRAINT);
		KEYWORDS.put("CREATE", TK_CREATE);
		KEYWORDS.put("CROSS", TK_JOIN_KW);
		KEYWORDS.put("CURRENT_DATE", TK_CTIME_KW);
		KEYWORDS.put("CURRENT_TIME", TK_CTIME_KW);
		KEYWORDS.put("CURRENT_TIMESTAMP", TK_CTIME_KW);
		KEYWORDS.put("DATABASE", TK_DATABASE);
		KEYWORDS.put("DEFAULT", TK_DEFAULT);
		KEYWORDS.put("DEFERRABLE", TK_DEFERRABLE);
		KEYWORDS.put("DEFERRED", TK_DEFERRED);
		KEYWORDS.put("DELETE", TK_DELETE);
		KEYWORDS.put("DESC", TK_DESC);
		KEYWORDS.put("DETACH", TK_DETACH);
		KEYWORDS.put("DISTINCT", TK_DISTINCT);
		KEYWORDS.put("DROP", TK_DROP);
		KEYWORDS.put("EACH", TK_EACH);
		KEYWORDS.put("ELSE", TK_ELSE);
		KEYWORDS.put("END", TK_END);
		KEYWORDS.put("ESCAPE", TK_ESCAPE);
		KEYWORDS.put("EXCEPT", TK_EXCEPT);
		KEYWORDS.put("EXCLUSIVE", TK_EXCLUSIVE);
		KEYWORDS.put("EXISTS", TK_EXISTS);
		KEYWORDS.put("EXPLAIN", TK_EXPLAIN);
		KEYWORDS.put("FAIL", TK_FAIL);
		KEYWORDS.put("FOR", TK_FOR);
		KEYWORDS.put("FOREIGN", TK_FOREIGN);
		KEYWORDS.put("FROM", TK_FROM);
		KEYWORDS.put("FULL", TK_JOIN_KW);
		KEYWORDS.put("GLOB", TK_LIKE_KW);
		KEYWORDS.put("GROUP", TK_GROUP);
		KEYWORDS.put("HAVING", TK_HAVING);
		KEYWORDS.put("IF", TK_IF);
		KEYWORDS.put("IGNORE", TK_IGNORE);
		KEYWORDS.put("IMMEDIATE", TK_IMMEDIATE);
		KEYWORDS.put("IN", TK_IN);
		KEYWORDS.put("INDEX", TK_INDEX);
		KEYWORDS.put("INDEXED", TK_INDEXED);
		KEYWORDS.put("INITIALLY", TK_INITIALLY);
		KEYWORDS.put("INNER", TK_JOIN_KW);
		KEYWORDS.put("INSERT", TK_INSERT);
		KEYWORDS.put("INSTEAD", TK_INSTEAD);
		KEYWORDS.put("INTERSECT", TK_INTERSECT);
		KEYWORDS.put("INTO", TK_INTO);
		KEYWORDS.put("IS", TK_IS);
		KEYWORDS.put("ISNULL", TK_ISNULL);
		KEYWORDS.put("JOIN", TK_JOIN);
		KEYWORDS.put("KEY", TK_KEY);
		KEYWORDS.put("LEFT", TK_JOIN_KW);
		KEYWORDS.put("LIKE", TK_LIKE_KW);
		KEYWORDS.put("LIMIT", TK_LIMIT);
		KEYWORDS.put("MATCH", TK_MATCH);
		KEYWORDS.put("NATURAL", TK_JOIN_KW);
		KEYWORDS.put("NO", TK_NO);
		KEYWORDS.put("NOT", TK_NOT);
		KEYWORDS.put("NOTNULL", TK_NOTNULL);
		KEYWORDS.put("NULL", TK_NULL);
		KEYWORDS.put("OF", TK_OF);
		KEYWORDS.put("OFFSET", TK_OFFSET);
		KEYWORDS.put("ON", TK_ON);
		KEYWORDS.put("OR", TK_OR);
		KEYWORDS.put("ORDER", TK_ORDER);
		KEYWORDS.put("OUTER", TK_JOIN_KW);
		KEYWORDS.put("PLAN", TK_PLAN);
		KEYWORDS.put("PRAGMA", TK_PRAGMA);
		KEYWORDS.put("PRIMARY", TK_PRIMARY);
		KEYWORDS.put("QUERY", TK_QUERY);
		KEYWORDS.put("RAISE", TK_RAISE);
		KEYWORDS.put("RECURSIVE", TK_RECURSIVE);
		KEYWORDS.put("REFERENCES", TK_REFERENCES);
		KEYWORDS.put("REGEXP", TK_LIKE_KW);
		KEYWORDS.put("REINDEX", TK_REINDEX);
		KEYWORDS.put("RELEASE", TK_RELEASE);
		KEYWORDS.put("RENAME", TK_RENAME);
		KEYWORDS.put("REPLACE", TK_REPLACE);
		KEYWORDS.put("RESTRICT", TK_RESTRICT);
		KEYWORDS.put("RIGHT", TK_JOIN_KW);
		KEYWORDS.put("ROLLBACK", TK_ROLLBACK);
		KEYWORDS.put("ROW", TK_ROW);
		KEYWORDS.put("SAVEPOINT", TK_SAVEPOINT);
		KEYWORDS.put("SELECT", TK_SELECT);
		KEYWORDS.put("SET", TK_SET);
		KEYWORDS.put("TABLE", TK_TABLE);
		KEYWORDS.put("TEMP", TK_TEMP);
		KEYWORDS.put("TEMPORARY", TK_TEMP);
		KEYWORDS.put("THEN", TK_THEN);
		KEYWORDS.put("TO", TK_TO);
		KEYWORDS.put("TRANSACTION", TK_TRANSACTION);
		KEYWORDS.put("TRIGGER", TK_TRIGGER);
		KEYWORDS.put("UNION", TK_UNION);
		KEYWORDS.put("UNIQUE", TK_UNIQUE);
		KEYWORDS.put("UPDATE", TK_UPDATE);
		KEYWORDS.put("USING", TK_USING);
		KEYWORDS.put("VACUUM", TK_VACUUM);
		KEYWORDS.put("VALUES", TK_VALUES);
		KEYWORDS.put("VIEW", TK_VIEW);
		KEYWORDS.put("VIRTUAL", TK_VIRTUAL);
		KEYWORDS.put("WHEN", TK_WHEN);
		KEYWORDS.put("WHERE", TK_WHERE);
		KEYWORDS.put("WITH", TK_WITH);
		KEYWORDS.put("WITHOUT", TK_WITHOUT);
	}

	public static Integer tokenType(String id) {
		return KEYWORDS.get(id);
	}
	public static boolean isKeyword(String id) {
		return KEYWORDS.containsKey(id);
	}
}