package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Arrays.asList;
import static java.util.Collections.singletonList;
import static java.util.Objects.requireNonNull;
import static org.sqlite.parser.ast.ToSql.comma;
import static org.sqlite.parser.ast.ToSql.doubleQuote;
import static org.sqlite.parser.ast.ToSql.isNotEmpty;

/**
 * Represents a call to a built-in function.
 * <pre>{@code function-name([DISTINCT] [expr][, expr]*)}</pre>
 */
public class FunctionCallExpr implements Expr {
	public final String name;
	public final Distinctness distinctness;
	public final List<Expr> args;

	public static FunctionCallExpr lower(Expr expr) {
		return new FunctionCallExpr("lower", null, singletonList(expr));
	}

	public static FunctionCallExpr from(String name, Expr... args) {
		return new FunctionCallExpr(name, null, asList(args));
	}

	public FunctionCallExpr(String name,
			Distinctness distinctness,
			List<Expr> args) {
		this.name = requireNonNull(name);
		this.distinctness = distinctness;
		this.args = args;
		// TODO "too many arguments on function %T"
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		doubleQuote(a, name);
		a.append('(');
		if (distinctness != null) {
			distinctness.toSql(a);
			a.append(' ');
		}
		if (isNotEmpty(args)) {
			comma(a, args);
		}
		a.append(')');
	}
}
