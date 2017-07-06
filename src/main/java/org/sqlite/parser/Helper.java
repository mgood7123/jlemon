package org.sqlite.parser;

import java.util.ArrayList;
import java.util.List;

import org.sqlite.parser.ast.ColumnConstraint;
import org.sqlite.parser.ast.DeferSubclause;
import org.sqlite.parser.ast.ForeignKeyColumnConstraint;
import org.sqlite.parser.ast.TableConstraint;

class Helper {
	static <E> List<E> append(List<E> lst, E item) {
		if (lst == null) {
			lst = new ArrayList<>();
		}
		lst.add(item);
		return lst;
	}

	static List<ColumnConstraint> append(List<ColumnConstraint> lst, ColumnConstraint item) {
		if (lst == null) {
			lst = new ArrayList<>();
		}
		if (ColumnConstraint.DUMMY == item) {
			return lst;
		}
		if (item instanceof DeferSubclause) {
			if (lst.isEmpty()) {
				throw new ParseException("No ForeignKeyColumnConstraint found before DeferSubclause");
			}
			final ColumnConstraint previous = lst.get(lst.size() - 1);
			if (previous instanceof ForeignKeyColumnConstraint) {
				((ForeignKeyColumnConstraint) previous).setDerefClause(((DeferSubclause) item));
			} else {
				throw new ParseException("No ForeignKeyColumnConstraint before DeferSubclause");
			}
			return lst;
		}
		lst.add(item);
		return lst;
	}

	static List<TableConstraint> append(List<TableConstraint> lst, TableConstraint item) {
		if (lst == null) {
			lst = new ArrayList<>();
		}
		if (TableConstraint.DUMMY == item) {
			return lst;
		}
		lst.add(item);
		return lst;
	}
}
