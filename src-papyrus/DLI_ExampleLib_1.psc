scriptname DLI_ExampleLib_1 extends DLI_LibBase

; LIBRARY INFO ------------------------------------------------------------------------------------

; @override DLI_LibBase
string function GetLibraryName()
	return "Example Library"
endFunction

; @override DLI_LibBase
int function GetLibraryVersion()
	return 1
endFunction


; PROPERTIES --------------------------------------------------------------------------------------

Form[] property	RegisteredForms auto
int property	RegistrationCount auto


; FUNCTIONS ---------------------------------------------------------------------------------------

; @override DLI_PeerBase
function OnInit()
	parent.OnInit()
	RegistrationCount = 0
	RegisteredForms = new Form[1]
	; RegisteredForms is properly initialized lazily
endFunction

; @interface
function InsertForm(Form a_form)
	if (MasterInstance)
		(MasterInstance as DLI_ExampleLib_1).InsertFormImpl(a_form)
	endIf
endFunction

; @interface
function ShowForms()
	if (MasterInstance)
		(MasterInstance as DLI_ExampleLib_1).ShowFormsImpl()
	endIf
endFunction

function InsertFormImpl(Form a_form)
	Lock()

	if (RegisteredForms.length == 1)
		RegisteredForms = new Form[128]
	endIf

	RegisteredForms[RegistrationCount] = a_form
	RegistrationCount += 1

	Debug.Trace(GetPeerId() + "> LIB1: Inserted " + a_form)

	Unlock()
endFunction

function ShowFormsImpl()
	Lock()

	int i = 0
	while (i<RegistrationCount)
		Debug.Trace(GetPeerId() + "> LIB1: " + i + " => " + RegisteredForms[i])
		i += 1
	endWhile

	Unlock()
endFunction

; @override DLI_LibBase
function MigrateData(DLI_LibBase a_newMaster)
	parent.MigrateData(a_newMaster)

	DLI_ExampleLib_1 target = a_newMaster as DLI_ExampleLib_1
	if (target)
		target.RegisteredForms = RegisteredForms
		target.RegistrationCount = RegistrationCount
		; Cleanup old state
		RegisteredForms = new Form[1]
		RegistrationCount = 0
	endIf
endFunction

; -------

bool _lock

function Lock()
	while (TryLock())
		Utility.Wait(0.5)
	endWhile
endFunction
 
bool function TryLock()
	if (_lock)
		return false
	endIf
	_lock = true
 
	return true
endFunction
 
function Unlock()
	_Lock = false
endFunction