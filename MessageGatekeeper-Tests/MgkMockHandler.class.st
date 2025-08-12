Class {
	#name : 'MgkMockHandler',
	#superclass : 'MgkHandler',
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkMockHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue [

	^ 'trapped [', returnValue asString, ']'
]
