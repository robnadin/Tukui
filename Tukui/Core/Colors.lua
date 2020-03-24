local T, C, L = select(2, ...):unpack()

local Framework = select(2, ...)
local oUF = oUF or Framework.oUF
local Class = select(2, UnitClass("player"))

oUF.colors.disconnected = {
	0.1, 0.1, 0.1
}

oUF.colors.reaction = {
	[1] = { 0.87, 0.37, 0.37 }, -- Hated
	[2] = { 0.87, 0.37, 0.37 }, -- Hostile
	[3] = { 0.87, 0.37, 0.37 }, -- Unfriendly
	[4] = { 0.85, 0.77, 0.36 }, -- Neutral
	[5] = { 0.29, 0.67, 0.30 }, -- Friendly
	[6] = { 0.29, 0.67, 0.30 }, -- Honored
	[7] = { 0.29, 0.67, 0.30 }, -- Revered
	[8] = { 0.29, 0.67, 0.30 }, -- Exalted
}

oUF.colors.power = {
	["MANA"]              = {0.31, 0.45, 0.63},
	["RAGE"]              = {0.69, 0.31, 0.31},
	["ENERGY"]            = {0.65, 0.63, 0.35},
	["FOCUS"]             = {0.71, 0.43, 0.27},
	["AMMOSLOT"]          = {0.80, 0.60, 0.00},
}

oUF.colors.class = {
	["DRUID"]       = { 1.00, 0.49, 0.03 },
	["HUNTER"]      = { 0.67, 0.84, 0.45 },
	["MAGE"]        = { 0.41, 0.80, 1.00 },
	["PALADIN"]     = { 0.96, 0.55, 0.73 },
	["PRIEST"]      = { 0.95, 0.95, 0.95 },
	["ROGUE"]       = { 1.00, 0.95, 0.32 },
	["SHAMAN"]      = { 0.01, 0.44, 0.87 },
	["WARLOCK"]     = { 0.58, 0.51, 0.79 },
	["WARRIOR"]     = { 0.78, 0.61, 0.43 },
}

oUF.colors.happiness = {
	[1] = {.69,.31,.31},
	[2] = {.65,.63,.35},
	[3] = {.33,.59,.33},
}

oUF.colors.specpowertypes = {
	["WARRIOR"] = {
		[71] = oUF.colors.power["RAGE"],
		[72] = oUF.colors.power["RAGE"],
		[73] = oUF.colors.power["RAGE"],
	},

	["PALADIN"] = {
		[65] = oUF.colors.power["MANA"],
		[66] = oUF.colors.power["MANA"],
		[70] = oUF.colors.power["MANA"],
	},

	["HUNTER"] = {
		[253] = oUF.colors.power["MANA"],
		[254] = oUF.colors.power["MANA"],
		[255] = oUF.colors.power["MANA"],
	},

	["ROGUE"] = {
		[259] = oUF.colors.power["ENERGY"],
		[260] = oUF.colors.power["ENERGY"],
		[261] = oUF.colors.power["ENERGY"],
	},

	["PRIEST"] = {
		[256] = oUF.colors.power["MANA"],
		[257] = oUF.colors.power["MANA"],
		[258] = oUF.colors.power["MANA"],
	},

	["SHAMAN"] = {
		[262] = oUF.colors.power["MANA"],
		[263] = oUF.colors.power["MANA"],
		[264] = oUF.colors.power["MANA"],
	},

	["MAGE"] = {
		[62] = oUF.colors.power["MANA"],
		[63] = oUF.colors.power["MANA"],
		[64] = oUF.colors.power["MANA"],
	},

	["WARLOCK"] = {
		[265] = oUF.colors.power["MANA"],
		[266] = oUF.colors.power["MANA"],
		[267] = oUF.colors.power["MANA"],
	},

	["DRUID"] = {
		[102] = oUF.colors.power["MANA"],
		[103] = oUF.colors.power["ENERGY"],
		[104] = oUF.colors.power["RAGE"],
		[105] = oUF.colors.power["MANA"],
	},
}

T["Colors"] = oUF.colors
