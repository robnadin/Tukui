local T, C, L = select(2, ...):unpack()

local Miscellaneous = T["Miscellaneous"]
local Experience = CreateFrame("Frame", nil, UIParent)
local HideTooltip = GameTooltip_Hide
local Panels = T["Panels"]
local Bars = 20

Experience.NumBars = 2
Experience.RestedColor = {75 / 255, 175 / 255, 76 / 255}
Experience.XPColor = {0 / 255, 144 / 255, 255 / 255}
Experience.PetXPColor = {255 / 255, 255 / 255, 105 / 255}

function Experience:SetTooltip()
	local BarType = self.BarType
	local Current, Max, Pts

	if (self == Experience.XPBar1) then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -1, 5)
	else
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 1, 5)
	end

	if BarType == "XP" then
		local Rested = GetXPExhaustion()
		local IsRested = GetRestState()

		Current, Max = Experience:GetExperience()

		if Max == 0 then
			return
		end

		GameTooltip:AddLine("|cff0090FF"..XP..": " .. Current .. " / " .. Max .. " (" .. floor(Current / Max * 100) .. "% - " .. floor(Bars - (Bars * (Max - Current) / Max)) .. "/" .. Bars .. ")|r")

		if (IsRested == 1 and Rested) then
			GameTooltip:AddLine("|cff4BAF4C"..TUTORIAL_TITLE26..": +" .. Rested .." (" .. floor(Rested / Max * 100) .. "%)|r")
		end
	elseif BarType == "PETXP" then
		local Happiness, DamagePercentage, LoyaltyRate = GetPetHappiness()
		local Happy = ({"|cffFF0000Unhappy|r", "|cffFFFF00Content|r", "|cff00FF00Happy|r"})[Happiness]
		local Loyalty = LoyaltyRate > 0 and "|cff00FF00gaining|r" or "|cffFF0000losing|r"
		local PetIcon, PetName, PetLevel, PetType, PetLoyalty = GetStablePetInfo(0)

		Current, Max = GetPetExperience()
		
		if Max == 0 then
			return
		end

		GameTooltip:AddLine("" ..PetName.."")
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|cffFFFFFFType:|r","|cffFFFFFF"..PetType.."|r")
		GameTooltip:AddDoubleLine("|cffFFFFFFLevel:|r","|cffFFFFFF"..PetLevel.."|r")
		GameTooltip:AddDoubleLine("|cffFFFFFFHappiness:|r",""..Happy.."")
		GameTooltip:AddDoubleLine("|cffFFFFFFDamage:|r","|cffFFFFFF"..DamagePercentage.."%|r")
		GameTooltip:AddDoubleLine("|cffFFFFFFLoyalty:|r",""..Loyalty.."")
		GameTooltip:AddDoubleLine(" ")
		GameTooltip:AddLine("|cffFFFF66PET XP: " .. Current .. " / " .. Max .. " (" .. floor(Current / Max * 100) .. "% - " .. floor(Bars - (Bars * (Max - Current) / Max)) .. "/" .. Bars .. ")|r")
	end

	GameTooltip:Show()
end

function Experience:GetExperience()
	return UnitXP("player"), UnitXPMax("player")
end

function Experience:Update(event, owner)
	if (event == "UNIT_INVENTORY_CHANGED" and owner ~= "player") then
		return
	end

	local PlayerLevel = UnitLevel("player")

	local Current, Max = self:GetExperience()
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()

	for i = 1, self.NumBars do
		local Bar = self["XPBar"..i]
		local RestedBar = self["RestedBar"..i]
		local r, g, b
		local InstanceType = select(2, IsInInstance())
		local HavePetXP = select(2, HasPetUI())

		Bar.BarType = "XP"

		if i == 2 and HavePetXP then
			Current, Max = GetPetExperience()

			Bar.BarType = "PETXP"
		end

		local BarType = Bar.BarType

		Bar:SetMinMaxValues(0, Max)
		Bar:SetValue(Current)

		if (BarType == "XP" and IsRested == 1 and Rested) then
			RestedBar:Show()
			RestedBar:SetMinMaxValues(0, Max)
			RestedBar:SetValue(Rested + Current)
		else
			RestedBar:Hide()
		end

		if BarType == "XP" then
			r, g, b = unpack(self.XPColor)
		elseif BarType == "PETXP" then
			r, g, b = unpack(self.PetXPColor)
		end

		Bar:SetStatusBarColor(r, g, b)

		if Bar.BarType == "XP" and PlayerLevel == MAX_PLAYER_LEVEL then
			Bar:Hide()
		end
	end
end

function Experience:Create()
	for i = 1, self.NumBars do
		local XPBar = CreateFrame("StatusBar", "TukuiExperienceBar" .. i, UIParent)
		local RestedBar = CreateFrame("StatusBar", nil, XPBar)

		XPBar:SetStatusBarTexture(C.Medias.Normal)
		XPBar:EnableMouse()
		XPBar:SetFrameStrata("BACKGROUND")
		XPBar:SetFrameLevel(3)
		XPBar:CreateBackdrop()
		XPBar:SetScript("OnEnter", Experience.SetTooltip)
		XPBar:SetScript("OnLeave", HideTooltip)

		RestedBar:SetStatusBarTexture(C.Medias.Normal)
		RestedBar:SetFrameStrata("BACKGROUND")
		RestedBar:SetStatusBarColor(unpack(self.RestedColor))
		RestedBar:SetAllPoints(XPBar)
		RestedBar:SetOrientation("HORIZONTAL")
		RestedBar:SetFrameLevel(XPBar:GetFrameLevel() - 1)
		RestedBar:SetAlpha(.5)
		RestedBar:SetReverseFill(i == 2 and true)

		XPBar:SetSize(i == 1 and Panels.LeftChatBG:GetWidth() or Panels.RightChatBG:GetWidth(), 6)
		XPBar:Point("BOTTOMLEFT", i == 1 and Panels.LeftChatBG or Panels.RightChatBG, "TOPLEFT", 0, 4)
		XPBar:SetReverseFill(i == 2 and true)

		XPBar.Backdrop:CreateShadow()

		self["XPBar"..i] = XPBar
		self["RestedBar"..i] = RestedBar

		-- Add moving
		T.Movers:RegisterFrame(XPBar)
	end

	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_PET_EXPERIENCE")

	self:SetScript("OnEvent", self.Update)
end

function Experience:Enable()
	if not C.Misc.ExperienceEnable then
		return
	end

	if not self.IsCreated then
		self:Create()

		self.IsCreated = true
	end

	for i = 1, self.NumBars do
		if not self["XPBar"..i]:IsShown() then
			self["XPBar"..i]:Show()
		end

		if not self["RestedBar"..i]:IsShown() then
			self["RestedBar"..i]:Show()
		end
	end
end

function Experience:Disable()
	for i = 1, self.NumBars do
		if self["XPBar"..i]:IsShown() then
			self["XPBar"..i]:Hide()
		end

		if self["RestedBar"..i]:IsShown() then
			self["RestedBar"..i]:Hide()
		end
	end
end

Miscellaneous.Experience = Experience
