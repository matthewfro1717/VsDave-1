package;

import TerminalCheatingState.TerminalText;
import flixel.group.FlxGroup;
import haxe.Json;
import haxe.Http;
import flixel.math.FlxRandom;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import flash.system.System;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var bg:FlxBackdrop;

	var menuItems:Array<PauseOption> = [
		new PauseOption('Resume'),
		new PauseOption('Restart Song'),
		new PauseOption('Change Character'),
		new PauseOption('No Miss Mode'),
		new PauseOption('Exit to menu')
	];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var expungedSelectWaitTime:Float = 0;
	var timeElapsed:Float = 0;
	var patienceTime:Float = 0;

	public var funnyTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	public function new(x:Float, y:Float)
	{
		super();

		if (['supernovae', 'cheating', 'unfairness', 'exploitation', 'master', 'recursed', 'glitch', 'kabunga', 'vs-dave-rap'].contains(PlayState.SONG.song.toLowerCase()))
			menuItems.insert(4, new PauseOption('Chart Editor'));

		funnyTexts = new FlxTypedGroup<FlxText>();
		add(funnyTexts);

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			case "exploitation":
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast-ohno'), true, true);
				expungedSelectWaitTime = new FlxRandom().float(2, 7);
				patienceTime = new FlxRandom().float(15, 30);
		}
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var backBg:FlxSprite = new FlxSprite();
		backBg.makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.BLACK);
		backBg.alpha = 0;
		backBg.scrollFactor.set();
		add(backBg);

		bg = new FlxBackdrop(Paths.image('ui/checkeredBG', 'preload'), 1, 1, true, true, 1, 1);
		bg.alpha = 0;
		bg.antialiasing = true;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.antialiasing = true;
		levelInfo.borderSize = 2.5;
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('comic.ttf'), 32, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelDifficulty.antialiasing = true;
		levelDifficulty.borderSize = 2.5;
		levelDifficulty.updateHitbox();
		if (PlayState.SONG.song.toLowerCase() == 'exploitation' && !PlayState.isGreetingsCutscene)
		{
			add(levelDifficulty);
		}

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(backBg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5,
		onComplete: function(tween:FlxTween)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'exploitation':
					doALittleTrolling(levelDifficulty);
			}
		}});
		if (PlayState.isStoryMode || FreeplayState.skipSelect.contains(PlayState.SONG.song.toLowerCase()) || PlayState.instance.localFunny == PlayState.CharacterFunnyEffect.Recurser)
		{
			menuItems.remove(PauseOption.getOption(menuItems, 'Change Character'));
		}
		for (item in menuItems)
		{
			if (PlayState.instance.localFunny == PlayState.CharacterFunnyEffect.Recurser)
			{
				if(item.optionName != 'Resume' && item.optionName != 'No Miss Mode')
				{
					menuItems.remove(PauseOption.getOption(menuItems, item.optionName));
				}
				continue;
			}
		}

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, LanguageManager.getTextString('pause_${menuItems[i].optionName}'), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if mobile
		addVirtualPad(UP_DOWN, A);
		addVirtualPadCamera();
		#end
	}

	override function update(elapsed:Float)
	{
		var scrollSpeed:Float = 50;
		bg.x -= scrollSpeed * elapsed;
		bg.y -= scrollSpeed * elapsed;

		timeElapsed += elapsed;
		if (pauseMusic.volume < 0.75)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (PlayState.SONG.song.toLowerCase() == 'exploitation' && this.exists && PauseSubState != null)
		{
			if (expungedSelectWaitTime >= 0)
			{
				expungedSelectWaitTime -= elapsed;
			}
			else
			{
				expungedSelectWaitTime = new FlxRandom().float(0.5, 2);
				changeSelection(new FlxRandom().int((menuItems.length - 1) * -1, menuItems.length - 1));
			}
		}

		if (accepted)
		{
			selectOption();
		}
	}
	function selectOption()
	{
		var daSelected:String = menuItems[curSelected].optionName;

		switch (daSelected)
		{
			case "Resume":
				close();
			case "Restart Song":
				FlxG.sound.music.volume = 0;
				PlayState.instance.vocals.volume = 0;

				PlayState.instance.shakeCam = false;
				PlayState.instance.camZooming = false;
				if (PlayState.SONG.song.toLowerCase() == "exploitation")
				{
					if (PlayState.window != null)
					{
						PlayState.window.close();
					}
				}
				FlxG.mouse.visible = false;
				FlxG.resetState();
			case "Change Character":
				if (MathGameState.failedGame)
					{
						MathGameState.failedGame = false;
					}
					funnyTexts.clear();
					PlayState.characteroverride = 'none';
					PlayState.formoverride = 'none';
					PlayState.recursedStaticWeek = false;
	
					Application.current.window.title = Main.applicationName;
	
					if (PlayState.SONG.song.toLowerCase() == "exploitation")
					{
						Main.toggleFuckedFPS(false);
						if (PlayState.window != null)
						{
							PlayState.window.close();
						}
					}
					PlayState.instance.shakeCam = false;
					PlayState.instance.camZooming = false;
					FlxG.mouse.visible = false;
					FlxG.switchState(new CharacterSelectState());	
			case "No Miss Mode":
				PlayState.instance.noMiss = !PlayState.instance.noMiss;
				if (['exploitation', 'cheating', 'unfairness', 'recursed', 'glitch', 'master', 'supernovae'].contains(PlayState.SONG.song.toLowerCase()))
				{
					PlayState.instance.health = 0;
					close();
				}
			case "Chart Editor":
				if(FlxTransitionableState.skipNextTransIn)
					Transition.nextCamera = null;
				
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'supernovae':
						FlxG.switchState(new TerminalCheatingState([
							new TerminalText(0, [['Warning: ', 1], ['Chart Editor access detected', 1],]),
							new TerminalText(200, [['run AntiCheat.dll', 0.5]]),
							new TerminalText(0, [['ERROR: File currently being used by another process. Retrying in 3...', 3]]),
							new TerminalText(200, [['File no longer in use, running AntiCheat.dll..', 2]]),
						], function()
						{
							PlayState.instance.shakeCam = false;
							#if SHADERS_ENABLED
							PlayState.screenshader.Enabled = false;
							#end
	
							PlayState.SONG = Song.loadFromJson("cheating"); // you dun fucked up
							PlayState.isStoryMode = false;
							PlayState.storyWeek = 14;
							FlxG.save.data.cheatingFound = true;
							FlxG.save.flush();
							LoadingState.loadAndSwitchState(new PlayState());
						}));
						return;
					case 'cheating':
						FlxG.switchState(new TerminalCheatingState([
							new TerminalText(0, [['Warning: ', 1], ['Chart Editor access detected', 1],]),
							new TerminalText(200, [['run AntiCheat.dll', 3]]),
						], function()
						{
							PlayState.isStoryMode = false;
							PlayState.storyPlaylist = [];
							
							PlayState.instance.shakeCam = false;
							#if SHADERS_ENABLED
							PlayState.screenshader.Enabled = false;
							#end
	
							PlayState.SONG = Song.loadFromJson("unfairness"); // you dun fucked up again
							PlayState.storyWeek = 15;
							FlxG.save.data.unfairnessFound = true;
							FlxG.save.flush();
							LoadingState.loadAndSwitchState(new PlayState());
						}));
						return;
					case 'unfairness':
						FlxG.switchState(new TerminalCheatingState([
							new TerminalText(0, [
								['bin/plugins/AntiCheat.dll: ', 1],
								['No argument for function "AntiCheatThree"', 1],
							]),
							new TerminalText(100, [['Redirecting to terminal...', 1]])
						], function()
						{
							PlayState.isStoryMode = false;
							PlayState.storyPlaylist = [];
							
							PlayState.instance.shakeCam = false;
							#if SHADERS_ENABLED
							PlayState.screenshader.Enabled = false;
							#end

							FlxG.switchState(new TerminalState());
						}));
						#if desktop
						DiscordClient.changePresence("I have your IP address", null, null, true);
						#end
						return;
					case 'exploitation' | 'master':
						PlayState.instance.health = 0;
					case 'recursed':
						ChartingState.hahaFunnyRecursed();
					case 'glitch':
						PlayState.storyPlaylist = [];
						
						PlayState.SONG = Song.loadFromJson("kabunga"); // lol you loser
						PlayState.isStoryMode = false;
						FlxG.save.data.exbungoFound = true;
						FlxG.save.flush();
						PlayState.instance.shakeCam = false;
						#if SHADERS_ENABLED
						PlayState.screenshader.Enabled = false;
						#end
						LoadingState.loadAndSwitchState(new PlayState());
						return;
					case 'kabunga':
						FlxG.openURL("https://benjaminpants.github.io/muko_firefox/index.html"); //banger game
						System.exit(0);
					case 'vs-dave-rap':
						PlayState.SONG = Song.loadFromJson("vs-dave-rap-two");
						FlxG.save.data.vsDaveRapTwoFound = true;
						FlxG.save.flush();
						PlayState.instance.shakeCam = false;
						#if SHADERS_ENABLED
						PlayState.screenshader.Enabled = false;
						#end
						LoadingState.loadAndSwitchState(new PlayState());
						return;
				}
			case "Exit to menu":
				if (MathGameState.failedGame)
				{
					MathGameState.failedGame = false;
				}
				funnyTexts.clear();
				PlayState.characteroverride = 'none';
				PlayState.formoverride = 'none';
				PlayState.recursedStaticWeek = false;

				Application.current.window.title = Main.applicationName;

				if (PlayState.SONG.song.toLowerCase() == "exploitation")
				{
					Main.toggleFuckedFPS(false);
					if (PlayState.window != null)
					{
						PlayState.window.close();
					}
				}
				PlayState.instance.shakeCam = false;
				PlayState.instance.camZooming = false;
				FlxG.mouse.visible = false;
				FlxG.switchState(new MainMenuState());
		}
	}
	override function close()
	{
		funnyTexts.clear();

		super.close();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
	function doALittleTrolling(levelDifficulty:FlxText)
	{
		var difficultyHeight = levelDifficulty.height;
		var amountOfDifficulties = Math.ceil(FlxG.height / difficultyHeight);

		for (i in 0...amountOfDifficulties)
		{
			if (funnyTexts.exists)
			{
				var difficulty:FlxText = new FlxText(20, (15 + 32) * (i + 2), 0, "", 32);
				difficulty.text += levelDifficulty.text;
				difficulty.scrollFactor.set();
				difficulty.setFormat(Paths.font('comic.ttf'), 32, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				difficulty.antialiasing = true;
				difficulty.borderSize = 2;
				difficulty.updateHitbox();
				funnyTexts.add(difficulty);

				difficulty.alpha = 0;

				difficulty.x = FlxG.width - (difficulty.width + 20);

				FlxTween.tween(difficulty, {alpha: 1, y: difficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.05 * i});
			}
			else
			{
				return;
			}

		}
	}
	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
class PauseOption
{
	public var optionName:String;

	public function new(optionName:String)
	{
		this.optionName = optionName;
	}
	
	public static function getOption(list:Array<PauseOption>, optionName:String):PauseOption
	{
		for (option in list)
		{
			if (option.optionName == optionName)
			{
				return option;
			}
		}
		return null;
	}
}
