local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))

if (Class ~= "PALADIN") then
	return
end

TukuiUnitFrames.AddClassFeatures["PALADIN"] = function(self)

end
