package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import mobile.flixel.FlxButton;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import openfl.utils.Assets;

class MobileControlsSubState extends FlxSubState
{
	final controlsItems:Array<String> = [
		'Pad-Right',
		'Pad-Left',
		'Pad-Custom',
		'Pad-Duo',
		'Hitbox',
		'Keyboard',
		'Space-Button'
	];
	var virtualPad:FlxVirtualPad;
	var hitbox:FlxHitbox;
	var upPozition:FlxText;
	var downPozition:FlxText;
	var leftPozition:FlxText;
	var rightPozition:FlxText;
	var spacePozition:FlxText;
	var inputvari:FlxText;
	var funitext:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var curSelected:Int = 0;
	var buttonBinded:Bool = false;

	var bindButton:FlxButton;
	var resetButton:FlxButton;
	var savePositionsButton:FlxButton;

	var bgShader:Shaders.GlitchEffect;
	var awaitingExploitation:Bool;

	override function create()
	{
		for (i in 0...controlsItems.length)
			if (controlsItems[i] == MobileControls.mode)
				curSelected = i;

		var menuBG:FlxSprite = new FlxSprite();

		awaitingExploitation = (FlxG.save.data.exploitationState == 'awaiting');

		if (awaitingExploitation)
		{
			menuBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/void/redsky', 'shared'));
			menuBG.scrollFactor.set();
			menuBG.antialiasing = false;
			add(menuBG);

			#if SHADERS_ENABLED
			bgShader = new Shaders.GlitchEffect();
			bgShader.waveAmplitude = 0.1;
			bgShader.waveFrequency = 5;
			bgShader.waveSpeed = 2;

			menuBG.shader = bgShader.shader;
			#end
		}
		else
		{
			menuBG.color = 0xFFea71fd;
			menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
			menuBG.updateHitbox();
			menuBG.antialiasing = true;
			menuBG.loadGraphic(MainMenuState.randomizeBG());
			add(menuBG);
		}

		var exitButton:FlxButton = new FlxButton(FlxG.width - 200, 50, 'Exit', function()
		{
			if (controlsItems[Math.floor(curSelected)] != 'Space-Button')
			{
				MobileControls.mode = controlsItems[Math.floor(curSelected)];

				if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom')
					MobileControls.customVirtualPad = virtualPad;
			}

			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		});
		exitButton.setGraphicSize(Std.int(exitButton.width) * 3);
		exitButton.label.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, CENTER, true);
		exitButton.color = FlxColor.YELLOW;
		add(exitButton);

		resetButton = new FlxButton(exitButton.x, exitButton.y + 100, 'Reset', function()
		{
			if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom' && resetButton.visible)
			{
				MobileControls.customVirtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				reloadMobileControls('Pad-Custom');
			}
			else if (controlsItems[Math.floor(curSelected)] == 'Space-Button' && resetButton.visible)
			{
				MobileControls.spaceButtonPositions = new FlxPoint(FlxG.width - 132, FlxG.height - 135);
				reloadMobileControls('Space-Button');
			}
		});
		resetButton.setGraphicSize(Std.int(resetButton.width) * 3);
		resetButton.label.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, CENTER, true);
		resetButton.color = FlxColor.RED;
		resetButton.visible = false;
		add(resetButton);

		savePositionsButton = new FlxButton(FlxG.width - exitButton.x, exitButton.y, 'Save Positions', function()
		{
			if (savePositionsButton.visible && virtualPad != null) // being sure about something
				MobileControls.spaceButtonPositions = new FlxPoint(virtualPad.buttonSpace.x, virtualPad.buttonSpace.y);
		});
		savePositionsButton.setGraphicSize(Std.int(savePositionsButton.width) * 3);
		savePositionsButton.label.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, CENTER, true);
		savePositionsButton.color = FlxColor.GREEN;
		savePositionsButton.visible = false;
		add(savePositionsButton);

		virtualPad = new FlxVirtualPad(NONE, NONE);
		virtualPad.visible = false;
		add(virtualPad);

		hitbox = new FlxHitbox(DEFAULT);
		hitbox.visible = false;
		add(hitbox);

		funitext = new FlxText(0, 50, 0, 'No Android Controls!', 32);
		funitext.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		funitext.borderSize = 2.4;
		funitext.screenCenter();
		funitext.visible = false;
		add(funitext);

		inputvari = new FlxText(0, 100, 0, '', 32);
		inputvari.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		inputvari.borderSize = 2.4;
		inputvari.screenCenter(X);
		add(inputvari);

		leftArrow = new FlxSprite(inputvari.x - 60, inputvari.y - 25);
		leftArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/mobile/menu/arrows.png'), Assets.getText('assets/mobile/menu/arrows.xml'));
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, inputvari.y - 25);
		rightArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/mobile/menu/arrows.png'), Assets.getText('assets/mobile/menu/arrows.xml'));
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.play('idle');
		add(rightArrow);

		rightPozition = new FlxText(10, FlxG.height - 24, 0, '', 16);
		rightPozition.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		rightPozition.borderSize = 2.4;
		add(rightPozition);

		leftPozition = new FlxText(10, FlxG.height - 44, 0, '', 16);
		leftPozition.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		leftPozition.borderSize = 2.4;
		add(leftPozition);

		downPozition = new FlxText(10, FlxG.height - 64, 0, '', 16);
		downPozition.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		downPozition.borderSize = 2.4;
		add(downPozition);

		upPozition = new FlxText(10, FlxG.height - 84, 0, '', 16);
		upPozition.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		upPozition.borderSize = 2.4;
		add(upPozition);

		spacePozition = new FlxText(10, FlxG.height - 24, 0, '', 16);
		spacePozition.setFormat(Assets.getFont('assets/mobile/menu/Comic Sans MS.ttf').fontName, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK, true);
		spacePozition.borderSize = 2.4;
		add(spacePozition);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if SHADERS_ENABLED
		if (bgShader != null)
		{
			bgShader.shader.uTime.value[0] += elapsed;
		}
		#end

		inputvari.text = controlsItems[curSelected];
		inputvari.screenCenter(X);
		leftArrow.x = inputvari.x - 60;
		rightArrow.x = inputvari.x + inputvari.width + 10;

		for (touch in FlxG.touches.list)
		{
			if (touch.overlaps(leftArrow) && touch.justPressed)
				changeSelection(-1);
			else if (touch.overlaps(rightArrow) && touch.justPressed)
				changeSelection(1);

			if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom')
			{
				if (buttonBinded)
				{
					if (touch.justReleased)
					{
						bindButton = null;
						buttonBinded = false;
					}
					else
						moveButton(touch, bindButton);
				}
				else
				{
					if (virtualPad.buttonUp.justPressed)
						moveButton(touch, virtualPad.buttonUp);

					if (virtualPad.buttonDown.justPressed)
						moveButton(touch, virtualPad.buttonDown);

					if (virtualPad.buttonRight.justPressed)
						moveButton(touch, virtualPad.buttonRight);

					if (virtualPad.buttonLeft.justPressed)
						moveButton(touch, virtualPad.buttonLeft);
				}
			}
			else if (controlsItems[Math.floor(curSelected)] == 'Space-Button')
			{
				if (buttonBinded)
				{
					if (touch.justReleased)
					{
						bindButton = null;
						buttonBinded = false;
					}
					else
						moveButton(touch, bindButton);
				}
				else
				{
					if (virtualPad.buttonSpace.justPressed)
						moveButton(touch, virtualPad.buttonSpace);
				}
			}
		}

		if (virtualPad != null)
		{
			if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom')
			{
				if (virtualPad.buttonUp != null)
					upPozition.text = 'Button Up X:' + virtualPad.buttonUp.x + ' Y:' + virtualPad.buttonUp.y;

				if (virtualPad.buttonDown != null)
					downPozition.text = 'Button Down X:' + virtualPad.buttonDown.x + ' Y:' + virtualPad.buttonDown.y;

				if (virtualPad.buttonLeft != null)
					leftPozition.text = 'Button Left X:' + virtualPad.buttonLeft.x + ' Y:' + virtualPad.buttonLeft.y;

				if (virtualPad.buttonRight != null)
					rightPozition.text = 'Button Right X:' + virtualPad.buttonRight.x + ' Y:' + virtualPad.buttonRight.y;
			}
			else if (controlsItems[Math.floor(curSelected)] == 'Space-Button')
			{
				if (virtualPad.buttonSpace != null)
					spacePozition.text = 'Space Button X:' + virtualPad.buttonSpace.x + ' Y:' + virtualPad.buttonSpace.y;
			}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = controlsItems.length - 1;

		if (curSelected >= controlsItems.length)
			curSelected = 0;

		var daChoice:String = controlsItems[Math.floor(curSelected)];

		reloadMobileControls(daChoice);

		funitext.visible = daChoice == 'Keyboard';
		resetButton.visible = (daChoice == 'Pad-Custom' || daChoice == 'Space-Button');
		upPozition.visible = daChoice == 'Pad-Custom';
		downPozition.visible = daChoice == 'Pad-Custom';
		leftPozition.visible = daChoice == 'Pad-Custom';
		rightPozition.visible = daChoice == 'Pad-Custom';
		spacePozition.visible = daChoice == 'Space-Button';
		savePositionsButton.visible = daChoice == 'Space-Button';
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void
	{
		bindButton = button;
		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);
		buttonBinded = true;
	}

	function reloadMobileControls(daChoice:String):Void
	{
		switch (daChoice)
		{
			case 'Pad-Right':
				hitbox.visible = false;
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Left':
				hitbox.visible = false;
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Custom':
				hitbox.visible = false;
				remove(virtualPad);
				virtualPad = MobileControls.customVirtualPad;
				add(virtualPad);
			case 'Pad-Duo':
				hitbox.visible = false;
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 'Hitbox':
				hitbox.visible = true;
				virtualPad.visible = false;
			case 'Keyboard':
				hitbox.visible = false;
				virtualPad.visible = false;
			case 'Space-Button':
				hitbox.visible = false;
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(NONE, SPACE);
				add(virtualPad);
		}
	}
}
