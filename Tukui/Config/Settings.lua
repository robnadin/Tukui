local T, C, L = select(2, ...):unpack()

----------------------------------------------------------------
-- Default settings of Tukui
----------------------------------------------------------------

C["General"] = {
	["BackdropColor"] = {0.11, 0.11, 0.11},
	["BorderColor"] = {0, 0, 0},
	["UseGlobal"] = false,
	["HideShadows"] = false,
	["UIScale"] = T.PerfectScale,
	["MinimapScale"] = 100,
	["WorldMapScale"] = 59,

	["Themes"] = {
		["Options"] = {
			["Tukui 18"] = "Tukui 18",
			["Tukui 17"] = "Tukui 17",
		},

		["Value"] = "Tukui 18",
	},
}

C["ActionBars"] = {
	["Enable"] = true,
	["HotKey"] = false,
	["EquipBorder"] = true,
	["Macro"] = false,
	["ShapeShift"] = true,
	["Pet"] = true,
	["SwitchBarOnStance"] = true,
	["NormalButtonSize"] = 27,
	["PetButtonSize"] = 25,
	["ButtonSpacing"] = 4,
	["HideBackdrop"] = false,
	["Font"] = "Tukui Outline",
}

C["Auras"] = {
	["Enable"] = true,
	["Flash"] = true,
	["ClassicTimer"] = false,
	["HideBuffs"] = false,
	["HideDebuffs"] = false,
	["Animation"] = false,
	["BuffsPerRow"] = 12,
	["Font"] = "Tukui Outline",
}

C["Bags"] = {
	["Enable"] = true,
	["ButtonSize"] = 28,
	["Spacing"] = 4,
	["ItemsPerRow"] = 11,
	["Font"] = "Tukui Outline",
}

C["Chat"] = {
	["Enable"] = true,
	["WhisperSound"] = true,
	["ShortChannelName"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["LinkBrackets"] = true,
	["ScrollByX"] = 3,
	["TabFont"] = "Tukui",
	["ChatFont"] = "Tukui",
}

C["Cooldowns"] = {
	["Font"] = "Tukui Outline",
}

C["DataTexts"] = {
	["Battleground"] = true,
	["HideBNConnected"] = true,
	["NameColor"] = {1, 1, 1},
	["ValueColor"] = {1, 1, 1},
	["Hour24"] = false,
	["Font"] = "Tukui",
}

C["Loot"] = {
	["Enable"] = true,
	["StandardLoot"] = false,
	["Font"] = "Tukui",
}

C["Misc"] = {
	["WorldMapEnable"] = true,
	["ExperienceEnable"] = true,
	["ReputationEnable"] = true,
	["ErrorFilterEnable"] = true,
	["AutoSellJunk"] = true,
	["AFKSaver"] = true,
	["FadeWorldMapWhileMoving"] = false,
}

C["NamePlates"] = {
	["Enable"] = true,
	["Width"] = 129,
	["Height"] = 12,
	["Font"] = "Tukui Outline",
	["OnlySelfDebuffs"] = true,
}

C["Party"] = {
	["Enable"] = false,
	["ShowPlayer"] = true,
	["RangeAlpha"] = 0.3,
	["Font"] = "Tukui",
	["HealthFont"] = "Tukui Outline",
}

C["Raid"] = {
	["Enable"] = true,
	["DebuffWatch"] = true,
	["RangeAlpha"] = 0.3,
	["VerticalHealth"] = false,
	["MaxUnitPerColumn"] = 10,
	["Font"] = "Tukui",
	["HealthFont"] = "Tukui Outline",
	["GroupBy"] = {
		["Options"] = {
			["Group"] = "GROUP",
			["Class"] = "CLASS",
			["Role"] = "ROLE",
		},

		["Value"] = "GROUP",
	},
}

C["Tooltips"] = {
	["Enable"] = true,
	["HideOnUnitFrames"] = false,
	["HideInCombat"] = false,
	["UnitHealthText"] = true,
	["MouseOver"] = false,
	["HealthFont"] = "Tukui Outline",
}

C["Textures"] = {
	["QuestProgressTexture"] = "Tukui",
	["TTHealthTexture"] = "Tukui",
	["UFPowerTexture"] = "Tukui",
	["UFHealthTexture"] = "Tukui",
	["UFCastTexture"] = "Tukui",
	["UFPartyPowerTexture"] = "Tukui",
	["UFPartyHealthTexture"] = "Tukui",
	["UFRaidPowerTexture"] = "Tukui",
	["UFRaidHealthTexture"] = "Tukui",
	["NPHealthTexture"] = "Tukui",
	["NPPowerTexture"] = "Tukui",
	["NPCastTexture"] = "Tukui",
}

C["UnitFrames"] = {
	["Enable"] = true,
	["ScrollingCombatText"] = false,
	["ScrollingCombatTextFontSize"] = 32,
	["ScrollingCombatTextFont"] = "Tukui Damage",
	["Portrait"] = false,
	["CastBar"] = true,
	["ComboBar"] = true,
	["UnlinkCastBar"] = false,
	["CastBarIcon"] = true,
	["CastBarLatency"] = true,
	["Smooth"] = true,
	["TargetEnemyHostileColor"] = true,
	["CombatLog"] = true,
	["PlayerAuras"] = true,
	["TargetAuras"] = true,
	["OnlySelfDebuffs"] = false,
	["OnlySelfBuffs"] = false,
	["Font"] = "Tukui Outline",
}
