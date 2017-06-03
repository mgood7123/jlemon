package org.sqlite.parser.ast;

import java.io.IOException;
import java.util.List;

import static java.util.Objects.requireNonNull;

public class SelectBody implements ToSql {
	public final OneSelect select;
	public final List<CompoundSelect> compounds;

	public SelectBody(OneSelect select, List<CompoundSelect> compounds) {
		this.select = requireNonNull(select);
		this.compounds = compounds;
	}

	@Override
	public void toSql(Appendable a) throws IOException {
		select.toSql(a);
		if (compounds != null && !compounds.isEmpty()) {
			for (int i = 0; i < compounds.size(); i++) {
				a.append(' ');
				compounds.get(i).toSql(a);
			}
		}
	}
}
