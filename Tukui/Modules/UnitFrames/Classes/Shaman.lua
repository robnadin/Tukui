local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))
local Movers = T["Movers"]

if (Class ~= "SHAMAN") then
	return
end

TukuiUnitFrames.TotemColors = {
	[1] = {.58,.23,.10},
	[2] = {.23,.45,.13},
	[3] = {.19,.48,.60},
	[4] = {.42,.18,.74},
}

TukuiUnitFrames.AddClassFeatures["SHAMAN"] = function(self)
	local HealthTexture = T.GetTexture(C["Textures"].UFHealthTexture)
	
	local totems = CreateFrame("Frame", "TukuiTotemBar", self)
	totems:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, 0)
	totems:SetFrameStrata(self.Health:GetFrameStrata())
	totems:SetFrameLevel(self.Health:GetFrameLevel() + 3)
	totems:SetSize(250, 6)
	totems:CreateBackdrop()
	totems.Destroy = {}

	for i = 1, 4 do
		local r, g, b = unpack(TukuiUnitFrames.TotemColors[i])

		totems[i] = CreateFrame("StatusBar", self:GetName().."Totem"..i, totems)
		totems[i]:CreateBackdrop()
		totems[i].Backdrop:SetParent(totems)

		totems[i]:SetStatusBarTexture(HealthTexture)
		totems[i]:SetStatusBarColor(r, g, b)
		totems[i]:SetMinMaxValues(0, 1)
		totems[i]:SetValue(0)

		totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
		totems[i].bg:SetAllPoints(totems[i])
		totems[i].bg:SetTexture(C.Medias.Blank)
		totems[i].bg.multiplier = 0.3

		totems[i].bg:SetVertexColor(r * .3, g * .3, b * .3)
		
		if i == 1 then
			totems[i]:Point("BOTTOMLEFT", totems, "BOTTOMLEFT", 0, 0)
			totems[i]:Size(61, 6)
		else
			totems[i]:Point("BOTTOMLEFT", totems[i-1], "BOTTOMRIGHT", 1, 0)
			totems[i]:Size(62, 6)
		end

		totems.Destroy[i] = CreateFrame("Button", totems[i]:GetName().."Destroy", UIParent, "SecureUnitButtonTemplate")
		totems.Destroy[i]:RegisterForClicks("RightButtonUp")
		totems.Destroy[i]:SetAllPoints(totems[i])
		totems.Destroy[i]:SetID(i)
		totems.Destroy[i]:SetAttribute("type2", "destroytotem")
		totems.Destroy[i]:SetAttribute("*totem-slot*", i)
	end
	
	self.Totems = totems
end
