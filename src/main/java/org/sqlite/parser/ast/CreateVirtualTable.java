package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Objects.requireNonNull;

public class CreateVirtualTable implements Stmt {
	public final boolean ifNotExists;
	public final QualifiedName tblName;
	public final String moduleName;
	public final List<Expr> args;

	public CreateVirtualTable(boolean ifNotExists,
			QualifiedName tblName,
			String moduleName,
			List<Expr> args) {
		this.ifNotExists = ifNotExists;
		this.tblName = requireNonNull(tblName);
		this.moduleName = requireNonNull(moduleName);
		this.args = args;
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		a.append("CREATE VIRTUAL TABLE ");
		if (ifNotExists) {
			a.append("IF NOT EXISTS ");
		}
		tblName.toSql(a);
		a.append("USING ");
		doubleQuote(a, moduleName);
		if (args != null && !args.isEmpty()) {
			a.append('(');
			comma(a, args);
			a.append(')');
		}
	}
}