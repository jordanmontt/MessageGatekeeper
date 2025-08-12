"
I'm a mock for tests that checks that the infrastructure does not collapse when a handler is failing.
"
Class {
	#name : 'MgkFailingHandlerMock',
	#superclass : 'MgkHandler',
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkFailingHandlerMock >> beforeExecutionWithReceiver: aReceiver arguments: args [

	self error: 'error during instrumentation'
]
