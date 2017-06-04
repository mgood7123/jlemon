package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Objects.requireNonNull;

public class Select implements Stmt {
	public final With with;
	public final SelectBody body;
	public final List<SortedColumn> orderBy;
	public final Limit limit;

	public Select(With with,
			SelectBody body,
			List<SortedColumn> orderBy,
			Limit limit) {
		this.with = with;
		this.body = requireNonNull(body);
		this.orderBy = orderBy;
		this.limit = limit;
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		if (with != null) {
			with.toSql(a);
			a.append(' ');
		}
		body.toSql(a);
		if (orderBy != null && !orderBy.isEmpty()) {
			a.append(" ORDER BY ");
			comma(a, orderBy);
		}
		if (limit != null) {
			a.append(' ');
			limit.toSql(a);
		}
	}
}