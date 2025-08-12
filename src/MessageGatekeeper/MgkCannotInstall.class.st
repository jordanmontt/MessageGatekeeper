Class {
	#name : 'MgkCannotInstall',
	#superclass : 'Error',
	#instVars : [
		'methodProxy'
	],
	#category : 'MessageGatekeeper',
	#package : 'MessageGatekeeper'
}

{ #category : 'signalling' }
MgkCannotInstall class >> signalWith: aMethodProxy [

	self new
		methodProxy: aMethodProxy;
		signal
]

{ #category : 'accessing' }
MgkCannotInstall >> methodProxy [

	^ methodProxy
]

{ #category : 'accessing' }
MgkCannotInstall >> methodProxy: anObject [

	methodProxy := anObject
]
