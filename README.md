# MessageGatekeeper

[![Pharo version](https://img.shields.io/badge/Pharo-12-%23aac9ff.svg)](https://pharo.org/download)[![Pharo version](https://img.shields.io/badge/Pharo-13-%23aac9ff.svg)](https://pharo.org/download)[![Pharo version](https://img.shields.io/badge/Pharo-14-%23aac9ff.svg)](https://pharo.org/download)

MessageGatekeeper is an instrumentation library for Pharo that allows you to instrument any method.

What does instrumentation mean? It’s the process of decorating a method so that an action is executed before and after the method itself runs.

MessageGatekeeper enables message-passing control by allowing this kind of method decoration. It supports meta-recursion safety (i.e., calling an instrumented method from within the instrumentation doesn't cause infinite loops) and is process-aware. It also has a robust architecture that allows for instrumentation of any method.

## Important Note
Wait, isn't [MethodProxies](https://github.com/pharo-contributions/MethodProxies) doing exactly the same thing?

Yes — and in fact, you _should_ use MethodProxies instead of this library, if possible.

MessageGatekeeper implements message-passing control similarly to MethodProxies, but it uses a different technique: it relies on the `run:with:in:` hook. Because of this, it's slower than MethodProxies, which uses a more efficient approach.

This project mainly exists to experiment with the alternative instrumentation technique and to run benchmarks comparing MethodProxies against `run:with:in:` based approaches. Still, MessageGatekeeper is a solid library and it works.

## How to load it

```st
EpMonitor disableDuring: [
	Metacello new
		baseline: 'MessageGatekeeper';
		repository: 'github://jordanmontt/MessageGatekeeper:main';
		load ].
```

# How to depend on it

```st
spec
  baseline: 'MessageGatekeeper'
  with: [ spec repository: 'github://jordanmontt/MessageGatekeeper:main' ].
```

## Small usage example

```st
"Create a handler and increments a count when a method is called.
You can also implement your own handlers."
handler :=  MgkCountingHandler new.

"Instantiate the method proxy"
p := MgkMethodWrapper 
	onMethod: Object >> #error: 
	handler: handler.

"Install the instrumentation"
p install.

"Execute the instrumented method"
1 error: 'foo'.

"Uninstall the instrumentation"
p uninstall.

"Inspect the handler count, which is 1 as the method has been called only one"
handler count.
>>> 1
```