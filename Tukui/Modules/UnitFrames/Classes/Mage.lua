local T, C, L = select(2, ...):unpack()

local TukuiUnitFrames = T["UnitFrames"]
local Class = select(2, UnitClass("player"))

if (Class ~= "MAGE") then
	return
end

TukuiUnitFrames.AddClassFeatures["MAGE"] = function(self)

end
