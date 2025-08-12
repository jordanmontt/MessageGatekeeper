"
I am a method proxy handler for testing that increments a counter after the method has been executed.
I therefore test method exit
"
Class {
	#name : 'MgkAfterCounterHandler',
	#superclass : 'MgkHandler',
	#instVars : [
		'count'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkAfterCounterHandler >> afterExecutionWithReceiver: aReceiver arguments: args returnValue: returnValue [

	count := count + 1.
	^ returnValue
]

{ #category : 'accessing' }
MgkAfterCounterHandler >> count [
	^ count
]

{ #category : 'evaluating' }
MgkAfterCounterHandler >> initialize [

	super initialize.
	count := 0
]
