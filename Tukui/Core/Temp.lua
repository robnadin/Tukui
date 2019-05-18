----------------------------------
-- Temporary code in this file! --
----------------------------------

local T, C, L = select(2, ...):unpack()

-- Temp for 8.0.1
GroupLootContainer:EnableMouse(false)

-- BUG TO REPORT AT BLIZZARD

-- Message: Interface\FrameXML\SecureGroupHeaders.lua:303: attempt to call global 'UnitGroupRolesAssigned' (a nil value)
-- Cause: UnitGroupRolesAssigned still exist in SecureGroupHeaders, it should not
-- UnitGroupRolesAssigned = function() return "" end

-- Message: Interface\FrameXML\SecureTemplates.lua:219: attempt to call global 'UnitIsOtherPlayersBattlePet' (a nil value)
-- Cause: UnitIsOtherPlayersBattlePet still exist in SecureTemplates, it should not
UnitIsOtherPlayersBattlePet = function(unit) return false end

