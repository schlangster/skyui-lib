import skyui.util.GlobalFunctions;
import uilib.Messages;

class uilib.NotificationArea extends MovieClip
{
  /* CONSTANTS */
	
	public static var UILIB_VERSION: Number = 1;
  

  /* STAGE ELEMENTS */
  
	public var messageHolder: Messages;
	

  /* INITIALIZATION */
	
	public function NotificationArea()
	{
		super();
		GlobalFunctions.addArrayFunctions();
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function onLoad(): Void
	{
		var hudMovie = _root.HUDMovieBaseInstance;
		var hudElements = hudMovie.HudElements;
		var oldMessagesBlock = hudMovie.MessagesBlock;
		
		// Place it next to the original messages block
		messageHolder._x = oldMessagesBlock._x + 100;
		messageHolder._y = oldMessagesBlock._y + 100;
		
		hudElements.push(messageHolder);
		
		// Set visiblity of new message holder
		messageHolder.All = true;
		messageHolder.Favor = true;
		messageHolder.InventoryMode = true;
		messageHolder.TweenMode = true;
		messageHolder.BookMode = true;
		messageHolder.DialogueMode = true;
		messageHolder.BarterMode = true;
		messageHolder.WorldMapMode = true;
		messageHolder.MovementDisabled = true;
		messageHolder.StealthMode = true;
		messageHolder.Swimming = true;
		messageHolder.HorseMode = true;
		messageHolder.WarHorseMode = true;
		messageHolder.CartMode = true;
		
		var hudMode: String = hudMovie.HUDModes[hudMovie.HUDModes.length - 1];
		messageHolder._visible = messageHolder.hasOwnProperty(hudMode);
		
		GlobalFunctions.hookFunction(hudMovie, "ShowMessage", this, "Hook_ShowMessage");
		GlobalFunctions.hookFunction(hudMovie.MessagesInstance, "Update", this, "Hook_Update");
		
		var idx = hudElements.indexOf(oldMessagesBlock);
		if (idx != undefined) {
			hudElements.splice(idx,1);
		}
		oldMessagesBlock._visible = false;
	}
	
	function ShowMessage(asMessage: String): Void
	{
		messageHolder.MessageArray.push(asMessage);
	}
	
	function Hook_ShowMessage(asMessage: String): Void
	{
		messageHolder.MessageArray.push("Hooked: " + asMessage);
	}
	
	function Hook_Update(): Void
	{
		messageHolder.Update();
	}
}