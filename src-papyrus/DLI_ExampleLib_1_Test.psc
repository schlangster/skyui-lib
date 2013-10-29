scriptname DLI_ExampleLib_1_Test extends Quest

DLI_ExampleLib_1	property  ExampleLib_1		auto

bool _show = false

event OnInit()
	RegisterForSingleUpdate(5)
endEvent

event OnUpdate()
	if (_show)
		ExampleLib_1.ShowForms()
	else
		_show = true
		ExampleLib_1.InsertForm(self)
	endIf

	RegisterForSingleUpdate(5)
endEvent
