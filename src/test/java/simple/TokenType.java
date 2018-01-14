package simple;

/**
 * Generated by jlemon.
 * But file must be renamed from `parser.h`to `TokenType.java`.
 * And package must be specified manually
 */
public interface TokenType {
  short PLUS                           =   1;
  short MINUS                          =   2;
  short DIVIDE                         =   3;
  short TIMES                          =   4;
  short INTEGER                        =   5;
  static String toString(short tokenType) {
    switch(tokenType) {
    case 1  : return "PLUS";
    case 2  : return "MINUS";
    case 3  : return "DIVIDE";
    case 4  : return "TIMES";
    case 5  : return "INTEGER";
    }
    throw new AssertionError(String.format("Unexpected token type: %d", tokenType));
  }
}
