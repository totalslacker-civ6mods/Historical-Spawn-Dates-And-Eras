-- ===========================================================================
--	Historical Victory Scripts
-- ===========================================================================
include("HistoricalVictory_Data");

print("Loading HistoricalVictory_Scripts.lua")

-- ===========================================================================
-- UI Context from ExposedMembers
-- ===========================================================================

ExposedMembers.GetPlayerCityUIDatas = {}
ExposedMembers.GetCalendarTurnYear = {}
ExposedMembers.CheckCityOriginalCapital = {}
ExposedMembers.HSD_GetTerritoryCache = {}
ExposedMembers.HSD_GetTerritoryID = {}

-- ===========================================================================
-- Variables
-- ===========================================================================

local territoryCache = {} -- Used to track territories detected from UI context

-- ===========================================================================
-- Helper functions
-- ===========================================================================
local function GetOccupiedCapitals(playerID)
    print("Checking number of occupied capitals for player " .. tostring(playerID))
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local count = 0

    for _, city in playerCities:Members() do
		-- print("city name is "..tostring(city:GetName()))
        if ExposedMembers.CheckCityOriginalCapital(playerID, city:GetID()) then
            count = count + 1
        end
    end

    print("Player " .. tostring(playerID) .. " owns " .. tostring(count) .. " occupied capitals.")
    return count
end

local function GetSuzeraintyCount(playerID)
    local suzerainCount = 0

    local playerDiplomacy = Players[playerID]:GetDiplomacy()

    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        local otherPlayer = Players[otherPlayerID]
        if otherPlayer:IsMinor() then
            local suzerainID = otherPlayer:GetInfluence():GetSuzerain()
            if suzerainID == playerID then
                suzerainCount = suzerainCount + 1
            end
        end
    end

    return suzerainCount
end

local function GetUnitCount(playerID, unitType)
    print("Checking number of " .. tostring(unitType) .. " units for player " .. tostring(playerID))
    local player = Players[playerID]
    local playerUnits = player:GetUnits()
    local count = 0

    for _, unit in playerUnits:Members() do
		-- print("unitType is "..tostring(unit:GetType()))
        if unit:GetType() == GameInfo.Units[unitType].Index then
            count = count + 1
        end
    end

    print("Player " .. tostring(playerID) .. " owns " .. tostring(count) .. " " .. tostring(unitType) .. " units.")
    return count
end

local function GetBorderingCitiesCount(iPlayer)
    local player = Players[iPlayer]
    local playerCities = player:GetCities()
    local borderingCityCount = 0

    for _, city in playerCities:Members() do
        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(iPlayer, city:GetID())
        for _, kCityUIDatas in pairs(CityUIDataList) do
            for _, kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
				local isBorderCity = false
                local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                if plot then
                    for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
                        local adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), direction)
                        if adjacentPlot and adjacentPlot:IsOwned() and adjacentPlot:GetOwner() ~= iPlayer then
                            borderingCityCount = borderingCityCount + 1
							isBorderCity = true
                            print("City bordering another player's territory detected. Total count is " .. tostring(borderingCityCount))
                            break -- Once a border is found, no need to check other plots for this city
                        end
                    end
                end
				if isBorderCity then
					break -- City already counted, move to next city
				end
            end
        end
    end

    return borderingCityCount
end

local function GetCityAdjacentToRiverCount(playerID)
    local player = Players[playerID]
    if not player then
        print("Invalid player ID: " .. tostring(playerID))
        return 0
    end

    local playerCities = player:GetCities()
    local riverAdjacentCityCount = 0

    for _, city in playerCities:Members() do
        local cityX, cityY = city:GetX(), city:GetY()
        local cityPlot = Map.GetPlot(cityX, cityY)

        if cityPlot:IsRiver() then
            riverAdjacentCityCount = riverAdjacentCityCount + 1
        else
            -- Check adjacent plots if the city center is not directly on a river
            for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
                local adjacentPlot = Map.GetAdjacentPlot(cityX, cityY, direction)
                if adjacentPlot and adjacentPlot:IsRiver() then
                    riverAdjacentCityCount = riverAdjacentCityCount + 1
                    break -- Found a river adjacent plot, no need to check further
                end
            end
        end
    end

    return riverAdjacentCityCount
end

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

local function GetImprovementCount(iPlayer, improvementType)
	print("Checking for total number of "..tostring(improvementType).." owned by player "..tostring(iPlayer))
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local improvementCount = 0
	
    if not GameInfo.Improvements[improvementType] then
        print("Improvement type " .. tostring(improvementType) .. " not found in GameInfo.")
        return false
    end

    local improvementIndex = GameInfo.Improvements[improvementType].Index
	
	for _, city in playerCities:Members() do
		local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(iPlayer, city:GetID())
		for _,kCityUIDatas in pairs(CityUIDataList) do
			for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
				local plot = Map.GetPlotByIndex(kCoordinates.plotID)
				if plot and plot:GetImprovementType() == improvementIndex then
					improvementCount = improvementCount + 1
					print("Improvement detected. Total count is "..tostring(improvementCount))
				end
			end
		end
	end
	
	return improvementCount
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

local function GetWonderAdjacentImprovement(playerID, wonderType, improvementType)
    print("Checking for " .. tostring(wonderType) .. " adjacent to " .. tostring(improvementType) .. " for player #" .. tostring(playerID))
    local player = Players[playerID]
    local playerCities = player:GetCities()
    
    if not GameInfo.Buildings[wonderType] then
        print("Wonder type " .. tostring(wonderType) .. " not found in GameInfo.")
        return false
    end

    if not GameInfo.Improvements[improvementType] then
        print("Improvement type " .. tostring(improvementType) .. " not found in GameInfo.")
        return false
    end

    local wonderIndex = GameInfo.Buildings[wonderType].Index
    local improvementIndex = GameInfo.Improvements[improvementType].Index

    for _, city in playerCities:Members() do
        if city:GetBuildings():HasBuilding(wonderIndex) then
			local wonderX, wonderY = city:GetBuildings():GetBuildingLocation(wonderIndex)
			if not wonderX or not wonderY then
				local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(playerID, city:GetID())
				for _,kCityUIDatas in pairs(CityUIDataList) do
					for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
						local plot = Map.GetPlotByIndex(kCoordinates.plotID)
						print("Plot wonder type is "..tostring(plot:GetWonderType()))
						if (plot:GetWonderType() == wonderIndex) and plot:IsWonderComplete() then
							wonderX, wonderY = plot:GetX(), plot:GetY()
						end
					end
				end
			end
            for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
                local adjacentPlot = Map.GetAdjacentPlot(wonderX, wonderY, direction)
                if adjacentPlot and adjacentPlot:GetImprovementType() == improvementIndex then
                    print("Found " .. improvementType .. " adjacent to " .. wonderType)
                    return true
                end
            end
        end
    end

    print("No " .. improvementType .. " found adjacent to " .. wonderType)
    return false
end

local function GetDistrictLocations(iPlayer, districtType)
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local districtLocations = {}
	local districtInfo = GameInfo.Districts[districtType]

	if not districtInfo then
		print("WARNING: District type " .. tostring(districtType) .. " not detected in game database!")
		return districtLocations
	end

	local districtIndex = districtInfo.Index

	for _, city in playerCities:Members() do
		local cityID = city:GetID()
		local districts = city:GetDistricts()
		if districts ~= nil then
			local districtX, districtY = districts:GetDistrictLocation(districtIndex)
			if districtX ~= nil and districtY ~= nil then
				if not districtLocations[cityID] then
					districtLocations[cityID] = {}
				end
				table.insert(districtLocations[cityID], {districtX, districtY})
			end
		end
	end

	return districtLocations
end

local function GetDistrictTypeCount(iPlayer, districtType)
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

-- Helper function to check if the civilization controls the required percentage of land area
local function GetPercentLandArea_ContinentType(playerID, continentName, percent)
    print("Checking land area control for player " .. tostring(playerID) .. " on continent " .. continentName)
    local totalContinentPlots = 0
    local controlledPlots = 0
	local tContinents = Map.GetContinentsInUse()
	
	for i,iContinent in ipairs(tContinents) do
		if (GameInfo.Continents[iContinent].ContinentType == continentName) then
			print("Continent type is "..tostring(GameInfo.Continents[iContinent].ContinentType))
			local continentPlotIndexes = Map.GetContinentPlots(iContinent)
			for _, plotID in ipairs(continentPlotIndexes) do
				local continentPlot = Map.GetPlotByIndex(plotID)
				if continentPlot:IsOwned() and continentPlot:GetOwner() == playerID then
					controlledPlots = controlledPlots + 1
				end
				totalContinentPlots = totalContinentPlots + 1
			end
		end
	end

    if totalContinentPlots == 0 then
        print("No plots found for the specified continent.")
        return false
    end

    local controlledPercent = (controlledPlots / totalContinentPlots) * 100
    controlledPercent = math.floor(controlledPercent * 10 + 0.5) / 10 -- Round to one decimal place
    print("Player "..tostring(playerID).." controls " .. tostring(controlledPercent) .. " percent of the continent.")
    
    -- return controlledPercent >= percent
	return controlledPercent
end

local function GetCitiesOnForeignContinents(playerID)
    local player = Players[playerID]
    local capital = player:GetCities():GetCapitalCity()
    local capitalContinentID = capital:GetContinentType()
    local foreignCityCount = 0

    for _, city in player:GetCities():Members() do
        if city:GetContinentType() ~= capitalContinentID then
            foreignCityCount = foreignCityCount + 1
        end
    end

    print("Player " .. tostring(playerID) .. " owns " .. tostring(foreignCityCount) .. " cities on foreign continents.")
    return foreignCityCount
end

-- Helper function to check if the civilization controls all plots of a territory
local function ControlsTerritory(iPlayer :number, territoryType :string, minimumSize :number)
    print("Checking for " .. territoryType .. " territory...")
    local player = Players[iPlayer]
    local playerCities = player:GetCities()
    local territoryOwnership = false
    local territoryIDs = {}

    local function isTargetTerritoryType(plot)
        if territoryType == "SEA" then
            return plot:IsWater()
        elseif territoryType == "DESERT" then
            return plot:GetTerrainType() == GameInfo.Terrains["TERRAIN_DESERT"].Index
        elseif territoryType == "MOUNTAIN" then
            return plot:IsMountain()
        end
        -- Add more conditions for other territory types
        return false
    end

    for _, city in playerCities:Members() do
        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(iPlayer, city:GetID())
        for _, kCityUIDatas in pairs(CityUIDataList) do
            for _, kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
                local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                local iTerritory = false
                local territoryInstance = false

                if isTargetTerritoryType(plot) then
                    iTerritory = ExposedMembers.HSD_GetTerritoryID(kCoordinates.plotID)
                    if iTerritory then
                        territoryInstance = territoryCache[iTerritory]
                        if territoryInstance and (#territoryInstance.pPlots > minimumSize) and (not territoryIDs[iTerritory]) then
                            territoryIDs[iTerritory] = true
                            print("Adding territory #"..tostring(iTerritory).." to table.")
                        end
                    end
                end
            end
        end
    end

    for territoryID, _ in pairs(territoryIDs) do
        print("Territory ID is "..tostring(territoryID))
        local territoryPlots = territoryCache[territoryID].pPlots
        local ownershipCount = 0

        for _, iPlot in ipairs(territoryPlots) do
			local plot = Map.GetPlotByIndex(iPlot)
			local plotOwnerID = plot:GetOwner()
			-- print("iPlot is "..tostring(iPlot))
			-- print("plotOwnerID is "..tostring(plotOwnerID))
            if plotOwnerID == iPlayer then 
                ownershipCount = ownershipCount + 1
            end
        end

        if ownershipCount == #territoryPlots then
            print(territoryType .. " territory controlled!")
            territoryOwnership = true
        end
    end

    return territoryOwnership
end

function HasMoreTechsThanContinentMinimum(playerID, continentName)
    local player = Players[playerID]
    local playerTechs = player:GetTechs()
    local playerTechCount = playerTechs:GetNumTechsResearched()
	local continentTechMinimum = 0

    -- Find players on the specified continent
    local playersOnContinent = {}
    for _, otherPlayer in ipairs(PlayerManager.GetAlive()) do
		if otherPlayer:GetCities():GetCount() > 0 then
			for _, city in otherPlayer:GetCities():Members() do
				if city:GetContinentType() == GameInfo.Continents[continentName].Index then
					table.insert(playersOnContinent, otherPlayer)
					break -- Found a city on the continent, no need to check other cities of this player
				end
			end
		end
    end

    -- Compare tech counts
    for _, otherPlayer in ipairs(playersOnContinent) do
        if otherPlayer:GetID() ~= playerID then
            local otherPlayerTechs = otherPlayer:GetTechs()
            local otherPlayerTechCount = otherPlayerTechs:GetNumTechsResearched()
			if continentTechMinimum == 0 then
				-- Set initial tech count for continent
				continentTechMinimum = otherPlayerTechCount
			end
			if otherPlayerTechCount < continentTechMinimum then
				-- Set lowest tech count for continent
				continentTechMinimum = otherPlayerTechCount
			end
        end
    end

    return playerTechCount, continentTechMinimum
end

function IsPlayerCityHighestPopulation(playerID)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local highestPopulation = 0
	local playerHighestPopulation = 0
    
    -- Get highest population of all cities
    for _, otherPlayer in ipairs(PlayerManager.GetAlive()) do
		if playerCities:GetCount() > 0 then
			for _, city in otherPlayer:GetCities():Members() do
				highestPopulation = math.max(highestPopulation, city:GetPopulation())
			end
		end
    end

    -- Get highest population of player cities
    for _, city in playerCities:Members() do
		if city:GetPopulation() > playerHighestPopulation then
			playerHighestPopulation = city:GetPopulation()
		end
    end

    return playerHighestPopulation, highestPopulation
end

-- ===========================================================================
-- EVENT HOOKS
-- ===========================================================================
-- Set property to match player when a wonder is built
local function HSD_HistoricalVictory_WonderConstructed(iX, iY, buildingIndex, playerIndex, cityID, iPercentComplete, iUnknown)
	local buildingInfo = GameInfo.Buildings[buildingIndex]
	local wonderKey = "HSD_WONDER_" .. tostring(buildingInfo.BuildingType)
	Game:SetProperty(wonderKey, playerIndex)
end

--TODO: Add a check for victory conditions being present (based on Civ, leader, menu options)
local function HSD_HistoricalVictory_OnPillage(UnitOwner, unitID, ImprovementType, BuildingType)
	local player = Players[UnitOwner]
	if (player and player:IsBarbarian() == false) then
		local unit = player:GetUnits():FindID(unitID)
		local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		if CivilizationTypeName == "CIVILIZATION_NORWAY" then
			-- Viking Age: pillage 30 times with longship
			local unitTypeHash = unit:GetTypeHash()
			if(unitTypeHash == GameInfo.Units["UNIT_NORWEGIAN_LONGSHIP"].Index) then
				local pillageCount = player:GetProperty("HSD_VIKING_LONGSHIP_PILLAGE_COUNT") or 0 -- nil check
				pillageCount = pillageCount + 1
				player:SetProperty("HSD_VIKING_LONGSHIP_PILLAGE_COUNT", pillageCount)
				local message = Locale.Lookup("LOC_HSD_VICTORY_CIVILIZATION_NORWAY_1_FLOATER_1", pillageCount)
				Game.AddWorldViewText(0, message, unit:GetX(), unit:GetY())
			end
		end
	end
end

local function HSD_HistoricalVictory_OnUnitKilled(killedPlayerID, killedUnitID, playerID, unitID)
    local player = Players[playerID]
    if player and not player:IsBarbarian() then
        local unit = player:GetUnits():FindID(unitID)
        if unit then
            local unitTypeName = unit:GetUnitType()
            local unitKillCount = player:GetProperty("HSD_"..tostring(unitTypeName).."_KILL_COUNT") or 0
            unitKillCount = unitKillCount + 1
            player:SetProperty("HSD_"..tostring(unitTypeName).."_KILL_COUNT", unitKillCount)
            -- TODO: Display in-game popup text
        else
			print("WARNING: OnUnitKilled did not detect a unit!")
		end
    end
end

local function HSD_HistoricalVictory_TechCompleted(ePlayer, eTech)
    print("ePlayer = " .. tostring(ePlayer) .. ", eTech = " .. tostring(eTech))
    local player = Players[ePlayer]
    
    if player then
        local playerCitiesCount = player:GetCities():GetCount()
        if playerCitiesCount >= 1 then
            local techInfo = GameInfo.Technologies[eTech]
            if techInfo then
                local techKey = "HSD_" .. tostring(techInfo.TechnologyType)
                -- Check if the tech has not already been recorded
                if not Game:GetProperty(techKey) then
                    Game:SetProperty(techKey, ePlayer)
                    print("Recorded " .. techKey .. " as first completed by player " .. tostring(ePlayer))
                else
                    print("Tech " .. techKey .. " already recorded for another player.")
                end
            else
                print("Error: Tech information not found for eTech = " .. tostring(eTech))
            end
        else
            print("Player " .. tostring(ePlayer) .. " does not have any cities, ignoring tech completion.")
        end
    else
        print("Error: Player not found for ePlayer = " .. tostring(ePlayer))
    end
end

local function HSD_HistoricalVictory_CivicCompleted(ePlayer, eCivic)
    print("ePlayer = " .. tostring(ePlayer) .. ", eCivic = " .. tostring(eCivic))
    local player = Players[ePlayer]
    
    if player then
        local playerCitiesCount = player:GetCities():GetCount()
        if playerCitiesCount >= 1 then
            local civicInfo = GameInfo.Civics[eCivic]
            if civicInfo then
                local civicKey = "HSD_" .. tostring(civicInfo.CivicType)
                if not Game:GetProperty(civicKey) then
                    Game:SetProperty(civicKey, ePlayer)
                    print("Recorded " .. civicKey .. " as first completed by player " .. tostring(ePlayer))
                else
                    print("Civic " .. civicKey .. " already recorded for another player.")
                end
            else
                print("Error: Civic information not found for eCivic = " .. tostring(eCivic))
            end
        else
            print("Player " .. tostring(ePlayer) .. " does not have any cities, ignoring civic completion.")
        end
    else
        print("Error: Player not found for ePlayer = " .. tostring(ePlayer))
    end
end


-- ===========================================================================
-- PRIMARY FUNCTIONS
-- ===========================================================================

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
				local districtCount = GetDistrictTypeCount(iPlayer, "DISTRICT_CITY_CENTER")
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

-- Helper function to evaluate and track all types of objectives
function EvaluateObjectives(player, condition)
    local objectivesMet = true
    local playerID = player:GetID()

    for index, obj in ipairs(condition.objectives) do
        local objectiveMet = false
		local current = 0
		local total = 0
        local propertyKey = "HSD_HISTORICAL_VICTORY_" .. condition.index .. "_OBJECTIVE_" .. index
		local isPropertyObjective = false
		
		if obj.type == "BORDERING_CITY_COUNT" then
			current = GetBorderingCitiesCount(playerID)
			total = obj.count
		elseif obj.type == "BUILDING" then
			current = GetBuildingCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "CITY_ADJACENT_TO_RIVER_COUNT" then
			current = GetCityAdjacentToRiverCount(playerID)
			total = obj.count
		elseif obj.type == "DISTRICT" then
			current = GetDistrictTypeCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "ROAD" then
			current = GetTotalRoutePlots(playerID)
			total = obj.count
		elseif obj.type == "IMPROVEMENT" then
			current = GetImprovementCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "LAND_AREA" then
			current = GetPercentLandArea_ContinentType(playerID, obj.region, obj.percent)
			total = obj.percent
		elseif obj.type == "OCCUPIED_CAPITAL_COUNT" then
			current = GetOccupiedCapitals(playerID)
			total = obj.count
		elseif obj.type == "FOREIGN_CONTINENT_CITIES" then
			current = GetCitiesOnForeignContinents(playerID)
			total = obj.count
		elseif obj.type == "HIGHEST_CITY_POPULATION" then
			current, total = IsPlayerCityHighestPopulation(playerID)
		elseif obj.type == "MINIMUM_CONTINENT_TECH_COUNT" then
			current, total = HasMoreTechsThanContinentMinimum(playerID, obj.continent)
		elseif obj.type == "TERRITORY_CONTROL" then
			current = ControlsTerritory(playerID, obj.territory, obj.minimumSize) and 1 or 0
			total = 1
		elseif obj.type == "UNIT" then
			current = GetUnitCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "UNIT_KILL_COUNT" then
			isPropertyObjective = true
			current = player:GetProperty("HSD_"..tostring(obj.id).."_KILL_COUNT") or 0
			total = obj.count
		elseif obj.type == "WONDER_ADJACENT" then
			current = GetWonderAdjacentImprovement(playerID, obj.id, obj.adjacentImprovement) and 1 or 0
			total = 1
		elseif obj.type == "WONDER_BUILT" then
			isPropertyObjective= true
			current = Game:GetProperty("HSD_WONDER_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		end
		
		if isPropertyObjective then
			objectiveMet = current == total
		elseif obj.type == "MINIMUM_CONTINENT_TECH_COUNT" then
			objectiveMet = current > total
		elseif current >= total then
			objectiveMet = true
		end

        -- Set property for this specific objective
		player:SetProperty(propertyKey, {current = current, total = total, objectiveMet = objectiveMet})

        -- If any objective is not met, objectivesMet becomes false
        objectivesMet = objectivesMet and objectiveMet
    end

    return objectivesMet
end

-- Main function
function GetHistoricalVictoryConditions(iPlayer)
    local player = Players[iPlayer]
	if (player:GetCities():GetCount() < 1) or (player:IsBarbarian() or iPlayer == 62) then
		return
	end
    local civType = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
    local currentYear = ExposedMembers.GetCalendarTurnYear(Game.GetCurrentGameTurn())
	local gameEra = Game.GetEras():GetCurrentEra()
    
    for index, condition in ipairs(HSD_victoryConditionsConfig[civType] or {}) do
        local isTimeConditionMet = condition.year == nil or currentYear <= condition.year
		local isEraConditionMet = condition.era == nil or GameInfo.Eras[condition.era].Index == gameEra
        local victoryPropertyName = "HSD_HISTORICAL_VICTORY_" .. index
        local victoryAlreadySet = player:GetProperty(victoryPropertyName)

        if isTimeConditionMet and isEraConditionMet and not victoryAlreadySet then
            if EvaluateObjectives(player, condition) then
                -- If all objectives are met, set the main victory property
                player:SetProperty(victoryPropertyName, Game.GetCurrentGameTurn())
                -- Add to victory score
                local victoryScore = player:GetProperty("HSD_HISTORICAL_VICTORY_SCORE") or 0
                player:SetProperty("HSD_HISTORICAL_VICTORY_SCORE", victoryScore + condition.score)
            end
        end
    end
end

-- ===========================================================================
-- INITIALIZATION
-- ===========================================================================

function HSD_InitVictoryMode()
	print("Initializing HistoricalVictory_Scripts.lua")
	territoryCache = ExposedMembers.HSD_GetTerritoryCache()
	Events.CivicCompleted.Add(HSD_HistoricalVictory_CivicCompleted)
	Events.ResearchCompleted.Add(HSD_HistoricalVictory_TechCompleted)
	Events.WonderCompleted.Add(HSD_HistoricalVictory_WonderConstructed)
	Events.UnitKilledInCombat.Add(HSD_HistoricalVictory_OnUnitKilled)
	GameEvents.OnPillage.Add(HSD_HistoricalVictory_OnPillage)
	GameEvents.PlayerTurnStarted.Add(GetHistoricalVictoryConditions)
end

Events.LoadScreenClose.Add(HSD_InitVictoryMode)