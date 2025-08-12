"
I'm the root of hierarchy of objects that can perform computation in place of method such as counting execution...
The main API is composed of two methods: 
- `afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue`
- `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`
"
Class {
	#name : 'MgkHandler',
	#superclass : 'Object',
	#category : 'MessageGatekeeper',
	#package : 'MessageGatekeeper'
}

{ #category : 'evaluating' }
MgkHandler >> aboutToReturnWithReceiver: receiver arguments: arguments [

	self afterExecutionWithReceiver: receiver arguments: arguments returnValue: nil
]

{ #category : 'evaluating' }
MgkHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	^ aReturnValue
]

{ #category : 'evaluating' }
MgkHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	
]

{ #category : 'evaluating' }
MgkHandler >> captureCallingContext [

	| runWithInContext |
	
	"Find the context of #run:with:in:"	
	runWithInContext := thisContext sender.
	[ runWithInContext isNil 
		or: [ runWithInContext method isCompiledMethod and: [runWithInContext method selector = #run:with:in:] ] ] 
		whileFalse: [ runWithInContext := runWithInContext sender ].
	
	"Find the real sender"	
	^ runWithInContext ifNotNil: [ runWithInContext sender ]
]
