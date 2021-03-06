<#
	.SYNOPSIS
	Print a color chart of 256 colors

	.DESCRIPTION
	Simple color chart of 256 colors ... leveraging a Hash of the Color by Name with:
		Color Values: Red, Green, and Blue
		ColorID: just a handy id
		Fore: the Foreground command
		Back: the Background command

	The colors are sorted by blue, then green, then red. It was the simplest way to
	group a rainbow-ish chart that I could think of.

	Ultimately, I expected this to be a handy hashtable to quick ref the colors for
	tables and output. However, since ConEmu doesn't seem to handle it as well as
	the default Win10 window (whodathunkit), I'll hold off on enhancing this much
	more.

	Also, there are some dupes in the list. I'd been looking for a handy name to val
	chart for ages, and stumble on one that I liked, but it had some errors (dupe names,
	dupe values, etc.). I _might_ clean this up if I revisit it.

	.EXAMPLE
	Get-Ansi256.ps1

	Lots of colors
	#>

## $Escape = "$([char]27)"
## FG: $Escape[38;2;${Red};${Blue};${Green}m
## BG: $Escape[48;2;${Red};${Blue};${Green}m
## $Off = "$Escape[0m"

$Colors = [ordered] @{}

$Colors.Add("DarkRed", @{r = 95; g = 0; b = 0; ColorID = 52; Fore = "$([char]27)[38;2;95;0;0m"; Back = "$([char]27)[48;2;95;0;0m"})
$Colors.Add("Maroon", @{r = 128; g = 0; b = 0; ColorID = 1; Fore = "$([char]27)[38;2;128;0;0m"; Back = "$([char]27)[48;2;128;0;0m"})
$Colors.Add("DarkRed1", @{r = 135; g = 0; b = 0; ColorID = 88; Fore = "$([char]27)[38;2;135;0;0m"; Back = "$([char]27)[48;2;135;0;0m"})
$Colors.Add("Red1", @{r = 175; g = 0; b = 0; ColorID = 124; Fore = "$([char]27)[38;2;175;0;0m"; Back = "$([char]27)[48;2;175;0;0m"})
$Colors.Add("Red3", @{r = 215; g = 0; b = 0; ColorID = 160; Fore = "$([char]27)[38;2;215;0;0m"; Back = "$([char]27)[48;2;215;0;0m"})
$Colors.Add("Red", @{r = 255; g = 0; b = 0; ColorID = 9; Fore = "$([char]27)[38;2;255;0;0m"; Back = "$([char]27)[48;2;255;0;0m"})
$Colors.Add("Red2", @{r = 255; g = 0; b = 0; ColorID = 196; Fore = "$([char]27)[38;2;255;0;0m"; Back = "$([char]27)[48;2;255;0;0m"})
$Colors.Add("DarkGreen", @{r = 0; g = 95; b = 0; ColorID = 22; Fore = "$([char]27)[38;2;0;95;0m"; Back = "$([char]27)[48;2;0;95;0m"})
$Colors.Add("Orange1", @{r = 95; g = 95; b = 0; ColorID = 58; Fore = "$([char]27)[38;2;95;95;0m"; Back = "$([char]27)[48;2;95;95;0m"})
$Colors.Add("Orange3", @{r = 135; g = 95; b = 0; ColorID = 94; Fore = "$([char]27)[38;2;135;95;0m"; Back = "$([char]27)[48;2;135;95;0m"})
$Colors.Add("DarkOrange1", @{r = 175; g = 95; b = 0; ColorID = 130; Fore = "$([char]27)[38;2;175;95;0m"; Back = "$([char]27)[48;2;175;95;0m"})
$Colors.Add("DarkOrange2", @{r = 215; g = 95; b = 0; ColorID = 166; Fore = "$([char]27)[38;2;215;95;0m"; Back = "$([char]27)[48;2;215;95;0m"})
$Colors.Add("OrangeRed", @{r = 255; g = 95; b = 0; ColorID = 202; Fore = "$([char]27)[38;2;255;95;0m"; Back = "$([char]27)[48;2;255;95;0m"})
$Colors.Add("Green", @{r = 0; g = 128; b = 0; ColorID = 2; Fore = "$([char]27)[38;2;0;128;0m"; Back = "$([char]27)[48;2;0;128;0m"})
$Colors.Add("Olive", @{r = 128; g = 128; b = 0; ColorID = 3; Fore = "$([char]27)[38;2;128;128;0m"; Back = "$([char]27)[48;2;128;128;0m"})
$Colors.Add("Green1", @{r = 0; g = 135; b = 0; ColorID = 28; Fore = "$([char]27)[38;2;0;135;0m"; Back = "$([char]27)[48;2;0;135;0m"})
$Colors.Add("Chartreuse1", @{r = 95; g = 135; b = 0; ColorID = 64; Fore = "$([char]27)[38;2;95;135;0m"; Back = "$([char]27)[48;2;95;135;0m"})
$Colors.Add("Yellow1", @{r = 135; g = 135; b = 0; ColorID = 100; Fore = "$([char]27)[38;2;135;135;0m"; Back = "$([char]27)[48;2;135;135;0m"})
$Colors.Add("DarkGoldenrod", @{r = 175; g = 135; b = 0; ColorID = 136; Fore = "$([char]27)[38;2;175;135;0m"; Back = "$([char]27)[48;2;175;135;0m"})
$Colors.Add("Orange2", @{r = 215; g = 135; b = 0; ColorID = 172; Fore = "$([char]27)[38;2;215;135;0m"; Back = "$([char]27)[48;2;215;135;0m"})
$Colors.Add("DarkOrange", @{r = 255; g = 135; b = 0; ColorID = 208; Fore = "$([char]27)[38;2;255;135;0m"; Back = "$([char]27)[48;2;255;135;0m"})
$Colors.Add("Green2", @{r = 0; g = 175; b = 0; ColorID = 34; Fore = "$([char]27)[38;2;0;175;0m"; Back = "$([char]27)[48;2;0;175;0m"})
$Colors.Add("Chartreuse2", @{r = 95; g = 175; b = 0; ColorID = 70; Fore = "$([char]27)[38;2;95;175;0m"; Back = "$([char]27)[48;2;95;175;0m"})
$Colors.Add("Yellow2", @{r = 135; g = 175; b = 0; ColorID = 106; Fore = "$([char]27)[38;2;135;175;0m"; Back = "$([char]27)[48;2;135;175;0m"})
$Colors.Add("Gold1", @{r = 175; g = 175; b = 0; ColorID = 142; Fore = "$([char]27)[38;2;175;175;0m"; Back = "$([char]27)[48;2;175;175;0m"})
$Colors.Add("Gold2", @{r = 215; g = 175; b = 0; ColorID = 178; Fore = "$([char]27)[38;2;215;175;0m"; Back = "$([char]27)[48;2;215;175;0m"})
$Colors.Add("Orange", @{r = 255; g = 175; b = 0; ColorID = 214; Fore = "$([char]27)[38;2;255;175;0m"; Back = "$([char]27)[48;2;255;175;0m"})
$Colors.Add("Green3", @{r = 0; g = 215; b = 0; ColorID = 40; Fore = "$([char]27)[38;2;0;215;0m"; Back = "$([char]27)[48;2;0;215;0m"})
$Colors.Add("Chartreuse3", @{r = 95; g = 215; b = 0; ColorID = 76; Fore = "$([char]27)[38;2;95;215;0m"; Back = "$([char]27)[48;2;95;215;0m"})
$Colors.Add("Chartreuse5", @{r = 135; g = 215; b = 0; ColorID = 112; Fore = "$([char]27)[38;2;135;215;0m"; Back = "$([char]27)[48;2;135;215;0m"})
$Colors.Add("Yellow3", @{r = 175; g = 215; b = 0; ColorID = 148; Fore = "$([char]27)[38;2;175;215;0m"; Back = "$([char]27)[48;2;175;215;0m"})
$Colors.Add("Yellow4", @{r = 215; g = 215; b = 0; ColorID = 184; Fore = "$([char]27)[38;2;215;215;0m"; Back = "$([char]27)[48;2;215;215;0m"})
$Colors.Add("Gold", @{r = 255; g = 215; b = 0; ColorID = 220; Fore = "$([char]27)[38;2;255;215;0m"; Back = "$([char]27)[48;2;255;215;0m"})
$Colors.Add("Green4", @{r = 0; g = 255; b = 0; ColorID = 46; Fore = "$([char]27)[38;2;0;255;0m"; Back = "$([char]27)[48;2;0;255;0m"})
$Colors.Add("Lime", @{r = 0; g = 255; b = 0; ColorID = 10; Fore = "$([char]27)[38;2;0;255;0m"; Back = "$([char]27)[48;2;0;255;0m"})
$Colors.Add("Chartreuse4", @{r = 95; g = 255; b = 0; ColorID = 82; Fore = "$([char]27)[38;2;95;255;0m"; Back = "$([char]27)[48;2;95;255;0m"})
$Colors.Add("Chartreuse", @{r = 135; g = 255; b = 0; ColorID = 118; Fore = "$([char]27)[38;2;135;255;0m"; Back = "$([char]27)[48;2;135;255;0m"})
$Colors.Add("GreenYellow", @{r = 175; g = 255; b = 0; ColorID = 154; Fore = "$([char]27)[38;2;175;255;0m"; Back = "$([char]27)[48;2;175;255;0m"})
$Colors.Add("Yellow5", @{r = 215; g = 255; b = 0; ColorID = 190; Fore = "$([char]27)[38;2;215;255;0m"; Back = "$([char]27)[48;2;215;255;0m"})
$Colors.Add("Yellow", @{r = 255; g = 255; b = 0; ColorID = 11; Fore = "$([char]27)[38;2;255;255;0m"; Back = "$([char]27)[48;2;255;255;0m"})
$Colors.Add("Yellow6", @{r = 255; g = 255; b = 0; ColorID = 226; Fore = "$([char]27)[38;2;255;255;0m"; Back = "$([char]27)[48;2;255;255;0m"})
$Colors.Add("NavyBlue", @{r = 0; g = 0; b = 95; ColorID = 17; Fore = "$([char]27)[38;2;0;0;95m"; Back = "$([char]27)[48;2;0;0;95m"})
$Colors.Add("DeepPink1", @{r = 95; g = 0; b = 95; ColorID = 53; Fore = "$([char]27)[38;2;95;0;95m"; Back = "$([char]27)[48;2;95;0;95m"})
$Colors.Add("DeepPink2", @{r = 135; g = 0; b = 95; ColorID = 89; Fore = "$([char]27)[38;2;135;0;95m"; Back = "$([char]27)[48;2;135;0;95m"})
$Colors.Add("DeepPink3", @{r = 175; g = 0; b = 95; ColorID = 125; Fore = "$([char]27)[38;2;175;0;95m"; Back = "$([char]27)[48;2;175;0;95m"})
$Colors.Add("DeepPink4", @{r = 215; g = 0; b = 95; ColorID = 161; Fore = "$([char]27)[38;2;215;0;95m"; Back = "$([char]27)[48;2;215;0;95m"})
$Colors.Add("DeepPink6", @{r = 255; g = 0; b = 95; ColorID = 197; Fore = "$([char]27)[38;2;255;0;95m"; Back = "$([char]27)[48;2;255;0;95m"})
$Colors.Add("DeepSkyBlue1", @{r = 0; g = 95; b = 95; ColorID = 23; Fore = "$([char]27)[38;2;0;95;95m"; Back = "$([char]27)[48;2;0;95;95m"})
$Colors.Add("LightPink1", @{r = 135; g = 95; b = 95; ColorID = 95; Fore = "$([char]27)[38;2;135;95;95m"; Back = "$([char]27)[48;2;135;95;95m"})
$Colors.Add("IndianRed", @{r = 175; g = 95; b = 95; ColorID = 131; Fore = "$([char]27)[38;2;175;95;95m"; Back = "$([char]27)[48;2;175;95;95m"})
$Colors.Add("IndianRed1", @{r = 215; g = 95; b = 95; ColorID = 167; Fore = "$([char]27)[38;2;215;95;95m"; Back = "$([char]27)[48;2;215;95;95m"})
$Colors.Add("IndianRed2", @{r = 255; g = 95; b = 95; ColorID = 203; Fore = "$([char]27)[38;2;255;95;95m"; Back = "$([char]27)[48;2;255;95;95m"})
$Colors.Add("SpringGreen1", @{r = 0; g = 135; b = 95; ColorID = 29; Fore = "$([char]27)[38;2;0;135;95m"; Back = "$([char]27)[48;2;0;135;95m"})
$Colors.Add("DarkSeaGreen1", @{r = 95; g = 135; b = 95; ColorID = 65; Fore = "$([char]27)[38;2;95;135;95m"; Back = "$([char]27)[48;2;95;135;95m"})
$Colors.Add("Wheat1", @{r = 135; g = 135; b = 95; ColorID = 101; Fore = "$([char]27)[38;2;135;135;95m"; Back = "$([char]27)[48;2;135;135;95m"})
$Colors.Add("LightSalmon1", @{r = 175; g = 135; b = 95; ColorID = 137; Fore = "$([char]27)[38;2;175;135;95m"; Back = "$([char]27)[48;2;175;135;95m"})
$Colors.Add("LightSalmon2", @{r = 215; g = 135; b = 95; ColorID = 173; Fore = "$([char]27)[38;2;215;135;95m"; Back = "$([char]27)[48;2;215;135;95m"})
$Colors.Add("Salmon", @{r = 255; g = 135; b = 95; ColorID = 209; Fore = "$([char]27)[38;2;255;135;95m"; Back = "$([char]27)[48;2;255;135;95m"})
$Colors.Add("SpringGreen2", @{r = 0; g = 175; b = 95; ColorID = 35; Fore = "$([char]27)[38;2;0;175;95m"; Back = "$([char]27)[48;2;0;175;95m"})
$Colors.Add("DarkSeaGreen2", @{r = 95; g = 175; b = 95; ColorID = 71; Fore = "$([char]27)[38;2;95;175;95m"; Back = "$([char]27)[48;2;95;175;95m"})
$Colors.Add("DarkOliveGreen", @{r = 135; g = 175; b = 95; ColorID = 107; Fore = "$([char]27)[38;2;135;175;95m"; Back = "$([char]27)[48;2;135;175;95m"})
$Colors.Add("DarkKhaki", @{r = 175; g = 175; b = 95; ColorID = 143; Fore = "$([char]27)[38;2;175;175;95m"; Back = "$([char]27)[48;2;175;175;95m"})
$Colors.Add("LightGoldenrod1", @{r = 215; g = 175; b = 95; ColorID = 179; Fore = "$([char]27)[38;2;215;175;95m"; Back = "$([char]27)[48;2;215;175;95m"})
$Colors.Add("SandyBrown", @{r = 255; g = 175; b = 95; ColorID = 215; Fore = "$([char]27)[38;2;255;175;95m"; Back = "$([char]27)[48;2;255;175;95m"})
$Colors.Add("SpringGreen3", @{r = 0; g = 215; b = 95; ColorID = 41; Fore = "$([char]27)[38;2;0;215;95m"; Back = "$([char]27)[48;2;0;215;95m"})
$Colors.Add("PaleGreen1", @{r = 95; g = 215; b = 95; ColorID = 77; Fore = "$([char]27)[38;2;95;215;95m"; Back = "$([char]27)[48;2;95;215;95m"})
$Colors.Add("DarkOliveGreen1", @{r = 135; g = 215; b = 95; ColorID = 113; Fore = "$([char]27)[38;2;135;215;95m"; Back = "$([char]27)[48;2;135;215;95m"})
$Colors.Add("DarkOliveGreen2", @{r = 175; g = 215; b = 95; ColorID = 149; Fore = "$([char]27)[38;2;175;215;95m"; Back = "$([char]27)[48;2;175;215;95m"})
$Colors.Add("Khaki1", @{r = 215; g = 215; b = 95; ColorID = 185; Fore = "$([char]27)[38;2;215;215;95m"; Back = "$([char]27)[48;2;215;215;95m"})
$Colors.Add("LightGoldenrod3", @{r = 255; g = 215; b = 95; ColorID = 221; Fore = "$([char]27)[38;2;255;215;95m"; Back = "$([char]27)[48;2;255;215;95m"})
$Colors.Add("SpringGreen5", @{r = 0; g = 255; b = 95; ColorID = 47; Fore = "$([char]27)[38;2;0;255;95m"; Back = "$([char]27)[48;2;0;255;95m"})
$Colors.Add("SeaGreen1", @{r = 95; g = 255; b = 95; ColorID = 83; Fore = "$([char]27)[38;2;95;255;95m"; Back = "$([char]27)[48;2;95;255;95m"})
$Colors.Add("LightGreen", @{r = 135; g = 255; b = 95; ColorID = 119; Fore = "$([char]27)[38;2;135;255;95m"; Back = "$([char]27)[48;2;135;255;95m"})
$Colors.Add("DarkOliveGreen3", @{r = 175; g = 255; b = 95; ColorID = 155; Fore = "$([char]27)[38;2;175;255;95m"; Back = "$([char]27)[48;2;175;255;95m"})
$Colors.Add("DarkOliveGreen4", @{r = 215; g = 255; b = 95; ColorID = 191; Fore = "$([char]27)[38;2;215;255;95m"; Back = "$([char]27)[48;2;215;255;95m"})
$Colors.Add("LightGoldenrod", @{r = 255; g = 255; b = 95; ColorID = 227; Fore = "$([char]27)[38;2;255;255;95m"; Back = "$([char]27)[48;2;255;255;95m"})
$Colors.Add("Navy", @{r = 0; g = 0; b = 128; ColorID = 4; Fore = "$([char]27)[38;2;0;0;128m"; Back = "$([char]27)[48;2;0;0;128m"})
$Colors.Add("Purple", @{r = 128; g = 0; b = 128; ColorID = 5; Fore = "$([char]27)[38;2;128;0;128m"; Back = "$([char]27)[48;2;128;0;128m"})
$Colors.Add("Teal", @{r = 0; g = 128; b = 128; ColorID = 6; Fore = "$([char]27)[38;2;0;128;128m"; Back = "$([char]27)[48;2;0;128;128m"})
$Colors.Add("DarkBlue", @{r = 0; g = 0; b = 135; ColorID = 18; Fore = "$([char]27)[38;2;0;0;135m"; Back = "$([char]27)[48;2;0;0;135m"})
$Colors.Add("Purple1", @{r = 95; g = 0; b = 135; ColorID = 54; Fore = "$([char]27)[38;2;95;0;135m"; Back = "$([char]27)[48;2;95;0;135m"})
$Colors.Add("DarkMagenta", @{r = 135; g = 0; b = 135; ColorID = 90; Fore = "$([char]27)[38;2;135;0;135m"; Back = "$([char]27)[48;2;135;0;135m"})
$Colors.Add("MediumVioletRed", @{r = 175; g = 0; b = 135; ColorID = 126; Fore = "$([char]27)[38;2;175;0;135m"; Back = "$([char]27)[48;2;175;0;135m"})
$Colors.Add("DeepPink5", @{r = 215; g = 0; b = 135; ColorID = 162; Fore = "$([char]27)[38;2;215;0;135m"; Back = "$([char]27)[48;2;215;0;135m"})
$Colors.Add("DeepPink", @{r = 255; g = 0; b = 135; ColorID = 198; Fore = "$([char]27)[38;2;255;0;135m"; Back = "$([char]27)[48;2;255;0;135m"})
$Colors.Add("DeepSkyBlue2", @{r = 0; g = 95; b = 135; ColorID = 24; Fore = "$([char]27)[38;2;0;95;135m"; Back = "$([char]27)[48;2;0;95;135m"})
$Colors.Add("MediumPurple1", @{r = 95; g = 95; b = 135; ColorID = 60; Fore = "$([char]27)[38;2;95;95;135m"; Back = "$([char]27)[48;2;95;95;135m"})
$Colors.Add("Plum1", @{r = 135; g = 95; b = 135; ColorID = 96; Fore = "$([char]27)[38;2;135;95;135m"; Back = "$([char]27)[48;2;135;95;135m"})
$Colors.Add("HotPink1", @{r = 175; g = 95; b = 135; ColorID = 132; Fore = "$([char]27)[38;2;175;95;135m"; Back = "$([char]27)[48;2;175;95;135m"})
$Colors.Add("HotPink2", @{r = 215; g = 95; b = 135; ColorID = 168; Fore = "$([char]27)[38;2;215;95;135m"; Back = "$([char]27)[48;2;215;95;135m"})
$Colors.Add("IndianRed3", @{r = 255; g = 95; b = 135; ColorID = 204; Fore = "$([char]27)[38;2;255;95;135m"; Back = "$([char]27)[48;2;255;95;135m"})
$Colors.Add("Turquoise1", @{r = 0; g = 135; b = 135; ColorID = 30; Fore = "$([char]27)[38;2;0;135;135m"; Back = "$([char]27)[48;2;0;135;135m"})
$Colors.Add("PaleTurquoise1", @{r = 95; g = 135; b = 135; ColorID = 66; Fore = "$([char]27)[38;2;95;135;135m"; Back = "$([char]27)[48;2;95;135;135m"})
$Colors.Add("RosyBrown", @{r = 175; g = 135; b = 135; ColorID = 138; Fore = "$([char]27)[38;2;175;135;135m"; Back = "$([char]27)[48;2;175;135;135m"})
$Colors.Add("LightPink2", @{r = 215; g = 135; b = 135; ColorID = 174; Fore = "$([char]27)[38;2;215;135;135m"; Back = "$([char]27)[48;2;215;135;135m"})
$Colors.Add("LightCoral", @{r = 255; g = 135; b = 135; ColorID = 210; Fore = "$([char]27)[38;2;255;135;135m"; Back = "$([char]27)[48;2;255;135;135m"})
$Colors.Add("DarkCyan", @{r = 0; g = 175; b = 135; ColorID = 36; Fore = "$([char]27)[38;2;0;175;135m"; Back = "$([char]27)[48;2;0;175;135m"})
$Colors.Add("CadetBlue", @{r = 95; g = 175; b = 135; ColorID = 72; Fore = "$([char]27)[38;2;95;175;135m"; Back = "$([char]27)[48;2;95;175;135m"})
$Colors.Add("DarkSeaGreen", @{r = 135; g = 175; b = 135; ColorID = 108; Fore = "$([char]27)[38;2;135;175;135m"; Back = "$([char]27)[48;2;135;175;135m"})
$Colors.Add("Tan", @{r = 215; g = 175; b = 135; ColorID = 180; Fore = "$([char]27)[38;2;215;175;135m"; Back = "$([char]27)[48;2;215;175;135m"})
$Colors.Add("LightSalmon", @{r = 255; g = 175; b = 135; ColorID = 216; Fore = "$([char]27)[38;2;255;175;135m"; Back = "$([char]27)[48;2;255;175;135m"})
$Colors.Add("SpringGreen4", @{r = 0; g = 215; b = 135; ColorID = 42; Fore = "$([char]27)[38;2;0;215;135m"; Back = "$([char]27)[48;2;0;215;135m"})
$Colors.Add("SeaGreen3", @{r = 95; g = 215; b = 135; ColorID = 78; Fore = "$([char]27)[38;2;95;215;135m"; Back = "$([char]27)[48;2;95;215;135m"})
$Colors.Add("PaleGreen2", @{r = 135; g = 215; b = 135; ColorID = 114; Fore = "$([char]27)[38;2;135;215;135m"; Back = "$([char]27)[48;2;135;215;135m"})
$Colors.Add("DarkSeaGreen4", @{r = 175; g = 215; b = 135; ColorID = 150; Fore = "$([char]27)[38;2;175;215;135m"; Back = "$([char]27)[48;2;175;215;135m"})
$Colors.Add("LightGoldenrod2", @{r = 215; g = 215; b = 135; ColorID = 186; Fore = "$([char]27)[38;2;215;215;135m"; Back = "$([char]27)[48;2;215;215;135m"})
$Colors.Add("LightGoldenrod4", @{r = 255; g = 215; b = 135; ColorID = 222; Fore = "$([char]27)[38;2;255;215;135m"; Back = "$([char]27)[48;2;255;215;135m"})
$Colors.Add("SpringGreen", @{r = 0; g = 255; b = 135; ColorID = 48; Fore = "$([char]27)[38;2;0;255;135m"; Back = "$([char]27)[48;2;0;255;135m"})
$Colors.Add("SeaGreen", @{r = 95; g = 255; b = 135; ColorID = 84; Fore = "$([char]27)[38;2;95;255;135m"; Back = "$([char]27)[48;2;95;255;135m"})
$Colors.Add("LightGreen1", @{r = 135; g = 255; b = 135; ColorID = 120; Fore = "$([char]27)[38;2;135;255;135m"; Back = "$([char]27)[48;2;135;255;135m"})
$Colors.Add("PaleGreen3", @{r = 175; g = 255; b = 135; ColorID = 156; Fore = "$([char]27)[38;2;175;255;135m"; Back = "$([char]27)[48;2;175;255;135m"})
$Colors.Add("DarkOliveGreen5", @{r = 215; g = 255; b = 135; ColorID = 192; Fore = "$([char]27)[38;2;215;255;135m"; Back = "$([char]27)[48;2;215;255;135m"})
$Colors.Add("Khaki", @{r = 255; g = 255; b = 135; ColorID = 228; Fore = "$([char]27)[38;2;255;255;135m"; Back = "$([char]27)[48;2;255;255;135m"})
$Colors.Add("Blue2", @{r = 0; g = 0; b = 175; ColorID = 19; Fore = "$([char]27)[38;2;0;0;175m"; Back = "$([char]27)[48;2;0;0;175m"})
$Colors.Add("Purple2", @{r = 95; g = 0; b = 175; ColorID = 55; Fore = "$([char]27)[38;2;95;0;175m"; Back = "$([char]27)[48;2;95;0;175m"})
$Colors.Add("DarkMagenta1", @{r = 135; g = 0; b = 175; ColorID = 91; Fore = "$([char]27)[38;2;135;0;175m"; Back = "$([char]27)[48;2;135;0;175m"})
$Colors.Add("Magenta1", @{r = 175; g = 0; b = 175; ColorID = 127; Fore = "$([char]27)[38;2;175;0;175m"; Back = "$([char]27)[48;2;175;0;175m"})
$Colors.Add("Magenta2", @{r = 215; g = 0; b = 175; ColorID = 163; Fore = "$([char]27)[38;2;215;0;175m"; Back = "$([char]27)[48;2;215;0;175m"})
$Colors.Add("DeepPink7", @{r = 255; g = 0; b = 175; ColorID = 199; Fore = "$([char]27)[38;2;255;0;175m"; Back = "$([char]27)[48;2;255;0;175m"})
$Colors.Add("DeepSkyBlue3", @{r = 0; g = 95; b = 175; ColorID = 25; Fore = "$([char]27)[38;2;0;95;175m"; Back = "$([char]27)[48;2;0;95;175m"})
$Colors.Add("SlateBlue1", @{r = 95; g = 95; b = 175; ColorID = 61; Fore = "$([char]27)[38;2;95;95;175m"; Back = "$([char]27)[48;2;95;95;175m"})
$Colors.Add("MediumPurple2", @{r = 135; g = 95; b = 175; ColorID = 97; Fore = "$([char]27)[38;2;135;95;175m"; Back = "$([char]27)[48;2;135;95;175m"})
$Colors.Add("MediumOrchid1", @{r = 175; g = 95; b = 175; ColorID = 133; Fore = "$([char]27)[38;2;175;95;175m"; Back = "$([char]27)[48;2;175;95;175m"})
$Colors.Add("HotPink3", @{r = 215; g = 95; b = 175; ColorID = 169; Fore = "$([char]27)[38;2;215;95;175m"; Back = "$([char]27)[48;2;215;95;175m"})
$Colors.Add("HotPink", @{r = 255; g = 95; b = 175; ColorID = 205; Fore = "$([char]27)[38;2;255;95;175m"; Back = "$([char]27)[48;2;255;95;175m"})
$Colors.Add("DeepSkyBlue4", @{r = 0; g = 135; b = 175; ColorID = 31; Fore = "$([char]27)[38;2;0;135;175m"; Back = "$([char]27)[48;2;0;135;175m"})
$Colors.Add("SteelBlue", @{r = 95; g = 135; b = 175; ColorID = 67; Fore = "$([char]27)[38;2;95;135;175m"; Back = "$([char]27)[48;2;95;135;175m"})
$Colors.Add("LightSlateGrey", @{r = 135; g = 135; b = 175; ColorID = 103; Fore = "$([char]27)[38;2;135;135;175m"; Back = "$([char]27)[48;2;135;135;175m"})
$Colors.Add("Pink1", @{r = 215; g = 135; b = 175; ColorID = 175; Fore = "$([char]27)[38;2;215;135;175m"; Back = "$([char]27)[48;2;215;135;175m"})
$Colors.Add("PaleVioletRed", @{r = 255; g = 135; b = 175; ColorID = 211; Fore = "$([char]27)[38;2;255;135;175m"; Back = "$([char]27)[48;2;255;135;175m"})
$Colors.Add("LightSeaGreen", @{r = 0; g = 175; b = 175; ColorID = 37; Fore = "$([char]27)[38;2;0;175;175m"; Back = "$([char]27)[48;2;0;175;175m"})
$Colors.Add("CadetBlue1", @{r = 95; g = 175; b = 175; ColorID = 73; Fore = "$([char]27)[38;2;95;175;175m"; Back = "$([char]27)[48;2;95;175;175m"})
$Colors.Add("LightSkyBlue1", @{r = 135; g = 175; b = 175; ColorID = 109; Fore = "$([char]27)[38;2;135;175;175m"; Back = "$([char]27)[48;2;135;175;175m"})
$Colors.Add("MistyRose1", @{r = 215; g = 175; b = 175; ColorID = 181; Fore = "$([char]27)[38;2;215;175;175m"; Back = "$([char]27)[48;2;215;175;175m"})
$Colors.Add("LightPink", @{r = 255; g = 175; b = 175; ColorID = 217; Fore = "$([char]27)[38;2;255;175;175m"; Back = "$([char]27)[48;2;255;175;175m"})
$Colors.Add("Cyan1", @{r = 0; g = 215; b = 175; ColorID = 43; Fore = "$([char]27)[38;2;0;215;175m"; Back = "$([char]27)[48;2;0;215;175m"})
$Colors.Add("Aquamarine2", @{r = 95; g = 215; b = 175; ColorID = 79; Fore = "$([char]27)[38;2;95;215;175m"; Back = "$([char]27)[48;2;95;215;175m"})
$Colors.Add("DarkSeaGreen3", @{r = 135; g = 215; b = 175; ColorID = 115; Fore = "$([char]27)[38;2;135;215;175m"; Back = "$([char]27)[48;2;135;215;175m"})
$Colors.Add("DarkSeaGreen5", @{r = 175; g = 215; b = 175; ColorID = 151; Fore = "$([char]27)[38;2;175;215;175m"; Back = "$([char]27)[48;2;175;215;175m"})
$Colors.Add("LightYellow", @{r = 215; g = 215; b = 175; ColorID = 187; Fore = "$([char]27)[38;2;215;215;175m"; Back = "$([char]27)[48;2;215;215;175m"})
$Colors.Add("MediumSpringGreen", @{r = 0; g = 255; b = 175; ColorID = 49; Fore = "$([char]27)[38;2;0;255;175m"; Back = "$([char]27)[48;2;0;255;175m"})
$Colors.Add("SeaGreen2", @{r = 95; g = 255; b = 175; ColorID = 85; Fore = "$([char]27)[38;2;95;255;175m"; Back = "$([char]27)[48;2;95;255;175m"})
$Colors.Add("PaleGreen", @{r = 135; g = 255; b = 175; ColorID = 121; Fore = "$([char]27)[38;2;135;255;175m"; Back = "$([char]27)[48;2;135;255;175m"})
$Colors.Add("DarkSeaGreen6", @{r = 175; g = 255; b = 175; ColorID = 157; Fore = "$([char]27)[38;2;175;255;175m"; Back = "$([char]27)[48;2;175;255;175m"})
$Colors.Add("DarkSeaGreen8", @{r = 215; g = 255; b = 175; ColorID = 193; Fore = "$([char]27)[38;2;215;255;175m"; Back = "$([char]27)[48;2;215;255;175m"})
$Colors.Add("Wheat", @{r = 255; g = 255; b = 175; ColorID = 229; Fore = "$([char]27)[38;2;255;255;175m"; Back = "$([char]27)[48;2;255;255;175m"})
$Colors.Add("Blue3", @{r = 0; g = 0; b = 215; ColorID = 20; Fore = "$([char]27)[38;2;0;0;215m"; Back = "$([char]27)[48;2;0;0;215m"})
$Colors.Add("Purple3", @{r = 95; g = 0; b = 215; ColorID = 56; Fore = "$([char]27)[38;2;95;0;215m"; Back = "$([char]27)[48;2;95;0;215m"})
$Colors.Add("DarkViolet", @{r = 135; g = 0; b = 215; ColorID = 92; Fore = "$([char]27)[38;2;135;0;215m"; Back = "$([char]27)[48;2;135;0;215m"})
$Colors.Add("DarkViolet1", @{r = 175; g = 0; b = 215; ColorID = 128; Fore = "$([char]27)[38;2;175;0;215m"; Back = "$([char]27)[48;2;175;0;215m"})
$Colors.Add("Magenta3", @{r = 215; g = 0; b = 215; ColorID = 164; Fore = "$([char]27)[38;2;215;0;215m"; Back = "$([char]27)[48;2;215;0;215m"})
$Colors.Add("Magenta5", @{r = 255; g = 0; b = 215; ColorID = 200; Fore = "$([char]27)[38;2;255;0;215m"; Back = "$([char]27)[48;2;255;0;215m"})
$Colors.Add("DodgerBlue1", @{r = 0; g = 95; b = 215; ColorID = 26; Fore = "$([char]27)[38;2;0;95;215m"; Back = "$([char]27)[48;2;0;95;215m"})
$Colors.Add("SlateBlue2", @{r = 95; g = 95; b = 215; ColorID = 62; Fore = "$([char]27)[38;2;95;95;215m"; Back = "$([char]27)[48;2;95;95;215m"})
$Colors.Add("MediumPurple3", @{r = 135; g = 95; b = 215; ColorID = 98; Fore = "$([char]27)[38;2;135;95;215m"; Back = "$([char]27)[48;2;135;95;215m"})
$Colors.Add("MediumOrchid", @{r = 175; g = 95; b = 215; ColorID = 134; Fore = "$([char]27)[38;2;175;95;215m"; Back = "$([char]27)[48;2;175;95;215m"})
$Colors.Add("Orchid", @{r = 215; g = 95; b = 215; ColorID = 170; Fore = "$([char]27)[38;2;215;95;215m"; Back = "$([char]27)[48;2;215;95;215m"})
$Colors.Add("HotPink4", @{r = 255; g = 95; b = 215; ColorID = 206; Fore = "$([char]27)[38;2;255;95;215m"; Back = "$([char]27)[48;2;255;95;215m"})
$Colors.Add("DeepSkyBlue5", @{r = 0; g = 135; b = 215; ColorID = 32; Fore = "$([char]27)[38;2;0;135;215m"; Back = "$([char]27)[48;2;0;135;215m"})
$Colors.Add("SteelBlue1", @{r = 95; g = 135; b = 215; ColorID = 68; Fore = "$([char]27)[38;2;95;135;215m"; Back = "$([char]27)[48;2;95;135;215m"})
$Colors.Add("MediumPurple", @{r = 135; g = 135; b = 215; ColorID = 104; Fore = "$([char]27)[38;2;135;135;215m"; Back = "$([char]27)[48;2;135;135;215m"})
$Colors.Add("MediumPurple5", @{r = 175; g = 135; b = 215; ColorID = 140; Fore = "$([char]27)[38;2;175;135;215m"; Back = "$([char]27)[48;2;175;135;215m"})
$Colors.Add("Plum2", @{r = 215; g = 135; b = 215; ColorID = 176; Fore = "$([char]27)[38;2;215;135;215m"; Back = "$([char]27)[48;2;215;135;215m"})
$Colors.Add("Orchid1", @{r = 255; g = 135; b = 215; ColorID = 212; Fore = "$([char]27)[38;2;255;135;215m"; Back = "$([char]27)[48;2;255;135;215m"})
$Colors.Add("DeepSkyBlue6", @{r = 0; g = 175; b = 215; ColorID = 38; Fore = "$([char]27)[38;2;0;175;215m"; Back = "$([char]27)[48;2;0;175;215m"})
$Colors.Add("SkyBlue1", @{r = 95; g = 175; b = 215; ColorID = 74; Fore = "$([char]27)[38;2;95;175;215m"; Back = "$([char]27)[48;2;95;175;215m"})
$Colors.Add("LightSkyBlue2", @{r = 135; g = 175; b = 215; ColorID = 110; Fore = "$([char]27)[38;2;135;175;215m"; Back = "$([char]27)[48;2;135;175;215m"})
$Colors.Add("LightSteelBlue1", @{r = 175; g = 175; b = 215; ColorID = 146; Fore = "$([char]27)[38;2;175;175;215m"; Back = "$([char]27)[48;2;175;175;215m"})
$Colors.Add("Thistle1", @{r = 215; g = 175; b = 215; ColorID = 182; Fore = "$([char]27)[38;2;215;175;215m"; Back = "$([char]27)[48;2;215;175;215m"})
$Colors.Add("Pink", @{r = 255; g = 175; b = 215; ColorID = 218; Fore = "$([char]27)[38;2;255;175;215m"; Back = "$([char]27)[48;2;255;175;215m"})
$Colors.Add("DarkTurquoise", @{r = 0; g = 215; b = 215; ColorID = 44; Fore = "$([char]27)[38;2;0;215;215m"; Back = "$([char]27)[48;2;0;215;215m"})
$Colors.Add("MediumTurquoise", @{r = 95; g = 215; b = 215; ColorID = 80; Fore = "$([char]27)[38;2;95;215;215m"; Back = "$([char]27)[48;2;95;215;215m"})
$Colors.Add("DarkSlateGray2", @{r = 135; g = 215; b = 215; ColorID = 116; Fore = "$([char]27)[38;2;135;215;215m"; Back = "$([char]27)[48;2;135;215;215m"})
$Colors.Add("LightCyan1", @{r = 175; g = 215; b = 215; ColorID = 152; Fore = "$([char]27)[38;2;175;215;215m"; Back = "$([char]27)[48;2;175;215;215m"})
$Colors.Add("MistyRose", @{r = 255; g = 215; b = 215; ColorID = 224; Fore = "$([char]27)[38;2;255;215;215m"; Back = "$([char]27)[48;2;255;215;215m"})
$Colors.Add("Cyan2", @{r = 0; g = 255; b = 215; ColorID = 50; Fore = "$([char]27)[38;2;0;255;215m"; Back = "$([char]27)[48;2;0;255;215m"})
$Colors.Add("Aquamarine", @{r = 95; g = 255; b = 215; ColorID = 86; Fore = "$([char]27)[38;2;95;255;215m"; Back = "$([char]27)[48;2;95;255;215m"})
$Colors.Add("Aquamarine3", @{r = 135; g = 255; b = 215; ColorID = 122; Fore = "$([char]27)[38;2;135;255;215m"; Back = "$([char]27)[48;2;135;255;215m"})
$Colors.Add("DarkSeaGreen7", @{r = 175; g = 255; b = 215; ColorID = 158; Fore = "$([char]27)[38;2;175;255;215m"; Back = "$([char]27)[48;2;175;255;215m"})
$Colors.Add("Honeydew2", @{r = 215; g = 255; b = 215; ColorID = 194; Fore = "$([char]27)[38;2;215;255;215m"; Back = "$([char]27)[48;2;215;255;215m"})
$Colors.Add("Cornsilk1", @{r = 255; g = 255; b = 215; ColorID = 230; Fore = "$([char]27)[38;2;255;255;215m"; Back = "$([char]27)[48;2;255;255;215m"})
$Colors.Add("Blue", @{r = 0; g = 0; b = 255; ColorID = 12; Fore = "$([char]27)[38;2;0;0;255m"; Back = "$([char]27)[48;2;0;0;255m"})
$Colors.Add("Blue1", @{r = 0; g = 0; b = 255; ColorID = 21; Fore = "$([char]27)[38;2;0;0;255m"; Back = "$([char]27)[48;2;0;0;255m"})
$Colors.Add("BlueViolet", @{r = 95; g = 0; b = 255; ColorID = 57; Fore = "$([char]27)[38;2;95;0;255m"; Back = "$([char]27)[48;2;95;0;255m"})
$Colors.Add("Purple4", @{r = 135; g = 0; b = 255; ColorID = 93; Fore = "$([char]27)[38;2;135;0;255m"; Back = "$([char]27)[48;2;135;0;255m"})
$Colors.Add("Purple5", @{r = 175; g = 0; b = 255; ColorID = 129; Fore = "$([char]27)[38;2;175;0;255m"; Back = "$([char]27)[48;2;175;0;255m"})
$Colors.Add("Magenta4", @{r = 215; g = 0; b = 255; ColorID = 165; Fore = "$([char]27)[38;2;215;0;255m"; Back = "$([char]27)[48;2;215;0;255m"})
$Colors.Add("Fuchsia", @{r = 255; g = 0; b = 255; ColorID = 13; Fore = "$([char]27)[38;2;255;0;255m"; Back = "$([char]27)[48;2;255;0;255m"})
$Colors.Add("Magenta", @{r = 255; g = 0; b = 255; ColorID = 201; Fore = "$([char]27)[38;2;255;0;255m"; Back = "$([char]27)[48;2;255;0;255m"})
$Colors.Add("DodgerBlue2", @{r = 0; g = 95; b = 255; ColorID = 27; Fore = "$([char]27)[38;2;0;95;255m"; Back = "$([char]27)[48;2;0;95;255m"})
$Colors.Add("RoyalBlue", @{r = 95; g = 95; b = 255; ColorID = 63; Fore = "$([char]27)[38;2;95;95;255m"; Back = "$([char]27)[48;2;95;95;255m"})
$Colors.Add("SlateBlue", @{r = 135; g = 95; b = 255; ColorID = 99; Fore = "$([char]27)[38;2;135;95;255m"; Back = "$([char]27)[48;2;135;95;255m"})
$Colors.Add("MediumPurple4", @{r = 175; g = 95; b = 255; ColorID = 135; Fore = "$([char]27)[38;2;175;95;255m"; Back = "$([char]27)[48;2;175;95;255m"})
$Colors.Add("MediumOrchid2", @{r = 215; g = 95; b = 255; ColorID = 171; Fore = "$([char]27)[38;2;215;95;255m"; Back = "$([char]27)[48;2;215;95;255m"})
$Colors.Add("MediumOrchid3", @{r = 255; g = 95; b = 255; ColorID = 207; Fore = "$([char]27)[38;2;255;95;255m"; Back = "$([char]27)[48;2;255;95;255m"})
$Colors.Add("DodgerBlue", @{r = 0; g = 135; b = 255; ColorID = 33; Fore = "$([char]27)[38;2;0;135;255m"; Back = "$([char]27)[48;2;0;135;255m"})
$Colors.Add("CornflowerBlue", @{r = 95; g = 135; b = 255; ColorID = 69; Fore = "$([char]27)[38;2;95;135;255m"; Back = "$([char]27)[48;2;95;135;255m"})
$Colors.Add("LightSlateBlue", @{r = 135; g = 135; b = 255; ColorID = 105; Fore = "$([char]27)[38;2;135;135;255m"; Back = "$([char]27)[48;2;135;135;255m"})
$Colors.Add("MediumPurple6", @{r = 175; g = 135; b = 255; ColorID = 141; Fore = "$([char]27)[38;2;175;135;255m"; Back = "$([char]27)[48;2;175;135;255m"})
$Colors.Add("Violet", @{r = 215; g = 135; b = 255; ColorID = 177; Fore = "$([char]27)[38;2;215;135;255m"; Back = "$([char]27)[48;2;215;135;255m"})
$Colors.Add("Orchid2", @{r = 255; g = 135; b = 255; ColorID = 213; Fore = "$([char]27)[38;2;255;135;255m"; Back = "$([char]27)[48;2;255;135;255m"})
$Colors.Add("DeepSkyBlue", @{r = 0; g = 175; b = 255; ColorID = 39; Fore = "$([char]27)[38;2;0;175;255m"; Back = "$([char]27)[48;2;0;175;255m"})
$Colors.Add("SteelBlue2", @{r = 95; g = 175; b = 255; ColorID = 75; Fore = "$([char]27)[38;2;95;175;255m"; Back = "$([char]27)[48;2;95;175;255m"})
$Colors.Add("SkyBlue2", @{r = 135; g = 175; b = 255; ColorID = 111; Fore = "$([char]27)[38;2;135;175;255m"; Back = "$([char]27)[48;2;135;175;255m"})
$Colors.Add("LightSteelBlue", @{r = 175; g = 175; b = 255; ColorID = 147; Fore = "$([char]27)[38;2;175;175;255m"; Back = "$([char]27)[48;2;175;175;255m"})
$Colors.Add("Plum3", @{r = 215; g = 175; b = 255; ColorID = 183; Fore = "$([char]27)[38;2;215;175;255m"; Back = "$([char]27)[48;2;215;175;255m"})
$Colors.Add("Plum", @{r = 255; g = 175; b = 255; ColorID = 219; Fore = "$([char]27)[38;2;255;175;255m"; Back = "$([char]27)[48;2;255;175;255m"})
$Colors.Add("Turquoise", @{r = 0; g = 215; b = 255; ColorID = 45; Fore = "$([char]27)[38;2;0;215;255m"; Back = "$([char]27)[48;2;0;215;255m"})
$Colors.Add("SteelBlue3", @{r = 95; g = 215; b = 255; ColorID = 81; Fore = "$([char]27)[38;2;95;215;255m"; Back = "$([char]27)[48;2;95;215;255m"})
$Colors.Add("SkyBlue", @{r = 135; g = 215; b = 255; ColorID = 117; Fore = "$([char]27)[38;2;135;215;255m"; Back = "$([char]27)[48;2;135;215;255m"})
$Colors.Add("LightSkyBlue", @{r = 175; g = 215; b = 255; ColorID = 153; Fore = "$([char]27)[38;2;175;215;255m"; Back = "$([char]27)[48;2;175;215;255m"})
$Colors.Add("LightSteelBlue2", @{r = 215; g = 215; b = 255; ColorID = 189; Fore = "$([char]27)[38;2;215;215;255m"; Back = "$([char]27)[48;2;215;215;255m"})
$Colors.Add("Thistle", @{r = 255; g = 215; b = 255; ColorID = 225; Fore = "$([char]27)[38;2;255;215;255m"; Back = "$([char]27)[48;2;255;215;255m"})
$Colors.Add("Aqua", @{r = 0; g = 255; b = 255; ColorID = 14; Fore = "$([char]27)[38;2;0;255;255m"; Back = "$([char]27)[48;2;0;255;255m"})
$Colors.Add("Cyan", @{r = 0; g = 255; b = 255; ColorID = 51; Fore = "$([char]27)[38;2;0;255;255m"; Back = "$([char]27)[48;2;0;255;255m"})
$Colors.Add("DarkSlateGray1", @{r = 95; g = 255; b = 255; ColorID = 87; Fore = "$([char]27)[38;2;95;255;255m"; Back = "$([char]27)[48;2;95;255;255m"})
$Colors.Add("DarkSlateGray", @{r = 135; g = 255; b = 255; ColorID = 123; Fore = "$([char]27)[38;2;135;255;255m"; Back = "$([char]27)[48;2;135;255;255m"})
$Colors.Add("PaleTurquoise", @{r = 175; g = 255; b = 255; ColorID = 159; Fore = "$([char]27)[38;2;175;255;255m"; Back = "$([char]27)[48;2;175;255;255m"})
$Colors.Add("LightCyan", @{r = 215; g = 255; b = 255; ColorID = 195; Fore = "$([char]27)[38;2;215;255;255m"; Back = "$([char]27)[48;2;215;255;255m"})
$Colors.Add("Black", @{r = 0; g = 0; b = 0; ColorID = 0; Fore = "$([char]27)[38;2;0;0;0m"; Back = "$([char]27)[48;2;0;0;0m"})
$Colors.Add("White", @{r = 255; g = 255; b = 255; ColorID = 15; Fore = "$([char]27)[38;2;255;255;255m"; Back = "$([char]27)[48;2;255;255;255m"})
$Colors.Add("NavajoWhite", @{r = 255; g = 215; b = 175; ColorID = 223; Fore = "$([char]27)[38;2;255;215;175m"; Back = "$([char]27)[48;2;255;215;175m"})
$Colors.Add("NavajoWhite2", @{r = 175; g = 175; b = 135; ColorID = 144; Fore = "$([char]27)[38;2;175;175;135m"; Back = "$([char]27)[48;2;175;175;135m"})
$Colors.Add("Silver", @{r = 192; g = 192; b = 192; ColorID = 7; Fore = "$([char]27)[38;2;192;192;192m"; Back = "$([char]27)[48;2;192;192;192m"})
$Colors.Add("Grey", @{r = 128; g = 128; b = 128; ColorID = 8; Fore = "$([char]27)[38;2;128;128;128m"; Back = "$([char]27)[48;2;128;128;128m"})
$Colors.Add("Grey0", @{r = 0; g = 0; b = 0; ColorID = 16; Fore = "$([char]27)[38;2;0;0;0m"; Back = "$([char]27)[48;2;0;0;0m"})
$Colors.Add("Grey1", @{r = 8; g = 8; b = 8; ColorID = 232; Fore = "$([char]27)[38;2;8;8;8m"; Back = "$([char]27)[48;2;8;8;8m"})
$Colors.Add("Grey2", @{r = 18; g = 18; b = 18; ColorID = 233; Fore = "$([char]27)[38;2;18;18;18m"; Back = "$([char]27)[48;2;18;18;18m"})
$Colors.Add("Grey3", @{r = 28; g = 28; b = 28; ColorID = 234; Fore = "$([char]27)[38;2;28;28;28m"; Back = "$([char]27)[48;2;28;28;28m"})
$Colors.Add("Grey4", @{r = 38; g = 38; b = 38; ColorID = 235; Fore = "$([char]27)[38;2;38;38;38m"; Back = "$([char]27)[48;2;38;38;38m"})
$Colors.Add("Grey5", @{r = 48; g = 48; b = 48; ColorID = 236; Fore = "$([char]27)[38;2;48;48;48m"; Back = "$([char]27)[48;2;48;48;48m"})
$Colors.Add("Grey6", @{r = 58; g = 58; b = 58; ColorID = 237; Fore = "$([char]27)[38;2;58;58;58m"; Back = "$([char]27)[48;2;58;58;58m"})
$Colors.Add("Grey7", @{r = 68; g = 68; b = 68; ColorID = 238; Fore = "$([char]27)[38;2;68;68;68m"; Back = "$([char]27)[48;2;68;68;68m"})
$Colors.Add("Grey8", @{r = 78; g = 78; b = 78; ColorID = 239; Fore = "$([char]27)[38;2;78;78;78m"; Back = "$([char]27)[48;2;78;78;78m"})
$Colors.Add("Grey9", @{r = 88; g = 88; b = 88; ColorID = 240; Fore = "$([char]27)[38;2;88;88;88m"; Back = "$([char]27)[48;2;88;88;88m"})
$Colors.Add("Grey10", @{r = 95; g = 95; b = 95; ColorID = 59; Fore = "$([char]27)[38;2;95;95;95m"; Back = "$([char]27)[48;2;95;95;95m"})
$Colors.Add("Grey11", @{r = 98; g = 98; b = 98; ColorID = 241; Fore = "$([char]27)[38;2;98;98;98m"; Back = "$([char]27)[48;2;98;98;98m"})
$Colors.Add("Grey12", @{r = 108; g = 108; b = 108; ColorID = 242; Fore = "$([char]27)[38;2;108;108;108m"; Back = "$([char]27)[48;2;108;108;108m"})
$Colors.Add("Grey13", @{r = 118; g = 118; b = 118; ColorID = 243; Fore = "$([char]27)[38;2;118;118;118m"; Back = "$([char]27)[48;2;118;118;118m"})
$Colors.Add("Grey14", @{r = 128; g = 128; b = 128; ColorID = 244; Fore = "$([char]27)[38;2;128;128;128m"; Back = "$([char]27)[48;2;128;128;128m"})
$Colors.Add("Grey15", @{r = 135; g = 135; b = 135; ColorID = 102; Fore = "$([char]27)[38;2;135;135;135m"; Back = "$([char]27)[48;2;135;135;135m"})
$Colors.Add("Grey16", @{r = 138; g = 138; b = 138; ColorID = 245; Fore = "$([char]27)[38;2;138;138;138m"; Back = "$([char]27)[48;2;138;138;138m"})
$Colors.Add("Grey17", @{r = 148; g = 148; b = 148; ColorID = 246; Fore = "$([char]27)[38;2;148;148;148m"; Back = "$([char]27)[48;2;148;148;148m"})
$Colors.Add("Grey18", @{r = 158; g = 158; b = 158; ColorID = 247; Fore = "$([char]27)[38;2;158;158;158m"; Back = "$([char]27)[48;2;158;158;158m"})
$Colors.Add("Grey19", @{r = 165; g = 165; b = 165; ColorID = 139; Fore = "$([char]27)[38;2;165;165;165m"; Back = "$([char]27)[48;2;165;165;165m"})
$Colors.Add("Grey20", @{r = 168; g = 168; b = 168; ColorID = 248; Fore = "$([char]27)[38;2;168;168;168m"; Back = "$([char]27)[48;2;168;168;168m"})
$Colors.Add("Grey21", @{r = 175; g = 175; b = 175; ColorID = 145; Fore = "$([char]27)[38;2;175;175;175m"; Back = "$([char]27)[48;2;175;175;175m"})
$Colors.Add("Grey22", @{r = 178; g = 178; b = 178; ColorID = 249; Fore = "$([char]27)[38;2;178;178;178m"; Back = "$([char]27)[48;2;178;178;178m"})
$Colors.Add("Grey23", @{r = 188; g = 188; b = 188; ColorID = 250; Fore = "$([char]27)[38;2;188;188;188m"; Back = "$([char]27)[48;2;188;188;188m"})
$Colors.Add("Grey24", @{r = 198; g = 198; b = 198; ColorID = 251; Fore = "$([char]27)[38;2;198;198;198m"; Back = "$([char]27)[48;2;198;198;198m"})
$Colors.Add("Grey25", @{r = 208; g = 208; b = 208; ColorID = 252; Fore = "$([char]27)[38;2;208;208;208m"; Back = "$([char]27)[48;2;208;208;208m"})
$Colors.Add("Grey26", @{r = 215; g = 215; b = 215; ColorID = 188; Fore = "$([char]27)[38;2;215;215;215m"; Back = "$([char]27)[48;2;215;215;215m"})
$Colors.Add("Grey27", @{r = 218; g = 218; b = 218; ColorID = 253; Fore = "$([char]27)[38;2;218;218;218m"; Back = "$([char]27)[48;2;218;218;218m"})
$Colors.Add("Grey28", @{r = 228; g = 228; b = 228; ColorID = 254; Fore = "$([char]27)[38;2;228;228;228m"; Back = "$([char]27)[48;2;228;228;228m"})
$Colors.Add("Grey29", @{r = 238; g = 238; b = 238; ColorID = 255; Fore = "$([char]27)[38;2;238;238;238m"; Back = "$([char]27)[48;2;238;238;238m"})
$Colors.Add("Grey30", @{r = 255; g = 255; b = 255; ColorID = 231; Fore = "$([char]27)[38;2;255;255;255m"; Back = "$([char]27)[48;2;255;255;255m"})
$Colors.Add("Off", @{r = 255; g = 255; b = 255; ColorID = 256; Fore = "$([char]27)[0m"; Back = "$([char]27)[0m"})

if ($env:ConEmuANSI -eq 'ON') {
	# ConEMU requires either scroll buffer = 0 or scroll to the very bottom and write...
	# Win10 console works without this
	write-host "$([char]27)[9999; 1H" -NoNewline
}

[int] $width = ($host.Ui.RawUI.BufferSize.Width / 19)
[int] $i = 0
$Colors.GetEnumerator() | ForEach-Object {
	$i += 1
	write-host "$($_.Value.Fore)$($_.Name.PadLeft(2).PadRight(17))" -NoNewline
	if ($i -ge $width) { write-host ''; $i = 0}
}
write-host ''

[int] $i = 0
$Colors.GetEnumerator() | ForEach-Object {
	$i += 1
	write-host "$($_.Value.Back)$($_.Name.PadLeft(2).PadRight(17))" -NoNewline
	if ($i -ge $width) { write-host ''; $i = 0}

}
write-host ''
