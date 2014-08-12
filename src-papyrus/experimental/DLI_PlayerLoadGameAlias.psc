scriptname DLI_PlayerLoadGameAlias extends ReferenceAlias

 ; EVENTS -----------------------------------------------------------------------------------------

event OnPlayerLoadGame()
	(GetOwningQuest() as DLI_PeerBase).OnGameReload(false)
endEvent
