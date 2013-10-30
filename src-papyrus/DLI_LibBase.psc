scriptname DLI_LibBase extends DLI_PeerBase

import Math

; PROPERTIES --------------------------------------------------------------------------------------

DLI_LibBase property	MasterInstance auto
bool property			IsReady auto


; INITIALIZATION ----------------------------------------------------------------------------------

; @override DLI_PeerBase
function OnInit()
	parent.OnInit()
endFunction

event OnGameReload(bool a_isOnInit)
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

function SetMaster(string a_libName, DLI_LibBase a_newMaster)
	; Not our library?
	if (a_libName != GetLibraryName())
		return
	endIf

	; Nothing changed?
	if (MasterInstance == a_newMaster)
		return
	endIf

	if (MasterInstance == self)
		MigrateData(a_newMaster)
	endIf

	MasterInstance = a_newMaster
endFunction

int function CalcLibraryRank(string a_name)
	if (a_name != GetLibraryName())
		return -1
	endIf
	
	int myIndex = RightShift(GetFormID(), 24)
	return LogicalOr(LeftShift(GetLibraryVersion(), 8), myIndex)
endFunction