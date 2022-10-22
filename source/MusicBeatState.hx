package;

#if mobile
import mobile.MobileControls;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if mobile
	var mobileControls:MobileControls;
	var virtualPad:FlxVirtualPad;
	var trackedinputsVirtualPad:Array<FlxActionInput> = [];
	var trackedinputsMobileControls:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPad(virtualPad, DPad, Action);
		trackedinputsVirtualPad = controls.trackedinputs;
		controls.trackedinputs = [];
	}

	public function removeVirtualPad()
	{
		if (trackedinputsVirtualPad != [])
			controls.removeControlsInput(trackedinputsVirtualPad);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addMobileControls(usesDodge:Bool = false, DefaultDrawTarget:Bool = true)
	{
		mobileControls = new MobileControls(usesDodge);

		switch (MobileControls.mode)
		{
			case 'Pad-Right' | 'Pad-Left' | 'Pad-Custom':
				controls.setVirtualPad(mobileControls.virtualPad, RIGHT_FULL, NONE);
			case 'Pad-Duo':
				controls.setVirtualPad(mobileControls.virtualPad, BOTH_FULL, NONE);
			case 'Hitbox':
				controls.setHitBox(mobileControls.hitbox, usesDodge ? SPACE : DEFAULT);
			case 'Keyboard': // do nothing
		}

		trackedinputsMobileControls = controls.trackedinputs;
		controls.trackedinputs = [];

		var camControls:FlxCamera = new FlxCamera();
		FlxG.cameras.add(camControls, DefaultDrawTarget);
		camControls.bgColor.alpha = 0;

		mobileControls.cameras = [camControls];
		mobileControls.visible = false;
		add(mobileControls);

		if (usesDodge && (MobileControls.mode != 'Hitbox' && MobileControls.mode != 'Keyboard'))
		{
			addVirtualPad(NONE, SPACE);
			virtualPad.cameras = [camControls];
		}
	}

	public function removeMobileControls()
	{
		if (trackedinputsMobileControls != [])
			controls.removeControlsInput(trackedinputsMobileControls);

		if (mobileControls != null)
			remove(mobileControls);
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = true)
	{
		if (virtualPad != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			camControls.bgColor.alpha = 0;
			virtualPad.cameras = [camControls];
		}
	}
	#end

	override function destroy()
	{
		#if mobile
		if (trackedinputsVirtualPad != [])
			controls.removeControlsInput(trackedinputsVirtualPad);

		if (trackedinputsMobileControls != [])
			controls.removeControlsInput(trackedinputsMobileControls);
		#end

		super.destroy();

		#if mobile
		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (mobileControls != null)
		{
			mobileControls = FlxDestroyUtil.destroy(mobileControls);
			mobileControls = null;
		}
		#end
	}

	override function create()
	{
		if (transIn != null)
			//trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
