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
			spec package: 'MessageGateKeeper'.
			spec package: 'MessageGateKeeper-Tests' with: [ spec requires: #( 'MessageGateKeeper' ) ].

			"Groups"
			spec group: 'default' with: #( 'core' 'tests' ).
			spec group: 'core' with: #( 'MessageGateKeeper' ).
			spec group: 'tests' with: #( 'MessageGateKeeper-Tests' ) ]
]
