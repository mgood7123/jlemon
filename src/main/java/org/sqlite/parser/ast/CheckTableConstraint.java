package org.sqlite.parser.ast;

import java.io.IOException;

import static java.util.Objects.requireNonNull;

public class CheckTableConstraint extends TableConstraint {
	public final Expr expr;

	public CheckTableConstraint(String name, Expr expr) {
		super(name);
		this.expr = requireNonNull(expr);
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		constraintName(a);
		a.append("CHECK (");
		expr.toSql(a);
		a.append(')');
	}
}
