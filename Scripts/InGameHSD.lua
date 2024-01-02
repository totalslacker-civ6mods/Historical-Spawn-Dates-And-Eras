------------------------------------------------------------------------------
--	FILE:	 InGameHSD.lua
--  Gedemon (2017)
--	totalslacker (2020-2021)
------------------------------------------------------------------------------

include("ScriptHSD.lua")

print ("loading InGameHSD.lua")

----------------------------------------------------------------------------------------
-- User Interface and Gameplay Menu Settings
----------------------------------------------------------------------------------------

--Share context via ExposedMembers for UI and Gameplay scripts to communicate
LuaEvents = ExposedMembers.LuaEvents

local defaultQuickMovement 	= UserConfiguration.GetValue("QuickMovement")
local defaultQuickCombat 	= UserConfiguration.GetValue("QuickCombat")
local defaultAutoEndTurn	= UserConfiguration.GetValue("AutoEndTurn") 

----------------------------------------------------------------------------------------
-- Timeline Functions
----------------------------------------------------------------------------------------

function GetStandardTimeline(civType)
	local iStartYear = false
	-- local results = DB.ConfigurationQuery("SELECT * FROM HistoricalSpawnDates")
	local results = DB.Query("SELECT * FROM HistoricalSpawnDates")
	for i, row in ipairs(results) do
		if row.Civilization == civType then
			iStartYear = row.StartYear
			print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
		end
	end
	return iStartYear
end

function GetTrueHSDTimeline(civType)
	local iStartYear = false
	-- local results = DB.ConfigurationQuery("SELECT * FROM HistoricalSpawnDates_TrueHSD")
	local results = DB.Query("SELECT * FROM HistoricalSpawnDates_TrueHSD")
	for i, row in ipairs(results) do
		if row.Civilization == civType then
			iStartYear = row.StartYear
			print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
		end
	end
	return iStartYear
end

function GetLeaderTimeline(civType)
	local iStartYear = false
	-- local results = DB.ConfigurationQuery("SELECT * FROM HistoricalSpawnDates_LeaderHSD")
	local results = DB.Query("SELECT * FROM HistoricalSpawnDates_LeaderHSD")
	for i, row in ipairs(results) do
		if row.Civilization == civType then
			iStartYear = row.StartYear
			print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
		end
	end
	return iStartYear
end

function GetEraTimeline(civType)
	local iStartEra = false
	-- local results = DB.ConfigurationQuery("SELECT * FROM HistoricalSpawnEras")
	local results = DB.Query("SELECT * FROM HistoricalSpawnEras")
	for i, row in ipairs(results) do
		if row.Civilization == civType then
			iStartEra = row.Era
			print(tostring(row.Civilization), " spawn era = ", tostring(row.Era))
		end
	end
	return iStartEra
end

function GetLitemodeCivs(civType)
	-- local iStartYear = false
	-- local iStartEra = false
	local eligibleForHSD = false
	local isolated = DB.Query("SELECT * FROM IsolatedCivs")
	local colonial = DB.Query("SELECT * FROM ColonialCivs")
	for i, row in ipairs(isolated) do
		if ((row.Civilization == civType) or ((GameInfo.CivilizationLeaders[civType]) and (row.Civilization == GameInfo.CivilizationLeaders[civType].CivilizationType))) then
			eligibleForHSD = true
			print(tostring(row.Civilization), " is an isolated player.")
		end
	end
	for i, row in ipairs(colonial) do
		if ((row.Civilization == civType) or ((GameInfo.CivilizationLeaders[civType]) and (row.Civilization == GameInfo.CivilizationLeaders[civType].CivilizationType))) then
			eligibleForHSD = true
			print(tostring(row.Civilization), " is a colonial player.")
		end
	end
	return eligibleForHSD
end

----------------------------------------------------------------------------------------
-- Calendar Functions
----------------------------------------------------------------------------------------

function GetCalendarTurnYear(iTurn)
	local turnYearStr = Calendar.MakeYearStr(iTurn)
	local isBC = string.find(turnYearStr, "BC") -- Check if the year is BC
	local gSubString = string.gsub(turnYearStr, "%D", "") -- Remove all non-digit characters to get the year number
	local turnYearInt = tonumber(gSubString)

	if isBC then
		turnYearInt = -turnYearInt -- Make the year negative if it's BC
	end
	
	print("GetCalendarTurnYear returned "..tostring(turnYearStr))
	print("New value is "..tostring(turnYearInt))
	return turnYearInt
end

function SetTurnYear(iTurn)
	previousTurnYear 	= Calendar.GetTurnYearForGame( iTurn )
	currentTurnYear 	= Calendar.GetTurnYearForGame( iTurn + 1 )
	nextTurnYear 		= Calendar.GetTurnYearForGame( iTurn + 2 )
	GameConfiguration.SetValue("PreviousTurnYear", previousTurnYear)
	GameConfiguration.SetValue("CurrentTurnYear", currentTurnYear)
	GameConfiguration.SetValue("NextTurnYear", nextTurnYear)
	LuaEvents.SetPreviousTurnYear(previousTurnYear)
	LuaEvents.SetCurrentTurnYear(currentTurnYear)
	LuaEvents.SetNextTurnYear(nextTurnYear)
end

function SetAutoValues()
	--UserConfiguration.SetValue("QuickMovement", 1)
	--UserConfiguration.SetValue("QuickCombat", 1)
	UserConfiguration.SetValue("AutoEndTurn", 1)
end

function RestoreAutoValues()
	--UserConfiguration.SetValue("QuickMovement", defaultQuickMovement)
	--UserConfiguration.SetValue("QuickCombat", 	defaultQuickCombat 	)
	UserConfiguration.SetValue("AutoEndTurn", 	defaultAutoEndTurn	)
end

function SetStartingEra(iPlayer, era)
	local key = "StartingEra"..tostring(iPlayer)
	print ("saving key = "..key..", value = ".. tostring(era))
	GameConfiguration.SetValue(key, era)
end

----------------------------------------------------------------------------------------
-- Support Functions for City Conversion and Revolts
----------------------------------------------------------------------------------------

function CheckCityGovernor(pPlayerID, pCityID)
	local pPlayer = Players[pPlayerID]
	local pCity = pPlayer:GetCities():FindID(pCityID)
	local pGovernor = pCity:GetAssignedGovernor()
	local bCapital = CheckCityCapital(pPlayerID, pCityID)
	if pCity and (pGovernor == nil or not pGovernor:IsEstablished()) and not bCapital then
		print ("CheckCityGovernor returning city ID")
		local pFreeCityID = pCity:GetID()
		if pFreeCityID then
			return pFreeCityID
		else
			print("CheckCityGovernor could not return a city ID")
			return false
		end
	else
		print ("City was an original capital or had an established governor.")
		return false
	end
end

function CheckCityCapital(pPlayerID, pCityID)
	local bCapital = false
	local pPlayer = Players[pPlayerID]
	local pCity = pPlayer:GetCities():FindID(pCityID)
	if pPlayer and pCity then
		if pCity:IsOriginalCapital() and (pCity:GetOriginalOwner() == pCity:GetOwner()) then
			if pCity:IsCapital() then
				-- Original capital still owned by original owner
				print("Found original capital")
				bCapital = true
			else
				print("Found occupied capital")
				bCapital = false
			end
		elseif pCity:IsOriginalCapital() and (pCity:GetOriginalOwner() ~= pCity:GetOwner()) then
			print("Found occupied capital")
			bCapital = false			
		elseif pCity:IsCapital() then
			-- New capital
			print("Found new capital")
			bCapital = false
		else
			-- Other cities
			print("Found non-capital city")
			bCapital = false
		end	
	end
	return bCapital
end

function CheckCityOriginalCapital(pPlayerID, pCityID)
	local pPlayer = Players[pPlayerID]
	local pCity = CityManager.GetCity(iPlayer, cityID)
	local bOriginalCapital = false
	-- if pCity:IsOriginalCapital() then 
		-- print("IsOriginalCapital is "..tostring(pCity:IsOriginalCapital()))
		-- bOriginalCapital = true 
	-- end
	if pPlayer:IsMajor() and pCity then
		if pCity:IsOriginalCapital() and pCity:GetOriginalOwner() == pCity:GetOwner() then
			if pCity:IsCapital() then
				-- Original capital still owned by original owner
				print("Found original capital")
				return false
			else
				local pOriginalOwner = pCity:GetOriginalOwner()
				print("Found occupied capital")
				return pOriginalOwner
			end
		elseif pCity:IsOriginalCapital() and pCity:GetOriginalOwner() ~= pCity:GetOwner() then
			local pOriginalOwner = pCity:GetOriginalOwner()
			print("Found occupied capital")
			return pOriginalOwner			
		elseif pCity:IsCapital() then
			-- New capital
			print("Found new capital")
			return false
		else
			-- Other cities
			print("Found non-capital city")
			return false
		end	
	end
	return bOriginalCapital
end

----------------------------------------------------------------------------------------
-- Get city data from UI context, such as plots owned, to pass to in-game context
----------------------------------------------------------------------------------------

-- all credit for the code below goes to Tiramasu, taken from the Free City States mod
function GetPlayerCityUIDatas(pPlayerID, pCityID)
	local CityUIDataList = {}	
	local pPlayer = Players[pPlayerID]
	local pCity = pPlayer:GetCities():FindID(pCityID)	
	if pCity then	
		local kCityUIDatas :table = {	
			iPosX = nil,
			iPosY = nil,
			iCityID = nil,
			sCityName = "",
			CityPlotCoordinates = {},
			CityDistricts = {},
			CityBuildings = {},
			CityReligions = {},
			-- CityPlotImprovements = {},
		}		
		--General City Datas:
		kCityUIDatas.iPosX = pCity:GetX()
		kCityUIDatas.iPosY = pCity:GetY()		
		kCityUIDatas.iCityID = pCity:GetID()
		kCityUIDatas.sCityName = pCity:GetName()
		--City Tiles Datas:
		local kCityPlots :table = Map.GetCityPlots():GetPurchasedPlots( pCity )				
		for _,plotID in pairs(kCityPlots) do
			local pPlot:table = Map.GetPlotByIndex(plotID)
			local kCoordinates:table = {
				iX = pPlot:GetX(), 
				iY = pPlot:GetY(),
				plotID = pPlot:GetIndex(),
				plotImprovementIndex = pPlot:GetImprovementType()
			}
			table.insert(kCityUIDatas.CityPlotCoordinates, kCoordinates)
			-- local kImprovement:table = {
				-- plotID = plotID,
				-- plotImprovement = pPlot:GetImprovementType()
			-- }
			-- table.insert(kCityUIDatas.CityPlotImprovements, kImprovement)
		end
		--City District Datas:
		local pCityDistricts :table	= pCity:GetDistricts()			
		for _, pDistrict in pCityDistricts:Members() do
			table.insert(kCityUIDatas.CityDistricts, {
				iPosX = pDistrict:GetX(), 
				iPosY = pDistrict:GetY(), 
				iType = pDistrict:GetType(), 
				bPillaged = pCityDistricts:IsPillaged(pDistrict:GetType()),
			})
		end
		--City Buildings Datas: (actually these Datas can also be accessed in gameplay context)
		local pCityBuildings = pCity:GetBuildings()
		for pBuilding in GameInfo.Buildings() do
			if( pCityBuildings:HasBuilding(pBuilding.Index) ) then				
				table.insert(kCityUIDatas.CityBuildings, {				
					iBuildingID = pBuilding.Index,
					bIsPillaged = pCityBuildings:IsPillaged(pBuilding.Index),
				})
			end
		end
		--Religious Pressure Data:
		local pReligions :table = pCity:GetReligion():GetReligionsInCity()
		for _, religionData in pairs(pReligions) do
			table.insert(kCityUIDatas.CityReligions, {
				iReligionType = religionData.Religion,
				iPressure = religionData.Pressure,
			})
		end
		--Save all City Datas:
		table.insert(CityUIDataList, kCityUIDatas)
	end	
	return CityUIDataList
end

----------------------------------------------------------------------------------------
-- Support functions for Raging Barbarians mode
----------------------------------------------------------------------------------------

function GetEraCountdown()
	local pGameEras:table = Game.GetEras()
	local nextEraCountdown = pGameEras:GetNextEraCountdown() + 1; -- 0 turns remaining is the last turn, shift by 1 to make sense to non-programmers
	-- print("nextEraCountdown is "..tostring(nextEraCountdown))
	return nextEraCountdown
end

function GetTribeNameType(iBarbarianTribe)
	local pBarbManager = Game.GetBarbarianManager()
	local iBarbType = pBarbManager:GetTribeNameType(iBarbarianTribe)
	print("GetTribeNameType returned iBarbType of "..tostring(iBarbType))
	return iBarbType
end

----------------------------------------------------------------------------------------
-- Support functions for Historical Victory Mode
----------------------------------------------------------------------------------------

function HSD_GetTerritoryCache()
	local territoryCache = {}

	local nPlots = Map.GetPlotCount();
	for iPlot = 0,nPlots-1 do
		local pTerritory = Territories.GetTerritoryAt(iPlot);
		if pTerritory then
			local eTerritory = pTerritory:GetID();
			if territoryCache[eTerritory] then
				-- Add a new plot
				table.insert(territoryCache[eTerritory].pPlots, iPlot);
			else
				-- Instantiate a new territory
				territoryCache[eTerritory] = { pPlots = { iPlot } };
			end
		end
	end
	
	return territoryCache
end

function HSD_GetTerritoryID(plotID)
	local iTerritory = false
	local territoryObject = Territories.GetTerritoryAt(plotID)
	if territoryObject then
		iTerritory = territoryObject:GetID()
	end
	return iTerritory
end

function HSD_GetTotalIncomingRoutes(playerID)
    local totalIncomingRoutes = 0
    local player = Players[playerID]

    if player then
        local playerCities = player:GetCities()
        for _, city in playerCities:Members() do
            local incomingRoutes = city:GetTrade():GetIncomingRoutes()
            for _, route in ipairs(incomingRoutes) do
                if route.OriginCityPlayer ~= playerID then -- Check if route is from a foreign city
                    totalIncomingRoutes = totalIncomingRoutes + 1
                end
            end
        end
    end

    return totalIncomingRoutes
end


----------------------------------------------------------------------------------------
-- Initialize all functions and link to the the necessary in-game event hooks
----------------------------------------------------------------------------------------

function InitializeHSD_UI()
	-- Update calendar functions from UI for gameplay scripts
	-- Events.TurnBegin.Add(SetTurnYear)
	Events.TurnEnd.Add(SetTurnYear)
	LuaEvents.SetTurnYear.Add(SetTurnYear)
	LuaEvents.SetAutoValues.Add(SetAutoValues)
	LuaEvents.RestoreAutoValues.Add(RestoreAutoValues)
	LuaEvents.SetStartingEra.Add( SetStartingEra )
	-- Share UI context functions with gameplay scripts
	ExposedMembers.GetStandardTimeline = GetStandardTimeline
	ExposedMembers.GetTrueHSDTimeline = GetTrueHSDTimeline
	ExposedMembers.GetLeaderTimeline = GetLeaderTimeline
	ExposedMembers.GetEraTimeline = GetEraTimeline
	ExposedMembers.GetLitemodeCivs = GetLitemodeCivs
	ExposedMembers.CheckCity.CheckCityGovernor = CheckCityGovernor
	ExposedMembers.CheckCityCapital = CheckCityCapital
	ExposedMembers.CheckCityOriginalCapital = CheckCityOriginalCapital
	ExposedMembers.GetPlayerCityUIDatas = GetPlayerCityUIDatas
	ExposedMembers.GetEraCountdown = GetEraCountdown
	ExposedMembers.GetTribeNameType = GetTribeNameType
	ExposedMembers.GetCalendarTurnYear = GetCalendarTurnYear
	ExposedMembers.HSD_GetTerritoryCache = HSD_GetTerritoryCache
	ExposedMembers.HSD_GetTerritoryID = HSD_GetTerritoryID
	ExposedMembers.HSD_GetTotalIncomingRoutes = HSD_GetTotalIncomingRoutes
	-- Set current & next turn year ASAP when (re)loading
	LuaEvents.SetCurrentTurnYear(Calendar.GetTurnYearForGame(Game.GetCurrentGameTurn()))
	LuaEvents.SetNextTurnYear(Calendar.GetTurnYearForGame(Game.GetCurrentGameTurn()+1))	
	-- Broacast that we're ready to set HSD
	LuaEvents.InitializeHSD()
end

InitializeHSD_UI();

----------------------------------------------------------------------------------------
-- END
----------------------------------------------------------------------------------------