"
Instance Variables:
	x	<Integer>
"
Class {
	#name : 'MgkClassA',
	#superclass : 'Object',
	#instVars : [
		'x'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'accessing' }
MgkClassA >> methodAcceptingABlock: aBlock [

	^ aBlock value
]

{ #category : 'debugging' }
MgkClassA >> methodDelay [

	(Delay forMilliseconds: 1) wait.
]

{ #category : 'debugging' }
MgkClassA >> methodLastingOneSecond [

	(Delay forMilliseconds: 0.5) wait.
	^ 999
]

{ #category : 'debugging' }
MgkClassA >> methodOne [
	^ 101
	
]

{ #category : 'debugging' }
MgkClassA >> methodTwo [
	^ 42
]

{ #category : 'debugging' }
MgkClassA >> methodWithArgument: anInteger [

	self x: self x + anInteger.
	^ self x
]

{ #category : 'debugging' }
MgkClassA >> methodWithException [

	1/0
]

{ #category : 'accessing' }
MgkClassA >> methodWithNonLocalReturn [

	self methodAcceptingABlock: [ ^ self ]
]

{ #category : 'debugging' }
MgkClassA >> methodWithWarning [

	Warning new signal: 'I warned you'.
]

{ #category : 'accessing' }
MgkClassA >> x [

	^ x
]

{ #category : 'accessing' }
MgkClassA >> x: anInteger [

	x := anInteger
]
