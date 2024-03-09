TokenKind.Bad		= 0
TokenKind.Name		= 1
TokenKind.Number	= 2
TokenKind.Plus		= 3
TokenKind.Minus		= 4
TokenKind.Star		= 5
TokenKind.Slash		= 6

	.struct 0
Token.kind:
	.space 1
Token.len:
	.space 8
Token.size = .
