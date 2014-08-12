scriptname UILIB_1_TestClient extends Quest

UILIB_1	property  UILib1		auto

event OnInit()
	RegisterForUpdate(5)
endEvent

event OnUpdate()
	UILib1.Notification("Normal Message")
	UILib1.Notification("Color #123456", "#123456")
	UILib1.NotificationIcon("Icon Message", "uilib/icon.swf")
endEvent
