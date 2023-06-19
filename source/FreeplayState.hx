package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	private var Catagories:Array<String> = ['dave', 'joke', 'extras', 'dave2.5', 'classic', 'cover', 'fanmade', 'finale'];
	var translatedCatagory:Array<String> = [
		LanguageManager.getTextString('freeplay_dave'),
		LanguageManager.getTextString('freeplay_joke'),
		LanguageManager.getTextString('freeplay_extra'),
		LanguageManager.getTextString('freeplay_dave2.5'),
		LanguageManager.getTextString('freeplay_classic'),
		LanguageManager.getTextString('freeplay_cover'),
		LanguageManager.getTextString('freeplay_fanmade'),
		LanguageManager.getTextString('freeplay_finale')
	];

	private var CurrentPack:Int = 0;

	var loadingPack:Bool = false;

	var songColors:Array<FlxColor> = 
	[
    	0xFF00137F,    // GF but its actually dave!
		0xFF4965FF,    // DAVE
		0xFF00B515,    // MISTER BAMBI RETARD (thats kinda rude ngl)
		0xFF00FFFF,    // SPLIT THE THONNNNN
		0xFF800080,    // FESTIVAL
		0xFF116E1C,    // MASTA BAMBI
		0xFFFF0000,    // KABUNGA
		0xFF0EAE2C,    // SECRET MOD LEAK
		0xFFFF0000,    // TRISTAN
		FlxColor.fromRGB(162, 150, 188), // PLAYROBOT
		FlxColor.fromRGB(44, 44, 44),    // RECURSED
		0xFF31323F,    // MOLDY
		0xFF35396C,    // FIVE NIGHT
		0xFF0162F5,    // OVERDRIVE
		0xFF119A2B,    // CHEATING
		0xFFFF0000,    // UNFAIRNESS
		0xFF810000,    // EXPLOITATION
		0xFF000000,    // Enter Terminal
		0xFFCC5555,    // Electric-Cockaldoodledoo
		0xFF008E00,    // longnosejohn
		0xFFFFFFFF,    // cuzsiee
    ];
	public static var skipSelect:Array<String> = 
	[
		'five-nights',
		'vs-dave-rap',
		'vs-dave-rap-two',
		'confronting-yourself',
		'cob',
		'cuzsie-x-kapi-shipping-cute',
		'oppression',
		'bananacore',
		'eletric-cockadoodledoo',
		'electric-cockaldoodledoo',
		'super-saiyan',
		'foolhardy',
		'detected',
		'cheating-not-cute'
	];

	public static var noExtraKeys:Array<String> = 
	[
		'five-nights',
		'vs-dave-rap',
		'vs-dave-rap-two',
		'overdrive',
		'confronting-yourself',
		'cob',
		'cuzsie-x-kapi-shipping-cute',
		'oppression',
		'bananacore',
		'eletric-cockadoodledoo',
		'electric-cockaldoodledoo',
		'super-saiyan',
		'foolhardy',
		'crop',
		'popcorn',
		'no-legs',
		'blitz',
		'importumania',
		'rigged',
		'old-house',
		'old-insanity',
		'furiosity',
		'old-blocked',
		'old-corn-theft',
		'old-maze',
		'beta-maze',
		'old-splitathon',
		'old-screwed',
		'screwed-v2',
		'secret',
		'secret-mod-leak',
		'vs-dave-thanksgiving',
		'bonkers',
		'duper',
		'mastered',
		'detected',
		'cheating-not-cute'
	];

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	var titles:Array<Alphabet> = [];
	var icons:Array<FlxSprite> = [];

	var doneCoolTrans:Bool = false;

	var defColor:FlxColor;
	var canInteract:Bool = true;

	//recursed
	var timeSincePress:Float;
	var lastTimeSincePress:Float;

	var pressSpeed:Float;
	var pressSpeeds:Array<Float> = new Array<Float>();
	var pressUnlockNumber:Int;
	var requiredKey:Array<Int>;
	var stringKey:String;

	var bgShader:Shaders.GlitchEffect;
	var awaitingExploitation:Bool;
	public static var packTransitionDone:Bool = false;
	var characterSelectText:FlxText;
	var showCharText:Bool = true;

	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('ui/checkeredBG'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFfd719b);

	override function create()
	{
		#if desktop DiscordClient.changePresence("In the Freeplay Menu", null); #end
		
		awaitingExploitation = (FlxG.save.data.exploitationState == 'awaiting');
		showCharText = FlxG.save.data.wasInCharSelect;

		if (awaitingExploitation)
		{
			bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/void/redsky', 'shared'));
			bg.scrollFactor.set();
			bg.antialiasing = false;
			bg.color = FlxColor.multiply(bg.color, FlxColor.fromRGB(50, 50, 50));
			add(bg);
			
			#if SHADERS_ENABLED
			bgShader = new Shaders.GlitchEffect();
			bgShader.waveAmplitude = 0.1;
			bgShader.waveFrequency = 5;
			bgShader.waveSpeed = 2;
			
			bg.shader = bgShader.shader;
			#end
			defColor = bg.color;
		}
		else
		{
			bg.loadGraphic(MainMenuState.randomizeBG());
			bg.color = 0xFF4965FF;
			defColor = bg.color;
			bg.scrollFactor.set();
			add(bg);

			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x558DE7E5, 0xAAE6F0A9], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			add(gradientBar);
			gradientBar.scrollFactor.set(0, 0);
			gradientBar.antialiasing = FlxG.save.data.globalAntialiasing;

			add(checker);
			checker.scrollFactor.set(0, 0.07);
			checker.antialiasing = FlxG.save.data.globalAntialiasing;
		}
		if (FlxG.save.data.terminalFound && !awaitingExploitation)
		{
			Catagories = ['dave', 'joke', 'extras', 'dave2.5', 'classic', 'cover', 'fanmade', 'finale', 'terminal'];
			translatedCatagory = [
				LanguageManager.getTextString('freeplay_dave'),
				LanguageManager.getTextString('freeplay_joke'),
				LanguageManager.getTextString('freeplay_extra'),
				LanguageManager.getTextString('freeplay_dave2.5'),
				LanguageManager.getTextString('freeplay_classic'),
				LanguageManager.getTextString('freeplay_cover'),
				LanguageManager.getTextString('freeplay_fanmade'),
		                LanguageManager.getTextString('freeplay_finale'),
				LanguageManager.getTextString('freeplay_terminal')];
		}

		for (i in 0...Catagories.length)
		{
			Highscore.load();

			var CurrentSongIcon:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('packs/' + (Catagories[i].toLowerCase()), "preload"));
			CurrentSongIcon.centerOffsets(false);
			CurrentSongIcon.x = (1000 * i + 1) + (512 - CurrentSongIcon.width);
			CurrentSongIcon.y = (FlxG.height / 2) - 256;
			CurrentSongIcon.antialiasing = true;

			var NameAlpha:Alphabet = new Alphabet(40, (FlxG.height / 2) - 282, translatedCatagory[i], true, false);
			NameAlpha.x = CurrentSongIcon.x;

			add(CurrentSongIcon);
			icons.push(CurrentSongIcon);
			add(NameAlpha);
			titles.push(NameAlpha);
		}


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(icons[CurrentPack].x + 256, icons[CurrentPack].y + 256);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		if (awaitingExploitation)
		{
			if (!packTransitionDone)
			{
				var curIcon = icons[CurrentPack];
				var curTitle = titles[CurrentPack];

				canInteract = false;
				var expungedPack:FlxSprite = new FlxSprite(curIcon.x, curIcon.y).loadGraphic(Paths.image('packs/uhoh', "preload"));
				expungedPack.centerOffsets(false);
				expungedPack.antialiasing = false;
				expungedPack.alpha = 0;
				add(expungedPack);

				var expungedTitle:Alphabet = new Alphabet(40, (FlxG.height / 2) - 282, 'uh oh', true, false);
				expungedTitle.x = expungedPack.x;
				add(expungedTitle);
			
				FlxTween.tween(curIcon, {alpha: 0}, 1);
				FlxTween.tween(curTitle, {alpha: 0}, 1);
				FlxTween.tween(expungedTitle, {alpha: 1}, 1);
				FlxTween.tween(expungedPack, {alpha: 1}, 1, {onComplete: function(tween:FlxTween)
				{
					icons[CurrentPack].destroy();
					titles[CurrentPack].destroy();
				
					icons[CurrentPack] = expungedPack;
					titles[CurrentPack] = expungedTitle;

					curIcon.alpha = 1;
					curTitle.alpha = 1;

					Catagories = ['uhoh'];
					translatedCatagory = ['uh oh'];
					packTransitionDone = true;
					canInteract = true;
				}});
			}
			else
			{
				var originalIconPos = icons[CurrentPack].getPosition();
				var originalTitlePos = titles[CurrentPack].getPosition();
				
				icons[CurrentPack].destroy();
				titles[CurrentPack].destroy();
								
				icons[CurrentPack].loadGraphic(Paths.image('packs/uhoh', "preload"));
				icons[CurrentPack].setPosition(originalIconPos.x, originalIconPos.y);
				icons[CurrentPack].centerOffsets(false);
				icons[CurrentPack].antialiasing = false;
				
				titles[CurrentPack] = new Alphabet(40, (FlxG.height / 2) - 282, 'uh oh', true, false);
				titles[CurrentPack].setPosition(originalTitlePos.x, originalTitlePos.y);
				
				Catagories = ['uhoh'];
				translatedCatagory = ['uh oh'];
			}
		}

		super.create();
	}

	public function LoadProperPack()
	{
		switch (Catagories[CurrentPack].toLowerCase())
		{
			case 'uhoh':
				addWeek(['Exploitation'], 16, ['expunged']);
			case 'dave':
				addWeek(['Warmup'], 0, ['dave']);
				addWeek(['House', 'Insanity', 'Polygonized'], 1, ['dave', 'dave-annoyed', 'dave-angey']);
				addWeek(['Blocked', 'Corn-Theft', 'Maze'], 2, ['bambi-new', 'bambi-new', 'bambi-new']);
				addWeek(['Splitathon'], 3, ['the-duo']);
				addWeek(['Shredder', 'Greetings', 'Interdimensional', 'Rano'], 4, ['bambi-new', 'tristan-festival', 'dave-festival-3d', 'dave-festival']);
			case 'joke':
				if (FlxG.save.data.hasPlayedMasterWeek)
				{
					addWeek(['Supernovae', 'Glitch', 'Master'], 5, ['bambi-joke']);
					addWeek(['Old-Supernovae', 'Old-Glitch'], 5, ['bambi-joke']);
					addWeek(['Vs-Dave-Thanksgiving'], 5, ['bambi-joke']);
				}				
				if (!FlxG.save.data.terminalFound)
				{
					if (FlxG.save.data.cheatingFound)
						addWeek(['Cheating'], 14, ['bambi-3d']);
					if (FlxG.save.data.unfairnessFound)
						addWeek(['Unfairness'], 15, ['bambi-unfair']);
						addWeek(['Cozen'], 15, ['bambi-unfair']);
				}
				if (FlxG.save.data.exbungoFound)
					addWeek(['Kabunga'], 6, ['exbungo']);

				if (FlxG.save.data.oppressionFound)
					addWeek(['Oppression'], 14, ['bambi-3d-old']);
				
				if (FlxG.save.data.roofsUnlocked)
					addWeek(['Roofs'], 7, ['baldi']);

				if (FlxG.save.data.secretUnlocked)
					addWeek(['Secret'], 5, ['marcello-dave']);

				if (FlxG.save.data.secretUnlocked)
					addWeek(['Secret-Mod-Leak'], 7, ['baldi']);

				if (FlxG.save.data.electricCockaldoodledooUnlocked)
					addWeek(['Bananacore', 'Eletric-Cockadoodledoo', 'Electric-Cockaldoodledoo'], 18, ['bananacoreicon', 'old-cicons', 'electricicons']);

			    addWeek(['Vs-Dave-Rap'], 1, ['dave-cool']);
				if(FlxG.save.data.vsDaveRapTwoFound)
				{
					addWeek(['Vs-Dave-Rap-Two'], 1, ['dave-cool']);
				}
			case 'extras':
				if (FlxG.save.data.recursedUnlocked)
					addWeek(['Recursed'], 10, ['recurser']);
			    addWeek(['Bonus-Song', 'Roots'], 1, ['dave', 'dave']);
				addWeek(['Bot-Trot'], 9, ['playrobot']);
				addWeek(['Escape-From-California'], 11, ['moldy']);
				addWeek(['Five-Nights'], 12, ['dave']);
				addWeek(['Bonkers'], 19, ['longnosejohn']);
				addWeek(['ThreeDimensional', 'Bf-Ugh', 'Adventure'], 8, ['tristan-opponent', 'tristan-opponent', 'tristan-opponent']);
				addWeek(['Overdrive'], 13, ['dave-awesome']);
				addWeek(['Mealie'], 2, ['bambi-loser']);
				addWeek(['Indignancy'], 2, ['bambi-angey']);
				addWeek(['Memory'], 1, ['dave']);
			case 'dave2.5':
				addWeek(['House-2.5', 'Insanity-2.5', 'Polygonized-2.5'], 1, ['dave-2.5', 'dave-annoyed-2.5', 'dave-angey-old']);
				addWeek(['Bonus-Song-2.5'], 1, ['dave-2.5']);
				addWeek(['Blocked-2.5', 'Corn-Theft-2.5', 'Maze-2.5'], 2, ['bambi-scrapped-3.0', 'bambi-scrapped-3.0', 'bambi-scrapped-3.0']);
			case 'classic':
				addWeek(['Old-House', 'Old-Insanity', 'Furiosity'], 1, ['dave-pre-alpha', 'dave-pre-alpha', 'furiosity-dave']);
				addWeek(['Old-Blocked', 'Old-Corn-Theft', 'Old-Maze', 'Beta-Maze'], 2, ['bambi-1.0', 'bambi-beta-2', 'bambi-beta-2', 'bambi-2.0']);
				addWeek(['Old-Splitathon'], 3, ['the-duo-old']);
				addWeek(['Old-Screwed', 'Screwed-V2'], 2, ['bambi-angey-old', 'bambi-angey-old']);
			case 'fanmade':
				addWeek(['Blitz', 'No-Legs'], 1, ['dave-annoyed', 'dave']);
				addWeek(['Duper'], 2, ['bambi-angey', 'bambi-new']);
				addWeek(['Cheating-Not-Cute'], 2, ['bambi_pissyboyBUTREALLYFAROMGPOMGGGG']);
				if (FlxG.save.data.importumaniaFound)
					addWeek(['Importumania'], 14, ['importumania']);
			case 'cover':
				addWeek(['Confronting-Yourself'], 4, ['tristan-festival']);
				addWeek(['Cob', 'Super-Saiyan'], 1, ['dave', 'dave-annoyed']);
				addWeek(['Foolhardy'], 2, ['zardyMyBeloved']);
				addWeek(['detected'], 1, ['dave-detected']);
				if (FlxG.save.data.electricCockaldoodledooUnlocked)
					addWeek(['Cuzsie-X-Kapi-Shipping-Cute'], 20, ['cuzsiee']);
			case 'finale':
				addWeek(['Mastered'], 1, ['dave-splitathon-mastered']);
			case 'terminal':
				if (FlxG.save.data.cheatingFound)
					addWeek(['Cheating'], 14, ['bambi-3d']);
				if (FlxG.save.data.riggedFound) // is back now
					addWeek(['Rigged'], 14, ['bambi-3d']);
				if (FlxG.save.data.unfairnessFound)
					addWeek(['Unfairness'], 15, ['bambi-unfair']);
				        addWeek(['Cozen'], 15, ['bambi-unfair']);
				if (FlxG.save.data.exploitationFound)
					addWeek(['Exploitation'], 16, ['expunged']);

				addWeek(['Enter Terminal'], 17, ['terminal']);

		}
	}

	var scoreBG:FlxSprite;

	public function GoToActualFreeplay()
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.itemType = 'Classic';
			songText.targetY = i;
			songText.scrollFactor.set();
			songText.alpha = 0;
			songText.y += 1000;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.scrollFactor.set();

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 0, 0, "", 32);
		scoreText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, LEFT);
		scoreText.antialiasing = true;
		scoreText.y = -225;
		scoreText.scrollFactor.set();

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.scrollFactor.set();
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 15, 0, "", 24);
		diffText.setFormat(Paths.font("comic.ttf"), 24, FlxColor.WHITE, LEFT);
		diffText.antialiasing = true;
		diffText.scrollFactor.set();

		if (showCharText)
		{
			characterSelectText = new FlxText(FlxG.width, FlxG.height, 0, LanguageManager.getTextString("freeplay_skipChar"), 18);
			characterSelectText.setFormat("Comic Sans MS Bold", 18, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			characterSelectText.borderSize = 1.5;
			characterSelectText.antialiasing = true;
			characterSelectText.scrollFactor.set();
			characterSelectText.alpha = 0;
			characterSelectText.x -= characterSelectText.textField.textWidth;
			characterSelectText.y -= characterSelectText.textField.textHeight;
			add(characterSelectText);

			FlxTween.tween(characterSelectText,{alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
		}
	
		add(diffText);
		add(scoreText);

		FlxTween.tween(scoreBG,{y: 0},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(scoreText,{y: -5},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(diffText,{y: 30},0.5,{ease: FlxEase.expoInOut});
		
		for (song in 0...grpSongs.length)
		{
			grpSongs.members[song].unlockY = true;

			// item.targetY = bullShit - curSelected;
			FlxTween.tween(grpSongs.members[song], {y: song, alpha: song == curSelected ? 1 : 0.6}, 0.5, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween)
			{
				grpSongs.members[song].unlockY = false;

				canInteract = true;
			}});
		}

		changeSelection();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
