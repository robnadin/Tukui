local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]

TukuiUnitFrames.DebuffsTracking = {}

------------------------------------------------------------------------------------
-- Locales functions and tables
------------------------------------------------------------------------------------

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

------------------------------------------------------------------------------------
-- RAID DEBUFFS (TRACKING LIST)
------------------------------------------------------------------------------------

TukuiUnitFrames.DebuffsTracking["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
		-- [209858] = Defaults(), -- Necrotic
	},
}

------------------------------------------------------------------------------------
-- CC DEBUFFS (TRACKING LIST)
------------------------------------------------------------------------------------

TukuiUnitFrames.DebuffsTracking["CCDebuffs"] = {
	-- BROKEN: Need to build a new classic cc debuffs list
	-- EXAMPLE: See comment in spells table
	
	["type"] = "Whitelist",
	["spells"] = {
		-- [107079] = Defaults(4), -- Quaking Palm
	},
}

------------------------------------------------------------------------------------
-- RAID BUFFS (SQUARED AURA TRACKING LIST)
------------------------------------------------------------------------------------

TukuiUnitFrames.RaidBuffsTracking = {
	-- BROKEN:  Need a classic spellID check in database.
	-- EXAMPLE: PRIEST = { {139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, },
	
	PRIEST = {

	},

	DRUID = {

	},

	PALADIN = {

	},

	SHAMAN = {

	},
}