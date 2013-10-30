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
	UILIB_1 master = GetMasterInstance() as UILIB_1
	if (master)
		master.NotificationImpl(msg)
	endIf
endFunction

function NotificationImpl(string msg)
	if (PrepareNotificationArea())
		UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.notificationArea.ShowMessage", msg)
	endIf
endFunction

; Injects a new notification area SWF into the HUDMenu at runtime.
; The loaded SWF will then hook ShowMessage and Update to intercept messages of the default message area.
bool function PrepareNotificationArea()

	; Already injected?
	int releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib.NotificationArea.UILIB_VERSION")
	if (releaseIdx > 0)
		return true
	endIf

	; Create empty container clip
	int handle = UICallback.Create(HUD_MENU, "_root.HUDMovieBaseInstance.createEmptyMovieClip")
	if (!handle)
		return false
	endIf

	UICallback.PushString(handle, "notificationAreaContainer")
	UICallback.PushInt(handle, -16380)
	if (! UICallback.Send(handle))
		return false
	endIf

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
		Debug.Trace("PrepareNotificationArea() failed")
		return false
	endIf

	return true
endFunction