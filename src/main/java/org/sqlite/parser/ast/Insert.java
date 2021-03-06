package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Objects.requireNonNull;
import static org.sqlite.parser.ast.ToSql.commaNames;
import static org.sqlite.parser.ast.ToSql.isNotEmpty;

public class Insert implements Stmt {
	public final With with;
	public final ResolveType orConflict;
	public final QualifiedName tblName;
	public final List<String> columns;
	public final Select select;
	public final Upsert upsert;

	public Insert(With with,
			ResolveType orConflict,
			QualifiedName tblName,
			List<String> columns,
			Select select,
			Upsert upsert) {
		this.with = with;
		this.orConflict = orConflict;
		this.tblName = requireNonNull(tblName);
		this.columns = columns;
		this.select = select;
		this.upsert = upsert;
		// TODO "%d values for %d columns"
		// columns.size = select.body.size
	}
	@Override
	public void toSql(Appendable a) throws IOException {
		if (with != null) {
			with.toSql(a);
			a.append(' ');
		}
		if (ResolveType.Replace == orConflict) {
			a.append("REPLACE");
		} else {
			a.append("INSERT");
			if (orConflict != null) {
				a.append(" OR ");
				orConflict.toSql(a);
			}
		}
		a.append(" INTO ");
		tblName.toSql(a);
		if (isNotEmpty(columns)) {
			a.append(" (");
			commaNames(a, columns);
			a.append(") ");
		}
		a.append(' ');
		if (select != null) {
			select.toSql(a);
			if (upsert != null) {
				upsert.toSql(a);
			}
		} else {
			a.append("DEFAULT VALUES");
		}
	}
}
