local T, C, L = select(2, ...):unpack()
local Toolkit = T00LKIT
local Settings = Toolkit.Settings
local API = Toolkit.API
local Functions = Toolkit.Functions
local Scales = Toolkit.UIScales
local Frames = Toolkit.Frames

-- Enable the API
Toolkit:Enable()

-- Settings we want to use for our API
Settings.NormalTexture = C.Medias.Blank
Settings.ShadowTexture = C.Medias.Glow
Settings.DefaultFont = C.Medias.Font
Settings.BackdropColor = C.General.BackdropColor
Settings.BorderColor = C.General.BorderColor
Settings.ArrowUp = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowUp]]
Settings.ArrowDown = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowDown]]
Settings.ClassColors = T.Colors.class