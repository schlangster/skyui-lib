scriptname DLI_LibBase extends DLI_PeerBase

import Math

; PRIVATE VARIABLES -------------------------------------------------------------------------------

DLI_LibBase	_master
bool		_ready




; PROPERTIES --------------------------------------------------------------------------------------

; INITIALIZATION ----------------------------------------------------------------------------------

; @override DLI_PeerBase
function OnInit()
	parent.OnInit()
endFunction

event OnGameReload(bool a_isOnInit)
	_ready = false
	parent.OnGameReload(a_isOnInit)
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @override DLI_PeerBase
event OnInvalidateGroup()	
	Debug.Trace("Starting InvalidateGroup")

	string[]	libNames = new string[128]
	int			libCount = 0

	; Phase 1 - Collect lib names

	DLI_LibBase p = DLI_Tail as DLI_LibBase
	bool continue = true
	while (continue)
		string name = p.GetLibraryName()
		if (name != "" && libNames.Find(name) < 0)
			Debug.Trace("Found library " + name)
			libNames[libCount] = name
			libCount += 1
		endIf

		continue = p != self
		if (continue)
			p = p.DLI_Successor as DLI_LibBase
		endIf
	endWhile

	; Phase 2 - Set master version for each lib

	int i = 0
	while (i < libCount)
		string name = libNames[i]

		; Find master
		DLI_LibBase newMaster = none
		int maxRank = -1

		p = DLI_Tail as DLI_LibBase
		continue = true
		while (continue)
			int rank = p.CalcLibraryRank(name)
			if (maxRank < rank)
				maxRank = rank
				newMaster = p
				Debug.Trace("New max rank library " + newMaster.DLI_GetPeerId() + " " + maxRank)
			endIf

			continue = p != self
			if (continue)
				p = p.DLI_Successor as DLI_LibBase
			endIf
		endWhile

		; Set master
		if (newMaster != none)	
			p = DLI_Tail as DLI_LibBase
			continue = true
			while (continue)
				p.SetMaster(name, newMaster)

				continue = p != self
				if (continue)
					p = p.DLI_Successor as DLI_LibBase
				endIf
			endWhile
		endIf

		Debug.Trace("Updated all masters to " + newMaster.DLI_GetPeerId())

		i += 1
	endWhile
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
string function GetLibraryName()
	return ""
endFunction

; @interface
int function GetLibraryVersion()
	return 0
endFunction

; @interface
function MigrateData(DLI_LibBase a_newMaster)
endFunction

; @interface
DLI_LibBase function GetMasterInstance(bool a_noWait = false)
	if (a_noWait == false)
		AwaitReady()
	endIf

	return _master
endFunction

; @interface
bool function IsReady()
	return _ready
endFunction

; @interface
bool function AwaitReady(int a_timeout = 200)
	if (_ready)
		return true
	endIf

	while (a_timeout > 0 && !_ready)
		a_timeout -= 1
		if (Utility.IsInMenuMode())
			Utility.WaitMenuMode(0.1)
		else
			Utility.Wait(0.1)
		endIf
	endWhile

	return a_timeout > 0
endFunction

function SetMaster(string a_libName, DLI_LibBase a_newMaster)
	; Not our library?
	if (a_libName != GetLibraryName())
		return
	endIf

	_ready = true

	; Nothing changed?
	if (_master == a_newMaster)
		return
	endIf

	if (_master == self)
		MigrateData(a_newMaster)
	endIf

	_master = a_newMaster
endFunction

int function CalcLibraryRank(string a_name)
	if (a_name != GetLibraryName())
		return -1
	endIf
	
	int myIndex = RightShift(GetFormID(), 24)
	return LogicalOr(LeftShift(GetLibraryVersion(), 8), myIndex)
endFunction