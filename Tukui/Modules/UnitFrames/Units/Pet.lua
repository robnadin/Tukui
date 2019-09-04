local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]

function TukuiUnitFrames:Pet()
	local HealthTexture = T.GetTexture(C["Textures"].UFHealthTexture)
	local PowerTexture = T.GetTexture(C["Textures"].UFPowerTexture)
	local Font = T.GetFont(C["UnitFrames"].Font)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetBackdrop(TukuiUnitFrames.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	self:CreateShadow()

	local Panel = CreateFrame("Frame", nil, self)
	Panel:SetFrameStrata(self:GetFrameStrata())
	Panel:SetFrameLevel(3)
	Panel:SetTemplate()
	Panel:Size(129, 17)
	Panel:Point("BOTTOM", self, "BOTTOM", 0, 0)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:Height(13)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(HealthTexture)

	Health.Background = Health:CreateTexture(nil, "BORDER")
	Health.Background:Point("TOPLEFT", Health, -1, 1)
	Health.Background:Point("BOTTOMRIGHT", Health, 1, -1)
	Health.Background:SetColorTexture(.1, .1, .1)
	
	Health.Value = Panel:CreateFontString(nil, "OVERLAY")
	Health.Value:SetFontObject(Font)
	Health.Value:Point("RIGHT", Panel, "RIGHT", -4, 0)

	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true
	
	if T.MyClass == "HUNTER" then
		Health.colorHappiness = true
	end

	if C.UnitFrames.Smooth then
		Health.Smooth = true
	end
	
	Health.PostUpdate = TukuiUnitFrames.PostUpdateHealth

	local Power = CreateFrame("StatusBar", nil, self)
	Power:Height(4)
	Power:Point("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
	Power:Point("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
	Power:SetStatusBarTexture(PowerTexture)

	Power.Background = Power:CreateTexture(nil, "BORDER")
	Power.Background:Point("TOPLEFT", Power, -1, 1)
	Power.Background:Point("BOTTOMRIGHT", Power, 1, -1)
	Power.Background:SetColorTexture(.4, .4, .4)
	Power.Background.multiplier = 0.3
	
	Power.Value = Panel:CreateFontString(nil, "OVERLAY")
	Power.Value:SetFontObject(Font)
	Power.Value:Point("LEFT", Panel, "LEFT", 4, 0)

	Power.frequentUpdates = true
	Power.colorPower = true

	if C.UnitFrames.Smooth then
		Power.Smooth = true
	end
	
	Power.PostUpdate = TukuiUnitFrames.PostUpdatePower

	local Name = Panel:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("CENTER", Panel, "CENTER", 0, 0)
	Name:SetFontObject(Font)
	Name:SetJustifyH("CENTER")
	Name:SetAlpha(0)

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(16, 16)
	RaidIcon:SetPoint("TOP", self, 0, 8)
	RaidIcon:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\RaidIcons]])

	self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium] [Tukui:DiffColor][level]")
	self.Panel = Panel
	self.Health = Health
	self.Health.bg = Health.Background
	self.Power = Power
	self.Power.bg = Power.Background
	self.Name = Name
	self.RaidTargetIndicator = RaidIcon
	
	if C.UnitFrames.OOCPetNameLevel then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", TukuiUnitFrames.DisplayPlayerAndPetNames, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", TukuiUnitFrames.DisplayPlayerAndPetNames, true)
		
		TukuiUnitFrames.DisplayPlayerAndPetNames(self, "PLAYER_REGEN_ENABLED")
	end
end
