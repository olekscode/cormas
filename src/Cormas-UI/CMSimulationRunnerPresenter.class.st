Class {
	#name : 'CMSimulationRunnerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'translator',
		'simulation',
		'simulationControls',
		'runButton',
		'stepButton',
		'progressBarLabel',
		'progressBar',
		'finalStep',
		'speedDropList',
		'displayEvery',
		'notebook',
		'spacePresenter',
		'dataTable',
		'chartPresenter',
		'spacePage',
		'dataPage',
		'chartsPage',
		'shouldPause'
	],
	#category : 'Cormas-UI',
	#package : 'Cormas-UI'
}

{ #category : 'examples' }
CMSimulationRunnerPresenter class >> example [
	<example>
	| simulation |

	simulation := (CMSimulation for: CMMockModel)
		randomSeed: 41;
		activeInitSelector: #initFixed;
		activeControlSelector: #step:;
		initializeSimulation;
		yourself.

	(self forTranslator: CMEnglishTranslator new)
		simulation: simulation;
		open
]

{ #category : 'examples' }
CMSimulationRunnerPresenter class >> exampleEmpty [
	<example>
	(self forTranslator: CMEnglishTranslator new) open
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter class >> forTranslator: aTranslator [

	^ self on: aTranslator
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter class >> openForSimulation: aSimulation withTranslator: aTranslator [

	(self forTranslator: aTranslator)
		simulation: aSimulation;
		open
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> beInNotRunningMode [

	runButton
		icon: CMIcons runIcon;
		action: [ self runSimulationUntilEnd ].
		
	stepButton enabled: true.
	
	self flag: 'TODO'.
	"owner ifNotNil: [ owner beInNotRunningMode ]"
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> beInRunningMode [

	runButton
		icon: CMIcons pauseIcon;
		action: [ self shouldPause: true ].
		
	stepButton enabled: false.
	
	self flag: 'TODO'.
	"owner ifNotNil: [ owner beInRunningMode ]"
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> connectPresenters [

	stepButton action: [
		self stepSimulation ].

	finalStep whenNumberChangedDo: [ :number |
		self updateFinalTimeStep: number ].
	
	notebook whenSelectedPageChangedDo: [ :page |
		self updateSelectedNotebookPage ].
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> currentTimeStep: aNumber [

	progressBarLabel label: ('Step ', aNumber asString).
	
	progressBar fixedAt: (finalStep number = 0
		ifTrue: [ 0 ]
		ifFalse: [ (aNumber / finalStep number) asFloat ]).
]

{ #category : 'specs' }
CMSimulationRunnerPresenter >> defaultLayout [

	| row1Height row2Height simulationControlsLayout |
	
	row1Height := self class labelHeight.
	row2Height := self class buttonHeight.

	simulationControlsLayout := SpBoxLayout newTopToBottom
		spacing: 10;
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: (SpBoxLayout newTopToBottom
				spacing: 3;
				add: translator tStepButtonLabel height: row1Height;
				add: stepButton height: row2Height;
				yourself) width: 40;
			add: (SpBoxLayout newTopToBottom
				spacing: 3;
				add: translator tRun height: row1Height;
				add: runButton height: row2Height;
				yourself) width: 40;
			add: '';
			add: (SpBoxLayout newTopToBottom
				spacing: 3;
				add: translator tFinalStep height: row1Height;
				add: finalStep height: row2Height;
				yourself) width: self class buttonWidth;
			add: (SpBoxLayout newTopToBottom
				spacing: 3;
				add: translator tSpeedLabel height: row1Height;
				add: speedDropList height: row2Height;
				yourself) width: 120;
			add: (SpBoxLayout newTopToBottom
				spacing: 3;
				add: translator tDisplayEveryLabel height: row1Height;
				add: displayEvery height: row2Height;
				yourself) width: self class buttonWidth;
			yourself) height: row1Height + row2Height + 3;
		add: (SpBoxLayout newLeftToRight 
			spacing: 3;
			add: (SpBoxLayout newTopToBottom
				add: translator tProgressBarLabel height: self class labelHeight;
				add: progressBarLabel height: self class labelHeight;
				yourself) width: 80;
			add: progressBar;
			yourself) height: self class labelHeight * 2 + 1;
		yourself.
	
	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: simulationControlsLayout height: 90;
		add: notebook;
		yourself
]

{ #category : 'examples' }
CMSimulationRunnerPresenter >> example [
	<script: 'self example'>
]

{ #category : 'settings' }
CMSimulationRunnerPresenter >> finalTimeStep [

	^ finalStep number = 0
		ifTrue: [ nil ]
		ifFalse: [ finalStep number ]
]

{ #category : 'settings' }
CMSimulationRunnerPresenter >> finalTimeStep: aNumber [

	finalStep number: aNumber
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> fitDiagram [

	simulation ifNil: [ ^ self ].
	spacePresenter fitDiagram.
]

{ #category : 'testing' }
CMSimulationRunnerPresenter >> hasSimulation [
	
	^ simulation isNotNil
]

{ #category : 'testing' }
CMSimulationRunnerPresenter >> hasSimulationData [
	"Answer true if there is a simulation data that could be lost if presenter is closed"
	
	^ simulation isNotNil and: [ simulation data isNotEmpty ]
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> hideSettings [

	self flag: 'TODO'.
	"simulationControls hide."
	
	self flag: 'TODO'.
	"owner hideInitializationSettings."
	self update.
	self fitDiagram
]

{ #category : 'public' }
CMSimulationRunnerPresenter >> initializeCharts [

	chartPresenter := self
		instantiate: CMChartPresenter
		on: { simulation . translator } 
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializeDataTable [

	dataTable := self instantiate: CMDataPresenter on: translator.
	dataTable columnNames: (simulation activeProbes collect: #name)
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializeNotebookPages [
	"Purpose: Set the Notebook Pages:
	grid = SpacePresenter, 
	data table = initializeDataTable,
	charts = diagrams"

	self initializeSpacePresenter.
	self initializeDataTable.
	self initializeCharts.

	notebook removeAll.

	spacePage := SpNotebookPage
		             title: translator tSpace
		             provider: [ spacePresenter ].
	"icon: (self iconNamed: #paint)"

	dataPage := SpNotebookPage
		            title: translator tData
		            provider: [ dataTable ].
	"icon: (self iconNamed: #database)"

	chartsPage := SpNotebookPage
		              title: translator tCharts
		              provider: [ chartPresenter ].
	"icon: CMIcons chartIcon"

	notebook addPage: spacePage.
	notebook addPage: dataPage.
	notebook addPage: chartsPage.

	notebook addPage: (SpNotebookPage
			 title: translator tInspector
			 provider: [ StInspectorPresenter onObject: simulation ]).
	"icon: (self iconNamed: #smallInspectIt)"

	notebook selectPageIndex: 1
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializePresenters [

	shouldPause := false.
	
	runButton := self newButton
		help: translator tRunButtonHelp;
		yourself.
		
	stepButton := self newButton
		icon: CMIcons stepIcon;
		help: translator tStepButtonHelp;
		yourself.
		
	progressBar := self newProgressBar.
	progressBarLabel := self newLabel.
		
	finalStep := self newNumberInput
		beInteger;
		climbRate: 50;
		minimum: 0;
		yourself.
	
	speedDropList := self newDropList
		help: translator tSpeedHelp;
		items: self speedDropListItems;
		selectItem: translator tSpeedNormal; 
		yourself.
		
	displayEvery := self newNumberInput
		beInteger;
		minimum: 1;
		number: 1;
		yourself.
		
	self currentTimeStep: 0.
	self beInNotRunningMode.
		
	notebook := self newNotebook.

	"A hack to overcome an issue with notebook pages that were added to an empty notebook not signalling the event when they are selected"
	notebook addPage: (SpNotebookPage
		title: 'Empty'
		provider: [ self newLabel ]).
	
	"By default this page is disabled. It will be enabled when the simulation: setter is called"
	self enabled: false
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializeSpacePresenter [
	"Purpose: Instanciates a new SpacePresenter for the given simulation"
	spacePresenter := self instantiate: CMSpacePresenter on: simulation cormasModel
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	
	aWindowPresenter 
		title: 'Simulation Runner';
		initialExtent: 1000@600;
		whenResizingDo: [ self fitDiagram ].
]

{ #category : 'initialization' }
CMSimulationRunnerPresenter >> initializeWithSimulation [
"Purpose: set the final time step, then initialize the Notebook Pages (grid, diagrams,...)"
	self enabled: true.
	self finalTimeStep: simulation finalTimeStep.
	self initializeNotebookPages.
]

{ #category : 'actions' }
CMSimulationRunnerPresenter >> runSimulationUntilEnd [

	self beInRunningMode.
	
	[ [ [ simulation currentTimeStep < simulation finalTimeStep and: [ shouldPause not ] ] whileTrue: [
		(displayEvery number min: (simulation finalTimeStep - simulation currentTimeStep))
			timesRepeat: [ simulation runStep ].
			
		[ self updateAfterStep ] onErrorDo: [ :error |
			"An ugly hack to silence Roassal errors that are caused by parallel execution"
			error asString = '#intersect: was sent to nil'
				ifFalse: [ error signal ] ].
		
		(Delay forMilliseconds: self speedInMilliseconds) wait ]
	] ensure: [
		shouldPause := false.
		self beInNotRunningMode ].
 
	shouldPause := false.
	self beInNotRunningMode ] fork.
]

{ #category : 'accessing - model' }
CMSimulationRunnerPresenter >> setModelBeforeInitialization: aTranslator [

	translator := aTranslator
]

{ #category : 'accessing' }
CMSimulationRunnerPresenter >> shouldPause: aBoolean [

	shouldPause := aBoolean
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> showSettings [

	self flag: 'TODO'.
	"simulationControls show."
	
	self flag: 'TODO'.
	"owner showInitializationSettings."
	self update.
	self fitDiagram
]

{ #category : 'accessing' }
CMSimulationRunnerPresenter >> simulation [

	^ simulation 
]

{ #category : 'accessing' }
CMSimulationRunnerPresenter >> simulation: aSimulation [

"Purpose: registers aSimulation, then initialize the Notebook Pages (grid, diagrams,...)"

	simulation := aSimulation.
	self initializeWithSimulation
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> speedDropListItems [

	^ {
		  translator tSpeed10xSlower.
		  translator tSpeed5xSlower.
		  translator tSpeed2xSlower.
		  translator tSpeedNormal.
		  translator tSpeed2xFaster.
		  translator tSpeed5xFaster.
		  translator tSpeed10xFaster }
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> speedInMilliseconds [

	| normalSpeed mapping |
	normalSpeed := 200.

	mapping := {
		translator tSpeed10xSlower -> (normalSpeed * 10) .
		translator tSpeed5xSlower -> (normalSpeed * 5) .
		translator tSpeed2xSlower -> (normalSpeed * 2) .
		translator tSpeedNormal -> normalSpeed .
		translator tSpeed2xFaster -> (normalSpeed / 2) .
		translator tSpeed5xFaster -> (normalSpeed / 5) .
		translator tSpeed10xFaster -> (normalSpeed / 10)
	} asDictionary.
	
	^ mapping at: speedDropList selectedItem
]

{ #category : 'actions' }
CMSimulationRunnerPresenter >> stepSimulation [

	simulation runStep.
	self updateAfterStep.
]

{ #category : 'accessing' }
CMSimulationRunnerPresenter >> translator: anObject [

	translator := anObject
]

{ #category : 'update presenters' }
CMSimulationRunnerPresenter >> updateAfterStep [

	self currentTimeStep: simulation currentTimeStep. 
	self updateSelectedNotebookPage.
]

{ #category : 'update presenters' }
CMSimulationRunnerPresenter >> updateChart [

	chartPresenter updateCharts.
]

{ #category : 'update presenters' }
CMSimulationRunnerPresenter >> updateDataTable [

	dataTable showData: simulation data
]

{ #category : 'as yet unclassified' }
CMSimulationRunnerPresenter >> updateFinalTimeStep: aNumber [

	simulation finalTimeStep: aNumber
]

{ #category : 'update presenters' }
CMSimulationRunnerPresenter >> updateSelectedNotebookPage [
	"Only update the page that is currently being displayed. This makes execution much faster because other pages (chart, space, data table) will not be updated when they are not displayed"
	
	notebook selectedPage ifNil: [ ^ self ].
	
	notebook selectedPage = spacePage ifTrue: [ self updateSpace ].
	notebook selectedPage = dataPage ifTrue: [ self updateDataTable ].
	notebook selectedPage = chartsPage ifTrue: [ self updateChart ]
]

{ #category : 'update presenters' }
CMSimulationRunnerPresenter >> updateSpace [

	spacePresenter updateDiagram
]
