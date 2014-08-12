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
	RegistrationCount = 0
	RegisteredForms = new Form[128]

	parent.OnInit()
endFunction

; @interface
function InsertForm(Form a_form)
	DLI_ExampleLib_1 master = GetMasterInstance() as DLI_ExampleLib_1
	if (master)
		master.InsertFormImpl(a_form)
	endIf
endFunction

function InsertFormImpl(Form a_form)
	Lock()

	if (RegistrationCount < 128)
		int index = RegistrationCount
		RegisteredForms[index] = a_form
		RegistrationCount += 1
		Debug.Trace(DLI_GetPeerId() + "> InsertForm: (" + index + ") -> " + a_form)
	else
		Debug.Trace(DLI_GetPeerId() + "> InsertForm: LIST IS FULL")
	endIf

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
		RegisteredForms = new Form[128]
		RegistrationCount = 0
	endIf
endFunction

; -------

bool _lock

function Lock()
	while (! TryLock())
		Utility.Wait(0.1)
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
	_lock = false
endFunction