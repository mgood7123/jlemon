package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Objects.requireNonNull;

public class DeleteTriggerCmd implements TriggerCmd {
	public final String tblName;
	public final Expr whereClause;

	public DeleteTriggerCmd(String tblName,
			Expr whereClause) {
		this.tblName = requireNonNull(tblName);
		this.whereClause = whereClause;
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		a.append("DELETE FROM ");
		doubleQuote(a, tblName);
		if (whereClause != null) {
			a.append(" WHERE ");
			whereClause.toSql(a);
		}
	}
}
