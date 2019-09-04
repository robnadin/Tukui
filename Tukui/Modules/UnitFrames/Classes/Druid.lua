local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))

if (Class ~= "DRUID") then
	return
end

TukuiUnitFrames.AddClassFeatures["DRUID"] = function(self)
	local Texture = T.GetTexture(C["Textures"].UFPowerTexture)
	
	local DruidMana = CreateFrame("StatusBar", nil, self.Health)
	DruidMana:SetFrameStrata(self.Health:GetFrameStrata())
	DruidMana:SetHeight(self.Health:GetFrameLevel() + 1)
	DruidMana:SetPoint("LEFT")
	DruidMana:SetPoint("RIGHT")
	DruidMana:SetPoint("BOTTOM")
	DruidMana:SetStatusBarTexture(Texture)
	DruidMana:SetStatusBarColor(unpack(T.Colors.power["MANA"]))

	local Background = DruidMana:CreateTexture(nil, "BACKGROUND")
	Background:SetPoint("LEFT")
	Background:SetPoint("RIGHT")
	Background:SetPoint("BOTTOM")
	Background:SetPoint("TOP", 0, 1)
	Background:SetColorTexture(.1, .1, .1)

	self.DruidMana = DruidMana
	self.DruidMana.bg = Background
end
