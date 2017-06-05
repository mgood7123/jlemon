package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static org.sqlite.parser.ast.ToSql.isNotEmpty;
import static org.sqlite.parser.ast.ToSql.requireNotEmpty;

public class ColumnsAndConstraints implements CreateTableBody {
	public final List<ColumnDefinition> columns;
	public final List<TableConstraint> constraints;
	public final boolean without;

	public ColumnsAndConstraints(List<ColumnDefinition> columns, List<TableConstraint> constraints, boolean without) {
		this.columns = requireNotEmpty(columns);
		this.constraints = constraints;
		this.without = without;
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		a.append('(');
		comma(a, columns);
		if (isNotEmpty(constraints)) {
			a.append(", ");
			comma(a, constraints);
		}
		a.append(')');
		if (without) {
			a.append(" WITHOUT ROWID");
		}
	}
}