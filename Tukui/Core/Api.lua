local T, C, L = select(2, ...):unpack()
local Toolkit = UIToolkit
local Settings = Toolkit.Settings
local API = Toolkit.API
local Functions = Toolkit.Functions
local Scales = Toolkit.UIScales
local Frames = Toolkit.Frames
local IsConfigLoaded = IsAddOnLoaded("Tukui_Config")

if IsConfigLoaded then
	-- Update Scaling Options from Toolkit Default
	C.General.Scaling.Options = Scales
	C.General.Scaling.Value = Scales["Pixel Perfection"]
end

-- Settings we want to use for our API
Settings.UIScale = C.General.Scaling.Value
Settings.DefaultTexture = C.Medias.Blank
Settings.DefaultFont = C.Medias.Font
Settings.BackdropColor = { .1,.1,.1 }
Settings.BorderColor = { 0, 0, 0 }
Settings.ArrowUp = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowUp]]
Settings.ArrowDown = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowDown]]

if C.General.HideShadows then
	Settings.ShadowGlowTexture = ""
else
	Settings.ShadowGlowTexture = C.Medias.Glow
end

-- Enable the API
Toolkit:Enable()

-- I want to use Toolkit Hider Frame in all my frames, register it to Tukui
T.Hider = Frames.Hider