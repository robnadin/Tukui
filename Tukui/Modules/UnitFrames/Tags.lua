local T, C, L = select(2, ...):unpack()
local AddOn, Plugin = ...
local oUF = Plugin.oUF or oUF
local UnitFrames = T["UnitFrames"]
local DEAD = DEAD
local CHAT_FLAG_AFK = CHAT_FLAG_AFK

UnitFrames.ShortNameLength = 10

oUF.Tags.Events["Tukui:GetRaidNameColor"] = "RAID_ROSTER_UPDATE GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["Tukui:GetRaidNameColor"] = function(unit)
	local IsPlayer = UnitIsPlayer(unit)
	local Reaction = UnitReaction(unit, "player")
	local R, G, B = 1, 1, 1

	if IsPlayer then
		local Class = select(2, UnitClass(unit))

		if Class then
			R, G, B = unpack(T.Colors.class[Class])
		end
	elseif Reaction then
		R, G, B = unpack(T.Colors.reaction[Reaction])
	end

	return string.format("|cff%02x%02x%02x", R * 255, G * 255, B * 255)
end

oUF.Tags.Events["Tukui:GetNameColor"] = "UNIT_POWER_UPDATE"
oUF.Tags.Methods["Tukui:GetNameColor"] = function(unit)
	local Reaction = UnitReaction(unit, "player")

	if (UnitIsPlayer(unit)) then
		return _TAGS["raidcolor"](unit)
	elseif (Reaction) then
		local c = T.Colors.reaction[Reaction]

		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		return string.format("|cff%02x%02x%02x", 1, 1, 1)
	end
end

oUF.Tags.Events["Tukui:GetNameHostilityColor"] = "UNIT_POWER_UPDATE"
oUF.Tags.Methods["Tukui:GetNameHostilityColor"] = function(unit)
	local Reaction = UnitReaction(unit, "player")

	if (Reaction) then
		local c = T.Colors.reaction[Reaction]

		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		return string.format("|cff%02x%02x%02x", 1, 1, 1)
	end
end

oUF.Tags.Events["Tukui:DiffColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["Tukui:DiffColor"] = function(unit)
	local r, g, b
	local Level = UnitLevel(unit)

	if (Level < 1) then
		r, g, b = 0.69, 0.31, 0.31
	else
		local DiffColor = UnitLevel(unit) - UnitLevel("player")

		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		--elseif (-DiffColor <= GetQuestGreenRange()) then
			--r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end

	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

oUF.Tags.Events["Tukui:NameShort"] = "UNIT_NAME_UPDATE PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["Tukui:NameShort"] = function(unit)
	local Name = UnitName(unit) or ""
	local IsLeader = UnitIsGroupLeader(unit)
	local IsAssistant = UnitIsGroupAssistant(unit) or UnitIsRaidOfficer(unit)
	local Assist, Lead = IsAssistant and "[A] " or "", IsLeader and "[L] " or ""

	return UnitFrames.UTF8Sub(Lead..Assist..Name, UnitFrames.ShortNameLength, false)
end

oUF.Tags.Events["Tukui:NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["Tukui:NameMedium"] = function(unit)
	local Name = UnitName(unit) or ""
	return UnitFrames.UTF8Sub(Name, 15, true)
end

oUF.Tags.Events["Tukui:NameLong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["Tukui:NameLong"] = function(unit)
	local Name = UnitName(unit) or ""
	return UnitFrames.UTF8Sub(Name, 20, true)
end

oUF.Tags.Events["Tukui:Dead"] = "UNIT_HEALTH"
oUF.Tags.Methods["Tukui:Dead"] = function(unit)
	if UnitIsDeadOrGhost(unit) then
		return DEAD
	end
end

oUF.Tags.Events["Tukui:CurrentHP"] = "UNIT_HEALTH"
oUF.Tags.Methods["Tukui:CurrentHP"] = function(unit)
	local HP = UnitFrames.ShortValue(UnitHealth(unit))
	
	return HP
end

oUF.Tags.Events["Tukui:AFK"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["Tukui:AFK"] = function(unit)
	if UnitIsAFK(unit) then
		return CHAT_FLAG_AFK
	end
end

oUF.Tags.Events["Tukui:Classification"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["Tukui:Classification"] = function(unit)
	local C = UnitClassification(unit)

	if(C == "rare") then
		return "|cffffff00R |r"
	elseif(C == "rareelite") then
		return "|cFFFF4500R+ |r"
	elseif(C == "elite") then
		return "|cFFFFA500+ |r"
	elseif(C == "worldboss") then
		return "|cffff0000B |r"
	elseif(C == "minus") then
		return "|cff888888- |r"
	end
end

UnitFrames.Tags = oUF.Tags
