local T, C, L = select(2, ...):unpack()
local AddOn, Plugin = ...
local oUF = Plugin.oUF or oUF
local LibClassicDurations = LibStub("LibClassicDurations")
local Panels = T["Panels"]
local Noop = function() end
local TukuiUnitFrames = CreateFrame("Frame")

-- Lib globals
local strfind = strfind
local format = format
local floor = floor

-- WoW globals (I don't really wanna import all the funcs we use here, so localize the ones called a LOT, like in Health/Power functions)
local UnitIsEnemy = UnitIsEnemy
local UnitIsPlayer = UnitIsPlayer
local UnitIsFriend = UnitIsFriend
local UnitIsConnected = UnitIsConnected
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitPowerType = UnitPowerType

-- Register LibClassicDurations
LibClassicDurations:Register("Tukui")

TukuiUnitFrames.Units = {}
TukuiUnitFrames.Headers = {}
TukuiUnitFrames.Framework = TukuiUnitFrameFramework
TukuiUnitFrames.HighlightBorder = {
	bgFile = "Interface\\Buttons\\WHITE8x8",
	insets = {top = -2, left = -2, bottom = -2, right = -2}
}

TukuiUnitFrames.AddClassFeatures = {}

TukuiUnitFrames.NameplatesVars = {
	nameplateMaxAlpha = 1,
	nameplateMinAlpha = 1,
	nameplateSelectedAlpha = 1,
	nameplateMaxDistance = 80,
	nameplateMaxScale = 1,
	nameplateMinScale = 1,
	nameplateSelectedScale = 1,
	nameplateSelfScale = 1,
	nameplateSelfAlpha = 1,
	nameplateOccludedAlphaMult = 1,
}

function TukuiUnitFrames:DisableBlizzard()
	if not C.UnitFrames.Enable then
		return
	end

	if C["Raid"].Enable and CompactRaidFrameManager then
		-- Disable Blizzard Raid Frames.
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameManager:Hide()

		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:Hide()

		-- Hide Raid Interface Options.
		InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
		InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
	end
end

function TukuiUnitFrames:ShortValue()
	if self <= 999 then
		return self
	end

	local Value

	if self >= 1000000 then
		Value = format("%.1fm", self / 1000000)
		return Value
	elseif self >= 1000 then
		Value = format("%.1fk", self / 1000)
		return Value
	end
end

function TukuiUnitFrames:UTF8Sub(i, dots)
	if not self then return end

	local Bytes = self:len()
	if (Bytes <= i) then
		return self
	else
		local Len, Pos = 0, 1
		while(Pos <= Bytes) do
			Len = Len + 1
			local c = self:byte(Pos)
			if (c > 0 and c <= 127) then
				Pos = Pos + 1
			elseif (c >= 192 and c <= 223) then
				Pos = Pos + 2
			elseif (c >= 224 and c <= 239) then
				Pos = Pos + 3
			elseif (c >= 240 and c <= 247) then
				Pos = Pos + 4
			end
			if (Len == i) then break end
		end

		if (Len == i and Pos <= Bytes) then
			return self:sub(1, Pos - 1)..(dots and "..." or "")
		else
			return self
		end
	end
end

function TukuiUnitFrames:MouseOnPlayer()
	local Status = self.Status
	local MouseOver = GetMouseFocus()

	if (MouseOver == self) then
		Status:Show()

		if (UnitIsPVP("player")) then
			Status:SetText("PVP")
		end
	else
		Status:Hide()
		Status:SetText()
	end
end

function TukuiUnitFrames:Highlight()
	local Shadow = self.Shadow

	if Shadow then
		if UnitIsUnit("target", self.unit) then
			if C.General.HideShadows then
				Shadow:Show()
			end

			Shadow:SetBackdropBorderColor(1, 1, 0, 1)
		else
			if C.General.HideShadows then
				Shadow:Hide()
			else
				Shadow:SetBackdropBorderColor(0, 0, 0, 1)
			end
		end
	end
end

function TukuiUnitFrames:NameplatesPostUpdate(event, ...)
	-- need rewrite
end

function TukuiUnitFrames:UpdateShadow(height)
	local Frame = self:GetParent()
	local Shadow = Frame.Shadow

	if not Shadow then
		return
	end

	Shadow:Point("TOPLEFT", -4, height)
end

function TukuiUnitFrames:UpdateBuffsHeaderPosition(height)
	local Frame = self:GetParent()
	local Buffs = Frame.Buffs

	if not Buffs then
		return
	end

	Buffs:ClearAllPoints()
	Buffs:Point("BOTTOMLEFT", Frame, "TOPLEFT", 0, height)
end

function TukuiUnitFrames:UpdateDebuffsHeaderPosition()
	local NumBuffs = self.visibleBuffs
	local PerRow = self.numRow
	local Size = self.size
	local Row = math.ceil((NumBuffs / PerRow))
	local Parent = self:GetParent()
	local Debuffs = Parent.Debuffs
	local Y = Size * Row
	local Addition = Size

	if NumBuffs == 0 then
		Addition = 0
	end

	Debuffs:ClearAllPoints()
	Debuffs:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -2, Y + Addition)
end

function TukuiUnitFrames:CustomCastTimeText(duration)
	local Value = format("%.1f / %.1f", self.channeling and duration or self.max - duration, self.max)

	self.Time:SetText(Value)
end

function TukuiUnitFrames:CustomCastDelayText(duration)
	local Value = format("%.1f |cffaf5050%s %.1f|r", self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay)

	self.Time:SetText(Value)
end

function TukuiUnitFrames:CheckInterrupt(unit)
	if (unit == "vehicle") then
		unit = "player"
	end

	local Frame = self:GetParent()
	local Power = Frame.Power

	if (self.notInterruptible and UnitCanAttack("player", unit)) then
		self:SetStatusBarColor(0.87, 0.37, 0.37, 0.7)
	else
		self:SetStatusBarColor(0.29, 0.67, 0.30, 0.7)
	end
end

function TukuiUnitFrames:CheckCast(unit, name, rank, castid)
	TukuiUnitFrames.CheckInterrupt(self, unit)
end

function TukuiUnitFrames:CheckChannel(unit, name, rank)
	TukuiUnitFrames.CheckInterrupt(self, unit)
end

function TukuiUnitFrames:UpdateNamePosition()
	if (self.Power.Value:GetText() and UnitIsEnemy("player", "target")) then
		self.Name:ClearAllPoints()
		self.Name:SetPoint("CENTER", self.Panel, "CENTER", 0, 0)
	else
		self.Name:ClearAllPoints()
		self.Power.Value:SetAlpha(0)
		self.Name:SetPoint("LEFT", self.Panel, "LEFT", 4, 0)
	end
end

function TukuiUnitFrames:PreUpdateHealth(unit)
	local HostileColor = C["UnitFrames"].TargetEnemyHostileColor

	if (HostileColor ~= true) then
		return
	end

	if UnitIsEnemy(unit, "player") then
		self.colorClass = false
	else
		self.colorClass = true
	end
end

function TukuiUnitFrames:PostUpdateHealth(unit, min, max)
	if (not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
		if (not UnitIsConnected(unit)) then
			self.Value:SetText("|cffD7BEA5"..FRIENDS_LIST_OFFLINE.."|r")
		elseif (UnitIsDead(unit)) then
			self.Value:SetText("|cffD7BEA5"..DEAD.."|r")
		elseif (UnitIsGhost(unit)) then
			self.Value:SetText("|cffD7BEA5"..L.UnitFrames.Ghost.."|r")
		end
	else
		local r, g, b
		local IsRaid = string.match(self:GetParent():GetName(), "Button") or false
		local Percent = max == 100 and "%" or ""

		if (min ~= max) then
			r, g, b = T.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if (unit == "player" and self:GetAttribute("normalUnit") ~= "pet") then
				if (IsRaid) then
					self.Value:SetText("|cffff2222-"..TukuiUnitFrames.ShortValue(max-min).."|r")
				else
					self.Value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
				end
			elseif (unit == "target") then
				self.Value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", TukuiUnitFrames.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif (unit and strfind(unit, "arena%d")) then
				self.Value:SetText("|cff559655"..TukuiUnitFrames.ShortValue(min).."|r")
			else
				self.Value:SetText("|cffff2222-"..TukuiUnitFrames.ShortValue(max-min).."|r")
			end
		else
			if (unit == "player" and self:GetAttribute("normalUnit") ~= "pet") then
				if (IsRaid) then
					self.Value:SetText(" ")
				else
					self.Value:SetText("|cff559655"..max.."|r")
				end
			elseif (unit == "target") then
				 
				self.Value:SetText("|cff559655"..TukuiUnitFrames.ShortValue(max)..Percent.."|r")
			else
				self.Value:SetText(" ")
			end
		end
	end
end

function TukuiUnitFrames:PostUpdatePower(unit, current, min, max)
	local Parent = self:GetParent()
	local pType, pToken = UnitPowerType(unit)
	local Colors = T["Colors"]
	local Color = Colors.power[pToken]

	if Color then
		self.Value:SetTextColor(Color[1], Color[2], Color[3])
	end

	if (not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit)) then
		self.Value:SetText()
	elseif (UnitIsDead(unit) or UnitIsGhost(unit)) then
		self.Value:SetText()
	else
		if (unit == "player" and not InCombatLockdown()) then
			local Color = T.RGBToHex(unpack(T.Colors.class[T.MyClass]))
			
			self.Value:SetText(Color..T.MyName.."|r ".."|cffD7BEA5"..UnitLevel("player").."|r")
		elseif (current ~= max) then
			if (pType == 0) then
				if (unit == "target") then
					self.Value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(current / max * 100), TukuiUnitFrames.ShortValue(max - (max - current)))
				elseif (unit == "player" and Parent:GetAttribute("normalUnit") == "pet" or unit == "pet") then
					self.Value:SetFormattedText("%d%%", floor(current / max * 100))
				else
					self.Value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(current / max * 100), max - (max - current))
				end
			else
				self.Value:SetText(max - (max - current))
			end
		else
			if (unit == "pet" or unit == "target" or unit == "targettarget") then
				self.Value:SetText(TukuiUnitFrames.ShortValue(current))
			else
				self.Value:SetText(current)
			end
		end
	end

	if (Parent.Name and unit == "target") then
		TukuiUnitFrames.UpdateNamePosition(Parent)
	end
end

local function hasbit(x, p)
	return x % (p + p) >= p
end

local function setbit(x, p)
	return hasbit(x, p) and x or x + p
end

local function clearbit(x, p)
	return hasbit(x, p) and x - p or x
end

function TukuiUnitFrames:CreateAuraTimer(elapsed)
	if (self.TimeLeft) then
		self.Elapsed = (self.Elapsed or 0) + elapsed

		if self.Elapsed >= 0.1 then
			if not self.First then
				self.TimeLeft = self.TimeLeft - self.Elapsed
			else
				self.TimeLeft = self.TimeLeft - GetTime()
				self.First = false
			end

			if self.TimeLeft > 0 then
				local Time = T.FormatTime(self.TimeLeft)
				self.Remaining:SetText(Time)

				if self.TimeLeft <= 5 then
					self.Remaining:SetTextColor(0.99, 0.31, 0.31)
				else
					self.Remaining:SetTextColor(1, 1, 1)
				end
			else
				self.Remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.Elapsed = 0
		end
	end
end

function TukuiUnitFrames:CancelPlayerBuff(index)
	if InCombatLockdown() then
		return
	end

	CancelUnitBuff("player", self.index)
end

function TukuiUnitFrames:PostCreateAura(button)
	-- Set "self.Buffs.isCancellable" to true to a buffs frame to be able to cancel click
	local isCancellable = button:GetParent().isCancellable

	-- Right-click-cancel script
	if isCancellable then
		-- Add a button.index to allow CancelUnitAura to work with player
		local Name = button:GetName()
		local Index = tonumber(Name:gsub('%D',''))

		button.index = Index
		button:SetScript("OnMouseUp", TukuiUnitFrames.CancelPlayerBuff)
	end

	-- Skin aura button
	button:SetTemplate("Default")
	button:CreateShadow()

	button.Remaining = button:CreateFontString(nil, "OVERLAY")
	button.Remaining:SetFont(C.Medias.Font, 12, "THINOUTLINE")
	button.Remaining:Point("CENTER", 1, 0)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetInside()
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetInside()
	button.icon:SetTexCoord(unpack(T.IconCoord))
	button.icon:SetDrawLayer("ARTWORK")

	button.count:Point("BOTTOMRIGHT", 3, 3)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C.Medias.Font, 9, "THICKOUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)

	button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
	button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.overlay:SetParent(button.OverlayFrame)
	button.count:SetParent(button.OverlayFrame)
	button.Remaining:SetParent(button.OverlayFrame)

	button.Animation = button:CreateAnimationGroup()
	button.Animation:SetLooping("BOUNCE")

	button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
	button.Animation.FadeOut:SetFromAlpha(1)
	button.Animation.FadeOut:SetToAlpha(0)
	button.Animation.FadeOut:SetDuration(.6)
	button.Animation.FadeOut:SetSmoothing("IN_OUT")
end

function TukuiUnitFrames:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local Name, _, _, DType, Duration, ExpirationTime, UnitCaster, IsStealable, _, SpellID = UnitAura(unit, index, button.filter)

	if Duration == 0 and ExpirationTime == 0 then
		Duration, ExpirationTime = LibClassicDurations:GetAuraDurationByUnit(unit, SpellID, UnitCaster, Name)
		
		button.IsLibClassicDuration = true
	else
		button.IsLibClassicDuration = false
	end

	if button then
		if(button.filter == "HARMFUL") then
			if(not UnitIsFriend("player", unit) and not button.isPlayer) then
				button.icon:SetDesaturated(true)
				button:SetBorderColor(unpack(C["General"].BorderColor))
			else
				local color = DebuffTypeColor[DType] or DebuffTypeColor.none
				button.icon:SetDesaturated(false)
				button:SetBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			end
		else
			if button.Animation then
				if (IsStealable or DType == "Magic") and not UnitIsFriend("player", unit) and not button.Animation.Playing then
					button.Animation:Play()
					button.Animation.Playing = true
				else
					button.Animation:Stop()
					button.Animation.Playing = false
				end
			end
		end

		if button.Remaining then
			if (Duration and Duration > 0) then
				button.Remaining:Show()
			else
				button.Remaining:Hide()
			end

			button:SetScript("OnUpdate", TukuiUnitFrames.CreateAuraTimer)
		end

		if (button.cd) and (button.IsLibClassicDuration) then
			if (Duration and Duration > 0) then
				button.cd:SetCooldown(ExpirationTime - Duration, Duration)
				button.cd:Show()
			else
				button.cd:Hide()
			end
		end

		button.Duration = Duration
		button.TimeLeft = ExpirationTime
		button.First = true
	end
end

function TukuiUnitFrames:Update()
	for _, element in ipairs(self.__elements) do
		element(self, "UpdateElement", self.unit)
	end
end

function TukuiUnitFrames:DisplayNameplatePowerAndCastBar(unit, cur, min, max)
	if not unit then
		unit = self:GetParent().unit
	end

	if not unit then
		return
	end

	if not cur then
		cur, max = UnitPower(unit), UnitPowerMax(unit)
	end

	local CurrentPower = cur
	local MaxPower = max
	local Nameplate = self:GetParent()
	local PowerBar = Nameplate.Power
	local Health = Nameplate.Health
	local IsPowerHidden = PowerBar.IsHidden

	if (CurrentPower and CurrentPower == 0) and (MaxPower and MaxPower == 0) then
		
		if (not IsPowerHidden) then
			Health:ClearAllPoints()
			Health:SetAllPoints()

			PowerBar:SetAlpha(0)
			PowerBar.IsHidden = true
		end
	else
		if IsPowerHidden then
			Health:ClearAllPoints()
			Health:SetPoint("TOPLEFT")
			Health:SetHeight(C.NamePlates.Height - 3)
			Health:SetWidth(Nameplate:GetWidth())

			PowerBar:SetAlpha(1)
			PowerBar.IsHidden = false
		end
	end
end

function TukuiUnitFrames:GetPartyFramesAttributes()
	return
		"TukuiParty",
		nil,
		"custom [@raid6,exists] hide;show",
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 180,
		"initial-height", 24,
		"showSolo", false,
		"showParty", true,
		"showPlayer", C["Party"].ShowPlayer,
		"showRaid", true,
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"yOffset", -50
end

function TukuiUnitFrames:GetRaidFramesAttributes()
	local Properties = C.Party.Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

	return
		"TukuiRaid",
		nil,
		Properties,
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 66,
		"initial-height", 50,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"showSolo", false,
		"xoffset", 4,
		"yOffset", -4,
		"point", "TOP",
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", C["Raid"].GroupBy.Value,
		"maxColumns", math.ceil(40 / 5),
		"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
		"columnSpacing", 4,
		"columnAnchorPoint", "LEFT"
end

function TukuiUnitFrames:Style(unit)
	if (not unit) then
		return
	end

	local Parent = self:GetParent():GetName()

	if (unit == "player") then
		TukuiUnitFrames.Player(self)
	elseif (unit == "target") then
		TukuiUnitFrames.Target(self)
	elseif (unit == "targettarget") then
		TukuiUnitFrames.TargetOfTarget(self)
	elseif (unit == "pet") then
		TukuiUnitFrames.Pet(self)
	elseif (unit:find("raid")) then
		if Parent:match("Party") then
			TukuiUnitFrames.Party(self)
		else
			TukuiUnitFrames.Raid(self)
		end
	elseif unit:match("nameplate") then
		TukuiUnitFrames.Nameplates(self)
	end

	return self
end

function TukuiUnitFrames:CreateAnchor()
	if not C.UnitFrames.Enable then
		return
	end

	local Anchor = CreateFrame("Frame", "TukuiActionBarAnchor", UIParent)

	if T.Panels.ActionBar2 and T.Panels.ActionBar3 then
		Anchor:SetPoint("TOPLEFT", T.Panels.ActionBar2)
		Anchor:SetPoint("BottomRight", T.Panels.ActionBar3)
	else
		Anchor:SetHeight(1)
		Anchor:SetWidth(800)
		Anchor:SetPoint("BOTTOM", 0, 106)
	end

	TukuiUnitFrames.Anchor = Anchor
end

function TukuiUnitFrames:CreateUnits()
	local Movers = T["Movers"]

	if C.UnitFrames.Enable then
		local Player = oUF:Spawn("player", "TukuiPlayerFrame")
		Player:SetPoint("BOTTOMLEFT", TukuiUnitFrames.Anchor, "TOPLEFT", 0, 8)
		Player:SetParent(UIParent)
		Player:Size(250, 57)

		local Target = oUF:Spawn("target", "TukuiTargetFrame")
		Target:SetPoint("BOTTOMRIGHT", TukuiUnitFrames.Anchor, "TOPRIGHT", 0, 8)
		Target:SetParent(UIParent)
		Target:Size(250, 57)

		local TargetOfTarget = oUF:Spawn("targettarget", "TukuiTargetTargetFrame")
		TargetOfTarget:SetPoint("BOTTOM", TukuiUnitFrames.Anchor, "TOP", 0, 8)
		TargetOfTarget:SetParent(UIParent)
		TargetOfTarget:Size(129, 36)

		local Pet = oUF:Spawn("pet", "TukuiPetFrame")
		Pet:SetParent(UIParent)
		Pet:SetPoint("BOTTOM", TukuiUnitFrames.Anchor, "TOP", 0, 49)
		Pet:Size(129, 36)

		self.Units.Player = Player
		self.Units.Target = Target
		self.Units.TargetOfTarget = TargetOfTarget
		self.Units.Pet = Pet
		
		if C.Party.Enable then
			local Party = oUF:SpawnHeader(TukuiUnitFrames:GetPartyFramesAttributes())
			Party:SetParent(UIParent)
			Party:Point("TOPLEFT", UIParent, "TOPLEFT", 28, -(UIParent:GetHeight() / 2) + 200)

			TukuiUnitFrames.Headers.Party = Party

			Movers:RegisterFrame(Party)
		end

		if C.Raid.Enable then
			local Raid = oUF:SpawnHeader(TukuiUnitFrames:GetRaidFramesAttributes())
			Raid:SetParent(UIParent)
			Raid:Point("TOPLEFT", UIParent, "TOPLEFT", 30, -30)

			TukuiUnitFrames.Headers.Raid = Raid

			Movers:RegisterFrame(Raid)
		end

		Movers:RegisterFrame(Player)
		Movers:RegisterFrame(Target)
		Movers:RegisterFrame(TargetOfTarget)
		Movers:RegisterFrame(Pet)
	end

	if C.NamePlates.Enable then
		oUF:SpawnNamePlates("Tukui", TukuiUnitFrames.NameplatesPostUpdate, TukuiUnitFrames.NameplatesVars)
	end
end

function TukuiUnitFrames:UpdateRaidDebuffIndicator()
	local ORD = Plugin.oUF_RaidDebuffs or oUF_RaidDebuffs

	if (ORD) then
		local _, InstanceType = IsInInstance()

		if (ORD.RegisteredList ~= "RD") and (InstanceType == "party" or InstanceType == "raid") then
			ORD:ResetDebuffData()
			ORD:RegisterDebuffs(TukuiUnitFrames.DebuffsTracking.RaidDebuffs.spells)
			ORD.RegisteredList = "RD"
		else
			if ORD.RegisteredList ~= "CC" then
				ORD:ResetDebuffData()
				ORD:RegisterDebuffs(TukuiUnitFrames.DebuffsTracking.CCDebuffs.spells)
				ORD.RegisteredList = "CC"
			end
		end
	end
end

function TukuiUnitFrames:PostUpdateArenaPreparationSpec()
	local specIcon = self.PVPSpecIcon
	local instanceType = select(2, IsInInstance())

	if (instanceType == "arena") then
		local specID = self.id and GetArenaOpponentSpec(tonumber(self.id))

		if specID and specID > 0 then
			local icon = select(4, GetSpecializationInfoByID(specID))

			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local faction = UnitFactionGroup(self.unit)

		if faction == "Horde" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif faction == "Alliance" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end
end

function TukuiUnitFrames:UpdatePowerColorArenaPreparation(specID)
	-- oUF is unable to get power color on arena preparation, so we add this feature here.
	local Power = self
	local Frame = Power:GetParent()
	local Health = Frame.Health
	local Class = select(6, GetSpecializationInfoByID(specID))

	if Class then
		local PowerColor = oUF.colors.specpowertypes[Class][specID]

		if PowerColor then
			local R, G, B = unpack(PowerColor)

			Power:SetStatusBarColor(R, G, B)
		else
			Power:SetStatusBarColor(0, 0, 0)
		end
	end
end

function TukuiUnitFrames:Enable()
	self.Backdrop = {
		bgFile = C.Medias.Blank,
		insets = {top = -1, left = -1, bottom = -1, right = -1},
	}

	oUF:RegisterStyle("Tukui", TukuiUnitFrames.Style)
	oUF:SetActiveStyle("Tukui")

	self:DisableBlizzard()
	self:CreateAnchor()
	self:CreateUnits()

	if (C.Raid.DebuffWatch) then
		local ORD = Plugin.oUF_RaidDebuffs or oUF_RaidDebuffs
		local RaidDebuffs = CreateFrame("Frame")

		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", TukuiUnitFrames.UpdateRaidDebuffIndicator)

		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end
	end
end

T["UnitFrames"] = TukuiUnitFrames
