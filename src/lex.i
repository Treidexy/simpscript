TokenKind.Eof		= 0
TokenKind.Name		= 1
TokenKind.Number	= 2
TokenKind.Plus		= 3
TokenKind.Minus		= 4
TokenKind.Star		= 5
TokenKind.Slash		= 6
TokenKind.LParen	= 7
TokenKind.RParen	= 8
TokenKind.Bad		= 69

	.struct 0
Token.kind:
	.space 8
Token.data:
	.space 8
Token.data_ext:
	.space 8, 0
Token.size = .
