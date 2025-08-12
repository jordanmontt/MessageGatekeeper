Extension { #name : 'BlockClosure' }

{ #category : '*MessageGatekeeper' }
BlockClosure >> methodProxiesIfCurtailed: aBlock [
	"Evaluate the receiver with an abnormal termination action.
	 Evaluate aBlock only if execution is unwound during execution
	 of the receiver.  If execution of the receiver finishes normally do
	 not evaluate aBlock.  N.B.  This method is *not* implemented as a
	 primitive.  Primitive 198 always fails.  The VM uses prim 198 in a
	 context's method as the mark for an ensure:/ifCurtailed: activation."
	| handler complete result |
	<primitive: 198>
	<methodProxyCannotWrap>
	"The handler should be in the first temporary to find it easily and support more complex unwind methods"
	handler := aBlock.
	result := self valueNoContextSwitch.
	complete := true.
	^result
]
