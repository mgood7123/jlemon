package org.sqlite.parser.ast;

import java.io.IOException;

import static java.util.Objects.requireNonNull;

public class IdExpr implements Expr {
	public final String name;

	public IdExpr(String name) {
		this.name = requireNonNull(name);
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		doubleQuote(a, name);
	}
}
