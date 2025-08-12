Class {
	#name : 'MgkMethodWrapperTest',
	#superclass : 'TestCase',
	#instVars : [
		'trackedWrappers'
	],
	#category : 'MessageGatekeeper-Tests',
	#package : 'MessageGatekeeper-Tests'
}

{ #category : 'asserting' }
MgkMethodWrapperTest class >> shouldInheritSelectors [
	^ true
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> assertCannotInstall: mp [

	[mp install.
	self fail.]
		on: MgkCannotInstall do: [ :ex |
			self assert: ex methodProxy equals: mp ]
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> callEnsureWithNonLocalReturn [
	
	[ ^ 7 ] ensure: [ 2 ]
]

{ #category : 'hook' }
MgkMethodWrapperTest >> handlerClass [

	^ MgkHandler
]

{ #category : 'tests - dead representation' }
MgkMethodWrapperTest >> installMethodProxy: aMethodProxy [

	trackedWrappers add: aMethodProxy.
	aMethodProxy install.

]

{ #category : 'initialization' }
MgkMethodWrapperTest >> setUp [ 

	super setUp.
	trackedWrappers := OrderedCollection new.
	MgkClassA methods do: [ :each | each uninstall ]
	
]

{ #category : 'initialization' }
MgkMethodWrapperTest >> tearDown [

	trackedWrappers do: [ :e | e uninstall ].
	super tearDown
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanRunConcurrently [
	"This tests the ability of method proxies to not influence each other between threads."
	| mp1 mp2 mpTrigger1 mpTrigger2 handlerTrigger1 handlerTrigger2 sharedObject testSemaphore |

	sharedObject := MgkTestConcurrentSharedObject new.
	testSemaphore := Semaphore new.

	mp1 := MgkMethodWrapper onMethod: (MgkTestConcurrentSharedObject lookupSelector: #methodProcess1) handler: (MgkWaitBeforeHandler new).
	mp2 := MgkMethodWrapper onMethod: (MgkTestConcurrentSharedObject lookupSelector: #methodProcess2) handler: (MgkWaitAndTriggerBeforeHandler new).
	mpTrigger1 := MgkMethodWrapper onMethod: (MgkTestConcurrentSharedObject lookupSelector: #trigger1) handler: (handlerTrigger1 := MgkAfterCounterHandler new).
	mpTrigger2 := MgkMethodWrapper onMethod: (MgkTestConcurrentSharedObject lookupSelector: #trigger2) handler: (handlerTrigger2 := MgkAfterCounterHandler new).

	self installMethodProxy: mp1.
	self installMethodProxy: mp2.
	self installMethodProxy: mpTrigger1.
	self installMethodProxy: mpTrigger2.

	"Here the first process will run an instrumented trigger (trigger1) while the second process is not instrumenting, then the second process will run a non-instrumented trigger while the first process is still instrumenting."
	[ sharedObject methodProcess1. testSemaphore signal ] fork.
	[ sharedObject methodProcess2. testSemaphore signal ] fork.
	testSemaphore wait.

	"Here the first trigger should have been captured, but not the second. If not concurrency is not correctly managed."
	self assert: handlerTrigger1 count equals: 1.
	self assert: handlerTrigger2 count equals: 0
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapAboutToReturnThroughWithNonLocalReturn [

	| mp handler |
	mp := MgkMethodWrapper onMethod: Context >> #aboutToReturn:through: handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapBasicNew [

	| mp handler |
	mp := MgkMethodWrapper onMethod: Behavior >> #basicNew handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	MgkClassA new.

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapEnsure [

	| mp handler |
	mp := MgkMethodWrapper onMethod: BlockClosure >> #ensure: handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	[ 1 ] ensure: [ 2 ].

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapEnsureNonLocalReturn [

	| mp handler |
	mp := MgkMethodWrapper onMethod: BlockClosure >> #ensure: handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapEnsureWithException [

	| mp handler |
	mp := MgkMethodWrapper onMethod: BlockClosure >> #ensure: handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 error ] ensure: [ 2 ]] on: Error do: [ "nothing" ].

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapValue [
	<compilerOptions: #(- optionConstantBlockClosure)>
	| mp handler |
	mp := MgkMethodWrapper onMethod: (FullBlockClosure lookupSelector: #value) handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 ] value] value.

	self assert: handler count equals: 2
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCanWrapValueWithException [

	| mp handler |
	mp := MgkMethodWrapper onMethod: (FullBlockClosure lookupSelector: #value) handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	[[[ 1 error ] value] value] on: Error do: #yourself "to avoid an extra block".

	self assert: handler count equals: 2 "value" + 1 "on:do:"
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testCannotProxyUnexistentMethod [

	| mp |
	mp := MgkMethodWrapper on: #methodOne inClass: Object handler: self handlerClass new.
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods [

	| mp handler |
	mp := MgkMethodWrapper onMethod: MgkMethodWrapper >> #run:with:in: handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods2 [

	| mp handler |
	mp := MgkMethodWrapper onMethod: MgkMethodWrapper >> #receiver:withArgs:executeMethod: handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods3 [

	| mp handler |
	mp := MgkMethodWrapper onMethod: MgkMethodWrapper >> #run:with:in: handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods4 [

	| mp handler |
	mp := MgkMethodWrapper onMethod: BlockClosure >> #methodProxiesIfCurtailed: handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods5 [

	| mp handler |
	mp := MgkMethodWrapper onMethod: MgkInstrumentationUnwinder >> #value handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testCannotWrapCriticalProxyMethods6 [

	| mp handler |
	mp := MgkMethodWrapper onMethod: InstrumentationDeactivator >> #value handler: (handler := MgkCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - dead representation' }
MgkMethodWrapperTest >> testCreatingAnInstanceDoesNotInstallIt [

	| mp method |
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	self assert: mp selector equals: #methodOne.
	self assert: mp methodClass equals: MgkClassA.

	self assert: mp wrappedMethod equals: nil
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testExceptionsAfterInstrumentationDoNotBreakInstrumentation [

	| mp handler |
	mp := MgkMethodWrapper onMethod: Object >> #error: handler: (handler := MgkCountingHandler new).
	
	self installMethodProxy: mp.

	"An error after instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented, and the counting code should still execute regardless the exception"
	2 timesRepeat: [
		[MgkClassB new error: 'error after instrumentation'.
		self fail] on: Error do: [ :error | ] ].

	self assert: handler count equals: 2
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testExceptionsAfterInstrumentationFlow [
"Managing exceptions in the wrapper"
	| p |
	p := MgkMethodWrapper onMethod: Object >> #error: handler: MgkCountingHandler new.
	
	self installMethodProxy: p.

	"An error after instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[ MgkClassB new error: 'error after instrumentation'.
		self fail ]
			on: Error do: [ :error |
				self assert: error messageText equals: 'error after instrumentation' ].]
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testExceptionsDuringInstrumentationDoNotBreakInstrumentation [
"Managing exceptions in the wrapper"
	| w |
	w := MgkMethodWrapper onMethod: MgkClassB >> #methodTwo  handler: MgkFailingHandlerMock new.
	
	self installMethodProxy: w.

	"An error during instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[MgkClassB new methodTwo.
		self fail]
			on: Error do: [ :error |
				self assert: error messageText equals: 'error during instrumentation' ].]
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testInstallSetCompiledMethod [

	| mw method |
	[ 
	method := MgkClassA >> #methodOne.
	mw := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mw install.
	self assert: mw selector equals: #methodOne.
	self assert: mw methodClass equals: MgkClassA.
	self assert: mw wrappedMethod equals: method ] ensure: [ 
		mw uninstall ]
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testIsInstalled [

	| mw method |
	[ 
	method := MgkClassA >> #methodOne.
	mw := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	self deny: mw isInstalled.
	mw install.
	self assert: mw isInstalled ] ensure: [ mw uninstall ]
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testIsInstalledNestedMWAreNotInstalled [

	| mp method mp2 |
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp2 := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: MgkMockHandler new.
	mp install.
	mp2 install.
	self deny: mp isInstalled.
	self assert: mp2 isInstalled.
	mp2 uninstall.
	self deny: mp2 isInstalled.
	self assert: mp isInstalled.
	mp uninstall.
	self deny: mp isInstalled
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testRecursiveMethodWrapperDoesNotRecurse [

	| mw method |
	method := MgkMockObject >> #recursiveMethod.
	mw := MgkMethodWrapper onMethod: method  handler: MgkMockHandler new.
	self installMethodProxy: mw.

	self assert: MgkMockObject new recursiveMethod equals: 'trapped [original]'.
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testUninstall [

	| mp method |
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp install.
	self assert: (MgkClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MgkClassA compiledMethodAt: #methodOne) == mp.
	mp uninstall.
	self assert: (MgkClassA compiledMethodAt: #methodOne) == method.
	self assert: mp wrappedMethod isNil
]

{ #category : 'tests - installation' }
MgkMethodWrapperTest >> testUninstallNestedInRightOrderIsOk [

	| mp mp2 method |
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp2 := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: MgkMockHandler new.
	mp install.
	mp2 install.
	self assert: (MgkClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MgkClassA compiledMethodAt: #methodOne) identicalTo: mp2.
	mp2 uninstall.
	self assert: (MgkClassA compiledMethodAt: #methodOne) identicalTo: mp.
	mp uninstall.
	self
		assert: (MgkClassA compiledMethodAt: #methodOne)
		identicalTo: method
]

{ #category : 'tests' }
MgkMethodWrapperTest >> testUnwrappedMethodAtOneLevelIsTheWrappedMethod [

	| mp method |
	[ 
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp install.
	self assert: mp unproxifiedMethod equals: method ] ensure: [ 
		mp uninstall ]
]

{ #category : 'tests' }
MgkMethodWrapperTest >> testUnwrappedMethodOfNestedMethodWrapperInTheCompiledMethod [

	| mp method mp2 |
	[ 
	method := MgkClassA >> #methodOne.
	mp := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp install.
	mp2 := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: MgkMockHandler new.
	mp2 install.

	self assert: mp2 wrappedMethod equals: mp.
	self assert: mp2 unproxifiedMethod equals: method ] ensure: [ 
		mp2 uninstall.
		mp uninstall ]
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testWrapEssentialPrimitiveShouldBeCalledDuringInstallation [

	| mw method handler |
	method := SmallInteger >> #+.
	mw := MgkMethodWrapper onMethod: method handler: (handler := MgkCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testWrapEssentialPrimitiveShouldNotRecurse [

	| mw method handler |
	method := SmallInteger >> #+.
	mw := MgkMethodWrapper onMethod: method handler: (handler := MgkCalledHandler new).
	self installMethodProxy: mw.

	"Do a perform, otherwise the addition is optimized out and tried as non-send addition.
	A message send is issued only if the normal addition fails"
	1 perform: #+ with: 2.

	self assert: handler called
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testWrapMethodCalledDuringInstallationIsNotIntercepted [

	| mw method handler |
	method := SmallInteger lookupSelector: #max:.
	mw := MgkMethodWrapper onMethod: method handler: (handler := MgkCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : 'tests - safety' }
MgkMethodWrapperTest >> testWrapNonLocalReturns [

	| mp handler |
	mp := MgkMethodWrapper
		      onMethod: MgkClassA >> #methodAcceptingABlock:
		      handler: (handler := MgkAfterCounterHandler new).

	self installMethodProxy: mp.

	MgkClassA new methodWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests' }
MgkMethodWrapperTest >> testWrappingTwiceIsPossible [

	| mp1 method mp2 |
	[ 
	method := MgkClassA >> #methodOne.
	mp1 := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: self handlerClass new.
	mp1 install.

	mp2 := MgkMethodWrapper on: #methodOne inClass: MgkClassA handler: MgkMockHandler new.
	mp2 install.

	self assert: mp1 selector equals: #methodOne.
	self assert: mp1 methodClass equals: MgkClassA.
	self assert: mp1 wrappedMethod equals: method.

	self assert: mp2 selector equals: #methodOne.
	self assert: mp2 methodClass equals: MgkClassA.
	self assert: mp2 wrappedMethod equals: mp1 ] ensure: [ 
		mp2 uninstall.
		self assert: (MgkClassA methodDict at: #methodOne) equals: mp1.
		mp1 uninstall.
		self assert: (MgkClassA methodDict at: #methodOne) equals: method ]
]
