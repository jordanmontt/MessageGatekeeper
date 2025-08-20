"
I'm a modern implementation of Python's method decorators or MethodWrappers for Pharo based on `valueWithReceiver:arguments:` VM hook.
Method proxies are objects that wrap methods stored in the method dictionary of the class. 
Some support before and after action the execution of the original method. 
Method proxies control their installation and propagation. 
In particular, they can be applied to any Pharo method. The implementation ensures that the method proxy installation cannot touch any part of the system that could be used to installation.
Method proxies delegate to method handler. This delegation ensures that end user cannot blow up their environment by overridding undesired methods.
## Usage
Here is a typical usage. Check the tests to know more. 
```
testCounts
	| proxy instance handler |
	[ proxy := MpMethodProxy
		on: #methodOne
		inClass: MpClassA
		handler: (handler := MwCountingHandler new).
	proxy install.
	instance := MpClassA new.
	self assert: handler count equals: 0.
	instance methodOne.
	self assert: handler count equals: 1.
	instance methodOne.
	self assert: handler count equals: 2 ] ensure: [ proxy uninstall ]
```
This package is developed and maintained by S. Ducasse, G. Polito and P. Tesone, but feel free to give a hand. 
"
Class {
	#name : 'MgkMethodWrapper',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'methodClass',
		'isDisabled',
		'handler',
		'proxifiedMethod'
	],
	#category : 'MessageGatekeeper',
	#package : 'MessageGatekeeper'
}

{ #category : 'reflective operations' }
MgkMethodWrapper class >> doesNotUnderstand: aMessage [

	^ CompiledMethod 
		  perform: aMessage selector
		  withArguments: aMessage arguments
]

{ #category : 'instance creation' }
MgkMethodWrapper class >> on: selector inClass: aClass handler: aHandler [

	| proxy |
	proxy := self new.
	proxy class: aClass selector: selector.
	proxy handler: aHandler.
	^ proxy
]

{ #category : 'instance creation' }
MgkMethodWrapper class >> onMethod: aMethod handler: aHandler [

	^ self on: aMethod selector inClass: aMethod methodClass handler: aHandler
]

{ #category : 'private' }
MgkMethodWrapper class >> uninstallAllWrappers [
	"self uninstallAllWrappers"

	self allSubInstancesDo: [ :inst | inst uninstall ]
]

{ #category : 'comparing' }
MgkMethodWrapper >> = anObject [
	"Answer whether the receiver and the argument represent the same
	object. If = is redefined in any subclass, consider also redefining the
	message hash."

	^ self == anObject
]

{ #category : 'accessing' }
MgkMethodWrapper >> calypsoEnvironmentType [
	^ proxifiedMethod 
			ifNotNil: [ proxifiedMethod calypsoEnvironmentType ]
			ifNil: [ super calypsoEnvironmentType ]
			
]

{ #category : 'initialization' }
MgkMethodWrapper >> class: aClass selector: aSymbol [

	self
		methodClass: aClass;
		selector: aSymbol
]

{ #category : 'accessing' }
MgkMethodWrapper >> disable [

	isDisabled := true
]

{ #category : 'accessing' }
MgkMethodWrapper >> doesNotUnderstand: aMessage [
	^ proxifiedMethod 
			ifNotNil: [ proxifiedMethod 
								perform: aMessage selector 
								withArguments: aMessage arguments ]
			ifNil: [ super doesNotUnderstand: aMessage ]
			
]

{ #category : 'accessing' }
MgkMethodWrapper >> fetchMethod [
	
	"Fetches the method to be instrumented"
	^ methodClass >> selector
]

{ #category : 'installation' }
MgkMethodWrapper >> handler [

	^ handler
]

{ #category : 'accessing' }
MgkMethodWrapper >> handler: aHandler [

	handler := aHandler
]

{ #category : 'installation' }
MgkMethodWrapper >> initialize [

	super initialize.
	isDisabled := true
]

{ #category : 'installation' }
MgkMethodWrapper >> install [
	"We have a method proxy with a method = class * selector of the method it will proxy."
	
	|  method |
	method := methodClass compiledMethodAt: selector ifAbsent: [ 
		MgkCannotInstall signalWith: self ].
	
	(self shouldWrap: method) ifFalse: [ 
		MgkCannotInstall signalWith: self ].
	
	self unproxifiedMethod: method.
	methodClass methodDict at: selector put: self.
	
	"Activate it now"
	isDisabled := false.
	^ self
]

{ #category : 'accessing' }
MgkMethodWrapper >> isEnabled [

	^ isDisabled not
]

{ #category : 'accessing' }
MgkMethodWrapper >> isEnabled: anObject [

	isDisabled := anObject not
]

{ #category : 'testing' }
MgkMethodWrapper >> isInstalled [
	"Return whether the receiver is effectively installed in a method dictionary.
	Note that in the case of nesting of method proxies the inner ones are not considered as installed."
	
	methodClass ifNotNil: [
		selector ifNotNil: [ 
			^ self == (methodClass methodDict at: selector ifAbsent: [])]].
	^ false
]

{ #category : 'testing' }
MgkMethodWrapper >> isMethodProxy [

	^ true
]

{ #category : 'accessing' }
MgkMethodWrapper >> methodClass [
	^ methodClass
]

{ #category : 'accessing' }
MgkMethodWrapper >> methodClass: aClass [

	methodClass := aClass
]

{ #category : 'evaluating' }
MgkMethodWrapper >> name [

	^ self printString
]

{ #category : 'printing' }
MgkMethodWrapper >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPutAll: '[';
		nextPutAll: methodClass name;
		nextPutAll: '>>#';
		nextPutAll: selector;
		nextPutAll: ']'
]

{ #category : 'evaluating' }
MgkMethodWrapper >> receiver: aReceiver withArgs: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and args in argArray"

	<primitive: 188>
	<methodProxyCannotWrap>
	self primitiveFailed
]

{ #category : 'evaluating' }
MgkMethodWrapper >> run: aSelector with: anArrayOfObjects in: aReceiver [
	"Do not intercept"

	<methodProxyCannotWrap>
	<primitive: 198>
	| unwinder complete process result |
	unwinder := (MgkInstrumentationUnwinder newWithHandler: handler receiver: aReceiver arguments: anArrayOfObjects).	
	
	process := Processor activeProcess.

	(isDisabled or: [ process isMeta ]) ifTrue: [
		^ self receiver: aReceiver withArgs: anArrayOfObjects executeMethod: proxifiedMethod ].

	process runInMetaLevel: [
		handler beforeExecutionWithReceiver: aReceiver arguments: anArrayOfObjects ].

	result := self receiver: aReceiver withArgs: anArrayOfObjects executeMethod: proxifiedMethod.
	complete := true.

	process runInMetaLevel: [
		^ handler afterExecutionWithReceiver: aReceiver arguments: anArrayOfObjects returnValue: result]
]

{ #category : 'accessing' }
MgkMethodWrapper >> selector [

	^ selector
]

{ #category : 'accessing' }
MgkMethodWrapper >> selector: aSymbol [

	selector := aSymbol
]

{ #category : 'installation' }
MgkMethodWrapper >> shouldWrap: aMethod [

	(aMethod isCompiledMethod not and: [
		 aMethod handler class ~~ self handler class ]) ifTrue: [ ^ true ].

	aMethod isCompiledMethod ifFalse: [ ^ false ].

	^ aMethod pragmas noneSatisfy: [ :pragma |
		  pragma selector = #methodProxyCannotWrap or: [
			  pragma selector = #noInstrumentation ] ]
]

{ #category : 'installation' }
MgkMethodWrapper >> uninstall [

	| installedMethod |
	thisProcess runInMetaLevel: [
		installedMethod := methodClass
			                   compiledMethodAt: selector
			                   ifAbsent: [ ^ self ].
		installedMethod == self ifTrue: [
			methodClass methodDict
				at: selector
				put: installedMethod wrappedMethod ].
		self unproxifiedMethod: nil ]
]

{ #category : 'accessing' }
MgkMethodWrapper >> unproxifiedMethod [
	"The unproxifedMethod returns the proxified method even in case we have multiple proxified nesting."
	
	^ proxifiedMethod ifNotNil: [ proxifiedMethod unproxifiedMethod ]
]

{ #category : 'when installed' }
MgkMethodWrapper >> unproxifiedMethod: aCompiledMethod [

	proxifiedMethod := aCompiledMethod
]

{ #category : 'accessing' }
MgkMethodWrapper >> wrappedClass [

	^ methodClass
]

{ #category : 'accessing' }
MgkMethodWrapper >> wrappedClass: aClass [

	methodClass := aClass
]

{ #category : 'when installed' }
MgkMethodWrapper >> wrappedMethod [

	^ proxifiedMethod
]
