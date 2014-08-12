import skyui.util.GlobalFunctions;
import skyui.util.Translator;

import uilib_1.Messages;

class uilib_1.NotificationArea extends MovieClip
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
	
  /* PAPYRUS INTERFACE */
	
	public function ShowMessage(a_message: String, a_color: String): Void
	{
		var translated = Translator.translateNested(a_message);
		var msgData = {text: "<font color='" + a_color + "'>" + translated + "</font>"};
		messageHolder.MessageArray.push(msgData);
	}
	
	public function ShowIconMessage(a_message: String, a_color: String, a_iconPath: String, a_iconFrame: Number): Void
	{
		var translated = Translator.translateNested(a_message);
		var msgData = {text: "<font color='" + a_color + "'>" + translated + "</font>", iconPath: a_iconPath, iconFrame: a_iconFrame};
		messageHolder.MessageArray.push(msgData);
	}
	
  /* PUBLIC FUNCTIONS */

	public function onLoad(): Void
	{
		var hudMovie = _root.HUDMovieBaseInstance;
		var hudElements = hudMovie.HudElements;
		var oldMessagesBlock = hudMovie.MessagesBlock;
		
		// Place it next to the original messages block
		messageHolder._x = oldMessagesBlock._x;
		messageHolder._y = oldMessagesBlock._y;
		
		hudElements.push(messageHolder);
		
		// Set visiblity of new message holder
		messageHolder["All"] = true;
		messageHolder["Favor"] = true;
		messageHolder["InventoryMode"] = true;
		messageHolder["TweenMode"] = true;
		messageHolder["BookMode"] = true;
		messageHolder["DialogueMode"] = true;
		messageHolder["BarterMode"] = true;
		messageHolder["WorldMapMode"] = true;
		messageHolder["MovementDisabled"] = true;
		messageHolder["StealthMode"] = true;
		messageHolder["Swimming"] = true;
		messageHolder["HorseMode"] = true;
		messageHolder["WarHorseMode"] = true;
		messageHolder["CartMode"] = true;
		
		var hudMode: String = hudMovie.HUDModes[hudMovie.HUDModes.length - 1];
		messageHolder._visible = messageHolder.hasOwnProperty(hudMode);
		
		GlobalFunctions.hookFunction(hudMovie, "ShowMessage", this, "Hook_ShowMessage");
		GlobalFunctions.hookFunction(hudMovie.MessagesInstance, "Update", this, "Hook_Update");
		
		var idx = hudElements.indexOf(oldMessagesBlock);
		if (idx != undefined)
		{
			hudElements.splice(idx,1);
		}
		oldMessagesBlock._visible = false;
	}
	
	function Hook_ShowMessage(a_message: String): Void
	{
		ShowMessage(a_message, "#FFFFFF");
	}
	
	function Hook_Update(): Void
	{
		messageHolder.Update();
	}
	

}