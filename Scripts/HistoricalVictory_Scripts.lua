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
ExposedMembers.GetEraCountdown = {}
ExposedMembers.CheckCityOriginalCapital = {}
ExposedMembers.HSD_GetTerritoryCache = {}
ExposedMembers.HSD_GetTerritoryID = {}
ExposedMembers.HSD_GetTotalIncomingRoutes = {}

-- ===========================================================================
-- Variables
-- ===========================================================================

local iVictoryScoreToWin = 3
local territoryCache = {} -- Used to track territories detected from UI context
local iFreeCitiesPlayerID = PlayerManager.GetFreeCitiesPlayerID()
local bCivilizationVictory = MapConfiguration.GetValue("CivilizationVictoryOnly")

-- ===========================================================================
-- Cache Functions
-- ===========================================================================
local function GetVictoryPlayerType(playerID)
    local CivilizationTypeName = PlayerConfigurations[playerID]:GetCivilizationTypeName()
    local LeaderTypeName = PlayerConfigurations[playerID]:GetLeaderTypeName()
    local playerTypeName = LeaderTypeName
    if bCivilizationVictory or not HSD_victoryConditionsConfig[playerTypeName] then
        -- Use the civ victory if the leader victory is not defined, or if civilization victory mode is enabled
        playerTypeName = CivilizationTypeName
        print("Leader not detected in historical victory table. Using civilization value.")
    end
    if not HSD_victoryConditionsConfig[playerTypeName] then
        playerTypeName = "GENERIC_CIVILIZATION"
    end
    print("GetVictoryPlayerType returned "..tostring(playerTypeName))
    return playerTypeName
end

local function CacheVictoryConditions()
    local allPlayerIDs = PlayerManager.GetAliveIDs()
    local playerVictoryConditions = {} -- Table to hold each player's victory conditions

    for _, playerID in ipairs(allPlayerIDs) do
        local playerTypeName = GetVictoryPlayerType(playerID)
        local conditionsForPlayer = HSD_victoryConditionsConfig[playerTypeName] or {}

        playerVictoryConditions[playerID] = {}

        for i, condition in ipairs(conditionsForPlayer) do
            -- Copy each condition to the player's specific condition list
            playerVictoryConditions[playerID][i] = {
                playerTypeName = playerTypeName,
                id = condition.id,
                index = condition.index,
                year = condition.year or nil,
                era = condition.era or nil,
                eraLimit = condition.eraLimit or nil,
                objectives = condition.objectives,
                score = condition.score
            }
        end
    end

    -- Store the cached conditions for later use
    Game:SetProperty("HSD_PlayerVictoryConditions", playerVictoryConditions)
end

-- ===========================================================================
-- Helper functions
-- ===========================================================================

function ConvertYearToAnnoDomini(currentTurnYear)
	local calendarDateBC = false
	local calendarTurnString = "nil"
	if (currentTurnYear < 0) then
		-- print("Converting negative year number to calendar date")
		calendarDateBC = currentTurnYear*(-1)
		if calendarDateBC then
			calendarTurnString = tostring(calendarDateBC).."BC"
			-- print("Current turn year is "..tostring(currentTurnYear)..". Converted to calendar year is "..tostring(calendarDateBC))
		else
			calendarTurnString = tostring(currentTurnYear)
		end
	else
		calendarTurnString = tostring(currentTurnYear).."AD"
	end
	return calendarTurnString
end

local function DoesPlayerHaveVictoryCondition(playerID, conditionID)
    local playerVictoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
    local conditionsForPlayer = playerVictoryConditions[playerID] or {}

    for _, condition in ipairs(conditionsForPlayer) do
        if condition.id == conditionID then
            return true
        end
    end
    return false
end

local function IsFreeCityPlayer(playerID)
    if playerID and (playerID == iFreeCitiesPlayerID) then
        return true
    end 
    return false
 end

local function IsHistoricalVictoryPlayer(playerID)
    local player = Players[playerID]
    if player and (player:IsMajor()) and (not player:IsBarbarian()) and not IsFreeCityPlayer(playerID) then
        return true
    end
    return false
end

local function IsCityState(playerID)
    local player = Players[playerID]
    if player and (not player:IsMajor()) and (not player:IsBarbarian()) and not IsFreeCityPlayer(playerID) then
        return true
    end
    return false
end

local function HasPlayerSpawned(playerID)
    local player = Players[playerID]
    if player then
        local numPlayerCities = player:GetCities():GetCount()
        if (numPlayerCities >= 1) then
            return true
        end
    end
    return false
end

-- ===========================================================================
-- Victory Conditions
-- ===========================================================================

local function AreTwoWondersInSameCity(playerID, firstWonderID, secondWonderID)
    local player = Players[playerID]
    local playerCities = player:GetCities()

    if not GameInfo.Buildings[firstWonderID] or not GameInfo.Buildings[secondWonderID] then
        return false
    end

    for _, city in playerCities:Members() do
        local cityBuildings = city:GetBuildings()

        local hasFirstWonder = cityBuildings:HasBuilding(GameInfo.Buildings[firstWonderID].Index)
        local hasSecondWonder = cityBuildings:HasBuilding(GameInfo.Buildings[secondWonderID].Index)

        if hasFirstWonder and hasSecondWonder then
            return true
        end
    end

    return false
end

local function GetNumCitiesWithPopulation(playerID, requiredCityNum, requiredPopulation)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local citiesMeetingCriteria = 0

    for _, city in playerCities:Members() do
        if city:GetPopulation() >= requiredPopulation then
            citiesMeetingCriteria = citiesMeetingCriteria + 1
        end
    end

    return citiesMeetingCriteria
end


local function GetCitiesWithFeatureCount(playerID, featureType)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local featureCount = 0

    if not GameInfo.Features[featureType] then
        print("Feature type " .. tostring(featureType) .. " not found in GameInfo.")
        return featureCount
    end

    local featureIndex = GameInfo.Features[featureType].Index

    for _, city in playerCities:Members() do
        local hasFeature = false

        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(playerID, city:GetID())
		for _,kCityUIDatas in pairs(CityUIDataList) do
			for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
				local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                if plot:GetFeatureType() == featureIndex then
                    hasFeature = true
                    break -- Break the inner loop as we found the feature in this city
                end
			end
		end

        if hasFeature then
            featureCount = featureCount + 1
        end
    end

    return featureCount
end

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
        local CivilizationTypeName = PlayerConfigurations[otherPlayerID]:GetCivilizationTypeName()
        if IsCityState(otherPlayerID) then
            local suzerainID = otherPlayer:GetInfluence():GetSuzerain()
			if suzerainID then
				print("suzerainID for "..tostring(CivilizationTypeName).." is "..tostring(suzerainID))
				if suzerainID == playerID then
					suzerainCount = suzerainCount + 1
					print("Suzerainty detected. suzerainCount is "..tostring(suzerainCount))
				end
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
    local riverAdjacentCityCount = 0

    if not player then
        print("Invalid player ID: " .. tostring(playerID))
        return riverAdjacentCityCount
    end

    local playerCities = player:GetCities()

    for _, city in playerCities:Members() do
        local cityX, cityY = city:GetX(), city:GetY()
        local cityPlot = Map.GetPlot(cityX, cityY)

        if cityPlot:IsRiver() or cityPlot:IsRiverAdjacent() then
            riverAdjacentCityCount = riverAdjacentCityCount + 1
        else
            -- Check adjacent plots if the city center is not directly on a river
            -- for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
            --     local adjacentPlot = Map.GetAdjacentPlot(cityX, cityY, direction)
            --     if adjacentPlot and adjacentPlot:IsRiver() then
            --         riverAdjacentCityCount = riverAdjacentCityCount + 1
            --         break -- Found a river adjacent plot, no need to check further
            --     end
            -- end
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
	-- print("Checking for total number of "..tostring(improvementType).." owned by player "..tostring(iPlayer))
	local player = Players[iPlayer]
	local playerCities = player:GetCities()
	local improvementCount = 0
	
    if not GameInfo.Improvements[improvementType] then
        print("Improvement type " .. tostring(improvementType) .. " not found in GameInfo.")
        return improvementCount
    end

    local improvementIndex = GameInfo.Improvements[improvementType].Index
	
	for _, city in playerCities:Members() do
		local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(iPlayer, city:GetID())
		for _,kCityUIDatas in pairs(CityUIDataList) do
			for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
				local plot = Map.GetPlotByIndex(kCoordinates.plotID)
				if plot and plot:GetImprovementType() == improvementIndex then
					improvementCount = improvementCount + 1
					-- print("Improvement detected. Total count is "..tostring(improvementCount))
				end
			end
		end
	end
	
	return improvementCount
end

local function GetTotalRoutePlots(iPlayer)
	-- print("Checking for total number of route plots owned by player "..tostring(iPlayer))
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
					-- print("plot isRoute detected. Total count is "..tostring(routeCount))
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

local function GetFullyUpgradedUnitsCount(playerID, unitType, requiredCount)
    local player = Players[playerID]
    local playerUnits = player:GetUnits()
    local count = 0

    for i, unit in playerUnits:Members() do
        if unit:GetType() == unitType and unit:GetExperience():GetLevel() == unit:GetExperience():GetMaxLevel() then
            count = count + 1
        end
    end

    return count
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

-- Helper function to check if the civilization controls the required percentage of land area on their home continent
local function GetPercentLandArea_HomeContinent(playerID, percent)
    local player = Players[playerID]
    local capital = player:GetCities():GetCapitalCity()

    if capital == nil then
        print("Player " .. tostring(playerID) .. " does not have a capital city.")
        return false
    end

    local capitalContinentID = capital:GetPlot():GetContinentType()
    local totalContinentPlots = 0
    local controlledPlots = 0

    local continentPlotIndexes = Map.GetContinentPlots(capitalContinentID)
    for _, plotID in ipairs(continentPlotIndexes) do
        local continentPlot = Map.GetPlotByIndex(plotID)
        if continentPlot:IsOwned() and continentPlot:GetOwner() == playerID then
            controlledPlots = controlledPlots + 1
        end
        totalContinentPlots = totalContinentPlots + 1
    end

    if totalContinentPlots == 0 then
        print("No plots found on the home continent for player " .. tostring(playerID))
        return false
    end

    local controlledPercent = (controlledPlots / totalContinentPlots) * 100
    controlledPercent = math.floor(controlledPercent * 10 + 0.5) / 10 -- Round to one decimal place
    print("Player " .. tostring(playerID) .. " controls " .. tostring(controlledPercent) .. "% of their home continent.")

    -- return controlledPercent >= percent
	return controlledPercent
end

local function GetCitiesOnForeignContinents(playerID)
    local player = Players[playerID]
    local capital = player:GetCities():GetCapitalCity()
    local iX, iY = capital:GetX(), capital:GetY()
    local capitalContinentID = Map.GetPlot(iX, iY):GetContinentType()
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
local function ControlsTerritory(iPlayer, territoryType, minimumSize)
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

local function GetOutgoingRoutesCount(playerID)
    local highestTradeRouteCount = 0

    -- Count outgoing trade routes for the player
    local playerOutgoingRoutes = Players[playerID]:GetTrade():CountOutgoingRoutes()
    print("playerOutgoingRoutes = "..tostring(playerOutgoingRoutes))

    -- Get highest outgoing route count among all other players
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        if otherPlayerID ~= playerID then
            if IsHistoricalVictoryPlayer(otherPlayerID) and HasPlayerSpawned(otherPlayerID) then
                local otherPlayerOutgoingRoutes = Players[otherPlayerID]:GetTrade():CountOutgoingRoutes()
                if otherPlayerOutgoingRoutes > highestTradeRouteCount then
                    highestTradeRouteCount = otherPlayerOutgoingRoutes
                end
            end

        end
    end

    return playerOutgoingRoutes, highestTradeRouteCount
end

local function GetTradeRoutesCount(playerID)
    local highestTradeRouteCount = 0

    -- Count total number of routes for the player
    local playerOutgoingRoutes = Players[playerID]:GetTrade():CountOutgoingRoutes()
    print("playerOutgoingRoutes = "..tostring(playerOutgoingRoutes))
    local playerIncomingRoutes = ExposedMembers.HSD_GetTotalIncomingRoutes(playerID)
    print("playerIncomingRoutes = "..tostring(playerIncomingRoutes))
    local playerTradeRoutes = playerOutgoingRoutes + playerIncomingRoutes

    -- Get highest route count among all other players
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        if otherPlayerID ~= playerID then
            if IsHistoricalVictoryPlayer(otherPlayerID) and HasPlayerSpawned(otherPlayerID) then
                local otherPlayerOutgoingRoutes = Players[otherPlayerID]:GetTrade():CountOutgoingRoutes()
                local otherplayerIncomingRoutes = ExposedMembers.HSD_GetTotalIncomingRoutes(otherPlayerID)
                local otherPlayerTradeRoutes = otherPlayerOutgoingRoutes + otherplayerIncomingRoutes
                if otherPlayerTradeRoutes > highestTradeRouteCount then
                    highestTradeRouteCount = otherPlayerTradeRoutes
                end
            end

        end
    end

    return playerTradeRoutes, highestTradeRouteCount
end

local function HasUnlockedAllCivicsForEra(playerID, eraType)
    local player = Players[playerID]
    local playerCulture = player:GetCulture()

    -- Loop through all civics and check if each civic in the specified era is unlocked
    for civic in GameInfo.Civics() do
        if civic.EraType == eraType then
            if not playerCulture:HasCivic(civic.Index) then
                -- If even one civic in the era is not unlocked, return false
                return false
            end
        end
    end

    -- All civics in the era are unlocked
    return true
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

local function HSD_OnBuildingConstructed(playerID, cityID, buildingID, plotID, bOriginalConstruction)
    local buildingInfo = GameInfo.Buildings[buildingID]
    local buildingKey = "HSD_" .. tostring(buildingInfo.BuildingType)
    if not Game:GetProperty(buildingKey) then
        Game:SetProperty(buildingKey, playerID)
        print("Recorded " .. buildingInfo.BuildingType .. " as first completed by player " .. tostring(playerID))

        -- Check if the building completion is part of any active victory conditions
        local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
        local conditionsForPlayer = victoryConditions[playerID] or {}
        for _, victoryCondition in ipairs(conditionsForPlayer) do
            for _, objective in ipairs(victoryCondition.objectives) do
                if (objective.type == "FIRST_BUILDING_CONSTRUCTED") and (objective.id == buildingInfo.BuildingType) then
                    local iX, iY = Map.GetPlotByIndex(plotID):GetX(), Map.GetPlotByIndex(plotID):GetY()
                    -- Display in-game popup text
                    local message = Locale.Lookup("LOC_HSD_BUILDING_CONSTRUCTED_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(buildingInfo.Name))
                    Game.AddWorldViewText(0, message, iX, iY)
                    break
                end
            end
        end
    end
end

-- function HSD_OnCityConquered(capturerID,  ownerID, cityID , cityX, cityY)
--     print("HSD_OnCityConquered detected")
--     local player = Players[capturerID]
--     local bIsValid = false
--     local plot = Map.GetPlot(cityX, cityY)
    
--     local function GetPlotUnitsAndSetProperty(unitPlot)
--         if unitPlot and (unitPlot:GetUnitCount() > 0) then
--             for _, unit in ipairs(Units.GetUnitsInPlot(unitPlot)) do
--                 if(unit ~= nil) then
--                     if unit:GetOwner() == capturerID then
--                         local unitTypeName = GameInfo.Units[unit:GetType()].UnitType
--                         local unitKey = "HSD_"..tostring(unitTypeName).."_CONQUER_COUNT"
--                         local conquerCount = player:GetProperty(unitKey) or 0
--                         conquerCount = conquerCount + 1
--                         player:SetProperty(unitKey, conquerCount)
--                         bIsValid = true
--                     end
--                 end
--             end
--         end
--     end

--     local unitsOnPlot = GetPlotUnitsAndSetProperty(plot)
    
--     if(bIsValid == false) then
--         -- Check adjacent plots
--         for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
--             local adjacentPlot = Map.GetAdjacentPlot(cityX, cityY, direction);
--             if (adjacentPlot ~= nil and bIsValid ~= true) then
--                 local unitsOnAdjacentPlot = GetPlotUnitsAndSetProperty(adjacentPlot)
--             end
--         end
--     end
-- end

local function HSD_OnCityConquered(capturerID, ownerID, cityID, cityX, cityY)
    print("HSD_OnCityConquered detected")
    local player = Players[capturerID]
    local countedUnitTypes = {}

    local function IsMilitaryUnit(unit)
        local unitType = unit:GetType()
        local unitInfo = GameInfo.Units[unitType]
        return (unitInfo.FormationClass == "FORMATION_CLASS_LAND_COMBAT") or (unitInfo.FormationClass == "FORMATION_CLASS_NAVAL")
    end

    local function ProcessUnit(unit)
        if unit and unit:GetOwner() == capturerID and IsMilitaryUnit(unit) then
            local unitTypeName = GameInfo.Units[unit:GetType()].UnitType
            if not countedUnitTypes[unitTypeName] then
                local unitKey = "HSD_"..tostring(unitTypeName).."_CONQUER_COUNT"
                local conquerCount = player:GetProperty(unitKey) or 0
                conquerCount = conquerCount + 1
                player:SetProperty(unitKey, conquerCount)
                countedUnitTypes[unitTypeName] = true
            end
        end
    end

    local function GetPlotUnits(unitPlot)
        if unitPlot and unitPlot:GetUnitCount() > 0 then
            for _, unit in ipairs(Units.GetUnitsInPlot(unitPlot)) do
                ProcessUnit(unit)
            end
        end
    end

    GetPlotUnits(Map.GetPlot(cityX, cityY)) -- Process units on the city plot

    -- Check adjacent plots
    for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
        local adjacentPlot = Map.GetAdjacentPlot(cityX, cityY, direction)
        if adjacentPlot then
            GetPlotUnits(adjacentPlot)
        end
    end
end


local function HSD_OnWonderConstructed(iX, iY, buildingIndex, playerIndex, cityID, iPercentComplete, iUnknown)
    if iPercentComplete == 100 then  -- Ensure the wonder is fully constructed
        local buildingInfo = GameInfo.Buildings[buildingIndex]

        if buildingInfo and buildingInfo.IsWonder then  -- Check if it's a wonder
            local wonderKey = "HSD_WONDER_" .. tostring(buildingInfo.BuildingType)

            -- Only record the first player to complete this wonder
            if not Game:GetProperty(wonderKey) then
                Game:SetProperty(wonderKey, playerIndex)
                print("Recorded " .. buildingInfo.BuildingType .. " as first completed by player " .. tostring(playerIndex))

                -- Check if the wonder completion is part of any active victory condition
                local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
                local conditionsForPlayer = victoryConditions[playerIndex] or {}
                for _, victoryCondition in ipairs(conditionsForPlayer) do
                    for _, objective in ipairs(victoryCondition.objectives) do
                        if (objective.type == "WONDER_BUILT") and (objective.id == buildingInfo.BuildingType) then
                            -- Display in-game popup text
                            local message = Locale.Lookup("LOC_HSD_WONDER_CONSTRUCTED_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(buildingInfo.Name))
                            Game.AddWorldViewText(0, message, iX, iY)
                            break
                        end
                    end
                end
            else
                print(buildingInfo.BuildingType .. " has already been completed by another player.")
            end
        else
            print("Error: Building index does not correspond to a wonder.")
        end
    end
end

local function HSD_OnGreatPersonActivated(UnitOwner, unitID, GreatPersonType, GreatPersonClass)
    local greatPersonClassInfo = GameInfo.GreatPersonClasses[GreatPersonClass]

    if greatPersonClassInfo then
        local greatPersonKey = "HSD_" .. tostring(greatPersonClassInfo.GreatPersonClassType)

        -- Only record first person to activate great person of this type
        if not Game:GetProperty(greatPersonKey) then
            Game:SetProperty(greatPersonKey, UnitOwner)
            print("Recorded first activation of great person class " .. greatPersonClassInfo.GreatPersonClassType .. " by player " .. tostring(UnitOwner))
        else
            -- print(greatPersonClassInfo.GreatPersonClassType .. " has already been activated by another player.")
        end
    else
        print("Error: GreatPersonClass not found for " .. tostring(GreatPersonClass))
    end
end

local function HSD_OnPillage(UnitOwner, unitID, ImprovementType, BuildingType)
    -- print("HSD_OnPillage detected...")
    -- print("Pillaging player is #"..tostring(UnitOwner))
    local player = Players[UnitOwner]
    if player and IsHistoricalVictoryPlayer(UnitOwner) then
        -- print("Player is a historical victory player")
        local unit = player:GetUnits():FindID(unitID)
        if unit then
            -- Set pillage count for unitType as player property
            local unitTypeName = GameInfo.Units[unit:GetType()].UnitType
            -- print("unitTypeName is "..tostring(unitTypeName))
            local unitPillageCount = player:GetProperty("HSD_"..tostring(unitTypeName).."_PILLAGE_COUNT") or 0
            unitPillageCount = unitPillageCount + 1
            player:SetProperty("HSD_"..tostring(unitTypeName).."_PILLAGE_COUNT", unitPillageCount)

            -- Display a popup in-game if the victory condition is active
            local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
            local conditionsForPlayer = victoryConditions[UnitOwner] or {}
            if conditionsForPlayer then
                for _, victoryCondition in ipairs(conditionsForPlayer) do
                    for _, objective in ipairs(victoryCondition.objectives) do
                        if (objective.type == "UNIT_PILLAGE_COUNT") and (objective.id == unitTypeName) then
                            -- Display in-game popup text
                            local message = Locale.Lookup("LOC_HSD_PILLAGE_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(GameInfo.Units[unitTypeName].Name), unitPillageCount, objective.count)
                            Game.AddWorldViewText(0, message, unit:GetX(), unit:GetY())
                            break
                        end
                    end
                end
            end
        else
            print("WARNING: OnPillage did not detect a unit!")
        end
    end
end

local function HSD_OnUnitKilled(killedPlayerID, killedUnitID, playerID, unitID)
    -- print("HSD_OnUnitKilled detected...")
    -- print("Killing player is #"..tostring(playerID))
    local player = Players[playerID]
    if player and IsHistoricalVictoryPlayer(playerID) then
        -- print("Player is a historical victory player")
        -- local unit = player:GetUnits():FindID(unitID)
        local unit = UnitManager.GetUnit(playerID, unitID)
        if unit then
            -- Set kill count for unitType as player property
            local unitTypeName = GameInfo.Units[unit:GetType()].UnitType
            -- print("unitTypeName is "..tostring(unitTypeName))
            local unitKillCount = player:GetProperty("HSD_"..tostring(unitTypeName).."_KILL_COUNT") or 0
            unitKillCount = unitKillCount + 1
            player:SetProperty("HSD_"..tostring(unitTypeName).."_KILL_COUNT", unitKillCount)

            -- Display a popup in-game if the victory condition is active
            local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
            local conditionsForPlayer = victoryConditions[playerID] or {}
            for _, victoryCondition in ipairs(conditionsForPlayer) do
                for _, objective in ipairs(victoryCondition.objectives) do
                    if (objective.type == "UNIT_KILL_COUNT") and (objective.id == unitTypeName) then
                        -- Display in-game popup text
                        local message = Locale.Lookup("LOC_HSD_KILL_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(GameInfo.Units[unitTypeName].Name), unitKillCount, objective.count)
                        Game.AddWorldViewText(0, message, unit:GetX(), unit:GetY())
                        break
                    end
                end
            end
        else
            print("WARNING: OnUnitKilled did not detect a unit!")
        end
    end
end


local function HSD_OnTechCompleted(ePlayer, eTech)
    -- print("ePlayer = " .. tostring(ePlayer) .. ", eTech = " .. tostring(eTech))
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
                    -- print("Tech " .. techKey .. " already recorded for another player.")
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

local function HSD_OnCivicCompleted(ePlayer, eCivic)
    -- print("ePlayer = " .. tostring(ePlayer) .. ", eCivic = " .. tostring(eCivic))
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
                    -- print("Civic " .. civicKey .. " already recorded for another player.")
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

-- Helper function to evaluate and track all types of objectives
function EvaluateObjectives(player, condition)
    local objectivesMet = true
    local playerID = player:GetID()

    for index, obj in ipairs(condition.objectives) do
        local objectiveMet = false
		local current = 0
		local total = 0
        local propertyKey = "HSD_HISTORICAL_VICTORY_" .. condition.index .. "_OBJECTIVE_" .. index
		local isPlayerProperty = false
        local isEqual = false
        local isGreaterThan = false
        local isLesserThan = false
		
		if obj.type == "2_WONDERS_IN_CITY" then
			current = AreTwoWondersInSameCity(playerID, obj.firstID, obj.secondID) and 1 or 0
			total = 1
        elseif obj.type == "BORDERING_CITY_COUNT" then
			current = GetBorderingCitiesCount(playerID)
			total = obj.count
		elseif obj.type == "BUILDING_COUNT" then
			current = GetBuildingCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "CITY_ADJACENT_TO_RIVER_COUNT" then
			current = GetCityAdjacentToRiverCount(playerID)
			total = obj.count
		elseif obj.type == "CITY_WITH_FEATURE_COUNT" then
			current = GetCitiesWithFeatureCount(playerID, obj.id) or 0
			total = obj.count
		elseif obj.type == "DISTRICT_COUNT" then
			current = GetDistrictTypeCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "FIRST_BUILDING_CONSTRUCTED" then
			isPlayerProperty = true
			current = player:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_CIVIC_RESEARCHED" then
			isPlayerProperty = true
			current = player:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_GREAT_PERSON_CLASS" then
			isPlayerProperty = true
			current = player:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_TECH_RESEARCHED" then
			isPlayerProperty = true
			current = player:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FOREIGN_CONTINENT_CITIES" then
			current = GetCitiesOnForeignContinents(playerID)
			total = obj.count
		elseif obj.type == "FULLY_UPGRADE_UNIT_COUNT" then
			current = GetFullyUpgradedUnitsCount(playerID, obj.id, obj.count)
			total = obj.count
		elseif obj.type == "HIGHEST_CITY_POPULATION" then
			current, total = IsPlayerCityHighestPopulation(playerID)
		elseif obj.type == "IMPROVEMENT_COUNT" then
			current = GetImprovementCount(playerID, obj.id) or -1
			total = obj.count
		elseif obj.type == "LAND_AREA_HOME_CONTINENT" then
			current = GetPercentLandArea_HomeContinent(playerID, obj.percent) or -1
			total = obj.percent
		elseif obj.type == "MINIMUM_CONTINENT_TECH_COUNT" then
            isGreaterThan = true
			current, total = HasMoreTechsThanContinentMinimum(playerID, obj.continent)
		elseif obj.type == "MOST_ACTIVE_TRADEROUTES_ALL" then
            isGreaterThan = true
			current, total = GetTradeRoutesCount(playerID)
		elseif obj.type == "MOST_OUTGOING_TRADE_ROUTES" then
            isGreaterThan = true
			current, total = GetOutgoingRoutesCount(playerID)
		elseif obj.type == "NUM_CITIES_POP_SIZE" then
			current = GetNumCitiesWithPopulation(playerID, obj.cityNum, obj.popNum)
			total = obj.cityNum
		elseif obj.type == "OCCUPIED_CAPITAL_COUNT" then
			current = GetOccupiedCapitals(playerID)
			total = obj.count
		elseif obj.type == "ROUTE_COUNT" then
			current = GetTotalRoutePlots(playerID)
			total = obj.count
		elseif obj.type == "SUZERAINTY_COUNT" then
			current = GetSuzeraintyCount(playerID)
			total = obj.count
		elseif obj.type == "TERRITORY_CONTROL" then
			current = ControlsTerritory(playerID, obj.territory, obj.minimumSize) and 1 or 0
			total = 1
		elseif obj.type == "UNIT_CONQUER_CITY_COUNT" then
			current = player:GetProperty("HSD_"..tostring(obj.id).."_CONQUER_COUNT") or 0
			total = obj.count
		elseif obj.type == "UNIT_COUNT" then
			current = GetUnitCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "UNIT_KILL_COUNT" then
			current = player:GetProperty("HSD_"..tostring(obj.id).."_KILL_COUNT") or 0
			total = obj.count
		elseif obj.type == "UNIT_PILLAGE_COUNT" then
			current = player:GetProperty("HSD_"..tostring(obj.id).."_PILLAGE_COUNT") or 0
			total = obj.count
		elseif obj.type == "UNLOCK_ALL_ERA_CIVICS" then
			current = HasUnlockedAllCivicsForEra(playerID, obj.id) and 1 or 0
			total = 1
		elseif obj.type == "WONDER_ADJACENT_IMPROVEMENT" then
			current = GetWonderAdjacentImprovement(playerID, obj.wonder, obj.improvement) and 1 or 0
			total = 1
		elseif obj.type == "WONDER_BUILT" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_WONDER_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		end
		
		if isPlayerProperty or isEqual then
			objectiveMet = current == total
		elseif isGreaterThan then
			objectiveMet = current > total
		elseif isLesserThan then
			objectiveMet = current < total
		else
			objectiveMet = current >= total
		end

        -- Set property for this specific objective
		player:SetProperty(propertyKey, {current = current, total = total, objectiveMet = objectiveMet})

        -- If any objective is not met, objectivesMet becomes false
        objectivesMet = objectivesMet and objectiveMet
    end

    return objectivesMet
end

-- Main function that calls the victory condition checker and sets victory and score properties 
function GetHistoricalVictoryConditions(iPlayer)
    local player = Players[iPlayer]
	if not IsHistoricalVictoryPlayer(iPlayer) or not HasPlayerSpawned(iPlayer) then
		return
	end
    local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
    local victoryConditionsCache = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
    local conditionsForPlayer = victoryConditionsCache[iPlayer] or {}

    local currentYear = ExposedMembers.GetCalendarTurnYear(Game.GetCurrentGameTurn())
    local annoDominiYear = ConvertYearToAnnoDomini(currentYear)
	local gameEra = Game.GetEras():GetCurrentEra()

    for index, condition in ipairs(conditionsForPlayer or {}) do
        local isTimeConditionMet = condition.year == nil or (currentYear <= condition.year)
		local isEraConditionMet = condition.era == nil or (GameInfo.Eras[condition.era].Index == gameEra)
        local isEraLimitMet = condition.eraLimit == nil or ((condition.eraLimit == "END_ERA") and (ExposedMembers.GetEraCountdown() > 0))
        local victoryPropertyName = "HSD_HISTORICAL_VICTORY_" .. index
        local victoryAlreadySet = player:GetProperty(victoryPropertyName)

        if isTimeConditionMet and isEraConditionMet and isEraLimitMet and not victoryAlreadySet then
            if EvaluateObjectives(player, condition) then
                -- If all objectives are met, set the main victory property
                player:SetProperty(victoryPropertyName, Game.GetCurrentGameTurn())
                -- Add to victory score
                local victoryScore = player:GetProperty("HSD_HISTORICAL_VICTORY_SCORE") or 0
                player:SetProperty("HSD_HISTORICAL_VICTORY_SCORE", victoryScore + condition.score)
                -- Generate popup
                local eventKey = GameInfo.EventPopupData["HSD_HISTORICAL_VICTORY_POPUP"].Type
                local eventEffectString = Locale.Lookup("LOC_HSD_EVENT_HISTORICAL_VICTORY_MESSAGE", Locale.Lookup("LOC_HSD_VICTORY_"..tostring(condition.playerTypeName).."_"..tostring(condition.index).."_NAME"), tostring(annoDominiYear), Locale.Lookup(GameInfo.Leaders[LeaderTypeName].Name))
                -- Show popup to all human players
                local allPlayerIDs = PlayerManager.GetAliveIDs()
                for _, playerID in ipairs(allPlayerIDs) do
                    local otherPlayer = Players[playerID]
                    if otherPlayer:IsHuman() then
                        ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = playerID, EventKey = eventKey, EventEffect = eventEffectString })
                    end
                end
                -- Show popup to local player
                -- ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = iPlayer, EventKey = eventKey, EventEffect = eventEffectString })
            end
        end
        if not victoryAlreadySet and ((not isTimeConditionMet) or ((not isEraConditionMet) and (GameInfo.Eras[condition.era].Index < gameEra))) then
            -- Objectives failed
            player:SetProperty(victoryPropertyName, -1)
        end
    end

    -- Create victory building if score threshold is reached
    local victoryPropertyName = "HSD_HISTORICAL_VICTORY_PROJECT_GRANTED"
    local victoryAlreadySet = player:GetProperty(victoryPropertyName)
    local totalVictoryScore = player:GetProperty("HSD_HISTORICAL_VICTORY_SCORE")
    if not victoryAlreadySet and totalVictoryScore and totalVictoryScore >= iVictoryScoreToWin then
		local victoryProjectBuilding = "BUILDING_HISTORICAL_VICTORY"
		if GameInfo.Buildings[victoryProjectBuilding] then
            local capital = player:GetCities():GetCapitalCity()
			local cityBuildQueue = capital:GetBuildQueue()
            if not capital:GetBuildings():HasBuilding(victoryProjectBuilding) then
                -- Create dummy building to apply effect
                cityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[victoryProjectBuilding].Index, 100)
                -- Set property
                player:SetProperty(victoryPropertyName, true)
                -- Show popup
                local eventKey = GameInfo.EventPopupData["HSD_HISTORICAL_VICTORY_UNLOCKED_POPUP"].Type
                local eventEffectString = Locale.Lookup("LOC_HSD_EVENT_HISTORICAL_VICTORY_UNLOCKED_MESSAGE", Locale.Lookup(GameInfo.Leaders[LeaderTypeName].Name))
                ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = iPlayer, EventKey = eventKey, EventEffect = eventEffectString })
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
    CacheVictoryConditions() -- Sets game property containing victory data as table
	Events.CivicCompleted.Add(HSD_OnCivicCompleted)
	Events.ResearchCompleted.Add(HSD_OnTechCompleted)
	Events.WonderCompleted.Add(HSD_OnWonderConstructed)
	Events.UnitKilledInCombat.Add(HSD_OnUnitKilled)
    GameEvents.BuildingConstructed.Add(HSD_OnBuildingConstructed)
    GameEvents.CityConquered.Add(HSD_OnCityConquered)
	GameEvents.OnGreatPersonActivated.Add(HSD_OnGreatPersonActivated)
	GameEvents.OnPillage.Add(HSD_OnPillage)
	GameEvents.PlayerTurnStarted.Add(GetHistoricalVictoryConditions)
end

Events.LoadScreenClose.Add(HSD_InitVictoryMode)