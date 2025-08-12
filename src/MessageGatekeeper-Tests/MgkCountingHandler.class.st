"
I'm counting the number of times I'm executed. 
"
Class {
	#name : 'MgkCountingHandler',
	#superclass : 'MgkHandler',
	#instVars : [
		'count'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkCountingHandler >> beforeExecutionWithReceiver: aReceiver arguments: args [ 

	self count: self count + 1
]

{ #category : 'accessing' }
MgkCountingHandler >> count [

	^ count
]

{ #category : 'accessing' }
MgkCountingHandler >> count: anInteger [

	count := anInteger
]

{ #category : 'initialization' }
MgkCountingHandler >> initialize [

	super initialize.
	self count: 0.

]
