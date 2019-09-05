-- This plugin require a power status bar (self.Power)
-- To add this feature in your layout, add this:
-- self.PowerTicker = CreateFrame("Frame", "Ticker", self.Power)
-- self.PowerTicker.Texture is optional in your layout, however if you set your own spark, it need to be parented to self.Power

local parent, ns = ...
local oUF = ns.oUF
local LastEnergyTickTime = GetTime()
local LastEnergyValue = 0

local function SetEnergyTickValue(self, timer)
	if not self.Texture then
		return
	end
	
	local Power = self:GetParent()
	local Width = Power:GetWidth()
	local Min, Max = UnitPower("player"), UnitPowerMax("player")
	local PType = UnitPowerType("player")

	if (Min == Max or PType ~= Enum.PowerType.Energy) and not IsStealthed() then
		if not self.IsHidden then
			self.Texture:Hide()

			self.IsHidden = true
		end
	else
		if self.IsHidden then
			self.Texture:Show()

			self.IsHidden = false
		end

		self.Texture:SetPoint("CENTER", Power, "LEFT", (Width * timer) / 2, 0)
	end
end

local Update = function(self, elapsed)
	local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)

	local Now = GetTime()
	local Timer = Now - LastEnergyTickTime

	if CurrentEnergy > LastEnergyValue or Now >= LastEnergyTickTime + 2 then
		LastEnergyTickTime = Now
	end

	SetEnergyTickValue(self, Timer)

	LastEnergyValue = CurrentEnergy
end

local Path = function(self, ...)
	return (self.Override or Update) (self, ...)
end


local Enable = function(self, unit)
	local PowerTicker = self.PowerTicker
	local Power = self.Power
	
	if (Power) and (PowerTicker) and (unit == "player") then
		PowerTicker.__owner = self

		if not PowerTicker.Texture then
			PowerTicker.Texture = self.Power:CreateTexture(nil, 'OVERLAY', 8)
			PowerTicker.Texture:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			PowerTicker.Texture:SetSize(Power:GetHeight() + 4, Power:GetHeight() + 4)
			PowerTicker.Texture:SetPoint("CENTER", Power, 0, 0)
			PowerTicker.Texture:SetBlendMode("ADD")
		end

		PowerTicker:SetScript("OnUpdate", Path)

		return true
	end
end

local Disable = function(self)
	local PowerTicker = self.PowerTicker
	local Power = self.Power
	
	if (Power) and (PowerTicker) then
		PowerTicker:SetScript("OnUpdate", nil)
		
		return false
	end
end

oUF:AddElement("PowerTicker", Path, Enable, Disable)
