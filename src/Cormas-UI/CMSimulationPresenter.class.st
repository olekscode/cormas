Class {
	#name : 'CMSimulationPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'translator',
		'modelClass',
		'fancyNotebookButtons',
		'fancyNotebookPage',
		'simulationRunner',
		'simulation'
	],
	#category : 'Cormas-UI',
	#package : 'Cormas-UI'
}

{ #category : 'examples' }
CMSimulationPresenter class >> example [
	<example>
	(self forModelClass: CMMockModel translator: CMEnglishTranslator new) open
]

{ #category : 'as yet unclassified' }
CMSimulationPresenter class >> forModelClass: aClass translator: aTranslator [

	^ self on: { aClass . aTranslator }
]

{ #category : 'layout' }
CMSimulationPresenter >> defaultLayout [

	| buttonsLayout |
	
	buttonsLayout := SpBoxLayout newTopToBottom.
	
	fancyNotebookButtons do: [ :button |
		buttonsLayout add: button height: 40 ].

	^ SpBoxLayout newLeftToRight
		spacing: 4;
		add: buttonsLayout width: 40;
		add: fancyNotebookPage width: 250;
		"this null presented is a hack to have a larger spacing between 2nd and 3rd column than the one between 1st and 2nd column while keeping all 3 columns in the same layout. If they are in different layouts, hiding column 2 will not expand column 3"
		add: SpNullPresenter new width: 6;
		add: simulationRunner;
		yourself
]

{ #category : 'examples' }
CMSimulationPresenter >> example [
	<script: 'self example'>
]

{ #category : 'settings' }
CMSimulationPresenter >> finalTimeStep [
	
	^ simulationRunner finalTimeStep
]

{ #category : 'as yet unclassified' }
CMSimulationPresenter >> hideOrShowFancyNotebookPage [

	(fancyNotebookButtons anySatisfy: #isActive)
		ifTrue: [ fancyNotebookPage show ]
		ifFalse: [ fancyNotebookPage hide ].
		
	"if we don't do this, the width of the page will not be applied in the layout"
	self update
]

{ #category : 'initialization' }
CMSimulationPresenter >> initializeFancyNotebook [
		
	| pages selectedPage |
	
	pages := (Pragma allNamed: #fancyNotebookPage in: self class) collect: [ :pragma |
		self perform: pragma methodSelector ].
	
	fancyNotebookButtons := pages collect: [ :page |
		self newToggleButton
			icon: page icon;
			help: page title;
			whenActivatedDo: [ "we keep it here and not in controlPresenters because we need to access page"
				selectedPage := page.
				fancyNotebookPage updatePresenter ];
			whenChangedDo: [ 
				self hideOrShowFancyNotebookPage ] ].
		
	fancyNotebookButtons size > 1 ifTrue: [ 
		fancyNotebookButtons first associatedToggleButtons: fancyNotebookButtons allButFirst ].
		
	fancyNotebookPage := self newPresenterSelector.
	
	pages do: [ :page | fancyNotebookPage
		when: [ selectedPage = page ]
		show: [ page retrievePresenter ] ].

	fancyNotebookPage
		defaultShow: [ self newLabel label: 'Choose one!' ];
		"update presenter is needed to make sure the presenter will have correct initial 
		 value (before anything happens)"
		updatePresenter.
]

{ #category : 'initialization' }
CMSimulationPresenter >> initializePresenters [
	
	modelClass initializeParameters.
	
	self initializeFancyNotebook.

	simulationRunner := self
		instantiate: CMSimulationRunnerPresenter
		on: translator.
		
	fancyNotebookButtons ifNotEmpty: [ fancyNotebookButtons first click ]
]

{ #category : 'instance creation' }
CMSimulationPresenter >> initializeSimulationInit: anInitSelector control: aControlSelector [
"Purpose: instanciate a new modelClass with init & control selectors. Then initialize this simulation by performing #activeInitSelector.
Reset the currentTimeStep and the data. Set the randomSeed"
	simulation := CMSimulation for: modelClass.

	modelClass parameters do: [ :parameter |
		simulation initialParameterValues at: parameter put: parameter value ].

	simulation
		activeInitSelector: anInitSelector;
		activeControlSelector: aControlSelector.
		
	self finalTimeStep ifNotNil: [ :number | simulation finalTimeStep: number ].
	
	"modelInitializationSettings isFixRandomSeed ifTrue: [ 
		simulation randomSeed: modelInitializationSettings randomSeed.
		simulation shouldReleaseRandomSeedAfterInitialization:
			modelInitializationSettings isReleaseRandomSeedAfterInitialization ]."
		
	simulation initializeSimulation.
	simulationRunner simulation: simulation
]

{ #category : 'initialization' }
CMSimulationPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.

	aWindowPresenter 
		title: (modelClass modelName, ' - Simulation');
		initialExtent: 1000@600;
		whenResizingDo: [ simulationRunner fitDiagram ].
]

{ #category : 'accessing - model' }
CMSimulationPresenter >> setModelBeforeInitialization: aCollection [

	modelClass := aCollection first.
	translator := aCollection second
]

{ #category : 'as yet unclassified' }
CMSimulationPresenter >> settingsSimulationInitializer [
	<fancyNotebookPage>
	
	^ SpNotebookPage
		title: 'Initialize simulation'
		icon: (self iconNamed: #smallNew)
		provider: [ (self
			instantiate: CMSimulationInitializerPresenter
			on: { modelClass . translator })
			whenInitializeButtonClickedDo: [ :initSelector :controlSelector |
				self initializeSimulationInit: initSelector control: controlSelector ] ]
]
