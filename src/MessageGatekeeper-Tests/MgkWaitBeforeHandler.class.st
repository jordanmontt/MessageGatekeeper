Class {
	#name : 'MgkWaitBeforeHandler',
	#superclass : 'MgkHandler',
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkWaitBeforeHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	"We are inside the before, not being instrumented, wait for second thread to enter inside before."
	anObject concurrencySemaphore wait
]
