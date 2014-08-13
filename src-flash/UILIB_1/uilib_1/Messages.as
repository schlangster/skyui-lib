class uilib_1.Messages extends MovieClip
{
  /* CONSTANTS */
  
	public static var MAX_SHOWN: Number = 15;
	public static var Y_SPACING: Number = 15;
	public static var END_ANIM_FRAME: Number = 80;
	
	public static var InstanceCounter: Number = 0;
	
	var MessageArray: Array;
	var ShownCount: Number;
	var ShownMessageArray: Array;
	var bAnimating: Boolean;
	var ySpacing: Number;

  /* INITIALIZATION */

	public function Messages()
	{
		super();
		
		MessageArray = new Array();
		ShownMessageArray = new Array();
		ShownCount = 0;
		bAnimating = false;
	}
	
  /* PUBLIC FUNCTIONS */

	public function Update(): Void
	{
		var bQueuedMessage = MessageArray.length > 0;
		
		if (bQueuedMessage && !bAnimating && ShownCount < MAX_SHOWN)
		{
			var msgData = MessageArray.shift();
			
			var msgClip = attachMovie("MessageText", "Text" + InstanceCounter++, getNextHighestDepth(), {_x: 0, _y: 0});
			ShownMessageArray.push(msgClip);
			
			msgClip.TextFieldClip.tf1.html = true;
			msgClip.TextFieldClip.tf1.textAutoSize = "shrink";
			msgClip.TextFieldClip.tf1.htmlText = msgData.text;
			
			if (msgData.iconPath)
			{
				msgClip.TextFieldClip.tf1._x = 26; // Adjust text position
				
				var iconLoader = new MovieClipLoader();
				iconLoader.addListener(msgClip);
				iconLoader.loadClip(msgData.iconPath, msgClip.TextFieldClip.iconHolder);
				
				if (msgData.iconFrame)
				{
					msgClip.iconFrame = msgData.iconFrame;
					msgClip.onLoadInit = function(a_icon: MovieClip)
					{
						a_icon.gotoAndStop(this.iconFrame);
					};
				}
			}
			else
			{
				msgClip.TextFieldClip.iconHolder._visible = false;
			}
			
			bAnimating = true;
			ySpacing = 0;
			
			onEnterFrame = function (): Void
			{
				if (ySpacing < Y_SPACING)
				{
					for (var i=0; i < ShownMessageArray.length - 1; i++)
					{
						ShownMessageArray[i]._y = ShownMessageArray[i]._y + 2;
					}
					++ySpacing;
					return;
				}
				bAnimating = false;
				if (!bQueuedMessage || ShownCount == MAX_SHOWN) 
					ShownMessageArray[0].gotoAndPlay("FadeOut");
				delete onEnterFrame;
			};
			++ShownCount;
		}
		for (var i=0; i<ShownMessageArray.length; i++)
		{
			if (ShownMessageArray[i]._currentFrame >= END_ANIM_FRAME)
			{
				var aShownMessageArray: Array = ShownMessageArray.splice(i, 1);
				aShownMessageArray[0].removeMovieClip();
				--ShownCount;
				bAnimating = false;
			}
		}
		if (!bQueuedMessage && !bAnimating && ShownMessageArray.length > 0)
		{
			bAnimating = true;
			ShownMessageArray[0].gotoAndPlay("FadeOut");
		}
	}

}
