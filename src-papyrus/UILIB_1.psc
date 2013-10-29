scriptname UILIB_2 extends UILIB_1

; SCRIPT VERSION ----------------------------------------------------------------------------------

int function GetVersion()
	return 2
endFunction


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
function Notification(string msg)
	if (Ready)
		(Master as UILIB_2).NotificationImpl_2(msg, "#FF00FF")
	endIf
endFunction

; @interface
function Notification_2(string msg, string color)
	if (Ready)
		(Master as UILIB_2).NotificationImpl_2(msg, color)
	endIf
endFunction

function NotificationImpl(string msg)
	NotificationImpl_2(msg, "#FF00FF")
endFunction

function NotificationImpl_2(string msg, string color)
	Debug.Trace(self + " UILIB_2 : " + msg)

	if (InitNotificationArea())
		UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.notificationArea.ShowMessage", "<font color='" + color + "'>" + msg + "</font>")
	endIf
endFunction

; Injects a new notification area SWF into the HUDMenu at runtime.
; The loaded SWF will then hook ShowMessage and Update to intercept messages of the default message area.
bool function InitNotificationArea()
	int releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib_1.NotificationArea.UILIB_VERSION")
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
	releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib_1.NotificationArea.UILIB_VERSION")

	; If failed, try to load from Interface/hudmenu.swf
	if (releaseIdx == 0)
		UI.InvokeString(HUD_MENU, "_root.HUDMovieBaseInstance.notificationAreaContainer.loadMovie", "exported/uilib/UILIB_1_notificationarea.swf")	
		Utility.Wait(0.5)
		releaseIdx = UI.GetInt(HUD_MENU, "_global.uilib_1.NotificationArea.UILIB_VERSION")
	endIf

	; Injection failed
	if (releaseIdx == 0)
		Debug.Trace("InitNotificationArea() failed")
		return false
	endIf

	return true
endFunction