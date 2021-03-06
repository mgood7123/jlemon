package org.sqlite.parser.ast;

import java.io.IOException;

import static java.util.Objects.requireNonNull;

/**
 * Represents an {@code IN} expression with the right-hand side being a {@code SELECT} statement.
 * <pre>{@code expr [NOT] IN (select-stmt)}</pre>
 */
public class InSelectExpr implements Expr {
	public final Expr lhs;
	public final boolean not;
	public final Select rhs;

	public InSelectExpr(Expr lhs, boolean not, Select rhs) {
		this.lhs = requireNonNull(lhs);
		this.not = not;
		this.rhs = requireNonNull(rhs);
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		lhs.toSql(a);
		if (not) {
			a.append(" NOT");
		}
		a.append(" IN (");
		rhs.toSql(a);
		a.append(")");
	}
}
