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
ExposedMembers.HSD_GetRiverPlots = {}
ExposedMembers.HSD_GetCultureCounts = {}
ExposedMembers.HSD_GetNumTechsResearched = {}
ExposedMembers.HSD_GetHolyCitiesCount = {}

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
                yearLimit = condition.yearLimit or nil,
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

local function CacheLuxuryResourcePlots()
    local luxuryResources = {}
    
    -- Iterate through all resources to initialize the luxuryResources table
    for resource in GameInfo.Resources() do
        if resource.ResourceClassType == "RESOURCECLASS_LUXURY" then
            luxuryResources[resource.ResourceType] = {}
        end
    end

    -- Iterate through all plots and store the indexes of luxury resource plots
    for plotIndex = 0, Map.GetPlotCount() - 1 do
        local plot = Map.GetPlotByIndex(plotIndex)
        local resourceType = plot:GetResourceType()

        if resourceType ~= -1 then -- Check if there is a resource on the plot
            local resourceInfo = GameInfo.Resources[resourceType]
            if resourceInfo and resourceInfo.ResourceClassType == "RESOURCECLASS_LUXURY" then
                table.insert(luxuryResources[resourceInfo.ResourceType], plotIndex)
            end
        end
    end

    -- Store the table in a game property for later access
    Game:SetProperty("HSD_LuxuryResourcePlotIndexes", luxuryResources)
end

local function CacheAllResourcePlots()
    local allResources = {}
    
    -- Initialize the allResources table for every resource type
    for resource in GameInfo.Resources() do
        allResources[resource.ResourceType] = {}
    end

    -- Iterate through all plots and store the indexes of resource plots
    for plotIndex = 0, Map.GetPlotCount() - 1 do
        local plot = Map.GetPlotByIndex(plotIndex)
        local resourceType = plot:GetResourceType()

        if resourceType ~= -1 then -- Check if there is a resource on the plot
            local resourceInfo = GameInfo.Resources[resourceType]
            if resourceInfo then
                table.insert(allResources[resourceInfo.ResourceType], plotIndex)
            end
        end
    end

    -- Store the table in a game property for later access
    Game:SetProperty("HSD_ResourceData", allResources)
end

-- ===========================================================================
-- Helper functions
-- ===========================================================================

-- Helper function to check if a table contains a certain element
local function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

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

local function CountCitiesInRange(centerX, centerY, range, playerID)
    local count = 0

    -- Iterate through each tile in the range
    for dx = -range, range do
        for dy = -range, range do
            local x = centerX + dx
            local y = centerY + dy

            if Map.IsPlot(x, y) then
                local plot = Map.GetPlot(x, y)

                -- Check if the plot has a city and if it belongs to the player
                if plot:IsCity() and plot:GetOwner() == playerID then
                    count = count + 1
                end
            end
        end
    end

    return count
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

local function GetCitiesCount(playerID)
    local player = Players[playerID]
    local playerCitiesCount = player:GetCities():GetCount()
    return playerCitiesCount
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

local function GetRiverOwnership(playerID)
    local player = Players[playerID]
    local capital = player:GetCities():GetCapitalCity()
    local capitalPlot = Map.GetPlot(capital:GetX(), capital:GetY())
    local capitalPlotIndex = Map.GetPlotIndex(capitalPlot)
    local riverID, riverPlots = ExposedMembers.HSD_GetRiverPlots(capitalPlot, capitalPlotIndex)

    local current = 0 -- Number of river plots owned by the player
    local total = #riverPlots -- Total number of river plots

    -- Iterate through each plot index in the riverPlots array
    for _, plotIndex in ipairs(riverPlots) do
        local plot = Map.GetPlotByIndex(plotIndex)
        if plot and plot:IsOwned() then
            if plot:GetOwner() == playerID then
                current = current + 1
            end
        end
    end

    return current, total
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

local function GetUnitClassCount(playerID, unitClassType)
    print("Checking number of " .. tostring(unitClassType) .. " units for player " .. tostring(playerID))
    local player = Players[playerID]
    local unitClassCount = 0

    if not player then
        print("Player not found for playerID: " .. tostring(playerID))
        return 0
    end

    local units = player:GetUnits()
    for _, unit in units:Members() do
        local unitType = unit:GetType()
        local unitInfo = GameInfo.Units[unitType]
        if unitInfo.PromotionClass == unitClassType then
            unitClassCount = unitClassCount + 1
        end
    end
    print("Player " .. tostring(playerID) .. " owns " .. tostring(unitClassCount) .. " " .. tostring(unitClassType) .. " units.")
    return unitClassCount
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

local function GetImprovementAdjacentPlot(improvementType, plot)
    local improvementIndex = GameInfo.Improvements[improvementType].Index
    for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
        local adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), direction)
        if adjacentPlot and adjacentPlot:GetImprovementType() == improvementIndex then
            print("Found " .. improvementType .. " in adjacent plot")
            return true
        end
    end
end

local function GetCitiesWithImprovementCount(playerID, improvementType)
    print("Checking for cities with improvement: " .. tostring(improvementType) .. " for player " .. tostring(playerID))
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local citiesWithImprovementCount = 0

    if not GameInfo.Improvements[improvementType] then
        print("Improvement type " .. tostring(improvementType) .. " not found in GameInfo.")
        return 0 -- Return 0 if the improvement doesn't exist in the database
    end

    local improvementIndex = GameInfo.Improvements[improvementType].Index

    for _, city in playerCities:Members() do
        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(playerID, city:GetID())
        for _, kCityUIDatas in pairs(CityUIDataList) do
            for _, kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
                local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                if plot and plot:GetImprovementType() == improvementIndex then
                    citiesWithImprovementCount = citiesWithImprovementCount + 1
                    break -- Found the improvement in this city, no need to check more plots for this city
                end
            end
        end
    end

    return citiesWithImprovementCount
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

local function GetFullyUpgradedUnitsCount(playerID, unitType)
    local player = Players[playerID]
    local playerUnits = player:GetUnits()
    local count = 0

    for i, unit in playerUnits:Members() do
        if unit:GetType() == unitType then 
            local unitLevel = unit:GetExperience():GetLevel()
            print("Unit is level "..tostring(unitLevel))
            if unitLevel == 8 then
                count = count + 1
            end
        end
    end

    return count
end

local function GetFullyUpgradedUnitClass(playerID, promotionClass)
    local player = Players[playerID]
    local playerUnits = player:GetUnits()
    local count = 0

    for i, unit in playerUnits:Members() do
        local unitType = unit:GetType()
        local unitPromotionClass = GameInfo.Units[unitType].PromotionClass
        if unitPromotionClass == promotionClass then
            local unitLevel = unit:GetExperience():GetLevel()
            print("Unit is level "..tostring(unitLevel))
            if unitLevel == 8 then
                count = count + 1
            end
        end
    end

    return count
end

local function GetNumCitiesWithinCapitalRange(playerID, range)
    local player = Players[playerID]
    local capitalCity = player:GetCities():GetCapitalCity()
    if not capitalCity then
        print("No capital city found for playerID:", playerID)
        return 0
    end

    local capitalX, capitalY = capitalCity:GetX(), capitalY:GetY()
    local citiesInRangeCount = 0

    -- Iterate through all cities owned by the player
    for _, city in player:GetCities():Members() do
        -- Exclude the capital city from the count
        if city:GetID() ~= capitalCity:GetID() then
            local cityX, cityY = city:GetX(), city:GetY()
            local distance = Map.GetPlotDistance(capitalX, capitalY, cityX, cityY)
            
            -- Increment count if the city is within the specified range
            if distance <= range then
                citiesInRangeCount = citiesInRangeCount + 1
            end
        end
    end

    -- Return the count of cities within range, excluding the capital itself
    return citiesInRangeCount
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
        if city:GetPlot():GetContinentType() ~= capitalContinentID then
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
				if city:GetPlot():GetContinentType() == GameInfo.Continents[continentName].Index then
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

local function GetHighestProduction(playerID)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local totalProduction = 0
    local highestOtherPlayerProduction = 0

    -- Calculate total production for the specified player
    for _, city in playerCities:Members() do
        local productionYield = city:GetYield(YieldTypes.PRODUCTION)
        totalProduction = totalProduction + productionYield
    end

    -- Compare against production of all other players
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        if otherPlayerID ~= playerID then
            local otherPlayer = Players[otherPlayerID]
            local otherPlayerTotalProduction = 0

            for _, city in otherPlayer:GetCities():Members() do
                local productionYield = city:GetYield(YieldTypes.PRODUCTION)
                otherPlayerTotalProduction = otherPlayerTotalProduction + productionYield
            end

            if otherPlayerTotalProduction > highestOtherPlayerProduction then
                highestOtherPlayerProduction = otherPlayerTotalProduction
            end
        end
    end

    print("Total Production for PlayerID " .. tostring(playerID) .. ": " .. tostring(totalProduction))
    print("Highest Production among other players: " .. tostring(highestOtherPlayerProduction))

    return totalProduction, highestOtherPlayerProduction
end


local function GetHighestFaithPerTurn(playerID)
    -- Get player faith per turn
    local player = Players[playerID]
    local playerFaithPerTurn = player:GetReligion():GetFaithYield()
    print("playerFaithPerTurn is "..tostring(playerFaithPerTurn))

    -- Get highest faith per turn count of all other players
    local highestFaithPerTurn = 0
    local allPlayerIDs = PlayerManager.GetAliveMajorIDs()  -- Using GetAliveMajorIDs to exclude city-states and other non-major civs
    for _, otherPlayerID in ipairs(allPlayerIDs) do
        if otherPlayerID ~= playerID then
            local otherPlayer = Players[otherPlayerID]
            local otherFaithPerTurn = otherPlayer:GetReligion():GetFaithYield()
            if otherFaithPerTurn > highestFaithPerTurn then
                highestFaithPerTurn = otherFaithPerTurn
            end
        end
    end
    print("highestFaithPerTurn is "..tostring(highestFaithPerTurn))

    return playerFaithPerTurn, highestFaithPerTurn
end


local function GetPlayerGold(playerID)
    local player = Players[playerID]
    if player then
        local playerTreasury = player:GetTreasury()
        local goldAmount = playerTreasury:GetGoldBalance()
        return goldAmount
    else
        print("Invalid player ID: " .. tostring(playerID))
        return 0
    end
end

local function GetHighestGoldPerTurn(playerID)
    local playerTreasury = Players[playerID]:GetTreasury()
    local playerGPT = playerTreasury:GetGoldYield() - playerTreasury:GetTotalMaintenance()

    local highestOtherGPT = 0
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        if otherPlayerID ~= playerID then
            local otherplayerTreasury = Players[otherPlayerID]:GetTreasury()
            local otherPlayerGPT = otherplayerTreasury:GetGoldYield() - otherplayerTreasury:GetTotalMaintenance()

            if otherPlayerGPT > highestOtherGPT then
                highestOtherGPT = otherPlayerGPT
            end
        end
    end

    return playerGPT, highestOtherGPT
end

local function GetHighestCityPopulation(playerID)
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

local function GetHighestCulture(playerID)
    local playerCulture, highestCulture = ExposedMembers.HSD_GetCultureCounts(playerID)
    return playerCulture, highestCulture
end

local function GetPlayerTechCounts(playerID)
    local playerTechCount, highestTechCount = ExposedMembers.HSD_GetNumTechsResearched(playerID)
    return playerTechCount, highestTechCount
end

local function IsBuildingInCapital(playerID, buildingType)
    local player = Players[playerID]
    if not player then
        print("Player not found for playerID:", playerID)
        return false
    end

    local capital = player:GetCities():GetCapitalCity()
    if not capital then
        print("Capital city not found for playerID:", playerID)
        return false
    end

    if not GameInfo.Buildings[buildingType] then
        print("Building type not found:", buildingType)
        return false
    end

    local buildingIndex = GameInfo.Buildings[buildingType].Index
    return capital:GetBuildings():HasBuilding(buildingIndex)
end

local function GetCitiesOnHomeContinent(playerID)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local homeContinent = nil
    local playerCityCount = 0
    local otherCityCount = 0

    -- Determine the player's home continent from their capital city
    local capitalCity = playerCities:GetCapitalCity()
    if capitalCity then
        homeContinent = capitalCity:GetPlot():GetContinentType()
    end

    -- Iterate through all cities to count those on the home continent
    for _, otherPlayer in ipairs(PlayerManager.GetAlive()) do
        for _, city in otherPlayer:GetCities():Members() do
            if city:GetPlot():GetContinentType() == homeContinent then
                if city:GetOwner() == playerID then
                    playerCityCount = playerCityCount + 1
                else
                    otherCityCount = otherCityCount + 1
                end
            end
        end
    end

    return playerCityCount, otherCityCount
end

local function GetCoastalCityCount(playerID)
    local player = Players[playerID]
    if not player then
        print("Player not found for playerID:", playerID)
        return 0
    end

    local playerCities = player:GetCities()
    local coastalCityCount = 0

    for _, city in playerCities:Members() do
        local cityPlot = Map.GetPlot(city:GetX(), city:GetY())

        -- Check adjacent plots for water
        for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
            local adjacentPlot = Map.GetAdjacentPlot(cityPlot:GetX(), cityPlot:GetY(), direction)
            if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
                coastalCityCount = coastalCityCount + 1
                break -- Found a water tile that is not a lake, no need to check other adjacent plots
            end
        end
    end

    return coastalCityCount
end

local function GetResourcePercentage(playerID, resourceType)
    local totalResourceCount = 0
    local playerResourceCount = 0
    local player = Players[playerID]

    -- Retrieve the resource data from the game property cache
    local resourceData = Game:GetProperty("HSD_ResourceData") or {}
    local resourcePlots = resourceData[resourceType]

    if not resourcePlots or #resourcePlots == 0 then
        print("No tiles found with resource " .. resourceType)
        return 0
    end

    -- Get the list of valid improvements for the resource
    local validImprovements = {}
    for row in GameInfo.Improvement_ValidResources() do
        if row.ResourceType == resourceType then
            table.insert(validImprovements, row.ImprovementType)
        end
    end

    -- Iterate through the plots of the specific resource
    for _, plotIndex in ipairs(resourcePlots) do
        local plot = Map.GetPlotByIndex(plotIndex)
        if plot then
            totalResourceCount = totalResourceCount + 1
            if plot:IsOwned() and plot:GetOwner() == playerID then
                -- Check if the plot has a valid improvement
                local improvementType = plot:GetImprovementType()
                local improvementInfo = GameInfo.Improvements[improvementType]
                if improvementInfo and tableContains(validImprovements, improvementInfo.ImprovementType) then
                    playerResourceCount = playerResourceCount + 1
                end
            end
        end
    end

    if totalResourceCount == 0 then
        print("No tiles found with resource " .. resourceType)
        return 0
    end

    local playerPercentage = (playerResourceCount / totalResourceCount) * 100
    return playerPercentage
end

local function GetPlayerFeaturePlotCount(playerID, featureType)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local featurePlotCount = 0

    -- Check if the feature type exists in the GameInfo table
    if not GameInfo.Features[featureType] then
        print("Feature type " .. tostring(featureType) .. " not found in GameInfo.")
        return featurePlotCount
    end

    local featureIndex = GameInfo.Features[featureType].Index

    for _, city in playerCities:Members() do
        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(playerID, city:GetID())
        for _, kCityUIDatas in pairs(CityUIDataList) do
            for _, kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
                local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                if plot:GetFeatureType() == featureIndex then
                    featurePlotCount = featurePlotCount + 1
                end
            end
        end
    end

    return featurePlotCount
end

local function GetNaturalWonderCount(playerID)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local controlledNaturalWonders = {}

    for _, city in playerCities:Members() do
        local CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(playerID, city:GetID())
        for _, kCityUIDatas in pairs(CityUIDataList) do
            for _, kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
                local plot = Map.GetPlotByIndex(kCoordinates.plotID)
                if plot and plot:IsNaturalWonder() then
                    local featureType = plot:GetFeatureType()
                    controlledNaturalWonders[featureType] = true
                end
            end
        end
    end

    local count = 0
    for _ in pairs(controlledNaturalWonders) do count = count + 1 end

    return count
end

-- Helper function to get the alliance count of a specific player
local function GetAllianceCount(playerID)
    local playerDiplomacy = Players[playerID]:GetDiplomacy()
    local allianceCount = 0

    for _, otherPlayerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        if otherPlayerID ~= playerID then
            if playerDiplomacy:HasAlliance(otherPlayerID) then
                allianceCount = allianceCount + 1
            end
        end
    end

    return allianceCount
end

local function GetAllianceCount_AllPlayers(targetAllianceCount)
    -- Check if the game property is already set
    if Game:GetProperty("HSD_"..tostring(targetAllianceCount).."_ACTIVE_ALLIANCES") then
        return Game:GetProperty("HSD_"..tostring(targetAllianceCount).."_ACTIVE_ALLIANCES") -- End the function if the property is already set
    end

    -- Iterate through all alive major players
    for _, playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        local allianceCount = GetAllianceCount(playerID)

        -- Check if the player has reached the target alliance count
        if allianceCount >= targetAllianceCount then
            -- Set the game property with this player's ID
            Game:SetProperty("HSD_"..tostring(targetAllianceCount).."_ACTIVE_ALLIANCES", playerID)
            return Game:GetProperty("HSD_"..tostring(targetAllianceCount).."_ACTIVE_ALLIANCES") -- Exit the loop as we found the first player to reach the target
        end
    end
end

local function GetAllianceLevelCount(playerID)
    local playerDiplomacy = Players[playerID]:GetDiplomacy()
    local allianceCount = 0
    local maximumAllianceLevel = 3

    for _, otherPlayerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        if otherPlayerID ~= playerID then
            if playerDiplomacy:HasAlliance(otherPlayerID) then
                local allianceLevel = playerDiplomacy:GetAllianceLevel()
                print("Alliance level is "..tostring(allianceLevel))
                if allianceLevel == maximumAllianceLevel then
                    allianceCount = allianceCount + 1
                end
            end
        end
    end

    return allianceCount
end

local function GetCitiesInRange_Building(playerID, buildingID, range)
    local player = Players[playerID]
    local playerCities = player:GetCities()
    local buildingIndex = GameInfo.Buildings[buildingID].Index
    local citiesInRangeCount = 0

    -- Iterate through player's cities to find the city with the specified building
    for _, city in playerCities:Members() do
        if city:GetBuildings():HasBuilding(buildingIndex) then
            local buildingPlot = city:GetBuildings():GetBuildingLocation(buildingIndex)

            -- Get the building's plot coordinates
            if buildingPlot then
                local buildingX, buildingY = buildingPlot:GetX(), buildingPlot:GetY()
                citiesInRangeCount = CountCitiesInRange(buildingX, buildingY, range, playerID)
            end
        end
    end

    return citiesInRangeCount
end

local function GetReligiousCitiesCount(playerID)
    local player = Players[playerID]
    local playerReligionID = player:GetReligion():GetReligionTypeCreated()
    local playerReligiousCitiesCount = 0
    local otherReligionsCitiesCounts = {}
    print("playerReligionID is "..tostring(playerReligionID))

    -- Iterate through all cities on the map
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        local otherPlayer = Players[otherPlayerID]
        for _, city in otherPlayer:GetCities():Members() do
            local cityReligion = city:GetReligion()
            local majorityReligion = cityReligion:GetMajorityReligion()
            print("majorityReligion is "..tostring(majorityReligion))
            -- Count cities for player's religion
            if majorityReligion == playerReligionID then
                playerReligiousCitiesCount = playerReligiousCitiesCount + 1
            elseif majorityReligion > 0 then
                -- Increment count for other religions
                if not otherReligionsCitiesCounts[majorityReligion] then
                    otherReligionsCitiesCounts[majorityReligion] = 1
                else
                    otherReligionsCitiesCounts[majorityReligion] = otherReligionsCitiesCounts[majorityReligion] + 1
                end
            end
        end
    end

    -- Find the highest number of cities converted by any single other religion
    local highestOtherReligionCitiesCount = 0
    for _, count in pairs(otherReligionsCitiesCounts) do
        if count > highestOtherReligionCitiesCount then
            highestOtherReligionCitiesCount = count
        end
    end

    return playerReligiousCitiesCount, highestOtherReligionCitiesCount
end

local function GetContinentsWithMajorityReligion(playerID)
    local player = Players[playerID]
    local playerReligionID = player:GetReligion():GetReligionTypeCreated()
    print("playerReligionID is "..tostring(playerReligionID))
    if playerReligionID == -1 then
        print("Player " .. tostring(playerID) .. " does not have a majority religion.")
        return 0
    end
    local continentsWithMajorityReligion = {}
    local continentReligionCounts = {}

    -- Iterate through all cities on the map
    for _, otherPlayerID in ipairs(PlayerManager.GetAliveIDs()) do
        local otherPlayer = Players[otherPlayerID]
        for _, city in otherPlayer:GetCities():Members() do
            local cityReligion = city:GetReligion()
            local majorityReligion = cityReligion:GetMajorityReligion()
            local cityPlot = city:GetPlot()
            local continentType = cityPlot:GetContinentType()

            -- Initialize continent religion count table
            if not continentReligionCounts[continentType] then
                continentReligionCounts[continentType] = {}
            end

            -- Initialize religion count for the continent
            if not continentReligionCounts[continentType][majorityReligion] then
                continentReligionCounts[continentType][majorityReligion] = 1
            else
                continentReligionCounts[continentType][majorityReligion] = continentReligionCounts[continentType][majorityReligion] + 1
            end
        end
    end

    -- Determine continents where player's religion is majority
    for continent, religions in pairs(continentReligionCounts) do
        local maxReligionCount = 0
        local maxReligion = nil
        for religion, count in pairs(religions) do
            if count > maxReligionCount then
                maxReligionCount = count
                maxReligion = religion
            end
        end
        if maxReligion == playerReligionID then
            table.insert(continentsWithMajorityReligion, continent)
        end
    end

    return #continentsWithMajorityReligion
end

local function GetCitiesFollowingReligion(playerID)
    local player = Players[playerID]
    local religionID = player:GetReligion():GetReligionTypeCreated()
    print("religionID is "..tostring(religionID))
    if religionID == -1 then
        print("Player " .. tostring(playerID) .. " does not have a majority religion.")
    end
    
    local citiesFollowingReligion = 0
    local totalCities = 0

    -- Iterate through player cities
    for _, city in player:GetCities():Members() do
        totalCities = totalCities + 1
        local cityReligion = city:GetReligion():GetMajorityReligion()

        -- Check if the city's majority religion matches the player's majority religion
        if cityReligion == religionID then
            citiesFollowingReligion = citiesFollowingReligion + 1
        end
    end

    return citiesFollowingReligion, totalCities
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

local function HSD_OnGovernmentChanged(playerID, governmentID)
    local governmentInfo = GameInfo.Governments[governmentID]
    local governmentKey = "HSD_" .. tostring(governmentInfo.GovernmentType)
    -- Only record first player to adopt government of this type
    if not Game:GetProperty(governmentKey) then
        Game:SetProperty(governmentKey, playerID)
        print("Recorded first adoption of government type " .. governmentInfo.GovernmentType .. " by player " .. tostring(playerID))
    else
        -- print(governmentInfo.GovernmentType .. " has already been adopted by another player.")
    end
end

local function HSD_OnGreatPersonActivated(UnitOwner, unitID, GreatPersonType, GreatPersonClass)
    local player = Players[UnitOwner]
    local greatPersonClassInfo = GameInfo.GreatPersonClasses[GreatPersonClass]
    local greatPersonEra = GameInfo.GreatPersonIndividuals[GreatPersonType].EraType
    print("Great person era is "..tostring(greatPersonEra))

    -- Record total number of Great people activated by the player
    local greatPersonCountKey = "HSD_GREAT_PERSON_COUNT_"..tostring(UnitOwner)
    local greatPersonCount = Game:GetProperty(greatPersonCountKey) or 0
    greatPersonCount = greatPersonCount + 1
    Game:SetProperty(greatPersonCountKey, greatPersonCount)

    -- Record total number of Great people activated by the player from this era
    local greatPersonEraCountKey = "HSD_GREAT_PERSON_ERA_COUNT_"..tostring(greatPersonEra)
    local greatPersonEraCount = player:GetProperty(greatPersonEraCountKey) or 0
    greatPersonEraCount = greatPersonEraCount + 1
    player:SetProperty(greatPersonEraCountKey, greatPersonEraCount)

    -- Record first player to activate great person of this type
    if greatPersonClassInfo then
        local greatPersonKey = "HSD_" .. tostring(greatPersonClassInfo.GreatPersonClassType)
        -- Only record first player to activate great person of this type
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

-- TODO: Seperate the count and first to completion functions
local function HSD_OnProjectCompleted(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
    local player = Players[playerID]
    local projectInfo = GameInfo.Projects[projectID]
    local projectKey = "HSD_" .. tostring(projectInfo.ProjectType) .. "_COMPLETED"

    -- Set turn project was first completed by any player
    if not Game:GetProperty(projectKey) then
        Game:SetProperty(projectKey, playerID)
        print("Recorded " .. projectInfo.ProjectType .. " as completed by player " .. tostring(playerID) .. " on turn " .. tostring(Game.GetCurrentGameTurn()))
    end

    -- Set project completed count
    local projectCountKey = "HSD_" .. tostring(projectInfo.ProjectType) .. "_PROJECT_COUNT"
    local projectCount = player:GetProperty(projectCountKey) or 0
    projectCount = projectCount + 1
    player:SetProperty(projectCountKey, projectCount)
    print("Project count is "..tostring(projectCount))

    -- Check if the project is part of any active victory conditions
    local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
    local conditionsForPlayer = victoryConditions[playerID] or {}
    for _, victoryCondition in ipairs(conditionsForPlayer) do
        for _, objective in ipairs(victoryCondition.objectives) do
            if (objective.type == "PROJECT_COMPLETED") and (objective.id == projectInfo.ProjectType) then
                -- Display in-game popup text
                local message = Locale.Lookup("LOC_HSD_PROJECT_COMPLETED_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(projectInfo.Name))
                Game.AddWorldViewText(0, message, iX, iY)
                break
            end
            if (objective.type == "PROJECT_COUNT") and (objective.id == projectInfo.ProjectType) then
                -- Display in-game popup text
                local message = Locale.Lookup("LOC_HSD_PROJECT_COUNT_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(projectInfo.Name), tostring(objective.count))
                Game.AddWorldViewText(0, message, iX, iY)
                break
            end
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

local function HSD_OnWarDeclared(firstPlayerID, secondPlayerID)
    -- local player = Players[firstPlayerID]
    -- local targetPlayer = Players[secondPlayerID]
    print("Player #"..tostring(firstPlayerID).." has declared war on player #"..tostring(secondPlayerID))
    -- Record the first player to declare war
    local propertyKey = "HSD_FIRST_WAR_DECLARED"
    if not Game:GetProperty(propertyKey) then
        Game:SetProperty(propertyKey, firstPlayerID)
        print("First war declared by player #"..tostring(firstPlayerID))
    end
end

local function HSD_OnWonderConstructed(iX, iY, buildingIndex, playerIndex, cityID, iPercentComplete, iUnknown)
    if iPercentComplete == 100 then  -- Ensure the wonder is fully constructed
        local buildingInfo = GameInfo.Buildings[buildingIndex]
        local wonderPlot = Map.GetPlot(iX, iY)
        local player = Players[playerIndex]
        if buildingInfo and buildingInfo.IsWonder then  -- Check if it's a wonder
            local wonderKey = "HSD_WONDER_" .. tostring(buildingInfo.BuildingType)

            -- Record the first player to complete this wonder
            if not Game:GetProperty(wonderKey) then
                Game:SetProperty(wonderKey, playerIndex)
                print("Recorded " .. buildingInfo.BuildingType .. " as first completed by player " .. tostring(playerIndex))
            else
                print(buildingInfo.BuildingType .. " has already been completed by another player.")
            end

            -- Check if the wonder completion is part of any active victory condition
            local victoryConditions = Game:GetProperty("HSD_PlayerVictoryConditions") or {}
            local conditionsForPlayer = victoryConditions[playerIndex] or {}
            for _, victoryCondition in ipairs(conditionsForPlayer) do
                for _, objective in ipairs(victoryCondition.objectives) do
                    if (objective.type == "WONDER_BUILT") and (objective.id == buildingInfo.BuildingType) then
                        -- Display in-game popup text
                        local message = Locale.Lookup("LOC_HSD_WONDER_CONSTRUCTED_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(buildingInfo.Name))
                        Game.AddWorldViewText(0, message, iX, iY)
                        -- break
                    end
                    if (objective.type == "WONDER_ADJACENT_IMPROVEMENT") and (objective.id == buildingInfo.BuildingType) then
                        -- Check for adjacent improvement
                        local objectiveMet = GetImprovementAdjacentPlot(objective.improvement, wonderPlot)
                        -- Set property
                        if objectiveMet then
                            local objectiveKey = "HSD_"..tostring(objective.improvement).."_ADJACENT_"..tostring(objective.id)
                            player:SetProperty(objectiveKey, Game.GetCurrentGameTurn())
                        end
                        -- Display in-game popup text
                        local message = Locale.Lookup("LOC_HSD_WONDER_CONSTRUCTED_FLOATER", "LOC_HSD_VICTORY_"..tostring(victoryCondition.playerTypeName).."_"..tostring(victoryCondition.index).."_NAME", Locale.Lookup(buildingInfo.Name))
                        Game.AddWorldViewText(0, message, iX, iY)
                        -- break
                    end
                end
            end
        else
            print("Error: Building index does not correspond to a wonder.")
        end
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
		elseif obj.type == "ALLIANCE_COUNT" then
			current = GetAllianceCount(playerID)
			total = obj.count
        elseif obj.type == "BORDERING_CITY_COUNT" then
			current = GetBorderingCitiesCount(playerID)
			total = obj.count
		elseif obj.type == "BUILDING_COUNT" then
			current = GetBuildingCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "BUILDING_IN_CAPITAL" then
			current = IsBuildingInCapital(playerID, obj.id) and 1 or 0
			total = 1
		elseif obj.type == "CITY_ADJACENT_TO_RIVER_COUNT" then
			current = GetCityAdjacentToRiverCount(playerID)
			total = obj.count
        elseif obj.type == "CITY_COUNT" then
			current = GetCitiesCount(playerID)
			total = obj.count
		elseif obj.type == "CITY_WITH_FEATURE_COUNT" then
			current = GetCitiesWithFeatureCount(playerID, obj.id) or 0
			total = obj.count
		elseif obj.type == "CITY_WITH_IMPROVEMENT_COUNT" then
			current = GetCitiesWithImprovementCount(playerID, obj.id) or 0
			total = obj.count
		elseif obj.type == "COASTAL_CITY_COUNT" then
			current = GetCoastalCityCount(playerID)
			total = obj.count
		elseif obj.type == "CONTROL_ALL_ADJACENT_RIVER_TO_CAPITAL" then
			current, total = GetRiverOwnership(playerID)
		elseif obj.type == "CONVERT_NUM_CONTINENTS" then -- UNTESTED
			current = GetContinentsWithMajorityReligion(playerID)
			total = obj.count
		elseif obj.type == "CONVERT_ALL_CITIES" then -- UNTESTED
			current, total = GetCitiesFollowingReligion(playerID)
		elseif obj.type == "DISTRICT_COUNT" then
			current = GetDistrictTypeCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "FEATURE_COUNT" then
			current = GetPlayerFeaturePlotCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "FIRST_NUM_ACTIVE_ALLIANCES" then
			current = GetAllianceCount_AllPlayers(obj.count)
			total = playerID
		elseif obj.type == "FIRST_BUILDING_CONSTRUCTED" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_CIVIC_RESEARCHED" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_GOVERNMENT" then -- UNTESTED
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_GREAT_PERSON_CLASS" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_TECH_RESEARCHED" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FIRST_WAR_DECLARED" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "FOREIGN_CONTINENT_CITIES" then
			current = GetCitiesOnForeignContinents(playerID)
			total = obj.count
		elseif obj.type == "FULLY_UPGRADE_UNIT_COUNT" then -- UNTESTED
			current = GetFullyUpgradedUnitsCount(playerID, obj.id)
			total = obj.count
		elseif obj.type == "FULLY_UPGRADE_UNIT_CLASS_COUNT" then -- UNTESTED
			current = GetFullyUpgradedUnitClass(playerID, obj.id)
			total = obj.count
		elseif obj.type == "GREAT_PERSON_ERA_COUNT" then -- UNTESTED
			current = player:GetProperty("HSD_GREAT_PERSON_ERA_COUNT_"..tostring(obj.id)) or 0
			total = obj.count
		elseif obj.type == "GOLD_COUNT" then -- UNTESTED
			current = GetPlayerGold(playerID)
			total = obj.count
		elseif obj.type == "GREAT_PEOPLE_ACTIVATED" then
			current = Game:GetProperty("HSD_GREAT_PERSON_COUNT_"..tostring(playerID)) or 0
			total = obj.count
		elseif obj.type == "HIGHEST_CITY_POPULATION" then
            isGreaterThan = true
			current, total = GetHighestCityPopulation(playerID)
		elseif obj.type == "HIGHEST_CULTURE" then
            isGreaterThan = true
			current, total = GetHighestCulture(playerID)
		elseif obj.type == "HIGHEST_FAITH_PER_TURN" then -- UNTESTED
            isGreaterThan = true
			current, total = GetHighestFaithPerTurn(playerID)
		elseif obj.type == "HIGHEST_GOLD_PER_TURN" then -- UNTESTED
            isGreaterThan = true
			current, total = GetHighestGoldPerTurn(playerID)
		elseif obj.type == "HIGHEST_PRODUCTION" then -- UNTESTED
            isGreaterThan = true
			current, total = GetHighestProduction(playerID)
		elseif obj.type == "HIGHEST_TECH_COUNT" then
            isGreaterThan = true
			current, total = GetPlayerTechCounts(playerID)
		elseif obj.type == "HOLY_CITY_COUNT" then
			current = ExposedMembers.HSD_GetHolyCitiesCount(playerID)
            total = obj.count
		elseif obj.type == "IMPROVEMENT_COUNT" then
			current = GetImprovementCount(playerID, obj.id) or -1
			total = obj.count
		elseif obj.type == "LAND_AREA_HOME_CONTINENT" then
			current = GetPercentLandArea_HomeContinent(playerID, obj.percent) or -1
			total = obj.percent
		elseif obj.type == "MAXIMUM_ALLIANCE_LEVEL_COUNT" then -- UNTESTED
			current = GetAllianceLevelCount(playerID)
			total = obj.count
		elseif obj.type == "MINIMUM_CONTINENT_TECH_COUNT" then
            isGreaterThan = true
			current, total = HasMoreTechsThanContinentMinimum(playerID, obj.continent)
		elseif obj.type == "MOST_ACTIVE_TRADEROUTES_ALL" then
            isGreaterThan = true
			current, total = GetTradeRoutesCount(playerID)
		elseif obj.type == "MOST_CITIES_FOLLOWING_RELIGION" then -- UNTESTED
            isGreaterThan = true
			current, total = GetReligiousCitiesCount(playerID)
		elseif obj.type == "MOST_CITIES_ON_HOME_CONTINENT" then
            isGreaterThan = true
			current, total = GetCitiesOnHomeContinent(playerID)
		elseif obj.type == "MOST_OUTGOING_TRADE_ROUTES" then
            isGreaterThan = true
			current, total = GetOutgoingRoutesCount(playerID)
		elseif obj.type == "NATURAL_WONDER_COUNT" then
			current = GetNaturalWonderCount(playerID)
			total = obj.count
		elseif obj.type == "NUM_CITIES_CAPITAL_RANGE" then -- UNTESTED
			current = GetNumCitiesWithinCapitalRange(playerID, obj.range)
			total = obj.count
		elseif obj.type == "NUM_CITIES_POP_SIZE" then
			current = GetNumCitiesWithPopulation(playerID, obj.cityNum, obj.popNum)
			total = obj.cityNum
		elseif obj.type == "OCCUPIED_CAPITAL_COUNT" then
			current = GetOccupiedCapitals(playerID)
			total = obj.count
		elseif obj.type == "PROJECT_COMPLETED" then
            isPlayerProperty = true
			current = Game:GetProperty("HSD_"..tostring(obj.id).."_COMPLETED") or -1 --playerID nil check
			total = playerID
		elseif obj.type == "PROJECT_COUNT" then
			current = player:GetProperty("HSD_"..tostring(obj.id).."_COUNT") or 0
			total = obj.count
		elseif obj.type == "RESOURCE_MONOPOLY" then
			current = GetResourcePercentage(playerID, obj.id)
			total = obj.percent
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
		elseif obj.type == "UNIT_CLASS_COUNT" then -- UNTESTED
			current = GetUnitClassCount(playerID, obj.id)
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
			-- current = GetWonderAdjacentImprovement(playerID, obj.id, obj.improvement) and 1 or 0
            current = player:GetProperty("HSD_"..tostring(obj.improvement).."_ADJACENT_"..tostring(obj.id)) and 1 or 0
			total = 1
		elseif obj.type == "WONDER_BUILT" then
			isPlayerProperty = true
			current = Game:GetProperty("HSD_WONDER_"..tostring(obj.id)) or -1 --playerID nil check
			total = playerID
		elseif obj.type == "WONDER_BUILT_CITIES_IN_RANGE" then
			current = GetCitiesInRange_Building(playerID, obj.id, obj.range)
			total = obj.count
		end

		if isPlayerProperty then
            -- Objective is met if the player detected is the local player (total == playerID)
			objectiveMet = current == total
            -- -- Display text instead of player IDs
            -- if (current == -1) then
            --     -- No player detected, display this via text
            --     current = "None"
            -- elseif (current >= 0) then
            --     -- Player ID detected, display the player name
            --     current = GameInfo.Civilizations[PlayerConfigurations[current]:GetCivilizationTypeName()].Name
            -- end
            -- -- Display the total as text
            -- total = GameInfo.Civilizations[PlayerConfigurations[total]:GetCivilizationTypeName()].Name
        elseif isEqual then
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
    local previousYear = ExposedMembers.GetCalendarTurnYear(Game.GetCurrentGameTurn() - 1)
    local annoDominiYear = ConvertYearToAnnoDomini(currentYear)
	local gameEra = Game.GetEras():GetCurrentEra()

    -- print("previousYear is "..tostring(previousYear))
    -- print("currentYear is "..tostring(currentYear))

    for index, condition in ipairs(conditionsForPlayer or {}) do
        local isTimeConditionMet = condition.year == nil or (currentYear <= condition.year)
        local isTimeLimit = (condition.yearLimit ~= nil)
        local isTimeLimitReached = ((condition.yearLimit == "ON_YEAR") and ((condition.year >= previousYear) and (condition.year < currentYear)))
        local isTimeLimitFailed = false
		local isEraConditionMet = condition.era == nil or (GameInfo.Eras[condition.era].Index >= gameEra)
        local isEraObjectiveMet = condition.era == nil or (GameInfo.Eras[condition.era].Index == gameEra)
        local isEraLimitMet = condition.eraLimit == nil or ((condition.eraLimit == "END_ERA") and (ExposedMembers.GetEraCountdown() > 0))
        local victoryPropertyName = "HSD_HISTORICAL_VICTORY_" .. index
        local victoryAlreadySet = player:GetProperty(victoryPropertyName)

        -- print("yearLimit is "..tostring(condition.yearLimit))
        -- print("isTimeLimit is "..tostring(isTimeLimit))
        -- print("isTimeLimitReached is "..tostring(isTimeLimitReached))

        if isTimeConditionMet and isEraConditionMet and not victoryAlreadySet then
            if EvaluateObjectives(player, condition) then
                if isEraObjectiveMet and isEraLimitMet and not isTimeLimit then
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
        end
        if isTimeLimitReached and not victoryAlreadySet then
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
            else
                isTimeLimitFailed = true
                print("Time limit failed for player #"..tostring(iPlayer))
            end
        end
        if not victoryAlreadySet and (((not isTimeConditionMet) and (not isTimeLimit)) or ((not isEraConditionMet) and (GameInfo.Eras[condition.era].Index < gameEra)) or (isTimeLimit and isTimeLimitFailed)) then
            -- Objectives failed
            player:SetProperty(victoryPropertyName, -1)
        end
    end

    -- Create victory building if score threshold is reached
    local victoryPropertyName = "HSD_HISTORICAL_VICTORY_PROJECT_GRANTED"
    local victoryAlreadySet = player:GetProperty(victoryPropertyName)
    local totalVictoryScore = player:GetProperty("HSD_HISTORICAL_VICTORY_SCORE")
    if not victoryAlreadySet and totalVictoryScore and (totalVictoryScore >= iVictoryScoreToWin) then
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
    CacheAllResourcePlots() -- Sets game property containing resource plots as table
    CacheVictoryConditions() -- Sets game property containing victory data as table
    Events.CityProjectCompleted.Add(HSD_OnProjectCompleted)
	Events.CivicCompleted.Add(HSD_OnCivicCompleted)
    Events.DiplomacyDeclareWar.Add(HSD_OnWarDeclared)
    Events.GovernmentChanged.Add(HSD_OnGovernmentChanged)
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