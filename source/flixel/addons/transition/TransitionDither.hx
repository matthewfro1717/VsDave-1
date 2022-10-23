package flixel.addons.transition;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

class TransitionDither extends TransitionEffect
{
   public function new(data:TransitionData)
   {
      //ain't doing anything on this until there's an actual dither shader that works lol
      super(data);

      var ugh:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(new BitmapData(FlxG.width * 2, FlxG.width * 2, false, FlxColor.BLACK)));
      ugh.screenCenter();
      add(ugh);
   }
}