ScriptName UILIB_1 Extends Form
{SkyUILib API - Version 1}

;Private variables
Bool bMenuOpen
String sTitle
String sInitialText
String sInput
String[] sOptions
Int iStartIndex
Int iDefaultIndex
Int iInput

;Text input
Function TextInputMenu_Open(Form akClient) Global
	akClient.RegisterForModEvent("UILIB_1_textInputOpen", "OnTextInputOpen")
	akClient.RegisterForModEvent("UILIB_1_textInputClose", "OnTextInputClose")
	UI.OpenCustomMenu("uilib/uilib_1_textinputmenu")
EndFunction

Function TextInputMenu_SetData(String asTitle = "", String asInitialText = "") Global
	UI.InvokeNumber("CustomMenu", "_root.textInputDialog.setPlatform", (Game.UsingGamepad() as Int))
	String[] sData = new String[2]
	sData[0] = asTitle
	sData[1] = asInitialText
	UI.InvokeStringA("CustomMenu", "_root.textInputDialog.initData", sData)
EndFunction

Function TextInputMenu_Release(Form akClient) Global
	akClient.UnregisterForModEvent("UILIB_1_textInputOpen")
	akClient.UnregisterForModEvent("UILIB_1_textInputClose")
EndFunction

String Function ShowTextInput(String asTitle = "", String asInitialText = "")
	If(bMenuOpen)
		Return ""
	EndIf
	bMenuOpen = True
	sInput = ""
	sTitle = asTitle
	sInitialText = asInitialText
	TextInputMenu_Open(Self)
	While(bMenuOpen)
		Utility.WaitMenuMode(0.1)
	EndWhile
	TextInputMenu_Release(Self)
	Return sInput
EndFunction

Event OnTextInputOpen(String asEventName, String asStringArg, Float afNumArg, Form akSender)
	If(asEventName == "UILIB_1_textInputOpen")
		TextInputMenu_SetData(sTitle, sInitialText)
	EndIf
EndEvent

Event OnTextInputClose(String asEventName, String asInput, Float afCancelled, Form akSender)
	If(asEventName == "UILIB_1_textInputClose")
		If(afCancelled as Bool)
			sInput = ""
		Else
			sInput = asInput
		EndIf
		bMenuOpen = False
	EndIf
EndEvent

;List
Function ListMenu_Open(Form akClient) Global
	akClient.RegisterForModEvent("UILIB_1_listMenuOpen", "OnListMenuOpen")
	akClient.RegisterForModEvent("UILIB_1_listMenuClose", "OnListMenuClose")
	UI.OpenCustomMenu("uilib/uilib_1_listmenu")
EndFunction

Function ListMenu_SetData(String asTitle = "", String[] asOptions, Int aiStartIndex, Int aiDefaultIndex) Global
	UI.InvokeNumber("CustomMenu", "_root.listDialog.setPlatform", (Game.UsingGamepad() as Int))
	UI.InvokeStringA("CustomMenu", "_root.listDialog.initListData", asOptions)
	Int iHandle = UICallback.Create("CustomMenu", "_root.listDialog.initListParams")
	If(iHandle)
		UICallback.PushString(iHandle, asTitle)
		UICallback.PushInt(iHandle, aiStartIndex)
		UICallback.PushInt(iHandle, aiDefaultIndex)
		UICallback.Send(iHandle)
	EndIf
EndFunction

Function ListMenu_Release(Form akClient) Global
	akClient.UnregisterForModEvent("UILIB_1_listMenuOpen")
	akClient.UnregisterForModEvent("UILIB_1_listMenuClose")
EndFunction

Int Function ShowList(String asTitle = "", String[] asOptions, Int aiStartIndex, Int aiDefaultIndex)
	If(bMenuOpen)
		Return -1
	EndIf
	bMenuOpen = True
	iInput = -1
	sTitle = asTitle
	sOptions = asOptions
	iStartIndex = aiStartIndex
	iDefaultIndex = aiDefaultIndex
	ListMenu_Open(Self)
	While(bMenuOpen)
		Utility.WaitMenuMode(0.1)
	EndWhile
	ListMenu_Release(Self)
	Return iInput
EndFunction

Event OnListMenuOpen(String asEventName, String asStringArg, Float afNumArg, Form akSender)
	If(asEventName == "UILIB_1_listMenuOpen")
		ListMenu_SetData(sTitle, sOptions, iStartIndex, iDefaultIndex)
	EndIf
EndEvent

Event OnListMenuClose(String asEventName, String asStringArg, Float afInput, Form akSender)
	If(asEventName == "UILIB_1_listMenuClose")
		iInput = afInput as Int
		bMenuOpen = False
	EndIf
EndEvent

;Notification
Function ShowNotification(String asMessage, String asColor = "#FFFFFF")
	If(!NotificationMenu_PrepareArea())
		Return
	EndIf
	Int iHandle = UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.uilib_1_notificationAreaContainer.notificationArea.ShowMessage")
	If(iHandle)
		UICallback.PushString(iHandle, asMessage)
		UICallback.PushString(iHandle, asColor)
		UICallback.Send(iHandle)
	EndIf
EndFunction

Function ShowNotificationIcon(String asMessage, String asIconPath, Int aiIconFrame = 0, String asColor = "#FFFFFF")
	If(!NotificationMenu_PrepareArea())
		Return
	EndIf
	Int iHandle = UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.uilib_1_notificationAreaContainer.notificationArea.ShowIconMessage")
	If(iHandle)
		UICallback.PushString(iHandle, asMessage)
		UICallback.PushString(iHandle, asColor)
		UICallback.PushString(iHandle, asIconPath)
		UICallback.PushInt(iHandle, aiIconFrame)
		UICallback.Send(iHandle)
	EndIf
EndFunction

Bool Function NotificationMenu_PrepareArea() global
	Int iVersion = UI.GetInt("HUD Menu", "_global.uilib_1.NotificationArea.UILIB_VERSION")
	If(iVersion == 0)
		Int iHandle = UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.createEmptyMovieClip")
		If(!iHandle)
			Return False
		EndIf
		UICallback.PushString(iHandle, "uilib_1_notificationAreaContainer")
		UICallback.PushInt(iHandle, -16380)
		If(!UICallback.Send(iHandle))
			Return False
		EndIf
		UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.uilib_1_notificationAreaContainer.loadMovie", "uilib/uilib_1_notificationarea.swf")
		Utility.Wait(0.5)
		iVersion = UI.GetInt("HUD Menu", "_global.uilib_1.NotificationArea.UILIB_VERSION")
		If(iVersion == 0)
			UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.uilib_1_notificationAreaContainer.loadMovie", "exported/uilib/uilib_1_notificationarea.swf")
			Utility.Wait(0.5)
			iVersion = UI.GetInt("HUD Menu", "_global.uilib_1.NotificationArea.UILIB_VERSION")

			If(iVersion == 0)
				Debug.Trace("===== UILib: Notification injection failed =====")
				Return False
			EndIf

			UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.uilib_1_notificationAreaContainer.SetRootPath", "exported/")
		EndIf
	EndIf
	Return True
EndFunction
