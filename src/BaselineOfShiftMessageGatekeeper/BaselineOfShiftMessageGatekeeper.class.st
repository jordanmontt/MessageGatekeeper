Class {
	#name : 'BaselineOfShiftMessageGatekeeper',
	#superclass : 'BaselineOfShift',
	#category : 'BaselineOfShiftMessageGatekeeper',
	#package : 'BaselineOfShiftMessageGatekeeper'
}

{ #category : 'baselines' }
BaselineOfShiftMessageGatekeeper >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: 'MessageGatekeeper'.
			spec package: 'MessageGatekeeper-Tests' with: [ spec requires: #( 'MessageGatekeeper' ) ].

			"Groups"
			spec group: 'default' with: #( 'core' 'tests' ).
			spec group: 'core' with: #( 'MessageGatekeeper' ).
			spec group: 'tests' with: #( 'MessageGatekeeper-Tests' ) ]
]
