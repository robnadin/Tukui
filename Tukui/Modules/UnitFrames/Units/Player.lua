local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Movers = T["Movers"]
local Class = select(2, UnitClass("player"))

function TukuiUnitFrames:Player()
	local HealthTexture = T.GetTexture(C["Textures"].UFHealthTexture)
	local PowerTexture = T.GetTexture(C["Textures"].UFPowerTexture)
	local CastTexture = T.GetTexture(C["Textures"].UFCastTexture)
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
	Panel:Size(250, 21)
	Panel:Point("BOTTOM", self, "BOTTOM", 0, 0)
	Panel:SetBorderColor(0, 0, 0, 0)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetFrameStrata(self:GetFrameStrata())
	Health:SetFrameLevel(4)
	Health:Height(26)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(HealthTexture)

	Health.Background = Health:CreateTexture(nil, "BACKGROUND")
	Health.Background:SetAllPoints()
	Health.Background:SetColorTexture(.1, .1, .1)

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetFontObject(Font)
	Health.Value:Point("RIGHT", Panel, "RIGHT", -4, 0)

	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true

	if (C.UnitFrames.Smooth) then
		Health.Smooth = true
	end

	Health.frequentUpdates = true

	Health.PostUpdate = TukuiUnitFrames.PostUpdateHealth

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetFrameStrata(self:GetFrameStrata())
	Power:SetFrameLevel(4)
	Power:Height(8)
	Power:Point("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
	Power:Point("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
	Power:SetStatusBarTexture(PowerTexture)

	Power.Background = Power:CreateTexture(nil, "BORDER")
	Power.Background:SetAllPoints()
	Power.Background:SetColorTexture(.4, .4, .4)
	Power.Background.multiplier = 0.3

	Power.Value = Power:CreateFontString(nil, "OVERLAY")
	Power.Value:SetFontObject(Font)
	Power.Value:Point("LEFT", Panel, "LEFT", 4, 0)

	Power.frequentUpdates = true
	Power.colorPower = true

	if (C.UnitFrames.Smooth) then
		Power.Smooth = true
	end

	Power.Prediction = CreateFrame("StatusBar", nil, Power)
	Power.Prediction:SetReverseFill(true)
	Power.Prediction:SetPoint("TOP")
	Power.Prediction:SetPoint("BOTTOM")
	Power.Prediction:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT")
	Power.Prediction:SetWidth(C.UnitFrames.Portrait and 214 or 250)
	Power.Prediction:SetStatusBarTexture(PowerTexture)
	Power.Prediction:SetStatusBarColor(1, 1, 1, .3)

	Power.PostUpdate = TukuiUnitFrames.PostUpdatePower

	local Name = Panel:CreateFontString(nil, "OVERLAY")
	Name:Point("LEFT", Panel, "LEFT", 4, 0)
	Name:SetJustifyH("LEFT")
	Name:SetFontObject(Font)
	Name:SetAlpha(0)

	if C.UnitFrames.Portrait then
		local Portrait

		if C.UnitFrames.Portrait2D then
			Portrait = self:CreateTexture(nil, "OVERLAY")
			Portrait:SetTexCoord(0.1,0.9,0.1,0.9)
		else
			Portrait = CreateFrame("PlayerModel", nil, Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetBackdrop(TukuiUnitFrames.Backdrop)
			Portrait:SetBackdropColor(0, 0, 0)
			Portrait:CreateBackdrop()

			Portrait.Backdrop:SetOutside(Portrait, -1, 1)
			Portrait.Backdrop:SetBorderColor(unpack(C["General"].BorderColor))
		end

		Portrait:Size(Health:GetHeight() + Power:GetHeight() + 1)
		Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

		Health:ClearAllPoints()
		Health:SetPoint("TOPLEFT", Portrait:GetWidth() + 1, 0)
		Health:SetPoint("TOPRIGHT")

		self.Portrait = Portrait
	end

	if C.UnitFrames.PlayerAuras and C.UnitFrames.PlayerAuraBars then
		local Gap = (T.MyClass == "ROGUE" or T.MyClass == "DRUID") and 8 or 0
		local AuraBars = CreateFrame("Frame", self:GetName().."AuraBars", self)

		AuraBars:SetHeight(10)
		AuraBars:SetWidth(250)
		AuraBars:SetPoint("TOPLEFT", -2, 12 + Gap)
		AuraBars.auraBarTexture = HealthTexture
		AuraBars.PostCreateBar = TukuiUnitFrames.PostCreateAuraBar
		AuraBars.onlyShowPlayer = C.UnitFrames.OnlySelfBuffs
		AuraBars.gap = 2
		AuraBars.width = 231
		AuraBars.height = 17
		AuraBars.spellNameObject = Font
		AuraBars.spellTimeObject = Font

		T.Movers:RegisterFrame(AuraBars)

		self.AuraBars = AuraBars
	elseif (C.UnitFrames.PlayerAuras) then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetFrameStrata(self:GetFrameStrata())
		Buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)

		Buffs:SetHeight(26)
		Buffs:SetWidth(252)
		Buffs.size = 26
		Buffs.num = 36
		Buffs.numRow = 9

		Debuffs:SetFrameStrata(self:GetFrameStrata())
		Debuffs:SetHeight(26)
		Debuffs:SetWidth(252)
		Debuffs:SetPoint("BOTTOMLEFT", Buffs, "TOPLEFT", -2, 2)
		Debuffs.size = 26
		Debuffs.num = 36
		Debuffs.numRow = 9

		Buffs.spacing = 2
		Buffs.initialAnchor = "TOPLEFT"
		Buffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
		Buffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura
		Buffs.PostUpdate = TukuiUnitFrames.UpdateDebuffsHeaderPosition
		Buffs.onlyShowPlayer = C.UnitFrames.OnlySelfBuffs
		Buffs.isCancellable = true

		Debuffs.spacing = 2
		Debuffs.initialAnchor = "TOPRIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = TukuiUnitFrames.PostCreateAura
		Debuffs.PostUpdateIcon = TukuiUnitFrames.PostUpdateAura

		if C.UnitFrames.AurasBelow then
			Buffs:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 0, -32)
			Debuffs["growth-y"] = "DOWN"
		end

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	end

	local Combat = Health:CreateTexture(nil, "OVERLAY", 1)
	Combat:Size(19, 19)
	Combat:Point("LEFT", 0, 1)
	Combat:SetVertexColor(0.69, 0.31, 0.31)

	local Status = Panel:CreateFontString(nil, "OVERLAY", 1)
	Status:SetFontObject(Font)
	Status:Point("CENTER", Panel, "CENTER", 0, 0)
	Status:SetTextColor(0.69, 0.31, 0.31)
	Status:Hide()

	local Leader = Health:CreateTexture(nil, "OVERLAY", 2)
	Leader:Size(14, 14)
	Leader:Point("TOPLEFT", 2, 8)

	local MasterLooter = Health:CreateTexture(nil, "OVERLAY", 2)
	MasterLooter:Size(14, 14)
	MasterLooter:Point("TOPRIGHT", -2, 8)

	if (C.UnitFrames.CastBar) then
		local CastBar = CreateFrame("StatusBar", "TukuiPlayerCastBar", self)
		CastBar:SetFrameStrata(self:GetFrameStrata())
		CastBar:SetStatusBarTexture(CastTexture)
		CastBar:SetFrameLevel(6)
		CastBar:SetInside(Panel, 0, 0)

		CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
		CastBar.Background:SetAllPoints(CastBar)
		CastBar.Background:SetTexture(C.Medias.Normal)
		CastBar.Background:SetVertexColor(0.15, 0.15, 0.15)

		CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
		CastBar.Time:SetFontObject(Font)
		CastBar.Time:Point("RIGHT", Panel, "RIGHT", -4, 0)
		CastBar.Time:SetTextColor(0.84, 0.75, 0.65)
		CastBar.Time:SetJustifyH("RIGHT")

		CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
		CastBar.Text:SetFontObject(Font)
		CastBar.Text:Point("LEFT", Panel, "LEFT", 4, 0)
		CastBar.Text:SetTextColor(0.84, 0.75, 0.65)
		CastBar.Text:SetWidth(166)
		CastBar.Text:SetJustifyH("LEFT")

		if (C.UnitFrames.CastBarIcon) then
			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:Size(26)
			CastBar.Button:SetTemplate()
			CastBar.Button:CreateShadow()
			CastBar.Button:Point("LEFT", -46.5, 26.5)

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetInside()
			CastBar.Icon:SetTexCoord(unpack(T.IconCoord))
		end

		if (C.UnitFrames.CastBarLatency) then
			CastBar.SafeZone = CastBar:CreateTexture(nil, "ARTWORK")
			CastBar.SafeZone:SetTexture(CastTexture)
			CastBar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end

		CastBar.CustomTimeText = TukuiUnitFrames.CustomCastTimeText
		CastBar.CustomDelayText = TukuiUnitFrames.CustomCastDelayText
		CastBar.PostCastStart = TukuiUnitFrames.CheckCast
		CastBar.PostChannelStart = TukuiUnitFrames.CheckChannel

		if (C.UnitFrames.UnlinkCastBar) then
			CastBar:ClearAllPoints()
			CastBar:SetWidth(200)
			CastBar:SetHeight(23)
			CastBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 220)
			CastBar:CreateShadow()

			if (C.UnitFrames.CastBarIcon) then
				CastBar.Icon:ClearAllPoints()
				CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -8, 0)
				CastBar.Icon:SetSize(CastBar:GetHeight(), CastBar:GetHeight())

				CastBar.Button:ClearAllPoints()
				CastBar.Button:SetAllPoints(CastBar.Icon)
			end

			CastBar.Time:ClearAllPoints()
			CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -4, 0)

			CastBar.Text:ClearAllPoints()
			CastBar.Text:Point("LEFT", CastBar, "LEFT", 4, 0)

			Movers:RegisterFrame(CastBar)
		end

		self.Castbar = CastBar
	end

	if (C.UnitFrames.CombatLog) then
		local CombatFeedbackText = Health:CreateFontString(nil, "OVERLAY", 7)
		CombatFeedbackText:SetFontObject(Font)
		CombatFeedbackText:SetFont(CombatFeedbackText:GetFont(), 14, "THINOUTLINE")
		CombatFeedbackText:SetPoint("CENTER", 0, -1)
		CombatFeedbackText.colors = {
			DAMAGE = {0.69, 0.31, 0.31},
			CRUSHING = {0.69, 0.31, 0.31},
			CRITICAL = {0.69, 0.31, 0.31},
			GLANCING = {0.69, 0.31, 0.31},
			STANDARD = {0.84, 0.75, 0.65},
			IMMUNE = {0.84, 0.75, 0.65},
			ABSORB = {0.84, 0.75, 0.65},
			BLOCK = {0.84, 0.75, 0.65},
			RESIST = {0.84, 0.75, 0.65},
			MISS = {0.84, 0.75, 0.65},
			HEAL = {0.33, 0.59, 0.33},
			CRITHEAL = {0.33, 0.59, 0.33},
			ENERGIZE = {0.31, 0.45, 0.63},
			CRITENERGIZE = {0.31, 0.45, 0.63},
		}

		self.CombatFeedbackText = CombatFeedbackText
	end

	if (C.UnitFrames.ComboBar) and (Class == "ROGUE" or Class == "DRUID") then
		local ComboPoints = CreateFrame("Frame", self:GetName().."ComboPointsBar", self)
		ComboPoints:SetFrameStrata(self:GetFrameStrata())
		ComboPoints:SetHeight(8)
		ComboPoints:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
		ComboPoints:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, 1)
		ComboPoints:SetBackdrop(TukuiUnitFrames.Backdrop)
		ComboPoints:SetBackdropColor(0, 0, 0)
		ComboPoints:SetBackdropBorderColor(unpack(C["General"].BorderColor))

		for i = 1, 5 do
			ComboPoints[i] = CreateFrame("StatusBar", nil, ComboPoints)
			ComboPoints[i]:SetHeight(8)
			ComboPoints[i]:SetStatusBarTexture(PowerTexture)

			if i == 1 then
				ComboPoints[i]:SetPoint("LEFT", ComboPoints, "LEFT", 0, 0)
				ComboPoints[i]:SetWidth(250 / 5)
			else
				ComboPoints[i]:SetWidth((250 / 5) - 1)
				ComboPoints[i]:SetPoint("LEFT", ComboPoints[i - 1], "RIGHT", 1, 0)
			end
		end

		ComboPoints:SetScript("OnShow", function(self)
			TukuiUnitFrames.UpdateShadow(self, 12)
			TukuiUnitFrames.UpdateBuffsHeaderPosition(self, 14)
		end)

		ComboPoints:SetScript("OnHide", function(self)
			TukuiUnitFrames.UpdateShadow(self, 4)
			TukuiUnitFrames.UpdateBuffsHeaderPosition(self, 4)
		end)

		self.ComboPointsBar = ComboPoints
	end

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY", 7)
	RaidIcon:Size(C.UnitFrames.RaidIconSize)
	RaidIcon:SetPoint("TOP", self, 0, C.UnitFrames.RaidIconSize / 2)
	RaidIcon:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\RaidIcons]])

	local RestingIndicator = Panel:CreateTexture(nil, "OVERLAY", 7)
	RestingIndicator:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\Resting]])
	RestingIndicator:SetSize(20, 20)
	RestingIndicator:SetPoint("CENTER", Panel, "CENTER", 0, 0)

	if C.UnitFrames.ScrollingCombatText then
		local DamageFont = T.GetFont(C.UnitFrames.ScrollingCombatTextFont)
		local DamageFontPath, DamageFontSize, DamageFontFlag = _G[DamageFont]:GetFont()

		local ScrollingCombatText = CreateFrame("Frame", "TukuiPlayerFrameScrollingCombatText", UIParent)
		ScrollingCombatText:SetSize(32, 32)
		ScrollingCombatText:SetPoint("CENTER", 0, -(T.ScreenHeight / 8))
		ScrollingCombatText.scrollTime = 1.5
		ScrollingCombatText.font = DamageFontPath
		ScrollingCombatText.fontHeight = C.UnitFrames.ScrollingCombatTextFontSize
		ScrollingCombatText.radius = 100
		ScrollingCombatText.fontFlags = DamageFontFlag

		for i = 1, 6 do
			ScrollingCombatText[i] = ScrollingCombatText:CreateFontString("TukuiPlayerFrameScrollingCombatTextFont" .. i, "OVERLAY")
		end

		self.FloatingCombatFeedback = ScrollingCombatText

		T.Movers:RegisterFrame(ScrollingCombatText)
	end

	if C.UnitFrames.PowerTick then
		local EnergyManaRegen = CreateFrame("StatusBar", nil, Power)

		EnergyManaRegen:SetFrameLevel(Power:GetFrameLevel() + 3)
		EnergyManaRegen:SetAllPoints()
		EnergyManaRegen.Spark = EnergyManaRegen:CreateTexture(nil, "OVERLAY")

		self.EnergyManaRegen = EnergyManaRegen
	end

	if C.UnitFrames.HealComm then
		local myBar = CreateFrame("StatusBar", nil, Health)
		local otherBar = CreateFrame("StatusBar", nil, Health)

		myBar:SetFrameLevel(Health:GetFrameLevel())
		myBar:SetStatusBarTexture(HealthTexture)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetWidth(250)
		myBar:SetStatusBarColor(unpack(C.UnitFrames.HealCommSelfColor))

		otherBar:SetFrameLevel(Health:GetFrameLevel())
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetWidth(250)
		otherBar:SetStatusBarTexture(HealthTexture)
		otherBar:SetStatusBarColor(C.UnitFrames.HealCommOtherColor)

		local HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}

		self.HealthPrediction = HealthPrediction
	end


	self:HookScript("OnEnter", TukuiUnitFrames.MouseOnPlayer)
	self:HookScript("OnLeave", TukuiUnitFrames.MouseOnPlayer)

	-- Register with oUF
	self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameLong] [Tukui:Classification][Tukui:DiffColor][level]")
	self.Panel = Panel
	self.Health = Health
	self.Health.bg = Health.Background
	self.Power = Power
	self.Name = Name
	self.Power.bg = Power.Background
	self.CombatIndicator = Combat
	self.Status = Status
	self.LeaderIndicator = Leader
	self.MasterLooterIndicator = MasterLooter
	self.RaidTargetIndicator = RaidIcon
	self.PowerPrediction = {}
	self.PowerPrediction.mainBar = Power.Prediction
	self.RestingIndicator = RestingIndicator

	-- Classes
	TukuiUnitFrames.AddClassFeatures[Class](self)

	if C.UnitFrames.OOCNameLevel then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", TukuiUnitFrames.DisplayPlayerAndPetNames, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", TukuiUnitFrames.DisplayPlayerAndPetNames, true)

		TukuiUnitFrames.DisplayPlayerAndPetNames(self, "PLAYER_REGEN_ENABLED")
	end
end
