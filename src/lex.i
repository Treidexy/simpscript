TokenKind.Eof		= 0
TokenKind.Name		= 1
TokenKind.Number	= 2
TokenKind.Plus		= 3
TokenKind.Minus		= 4
TokenKind.Star		= 5
TokenKind.Slash		= 6

	.struct 0
.align 16
Token.data:
	.space 15
Token.kind:
	.space 1
Token.size = .
