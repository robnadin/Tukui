local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))

function TukuiUnitFrames:Raid()
	local HealthTexture = T.GetTexture(C["Textures"].UFRaidHealthTexture)
	local PowerTexture = T.GetTexture(C["Textures"].UFRaidPowerTexture)
	local Font = T.GetFont(C["Raid"].Font)
	local HealthFont = T.GetFont(C["Raid"].HealthFont)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetBackdrop(TukuiUnitFrames.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	self:CreateShadow()
	
	-- We need a shadow for highlighting target
	if C.General.HideShadows then
		self.Shadow:SetBackdrop( {
			edgeFile = C.Medias.Glow, edgeSize = 4,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		self.Shadow:Hide()
	end

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:Height(33)
	Health:SetStatusBarTexture(HealthTexture)

	if C.Raid.VerticalHealth then
		Health:SetOrientation("VERTICAL")
	end

	Health.Background = Health:CreateTexture(nil, "BORDER")
	Health.Background:SetAllPoints()
	Health.Background:SetColorTexture(.1, .1, .1)
	
	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetFontObject(HealthFont)
	Health.Value:Point("CENTER", Health, "CENTER", 0, -6)

	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true

	if (C.UnitFrames.Smooth) then
		Health.Smooth = true
	end
	
	Health.PostUpdate = TukuiUnitFrames.PostUpdateHealth

	-- Power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:Height(3)
	Power:Point("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
	Power:Point("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)

	Power.Background = Power:CreateTexture(nil, "BORDER")
	Power.Background:SetAllPoints(Power)
	Power.Background:SetColorTexture(.4, .4, .4)
	Power.Background.multiplier = 0.3

	Power:SetStatusBarTexture(PowerTexture)

	Power.frequentUpdates = true
	Power.colorPower = true

	if (C.UnitFrames.Smooth) then
		Power.Smooth = true
	end

	local Panel = CreateFrame("Frame", nil, self)
	Panel:Point("TOPLEFT", Power, "BOTTOMLEFT", 0, -1)
	Panel:Point("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -1)
	Panel:SetPoint("BOTTOM", 0, 0)
	Panel:SetTemplate()
	Panel:SetBorderColor(0, 0, 0, 0)

	local Name = Panel:CreateFontString(nil, "OVERLAY", 1)
	Name:SetPoint("CENTER")
	Name:SetFontObject(Font)

	local ReadyCheck = Power:CreateTexture(nil, "OVERLAY", 2)
	ReadyCheck:Height(12)
	ReadyCheck:Width(12)
	ReadyCheck:SetPoint("CENTER")

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(16, 16)
	RaidIcon:SetPoint("TOP", self, 0, 8)
	RaidIcon:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\RaidIcons]])

	local Range = {
		insideAlpha = 1,
		outsideAlpha = C["Raid"].RangeAlpha,
	}
	
	if C.Raid.MyRaidBuffs then
		local Buffs = CreateFrame("Frame", self:GetName()..'Buffs', Health)
		Buffs:Point("TOPLEFT", Health, "TOPLEFT", 0, 0)
		Buffs:SetHeight(16)
		Buffs:SetWidth(79)
		Buffs.size = 16
		Buffs.num = 5
		Buffs.numRow = 1
		Buffs.spacing = 0
		Buffs.initialAnchor = "TOPLEFT"
		Buffs.disableCooldown = true
		Buffs.disableMouse = true
		Buffs.onlyShowPlayer = true
		Buffs.IsRaid = true
		Buffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
		
		self.Buffs = Buffs
	end
	
	if C.Raid.DebuffWatch then
		local RaidDebuffs = CreateFrame("Frame", nil, Health)
		RaidDebuffs:SetHeight(20)
		RaidDebuffs:SetWidth(20)
		RaidDebuffs:SetPoint("CENTER", Health)
		RaidDebuffs:SetFrameLevel(Health:GetFrameLevel() + 10)
		RaidDebuffs:SetTemplate()
		RaidDebuffs:CreateShadow()
		RaidDebuffs.Shadow:SetFrameLevel(RaidDebuffs:GetFrameLevel() + 1)
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "ARTWORK")
		RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		RaidDebuffs.icon:SetInside(RaidDebuffs)
		RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs, "CooldownFrameTemplate")
		RaidDebuffs.cd:SetInside(RaidDebuffs, 1, 0)
		RaidDebuffs.cd:SetReverse(true)
		RaidDebuffs.cd.noOCC = true
		RaidDebuffs.cd.noCooldownCount = true
		RaidDebuffs.cd:SetHideCountdownNumbers(true)
		RaidDebuffs.cd:SetAlpha(.7)
		RaidDebuffs.showDispellableDebuff = true
		RaidDebuffs.onlyMatchSpellID = true
		RaidDebuffs.FilterDispellableDebuff = true
		RaidDebuffs.time = RaidDebuffs:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.time:SetFont(C.Medias.Font, 12, "OUTLINE")
		RaidDebuffs.time:Point("CENTER", RaidDebuffs, 1, 0)
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.count:SetFont(C.Medias.Font, 12, "OUTLINE")
		RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		RaidDebuffs.forceShow = true
		
		self.RaidDebuffs = RaidDebuffs
	end

	self:Tag(Name, "[Tukui:GetRaidNameColor][Tukui:NameShort]")
	self.Health = Health
	self.Health.bg = Health.Background
	self.Power = Power
	self.Power.bg = Power.Background
	self.Panel = Panel
	self.Name = Name
	self.ReadyCheckIndicator = ReadyCheck
	self.Range = Range
	self.RaidTargetIndicator = RaidIcon
	
	
	self:RegisterEvent("PLAYER_TARGET_CHANGED", TukuiUnitFrames.Highlight, true)
	self:RegisterEvent("RAID_ROSTER_UPDATE", TukuiUnitFrames.Highlight, true)
end
