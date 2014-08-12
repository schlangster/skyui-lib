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
function Notification(string a_message, string a_color = "#FFFFFF")
	UILIB_1 master = GetMasterInstance() as UILIB_1
	if (master)
		master.NotificationImpl(a_message, a_color)
	endIf
endFunction

; @interface
function NotificationIcon(string a_message, string a_iconPath, int a_iconFrame = 0, string a_color = "#FFFFFF")
	UILIB_1 master = GetMasterInstance() as UILIB_1
	if (master)
		master.NotificationIconImpl(a_message, a_iconPath, a_iconFrame, a_color)
	endIf
endFunction

function NotificationImpl(string a_message, string a_color)
	if (! PrepareNotificationArea())
		return
	endIf
	
	int handle = UICallback.Create(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.notificationArea.ShowMessage")
	if (handle)
		UICallback.PushString(handle, a_message)
		UICallback.PushString(handle, a_color)
		UICallback.Send(handle)
	endIf
endFunction

function NotificationIconImpl(string a_message, string a_iconPath, int a_iconFrame, string a_color)
	if (! PrepareNotificationArea())
		return
	endIf
	
	int handle = UICallback.Create(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.notificationArea.ShowIconMessage")
	if (handle)
		UICallback.PushString(handle, a_message)
		UICallback.PushString(handle, a_color)
		UICallback.PushString(handle, a_iconPath)
		UICallback.PushInt(handle, a_iconFrame)
		UICallback.Send(handle)
	endIf

	
	UI.OpenCustomMenu("textentrymenu")
	
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