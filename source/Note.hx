package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	//////////////////////////////////////////////////
	//Extra keys stuff

	//Important stuff
	public static var gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
												'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'];
	public static var ammo:Array<Int> = EKData.gun;
	public static var minMania:Int = 0;
	public static var maxMania:Int = 17; // key value is this + 1

	public static var scales:Array<Float> = EKData.scales;
	public static var lessX:Array<Int> = EKData.lessX;
	public static var separator:Array<Int> = EKData.noteSep;
	public static var xtra:Array<Float> = EKData.offsetX;
	public static var posRest:Array<Float> = EKData.restPosition;
	public static var gridSizes:Array<Int> = EKData.gridSizes;
	public static var noteSplashOffsets:Map<Int, Array<Int>> = [
		0 => [20, 10],
		9 => [10, 20]
	];
	public static var noteSplashScales:Array<Float> = EKData.splashScales;

	public static var xmlMax:Int = 17; // This specifies the max of the splashes can go

	public static var minManiaUI_integer:Int = minMania + 1;
	public static var maxManiaUI_integer:Int = maxMania + 1;

	public static var defaultMania:Int = 3;

	// pixel notes
	public static var pixelNotesDivisionValue:Int = 18;
	public static var pixelScales:Array<Float> = EKData.pixelScales;

	public static var keysShit:Map<Int, Map<String, Dynamic>> = EKData.keysShit;

	// End of extra keys stuff
	//////////////////////////////////////////////////

	public var extraData:Map<String,Dynamic> = [];
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	public var changeAnim:Bool = true;
	public var changeColSwap:Bool = true;
	
	public function resizeByRatio(ratio:Float) //haha funny twitter shit
		{
			if(isSustainNote && !animation.curAnim.name.endsWith('tail'))
			{
				scale.y *= ratio;
				updateHitbox();
			}
		}

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public var mania:Int = 1;

	private var CharactersWith3D:Array<String> = ["dave-angey", "bambi-3d", 'bambi-unfair', 'exbungo', 'expunged', 'dave-festival-3d', 'dave-3d-recursed', 'bf-3d', 'nofriend'];

	public static var widths:Array<Float> = [160, 140, 120, 110, 90, 70];
	public static var scales:Array<Float> = [0.7, 0.65, 0.6, 0.55, 0.46, 0.36];
	public static var posRest:Array<Int> = [0, 25, 35, 50, 70, 80];

	public static var swagWidth:Float = 160 * 0.7;
	public static var noteSize:Float = 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	private var notetolookfor = 0;

	public var originalType = 0;

	public var MyStrum:StrumNote;

	public var noteStyle:String = 'normal';

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var guitarSection:Bool;

	public var alphaMult:Float = 1.0;
	public var noteOffset:Float = 0;

	var notes = ['purple', 'blue', 'green', 'red'];

	var ogW:Float;
	var ogH:Float;

	var defaultWidth:Float = 0;
	var defaultHeight:Float = 0;
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?musthit:Bool = true, noteStyle:String = "normal", inCharter:Bool = false, guitarSection:Bool = false)
	{
		mania = PlayState.SONG.mania;
		swagWidth = widths[mania] * 0.7; //factor not the same as noteScale

		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.noteStyle = noteStyle;
		this.isSustainNote = sustainNote;
		this.originalType = noteData;
		this.guitarSection = guitarSection;
		this.noteData = noteData;

		x += 78 - posRest[mania];
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		//NOW IT SHALL FOR REALLY ALWAYS BE OFF SCREEN.
		//luckily i think only the devs really noticed that you can see the notes spawn in at the bottom of the screen when there is a modchart.
		y -= 9000;
		
		inCharter ? this.strumTime = strumTime : {
			this.strumTime = Math.round(strumTime);
			alpha = 0;
		}
		
		if (this.strumTime < 0)
			this.strumTime = 0;

		if (isInState('PlayState'))
		{
			this.strumTime += FlxG.save.data.offset;
		}		
		if (mania == 1) notes = ['purple', 'blue', 'white', 'green', 'red'];
		if (mania == 2) notes = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
		if (mania == 3) notes = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
		if (mania == 4) notes = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
		if (mania == 5) notes = ['purple', 'blue', 'green', 'red', 'pink', 'turq', 'emerald', 'lightred', 'yellow', 'violet', 'black', 'dark'];
		if ((guitarSection && inCharter && noteData < 5) || (guitarSection)) notes = ['green', 'red', 'yellow', 'blue', 'orange'];

		var notePathLol:String = 'notes/NOTE_assets';
		noteSize = scales[mania];

		if ((((CharactersWith3D.contains(PlayState.SONG.player2) && !musthit) || ((CharactersWith3D.contains(PlayState.SONG.player1)
				|| CharactersWith3D.contains(PlayState.characteroverride) || CharactersWith3D.contains(PlayState.formoverride)) && musthit))
				|| ((CharactersWith3D.contains(PlayState.SONG.player2) || CharactersWith3D.contains(PlayState.SONG.player1)) && ((this.strumTime / 50) % 20 > 10)))
				&& this.noteStyle == 'normal')
		{
			this.noteStyle = '3D';
			notePathLol = 'notes/NOTE_assets_3D';
		}
		switch (noteStyle)
		{
			case 'phone':
				notePathLol = 'notes/NOTE_phone';
			case 'shape':
				notePathLol = 'notes/NOTE_assets_Shape';
		}
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'overdrive':
				notePathLol = 'notes/OMGtop10awesomehi';
			case 'recursed':
				musthit ? {
					if ((this.strumTime / 50) % 20 > 12 && !isSustainNote)
					{
						this.noteStyle = 'text';
					}
				} : {
					this.noteStyle = 'recursed';
					notePathLol = 'notes/NOTE_recursed';
				}
		}
		if (guitarSection) this.noteStyle = 'guitarHero';
		switch (this.noteStyle)
		{
			default:
				frames = Paths.getSparrowAtlas(notePathLol, 'shared');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('whiteScroll', 'white0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('violetScroll', 'violet0');
				animation.addByPrefix('blackScroll', 'black0');
				animation.addByPrefix('darkScroll', 'dark0');
				animation.addByPrefix('pinkScroll', 'pink0');
				animation.addByPrefix('turqScroll', 'turq0');
				animation.addByPrefix('emeraldScroll', 'emerald0');
				animation.addByPrefix('lightredScroll', 'lightred0');


				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('whiteholdend', 'white hold end');
				animation.addByPrefix('yellowholdend', 'yellow hold end');
				animation.addByPrefix('violetholdend', 'violet hold end');
				animation.addByPrefix('blackholdend', 'black hold end');
				animation.addByPrefix('darkholdend', 'dark hold end');
				animation.addByPrefix('pinkholdend', 'pink hold end');
				animation.addByPrefix('turqholdend', 'turq hold end');
				animation.addByPrefix('emeraldholdend', 'emerald hold end');
				animation.addByPrefix('lightredholdend', 'lightred hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('whitehold', 'white hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('violethold', 'violet hold piece');
				animation.addByPrefix('blackhold', 'black hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');
				animation.addByPrefix('pinkhold', 'pink hold piece');
				animation.addByPrefix('turqhold', 'turq hold piece');
				animation.addByPrefix('emeraldhold', 'emerald hold piece');
				animation.addByPrefix('lightredhold', 'lightred hold piece');
	
				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = noteStyle != '3D';
			
			case 'shape':
				frames = Paths.getSparrowAtlas(notePathLol, 'shared');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('darkScroll', 'dark0');


				animation.addByPrefix('purpleholdend', 'purple hold piece');
				animation.addByPrefix('greenholdend', 'green hold piece');
				animation.addByPrefix('redholdend', 'red hold piece');
				animation.addByPrefix('blueholdend', 'blue hold piece');
				animation.addByPrefix('yellowholdend', 'yellow hold piece');
				animation.addByPrefix('darkholdend', 'dark hold piece');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');

				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = false;

			case 'text':
				frames = Paths.getSparrowAtlas('ui/alphabet');

				var noteColors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
	
				var boldLetters:Array<String> = new Array<String>();
	
				for (frameName in frames.frames)
				{
					if (frameName.name.contains('bold'))
					{
						boldLetters.push(frameName.name);
					}
				}
				var randomFrame = boldLetters[new FlxRandom().int(0, boldLetters.length - 1)];
				var prefix = randomFrame.substr(0, randomFrame.length - 4);
				for (note in noteColors)
				{
					animation.addByPrefix('${note}Scroll', prefix, 24);
				}
				setGraphicSize(Std.int(width * 1.2 * (noteSize / 0.7)));
				updateHitbox();
				antialiasing = true;
				// noteOffset = -(width - 78 + (mania == 4 ? 30 : 0));

			case 'guitarHero':
				frames = Paths.getSparrowAtlas('notes/NOTEGH_assets', 'shared');

				animation.addByPrefix('greenScroll', 'A Note');
				animation.addByPrefix('greenhold', 'A Hold Piece');
				animation.addByPrefix('greenholdend', 'A Hold End');


				animation.addByPrefix('redScroll', 'B Note');
				animation.addByPrefix('redhold', 'B Hold Piece');
				animation.addByPrefix('redholdend', 'B Hold End');

				animation.addByPrefix('yellowScroll', 'C Note');
				animation.addByPrefix('yellowhold', 'C Hold Piece');
				animation.addByPrefix('yellowholdend', 'C Hold End');

				animation.addByPrefix('blueScroll', 'D Note');
				animation.addByPrefix('bluehold', 'D Hold Piece');
				animation.addByPrefix('blueholdend', 'D Hold End');

				animation.addByPrefix('orangeScroll', 'E Note');
				animation.addByPrefix('orangehold', 'E Hold Piece');
				animation.addByPrefix('orangeholdend', 'E Hold End');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
			case 'phone' | 'phone-alt':
				if (!isSustainNote)
				{
					frames = Paths.getSparrowAtlas('notes/NOTE_phone', 'shared');
				}
				else
				{
					frames = Paths.getSparrowAtlas('notes/NOTE_assets', 'shared');
				}
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('whiteScroll', 'white0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('violetScroll', 'violet0');
				animation.addByPrefix('blackScroll', 'black0');
				animation.addByPrefix('darkScroll', 'dark0');


				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('whiteholdend', 'white hold end');
				animation.addByPrefix('yellowholdend', 'yellow hold end');
				animation.addByPrefix('violetholdend', 'violet hold end');
				animation.addByPrefix('blackholdend', 'black hold end');
				animation.addByPrefix('darkholdend', 'dark hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('whitehold', 'white hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('violethold', 'violet hold piece');
				animation.addByPrefix('blackhold', 'black hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');

				LocalScrollSpeed = 1.08;
				
				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = true;
				
				// noteOffset = 20;

		}
		var str:String = PlayState.SONG.song.toLowerCase();
		if (isInState('PlayState'))
		{
			var state:PlayState = cast(FlxG.state, PlayState);
			if (state.localFunny == CharacterFunnyEffect.Dave)
			{
				str = 'cheating';
			}
		}
		if (str == 'cheating' && PlayState.modchartoption) {
			if (mania == 0) {
				switch (originalType)
				{
					case 0:
						x += swagWidth * 3;
						notetolookfor = 3;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						notetolookfor = 1;
						animation.play('blueScroll');
					case 2:
						x += swagWidth * 0;
						notetolookfor = 0;
						animation.play('greenScroll');
					case 3:
						notetolookfor = 2;
						x += swagWidth * 2;
						animation.play('redScroll');
				}
			} else if (mania == 2) {
				switch (originalType)
				{
					case 0:
						x += swagWidth * 5;
						notetolookfor = 5;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 3;
						notetolookfor = 3;
						animation.play('greenScroll');
					case 2:
						notetolookfor = 1;
						x += swagWidth * 1;
						animation.play('redScroll');
					case 3:
						notetolookfor = 2;
						x += swagWidth * 2;
						animation.play('yellowScroll');
					case 4:
						x += swagWidth * 0;
						notetolookfor = 0;
						animation.play('blueScroll');
					case 5:
						x += swagWidth * 4;
						notetolookfor = 4;
						animation.play('darkScroll');
				}
			}
			if (!isSustainNote) {
				flipY = (Math.round(Math.random()) == 0); // fuck you
				flipX = (Math.round(Math.random()) == 1);
			}
		} else {
			var not = originalType % Main.keyAmmo[mania];
			if (guitarSection) not = originalType;
			x += swagWidth * not;
			notetolookfor = not;
			animation.play(notes[not] + 'Scroll');
		}
		if (isInState('PlayState'))
		{
			SearchForStrum(musthit);
		}
		if (!isSustainNote) {
			if (!PlayState.modchartoption) {
				if (PlayState.SONG.song.toLowerCase() == 'cheating')
					LocalScrollSpeed = 0.75; // target practice old
				if (PlayState.SONG.song.toLowerCase() == 'kabunga')
					LocalScrollSpeed = 0.81;
			}
			if (PlayState.SONG.song.toLowerCase() == 'unfairness')
			{
				if (PlayState.modchartoption) {
					var rng:FlxRandom = new FlxRandom();
					if (rng.int(0, 120) == 1)
					{
						LocalScrollSpeed = 0.1;
					}
					else
					{
						LocalScrollSpeed = rng.float(1, 3);
					}
				} else {
					LocalScrollSpeed = 2;
				}
			}
			if (PlayState.SONG.song.toLowerCase() == 'exploitation')
			{
				if (PlayState.modchartoption) {
					var rng:FlxRandom = new FlxRandom();
					if (rng.int(0, 484) == 1)
					{
						LocalScrollSpeed = 0.1;
					}
					else
					{
						LocalScrollSpeed = rng.float(2.9, 3.6);
					}
				} else {
					LocalScrollSpeed = 3;
				}
			}
		}

		if (isSustainNote && prevNote != null)
		{
			alphaMult = 0.6;

			noteOffset += width / 2;

			animation.play(notes[noteData % Main.keyAmmo[mania]] + 'holdend');

			if (PlayState.scrollType == 'downscroll')
			{
				flipY = true;
			}

			updateHitbox();

			noteOffset -= width / 2;

			LocalScrollSpeed = prevNote.LocalScrollSpeed;

			var noteSpeed = (LocalScrollSpeed == 0 ? 1 : LocalScrollSpeed);

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(notes[prevNote.noteData] + 'hold');

				if (noteStyle != 'shape')
				{
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed * noteSpeed * (0.7 / noteSize);
					// prevNote.scale.y *= (Conductor.stepCrochet / 100) * PlayState.SONG.speed * 1.5;
					prevNote.updateHitbox();
				}
				else
				{
					//INCOMPLETE
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 0.75 * PlayState.SONG.speed * noteSpeed * (0.7 / noteSize);
					prevNote.scale.x *= Conductor.stepCrochet / 100 * 0.5 * PlayState.SONG.speed * noteSpeed * (0.7 / noteSize);
					// prevNote.scale.y *= (Conductor.stepCrochet / 100) * PlayState.SONG.speed * 0.75;
					// prevNote.scale.x *= (Conductor.stepCrochet / 100) * PlayState.SONG.speed * 0.5;
					prevNote.offset.y += prevNote.height / 3;
					prevNote.updateHitbox();
				}
			}
		}
		if (noteStyle == 'shape')
		{
			switch (noteData)
			{
				/* case 1:
					noteOffset += 4;
				case 2:
					noteOffset += 10; */
			}
			if (isSustainNote)
			{
				alphaMult = 1;
				noteOffset += (width / 2);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (MyStrum != null)
		{
			GoToStrum(MyStrum);
		}
		else
		{
			if (isInState('PlayState'))
			{
				SearchForStrum(mustPress);
			}
		}
		if (mustPress && isInState('PlayState'))
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else 
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			alphaMult = 0.3;
		}
	}
	public function GoToStrum(strum:StrumNote)
	{
		x = strum.x + noteOffset;
		alpha = strum.alpha * alphaMult;

		if (strum.pressingKey5)
		{
			if (noteStyle != "shape")
			{
				alpha *= 0.5;
			}
		}
		else
		{
			if (noteStyle == "shape")
			{
				alpha *= 0.5;
			}
		}
	}

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}


	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length)
		{
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;
		}

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		mania = PlayState.mania;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % Note.ammo[mania]);
			if(!isSustainNote && noteData > -1 && noteData < Note.maxManiaUI_integer) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
				animation.play(animToPlay);
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30 * Note.pixelScales[mania];

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) { ///Y E  A H
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 157;
		defaultHeight = 154;
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / pixelNotesDivisionValue;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / pixelNotesDivisionValue;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				
				/*if(animName != null && !animName.endsWith('tail'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo; 
				}*/
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		for (i in 0...gfxLetter.length)
			{
				animation.addByPrefix(gfxLetter[i], gfxLetter[i] + '0');
	
				if (isSustainNote)
				{
					animation.addByPrefix(gfxLetter[i] + ' hold', gfxLetter[i] + ' hold');
					animation.addByPrefix(gfxLetter[i] + ' tail', gfxLetter[i] + ' tail');
				}
			}
				
			ogW = width;
			ogH = height;
			if (!isSustainNote)
				setGraphicSize(Std.int(defaultWidth * scales[mania]));
			else
				setGraphicSize(Std.int(defaultWidth * scales[mania]), Std.int(defaultHeight * scales[0]));
			updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i] + ' hold', [i]);
				animation.add(gfxLetter[i] + ' tail', [i + pixelNotesDivisionValue]);
			}
		} else {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i], [i + pixelNotesDivisionValue]);
			}
		}
	}

	/*public function applyManiaChange()
	{
		if (isSustainNote) 
			scale.y = 1;
		reloadNote(texture);
		if (isSustainNote)
			offsetX = width / 2;
		if (!isSustainNote)
		{
			var animToPlay:String = '';
			animToPlay = Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]];
			animation.play(animToPlay);
		}

		/*if (isSustainNote && prevNote != null) someone please tell me why this wont work
		{
			animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]] + ' tail');
			if (prevNote != null && prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData % Note.ammo[mania]] + ' hold');
				prevNote.updateHitbox();
			}
		}

		updateHitbox();
	}*/


	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mania = PlayState.mania;

		/* im so stupid for that
		if (noteData == 9)
		{
			if (animation.curAnim != null)
				trace(animation.curAnim.name);
			else trace("te anim is null waaaaaa");

			trace(Note.keysShit.get(mania).get('letters')[noteData]);
		}
		*/

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
