local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local Class = select(2, UnitClass("player"))

local OnEnter = function(self)
	if (not InCombatLockdown()) then
		local SpellPower = GetSpellBonusDamage(7)
		local BonusHealing = GetSpellBonusHealing()
		local PowerRegenBase, PowerRegenCombat = GetPowerRegen()
		local CritMelee = GetCritChance()
		local CritSpell = GetSpellCritChance(1)
		local CritRanged = GetRangedCritChance()
		local CritValue
		
		if (CritSpell > CritMelee) then
			CritValue = CritSpell
		elseif (Class == "HUNTER") then
			CritValue = CritRanged
		else
			CritValue = CritMelee
		end
		
		CritValue = string.format("%.2f", CritValue)
		
		PaperDollFrame_UpdateStats()
		
		GameTooltip:SetOwner(self:GetTooltipAnchor())
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Character Stats")
		GameTooltip:AddLine(" ")
		
		for i=1, NUM_STATS, 1 do
			local Text = _G["CharacterStatFrame"..i.."StatText"]
			local Frame = _G["CharacterStatFrame"..i]
			local Stat = Frame.Label:GetText()
			local Value = Text:GetText()
			
			GameTooltip:AddDoubleLine(Stat, Value)
		end
		
		GameTooltip:AddLine(" ")

		if UnitPowerType("player") == Enum.PowerType.Mana then
			GameTooltip:AddDoubleLine(STAT_SPELLPOWER..":", SpellPower)
			GameTooltip:AddDoubleLine(BONUS_HEALING..":", BonusHealing)
			GameTooltip:AddDoubleLine(ITEM_MOD_POWER_REGEN0_SHORT..":", floor(PowerRegenCombat + 0.5))
		end
		
		GameTooltip:AddDoubleLine(MELEE_CRIT_CHANCE..":", CritValue.."%")
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(CharacterAttackFrame.Label:GetText()..":", CharacterAttackFrameStatText:GetText())
		GameTooltip:AddDoubleLine(CharacterAttackPowerFrame.Label:GetText(), CharacterAttackPowerFrameStatText:GetText())
		GameTooltip:AddDoubleLine(CharacterDamageFrame.Label:GetText(), CharacterDamageFrameStatText:GetText())
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(CharacterRangedAttackFrame.Label:GetText()..":", CharacterRangedAttackFrameStatText:GetText())
		GameTooltip:AddDoubleLine(CharacterRangedAttackPowerFrame.Label:GetText(), CharacterRangedAttackPowerFrameStatText:GetText())
		GameTooltip:AddDoubleLine(CharacterRangedDamageFrame.Label:GetText(), CharacterRangedDamageFrameStatText:GetText())
		
		GameTooltip:Show()
	end
end

local Enable = function(self)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self.Text:SetText(PAPERDOLL_SIDEBAR_STATS)
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end

DataText:Register("Stats", Enable, Disable, Update)
