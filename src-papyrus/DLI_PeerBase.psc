scriptname DLI_PeerBase extends Quest

import Math

; debug -------

string function Dump()
	if (DLI_Successor)
		return DLI_GetPeerId() + " -> " + DLI_Successor.Dump()
	else
		return DLI_GetPeerId() + " -> []"
	endIf
endFunction


; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool	_attemptedAttach
int		_silenceCounter

int		_partitionIndex
int		_partitionCount


; PROPERTIES --------------------------------------------------------------------------------------

DLI_PeerBase property	DLI_Successor auto

DLI_PeerBase property	DLI_Head auto
DLI_PeerBase property	DLI_Tail auto

bool property			DLI_Invalidated auto


; INITIALIZATION ----------------------------------------------------------------------------------

function OnInit()
	OnGameReload(true)
endFunction

event OnGameReload(bool a_isOnInit)
	DLI_Head = self
	DLI_Tail = self

	DLI_Successor = none
	_attemptedAttach = false
	DLI_Invalidated = true

	OnGroupReset(a_isOnInit)

	DLI_UnregisterAll()
	RegisterForModEvent("DLI_L1_join_all", "DLI_OnJoinRequest")

	_partitionIndex = Utility.RandomInt(0, 7)
	_partitionCount = 0

	GotoState("JOIN_PHASE")
	RegisterForSingleUpdate(0.1)
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnInvalidateGroup()
endEvent

; @interface
event OnGroupReset(bool a_isOnInit)	
endEvent

event OnUpdate()
endEvent

event DLI_OnJoinRequest(string a_eventName, Form a_sender)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function DLI_Attach(DLI_PeerBase a_other)
endFunction

function DLI_DoAttach(DLI_PeerBase a_other)
	DLI_Successor = a_other
	DLI_Head = a_other.DLI_Head
	a_other.DLI_Head.DLI_Tail = DLI_Tail
	DLI_Tail.DLI_Head = a_other.DLI_Head

	DLI_Head.DLI_Invalidated = true
endFunction

function DLI_UnregisterAll()
	UnregisterForModEvent("DLI_L1_join_0")
	UnregisterForModEvent("DLI_L1_join_1")
	UnregisterForModEvent("DLI_L1_join_2")
	UnregisterForModEvent("DLI_L1_join_3")
	UnregisterForModEvent("DLI_L1_join_4")
	UnregisterForModEvent("DLI_L1_join_5")
	UnregisterForModEvent("DLI_L1_join_6")
	UnregisterForModEvent("DLI_L1_join_7")
	UnregisterForModEvent("DLI_L1_join_all")
endFunction

function DLI_SendJoinRequest()
	if (_partitionCount == 8)
		int handle = ModEvent.Create(self, "DLI_L1_join_all")
		if (handle)
			ModEvent.Send(handle)
		endIf
	else
		RegisterForModEvent("DLI_L1_join_" + _partitionIndex, "DLI_OnJoinRequest")

		int joinIndex =  (_partitionIndex + 4) % 8
		_partitionIndex = (_partitionIndex + 1) % 8

		int handle = ModEvent.Create(self, "DLI_L1_join_" + joinIndex)
		if (handle)
			ModEvent.Send(handle)
		endIf

		_partitionCount += 1
	endIf
endFunction

string function	DLI_GetPeerId()
	return "Peer" + Math.RightShift(GetFormID(), 24)
endFunction


; JOIN_PHASE STATE --------------------------------------------------------------------------------

state JOIN_PHASE

	event OnUpdate()
		if (_attemptedAttach)
			_attemptedAttach = false
			_silenceCounter = 0
		elseIf (_silenceCounter < 16)
			_silenceCounter += 1
		endIf

		if (_silenceCounter < 16)
			DLI_SendJoinRequest()
			RegisterForSingleUpdate(0.1)
		else
			Debug.Trace(DLI_GetPeerId() + " : I think im alone now")
			RegisterForSingleUpdate(5)

			if (DLI_Invalidated)
				;Debug.Trace("Invalidate started by " + DLI_GetPeerId() + " : " + DLI_Tail.Dump())
				DLI_Invalidated = false

				GotoState("BUSY")
				OnInvalidateGroup()

				GotoState("JOIN_PHASE")
			endIf
		endIf
	endEvent

	event DLI_OnJoinRequest(string a_eventName, Form a_sender)
		GotoState("BUSY")

		DLI_PeerBase other = a_sender as DLI_PeerBase

		if (DLI_Head == self && self != other)
			_attemptedAttach = true
			other.DLI_Attach(DLI_Tail)
		endIf

		gotoState("JOIN_PHASE")
	endEvent

	function DLI_Attach(DLI_PeerBase a_other)
		gotoState("")
		DLI_DoAttach(a_other)
		DLI_UnregisterAll()
	endFunction

endState


; BUSY STATE --------------------------------------------------------------------------------------

state BUSY

	event OnUpdate()
		RegisterForSingleUpdate(0.2)
	endEvent

	event DLI_OnJoinRequest(string a_eventName, Form a_sender)
	endEvent

	function DLI_Attach(DLI_PeerBase a_other)
	endFunction

endState