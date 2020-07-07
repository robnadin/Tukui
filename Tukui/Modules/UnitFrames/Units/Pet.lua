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

	Health.Background = Health:CreateTexture(nil, "BACKGROUND")
	Health.Background:SetTexture(C.Medias.Blank)
    Health.Background:SetAllPoints(Health)
	Health.Background.multiplier = C.UnitFrames.StatusBarBackgroundMultiplier / 100

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
	Power.Background:SetTexture(C.Medias.Blank)
	Power.Background:SetAllPoints(Power)
	Power.Background.multiplier = C.UnitFrames.StatusBarBackgroundMultiplier / 100

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
	RaidIcon:Size(C.UnitFrames.RaidIconSize)
	RaidIcon:SetPoint("TOP", self, 0, C.UnitFrames.RaidIconSize / 2)
	RaidIcon:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\RaidIcons]])
    
	if (C.UnitFrames.PetAuras) then
		local Buffs = CreateFrame("Frame", self:GetName()..'Buffs', self)
		local Debuffs = CreateFrame("Frame", self:GetName()..'Debuffs', self)

		Buffs:SetFrameStrata(self:GetFrameStrata())
		Buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)

		Buffs:SetHeight(18)
		Buffs:SetWidth(129)
		Buffs.size = 18
		Buffs.num = 3
		Buffs.numRow = 1

		Debuffs:SetFrameStrata(self:GetFrameStrata())
		Debuffs:SetHeight(18)
		Debuffs:SetWidth(129)
		Debuffs:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, 4)
		Debuffs.size = 18
		Debuffs.num = 3
		Debuffs.numRow = 1

		Buffs.spacing = 4
		Buffs.initialAnchor = "TOPLEFT"
		Buffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
		Buffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura
		Buffs.onlyShowPlayer = C.UnitFrames.OnlySelfBuffs

		Debuffs.spacing = 4
		Debuffs.initialAnchor = "TOPRIGHT"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
		Debuffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura
		Debuffs.onlyShowPlayer = C.UnitFrames.OnlySelfDebuffs

		if C.UnitFrames.AurasBelow then
			Buffs:ClearAllPoints()
			Buffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -4)
			
			Debuffs:ClearAllPoints()
			Debuffs:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -4)
		end

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	end

	if C.UnitFrames.HealComm then
		local myBar = CreateFrame("StatusBar", nil, Health)
		local otherBar = CreateFrame("StatusBar", nil, Health)

		myBar:SetFrameLevel(Health:GetFrameLevel())
		myBar:SetStatusBarTexture(HealthTexture)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetWidth(129)
		myBar:SetStatusBarColor(unpack(C.UnitFrames.HealCommSelfColor))

		otherBar:SetFrameLevel(Health:GetFrameLevel())
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetWidth(129)
		otherBar:SetStatusBarTexture(HealthTexture)
		otherBar:SetStatusBarColor(unpack(C.UnitFrames.HealCommOtherColor))

		local HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}

		self.HealthPrediction = HealthPrediction
	end

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
