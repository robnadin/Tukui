local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))

function TukuiUnitFrames:Party()
	local HealthTexture = T.GetTexture(C["Textures"].UFPartyHealthTexture)
	local PowerTexture = T.GetTexture(C["Textures"].UFPartyPowerTexture)
	local Font = T.GetFont(C["Party"].Font)
	local HealthFont = T.GetFont(C["Party"].HealthFont)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetBackdrop(TukuiUnitFrames.Backdrop)
	self:SetBackdropColor(0, 0, 0)

	self:CreateShadow()
	self.Shadow:SetFrameLevel(2)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:Height(self:GetHeight() - 5)
	Health:SetStatusBarTexture(HealthTexture)

	Health.Background = Health:CreateTexture(nil, "BORDER")
	Health.Background:SetAllPoints()
	Health.Background:SetColorTexture(.1, .1, .1)

	if C.Party.ShowHealthText then
		Health.Value = Health:CreateFontString(nil, "OVERLAY")
		Health.Value:SetFontObject(Font)
		Health.Value:SetPoint("TOPRIGHT", -4, 6)
		Health.PostUpdate = TukuiUnitFrames.PostUpdateHealth
	end

	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true
	Health.isParty = true

	if (C.UnitFrames.Smooth) then
		Health.Smooth = true
	end

	-- Power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:Height(4)
	Power:Point("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
	Power:Point("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
	Power:SetStatusBarTexture(PowerTexture)

	Power.Background = Power:CreateTexture(nil, "BORDER")
	Power.Background:SetAllPoints(Power)
	Power.Background:SetColorTexture(.4, .4, .4)
	Power.Background.multiplier = 0.3

	if C.Party.ShowManaText then
		Power.Value = Power:CreateFontString(nil, "OVERLAY")
		Power.Value:SetFontObject(Font)
		Power.Value:SetPoint("BOTTOMRIGHT", -4, 0)
		Power.PostUpdate = TukuiUnitFrames.PostUpdatePower
	end

	Power.frequentUpdates = true
	Power.colorPower = true
	Power.isParty = true

	if (C.UnitFrames.Smooth) then
		Power.Smooth = true
	end

	local Name = Health:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("TOPLEFT", 4, 7)
	Name:SetFontObject(Font)

	local Buffs = CreateFrame("Frame", self:GetName()..'Buffs', self)
	Buffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
	Buffs:SetHeight(24)
	Buffs:SetWidth(206)
	Buffs.size = 24
	Buffs.num = 7
	Buffs.numRow = 1
	Buffs.spacing = 2
	Buffs.initialAnchor = "TOPLEFT"
	Buffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
	Buffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura

	local Debuffs = CreateFrame("Frame", self:GetName()..'Debuffs', self)
	Debuffs:Point("LEFT", self, "RIGHT", 6, 0)
	Debuffs:SetHeight(self:GetHeight())
	Debuffs:SetWidth(250)
	Debuffs.size = self:GetHeight()
	Debuffs.num = 6
	Debuffs.spacing = 2
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
	Debuffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura

	local Leader = self:CreateTexture(nil, "OVERLAY")
	Leader:SetSize(16, 16)
	Leader:SetPoint("TOPRIGHT", self, "TOPLEFT", -4, 0)

	local MasterLooter = self:CreateTexture(nil, "OVERLAY")
	MasterLooter:SetSize(16, 16)
	MasterLooter:SetPoint("TOPRIGHT", self, "TOPLEFT", -4.5, -20)

	local ReadyCheck = Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetPoint("CENTER", Health, "CENTER")
	ReadyCheck:SetSize(16, 16)

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY")
	RaidIcon:Size(C.UnitFrames.RaidIconSize)
	RaidIcon:SetPoint("CENTER", Health, "CENTER")
	RaidIcon:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\RaidIcons]])

	local Range = {
		insideAlpha = 1,
		outsideAlpha = C["Party"].RangeAlpha,
	}

	if C.UnitFrames.HealComm then
		local myBar = CreateFrame("StatusBar", nil, Health)
		local otherBar = CreateFrame("StatusBar", nil, Health)

		myBar:SetFrameLevel(Health:GetFrameLevel())
		myBar:SetStatusBarTexture(HealthTexture)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetWidth(180)
		myBar:SetStatusBarColor(unpack(C.UnitFrames.HealCommSelfColor))

		otherBar:SetFrameLevel(Health:GetFrameLevel())
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetWidth(180)
		otherBar:SetStatusBarTexture(HealthTexture)
		otherBar:SetStatusBarColor(C.UnitFrames.HealCommOtherColor)

		local HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}

		self.HealthPrediction = HealthPrediction
	end

	local Highlight = CreateFrame("Frame", nil, self)
	Highlight:SetBackdrop({edgeFile = C.Medias.Glow, edgeSize = C.Party.HighlightSize})
	Highlight:SetOutside(self, C.Party.HighlightSize, C.Party.HighlightSize)
	Highlight:SetBackdropBorderColor(unpack(C.Party.HighlightColor))
	Highlight:SetFrameLevel(0)
	Highlight:Hide()

	self.Health = Health
	self.Health.bg = Health.Background
	self.Power = Power
	self.Power.bg = Power.Background
	self.Name = Name
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.LeaderIndicator = Leader
	self.MasterLooterIndicator = MasterLooter
	self.ReadyCheckIndicator = ReadyCheck
	self.RaidTargetIndicator = RaidIcon
	self.Range = Range
	self.Range.Override = TukuiUnitFrames.UpdateRange
	self:Tag(Name, "[level] [Tukui:NameLong]")
	self.Highlight = Highlight

	self:RegisterEvent("PLAYER_TARGET_CHANGED", TukuiUnitFrames.Highlight, true)
	self:RegisterEvent("RAID_ROSTER_UPDATE", TukuiUnitFrames.Highlight, true)
end
