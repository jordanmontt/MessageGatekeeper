Class {
	#name : 'MgkCalledHandler',
	#superclass : 'MgkHandler',
	#instVars : [
		'called'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkCalledHandler >> beforeExecutionWithReceiver: aReceiver arguments: args [

	called := true
]

{ #category : 'evaluating' }
MgkCalledHandler >> called [

	^ called
]

{ #category : 'evaluating' }
MgkCalledHandler >> called: aBoolean [

	called := aBoolean
]

{ #category : 'initialization' }
MgkCalledHandler >> initialize [

	super initialize.
	called := false
]
