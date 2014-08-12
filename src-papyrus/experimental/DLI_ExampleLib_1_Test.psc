scriptname DLI_ExampleLib_1_Test extends Quest

DLI_ExampleLib_1	property  ExampleLib_1		auto

event OnInit()
	RegisterForSingleUpdate(1)
endEvent

event OnUpdate()
	ExampleLib_1.InsertForm(self)
endEvent
