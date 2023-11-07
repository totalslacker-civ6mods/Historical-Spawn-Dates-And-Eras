-- ===========================================================================
--	Historical Victory Scripts
-- ===========================================================================
print("Loading HistoricalVictory_Scripts.lua")

ExposedMembers.GetPlayerCityUIDatas = {}
ExposedMembers.GetCalendarTurnYear = {}

-- Helper functions

local function GetBuildingCount(iPlayer, buildingType)
	print("Checking total number of "..tostring(buildingType).." owned by player "..tostring(iPlayer))
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local buildingCount = 0
	
	if not GameInfo.Buildings[buildingType] then
		print("WARNING: Building type "..tostring(buildingType).." not detected in game database!")
		return buildingCount
	end
	
	local buildingIndex = GameInfo.Buildings[buildingType].Index
		
	for _, city in playerCities:Members() do
		if city:GetBuildings():HasBuilding(buildingIndex) then
			buildingCount = buildingCount + 1
		end
	end
	
	return buildingCount
end

local function GetTotalRoutePlots(iPlayer)
	print("Checking for total number of route plots owned by player "..tostring(iPlayer))
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local routeCount = 0
	
	for _, city in playerCities:Members() do
		local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(iPlayer, city:GetID())
		for _,kCityUIDatas in pairs(CityUIDataList) do
			for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
				local plot = Map.GetPlotByIndex(kCoordinates.plotID)
				if plot:IsRoute() then
					routeCount = routeCount + 1
					print("plot isRoute detected. Total count is "..tostring(routeCount))
				end
			end
		end
	end
	
	return routeCount
end

local function DistrictTypeCount_EnumerateDistrict(iPlayer, districtType)
	print("Checking for total number of "..tostring(districtType).." districts.")
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local districtCount = 0
	
	if not GameInfo.Districts[districtType] then
		print("WARNING: District type "..tostring(districtType).." not detected.")
		return districtCount
	end
	
	for _, city in playerCities:Members() do
		local districts = city:GetDistricts()
		if (districts ~= nil) then
			local iX, iY = districts:GetDistrictLocation(GameInfo.Districts[districtType].Index)
			if (iX ~= nil and iY ~= nil) then
				local districtPlot = Map.GetPlot(iX, iY)
				if (districtPlot ~= nil) then
					districtCount = districtCount + 1
				end
			end
		end
	end
	
	return districtCount
end

local function DistrictTypeCount_HasDistrict(iPlayer, districtType)
	print("Checking for total number of "..tostring(districtType).." districts.")
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local districtCount = 0
	
	if not GameInfo.Districts[districtType] then
		print("WARNING: District type "..tostring(districtType).." not detected in game database!")
		return districtCount
	end
	
	for _, city in playerCities:Members() do
		local districts = city:GetDistricts()
		if (districts ~= nil) then
			local hasDistrict = districts:HasDistrict(GameInfo.Districts[districtType].Index)
			if hasDistrict then
				districtCount = districtCount + 1
				print(tostring(districtType).." detected. Total count is "..tostring(districtCount))
			end
		else
			print("No districts detected in city!")
		end
	end
	
	return districtCount
end

-- Set property to match building player when a wonder is built
function HSD_HistoricalVictory_WonderConstructed(iX, iY, buildingIndex, playerIndex, cityID, iPercentComplete, iUnknown)
	if buildingIndex == GameInfo.Buildings["BUILDING_COLOSSEUM"].Index then
		Game:SetProperty("HSD_WONDER_COLOSSEUM", playerIndex)
	end
end

-- Called at the start of every player's turn
function GetHistoricalVictoryConditions(iPlayer)
	local player = Players[iPlayer]
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName() 
	local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
	local bLeaderVictory = false
	local currentTurn = Game.GetCurrentGameTurn() - 1 -- Use previous turn year since we call at the start of turn
	local currentTurnYear = ExposedMembers.GetCalendarTurnYear(Game.GetCurrentGameTurn())
	
	-- Check if leader victories are enabled and change to the leader name instead
	if MapConfiguration.GetValue("HSD_LEADER_VICTORIES") then
		CivilizationTypeName = LeaderTypeName
	end
	print("Checking Historical Victory conditions for "..tostring(CivilizationTypeName))
	
	if CivilizationTypeName == "CIVILIZATION_ROME" then
		-- Pax Romana
		if not (player:GetProperty("HSD_HISTORICAL_VICTORY_1")) then
			if (currentTurnYear <= 100) then
				print("currentTurnYear = "..tostring(currentTurnYear))
				-- Build the Colosseum (monument placeholder for testing)
				if Game:GetProperty("HSD_WONDER_COLOSSEUM") then
					if Game:GetProperty("HSD_WONDER_COLOSSEUM") == iPlayer then
						player:SetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_1", 1)
					else
						player:SetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_1", -1)
					end
				end
				-- placeholder
				local buildingCount = GetBuildingCount(iPlayer, "BUILDING_MONUMENT")
				if buildingCount > 0 then
					player:SetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_1", 1)
				end
				-- Control 4 Bath Districts (1 city center for testing)
				local districtCount = DistrictTypeCount_HasDistrict(iPlayer, "DISTRICT_CITY_CENTER")
				if districtCount > 0 then
					player:SetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_2", 1)
				end
				-- Control 15 road plots (1 for testing)
				local roadCount = GetTotalRoutePlots(iPlayer)
				if roadCount > 0 then
					player:SetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_3", 1)
				end
				
				-- Award victory score
				if (player:GetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_1") == 1) and (player:GetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_2") == 1) and (player:GetProperty("HSD_HISTORICAL_VICTORY_1_OBJECTIVE_3") == 1) then
					player:SetProperty("HSD_HISTORICAL_VICTORY_1", currentTurn)
					local victoryScore = player:GetProperty("HSD_HISTORICAL_VICTORY_SCORE") or 0
					player:SetProperty("HSD_HISTORICAL_VICTORY_SCORE", victoryScore + 1)
				end
			else
				player:SetProperty("HSD_HISTORICAL_VICTORY_1", -1)
			end
		end
	end
end

Events.WonderCompleted.Add(HSD_HistoricalVictory_WonderConstructed)
GameEvents.PlayerTurnStarted.Add(GetHistoricalVictoryConditions)