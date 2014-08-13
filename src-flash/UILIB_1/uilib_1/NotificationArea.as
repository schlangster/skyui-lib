import skyui.util.GlobalFunctions;
import skyui.util.Translator;

import uilib_1.Messages;

class uilib_1.NotificationArea extends MovieClip
{
  /* CONSTANTS */
	
	public static var UILIB_VERSION: Number = 1;

  /* STAGE ELEMENTS */
  
	public var messageHolder: Messages;

  /* PRIVATE VARIABLES */

	private var myMaster_: Object = null;
	private var isActive_: Boolean = false;
	private var rootPath_: String = "";

  /* INITIALIZATION */
	
	public function NotificationArea()
	{
		super();
		GlobalFunctions.addArrayFunctions();
	}
	
  /* PAPYRUS INTERFACE */
  
	public function SetRootPath(a_path: String): Void
	{
		rootPath_ = a_path;
	}
	
	public function ShowMessage(a_message: String, a_color: String): Void
	{
		if (myMaster_ != null) {
			myMaster_.ShowMessage(a_message, a_color);
			return;
		}
		
		var translated = Translator.translateNested(a_message);
		var msgData = {text: "<font color='" + a_color + "'>" + translated + "</font>"};
		messageHolder.MessageArray.push(msgData);
	}
	
	public function ShowIconMessage(a_message: String, a_color: String, a_iconPath: String, a_iconFrame: Number): Void
	{
		if (myMaster_ != null) {
			myMaster_.ShowMessage(a_message, a_color, a_iconPath, a_iconFrame);
			return;
		}
		
		// Account for exported/
		a_iconPath = rootPath_ + a_iconPath;
		
		var translated = Translator.translateNested(a_message);
		var msgData = {text: "<font color='" + a_color + "'>" + translated + "</font>", iconPath: a_iconPath, iconFrame: a_iconFrame};
		messageHolder.MessageArray.push(msgData);
	}
	
  /* PUBLIC FUNCTIONS */
  
	public function GetVersion(): Number
	{
		return UILIB_VERSION;
	}
	
	public function ForwardTo(master: Object): Void
	{
		myMaster_ = master;
		
		// Disable message holder of this notification area.
		// Messages will be displayed by master instead.
		if (isActive_)
		{
			isActive_ = false;
			
			var hudMovie = _root.HUDMovieBaseInstance;
			var hudElements = hudMovie.HudElements;
			
			var idx = hudElements.indexOf(messageHolder);
			if (idx != undefined)
			{
				hudElements.splice(idx,1);
			}
			messageHolder._visible = false;
		}
	}

	public function onLoad(): Void
	{
		var curMaster = _root.UILIB_MASTER_INSTANCE;

		if (curMaster != null) {
			var curVersion = curMaster.GetVersion();
			
			if (curVersion < UILIB_VERSION) {
				_root.UILIB_MASTER_INSTANCE = this;
				curMaster.ForwardTo(this);				
			} else {
				this.ForwardTo(curMaster);
			}
		} else {
			_root.UILIB_MASTER_INSTANCE = this;
		}
		
		// No need to hook anything if the master is already doing it
		if (myMaster_ == null)
			InitHook();
	}
	
	public function InitHook(): Void
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
		
		isActive_ = true;
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