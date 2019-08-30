local T, C, L = select(2, ...):unpack()

local WorldMap = CreateFrame("Frame")
local WorldMapFrame = WorldMapFrame
local FadeMap = PlayerMovementFrameFader.AddDeferredFrame

function WorldMap:OnUpdate(elapsed)
	if not WorldMapFrame:IsShown() then
		return
	end
	
	WorldMap.Interval = WorldMap.Interval - elapsed

	if WorldMap.Interval < 0 then
		local UnitMap = C_Map.GetBestMapForUnit("player")
		local X, Y = 0, 0
		local MouseX, MouseY = GetCursorPosition()

		if UnitMap then
			local GetPlayerMapPosition = C_Map.GetPlayerMapPosition(UnitMap, "player")

			if GetPlayerMapPosition then
				X, Y = C_Map.GetPlayerMapPosition(UnitMap, "player"):GetXY()
			end
		end

		X = math.floor(100 * X)
		Y = math.floor(100 * Y)

		if X ~= 0 and Y ~= 0 then
			WorldMap.Coords.PlayerText:SetText(PLAYER..":   "..X..", "..Y)
		else
			WorldMap.Coords.PlayerText:SetText(" ")
		end
		
		-- Mouse Coords
		local Scale = WorldMapFrame:GetCanvas():GetEffectiveScale()
		MouseX = MouseX / Scale
		MouseY = MouseY / Scale
		
		local Width = WorldMapFrame:GetCanvas():GetWidth()
		local Height = WorldMapFrame:GetCanvas():GetHeight()
		local Left = WorldMapFrame:GetCanvas():GetLeft()
		local Top = WorldMapFrame:GetCanvas():GetTop()
		
		MouseX = math.floor((MouseX - Left) / Width * 100)
		MouseY = math.floor((Top - MouseY) / Height * 100)
		
		if MouseX ~= 0 and MouseY ~= 0 then
			WorldMap.Coords.CursorText:SetText(MOUSE_LABEL..":   "..MouseX..", "..MouseY)
		else
			WorldMap.Coords.CursorText:SetText(" ")
		end

		WorldMap.Interval = 0.1
	end
end

function WorldMap:CreateCoords()
	local Map = WorldMapFrame.ScrollContainer.Child
	
	self.Coords = CreateFrame("Frame", nil, WorldMapFrame)
	self.Coords:SetFrameLevel(90)
	self.Coords.PlayerText = self.Coords:CreateFontString(nil, "OVERLAY")
	self.Coords.PlayerText:SetFontTemplate(C.Medias.Font, 16)
	self.Coords.PlayerText:SetTextColor(1, 1, 1)
	self.Coords.PlayerText:SetPoint("BOTTOMLEFT", Map, "BOTTOMLEFT", 5, 5)
	self.Coords.PlayerText:SetText("")
	self.Coords.CursorText = self.Coords:CreateFontString(nil, "OVERLAY")
	self.Coords.CursorText:SetFontTemplate(C.Medias.Font, 16)
	self.Coords.CursorText:SetTextColor(1, 1, 1)
	self.Coords.CursorText:SetPoint("BOTTOMRIGHT", Map, "BOTTOMRIGHT", -5, 5)
	self.Coords.CursorText:SetText("")
end

function WorldMap:SkinMap()
	local Frame = WorldMapFrame
	local Blackout = Frame.BlackoutFrame
	local Borders = Frame.BorderFrame
	local Map = Frame.ScrollContainer.Child
	local CloseButton = WorldMapFrameCloseButton
	local ContinentButton = WorldMapContinentDropDown
	local ZoneButton = WorldMapZoneDropDown
	local ZoonButton = WorldMapZoomOutButton
	local MagnifyButton = WorldMapMagnifyingGlassButton
	
	Frame:CreateBackdrop()
	Frame.Backdrop:ClearAllPoints()
	Frame.Backdrop:SetAllPoints(Map)
	Frame.Backdrop:CreateShadow()

	Blackout:StripTextures()
	Blackout:EnableMouse(false)
	
	Borders:SetAlpha(0)
	
	ContinentButton:SetParent(T.Hider)
	
	ZoneButton:SetParent(T.Hider)
	
	WorldMapZoomOutButton:SetParent(T.Hider)
	
	MagnifyButton:SetParent(T.Hider)
	
	CloseButton:ClearAllPoints()
	CloseButton:SetPoint("TOPRIGHT", -10, -72)
	CloseButton:SetFrameStrata("FULLSCREEN")
	CloseButton:SetFrameLevel(Map:GetFrameLevel() + 1)
end

function WorldMap:SizeMap()
	local Scale = C.General.WorldMapScale / 100
	
	WorldMapFrame:SetScale(Scale)
	
	WorldMapFrame.ScrollContainer.GetCursorPosition = function(self)
	   local X, Y = MapCanvasScrollControllerMixin.GetCursorPosition(self)
	   local Scale = WorldMapFrame:GetScale()
		
	   return X / Scale, Y / Scale
	end
end

function WorldMap:AddMoving()
	WorldMap.MoveButton = CreateFrame("Frame", nil, WorldMapFrame)
	WorldMap.MoveButton:SetSize(60, 23)
	WorldMap.MoveButton:SetPoint("TOPLEFT", 24, -80)
	WorldMap.MoveButton:SetTemplate()
	WorldMap.MoveButton:CreateShadow()
	WorldMap.MoveButton:SetFrameLevel(WorldMapFrameCloseButton:GetFrameLevel())
	WorldMap.MoveButton:EnableMouse(true)
	WorldMap.MoveButton:RegisterForDrag("LeftButton")
	
	WorldMap.MoveButton.Title = WorldMap.MoveButton:CreateFontString(nil, "OVERLAY")
	WorldMap.MoveButton.Title:SetPoint("LEFT", 5, 0)
	WorldMap.MoveButton.Title:SetFontTemplate(C.Medias.Font, 16)
	WorldMap.MoveButton.Title:SetText("Drag me")
	
	WorldMapFrame:SetMovable(true)
	WorldMapFrame:SetUserPlaced(true)
	
	WorldMapFrame.ClearAllPoints = function() end
	WorldMapFrame.SetPoint = function() end
	
	WorldMap.MoveButton:SetScript("OnDragStart", function(self)
		WorldMapFrame:StartMoving()
	end)
	
	WorldMap.MoveButton:SetScript("OnDragStop", function(self)
		WorldMapFrame:StopMovingOrSizing()
	end)
end

function WorldMap:AddFading()
	FadeMap(WorldMapFrame, .3)
end

function WorldMap:Enable()
	self.Interval = 0.1
	self:CreateCoords()
	self:HookScript("OnUpdate", WorldMap.OnUpdate)
	self:SkinMap()
	self:SizeMap()
	self:AddMoving()
	
	if C.Misc.FadeWorldMapWhileMoving then
		self:AddFading()
	end
	
	UIPanelWindows["WorldMapFrame"] = nil
	WorldMapFrame:SetAttribute("UIPanelLayout-area", nil)
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	
	tinsert(UISpecialFrames, "WorldMapFrame")
end

T["Maps"].Worldmap = WorldMap
