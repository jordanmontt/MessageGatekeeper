Class {
	#name : 'MgkWaitAndTriggerBeforeHandler',
	#superclass : 'MgkHandler',
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'evaluating' }
MgkWaitAndTriggerBeforeHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	"Begin execution, stop instrumentation and let first thread enter its method."
	anObject concurrencySemaphore signal.
	anObject concurrencySemaphore wait.
	
	"Trigger count, shouldn't be registered as we are in the before."
	anObject trigger2.
	anObject concurrencySemaphore signal.
]
