local T, C, L = select(2, ...):unpack()
local Toolkit = APIToolkit

-- Settings we want to use for our API
Toolkit.Mult = T.Mult
Toolkit.Scale = T.Scale
Toolkit.DefaultTexture = C.Medias.Blank
Toolkit.DefaultFont = C.Medias.Font
Toolkit.BackdropColor = { .1,.1,.1 }
Toolkit.BorderColor = { 0, 0, 0 }
Toolkit.ArrowUp = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowUp]]
Toolkit.ArrowDown = [[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowDown]]

if C.General.HideShadows then
	Toolkit.ShadowGlowTexture = ""
else
	Toolkit.ShadowGlowTexture = C.Medias.Glow
end

-- Enable the API
Toolkit:Enable()

-- I want to use Toolkit Hider Frame in all my frames, register it to Tukui
T.Hider = Toolkit.Hider