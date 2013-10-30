scriptname UILIB_1 extends DLI_LibBase

; LIBRARY INFO ------------------------------------------------------------------------------------

; @override DLI_LibBase
string function GetLibraryName()
	return "UILIB"
endFunction

; @override DLI_LibBase
int function GetLibraryVersion()
	return 1
endFunction


; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
function Notification(string msg)
	UILIB_1 target = MasterInstance as UILIB_1
	if (target)
		target.NotificationImpl(msg)
	endIf
endFunction

function NotificationImpl(string msg)
	if (InitNotificationArea())
		UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.notificationArea.ShowMessage", msg)
	endIf
endFunction

; Injects a new notification area SWF into the HUDMenu at runtime.
; The loaded SWF will then hook ShowMessage and Update to intercept messages of the default message area.
bool function InitNotificationArea()
	int releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib.NotificationArea.UILIB_VERSION")
	if (releaseIdx > 0)
		return true
	endIf

	; Not injected yet

	string[] args = new string[2]
	args[0] = "notificationAreaContainer"
	args[1] = "-16380"
	
	; Create empty container clip
	UI.InvokeStringA(HUD_MENU, "_root.HUDMovieBaseInstance.createEmptyMovieClip", args)

	; Try to load from Interface/exported/hudmenu.gfx
	UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.loadMovie", "uilib/UILIB_1_notificationarea.swf")
	Utility.Wait(0.5)
	releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib.NotificationArea.UILIB_VERSION")

	; If failed, try to load from Interface/hudmenu.swf
	if (releaseIdx == 0)
		UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.loadMovie", "exported/uilib/UILIB_1_notificationarea.swf")	
		Utility.Wait(0.5)
		releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib.NotificationArea.UILIB_VERSION")
	endIf

	; Injection failed
	if (releaseIdx == 0)
		Debug.Trace("InitNotificationArea() failed")
		return false
	endIf

	return true
endFunction