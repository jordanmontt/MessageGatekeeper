Class {
	#name : 'MgkTestConcurrentSharedObject',
	#superclass : 'Object',
	#instVars : [
		'concurrencySemaphore'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'accessing' }
MgkTestConcurrentSharedObject >> concurrencySemaphore [

	^ concurrencySemaphore
]

{ #category : 'accessing' }
MgkTestConcurrentSharedObject >> concurrencySemaphore: anObject [

	concurrencySemaphore := anObject
]

{ #category : 'initialization' }
MgkTestConcurrentSharedObject >> initialize [ 
	self concurrencySemaphore: (Semaphore new).
]

{ #category : 'debugging' }
MgkTestConcurrentSharedObject >> methodProcess1 [
	"We are in instrumented territory this trigger should be registered."
	self trigger1.
	"Let the second thread end its before execution and wait for its signal."
	concurrencySemaphore signal.
	concurrencySemaphore wait.
]

{ #category : 'debugging' }
MgkTestConcurrentSharedObject >> methodProcess2 [
	"Do nothing"
]

{ #category : 'debugging' }
MgkTestConcurrentSharedObject >> trigger1 [
	"Proxified method being counted"
]

{ #category : 'debugging' }
MgkTestConcurrentSharedObject >> trigger2 [
	"Proxified method being counted"
]
