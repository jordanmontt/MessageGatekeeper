Class {
	#name : 'MgkInstrumentationUnwinder',
	#superclass : 'InstrumentationEnsurer',
	#instVars : [
		'receiver',
		'arguments',
		'handler'
	],
	#category : 'MessageGatekeeper',
	#package : 'MessageGatekeeper'
}

{ #category : 'instance creation' }
MgkInstrumentationUnwinder class >> newWithHandler: aHandler receiver: receiver arguments: arguments [

	^ self new
		  handler: aHandler;
		  receiver: receiver;
		  arguments: arguments;
		  yourself
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> arguments [

	^ arguments
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> arguments: anObject [

	arguments := anObject
]

{ #category : 'converting' }
MgkInstrumentationUnwinder >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^(Context newForMethod: (MgkInstrumentationUnwinder >> #value))
		setSender: aContext
		receiver: self
		method: (MgkInstrumentationUnwinder >> #value)
		closure: nil
		startpc: (MgkInstrumentationUnwinder >> #value) initialPC;
		privRefresh
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> handler [

	^ handler
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> handler: anObject [

	handler := anObject
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> receiver [

	^ receiver
]

{ #category : 'accessing' }
MgkInstrumentationUnwinder >> receiver: anObject [

	receiver := anObject
]

{ #category : 'evaluating' }
MgkInstrumentationUnwinder >> value [

	<methodProxyCannotWrap>
	Processor activeProcess runInMetaLevel: [
		^ handler aboutToReturnWithReceiver: receiver arguments: arguments ]
]
