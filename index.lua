Graphics.init()
Sound.init()

emulator = System.doesFileExist(System.currentDirectory().."is_citra")
if not emulator and System.currentDirectory() == "/" then
	System.currentDirectory("romfs:/3ds/Windose3DS/")
end

LOADER = {}
LOADER_VARIABLES = {}
function loadNextAsset()
	if #LOADER == 0 then return end
	if #LOADER ~= #LOADER_VARIABLES then
		error(string.format("LOADER (%i) and LOADER_VARIABLES (%i) are not the same size!", #LOADER, #LOADER_VARIABLES))
	end
	local path = table.remove(LOADER, 1)
	local name = table.remove(LOADER_VARIABLES, 1)
	local type = path:sub(1, 3)
	if type == "img" then
		loadImage(path, name)
	elseif type == "aud" then
		loadSound(path, name)
	elseif type == "fonts" then
		loadFonts(path, name)
	end
end

UNLOADER = {}
function unloadNextAsset()
	if #UNLOADER == 0 then return end
	local data = table.remove(UNLOADER, 1)
	local asset, type = data[1], data[2]
	if type == "img" then
		unloadImage(asset)
	elseif type == "aud" then
		unloadSound(asset)
	elseif type == "fonts" then
		unloadFonts(asset)
	end
end

IMAGES = {}
function loadImage(path, name)
	local image = Graphics.loadImage(System.currentDirectory()..path)
	if not name then
		table.insert(IMAGES, image)
	else
		IMAGES[name] = image
	end
	return image
end

function unloadImage(image)
	for i,v in ipairs(IMAGES) do
		if v == image then
			table.remove(IMAGES, i)
		end
	end
	for k,v in pairs(IMAGES) do
		if v == image then
			IMAGES[k] = nil
		end
	end
	Graphics.freeImage(image)
end

SOUNDS = {}
function loadSound(path, name, streaming)
	local sound = Sound.openOgg(System.currentDirectory()..path, streaming or false)
	if not name then
		table.insert(SOUNDS, sound)
	else
		SOUNDS[name] = sound
	end
	return sound
end

function unloadSound(sound)
	for i,v in ipairs(SOUNDS) do
		if v == sound then
			table.remove(SOUNDS, i)
		end
	end
	for k,v in pairs(SOUNDS) do
		if v == sound then
			SOUNDS[k] = nil
		end
	end
	Sound.close(sound)
end

FONTS = {}
function loadFonts(path, name)
	local font = Font.load(System.currentDirectory()..path)
	if not name then
		table.insert(FONTS, font)
	else
		FONTS[name] = font
	end
	return font
end

function unloadFont(font)
	for i,v in ipairs(FONTS) do
		if v == font then
			table.remove(FONTS, i)
		end
	end
	for k,v in pairs(FONTS) do
		if v == font then
			FONTS[k] = nil
		end
	end
	Font.unload(font)
end

requirePath = emulator and System.currentDirectory() or ""
Battery = require(requirePath.."scripts/BatteryIndicator")
Cursor = require(requirePath.."scripts/Cursor")

bios_logo = loadImage("img/bios_logo.png")
bios_nso = loadImage("img/bios_nso.png")
bios_screen = loadImage("img/boot_bios.png")

bios_font = loadFonts("fonts/PixelMplus10-Regular.ttf")

bios = loadSound("aud/bgm/bios.ogg")

Sound.play(bios, LOOP)

COLORS = {
	white = Color.new(255,255,255),
	lime = Color.new(math.floor(255/2), 255, math.floor(255/2)),
	red = Color.new(255, 0, 0),
	gray = Color.new(200, 200, 200),

	main = Color.new(250, 222, 244)
}

State = "BIOS"

LOADER = {
	"img/bg_boot_en.png",
	"img/setup.png",

	"img/battery_1.png",
	"img/battery_2.png",
	"img/battery_3.png",
	"img/battery_4.png",
	"img/battery_5.png",
	"img/battery_charge.png",

	"aud/bgm/boot.ogg",

	"fonts/zpix.tff",
	"fonts/PixelMplus10-Bold.tff",
	"fonts/PerfectDOSVGA437.tff",
	"fonts/NotoSansKR-Medium.tff",
	"fonts/LiberationSans.tff",
	"fonts/DinkieBitmap-9px.tff",
	"fonts/DinkieBitmap-7px.tff"
}

LOADER_VARIABLES = {
	"win_boot",
	"setup",

	"battery1",
	"battery2",
	"battery3",
	"battery4",
	"battery5",
	"batteryCharge",

	"boot",

	"zpix_font",
	"pixel_font",
	"dos_font",
	"sansKR_font",
	"libeSans_font",
	"bitmap9_font",
	"bitmap7_font"
}

function changeState(new, old)
	if old == "BIOS" then
		table.insert(UNLOADER, {bios_screen, "img"})
		table.insert(UNLOADER, {bios_nso, "img"})
		table.insert(UNLOADER, {bios_logo, "img"})

		Sound.play(bios, NO_LOOP)
		if new == "BOOT" then
			Sound.play(SOUNDS["boot"], NO_LOOP)

			alpha = 0
		end
	elseif old == "BOOT" and new == "MENU" then
		table.insert(UNLOADER, {IMAGES["win_boot"], "img"})
		table.insert(UNLOADER, {SOUNDS["boot"], "aud"})

		Sound.play(SOUNDS["menu"], LOOP)
	end
	State = new
end

-- Main Loop
while true do

	-- Updating screens
	Screen.refresh()	

	--Graphics.fillRect(0, 600, 0, 600, COLORS.red)

	if State == "BIOS" then
		Graphics.initBlend(TOP_SCREEN)

		Graphics.drawScaleImage(-65, 0, bios_screen, 0.5, 0.5)
		Graphics.drawScaleImage(0, 0, bios_nso, 0.21, 0.21)
		Graphics.drawScaleImage(280, 5, bios_logo, 0.8, 0.8)

		Graphics.termBlend()

		local nb_dots = 2 * 7-#LOADER
		local dots = ""
		while nb_dots > 0 do
			dots = dots.."."
			nb_dots = nb_dots-1
		end

		Font.print(bios_font, 3, 220, "Booting Windose3DS"..dots, COLORS.gray, TOP_SCREEN)
		if #LOADER> 0 then
			Screen.debugPrint(5,180,"Size of LOADER: "..#LOADER, COLORS.red,TOP_SCREEN)
		else
			Screen.debugPrint(5,180,"Size of LOADER: "..#LOADER, COLORS.lime,TOP_SCREEN)
		end

		if #LOADER == 0 then
			changeState("BOOT", State)
		end
	elseif State == "BOOT" then
		Graphics.initBlend(TOP_SCREEN)

		Graphics.drawScaleImage(-40, 0, IMAGES["win_boot"], 0.5, 0.5, Color.new(255, 255, 255, alpha))
		alpha = alpha + 2
		if alpha > 255 then
			alpha = 255
			loadSound("aud/bgm/menu.ogg", "menu", true)
		end

		Graphics.termBlend()

		Screen.debugPrint(5,180,Sound.getTime(SOUNDS["boot"]).."/"..Sound.getTotalTime(SOUNDS["boot"]), COLORS.red,TOP_SCREEN)
		if Sound.getTime(SOUNDS["boot"]) >= Sound.getTotalTime(SOUNDS["boot"]) then
			changeState("MENU", State)
		end
	elseif State == "MENU" then
		Graphics.initBlend(TOP_SCREEN)

		Graphics.drawScaleImage(0, 0, IMAGES["setup"], 0.7, 0.7, Color.new(0, 0, 255))
		Battery.update()

		Graphics.termBlend()

		Graphics.initBlend(BOTTOM_SCREEN)

		Graphics.drawScaleImage(-60, -120, IMAGES["setup"], 0.7, 0.7, Color.new(0, 0, 255))
		Cursor.update()

		Graphics.termBlend()

		Screen.debugPrint(0, 100, "Cursor X/Y: "..Cursor.x..", "..Cursor.y, COLORS.white, BOTTOM_SCREEN)
		local touch_x, touch_y = Controls.readTouch()
		Screen.debugPrint(0, 120, "Touch X/Y: "..touch_x..", "..touch_y, COLORS.white, BOTTOM_SCREEN)
		local pad_x, pad_y = Controls.readCirclePad()
		Screen.debugPrint(0, 140, "Pad X/Y: "..pad_x..", "..pad_y, COLORS.white, BOTTOM_SCREEN)

		Sound.updateStream()
		Screen.debugPrint(5,180,Sound.getTime(SOUNDS["menu"]).."/"..Sound.getTotalTime(SOUNDS["menu"]), COLORS.red,TOP_SCREEN)
	end
	Screen.debugPrint(0, 100, "Battery Life: "..System.getBatteryLife(), COLORS.white, TOP_SCREEN)

	Screen.debugPrint(5,160,"State: "..State, COLORS.lime,TOP_SCREEN)

	--[[-- Writing something on screen
	Screen.debugPrint(0,0,"Needy Girl Overdose", COLORS.white,TOP_SCREEN)

	if Sound.isPlaying(boot) then
		Screen.debugPrint(0, 20, "boot playing", COLORS.lime, TOP_SCREEN)
		Screen.debugPrint(0, 40, Sound.getTime(boot).."/"..Sound.getTotalTime(boot), COLORS.white, TOP_SCREEN)
	else
		Screen.debugPrint(0, 20, "boot not playing", COLORS.red, TOP_SCREEN)
	end

	Screen.debugPrint(0, 65, "image exists: "..tostring(System.doesFileExist(System.currentDirectory().."img/boot_bios.png")), COLORS.white, TOP_SCREEN)

	Screen.debugPrint(0, 100, "Battery Life: "..System.getBatteryLife(), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 120, "3DS Model: "..System.getModel(), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 140, string.format("Kernel version: %i.%i.%i", System.getKernel()), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 160, string.format("Firmware version: %i.%i.%i", System.getFirmware()), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 180, "Lua Build: "..System.checkBuild(), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 200, "Homebrew Status: "..System.checkStatus(), COLORS.white, TOP_SCREEN)
	Screen.debugPrint(0, 220, "on Citra: "..tostring(emulator), COLORS.white, TOP_SCREEN)]]
	
	-- Flipping screen
	Screen.flip()
	Screen.waitVblankStart()

	-- Sets up HomeMenu syscall
	if Controls.check(Controls.read(),KEY_HOME) or Controls.check(Controls.read(),KEY_POWER) then
		--System.showHomeMenu()
		break
	end
	
	-- Exit if HomeMenu calls APP_EXITING
	if System.checkStatus() == APP_EXITING then
		break
	end
	
	loadNextAsset()
	unloadNextAsset()
end

for key,sound in pairs(SOUNDS) do
	Sound.close(sound)
end
Sound.term()

for key,image in pairs(IMAGES) do
	Graphics.freeImage(image)
end
Graphics.term()

for key,font in pairs(FONTS) do
	Font.unload(font)
end

System.exit()