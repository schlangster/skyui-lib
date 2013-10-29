scriptname DLI_PeerBase extends Quest

import Math

; debug -------

string function Dump()
	if (Successor)
		return GetPeerId() + " -> " + Successor.Dump()
	else
		return GetPeerId() + " -> []"
	endIf
endFunction


; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool	_attemptedAttach
int		_silenceCounter

int		_partitionIndex
int		_partitionCount


; PROPERTIES --------------------------------------------------------------------------------------

DLI_PeerBase property	Successor auto

DLI_PeerBase property	Head auto
DLI_PeerBase property	Tail auto

bool property			Invalidated auto


; INITIALIZATION ----------------------------------------------------------------------------------

function OnInit()
	OnGameReload(true)
endFunction

event OnGameReload(bool a_isOnInit)
	Head = self
	Tail = self

	Successor = none
	_attemptedAttach = false
	Invalidated = true

	OnGroupReset(a_isOnInit)

	UnregisterAll()
	RegisterForModEvent("DLI_L1_join_all", "OnJoinRequest")

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

event OnJoinRequest(string a_eventName, Form a_sender)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Attach(DLI_PeerBase a_other)
endFunction

function DoAttach(DLI_PeerBase a_other)
	Successor = a_other
	Head = a_other.Head
	a_other.Head.Tail = Tail
	Tail.Head = a_other.Head

	Head.Invalidated = true
endFunction

function UnregisterAll()
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

function SendJoinRequest()
	if (_partitionCount == 8)
		int handle = ModEvent.Create(self, "DLI_L1_join_all")
		if (handle)
			ModEvent.Send(handle)
		endIf
	else
		RegisterForModEvent("DLI_L1_join_" + _partitionIndex, "OnJoinRequest")

		int joinIndex =  (_partitionIndex + 4) % 8
		_partitionIndex = (_partitionIndex + 1) % 8

		int handle = ModEvent.Create(self, "DLI_L1_join_" + joinIndex)
		if (handle)
			ModEvent.Send(handle)
		endIf

		_partitionCount += 1
	endIf
endFunction

string function	GetPeerId()
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
			SendJoinRequest()
			RegisterForSingleUpdate(0.1)
		else
			Debug.Trace(GetPeerId() + " : I think im alone now")
			RegisterForSingleUpdate(5)

			if (Invalidated)
				Debug.Trace("Invalidate started by " + GetPeerId() + " : " + Tail.Dump())
				Invalidated = false

				GotoState("BUSY")
				OnInvalidateGroup()

				Message m = Game.GetForm(0x0000017E) as Message
				RegisterForMenu("MessageBoxMenu")
				m.Show()

				;int handle = UICallback.Create("HUD Menu", "_global.skse.OpenMenu")
				;if (handle)
				;	UICallback.PushString(handle, "TweenMenu")
				;	UICallback.Send(handle)
				;endIf

				GotoState("JOIN_PHASE")
			endIf
		endIf
	endEvent

	event OnJoinRequest(string a_eventName, Form a_sender)
		GotoState("BUSY")

		DLI_PeerBase other = a_sender as DLI_PeerBase

		if (head == self && self != other)
			_attemptedAttach = true
			other.Attach(tail)
		endIf

		gotoState("JOIN_PHASE")
	endEvent

	function Attach(DLI_PeerBase a_other)
		gotoState("")
		DoAttach(a_other)
		UnregisterAll()
	endFunction

endState

event OnMenuOpen(string a_menuName)
	UnregisterForMenu("MessageBoxMenu")
	UI.SetBool("MessageBoxMenu", "_root.MessageMenu._visible", false)
endEvent


; BUSY STATE --------------------------------------------------------------------------------------

state BUSY

	event OnUpdate()
		RegisterForSingleUpdate(0.2)
	endEvent

	event OnJoinRequest(string a_eventName, Form a_sender)
	endEvent

	function Attach(DLI_PeerBase a_other)
	endFunction

endState