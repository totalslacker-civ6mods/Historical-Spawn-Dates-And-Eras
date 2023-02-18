------------------------------------------------------------------------------
--	FILE:	 ScriptHSD.lua
--  Gedemon (2017)
--  totalslacker (2020-2023)
--
--	TODO:
--  Receive spawn bonuses based on progress of other players on same continent
--  Spawn units based on military strength of nearby players
--  Starting units receive free maintainence and extra movement points
--  Ancient era civs do not receive bonuses unless they have HSD
--	City states able to cause revolts and convert cities
--	Test CityManager.TransferCityToFreeCities(CityInstance) and CityManager.TransferCity(Player)
------------------------------------------------------------------------------

include("UnitFunctions");
include("ScenarioFunctions");
include("SupportFunctions");

local HSD_Version 	= GameInfo.GlobalParameters["HSD_VERSION"].Value
-- local ShowLuaLogs	= true	--not active yet, will be implemented later
print ("Historical Spawn Dates version " .. tostring(HSD_Version))
print ("loading ScriptHSD.lua")

-- ===========================================================================
-- UI Context from ExposedMembers
-- ===========================================================================

ExposedMembers.LuaEvents = LuaEvents
ExposedMembers.GameEvents = GameEvents
ExposedMembers.CheckCity =	{}
ExposedMembers.CheckCityCapital =	{}
ExposedMembers.CheckCityOriginalCapital = {}
ExposedMembers.GetPlayerCityUIDatas = {}
ExposedMembers.GetEraCountdown = {}
ExposedMembers.GetStandardTimeline = {}
ExposedMembers.GetTrueHSDTimeline = {}
ExposedMembers.GetLeaderTimeline = {}
ExposedMembers.GetEraTimeline = {}
ExposedMembers.GetLitemodeCivs = {}

-- ===========================================================================
-- Global Variables - Shared with support functions
-- ===========================================================================

local bExpansion2				= GameConfiguration.GetValue("RULESET") == "RULESET_EXPANSION_2"
print("bExpansion2 is "..tostring(bExpansion2))
bGatheringStormActive			= false	--Global Variable
bSpawnUniqueUnits				= MapConfiguration.GetValue("SpawnUUs")	--Global Variable
bSubtractEra					= MapConfiguration.GetValue("SubtractEra") --Global Variable

-- ===========================================================================
-- Game Configuration Values 
-- ===========================================================================

GameSpeedMultiplier = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier
print("Game speed multiplier is "..tostring(GameSpeedMultiplier).." = "..Locale.Lookup(GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].Name))
iDifficulty = GameInfo.Difficulties[PlayerConfigurations[0]:GetHandicapTypeID()].Index
print("Difficulty setting is "..tostring(iDifficulty).." = "..Locale.Lookup(GameInfo.Difficulties[iDifficulty].Name))
bDramaticAges = GameConfiguration.GetValue("GAMEMODE_DRAMATICAGES")
print("Dramatic Ages is "..tostring(bDramaticAges))

--This is the maximum possible number of player slots, minus one, for the zero index. DO NOT CHANGE THIS VALUE
--Player ID is zero indexed, so the player (in player slot 1 in the setup menu) is #0, next is #1, etc
iMaxPlayersZeroIndex = 63 
print("iMaxPlayersZeroIndex is "..tostring(iMaxPlayersZeroIndex))

-- ===========================================================================
-- Mod Configuration Values
-- ===========================================================================

local bHistoricalSpawnDates		= MapConfiguration.GetValue("HistoricalSpawnDates") or GameConfiguration.GetValue("GAMEMODE_HSD")
local bHistoricalSpawnEras		= MapConfiguration.GetValue("HistoricalSpawnEras")
local bInputHSD					= MapConfiguration.GetValue("InputHSD")
local bApplyBalance				= MapConfiguration.GetValue("BalanceHSD")
local bTechCivicBoost			= MapConfiguration.GetValue("TechCivicBoost")
local iSpawnDateTables			= MapConfiguration.GetValue("SpawnDateTables")
local bEraBuilding				= MapConfiguration.GetValue("EraBuildingForAll")
local bColonizationMode			= MapConfiguration.GetValue("Colonization") 
local bPlayerColonies			= MapConfiguration.GetValue("PlayerColonies")
local bGrantGPP					= MapConfiguration.GetValue("GrantGPP")
local bSpawnZonesDisabled		= MapConfiguration.GetValue("FlipZones")
local bSpawnRange				= MapConfiguration.GetValue("SpawnRange")
local bGoldenAgeSpawn			= MapConfiguration.GetValue("SpawnAge")
local bLiteMode					= MapConfiguration.GetValue("LiteMode")
local bCityStateRevolts			= MapConfiguration.GetValue("CityStateRevolts") or true --set to false if config value is created
local bRenameCapitals			= MapConfiguration.GetValue("RenameCapitals") or false
local bConvertMode				= MapConfiguration.GetValue("ConvertMode") or false
-- local iLegacySpawnDates			= MapConfiguration.GetValue("OldWorldStart")
local bRagingBarbarians			= MapConfiguration.GetValue("RagingBarbarians") or false
local bBarbarianInvasions		= MapConfiguration.GetValue("RagingBarbarians_Invasions") or false
local bConvertCities			= MapConfiguration.GetValue("ConvertCities") or false 
local iConvertSpawnZone			= MapConfiguration.GetValue("ConvertSpawnZones") or false
local bPeacefulSpawns			= MapConfiguration.GetValue("PeacefulSpawns") or false
local bRestrictSpawnZone		= MapConfiguration.GetValue("RestrictSpawnZone") or false
local bUniqueSpawnZones			= MapConfiguration.GetValue("UniqueSpawnZones") or false
local bIgnoreGovernor			= MapConfiguration.GetValue("IgnoreGovernor") or false
local bOverrideSpawn			= MapConfiguration.GetValue("OverrideSpawn") or false
local iUnitListType				= MapConfiguration.GetValue("UnitList") or 1 -- 1 = Static Unit List, 0 = Dynamic Unit List

print("bHistoricalSpawnDates is "..tostring(bHistoricalSpawnDates))
print("bHistoricalSpawnEras is "..tostring(bHistoricalSpawnEras))
print("bInputHSD is "..tostring(bInputHSD))
print("bApplyBalance is "..tostring(bApplyBalance))
print("bTechCivicBoost is "..tostring(bTechCivicBoost))
print("iSpawnDateTables is "..tostring(iSpawnDateTables))
-- print("iLegacySpawnDates is "..tostring(iLegacySpawnDates))
print("bEraBuilding is "..tostring(bEraBuilding))
print("bColonizationMode is "..tostring(bColonizationMode))
print("bPlayerColonies is "..tostring(bPlayerColonies))
print("bGrantGPP is "..tostring(bGrantGPP))
print("bSpawnUniqueUnits is "..tostring(bSpawnUniqueUnits))
print("bSpawnZonesDisabled is "..tostring(bSpawnZonesDisabled))
print("bSpawnRange is "..tostring(bSpawnRange))
print("bGoldenAgeSpawn is "..tostring(bGoldenAgeSpawn))
print("bSubtractEra is "..tostring(bSubtractEra))
print("bConvertCities is "..tostring(bConvertCities))
print("iConvertSpawnZone is "..tostring(iConvertSpawnZone))
print("bPeacefulSpawns is "..tostring(bPeacefulSpawns))
print("bRestrictSpawnZone is "..tostring(bRestrictSpawnZone))
print("bUniqueSpawnZones is "..tostring(bUniqueSpawnZones))
print("bIgnoreGovernor is "..tostring(bIgnoreGovernor))
print("bOverrideSpawn is "..tostring(bOverrideSpawn))
print("iUnitListType is "..tostring(iUnitListType))
print("bCityStateRevolts is "..tostring(bCityStateRevolts))

-- ===========================================================================
-- Other Game Settings
-- ===========================================================================

-- local iTestingRandoms = Game.GetRandNum(2, "Random Continent Roll")
-- print("iTestingRandoms is "..tostring(iTestingRandoms))

--New players will receive bonus settlers after this era
local iSettlerEra :number = 0
print("iSettlerEra is "..tostring(iSettlerEra))

local iSpawnRange = MapConfiguration.GetValue("SpawnRangeSlider") or 10
print("iSpawnRange is "..tostring(iSpawnRange))

local bNotifications :boolean = true
print("bNotifications is "..tostring(bNotifications)..". Notifications will displayed for player spawns.")

local bSavedSpawnDates :boolean = true
print("bSavedSpawnDates is "..tostring(bSavedSpawnDates))

local bAnnoDomini :boolean = true
print("bAnnoDomini is "..tostring(bAnnoDomini))

if bExpansion2 then bGatheringStormActive = true end
print("bGatheringStormActive is "..tostring(bGatheringStormActive))

----------------------------------------------------------------------------------------
-- Historical Spawn Dates <<<<<
----------------------------------------------------------------------------------------
if bHistoricalSpawnDates then
----------------------------------------------------------------------------------------

-- ===========================================================================
-- Initialize variables
-- ===========================================================================

print("Activating Historical Spawn Dates...")
local minimalStartYear 		= -4000000 -- Should cover every prehistoric start mod...
local defaultStartYear 		= -3960
local defaultStartEra 		= 0
local previousTurnYear 		= GameConfiguration.GetValue("PreviousTurnYear") or minimalStartYear
local currentTurnYear 		= GameConfiguration.GetValue("CurrentTurnYear")
local nextTurnYear 			= GameConfiguration.GetValue("NextTurnYear")

local isInGame 			= {}	-- Table to track players in the game
local knownTechs		= {} 	-- Table to track each known tech (with number of civs) 
local knownCivics		= {}	-- Table to track each known civic (with number of civs) 
local researchedCivics	= {}	-- Table to track each researched civic 
local spawnDates 		= {}	-- Table to track starting years
local spawnEras			= {}	-- Table to track starting eras
local Notifications_revoltingCityPlots	= {} -- Table to track city revolts
local playersWithCity	= 0		-- Total number of major players with at least one city
local scienceBonus		= 0
local goldBonus			= 0
local settlersBonus		= 0
local tokenBonus		= 0
local faithBonus		= 0
local minCivForTech		= 1
local minCivForCivic	= 1
local currentEra		= 0
local gameCurrentEra	= 0

-- ===========================================================================
-- GameInfo indexes
-- ===========================================================================

local ms_TundraTerrainClass :number 	= 4 --Default TerrainClass index for Tundra
local ms_SnowTerrainClass :number 		= 5 --Default TerrainClass index for Snow
local ms_IceFeatureType :number			= 1 --Default Features index for Ice

if GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"] then
	ms_TundraTerrainClass = GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"].Index
else
	print("Tundra TerrainClass is nil")
end

if GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"] then
	ms_SnowTerrainClass	= GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"].Index
else
	print("Snow TerrainClass is nil")
end

if GameInfo.Features["FEATURE_ICE"] then
	ms_IceFeatureType = GameInfo.Features["FEATURE_ICE"].Index
else
	print("Ice FeatureClass is nil")
end

local iGreatScientist 	= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_SCIENTIST"].Index
local iGreatWriter 		= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_WRITER"].Index
local iGreatArtist 		= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_ARTIST"].Index
local iGreatMusician	= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_MUSICIAN"].Index
local iGreatProphet 	= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_PROPHET"].Index
local iGreatEngineer	= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_ENGINEER"].Index
local iGreatMerchant	= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_MERCHANT"].Index
local iGreatAdmiral		= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_ADMIRAL"].Index
local iGreatGeneral		= GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_GENERAL"].Index

-- ===========================================================================
-- Utility Functions
-- ===========================================================================

function Round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

function ConvertStringToYear(inputHSD)
	-- print("Calling ConvertStringToYear")
	-- print("inputHSD is type "..type(inputHSD))
	local value = tonumber(inputHSD)
	-- print("tonumber is type "..type(value))
	if not value then
		print("WARNING: The start date was input incorrectly. value is "..tostring(inputHSD))
		local gSubString = string.gsub(inputHSD, "%D", "")
		print("New value is "..tostring(gSubString))
		value = math.max(tonumber(gSubString) or 0)
	end
	return value
end

function ConvertYearToEra(startYear)
	local startEra = 0
	local bEraMod_6T = false
	if GameInfo.Eras["ERA_6T_POST_CLASSICAL"] then 
		bEraMod_6T = true 
		print("Historical Spawn Dates has detected the 6T Era Mod. Era values will be adjusted where necessary.")
	end
	if not bEraMod_6T then
		if startYear < -1600 then
			print("Start year less than -1600. Converting to Ancient Era")
			startEra = 0
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 100 and startYear >= -1600 then
			print("Start year between -1600 and 100. Converting to  Classical Era")
			startEra = 1
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1300 and startYear >= 100 then
			print("Start year between 100 and 1300. Converting to Medieval Era")
			startEra = 2
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1600 and startYear >= 1300 then
			print("Start year between 1300 and 1600. Converting to Renaissance Era")
			startEra = 3
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1800 and startYear >= 1600 then
			print("Start year between 1600 and 1800. Converting to Industrial Era")
			startEra = 4
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1950 and startYear >= 1800 then
			print("Start year between 1800 and 1950. Converting to Modern Era")
			startEra = 5
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1980 and startYear >= 1950 then
			print("Start year between 1950 and 1980. Converting to Atomic Era")
			startEra = 6
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 2020 and startYear >= 1980 then
			print("Start year between 1980 and 2020. Converting to Information Era")
			startEra = 7
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear >= 2020 then
			print("Start year greater than 2020. Converting to Future Era")
			startEra = 8
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
	else
		if startYear < -1600 then
			print("Start year less than -1600. Converting to Ancient Era")
			startEra = 0
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < -300 and startYear >= -1600 then
			print("Start year between -1600 and -300. Converting to  Classical Era")
			startEra = 1
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 500 and startYear >= -300 then
			print("Start year between -300 and 500. Converting to Post-Classical Era")
			startEra = 2
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1200 and startYear >= 500 then
			print("Start year between 500 and 1200. Converting to Medieval Era")
			startEra = 3
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1600 and startYear >= 1200 then
			print("Start year between 1200 and 1600. Converting to Renaissance Era")
			startEra = 4
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1800 and startYear >= 1600 then
			print("Industrial Era detected")
			print("Start year between 1600 and 1800. Converting to Renaissance Era")
			startEra = 5
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1950 and startYear >= 1800 then
			print("Start year between 1800 and 1950. Converting to Modern Era")
			startEra = 6
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 1980 and startYear >= 1950 then
			print("Start year between 1950 and 1980. Converting to Atomic Era")
			startEra = 7
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear < 2020 and startYear >= 1980 then
			print("Start year between 1980 and 2020. Converting to Information Era")
			startEra = 8
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
		if startYear >= 2020 then
			print("Start year greater than 2020. Converting to Future Era")
			startEra = 9
			print("Start year is "..tostring(startYear)..". Converted to Era is "..tostring(startEra))
		end
	end
	return startEra
end

function ConvertYearToAnnoDomini(currentTurnYear)
	local calendarDateBC = false
	local calendarTurnString :string = "nil"
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

function RemoveEraBuildings()
	print("Calling RemoveEraBuildings() ...")
	print("Multiple copies of Era Buildings will be deleted ...")
	for iPlayer = 0, iMaxPlayersZeroIndex do
		local player = Players[iPlayer]
		if player and player:GetCities():GetCount() > 0 then
			-- local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
			-- print ("CivilizationTypeName is " .. tostring(CivilizationTypeName))
			local playerCities = player:GetCities()
			local buildingsToDestroy = {}
			for i, city in ipairs(playerCities) do
				for kEra in GameInfo.Eras() do
					local EraBuilding = GameInfo.Buildings["BUILDING_CENTER_"..tostring(kEra.EraType)]
					if EraBuilding and city:GetBuildings():HasBuilding(EraBuilding.Index) then
						table.insert(buildingsToDestroy, EraBuilding.Index)
					end
				end
				if #buildingsToDestroy > 1 then
					for i, eraBuildingIndex in ipairs(buildingsToDestroy) do
						if (i < #buildingsToDestroy) and city:GetBuildings():HasBuilding(eraBuildingIndex) then
							city:GetBuildings():RemoveBuilding(eraBuildingIndex)
							print("Deleting extra Era Building #"..tostring(i).." from city...")
						end
					end
				end
			end
		end
	end
end

-- ===========================================================================
-- Notification Messages
-- ===========================================================================
function ShowLoadingPopup()
	local aPlayers = PlayerManager.GetAliveMajors()
	for loop, pPlayer in ipairs(aPlayers) do
		if pPlayer:IsHuman() then
			local pPlayerID = pPlayer:GetID()
			local CivilizationTypeName = PlayerConfigurations[pPlayerID]:GetCivilizationTypeName()
			local LeaderTypeName = PlayerConfigurations[pPlayerID]:GetLeaderTypeName()
			local spawnYear = spawnDates[LeaderTypeName] or spawnDates[CivilizationTypeName] or defaultStartYear
			local spawnEra 	= spawnEras[LeaderTypeName] or spawnEras[CivilizationTypeName] or defaultStartEra
			if bHistoricalSpawnEras then
				if spawnEra and (spawnEra > Game.GetEras():GetCurrentEra()) then
					local eventKey = GameInfo.EventPopupData["HSD_LOADING_POPUP"].Type
					local eventEffectString = Locale.Lookup("LOC_HSD_LOADING_MESSAGE", GameInfo.Leaders[LeaderTypeName].Name, GameInfo.Eras[spawnEra].Name)
					ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = pPlayer:GetID(), EventKey = eventKey, EventEffect = eventEffectString })
				end
			elseif(not bHistoricalSpawnEras) then
				if spawnYear and (spawnYear > currentTurnYear) then
					local eventKey = GameInfo.EventPopupData["HSD_LOADING_POPUP"].Type
					local eventEffectString = Locale.Lookup("LOC_HSD_LOADING_MESSAGE", GameInfo.Leaders[LeaderTypeName].Name, tostring(spawnYear))
					ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = pPlayerID, EventKey = eventKey, EventEffect = eventEffectString })
				end
			end
		end
	end
end

function ShowSpawnNotifications(iPlayer, startingPlot, newStartingPlot, CivilizationTypeName)
	local player = Players[iPlayer]
	local turnYearString :string = "nil"
	if bAnnoDomini then
		turnYearString = ConvertYearToAnnoDomini(currentTurnYear)
	else
		turnYearString = tostring(currentTurnYear)
	end
	if player:IsHuman() then
		if bNotifications then
			local adjective = Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_ADJECTIVE")
			if(#Notifications_revoltingCityPlots > 0) then
				for _, freeCityPlot in ipairs(Notifications_revoltingCityPlots) do
					local freeCity = Cities.GetCityInPlot(freeCityPlot)
					if freeCity then
						local freeCityMessage = "The noble cause of the "..adjective.." nation has encouraged the nearby city of "..Locale.Lookup(freeCity:GetName()).." to declare independance from its previous rulers!"
						NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, "Civil war erupts!", freeCityMessage, freeCity:GetX(), freeCity:GetY())								
					end
				end							
			end
		end
		return true
	else
		if bNotifications and bHistoricalSpawnEras then
			local name = "The "..Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_DESCRIPTION")
			local adjective = Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_ADJECTIVE")
			if(#Notifications_revoltingCityPlots > 0) then
				if newStartingPlot then 
					local messageNewPlot = "At the dawn of the "..Locale.Lookup("LOC_"..GameInfo.Eras[gameCurrentEra].EraType.."_NAME").." the "..adjective.." people ended centuries of foreign domination. "..name.." has emerged onto the world stage at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					-- local messageNewPlot = name.." has spawned at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", messageNewPlot, newStartingPlot:GetX(), newStartingPlot:GetY())
				else
					local message = "At the dawn of the "..Locale.Lookup("LOC_"..GameInfo.Eras[gameCurrentEra].EraType.."_NAME").." the "..adjective.." people ended centuries of foreign domination. "..name.." has emerged onto the world stage at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					-- local message = name.." has spawned at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", message, startingPlot:GetX(), startingPlot:GetY())
				end
				for _, freeCityPlot in ipairs(Notifications_revoltingCityPlots) do
					local freeCity = Cities.GetCityInPlot(freeCityPlot)
					if freeCity then
						local freeCityMessage = "The "..adjective.." rebellion caused the nearby city of "..Locale.Lookup(freeCity:GetName()).." to declare independance from its previous rulers!"
						NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, "Civil war erupts!", freeCityMessage, freeCity:GetX(), freeCity:GetY())								
					end
				end
			else
				if newStartingPlot then 
					local messageNewPlot = "At the dawn of the "..Locale.Lookup("LOC_"..GameInfo.Eras[gameCurrentEra].EraType.."_NAME").." the wandering "..adjective.." tribes unified under one ruler. "..name.." has emerged onto the world stage at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", messageNewPlot, newStartingPlot:GetX(), newStartingPlot:GetY())
				else
					local message = "At the dawn of the "..Locale.Lookup("LOC_"..GameInfo.Eras[gameCurrentEra].EraType.."_NAME").." the "..adjective.." tribes unified under one ruler. "..name.." has emerged onto the world stage at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", message, startingPlot:GetX(), startingPlot:GetY())
				end						
			end
		elseif(bNotifications and not bHistoricalSpawnEras) then
			local name = "The "..Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_DESCRIPTION")
			local adjective = Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_ADJECTIVE")
			if(#Notifications_revoltingCityPlots > 0) then
				if newStartingPlot then 
					local messageNewPlot = "In the year "..turnYearString.." the "..adjective.." people ended centuries of foreign domination. "..name.." has emerged onto the world stage at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					-- local messageNewPlot = name.." has spawned at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", messageNewPlot, newStartingPlot:GetX(), newStartingPlot:GetY())
				else
					local message = "In the year "..turnYearString.." the "..adjective.." people ended centuries of foreign domination. "..name.." has emerged onto the world stage at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					-- local message = name.." has spawned at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", message, startingPlot:GetX(), startingPlot:GetY())
				end
				for _, freeCityPlot in ipairs(Notifications_revoltingCityPlots) do
					local freeCity = Cities.GetCityInPlot(freeCityPlot)
					if freeCity then
						local freeCityMessage = "The "..adjective.." rebellion caused the nearby city of "..Locale.Lookup(freeCity:GetName()).." to declare independance from its previous rulers!"
						NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, "Civil war erupts!", freeCityMessage, freeCity:GetX(), freeCity:GetY())								
					end
				end
			else
				if newStartingPlot then 
					local messageNewPlot = "In the year "..turnYearString.." the wandering "..adjective.." tribes unified under one ruler. "..name.." has emerged onto the world stage at "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", messageNewPlot, newStartingPlot:GetX(), newStartingPlot:GetY())
				else
					local message = "In the year "..turnYearString.." the "..adjective.." tribes unified under one ruler. "..name.." has emerged onto the world stage at "..tostring(startingPlot:GetX())..", "..tostring(startingPlot:GetY())
					NotificationManager.SendNotification(Players[0], NotificationTypes.REBELLION, name.." emerges!", message, startingPlot:GetX(), startingPlot:GetY())
				end						
			end		
		end
		return true
	end
	return false
end

function Notification_FailedSpawn(iPlayer :number, pPlot :object, errorString :string)
	print(errorString)
	local aPlayers = PlayerManager.GetAliveMajors()
	for loop, pPlayer in ipairs(aPlayers) do
		if pPlayer:IsHuman() then
			NotificationManager.SendNotification(pPlayer, NotificationTypes.REBELLION, "Spawn Failed!", errorString, pPlot:GetX(), pPlot:GetY())
		end
	end
	return true
end

function Notification_GenericWithPlot(iPlayer :number, pPlot :object, headText :string, bodyText :string)
	print(tostring(headText).." : "..tostring(bodyText))
	local notification = false
	local aPlayers = PlayerManager.GetAliveMajors()
	for loop, pPlayer in ipairs(aPlayers) do
		if pPlayer:IsHuman() then
			notification = NotificationManager.SendNotification(pPlayer, NotificationTypes.REBELLION, headText, bodyText, pPlot:GetX(), pPlot:GetY())
		end
	end
	-- return notification
end

-- ===========================================================================
-- Build initialization tables when the script runs for the first time
-- ===========================================================================

-- Create list of civilizations
for iPlayer = 0, iMaxPlayersZeroIndex do
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
	local slotStatus = PlayerConfigurations[iPlayer]:GetSlotStatus()
	local reservePlayer = Game:GetProperty("ReservePlayer"..iPlayer)
	local originalPlayer = Game:GetProperty("OriginalPlayer"..iPlayer)
	if not ((slotStatus == 2) or (slotStatus == 5) or (slotStatus == nil)) and not reservePlayer then
		if CivilizationTypeName then isInGame[CivilizationTypeName] = true end
		if LeaderTypeName 		then isInGame[LeaderTypeName] 		= true end
		--Save the original player property at the beginning of the game but don't overwrite it later
		if not orginalPlayer then
			Game:SetProperty("OriginalPlayer"..iPlayer, 1)
		end
	else
		--Save the reserve player property at the beginning of the game but don't overwrite it later
		if not reservePlayer and not orginalPlayer then 
			Game:SetProperty("ReservePlayer"..iPlayer, 1)
			-- print("Reserving player slot for an uninitialized player")
		end
	end
end

print("Building spawn year table...")

-- Create list of spawn dates (Legacy support for old saves)
-- if not iSpawnDateTables and iLegacySpawnDates == 1 then
	-- print("Using Historical Spawn Dates for New World and Isolated Civs only (this is an old save)")
	-- for row in GameInfo.HistoricalSpawnDates_LiteMode() do
		-- if isInGame[row.Civilization]  then
			-- spawnDates[row.Civilization] = row.StartYear
			-- print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
		-- end
	-- end
-- elseif(not iSpawnDateTables and iLegacySpawnDates == 0) then
	-- --This will also activate in Eras mode is enabled but it will be ignored
	-- print("Using Historical Spawn Dates for all Civs (this is an old save or Spawn Eras have been selected)")
	-- for row in GameInfo.HistoricalSpawnDates() do
		-- if isInGame[row.Civilization]  then
			-- spawnDates[row.Civilization] = row.StartYear
			-- print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
		-- end
	-- end
-- end

function SetSpawnYears()
	if bInputHSD then
		print("Using manually entered dates from the advanced setup menu")
		for row in GameInfo.Civilizations() do
			if isInGame[row.CivilizationType]  then
				local inputHSD = MapConfiguration.GetValue('HSD_'..row.CivilizationType)
				if inputHSD then
					local value = ConvertStringToYear(inputHSD)
					print(tostring(row.CivilizationType), " spawn year = ", tostring(value))
					spawnDates[row.CivilizationType] = value
				else
					-- print("Start date is invalid!")
				end
			end
		end
		for row in GameInfo.Leaders() do
			if isInGame[row.LeaderType]  then
				local inputHSD = MapConfiguration.GetValue('HSD_'..row.LeaderType)
				if inputHSD then
					local value = ConvertStringToYear(inputHSD)
					print(tostring(row.LeaderType), " spawn year = ", tostring(value))
					spawnDates[row.LeaderType] = value
				else
					-- print("Start date is invalid!")
				end
			end
		end
	elseif(bLiteMode) then
		print("Lite Mode activated for Spawn Dates")
		for row in GameInfo.HistoricalSpawnDates_LiteMode() do
			if isInGame[row.Civilization]  then
				if bSavedSpawnDates then
					if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
						spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
						print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
					else
						spawnDates[row.Civilization] = row.StartYear
						print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
						Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
					end
				else
					spawnDates[row.Civilization] = row.StartYear
					print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
					Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
				end
			end
		end	
	elseif(iSpawnDateTables == 0) then
		print("Standard timeline selected")
		for row in GameInfo.HistoricalSpawnDates() do
			if isInGame[row.Civilization]  then
				if bSavedSpawnDates then
					if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
						spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
						print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
					else
						spawnDates[row.Civilization] = row.StartYear
						print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
						Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
					end
				else
					spawnDates[row.Civilization] = row.StartYear
					print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
					Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)				
				end
			end
		end
	elseif(iSpawnDateTables == 1) then
		print("True Historical Start timeline selected")
		for row in GameInfo.HistoricalSpawnDates_TrueHSD() do
			if isInGame[row.Civilization]  then
				if bSavedSpawnDates then
					if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
						spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
						print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
					else
						local iStartYear = ExposedMembers.GetStandardTimeline(row.Civilization)
						spawnDates[row.Civilization] = iStartYear
						-- spawnDates[row.Civilization] = row.StartYear
						print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
						Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
					end				
				else
					spawnDates[row.Civilization] = row.StartYear
					print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
					Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)				
				end
			end
		end
		print("Checking for missing start dates")
		for iPlayer = 0, iMaxPlayersZeroIndex do
			local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
			local reservePlayer = Game:GetProperty("ReservePlayer"..iPlayer)
			if CivilizationTypeName and not spawnDates[CivilizationTypeName] and not reservePlayer then
				print("Detected missing start date. Referring to Standard Timeline")
				print("CivilizationTypeName is "..tostring(CivilizationTypeName).." and spawnDates[CivilizationTypeName] is "..tostring(spawnDates[CivilizationTypeName]))
				local bMissingSpawnDate = true
				while bMissingSpawnDate do 
					for row in GameInfo.HistoricalSpawnDates() do
						if row.Civilization == CivilizationTypeName  then
							if bSavedSpawnDates then
								if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
									spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
									print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
									bMissingSpawnDate = false
								else
									spawnDates[row.Civilization] = row.StartYear
									print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
									Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
									bMissingSpawnDate = false
								end	
							else
								spawnDates[row.Civilization] = row.StartYear
								print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
								Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
								bMissingSpawnDate = false						
							end
						end
					end	
					if bMissingSpawnDate then
						print("Alternate starting date not found. Using default starting date")
						bMissingSpawnDate = false
					end
				end
			end		
		end
	elseif(iSpawnDateTables == 2) then
		print("Leader Start timeline selected")
		for row in GameInfo.HistoricalSpawnDates_LeaderHSD() do
			if isInGame[row.Civilization]  then
				if bSavedSpawnDates then
					if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
						spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
						print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
					else
						spawnDates[row.Civilization] = row.StartYear
						print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
						Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
					end				
				else
					spawnDates[row.Civilization] = row.StartYear
					print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
					Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)				
				end
			end
		end
		print("Checking for missing start dates")
		for iPlayer = 0, iMaxPlayersZeroIndex do
			local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
			local reservePlayer = Game:GetProperty("ReservePlayer"..iPlayer)
			if CivilizationTypeName and not spawnDates[CivilizationTypeName] and not reservePlayer then
				print("Detected missing start date. Referring to Standard Timeline")
				print("CivilizationTypeName is "..tostring(CivilizationTypeName).." and spawnDates[CivilizationTypeName] is "..tostring(spawnDates[CivilizationTypeName]))
				local bMissingSpawnDate = true
				while bMissingSpawnDate do 
					for row in GameInfo.HistoricalSpawnDates() do
						if row.Civilization == CivilizationTypeName  then
							if bSavedSpawnDates then
								if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
									spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
									print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
									bMissingSpawnDate = false
								else
									spawnDates[row.Civilization] = row.StartYear
									print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
									Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
									bMissingSpawnDate = false
								end	
							else
								spawnDates[row.Civilization] = row.StartYear
								print(tostring(row.Civilization), " spawn year = ", tostring(row.StartYear))
								Game.SetProperty("SpawnDate_"..tostring(row.Civilization), row.StartYear)
								bMissingSpawnDate = false						
							end
						end
					end	
					if bMissingSpawnDate then
						print("Alternate starting date not found. Using default starting date")
						bMissingSpawnDate = false
					end
				end
			end		
		end
	end
end

function GetHSD(iSpawnDateTables, civilizationType)
	local iStartYear = false
	local timeline = tonumber(iSpawnDateTables)
	if not civilizationType then
		print("WARNING: The selected civilization is "..tostring(civilizationType))
		return false
	end
	if not timeline then
		print("WARNING: The timeline option is "..tostring(iSpawnDateTables))
		return false
	else
		-- print("Selected timeline number "..tostring(iSpawnDateTables))
	end
	if (timeline == 0) then
		-- print("Standard timeline selected")
		iStartYear = ExposedMembers.GetStandardTimeline(civilizationType)
	elseif(timeline == 1) then
		-- print("True Start timeline selected")
		iStartYear = ExposedMembers.GetTrueHSDTimeline(civilizationType)
	elseif(timeline == 2) then
		-- print("Leader timeline selected")
		iStartYear = ExposedMembers.GetLeaderTimeline(civilizationType)
	end
	if bLiteMode then
		local eligibleForHSD = ExposedMembers.GetLitemodeCivs(civilizationType)
		if not eligibleForHSD then
			iStartYear = -4100
		end
	end
	if not iStartYear then
		print("GetHSD() could not find a start year! Returning default start year")
		iStartYear = -4100
	end
	return iStartYear
end

function GetEraHSD(civilizationType)
	if not civilizationType then
		print("WARNING: The selected civilization is "..tostring(civilizationType))
		return false
	end
	local iStartEra = false
	iStartEra = ExposedMembers.GetEraTimeline(civilizationType)
	if bLiteMode then
		local eligibleForHSD = ExposedMembers.GetLitemodeCivs(civilizationType)
		if not eligibleForHSD then
			iStartEra = 0
		end
	end
	if not iStartEra then
		print("GetEraHSD() could not find a start era! Returning default start era")
		iStartEra = 0
	end
	return iStartEra
end

--Unused
function SetHSD(iSpawnDateTables, Civilization)
	local iStartYear = false
	local iStartEra = false
	if bHistoricalSpawnEras then --Global Variable
		--Era Based Timeline
		if bSavedSpawnDates then --Global Variable
			if Game.GetProperty("SpawnEra_"..tostring(Civilization)) then
				spawnEras[Civilization] = Game.GetProperty("SpawnEra_"..tostring(Civilization))
				print(tostring(Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(Civilization))), " (saved start era)")
			else
				iStartYear = GetHSD(iSpawnDateTables, Civilization)
				if iSpawnDateTables == 3 then
					iStartEra = GetEraHSD(row.CivilizationType)
				else
					iStartEra = ConvertYearToEra(iStartYear)
					if not iStartEra then
						print("Start date could not be converted to era! Using default era")
						iStartEra = 0
					end
				end
				spawnEras[Civilization] = iStartEra
				print(tostring(Civilization), " spawn era = ", tostring(iStartEra))
				Game.SetProperty("SpawnEra_"..tostring(Civilization), iStartEra)
			end
		else
			iStartYear = GetHSD(iSpawnDateTables, Civilization)
			if iSpawnDateTables == 3 then
				iStartEra = GetEraHSD(row.CivilizationType)
			else
				iStartEra = ConvertYearToEra(iStartYear)
				if not iStartEra then
					print("Start date could not be converted to era! Using default era")
					iStartEra = 0
				end
			end
			spawnEras[Civilization] = iStartEra
			print(tostring(Civilization), " spawn era = ", tostring(iStartEra))
			Game.SetProperty("SpawnEra_"..tostring(Civilization), iStartEra)
		end
	elseif(not bHistoricalSpawnEras) then --Global Variable
		--Year based timeline
		if bSavedSpawnDates then --Global Variable
			if Game.GetProperty("SpawnDate_"..tostring(Civilization)) then
				spawnDates[Civilization] = Game.GetProperty("SpawnDate_"..tostring(Civilization))
				print(tostring(Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(Civilization))), " (saved start date)")
			else
				iStartYear = GetHSD(iSpawnDateTables, Civilization)
				spawnDates[Civilization] = iStartYear
				print(tostring(Civilization), " spawn year = ", tostring(iStartYear))
				Game.SetProperty("SpawnDate_"..tostring(Civilization), iStartYear)
			end
		else
			iStartYear = GetHSD(iSpawnDateTables, Civilization)
			spawnDates[Civilization] = iStartYear
			print(tostring(Civilization), " spawn year = ", tostring(iStartYear))
			Game.SetProperty("SpawnDate_"..tostring(Civilization), iStartYear)
		end
	end
end

function GetTimelineOptions()
	if bInputHSD then
		print("User entered dates from the advanced setup menu")
		for row in GameInfo.Civilizations() do
			if isInGame[row.CivilizationType]  then
				local inputHSD = MapConfiguration.GetValue('HSD_'..row.CivilizationType)
				if inputHSD then
					local value = ConvertStringToYear(inputHSD)
					if bHistoricalSpawnEras then
						-- print("Spawn eras are enabled. Converting start year to era")
						local startEra = ConvertYearToEra(value)
						if (iSpawnDateTables == 3) then
							print("Era timeline detected. Using original values")
							startEra = value
						end						
						if startEra then
							spawnEras[row.CivilizationType] = startEra
							print(tostring(row.CivilizationType), " spawn era = ", tostring(startEra))
						else
							print("Start date could not be converted to era!")
						end
					elseif(not bHistoricalSpawnEras) then
						print(tostring(row.CivilizationType), " spawn year = ", tostring(value))
						spawnDates[row.CivilizationType] = value
					end
				else
					-- print("WARNING: Invalid start date for "..tostring(row.CivilizationType))
				end
			end
		end
		for row in GameInfo.Leaders() do
			if isInGame[row.LeaderType]  then
				local inputHSD = MapConfiguration.GetValue('HSD_'..row.LeaderType)
				if inputHSD then
					local value = ConvertStringToYear(inputHSD)
					if bHistoricalSpawnEras then
						-- print("Spawn eras are enabled. Converting start year to era")
						local startEra = ConvertYearToEra(value)
						if (iSpawnDateTables == 3) then
							print("Era timeline detected. Using original values")
							startEra = value
						end		
						if startEra then
							spawnEras[row.LeaderType] = startEra
							print(tostring(row.LeaderType), " spawn era = ", tostring(startEra))
						else
							print("Start date could not be converted to era!")
						end
					elseif(not bHistoricalSpawnEras) then
						print(tostring(row.LeaderType), " spawn year = ", tostring(value))
						spawnDates[row.LeaderType] = value
					end
				else
					-- print("WARNING: Invalid start date for "..tostring(row.LeaderType))
				end
			end
		end
	elseif(iSpawnDateTables) then
		if (iSpawnDateTables == 0) then
			print("Standard timeline selected")
			for row in GameInfo.HistoricalSpawnDates() do
				if isInGame[row.Civilization]  then
					-- SetHSD(iSpawnDateTables, row.Civilization)
					if bHistoricalSpawnEras then
						--Era Based Timeline
						local iStartEra = false
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
								spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								iStartEra = ConvertYearToEra(iStartYear)
								if not iStartEra then
									print("Start date could not be converted to era! Using default era")
									iStartEra = 0
								end
								spawnEras[row.Civilization] = iStartEra
								print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
								Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							iStartEra = ConvertYearToEra(iStartYear)
							if not iStartEra then
								print("Start date could not be converted to era! Using default era")
								iStartEra = 0
							end
							spawnEras[row.Civilization] = iStartEra
							print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
							Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
						end
					elseif(not bHistoricalSpawnEras) then
						--Year based timeline
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
								spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								spawnDates[row.Civilization] = iStartYear
								print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
								Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							spawnDates[row.Civilization] = iStartYear
							print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
							Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
						end
					end
				end
			end	
		elseif(iSpawnDateTables == 1) then
			print("True Start timeline selected")
			for row in GameInfo.HistoricalSpawnDates_TrueHSD() do
				if isInGame[row.Civilization]  then
					-- SetHSD(iSpawnDateTables, row.Civilization)
					if bHistoricalSpawnEras then
						--Era Based Timeline
						local iStartEra = false
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
								spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								iStartEra = ConvertYearToEra(iStartYear)
								if not iStartEra then
									print("Start date could not be converted to era! Using default era")
									iStartEra = 0
								end
								spawnEras[row.Civilization] = iStartEra
								print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
								Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							iStartEra = ConvertYearToEra(iStartYear)
							if not iStartEra then
								print("Start date could not be converted to era! Using default era")
								iStartEra = 0
							end
							spawnEras[row.Civilization] = iStartEra
							print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
							Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
						end
					elseif(not bHistoricalSpawnEras) then
						--Year based timeline
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
								spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								spawnDates[row.Civilization] = iStartYear
								print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
								Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							spawnDates[row.Civilization] = iStartYear
							print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
							Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
						end
					end
				end
			end	
		elseif(iSpawnDateTables == 2) then
			print("Leader timeline selected")
			for row in GameInfo.HistoricalSpawnDates_LeaderHSD() do
				if isInGame[row.Civilization]  then
					-- SetHSD(iSpawnDateTables, row.Civilization)
					if bHistoricalSpawnEras then
						--Era Based Timeline
						local iStartEra = false
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
								spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								iStartEra = ConvertYearToEra(iStartYear)
								if not iStartEra then
									print("Start date could not be converted to era! Using default era")
									iStartEra = 0
								end
								spawnEras[row.Civilization] = iStartEra
								print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
								Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							iStartEra = ConvertYearToEra(iStartYear)
							if not iStartEra then
								print("Start date could not be converted to era! Using default era")
								iStartEra = 0
							end
							spawnEras[row.Civilization] = iStartEra
							print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
							Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
						end
					elseif(not bHistoricalSpawnEras) then
						--Year based timeline
						if bSavedSpawnDates then
							if Game.GetProperty("SpawnDate_"..tostring(row.Civilization)) then
								spawnDates[row.Civilization] = Game.GetProperty("SpawnDate_"..tostring(row.Civilization))
								print(tostring(row.Civilization), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(row.Civilization))), " (saved start date)")
							else
								local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
								spawnDates[row.Civilization] = iStartYear
								print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
								Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
							end
						else
							local iStartYear = GetHSD(iSpawnDateTables, row.Civilization)
							spawnDates[row.Civilization] = iStartYear
							print(tostring(row.Civilization), " spawn year = ", tostring(iStartYear))
							Game.SetProperty("SpawnDate_"..tostring(row.Civilization), iStartYear)
						end
					end
				end
			end	
		elseif(iSpawnDateTables == 3) then
			print("Era timeline selected")
			for row in GameInfo.HistoricalSpawnEras() do
				if isInGame[row.Civilization]  then
					--Era Based Timeline
					local iStartEra = false
					if bSavedSpawnDates then
						if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
							spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
							print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
						else
							iStartEra = GetEraHSD(row.Civilization)
							spawnEras[row.Civilization] = iStartEra
							print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
							Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
						end
					else
						iStartEra = GetEraHSD(row.Civilization)
						spawnEras[row.Civilization] = iStartEra
						print(tostring(row.Civilization), " spawn era = ", tostring(iStartEra))
						Game.SetProperty("SpawnEra_"..tostring(row.Civilization), iStartEra)
					end
				end
			end	
		end
	end
	print("Checking for missing start dates")
	for iPlayer = 0, iMaxPlayersZeroIndex do
		local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
		local reservePlayer = Game:GetProperty("ReservePlayer"..iPlayer)
		if CivilizationTypeName and not bHistoricalSpawnEras and not spawnDates[LeaderTypeName] and not spawnDates[CivilizationTypeName] and not reservePlayer then
			print("Detected missing start date.")
			print("CivilizationTypeName is "..tostring(CivilizationTypeName).." and spawnDates[CivilizationTypeName] is "..tostring(spawnDates[CivilizationTypeName]))
			if bSavedSpawnDates then
				if Game.GetProperty("SpawnDate_"..tostring(CivilizationTypeName)) then
					spawnDates[CivilizationTypeName] = Game.GetProperty("SpawnDate_"..tostring(CivilizationTypeName))
					print(tostring(CivilizationTypeName), " spawn year = ", tostring(Game.GetProperty("SpawnDate_"..tostring(CivilizationTypeName))), " (saved start date)")
				else
					local iStartYear = GetHSD(iSpawnDateTables, CivilizationTypeName)
					spawnDates[CivilizationTypeName] = iStartYear
					print(tostring(CivilizationTypeName), " spawn year = ", tostring(iStartYear))
					Game.SetProperty("SpawnDate_"..tostring(CivilizationTypeName), iStartYear)
				end
			else
				local iStartYear = GetHSD(iSpawnDateTables, CivilizationTypeName)
				spawnDates[CivilizationTypeName] = iStartYear
				print(tostring(CivilizationTypeName), " spawn year = ", tostring(iStartYear))
				Game.SetProperty("SpawnDate_"..tostring(CivilizationTypeName), iStartYear)
			end
		end	
		if CivilizationTypeName and bHistoricalSpawnEras and not spawnEras[LeaderTypeName] and not spawnEras[CivilizationTypeName] and not reservePlayer then
			print("Detected missing start era.")
			print("CivilizationTypeName is "..tostring(CivilizationTypeName).." and spawnEras[CivilizationTypeName] is "..tostring(spawnEras[CivilizationTypeName]))
			local iStartEra = false
			if bSavedSpawnDates then
				if Game.GetProperty("SpawnEra_"..tostring(CivilizationTypeName)) then
					spawnEras[CivilizationTypeName] = Game.GetProperty("SpawnEra_"..tostring(CivilizationTypeName))
					print(tostring(CivilizationTypeName), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(CivilizationTypeName))), " (saved start era)")
				else
					local iStartYear = GetHSD(iSpawnDateTables, CivilizationTypeName)
					iStartEra = ConvertYearToEra(iStartYear)
					if not iStartEra then
						print("Start date could not be converted to era! Using default era")
						iStartEra = 0
					end
					spawnEras[CivilizationTypeName] = iStartEra
					print(tostring(CivilizationTypeName), " spawn era = ", tostring(iStartEra))
					Game.SetProperty("SpawnEra_"..tostring(CivilizationTypeName), iStartEra)
				end
			else
				local iStartYear = GetHSD(iSpawnDateTables, CivilizationTypeName)
				iStartEra = ConvertYearToEra(iStartYear)
				if not iStartEra then
					print("Start date could not be converted to era! Using default era")
					iStartEra = 0
				end
				spawnEras[CivilizationTypeName] = iStartEra
				print(tostring(CivilizationTypeName), " spawn era = ", tostring(iStartEra))
				Game.SetProperty("SpawnEra_"..tostring(CivilizationTypeName), iStartEra)
			end
		end
	end
end

-- Create list of spawn eras
-- print("Building spawn era table...")
-- if bInputHSD then
	-- print("Converting starting eras from manually entered dates in the advanced setup menu")
	-- for row in GameInfo.Civilizations() do
		-- if isInGame[row.CivilizationType]  then
			-- local inputHSD = MapConfiguration.GetValue('HSD_'..row.CivilizationType)
			-- if inputHSD then
				-- local value = ConvertStringToYear(inputHSD)
				-- local startEra = ConvertYearToEra(value)
				-- if startEra then
					-- spawnEras[row.CivilizationType] = startEra
					-- print(tostring(row.CivilizationType), " spawn era = ", tostring(startEra))
				-- else
					-- print("Start date could not be converted to era!")
				-- end
			-- else
				-- -- print("Start date is invalid!")
			-- end
		-- end
	-- end
	-- for row in GameInfo.Leaders() do
		-- if isInGame[row.LeaderType]  then
			-- local inputHSD = MapConfiguration.GetValue('HSD_'..row.LeaderType)
			-- if inputHSD then
				-- local value = ConvertStringToYear(inputHSD)
				-- local startEra = ConvertYearToEra(value)
				-- if startEra then
					-- spawnEras[row.LeaderType] = startEra
					-- print(tostring(row.LeaderType), " spawn era = ", tostring(startEra))
				-- else
					-- print("Start date could not be converted to era!")
				-- end
			-- else
				-- -- print("Start date is invalid!")
			-- end
		-- end
	-- end
-- elseif(bLiteMode) then
	-- print("Lite Mode activated for Spawn Eras")
	-- for row in GameInfo.HistoricalSpawnEras_LiteMode() do
		-- if isInGame[row.Civilization]  then
			-- if bSavedSpawnDates then
				-- if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
					-- spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
					-- print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
				-- else
					-- spawnEras[row.Civilization] = row.Era
					-- print(tostring(row.Civilization), " spawn era = ", tostring(row.Era))
					-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), row.Era)
				-- end	
			-- else
				-- spawnEras[row.Civilization] = row.Era
				-- print(tostring(row.Civilization), " spawn era = ", tostring(row.Era))
				-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), row.Era)			
			-- end
		-- end
	-- end
-- else
	-- print("Historical Spawn Eras selected")
	-- for row in GameInfo.HistoricalSpawnEras() do
		-- if isInGame[row.Civilization]  then
			-- if bSavedSpawnDates then
				-- if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
					-- spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
					-- print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
				-- else
					-- spawnEras[row.Civilization] = row.Era
					-- print(tostring(row.Civilization), " spawn era = ", tostring(row.Era))
					-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), row.Era)
				-- end
			-- else
				-- spawnEras[row.Civilization] = row.Era
				-- print(tostring(row.Civilization), " spawn era = ", tostring(row.Era))
				-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), row.Era)
			-- end
		-- end
	-- end
	-- print("Checking for missing start eras")
	-- for iPlayer = 0, iMaxPlayersZeroIndex do
		-- local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		-- local reservePlayer = Game:GetProperty("ReservePlayer"..iPlayer)
		-- if CivilizationTypeName and not spawnEras[CivilizationTypeName] and not reservePlayer then
			-- print("Detected missing start era. Referring to Standard Timeline")
			-- print("CivilizationTypeName is "..tostring(CivilizationTypeName).." and spawnEras[CivilizationTypeName] is "..tostring(spawnEras[CivilizationTypeName]))
			-- local bMissingSpawnEra = true
			-- while bMissingSpawnEra do 
				-- for row in GameInfo.HistoricalSpawnDates() do
					-- if row.Civilization == CivilizationTypeName  then
						-- local startEra = ConvertYearToEra(row.StartYear)
						-- if startEra then
							-- if bSavedSpawnDates then
								-- if Game.GetProperty("SpawnEra_"..tostring(row.Civilization)) then
									-- spawnEras[row.Civilization] = Game.GetProperty("SpawnEra_"..tostring(row.Civilization))
									-- print(tostring(row.Civilization), " spawn era = ", tostring(Game.GetProperty("SpawnEra_"..tostring(row.Civilization))), " (saved start era)")
									-- bMissingSpawnEra = false
								-- else
									-- spawnEras[row.Civilization] = startEra
									-- print(tostring(row.Civilization), " spawn era = ", tostring(startEra))
									-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), startEra)
									-- bMissingSpawnEra = false
								-- end
							-- else
								-- spawnEras[row.Civilization] = startEra
								-- print(tostring(row.Civilization), " spawn era = ", tostring(startEra))
								-- Game.SetProperty("SpawnEra_"..tostring(row.Civilization), startEra)
								-- bMissingSpawnEra = false
							-- end
						-- end
					-- end
				-- end	
				-- if bMissingSpawnEra then
					-- print("Alternate starting era not found. Using default starting era")
					-- bMissingSpawnEra = false
				-- end
			-- end
		-- end		
	-- end
-- end

-- Create list of Civilizations that don't receive starting bonuses
print("Building isolated civilizations table...")
local isolatedCivs = {}
for row in GameInfo.IsolatedCivs() do
	if isInGame[row.Civilization] then
		isolatedCivs[row.Civilization] = true
		print("isolatedCivs = "..tostring(row.Civilization))
	end
end

-- Create list of Colonial Civilizations
print("Building colonial civilizations table...")
local ColonialCivs = {}
for row in GameInfo.ColonialCivs() do
	if isInGame[row.Civilization] then
		ColonialCivs[row.Civilization] = true
		print("ColonialCivs = "..tostring(row.Civilization))
	end
end

-- Create list of colonizers
print("Building list of colonizers...")
local colonizerCivs = {}
for row in GameInfo.ColonizerCivs() do
	if isInGame[row.Civilization] then
		colonizerCivs[row.Civilization] = true
		print("colonizerCivs = "..tostring(row.Civilization))
	end
end

-- Create list of players with restricted spawns who will only convert their capital
print("Building list of restricted spawn Civs...")
local restrictedSpawns = {}
for row in GameInfo.RestrictedSpawns() do
	if isInGame[row.Civilization] and bRestrictSpawnZone then
		restrictedSpawns[row.Civilization] = true
		print("restrictedSpawns = "..tostring(row.Civilization))
	end
end

-- Create list of players with peaceful spawns who will not declare war
print("Building list of peaceful spawn Civs...")
local peacefulSpawns = {}
for row in GameInfo.PeacefulSpawns() do
	if isInGame[row.Civilization] and bPeacefulSpawns then
		peacefulSpawns[row.Civilization] = true
		print("peacefulSpawns = "..tostring(row.Civilization))
	end
end

-- Create list of players with unique spawn zones
print("Building list of Civs with unique spawn zones...")
local uniqueSpawnZones = {}
for row in GameInfo.UniqueSpawnZones() do
	if isInGame[row.Civilization] and bUniqueSpawnZones then
		uniqueSpawnZones[row.Civilization] = true
		print("uniqueSpawnZones = "..tostring(row.Civilization))
	end
end

-- Create list of captured capitals
-- totalslacker: Not used for anything yet, needs to be called at the start of the game on load
print("Building occupied capitals table...")
local occupiedCapitals = {}
function CheckOriginalCapital(iPlayer)
	local pPlayer = Players[iPlayer]
	local pPlayerCities:table = pPlayer:GetCities()
	for i, pCity in pPlayerCities:Members() do
		local pPlayerID = pPlayer:GetID()
		local pCityID = pCity:GetID()
		local bOriginalCapital = ExposedMembers.CheckCityOriginalCapital(pPlayerID, pCityID)
		if pCity and bOriginalCapital then	
			occupiedCapitals[bOriginalCapital] = true	
			print("Found an occupied capital")
		end
	end
end

-- totalslacker: 	Unused function
--[[
-- Set Starting Plots
for iPlayer, position in ipairs(ExposedMembers.HistoricalStartingPlots) do
	local player = Players[iPlayer]
	if player then
		local startingPlot = Map.GetPlot(position.X, position.Y)
		player:SetStartingPlot(startingPlot)
	else
		print("WARNING: player #"..tostring(iPlayer) .." is nil for Set Starting Plots at ", position.X, position.Y)
	end
end
ExposedMembers.HistoricalStartingPlots = nil
--]]

-- ===========================================================================
-- Calendar related functions and state management, these run throughout the game
-- UI calls are made here
-- ===========================================================================

function SetPreviousTurnYear(year)
	previousTurnYear = year
end
LuaEvents.SetPreviousTurnYear.Add( SetPreviousTurnYear )

function SetCurrentTurnYear(year)
	currentTurnYear = year
end
LuaEvents.SetCurrentTurnYear.Add( SetCurrentTurnYear )

function SetNextTurnYear(year)
	nextTurnYear = year
end
LuaEvents.SetNextTurnYear.Add( SetNextTurnYear )

local StartingEra = {}
function GetStartingEra(iPlayer)
	print("------------")
	local key = "StartingEra"..tostring(iPlayer)
	local value = GameConfiguration.GetValue(key)
	print("StartingEra[iPlayer] = "..tostring(StartingEra[iPlayer]))
	print("GameConfiguration.GetValue("..tostring(key)..") = "..tostring(value))
	return StartingEra[iPlayer] or value or 0
end

function SetStartingEra(iPlayer, era)
	LuaEvents.SetStartingEra(iPlayer, era)	-- saved/reloaded
	StartingEra[iPlayer] = era 				-- to keep the value in the current session, GameConfiguration.GetValue in this context will only work after a save/load
end

-- ===========================================================================
-- Remove Civilizations that can't be spawned on start date
-- Called from the UI script on game load after the calendar functions are initializated
-- ===========================================================================

function InitializeHSD()
	if Game.GetCurrentGameTurn() ~= GameConfiguration.GetStartTurn() then
		LuaEvents.SetTurnYear(Game.GetCurrentGameTurn())
	end
	-- print("Setting the HSD")
	GetTimelineOptions()
	-- print("Setting the current era on game load")
	SetCurrentGameEra()
	-- print("Setting bonuses on load")
	SetCurrentBonuses()
	for iPlayer = 0, iMaxPlayersZeroIndex do
		local playerConfig = PlayerConfigurations[iPlayer]
		local slotStatus = playerConfig:GetSlotStatus()
		local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
		print("---------")
		print ("CivilizationTypeName is " .. tostring(CivilizationTypeName))	
		print ("LeaderTypeName is " .. tostring(LeaderTypeName))
		print ("slotStatus is "..tostring(slotStatus))
		if CivilizationTypeName and not (iPlayer == 62) and not (iPlayer == 63) and not ((slotStatus == 2) or (slotStatus == 5) or (slotStatus == nil)) then
			local player = Players[iPlayer]
			local spawnEra 	= spawnEras[LeaderTypeName] or spawnEras[CivilizationTypeName] or defaultStartEra
			local spawnYear = spawnDates[LeaderTypeName] or spawnDates[CivilizationTypeName] or defaultStartYear
			if bHistoricalSpawnEras then
				if spawnEras[LeaderTypeName] then
					print("Check "..tostring(LeaderTypeName)..", spawn era  = ".. tostring(spawnEra))		
				elseif(spawnEras[CivilizationTypeName]) then
					print("Check "..tostring(CivilizationTypeName)..", spawn era  = ".. tostring(spawnEra))		
				end
			else
				if spawnDates[LeaderTypeName] then
					print("Check "..tostring(LeaderTypeName)..", spawn year  = ".. tostring(spawnYear))
				elseif(spawnDates[CivilizationTypeName]) then
					print("Check "..tostring(CivilizationTypeName)..", spawn year  = ".. tostring(spawnYear))
				end
			end
			if bHistoricalSpawnEras and spawnEra and (spawnEra > gameCurrentEra) then
				if player then
					local playerUnits = player:GetUnits()
					local toKill = {}
					local offmapUnits = {}
					for i, unit in playerUnits:Members() do
						print("Found "..tostring(GameInfo.Units[unit:GetType()].UnitType).." at "..tostring(unit:GetX())..", "..tostring(unit:GetY()))
						if((unit:GetX() >= 0) or  (unit:GetY() >= 0)) then
							table.insert(toKill, unit)
						else
							table.insert(offmapUnits, unit)
						end
					end
					if (#offmapUnits < 1) then
						print("No settler detected off map. Spawning settler at (-1, -1) to keep the player alive until their spawn date...")
						UnitManager.InitUnit(player, "UNIT_SETTLER", -1, -1)
					elseif (#offmapUnits > 1) then
						print("There are "..tostring(#offmapUnits).." extra settlers off map. Deleting extra settlers...")
						for i, unit in ipairs(offmapUnits) do
							if (i < #offmapUnits) then
								playerUnits:Destroy(unit)
								print("Deleting extra off map unit #"..tostring(i).."...")
							end
						end	
					end
					if (#toKill > 0) then
						print("This player has units on the map before their spawn date. Deleting these units")
						for i, unit in ipairs(toKill) do
							playerUnits:Destroy(unit)
							-- print("Deleting unit for player spawn...")
						end	
					end
					if player:IsHuman() then
						LuaEvents.SetAutoValues()
					end
				end					
			elseif(not bHistoricalSpawnEras and spawnYear and (spawnYear > currentTurnYear)) then
				if player then
					local playerUnits = player:GetUnits()
					local toKill = {}
					local offmapUnits = {}
					for i, unit in playerUnits:Members() do
						if((unit:GetX() >= 0) or  (unit:GetY() >= 0)) then
							table.insert(toKill, unit)
						else
							table.insert(offmapUnits, unit)
						end
					end
					if (#offmapUnits < 1) then
						print("No settler detected off map. Spawning settler at (-1, -1) to keep the player alive until their spawn date...")
						UnitManager.InitUnit(player, "UNIT_SETTLER", -1, -1)
					elseif (#offmapUnits > 1) then
						print("There are "..tostring(#offmapUnits).." extra settlers off map. Deleting extra settlers...")
						for i, unit in ipairs(offmapUnits) do
							if (i < #offmapUnits) then
								playerUnits:Destroy(unit)
								print("Deleting extra off map unit #"..tostring(i).."...")
							end
						end	
					end
					if (#toKill > 0) then
						print("This player has units on the map before their spawn date. Deleting these units")
						for i, unit in ipairs(toKill) do
							playerUnits:Destroy(unit)
							-- print("Deleting unit for player spawn...")
						end	
					end
					if player:IsHuman() then
						LuaEvents.SetAutoValues()
					end
				end	
			end			
		end
	end
end
LuaEvents.InitializeHSD.Add(InitializeHSD)

-- ===========================================================================
-- Hard city conversion code from the Free City States mod, all credit goes to Tiramasu
-- totalslacker: 	It destroys and recreates the city. 
-- 					The city is different in game terms, such as original owner
-- ===========================================================================

-- ===========================================================================
-- Used to delete the starting settlers that are created offmap at (-1,-1)
-- Don't call until the player has founded a city or has new settlers!
-- ===========================================================================
function DeleteUnitsOffMap ( iPlayerID )
	local pUnits = Players[iPlayerID]:GetUnits();
	local pUnit;
	local bSettlerUnit = false
	for ii, pUnit in pUnits:Members() do
		local pUnitType = GameInfo.Units[pUnit:GetType()].UnitType
		if pUnitType == "UNIT_SETTLER" then
			bSettlerUnit = true
		end
		if (bSettlerUnit) and (pUnit:GetX() < 0 or  pUnit:GetY() < 0)  then
			UnitManager.Kill(pUnit, false)
		end
	end	
end

-- ===========================================================================
-- City conversion related code below, everything is called from the function ConvertCapital
-- ===========================================================================
local CityDataList = {}
function GetCityDatas ( pCity )
	local kCityDatas :table = {
		iTurn = Game.GetCurrentGameTurn(),
		iPosX = pCity:GetX(),
		iPosY = pCity:GetY(),
		iPop = pCity:GetPopulation()
	};	
	table.insert(CityDataList, kCityDatas)
end

function SetCityPopulation( pCity, iPopulation )
	if ( pCity ) then
		while pCity:GetPopulation() < iPopulation do
			pCity:ChangePopulation(1); --increase pop by +1
		end
	end
end

function SetCityDatas(iPlayer)	 	
	local pCities = Players[iPlayer]:GetCities()
	local pCity
	for ii, pCity in pCities:Members() do			
		for i, kCityDatas in pairs(CityDataList) do						
			if ( pCity:GetX() == kCityDatas.iPosX and pCity:GetY() == kCityDatas.iPosY ) then
				SetCityPopulation( pCity, kCityDatas.iPop )
			end	
			--table.remove(CityDataList, i) --dont remove items during loop!
		end
	end	
end

local CityUIDataList = {} 
function SetPlayerCityUIDatas( iPlayer )	
	local CityManager	= WorldBuilder.CityManager or ExposedMembers.CityManager
	local bInheritCityPlots = true
	local bInheritCityName = false
	for _,kCityUIDatas in pairs(CityUIDataList) do
		local pCities = Players[iPlayer]:GetCities();
		for _, pCity in pCities:Members() do
			if( pCity:GetX() == kCityUIDatas.iPosX and pCity:GetY() == kCityUIDatas.iPosY ) then 
				--Set City Name:
				if (bInheritCityName == true) then pCity:SetName(kCityUIDatas.sCityName); end		
				--Set City Tiles:
				if (bInheritCityPlots == true) then
					for _,kCoordinates in pairs(kCityUIDatas.CityPlotCoordinates) do
						local pPlot = Map.GetPlotByIndex(kCoordinates.plotID)
						if CityManager then
							if iPlayer ~= -1 then
								if pCity then
									CityManager():SetPlotOwner(kCoordinates.iX, kCoordinates.iY, false )
									CityManager():SetPlotOwner(kCoordinates.iX, kCoordinates.iY, iPlayer, pCity:GetID())
									local plotImprovementIndex = kCoordinates.plotImprovementIndex
									if plotImprovementIndex and GameInfo.Improvements[plotImprovementIndex] then
										ImprovementBuilder.SetImprovementType(pPlot, -1) 
										ImprovementBuilder.SetImprovementType(pPlot, plotImprovementIndex, iPlayer)
										print("Set a "..Locale.Lookup(GameInfo.Improvements[plotImprovementIndex].ImprovementType).." in converted city plot "..tostring(pPlot:GetIndex()))
									end
								end
							else
								CityManager():SetPlotOwner(kCoordinates.iX, kCoordinates.iY, false )
							end
						else
							if iPlayer ~= -1 then
								if pCity then
									Map.GetPlot(kCoordinates.iX,kCoordinates.iY):SetOwner(-1)
									Map.GetPlot(kCoordinates.iX,kCoordinates.iY):SetOwner(iPlayer, pCity:GetID(), true)
								end
							else
								Map.GetPlot(kCoordinates.iX,kCoordinates.iY):SetOwner(-1)
							end
						end
						-- Map.GetPlot(kCoordinates.iX,kCoordinates.iY):SetOwner(-1)
						-- Map.GetPlot(kCoordinates.iX,kCoordinates.iY):SetOwner(iPlayer, pCity:GetID(), true)
					end
				end
				--Set City Districts:								
				local pCityBuildQueue = pCity:GetBuildQueue();
				for _,kDistrictDatas in pairs(kCityUIDatas.CityDistricts) do 
					local plot = Map.GetPlot(kDistrictDatas.iPosX, kDistrictDatas.iPosY)
					local iDistrictType = kDistrictDatas.iType
					--Check if district exists in the unique districts table
					if GameInfo.DistrictReplaces[GameInfo.Districts[iDistrictType].DistrictType] then
						print("DistrictReplaces detected a "..tostring(GameInfo.Districts[iDistrictType].DistrictType))
						iDistrictType = GameInfo.DistrictReplaces[GameInfo.Districts[iDistrictType].DistrictType].ReplacesDistrictType
						print("Replaced with "..tostring(iDistrictType))
						iDistrictType = GameInfo.Districts[iDistrictType].Index
						print("Converted to number "..tostring(iDistrictType).." in the districts table.")
					end
					local iConstructionLevel = 100 --complete district					
					pCityBuildQueue:CreateIncompleteDistrict(iDistrictType, plot:GetIndex(), iConstructionLevel)
					--unfortunately we do not have any Lua function that can set a district to pillaged
				end		
				--Set City Buildings:
				for _,kBuildingData in pairs(kCityUIDatas.CityBuildings) do
					local iConstructionLevel = 100 --complete building
					local iBuildingID = kBuildingData.iBuildingID
					local bIsPillaged = kBuildingData.bIsPillaged
					pCityBuildQueue:CreateIncompleteBuilding(iBuildingID, iConstructionLevel)
					pCity:GetBuildings():SetPillaged(iBuildingID, bIsPillaged)
				end
				--Set Religious Pressures:
				for _,kReligionData in pairs(kCityUIDatas.CityReligions) do
					local iPressure = kReligionData.iPressure
					local iReligionType = kReligionData.iReligionType
					-- print("Setting " .. iPressure .. " pressure for Religion " .. iReligionType)
					local iSomeNumber = 0 --I dont know which value to use and probably it does not matter
					pCity:GetReligion():AddReligiousPressure(iSomeNumber, iReligionType , iPressure)
				end
			end			
		end		
	end
end

function ConvertCapital(iPlayer, startingPlot, pCityOwnerID, pCity)
	local pPlayer = Players[pCityOwnerID]
	local pPlayerID = pPlayer:GetID()
	if pCity then
		local pCityID = pCity:GetID()
		local iX, iY = pCity:GetX(), pCity:GetY()
		local plotUnits = Units.GetUnitsInPlot(startingPlot)
		if plotUnits ~= nil then
			local toKill = {}
			for i, unit in ipairs(plotUnits) do
				table.insert(toKill, unit)
			end
			for i, unit in ipairs(toKill) do
				local unitOwnerID = unit:GetOwner()
				local unitOwnerUnits = Players[unitOwnerID]:GetUnits()
				unitOwnerUnits:Destroy(unit)
			end					
		end		
		GetCityDatas(pCity)
		CityUIDataList = ExposedMembers.GetPlayerCityUIDatas(pPlayerID, pCityID)		
		Cities.DestroyCity(pCity) --destroy city before spawning city state units to prevent overlaps			
		Players[iPlayer]:GetCities():Create(iX, iY)
		SetCityDatas(iPlayer)
		SetPlayerCityUIDatas(iPlayer)
		return true
	end
	return false
end

-- ===========================================================================
-- Helper functions used in spawning the player
-- ===========================================================================

function FindSpawnPlotsByEra(startingPlot, iPlayer)
	local booleanReturnValue = false
	local permPlots = {}
	local curPlots = {}
	local nextPlots = {}
	local revoltCityPlots = {}
	local iShortestDistance = 0
	if gameCurrentEra < 4 then
		iShortestDistance = ((4 * (gameCurrentEra + 1)) / 2)
	else
		iShortestDistance = 6
	end
	-- print("Adding starting plot index to spawn zone table. Searching adjacent plots")
	table.insert(permPlots, startingPlot:GetIndex())
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(startingPlot:GetX(), startingPlot:GetY(), direction)
		if adjacentPlot and not adjacentPlot:IsWater() and not adjacentPlot:IsImpassable() then
			-- print("Adding index of adjacent plot "..tostring(adjacentPlot:GetX())..", "..tostring(adjacentPlot:GetY()).." to table")
			table.insert(permPlots, adjacentPlot:GetIndex())
			table.insert(curPlots, adjacentPlot:GetIndex())
		end
	end
	-- print("curPlots = "..tostring(#curPlots))
	local bAdjacentPlots = true
	while (bAdjacentPlots) do
		for j, iPlotIndex in ipairs(curPlots) do
			local pPlot = Map.GetPlotByIndex(iPlotIndex)
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
				if adjacentPlot and not adjacentPlot:IsWater() and not adjacentPlot:IsImpassable() then
					local bDuplicate = false
					for j, iPlotIndex in ipairs(permPlots) do
						if iPlotIndex == adjacentPlot:GetIndex() then
							bDuplicate = true
						end
					end
					if not bDuplicate then
						local iDistance = Map.GetPlotDistance(startingPlot:GetX(), startingPlot:GetY(), adjacentPlot:GetX(), adjacentPlot:GetY())
						if iDistance <= iShortestDistance then
							-- print("Adding index of adjacent plot "..tostring(adjacentPlot:GetX())..", "..tostring(adjacentPlot:GetY()).." to table")
							table.insert(permPlots, adjacentPlot:GetIndex())
							table.insert(nextPlots, adjacentPlot:GetIndex())
						end
					end
				end
			end
		end
		curPlots = {}
		-- print("curPlots = "..tostring(#curPlots))
		-- print("nextPlots = "..tostring(#nextPlots))
		-- print("permPlots = "..tostring(#permPlots))
		for j, iPlotIndex in ipairs(nextPlots) do
			local pPlot = Map.GetPlotByIndex(iPlotIndex)
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
				if adjacentPlot and not adjacentPlot:IsWater() and not adjacentPlot:IsImpassable() then
					local bDuplicate = false
					for j, iPlotIndex in ipairs(permPlots) do
						if iPlotIndex == adjacentPlot:GetIndex() then
							bDuplicate = true
						end
					end
					if not bDuplicate then
						local iDistance = Map.GetPlotDistance(startingPlot:GetX(), startingPlot:GetY(), adjacentPlot:GetX(), adjacentPlot:GetY())
						if iDistance <= iShortestDistance then
							-- print("Adding index of adjacent plot "..tostring(adjacentPlot:GetX())..", "..tostring(adjacentPlot:GetY()).." to table")
							table.insert(permPlots, adjacentPlot:GetIndex())
							table.insert(curPlots, adjacentPlot:GetIndex())
						end
					end
				end
			end
		end
		nextPlots = {}
		-- print("curPlots = "..tostring(#curPlots))
		-- print("nextPlots = "..tostring(#nextPlots))
		-- print("permPlots = "..tostring(#permPlots))
		if ((#curPlots == 0) and (#nextPlots == 0)) then
			print("No more adjacent plots in range")
			bAdjacentPlots = false
		elseif(#permPlots >= 127) then
			print("The maximum number of plots in a 6 hex range have been added to the table! We should stop here.")
			bAdjacentPlots = false
		end
	end
	-- print("Iterating through list of spawn plots and gathering all cities into table")
	for j, iPlotIndex in ipairs(permPlots) do
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		if pPlot then
			local isCity = false
			if pPlot:IsCity() ~= nil then isCity = pPlot:IsCity() end
			if isCity then
				local pCity = Cities.GetCityInPlot(pPlot)
				if pCity and (pCity:GetOwner() ~= iPlayer) then
					table.insert(revoltCityPlots, pPlot)
					-- print("New city plot found")
					-- print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
				end
			end	
		end
	end
	-- print("Iterating through list of cities and converting")
	if #revoltCityPlots > 0 then
		for j, pPlot in ipairs(revoltCityPlots) do
			local pCity = Cities.GetCityInPlot(pPlot)
			if pCity and (pCity:GetOwner() ~= iPlayer) and (pCity:GetOwner() ~= Players[62]) then
				local pPlayer = Players[pCity:GetOwner()]
				if pPlayer:GetCities() and (pPlayer:GetCities():GetCount() > 1) then
					booleanReturnValue = CityRebellion(pCity, iPlayer, pCity:GetOwner())
				end
			end
		end
	end
	return booleanReturnValue
end

-- Used when converting nearby cities to free cities
function FindClosestCityByEra(playerID, iStartX , iStartY)
    local pCity = false
	local iShortestDistance = 0
	if gameCurrentEra < 4 then
		iShortestDistance = ((4 * (gameCurrentEra + 1)) / 2)
	else
		iShortestDistance = 6
	end
	local pPlayer = Players[playerID]
	local pFreeCities = Players[62]
	if pPlayer:GetCities() and (pPlayer:GetCities():GetCount() > 1) and (pPlayer ~= pFreeCities) then
		local pPlayerCities:table = pPlayer:GetCities()
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
			if (iDistance < iShortestDistance) then
				pCity = pLoopCity
				iShortestDistance = iDistance
			end
		end
	end
	if not pCity then
		-- print ("No closest city found of player " .. tostring(playerID) .. " from " .. tostring(iStartX) .. ", " .. tostring(iStartX) .. ", distance of: " .. tostring(iShortestDistance))
	end	
    return pCity
end

function FindClosestCitiesByEra(playerID, iStartX, iStartY)
    local pCity = false
    local iShortestDistance = ((4 * (gameCurrentEra + 1)) / 2)
	local pPlayer = Players[playerID]
	local pFreeCities = Players[62]
	local revoltCities = {}
	if pPlayer and pPlayer:GetCities() and (pPlayer:GetCities():GetCount() > 1) and (pPlayer ~= pFreeCities) then
		local pPlayerCities:table = pPlayer:GetCities()
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
			if (iDistance < iShortestDistance) then
				pCity = pLoopCity
				table.insert(revoltCities, pCity)
			end
		end
	end
	if #revoltCities <= 0 then
		-- print ("No closest city found of player " .. tostring(playerID) .. " from " .. tostring(iStartX) .. ", " .. tostring(iStartX) .. ", distance of: " .. tostring(iShortestDistance))
		revoltCities = false
	end	
    return revoltCities
end

--Find the city that owns this plot
function FindClosestCityOfPlot(startingPlot)
	print("Calling FindClosestCityOfPlot...")
    local pCity = false
    local iShortestDistance = 10000;
	local plotOwnerID = startingPlot:GetOwner()
	print("plotOwnerID is "..tostring(plotOwnerID))
	if not plotOwnerID then	return false end
	if plotOwnerID == -1 then return false end
	local pPlayer = Players[plotOwnerID]
	local pPlayerCities:table = pPlayer:GetCities();
	for i, pLoopCity in pPlayerCities:Members() do
		local iDistance = Map.GetPlotDistance(startingPlot:GetX(), startingPlot:GetY(), pLoopCity:GetX(), pLoopCity:GetY());
		if (iDistance < iShortestDistance) then
			pCity = pLoopCity;
			iShortestDistance = iDistance;
		end
	end
	print("pCity is a city? "..tostring(pCity ~= false))
	print("returning pCity from FindClosestCityOfPlot")
    return pCity;
end

-- Used when selecting a new starting plot
function FindClosestCityDistance(iStartX, iStartY)
	local pCity = nullptr;
	local iShortestDistance = 10000;
	-- print("Finding closest city distance...")
	local aPlayers = PlayerManager.GetAlive();
	for loop, pPlayer in ipairs(aPlayers) do
		local pPlayerCities:table = pPlayer:GetCities();
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY());
			if iDistance and (iDistance < iShortestDistance) then
				pCity = pLoopCity;
				iShortestDistance = iDistance;
			end
		end
	end
	if (pCity == nullptr) then
		print ("FindClosestCityDistance() found no target city");
	end
    return iShortestDistance;
end

function FindClosestCityToPlotXY(iStartX, iStartY)
	local pCity = false;
	local iShortestDistance = 10000;
	-- print("Finding closest city distance...")
	local aPlayers = PlayerManager.GetAlive();
	for loop, pPlayer in ipairs(aPlayers) do
		local pPlayerCities:table = pPlayer:GetCities();
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY());
			if iDistance and (iDistance < iShortestDistance) then
				pCity = pLoopCity;
				iShortestDistance = iDistance;
			end
		end
	end
	if pCity then
		print ("FindClosestCityToPlotXY() found a target city");
	else
		print ("FindClosestCityToPlotXY() found no target city");
	end
    return pCity;
end

function FindClosestCitiesToPlotXY(iStartX, iStartY)
	local pCities = {}
	local iShortestDistance = 10000;
	-- print("Finding closest city distance...")
	local aPlayers = PlayerManager.GetAlive()
	for loop, pPlayer in ipairs(aPlayers) do
		local pPlayerCities:table = pPlayer:GetCities()
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
			if iDistance and (iDistance < iShortestDistance) then
				iShortestDistance = iDistance
			end
		end
	end
	-- print("Finding all cities at this distance...")
	for loop, pPlayer in ipairs(aPlayers) do
		local pPlayerCities:table = pPlayer:GetCities()
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
			if iDistance and (iDistance == iShortestDistance) then
				table.insert(pCities, pLoopCity)
			end
		end
	end
	if (#pCities > 0) then
		for i, pLoopCity in ipairs(pCities) do
			print("FindClosestCitiesToPlotXY() found a target city")
		end
	else
		print("FindClosestCitiesToPlotXY() found no target city")
		pCities = false
	end
    return pCities
end

-- Used by invasion logic
function FindClosestTargetCity(iAttackingPlayer, iStartX, iStartY)
	local pCity = nullptr;
	local iShortestDistance = 10000;
	local aPlayers = PlayerManager.GetAlive();
	for loop, pPlayer in ipairs(aPlayers) do
		local iPlayer = pPlayer:GetID();
		if (iPlayer ~= iAttackingPlayer and pPlayer:GetDiplomacy():IsAtWarWith(iAttackingPlayer)) then
			local pPlayerCities:table = pPlayer:GetCities();
			for i, pLoopCity in pPlayerCities:Members() do
				local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY());
				if (iDistance < iShortestDistance) then
					pCity = pLoopCity;
					iShortestDistance = iDistance;
				end
			end
		end
	end
	if (pCity == nullptr) then
		print ("No target city found for player " .. tostring(iAttackingPlayer) .. " from " .. tostring(iStartX) .. ", " .. tostring(iStartY));
	end
    return pCity;
end

function InitiateInvasions(player, startingPlot)
	local pAttacker = Players[player]
	local startingPlot = startingPlot
	-- local g_iInvaderX = pAttacker:GetStartingPlot():GetX()
	-- local g_iInvaderY = pAttacker:GetStartingPlot():GetY()
	local g_iInvaderX = startingPlot:GetX()
	local g_iInvaderY = startingPlot:GetY()
	local pNearestCity = FindClosestTargetCity(player, g_iInvaderX, g_iInvaderY);
	if (pNearestCity ~= nullptr) then
		local pMilitaryAI = pAttacker:GetAi_Military()
		if (pMilitaryAI ~= nullptr) then
			local iOperationID = pMilitaryAI:StartScriptedOperationWithTargetAndRally("Attack Enemy City", pNearestCity:GetOwner(), Map.GetPlot(pNearestCity:GetX(), pNearestCity:GetY()):GetIndex(), Map.GetPlot(g_iInvaderX, g_iInvaderY):GetIndex())
			local pUnits :table = pAttacker:GetUnits()	
			for i, pUnit in pUnits:Members() do
				pMilitaryAI:AddUnitToScriptedOperation(iOperationID, pUnit:GetID())
			end
			print("Target city found, starting invasion")
		end
	end
end

function ScorePlots(pPlot)
	local iScore = 0
	if pPlot:IsFreshWater() then 
		iScore = iScore + 100 
	end
	if (pPlot:GetResourceType() ~= -1) then
		iScore = iScore - 5
	end
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
		if (adjacentPlot) then
			if (adjacentPlot:GetResourceType() ~= -1) then
				iScore = iScore + 5
			end
		end
	end
	return iScore
end

function ScorePlotsByDistance(pPlot, startingPlot)
	local iScore = ScorePlots(pPlot)
	local iPlotDistance = Map.GetPlotDistance(pPlot:GetIndex(), startingPlot:GetIndex())
	if iPlotDistance then
		iScore = iScore - iPlotDistance
	end
	return iScore
end

function ScoreColonyPlot(pPlot)
	local iScore = 0
	local terrainClass :number = pPlot:GetTerrainClassType()
	if(terrainClass == ms_SnowTerrainClass) then
		iScore = iScore - 15
	end
	if(terrainClass == ms_TundraTerrainClass) then
		iScore = iScore - 5
	end
	if pPlot:IsFreshWater() then 
		iScore = iScore + 5 
	end
	if pPlot:IsRiver() then 
		iScore = iScore + 5 
	end
	if pPlot:IsCoastalLand() then
		iScore = iScore + 5
	end
	if (pPlot:GetResourceType() ~= -1) then
		iScore = iScore - 5
	end
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
		if (adjacentPlot) then
			if (adjacentPlot:GetResourceType() ~= -1) then
				iScore = iScore + 5
			end
			if(adjacentPlot:GetTerrainClassType() == ms_TundraTerrainClass) then
				iScore = iScore - 5
			end
			if(adjacentPlot:GetTerrainClassType() == ms_SnowTerrainClass) then
				iScore = iScore - 15
			end
			if(adjacentPlot:GetFeatureType() == g_FEATURE_ICE) then
				iScore = iScore - 15
			end
		end
	end
	return iScore
end

function ScoreColonyPlotsByDistance(pPlot, startingPlot)
	local iScore = ScoreColonyPlot(pPlot)
	local iPlotDistance = Map.GetPlotDistance(pPlot:GetIndex(), startingPlot:GetIndex())
	if iPlotDistance then
		iScore = iScore - iPlotDistance
	end
	return iScore
end

function ScoreColonyPlotsMostDistant(pPlot, startingPlot)
	local iScore = ScoreColonyPlot(pPlot)
	local iPlotDistance = Map.GetPlotDistance(pPlot:GetIndex(), startingPlot:GetIndex())
	if iPlotDistance then
		iScore = iScore + iPlotDistance
	end
	return iScore
end

--Default function to find a suitable spot for a city nearby. Returns the plot object only. Also used for scout placement
function PlayerBuffer(startingPlot)	
	local newStartingPlots = {}
	local selectedPlot = startingPlot
	local range = 3
	local plotX = startingPlot:GetX()
	local plotY = startingPlot:GetY()
	local plotScore = -100
	local tableEmpty = true
	local finalPass = false
	while (tableEmpty)
	do
		for dx = -range, range do
			for dy = -range, range do
				-- print("Searching for new starting plots...")
				local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
				if otherPlot and not bFinalPass then
					local impassable = otherPlot:IsImpassable()
					local isWater = otherPlot:IsWater()
					local isOwned = otherPlot:IsOwned()
					local isUnit  = otherPlot:IsUnit()
					if not impassable and not isWater and not isOwned and not isUnit then
						local iDistance = FindClosestCityDistance(otherPlot:GetX(), otherPlot:GetY())
						-- print("Plot: "..tostring(otherPlot:GetX())..", "..tostring(otherPlot:GetY()))
						-- print("iDistance: "..tostring(iDistance))
						if iDistance > 3 then
							table.insert(newStartingPlots, otherPlot)
							tableEmpty = false
							-- print("New starting plot found")
							-- print("Plot: "..tostring(otherPlot:GetX())..", "..tostring(otherPlot:GetY()))
							-- print("iDistance: "..tostring(iDistance))								
						end
					end
				elseif(otherPlot and bFinalPass) then
					local impassable = otherPlot:IsImpassable()
					local isWater = otherPlot:IsWater()
					local isOwned = otherPlot:IsOwned()
					local isUnit  = otherPlot:IsUnit()
					if not impassable and not isWater and not isOwned and not isUnit then
						-- print("Plot: "..tostring(otherPlot:GetX())..", "..tostring(otherPlot:GetY()))
						table.insert(newStartingPlots, otherPlot)
						tableEmpty = false
						-- print("New starting plot found")
						-- print("Plot: "..tostring(otherPlot:GetX())..", "..tostring(otherPlot:GetY()))
					end				
				end
			end
		end
		if tableEmpty then 
			range = range + 1 
		end
		if range >= iSpawnRange and not bFinalPass then
			bFinalPass = true
			range = 3
		elseif(range >= iSpawnRange and bFinalPass) then
			tableEmpty = false
		end
	end
	for j, plot in ipairs(newStartingPlots) do
		if plot then
			local iScore = ScorePlots(plot)
			if iScore > plotScore then 
				plotScore = iScore 
				selectedPlot = plot
			end
		end
	end
	if selectedPlot == startingPlot then
		-- print("WARNING: A new starting plot could not be found, returning original starting plot")
	end
	return selectedPlot
end

function GetUniqueSpawnZone(iPlayer, startingPlot)
	-- print("Initializing variables...")
	local pPlayer = Players[iPlayer]
	local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local continentPlotsIndexTable = {}
	local revoltCityPlots = {}
	local pContinentType = startingPlot:GetContinentType()
	local continentTypeName = GameInfo.Continents[pContinentType].ContinentType
	local maxY = ContinentDimensions[continentTypeName].maxY
	local spanY = ContinentDimensions[continentTypeName].spanY
	local lowerHalf = ContinentDimensions[continentTypeName].lowerHalf
	local maxX = ContinentDimensions[continentTypeName].maxX
	local spanX = ContinentDimensions[continentTypeName].spanX
	local rightHalf = ContinentDimensions[continentTypeName].rightHalf
	local baseX = ContinentDimensions[continentTypeName].baseX
	-- print("Iterating through list of spawn conditions based on civilization...")
	if (sCivTypeName == "CIVILIZATION_AUSTRALIA") then
		print("Convert all cities on Australian continent")
		--Iterate through list of continents in game to match to starting plot continent and gather plots
		local tContinents = Map.GetContinentsInUse()
		for i, iContinent in ipairs(tContinents) do
			print("Starting continent is "..tostring(GameInfo.Continents[pContinentType].ContinentType)..", checking continent is "..tostring(GameInfo.Continents[iContinent].ContinentType))
			if (GameInfo.Continents[iContinent].ContinentType == GameInfo.Continents[pContinentType].ContinentType) then
				print("Starting continent matches")
				continentPlotsIndexTable = Map.GetContinentPlots(iContinent)
			end
		end
		--Iterate through list of continent plots and gather all cities into table
		for j, iPlotIndex in ipairs(continentPlotsIndexTable) do
			local pPlot = Map.GetPlotByIndex(iPlotIndex)
			if pPlot then
				local isCity = false
				if pPlot:IsCity() ~= nil then isCity = pPlot:IsCity() end
				if isCity then
					local pCity = Cities.GetCityInPlot(pPlot)
					if pCity and (pCity:GetOwner() ~= iPlayer) then
						table.insert(revoltCityPlots, pPlot)
						print("New city plot found")
						print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
					end
				end	
			end
		end
		--Iterate through list of cities and convert
		if #revoltCityPlots > 0 then
			for j, pPlot in ipairs(revoltCityPlots) do
				local pCity = Cities.GetCityInPlot(pPlot)
				if pCity then
					CityRebellion(pCity, iPlayer, pCity:GetOwner())						
				end
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_CANADA") then
		print("Convert all cities north of Canada's start position and east of the continental divide")
		--Iterate through list of continents in game to match to starting plot continent and gather plots
		local tContinents = Map.GetContinentsInUse()
		for i, iContinent in ipairs(tContinents) do
			print("Starting continent is "..tostring(GameInfo.Continents[pContinentType].ContinentType)..", checking continent is "..tostring(GameInfo.Continents[iContinent].ContinentType))
			if (GameInfo.Continents[iContinent].ContinentType == GameInfo.Continents[pContinentType].ContinentType) then
				print("Starting continent matches")
				continentPlotsIndexTable = Map.GetContinentPlots(iContinent)
			end
		end
		--Iterate through list of continent plots and gather all cities into table (Canada's spawn zone includes all cities north of the starting plot and east of the continental divide)
		for j, iPlotIndex in ipairs(continentPlotsIndexTable) do
			local pPlot = Map.GetPlotByIndex(iPlotIndex)
			if pPlot then
				local isCity = false
				if pPlot:IsCity() ~= nil then isCity = pPlot:IsCity() end
				if isCity then
					if (pPlot:GetY() >= startingPlot:GetY()) and (((pPlot:GetX() > rightHalf) and (baseX < rightHalf)) or ((baseX > rightHalf) and ((pPlot:GetX() > rightHalf) and (pPlot:GetX() < baseX)))) then
						local pCity = Cities.GetCityInPlot(pPlot)
						if pCity and (pCity:GetOwner() ~= iPlayer) then
							table.insert(revoltCityPlots, pPlot)
							print("New city plot found")
							print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
						end
					end
				end	
			end
		end
		--Iterate through list of cities and convert (do not convert Cree cities)
		if #revoltCityPlots > 0 then
			for j, pPlot in ipairs(revoltCityPlots) do
				local pCity = Cities.GetCityInPlot(pPlot)
				if pCity and (PlayerConfigurations[pCity:GetOwner()]:GetCivilizationTypeName() ~= "CIVILIZATION_CREE") then
					CityRebellion(pCity, iPlayer, pCity:GetOwner())						
				end
			end
		end
	else
		print("This player does not have a unique spawn function! Reverting to default spawn function")
		FreeCityRevolt(iPlayer, startingPlot)
	end
end

function FindClosestStartingPlotByContinent(startingPlot)	
	local selectedPlot = startingPlot
	local pContinentType = startingPlot:GetContinentType()
	local continentPlots = {}
	local newStartingPlots = {}
	local iNumAreaPlots = 0
	local tContinents = Map.GetContinentsInUse()
	for i, iContinent in ipairs(tContinents) do
		print("Starting continent is "..tostring(GameInfo.Continents[pContinentType].ContinentType)..", checking continent is "..tostring(GameInfo.Continents[iContinent].ContinentType))
		if (GameInfo.Continents[iContinent].ContinentType == GameInfo.Continents[pContinentType].ContinentType) then
			print("Starting continent matches")
			continentPlots = Map.GetContinentPlots(iContinent)
			print("Number of continent plots is "..tostring(#continentPlots))
		end
	end
	--Check the plots in table continentPlots to create the list of new starting plots
	for j, iPlotIndex in ipairs(continentPlots) do
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		if pPlot then
			local impassable = true
			local isOwned = true
			local isDistanceReq = false
			if pPlot:IsImpassable() ~= nil then impassable = pPlot:IsImpassable() end
			if pPlot:IsOwned() ~= nil then isOwned = pPlot:IsOwned() end
			-- local isContinentSame = false
			-- print("ContinentType for plot is "..tostring(pPlot:GetContinentType()))
			-- if pPlot:GetContinentType() == pContinentType then isContinentSame = true end
			if not impassable and not isOwned then
				if Map.GetPlotDistance(pPlot:GetIndex(), startingPlot:GetIndex()) < iSpawnRange+1 then isDistanceReq = true end
				if isDistanceReq then
					local iCityDistance = FindClosestCityDistance(pPlot:GetX(), pPlot:GetY())
					if iCityDistance > 3 then
						table.insert(newStartingPlots, pPlot)
						print("New starting plot found")
						print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))
						print("iCityDistance: "..tostring(iCityDistance))								
					end
				end
			end		
		end
	end
	--Fallback if no new starting plots are found
	if #newStartingPlots < 1 and continentPlots then
		print("No new starting plots found. Attempting final pass without city distance check")
		for j, iPlotIndex in ipairs(continentPlots) do
			local pPlot = Map.GetPlotByIndex(iPlotIndex)
			if pPlot then
				local impassable = true
				local isOwned = true
				local isDistanceReq = false
				if pPlot:IsImpassable() ~= nil then impassable = pPlot:IsImpassable() end
				if pPlot:IsOwned() ~= nil then isOwned = pPlot:IsOwned() end
				if not impassable and not isOwned then
					if Map.GetPlotDistance(pPlot:GetIndex(), startingPlot:GetIndex()) < 10 then isDistanceReq = true end
					if isDistanceReq then
						table.insert(newStartingPlots, pPlot)
						print("New starting plot found (final pass)")
						print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))
					end
				end		
			end
		end		
	end
	--Score the table/list of new starting plots
	local plotScore = -100
	for j, pPlot in ipairs(newStartingPlots) do
		if pPlot then
			local iScore = ScorePlotsByDistance(pPlot, startingPlot)
			if iScore > plotScore then 
				plotScore = iScore 
				selectedPlot = pPlot
			end
		end
	end
	if selectedPlot == startingPlot then
		print("WARNING: A new starting plot could not be found, returning false")
		selectedPlot = false
	end
	return selectedPlot
end

--Give all players with HSD the Code of Laws civic to prevent issues with choosing a policy before spawning
--Use different methods for AI and Human players to prevent popups and allow the AI to progress
--Left the option open to give isolated players more starting civics in the code below
function GetStartingCivics (iPlayer, isolatedSpawn)
	local player = Players[iPlayer]
	local pCulture = player:GetCulture()
	if player and isolatedSpawn then
		if player:IsHuman() then
			player:GetCulture():SetCivic(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index, true)
		else
			local CultureCost  = pCulture:GetCultureCost(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index)
			pCulture:SetCulturalProgress(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index, CultureCost)
		end
		return true
	elseif(player) then
		if player:IsHuman() then
			player:GetCulture():SetCivic(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index, true)
		else
			local CultureCost  = pCulture:GetCultureCost(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index)
			pCulture:SetCulturalProgress(GameInfo.Civics["CIVIC_CODE_OF_LAWS"].Index, CultureCost)
		end
		return true
	end
	return false
end

-- ===========================================================================
-- Colonization Mode (also in ScenarioFunctions.lua)
-- ===========================================================================
function Colonization_OnTechLearned(iPlayer, pTech)
	local pPlayer = Players[iPlayer]
	local PlayerID = pPlayer:GetID()
	local bColonizationWave01 = Game.GetProperty("Colonization_Wave01_Player_#"..PlayerID)
	if bColonizationWave01 then return end
	local iCitiesOwnedByPlayer = pPlayer:GetCities():GetCount()
	-- print("iCitiesOwnedByPlayer is "..tostring(iCitiesOwnedByPlayer))
	if iCitiesOwnedByPlayer and (iCitiesOwnedByPlayer < 1) then
		return
	end
	if pPlayer:IsHuman() and not bPlayerColonies then
		return
	end
	local colonyPlot = false
	local sCivTypeName = PlayerConfigurations[PlayerID]:GetCivilizationTypeName()
	local bColonizer = false
	if colonizerCivs[sCivTypeName] then 
		bColonizer = true 
	end
	local bCartography = false
	if pPlayer:GetTechs():HasTech(GameInfo.Technologies["TECH_CARTOGRAPHY"].Index) then
		bCartography = true
	end
	if bColonizer and bCartography and (not bColonizationWave01) then
		--Spawn first colonies when cartography is discovered
		colonyPlot = InitiateColonization_FirstWave(PlayerID, sCivTypeName)
	end	
end

-- Used in Colonization mode (main functions are in ScenarioFunctions.lua)
function Colonization_OnPlayerEraChanged(PlayerID, iNewEraID)
	local pPlayer = Players[PlayerID]
	-- print("Era Changed for Player # " .. PlayerID )
	local bEraMod_6T = false
	local iEra = 0
	if GameInfo.Eras["ERA_6T_POST_CLASSICAL"] then 
		bEraMod_6T = true 
		-- print("Historical Spawn Dates has detected the 6T Era Mod. Era values will be adjusted where necessary.")
	end
	if bEraMod_6T then
		-- print("Increase the era count check for the additional era.")
		iEra = 1
	end
	local iCitiesOwnedByPlayer :number = pPlayer:GetCities():GetCount()
	-- print("iCitiesOwnedByPlayer is "..tostring(iCitiesOwnedByPlayer))
	if iCitiesOwnedByPlayer and (iCitiesOwnedByPlayer < 1) then
		return
	end
	if pPlayer:IsHuman() and not bPlayerColonies then
		return
	end
	local colonyPlot = false
	local sCivTypeName = PlayerConfigurations[PlayerID]:GetCivilizationTypeName()
	-- local sLeaderTypeName = PlayerConfigurations[PlayerID]:GetLeaderTypeName()
	-- local sCivTextName = Locale.Lookup(GameInfo.Civilizations[sCivTypeName].Name)
	-- local sLeaderTextName = Locale.Lookup(GameInfo.Leaders[sLeaderTypeName].Name)
	-- print("The player's Civilization is " .. sCivTextName)
	-- print("The player's Leader is " .. sLeaderTextName)
	local tEraGameInfo = GameInfo.Eras[iNewEraID]
	if (tEraGameInfo ~= nil) then
		local sEraTypeName = tEraGameInfo.EraType
		local sEraTextName = Locale.Lookup(tEraGameInfo.Name)
		-- print("The Player's new Era ID# (" .. iNewEraID .. ") matches to the " .. sEraTextName .. " Era (" .. sEraTypeName)
	else
		print("The GameInfo for " .. iNewEraID .. " retrieved a nil value: this should not be possible")
	end
	local bColonizer = false
	if colonizerCivs[sCivTypeName] then 
		bColonizer = true 
	end
	local bCartography = false
	if pPlayer:GetTechs():HasTech(GameInfo.Technologies["TECH_CARTOGRAPHY"].Index) then
		bCartography = true
	end
	local bColonizationWave01 = Game.GetProperty("Colonization_Wave01_Player_#"..PlayerID)
	local bColonizationWave02 = Game.GetProperty("Colonization_Wave02_Player_#"..PlayerID)
	local bColonizationWave03 = Game.GetProperty("Colonization_Wave03_Player_#"..PlayerID)
	if bColonizer and (iNewEraID >= (3 + iEra)) and bCartography and (not bColonizationWave01) then
		--Spawn first colonies starting during Renaissance Era
		colonyPlot = InitiateColonization_FirstWave(PlayerID, sCivTypeName)
		bColonizationWave01 = Game.GetProperty("Colonization_Wave01_Player_#"..PlayerID)
		-- if colonyPlot then
			-- Notification_NewColony(PlayerID, colonyPlot)
			-- print("Spawned a Renaissance era colony for "..tostring(sCivTypeName))
		-- else
			-- print("Failed to spawn a new colony")
		-- end
	end
	if bColonizer and (iNewEraID >= (4 + iEra)) and bCartography and bColonizationWave01 and (not bColonizationWave02) then
		--Spawn second wave of colonies starting during Industrial Era
		colonyPlot = InitiateColonization_SecondWave(PlayerID, sCivTypeName)
		bColonizationWave02 = Game.GetProperty("Colonization_Wave02_Player_#"..PlayerID)
		-- if colonyPlot then
			-- Notification_NewColony(PlayerID, colonyPlot)
			-- print("Spawned a Industrial era colony for "..tostring(sCivTypeName))
		-- else
			-- print("Failed to spawn a new colony")
		-- end
	end
	if bColonizer and (iNewEraID >= (5 + iEra)) and bCartography and bColonizationWave01 and bColonizationWave02 and (not bColonizationWave03) then
		--Spawn third wave of colonies starting during Modern Era
		colonyPlot = InitiateColonization_ThirdWave(PlayerID, sCivTypeName)
		bColonizationWave03 = Game.GetProperty("Colonization_Wave03_Player_#"..PlayerID)
		-- if colonyPlot then
			-- Notification_NewColony(PlayerID, colonyPlot)
			-- print("Spawned a Modern era colony for "..tostring(sCivTypeName))
		-- else
			-- print("Failed to spawn a new colony for "..tostring(sCivTypeName))
		-- end
	end
end

--Unused
function Colonization_OnGameEraChanged(previousEra, iNewEraID)
	print("Colonization mode is checking for new colonies to spawn...")
	for PlayerID = 0, iMaxPlayersZeroIndex do
		local pPlayer = Players[PlayerID]
		local iCitiesOwnedByPlayer :number = pPlayer:GetCities():GetCount()
		if iCitiesOwnedByPlayer and (iCitiesOwnedByPlayer < 1) then
			return
		end
		if pPlayer:IsHuman() and not bPlayerColonies then
			return
		end
		local colonyPlot = false
		local sCivTypeName = PlayerConfigurations[PlayerID]:GetCivilizationTypeName()
		local tEraGameInfo = GameInfo.Eras[iNewEraID]
		local bColonizer = false
		if colonizerCivs[sCivTypeName] then 
			bColonizer = true 
		end
		local bCartography = false
		if pPlayer:GetTechs():HasTech(GameInfo.Technologies["TECH_CARTOGRAPHY"].Index) then
			bCartography = true
		end
		local bColonizationWave01 = Game.GetProperty("Colonization_Wave01_Player_#"..PlayerID)
		local bColonizationWave02 = Game.GetProperty("Colonization_Wave02_Player_#"..PlayerID)
		local bColonizationWave03 = Game.GetProperty("Colonization_Wave03_Player_#"..PlayerID)
		if bColonizer and (iNewEraID >= 3) and bCartography and (not bColonizationWave01) then
			--Spawn first colonies starting during Renaissance Era
			colonyPlot = InitiateColonization_FirstWave(PlayerID, sCivTypeName)
			bColonizationWave01 = Game.GetProperty("Colonization_Wave01_Player_#"..PlayerID)
			if colonyPlot then
				Notification_NewColony(PlayerID, colonyPlot)
				print("Spawned a Renaissance era colony for "..tostring(sCivTypeName))
			else
				print("Failed to spawn a new colony")
			end
		end
		if bColonizer and (iNewEraID >= 4) and bCartography and bColonizationWave01 and (not bColonizationWave02) then
			--Spawn second wave of colonies starting during Industrial Era
			colonyPlot = InitiateColonization_SecondWave(PlayerID, sCivTypeName)
			bColonizationWave02 = Game.GetProperty("Colonization_Wave02_Player_#"..PlayerID)
			if colonyPlot then
				Notification_NewColony(PlayerID, colonyPlot)
				print("Spawned a Industrial era colony for "..tostring(sCivTypeName))
			else
				print("Failed to spawn a new colony")
			end
		end
		if bColonizer and (iNewEraID >= 5) and bCartography and bColonizationWave01 and bColonizationWave02 and (not bColonizationWave03) then
			--Spawn third wave of colonies starting during Modern Era
			colonyPlot = InitiateColonization_ThirdWave(PlayerID, sCivTypeName)
			bColonizationWave03 = Game.GetProperty("Colonization_Wave03_Player_#"..PlayerID)
			if colonyPlot then
				Notification_NewColony(PlayerID, colonyPlot)
				print("Spawned a Modern era colony for "..tostring(sCivTypeName))
			else
				print("Failed to spawn a new colony for "..tostring(sCivTypeName))
			end
		end
	end
end

-- ===========================================================================
-- Main functions for player spawns
-- ===========================================================================

function CityRebellion(pCity, playerID, otherPlayerID)
	local bRevolt = false
	local pPlayer = Players[playerID]
	local sCivTypeName = PlayerConfigurations[playerID]:GetCivilizationTypeName()
	if pCity and pPlayer and Players[otherPlayerID] then
		print("Calling CityRebellion()")
		local pCityID = pCity:GetID()
		-- print("pCityID = "..tostring(pCityID))
		local pFreeCityID = -1
		if bOverrideSpawn then
			print("bOverrideSpawn is "..tostring(bOverrideSpawn)..". Converting any city")
			pFreeCityID = pCityID
		elseif bConvertCities then
			if not (Players[otherPlayerID]:GetCities():GetCount() <= 1) then
				-- print("Detected non-capital city to convert in spawn zone")
				if bIgnoreGovernor then
					print("Skipping check for governor or original capital. Will not convert last city or capital.")
					local bCapital = ExposedMembers.CheckCityCapital(otherPlayerID, pCityID)
					if not bCapital then
						pFreeCityID = pCityID
					end
				else
					print("Checking city for governor or original capital")
					pFreeCityID = ExposedMembers.CheckCity.CheckCityGovernor(otherPlayerID, pCityID)
				end
			end
		else
			print("Checking city for governor or original capital")
			pFreeCityID = ExposedMembers.CheckCity.CheckCityGovernor(otherPlayerID, pCityID)
		end
		if pCityID == pFreeCityID then
			if not bSpawnZonesDisabled then
				if bConvertCities then
					local freeCityPlot = Map.GetPlot(pCity:GetX(), pCity:GetY())
					if freeCityPlot then
						local convertedCity = DirectCityConversion(playerID, freeCityPlot)
						if convertedCity then
							table.insert(Notifications_revoltingCityPlots, freeCityPlot)
							print("----------")
							print("Converting city to new player")
							print("----------")
							if (iUnitListType == 0) then
								CityUnits_Dynamic(playerID, freeCityPlot, gameCurrentEra)
							elseif(iUnitListType == 1) then
								CityUnits_Static(playerID, freeCityPlot, gameCurrentEra)
							end
							bRevolt = true
						end
					else
						print("freeCityPlot is "..tostring(freeCityPlot))
					end
				else
					local freeCityPlot = Map.GetPlot(pCity:GetX(), pCity:GetY())
					table.insert(Notifications_revoltingCityPlots, freeCityPlot)
					CityManager.TransferCityToFreeCities(pCity)
					print("----------")
					print("Converting city to the Free Cities")
					print("----------")
					bRevolt = true
				end
			elseif(bSpawnZonesDisabled) then
				print("Flip zones have been disabled. Declaring war on city owner")
				local pDiplomacy = pPlayer:GetDiplomacy()
				local iWar = WarTypes.FORMAL_WAR
				pDiplomacy:SetHasMet(otherPlayerID)
				if not peacefulSpawns[sCivTypeName] then
					local bCanWar = pDiplomacy:CanDeclareWarOn(otherPlayerID)
					if bCanWar and not (otherPlayerID == 62) then 
						pDiplomacy:DeclareWarOn(otherPlayerID, iWar, true) 
						print("War declared successfully")
					end	
				end
			end
		else
			print("City could not be converted to free cities. Declaring war on city owner")
			local pDiplomacy = pPlayer:GetDiplomacy()
			local iWar = WarTypes.FORMAL_WAR
			pDiplomacy:SetHasMet(otherPlayerID)
			if not peacefulSpawns[sCivTypeName] then
				local bCanWar = pDiplomacy:CanDeclareWarOn(otherPlayerID)
				if bCanWar and not (otherPlayerID == 62) then 
					pDiplomacy:DeclareWarOn(otherPlayerID, iWar, true) 
					print("War declared successfully")
				end	
			end
		end
	end	
	return bRevolt
end	

function FreeCityRevolt(playerID, startingPlot)
	local bRevolt = false
	local player = Players[playerID]
	--City States
	if not player:IsMajor() then
		if (player:GetCities():GetCount() >= 1) then
			print("City state detected with a starting city. Will not convert any more cities.")
			return bRevolt
		end
		print("City state detected without a starting city. One city in the spawn zone will revolt!")
		local aPlayers = PlayerManager.GetAlive()
		for loop, pPlayer in ipairs(aPlayers) do
			local iPlayer = pPlayer:GetID()
			if iPlayer == playerID then
				-- print("Don't convert your own cities!")
			else
				local pCity = FindClosestCityByEra(iPlayer, startingPlot:GetX(), startingPlot:GetY())
				if pCity then
					bRevolt = CityRebellion(pCity, playerID, iPlayer)
					if bRevolt then 
						return bRevolt 
					end
				end
			end
		end
		print("Could not convert a city in the spawn zone.")
		return bRevolt
	end
	--Major players
	if (iConvertSpawnZone == 0) then
		print("iConvertSpawnZone is "..tostring(iConvertSpawnZone)..". One city per player in the spawn zone will revolt!")
		local aPlayers = PlayerManager.GetAlive()
		for loop, pPlayer in ipairs(aPlayers) do
			local iPlayer = pPlayer:GetID()
			if iPlayer == playerID then
				-- print("Don't convert your own cities!")
			else
				local pCity = FindClosestCityByEra(iPlayer, startingPlot:GetX(), startingPlot:GetY())
				if pCity then
					bRevolt = CityRebellion(pCity, playerID, iPlayer)
				end
			end
		end
	elseif(iConvertSpawnZone == 1) then
		print("iConvertSpawnZone is "..tostring(iConvertSpawnZone)..". All cities in the spawn zone not separated by mountains or sea will revolt!")
		bRevolt = FindSpawnPlotsByEra(startingPlot, playerID)
	elseif(iConvertSpawnZone == 2) then
		print("iConvertSpawnZone is "..tostring(iConvertSpawnZone)..". All cities in the spawn zone will revolt!")
		local aPlayers = PlayerManager.GetAlive();
		for loop, pPlayer in ipairs(aPlayers) do
			local iPlayer = pPlayer:GetID()
			if iPlayer == playerID then
				-- print("Don't convert your own cities!")
			else
				local pPlayerCities = FindClosestCitiesByEra(iPlayer, startingPlot:GetX(), startingPlot:GetY())
				if pPlayerCities and (#pPlayerCities > 0) then
					for loop, pCity in ipairs(pPlayerCities) do
						bRevolt = CityRebellion(pCity, playerID, iPlayer)
					end
				end
			end
		end
	else
		print("iConvertSpawnZone was false. One city per player in the spawn zone will revolt!")
		local aPlayers = PlayerManager.GetAlive();
		for loop, pPlayer in ipairs(aPlayers) do
			local iPlayer = pPlayer:GetID()
			if iPlayer == playerID then
				-- print("Don't convert your own cities!")
			else
				local pCity = FindClosestCityByEra(iPlayer, startingPlot:GetX(), startingPlot:GetY())
				if pCity then
					bRevolt = CityRebellion(pCity, playerID, iPlayer)
				end
			end
		end
	end
	return bRevolt
end	

--Unused
function FreeCitiesRevoltArea(playerID, startingPlot)
	local bRevolt = false
	local revoltCityPlots = {}
	local range = 3
	local plotX = startingPlot:GetX()
	local plotY = startingPlot:GetY()
	local searchingArea = true
	while (searchingArea)
	do
		for dx = -range, range do
			for dy = -range, range do
				-- print("Searching for new revolt city plots...")
				local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
				if otherPlot and not revoltCityPlots[otherPlot] then
					local isCity  = otherPlot:IsCity()
					if isCity then
						local pCity = Cities.GetCityInPlot(otherPlot)
						if pCity then
							table.insert(revoltCityPlots, otherPlot)
							print("New city plot found")
							print("Plot: "..tostring(otherPlot:GetX())..", "..tostring(otherPlot:GetY()))							
						end
					end
				end
			end
		end
		if searchingArea then 
			range = range + 1 
		end
		if range > iSpawnRange then
			searchingArea = false
		end
	end
	if #revoltCityPlots > 0 then
		for j, pCityPlot in ipairs(revoltCityPlots) do
			local pCity = Cities.GetCityInPlot(pCityPlot)
			if pCity then
				local pCityOwnerID = pCity:GetOwner()
				if pCityOwnerID then
					bRevolt = CityRebellion(pCity, playerID, pCityOwnerID)
				end
			end
		end
	end
	return bRevolt
end

function DirectCityConversion(iPlayer, pPlot)
	local bConvertedCity = false
	local pPlayer = Players[iPlayer]
	local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if pPlayer and pPlot and pPlot:IsCity() then
		local pCity = Cities.GetCityInPlot(pPlot)
		local pCityOwnerID = pCity:GetOwner()
		local pDiplomacy = pPlayer:GetDiplomacy()
		local iWar = WarTypes.FORMAL_WAR
		pDiplomacy:SetHasMet(pCityOwnerID)
		local convertedCity = false
		if bConvertMode then
			print("Convert as New City option detected. City will be destroyed and recreated as an original city of the new player.")
			convertedCity = ConvertCapital(iPlayer, pPlot, pCityOwnerID, pCity)
		else
			print("Default city conversion selected. City will be marked as conquered from the original owner.")
			local temp = CityManager.TransferCity(pCity, iPlayer)	--will return false
		end
		local newCityOwnerID = Cities.GetCityInPlot(pPlot):GetOwner()
		if (pCityOwnerID ~= newCityOwnerID) then
			print("City has been converted!")
			local originalOwnerID = Cities.GetCityInPlot(pPlot):GetOriginalOwner()
			print("originalOwnerID is "..tostring(originalOwnerID))
			-- local checkOriginalCapital = ExposedMembers.CheckCityOriginalCapital(iPlayer, Cities.GetCityInPlot(pPlot):GetID())
			-- if checkOriginalCapital then 
				-- occupiedCapitals[checkOriginalCapital] = true 
				-- print("An original capital has been conquered by player "..tostring(iPlayer).." from player "..tostring(pCityOwnerID))
			-- else
				-- print("Check capital returned false")
			-- end
			if bRenameCapitals and (pPlayer:GetCities():GetCapitalCity():GetID() == Cities.GetCityInPlot(pPlot):GetID()) then
				local newCityName = false
				local results = DB.Query("SELECT * FROM CityNames")
				for i, row in ipairs(results) do
					if row.CivilizationType == PlayerConfigurations[newCityOwnerID]:GetCivilizationTypeName() then
						newCityName = row.CityName
						print(tostring(row.CivilizationType), " new capital name = ", tostring(row.CityName))
						-- print("The first city name in the list for a Civ is always the capital. Break the loop to stop searching now.")
						break
					end
				end
				-- print("Changing city name for capital city of new player to "..tostring(GameInfo.CityNames[PlayerConfigurations[newCityOwnerID]:GetCivilizationTypeName()]))
				Cities.GetCityInPlot(pPlot):SetName(newCityName)
			end
			convertedCity = true	
		end
		if convertedCity then
			if not peacefulSpawns[sCivTypeName] then
				local bCanWar = pDiplomacy:CanDeclareWarOn(pCityOwnerID)
				if bCanWar and not (pCityOwnerID == 62) then 
					pDiplomacy:DeclareWarOn(pCityOwnerID, iWar, true) 
					print("War declared successfully")
				end	
			end
			bConvertedCity = true	
		end
	end	
	return bConvertedCity
end

function ConvertInnerRingToCity(iPlayer, startingPlot)
	local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local adjacentPlots = {}
	local CityManager = WorldBuilder.CityManager or ExposedMembers.CityManager
	local pCity = Cities.GetCityInPlot(startingPlot)
	local bConvertSurroundingPlots = false
	--Check for restricted spawn where Civ will only convert capital
	local bRestrictedSpawn = false
	if restrictedSpawns[sCivTypeName] then 
		bRestrictedSpawn = true 
	end
	if bRestrictedSpawn and bRestrictSpawnZone then
		--If the restricted spawn zones option is enabled and the player is on the list
		bConvertSurroundingPlots = true
		print("Outer ring plots will be converted")
	end
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local adjacentPlot = Map.GetAdjacentPlot(startingPlot:GetX(), startingPlot:GetY(), direction)
		if adjacentPlot then
			local isOwned = false
			if adjacentPlot:IsOwned() then isOwned = true end
			if adjacentPlot and isOwned then
				local adjPlotOwnerID = adjacentPlot:GetOwner()
				if adjPlotOwnerID ~= iPlayer then
					local plotImprovementIndex = adjacentPlot:GetImprovementType()
					local plotDistrictIndex = adjacentPlot:GetDistrictType()
					local plotWonderIndex = adjacentPlot:GetWonderType()
					local bDistrictInPlot = false
					local bImprovementInPlot = false
					local bWonderInPlot = false
					if GameInfo.Improvements[plotImprovementIndex] then
						bImprovementInPlot = true
						print("Plot improvement detected: "..tostring(GameInfo.Improvements[plotImprovementIndex].ImprovementType))
					end
					if GameInfo.Districts[plotDistrictIndex] then
						bDistrictInPlot = true
						print("Plot district detected: "..tostring(GameInfo.Districts[plotDistrictIndex].DistrictType))
					end
					if GameInfo.Buildings[plotWonderIndex] then
						bWonderInPlot = true
						print("Plot wonder detected: "..tostring(GameInfo.Buildings[plotWonderIndex].BuildingType))
					end
					if CityManager and not bDistrictInPlot and not bWonderInPlot then
						CityManager():SetPlotOwner(adjacentPlot:GetX(), adjacentPlot:GetY(), false )
						CityManager():SetPlotOwner(adjacentPlot:GetX(), adjacentPlot:GetY(), iPlayer, pCity:GetID())	
						if bImprovementInPlot and ImprovementBuilder.CanHaveImprovement(adjacentPlot, plotImprovementIndex, -1) then
							ImprovementBuilder.SetImprovementType(adjacentPlot, -1) 
							ImprovementBuilder.SetImprovementType(adjacentPlot, plotImprovementIndex, iPlayer)
						end
						print("Converting inner ring plot to new city")	
					end	
				end
				table.insert(adjacentPlots, adjacentPlot)
			end
		end
	end	
	if bConvertSurroundingPlots then
		for j, pPlot in ipairs(adjacentPlots) do 
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
				if adjacentPlot then
					local isOwned = false
					if adjacentPlot:IsOwned() then isOwned = true end
					if adjacentPlot and isOwned then
						local adjPlotOwnerID = adjacentPlot:GetOwner()
						if adjPlotOwnerID ~= iPlayer then
							if CityManager then
								CityManager():SetPlotOwner(adjacentPlot:GetX(), adjacentPlot:GetY(), false )
								CityManager():SetPlotOwner(adjacentPlot:GetX(), adjacentPlot:GetY(), iPlayer, pCity:GetID())	
								print("Converting outer ring plot to new city")	
							end	
						end
					end
				end
			end					
		end
	end
end

function MoveStartingPlotUnits(plotUnits, startingPlot)
	for loop, pUnit in ipairs(plotUnits) do
		local pUnitOwnerID = pUnit:GetOwner()
		local pUnitOwner = Players[pUnitOwnerID]
		local pUnitType = GameInfo.Units[pUnit:GetType()].UnitType
		local bTrader = false
		if pUnitType == "UNIT_TRADER" then bTrader = true end
		if pUnitOwner:IsBarbarian() then
			UnitManager.Kill(pUnit)
			print("Killing barbarian unit to spawn player #"..tostring(iPlayer))
		elseif(not pUnitOwner:IsMajor() and not bTrader) then
			if (Game.GetCurrentGameTurn() ~= 1) then
				UnitManager.Kill(pUnit)
				print("Killing city-state unit or first-turn settler to spawn player #"..tostring(iPlayer))
			end							
		else
			--Major Players (Human and AI)
			if (Game.GetCurrentGameTurn() ~= 1) and not bTrader then
				local pCapital = pUnitOwner:GetCities():GetCapitalCity()
				local possibleSpawnPlots = {}
				local bNoAdjacentPlots = false
				for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
					local adjacentPlot = Map.GetAdjacentPlot(startingPlot:GetX(), startingPlot:GetY(), direction)
					if adjacentPlot and not adjacentPlot:IsWater() and not adjacentPlot:IsImpassable() and not adjacentPlot:IsUnit() then
						table.insert(possibleSpawnPlots, adjacentPlot)
					end
				end
				if (#possibleSpawnPlots > 0) then
					local randPlot = RandRange(1, #possibleSpawnPlots, "Selecting adjacent plot to move unit on spawn plot")
					UnitManager.PlaceUnit(pUnit, possibleSpawnPlots[randPlot]:GetX(), possibleSpawnPlots[randPlot]:GetY())
					print("A unit occupying a starting plot was moved to the nearest adjacent plot")
				else
					bNoAdjacentPlots = true
				end
				if bNoAdjacentPlots then
					if (pCapital ~= nil) then
						UnitManager.PlaceUnit(pUnit, pCapital:GetX(), pCapital:GetY());
						print("A unit occupying a starting plot was moved to the nearest owned city")
					else
						UnitManager.Kill(pUnit)
						print("A unit occupying a starting plot didn't have a city or nearby plot to move to and was killed")
					end
				end
			end
		end
	end				
end

function SpawnMajorPlayer(iPlayer, startingPlot, newStartingPlot)
	--Set variables
	local pPlayer = Players[iPlayer]
	local pPlotOwnerID = startingPlot:GetOwner()
	local iOtherPlayerCities = 0
	if Players[pPlotOwnerID] then
		iOtherPlayerCities = Players[pPlotOwnerID]:GetCities():GetCount()
	end
	local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local newStartingPlot = newStartingPlot
	if newStartingPlot and startingPlot:GetIndex() == newStartingPlot:GetIndex() then
		newStartingPlot = false
	end
	local bOwnerIsPlayer = false
	if pPlotOwnerID == iPlayer then bOwnerIsPlayer = true end
	--Try to convert the first city, or look for a plot nearby if not possible, or just spawn starting units after turn 10 if no city to convert
	if bConvertCities and startingPlot:IsCity() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		local convertedCity = DirectCityConversion(iPlayer, startingPlot)
		if convertedCity then
			if (iUnitListType == 0) then
				StartingUnits_Dynamic(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
			elseif(iUnitListType == 1) then
				StartingUnits_Static(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
			end
		else
			local errorString :string = "Failed to convert city to new player"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			if (iUnitListType == 0) then
				StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
			elseif(iUnitListType == 1) then
				StartingUnits_Static(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
			end
		end
	elseif bConvertCities and startingPlot:IsOwned() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		print("bConvertCities is true")
		print("Starting plot is owned. Searching for owner city to convert.")
		local cityFromPlot = FindClosestCityOfPlot(startingPlot)
		if cityFromPlot then
			local cityPlot = Map.GetPlot(cityFromPlot:GetX(), cityFromPlot:GetY())
			local convertedCity = DirectCityConversion(iPlayer, cityPlot)
			if convertedCity then
				if (iUnitListType == 0) then
					StartingUnits_Dynamic(iPlayer, cityPlot, gameCurrentEra, settlersBonus)
				elseif(iUnitListType == 1) then
					StartingUnits_Static(iPlayer, cityPlot, gameCurrentEra, settlersBonus)
				end
				newStartingPlot = cityPlot
			else
				local errorString :string = "Failed to convert city to new player"
				local errorMessage = Notification_FailedSpawn(iPlayer, cityPlot, errorString)
			end								
		else
			local errorString :string = "No city found for this plot!"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			if (iUnitListType == 0) then
				StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
			elseif(iUnitListType == 1) then
				StartingUnits_Static(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
			end
		end
	elseif(startingPlot:IsOwned() and not bOwnerIsPlayer) then
		print("Starting plot is owned. Searching for new starting plot.")
		newStartingPlot = PlayerBuffer(startingPlot)
		local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
		if plotUnits and #plotUnits > 0 then
			MoveStartingPlotUnits(plotUnits, newStartingPlot)
		end
		print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
		if (iUnitListType == 0) then
			StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
		elseif(iUnitListType == 1) then
			StartingUnits_Static(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
		end
	else
		if (Game.GetCurrentGameTurn() >= 10) then
			if (iUnitListType == 0) then
				StartingUnits_Dynamic(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
			elseif(iUnitListType == 1) then
				StartingUnits_Static(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
			end
		end
	end
	--Check for restricted spawn where Civ will only convert capital
	local bRestrictedSpawn = false
	if restrictedSpawns[sCivTypeName] then 
		bRestrictedSpawn = true 
	end
	--Check for unique spawn zones using defined spawn conditions
	local bUniqueSpawnZone = false
	if uniqueSpawnZones[sCivTypeName] then 
		bUniqueSpawnZone = true 
	end
	--Convert surrounding cities
	if bRestrictedSpawn then
		print("This player is in the restricted spawns list. Surrounding cities will NOT be converted.")
	elseif(bUniqueSpawnZone) then
		print("This player has a unique spawn zone.")
		GetUniqueSpawnZone(iPlayer, startingPlot)
	else
		if bSpawnRange and newStartingPlot then 
			FreeCityRevolt(iPlayer, newStartingPlot)
		else
			FreeCityRevolt(iPlayer, startingPlot)
		end
	end
	--AI invasions
	if not pPlayer:IsHuman() then
		if newStartingPlot then
			InitiateInvasions(iPlayer, newStartingPlot)
			print("Start scripted attack on nearest city if possible (starting plot has been relocated)")	
		else
			InitiateInvasions(iPlayer, startingPlot)
			print("Start scripted attack on nearest city if possible")							
		end
	end
	return newStartingPlot
end

function SpawnMinorPlayer(iPlayer, startingPlot, newStartingPlot)
	print("SpawnMinorPlayer initiated for player #"..tostring(iPlayer))
	--Set variables
	local pPlayer = Players[iPlayer]
	local pPlotOwnerID = startingPlot:GetOwner()
	local iOtherPlayerCities = 0
	if Players[pPlotOwnerID] then
		iOtherPlayerCities = Players[pPlotOwnerID]:GetCities():GetCount()
	end
	local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local newStartingPlot = newStartingPlot
	if newStartingPlot and startingPlot:GetIndex() == newStartingPlot:GetIndex() then
		newStartingPlot = false
	end
	local bOwnerIsPlayer = false
	if pPlotOwnerID == iPlayer then bOwnerIsPlayer = true end
	--Try to convert the first city, or look for a plot nearby if not possible, or just spawn starting units after turn 10 if no city to convert
	if bConvertCities and startingPlot:IsCity() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		local convertedCity = DirectCityConversion(iPlayer, startingPlot)
		if convertedCity then
			StartingUnits_Dynamic(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
		else
			local errorString :string = "Failed to convert city to new player"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
		end
	elseif bConvertCities and startingPlot:IsOwned() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		print("bConvertCities is true")
		print("Starting plot is owned. Searching for owner city to convert.")
		local cityFromPlot = FindClosestCityOfPlot(startingPlot)
		if cityFromPlot then
			local cityPlot = Map.GetPlot(cityFromPlot:GetX(), cityFromPlot:GetY())
			local convertedCity = DirectCityConversion(iPlayer, cityPlot)
			if convertedCity then
				StartingUnits_Dynamic(iPlayer, cityPlot, gameCurrentEra, settlersBonus)
				newStartingPlot = cityPlot
			else
				local errorString :string = "Failed to convert city to new player"
				local errorMessage = Notification_FailedSpawn(iPlayer, cityPlot, errorString)
				newStartingPlot = PlayerBuffer(startingPlot)
				local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
				if plotUnits and #plotUnits > 0 then
					MoveStartingPlotUnits(plotUnits, newStartingPlot)
				end
				print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			end								
		else
			local errorString :string = "No city found for this plot!"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
		end
	elseif(startingPlot:IsOwned() and not bOwnerIsPlayer) then
		print("Starting plot is owned. Searching for new starting plot.")
		newStartingPlot = PlayerBuffer(startingPlot)
		local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
		if plotUnits and #plotUnits > 0 then
			MoveStartingPlotUnits(plotUnits, newStartingPlot)
		end
		print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
		StartingUnits_Dynamic(iPlayer, newStartingPlot, gameCurrentEra, settlersBonus)
	else
		if (Game.GetCurrentGameTurn() >= 10) then
			StartingUnits_Dynamic(iPlayer, startingPlot, gameCurrentEra, settlersBonus)
		end
	end
	--Check for restricted spawn where Civ will only convert capital
	local bRestrictedSpawn = false
	if restrictedSpawns[sCivTypeName] then 
		bRestrictedSpawn = true 
	end
	--Check for unique spawn zones using defined spawn conditions
	local bUniqueSpawnZone = false
	if uniqueSpawnZones[sCivTypeName] then 
		bUniqueSpawnZone = true 
	end
	--Convert surrounding cities
	if bRestrictedSpawn then
		print("This player is in the restricted spawns list. Surrounding cities will NOT be converted.")
	elseif(bUniqueSpawnZone) then
		print("This player has a unique spawn zone.")
		GetUniqueSpawnZone(iPlayer, startingPlot)
	else
		if bSpawnRange and newStartingPlot then 
			FreeCityRevolt(iPlayer, newStartingPlot)
		else
			FreeCityRevolt(iPlayer, startingPlot)
		end
	end
	--AI invasions
	-- if not pPlayer:IsHuman() then
		-- if newStartingPlot then
			-- InitiateInvasions(iPlayer, newStartingPlot)
			-- print("Start scripted attack on nearest city if possible (starting plot has been relocated)")	
		-- else
			-- InitiateInvasions(iPlayer, startingPlot)
			-- print("Start scripted attack on nearest city if possible")							
		-- end
	-- end
	return newStartingPlot
end

function SpawnIsolatedPlayer(iPlayer, startingPlot, isolatedSpawn, CivilizationTypeName)
	local player = Players[iPlayer]
	local newStartingPlot = false
	local bCityTooClose = false
	local iShortestDistance = FindClosestCityDistance(startingPlot:GetX(), startingPlot:GetY())
	if iShortestDistance < 4 then	
		bCityTooClose = true
	end	
	local pPlotOwnerID = startingPlot:GetOwner()
	local bOwnerIsPlayer = false
	if pPlotOwnerID == iPlayer then bOwnerIsPlayer = true end
	local iOtherPlayerCities = 0
	if Players[pPlotOwnerID] then
		iOtherPlayerCities = Players[pPlotOwnerID]:GetCities():GetCount()
	end
	if bConvertCities and startingPlot:IsCity() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		local convertedCity = DirectCityConversion(iPlayer, startingPlot)
		if convertedCity then
			StartingUnits_Isolated(iPlayer, startingPlot, isolatedSpawn, CivilizationTypeName)
		else
			local errorString :string = "Failed to convert city to new player"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			StartingUnits_Isolated(iPlayer, newStartingPlot, isolatedSpawn, CivilizationTypeName)
		end
	elseif bConvertCities and startingPlot:IsOwned() and not bOwnerIsPlayer and ((iOtherPlayerCities > 1) or (pPlotOwnerID == 62)) then
		print("bConvertCities is true")
		print("Starting plot is owned. Searching for owner city to convert.")
		local cityFromPlot = FindClosestCityOfPlot(startingPlot)
		if cityFromPlot then
			local cityPlot = Map.GetPlot(cityFromPlot:GetX(), cityFromPlot:GetY())
			local convertedCity = DirectCityConversion(iPlayer, cityPlot)
			if convertedCity then
				StartingUnits_Isolated(iPlayer, cityPlot, isolatedSpawn, CivilizationTypeName)
				newStartingPlot = cityPlot
			else
				local errorString :string = "Failed to convert city to new player"
				local errorMessage = Notification_FailedSpawn(iPlayer, cityPlot, errorString)
				newStartingPlot = PlayerBuffer(startingPlot)
				local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
				if plotUnits and #plotUnits > 0 then
					MoveStartingPlotUnits(plotUnits, newStartingPlot)
				end
				print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
				StartingUnits_Isolated(iPlayer, newStartingPlot, isolatedSpawn, CivilizationTypeName)
			end								
		else
			local errorString :string = "No city found for this plot!"
			local errorMessage = Notification_FailedSpawn(iPlayer, startingPlot, errorString)
			newStartingPlot = PlayerBuffer(startingPlot)
			local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
			if plotUnits and #plotUnits > 0 then
				MoveStartingPlotUnits(plotUnits, newStartingPlot)
			end
			print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
			StartingUnits_Isolated(iPlayer, newStartingPlot, isolatedSpawn, CivilizationTypeName)
		end
	elseif(startingPlot:IsOwned() and not bOwnerIsPlayer) then
		print("Starting plot is owned. Searching for new starting plot.")
		newStartingPlot = PlayerBuffer(startingPlot)
		local plotUnits = Units.GetUnitsInPlot(newStartingPlot)
		if plotUnits and #plotUnits > 0 then
			MoveStartingPlotUnits(plotUnits, newStartingPlot)
		end
		print("New starting plot found: "..tostring(newStartingPlot:GetX())..", "..tostring(newStartingPlot:GetY()))
		StartingUnits_Isolated(iPlayer, newStartingPlot, isolatedSpawn, CivilizationTypeName)
	elseif(bCityTooClose) then
		StartingUnits_Isolated(iPlayer, startingPlot, isolatedSpawn, CivilizationTypeName)
	end
	if bSpawnRange and newStartingPlot then 
		FreeCityRevolt(iPlayer, newStartingPlot)
	else
		FreeCityRevolt(iPlayer, startingPlot)
	end
	if not player:IsHuman() then
		if newStartingPlot then
			InitiateInvasions(iPlayer, newStartingPlot)
			print("Start scripted attack on nearest city if possible (starting plot has been relocated)")	
		else
			InitiateInvasions(iPlayer, startingPlot)
			print("Start scripted attack on nearest city if possible")							
		end
	end
	return newStartingPlot
end

function SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
	local player = Players[iPlayer]
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local iTurn = Game.GetCurrentGameTurn()
	local startTurn = GameConfiguration.GetStartTurn()	
	local newStartingPlot = newStartingPlot
	local oceanStart = false
	local bDistanceCheck = true
	local colonialCivilization = false
	if ColonialCivs[CivilizationTypeName] then colonialCivilization = true end
	if startingPlot:IsWater() then oceanStart = true end
	if (player:GetCities():GetCount() >= 1) then
		print("Player already has a city.")
		return newStartingPlot
	end
	if oceanStart then
		--Ocean Start
		--Attempting to spawn a city broke the Maori ocean start bonus, always spawn settler instead
		UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
		return newStartingPlot
	end
	if startingPlot:IsOwned() then
		--Check if the player is the owner of the plot already (maybe converted a city previously)
		if (player:GetCities():GetCount() < 1) then
			print("Starting plot is owned. Moving starting settler.")
			if not newStartingPlot then
				newStartingPlot = PlayerBuffer(startingPlot)
				UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", newStartingPlot:GetX(), newStartingPlot:GetY())
			else
				UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", newStartingPlot:GetX(), newStartingPlot:GetY())
			end
		end
	elseif((iTurn ~= startTurn) and not startingPlot:IsOwned()) then
		if bDistanceCheck then
			local iShortestDistance = FindClosestCityDistance(startingPlot:GetX(), startingPlot:GetY())
			if (iShortestDistance > 3) then
				if not player:IsMajor() then
					--City states spawn a settler
					UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
				elseif((not colonialCivilization) and (not player:IsHuman())) then
					-- Major AI players spawn their first city automatically
					-- ImprovementBuilder.SetImprovementType(startingPlot, -1) --Not necessary 
					local city = player:GetCities():Create(startingPlot:GetX(), startingPlot:GetY())
					if not city then
						print("Failed to spawn starting city. Spawning settler instead.")
						UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
					end	
				else
					--Human players and Colonial Civs spawn a settler
					UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
				end
			elseif(iShortestDistance == 3) then
				print("iShortestDistance is "..tostring(iShortestDistance))
					--The code within this scope was meant to detect when a city could be founded on a starting plot that is an island
					--Island cities can be founded within 3 plots of a city on another landmass by default in Civ6
					--To check this you could use the GetAreaID() function on two plots and compare the AreaID integer to ensure they differ
					--Area seems to defined as connected landmass, independent of the continent property. This should allow islands to be detected
					--GetAreaID() does not always work as expected and can return different IDs for plots on the same landmass
					--This can cause a bug where civs spawn with territory but no city
					--Set bDifferentAreaIDs to false to bypass GetAreaID() and just spawn a settler every time instead
					local bDifferentAreaIDs = false
					local pCitiesInRange = FindClosestCitiesToPlotXY(startingPlot:GetX(), startingPlot:GetY())
					if pCitiesInRange then
						for i, pCity in ipairs(pCitiesInRange) do
							local pCityPlot = Map.GetPlotXY(pCity:GetX(), pCity:GetY())
							print("pCityPlot AreaID is "..tostring(pCityPlot:GetAreaID())..". startingPlot AreaID is "..tostring(startingPlot:GetAreaID()))
							if pCityPlot and (pCityPlot:GetAreaID() ~= startingPlot:GetAreaID()) then
								print("AreaIDs are different. Starting plot or other city is located on an island.")
							else
								bDifferentAreaIDs = false
								print("AreaIDs are the same. Cities are too close.")
							end
						end
						if bDifferentAreaIDs then
							local city = player:GetCities():Create(startingPlot:GetX(), startingPlot:GetY())
							if (player:GetCities():GetCount() < 1) then
								print("Failed to spawn starting city. Spawning settler instead.")
								UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
							end
						else
							print("Failed to spawn starting city. Spawning settler instead.")
							UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
						end
					else
						print("City within 3 plots of starting plot. Spawning starting settler in adjacent hex.")
						UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())			
					end

			elseif(iShortestDistance < 3) then
				--Distance must be 2 or less
				print("City within 3 plots of starting plot. Spawning starting settler in adjacent hex.")
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
			end
		else
			print("Distance Check is false (not recommended)")
			if not player:IsMajor() then
				UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
			elseif(not colonialCivilization) then
				-- Major players spawn their city here
				local city = player:GetCities():Create(startingPlot:GetX(), startingPlot:GetY())
				if (player:GetCities():GetCount() < 1) then
					print("Failed to spawn starting city. Spawning settler instead.")
					UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
				end
			else
				--Colonial Civs spawn a settler
				UnitManager.InitUnit(iPlayer, "UNIT_SETTLER", startingPlot:GetX(), startingPlot:GetY())
			end
		end
	elseif(iTurn == startTurn) then
		if not player:IsHuman() and player:IsMajor() then
			--Force AI players to found their first city automatically on turn 1
			local city = player:GetCities():Create(startingPlot:GetX(), startingPlot:GetY())
			if not city then
				print("Failed to spawn starting city.")
			else
				local playerUnits = player:GetUnits()
				local toKill = {}
				for i, unit in playerUnits:Members() do
					local pUnitType = GameInfo.Units[unit:GetType()].UnitType
					if pUnitType == "UNIT_SETTLER" then									
						table.insert(toKill, unit)
						print("Found first turn settler")
					end
				end
				for i, unit in ipairs(toKill) do
					playerUnits:Destroy(unit)
					print("Killing first turn settler")
				end
			end
		end
	end
	return newStartingPlot
end

function SpawnPlayer(iPlayer)
	local player = Players[iPlayer]
	local bPlayerSpawned = false
	local bBarbarian = false
	local bFreeCities = false
	if player:IsBarbarian() then bBarbarian = true end
	if iPlayer == 62 then bFreeCities = true end
	if bFreeCities or bBarbarian then
		-- print("Cannot spawn barbarian or free city players")
		return bPlayerSpawned
	end
	if player then
		local playerID = player:GetID()
		local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		local LeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
		local spawnYear = spawnDates[LeaderTypeName] or spawnDates[CivilizationTypeName] or defaultStartYear
		local spawnEra 	= spawnEras[LeaderTypeName] or spawnEras[CivilizationTypeName] or defaultStartEra
		local iTurn = Game.GetCurrentGameTurn()
		local playerEra = player:GetEras():GetEra()
		local isolatedPlayer = false
		local colonialPlayer = false
		if isolatedCivs[CivilizationTypeName] then isolatedPlayer = true end
		if ColonialCivs[CivilizationTypeName] then colonialPlayer = true end
		
		-- print("Check Spawning Date for ", tostring(CivilizationTypeName), "Start Year = ", tostring(spawnYear), "Previous Turn Year = ", tostring(previousTurnYear), "Current Turn Year = ", tostring(currentTurnYear))
		
		-- Give era score to civilizations before spawn		
		if bHistoricalSpawnEras and player:IsMajor() then
			if bGoldenAgeSpawn and spawnEra > Game.GetEras():GetCurrentEra() then
				Game:GetEras():ChangePlayerEraScore(playerID, 1)
			end
			if not bGoldenAgeSpawn and playerEra < currentEra and spawnEra > Game.GetEras():GetCurrentEra() then
				Game:GetEras():ChangePlayerEraScore(playerID, 1)
			end
			if spawnEra > Game.GetEras():GetCurrentEra() and (iTurn == 1) then
				GetStartingCivics(iPlayer, isolatedPlayer)
			end
		elseif(not bHistoricalSpawnEras and player:IsMajor()) then
			if bGoldenAgeSpawn and spawnYear > currentTurnYear then
				Game:GetEras():ChangePlayerEraScore(playerID, 1)
			end
			if not bGoldenAgeSpawn and playerEra < currentEra and spawnYear > currentTurnYear then
				Game:GetEras():ChangePlayerEraScore(playerID, 1)
			end
			if spawnYear > currentTurnYear and (iTurn == 1) then
				GetStartingCivics(iPlayer, isolatedPlayer)
			end
		end
		
		--Main Function
		if bHistoricalSpawnEras and spawnEra and (spawnEra <= gameCurrentEra) then
			local eraSpawnCheck = Game:GetProperty(playerID .. "EraSpawn" .. spawnEra)
			if not eraSpawnCheck then
				Game:SetProperty(playerID .. "EraSpawn" .. spawnEra, 1)
				-- print ("----------")
				-- print("Setting eraSpawnCheck for player has spawned")
				local startingPlot = player:GetStartingPlot()
				local newStartingPlot = false
				local cityPlot = false
				local oceanStart = false
				if startingPlot:IsWater() then oceanStart = true end
				
				--Prepare starting plot by removing units
				if not startingPlot:IsOwned() then
					local plotUnits = Units.GetUnitsInPlot(startingPlot)
					if plotUnits and #plotUnits > 0 then
						MoveStartingPlotUnits(plotUnits, startingPlot)
					end
				end
				
				print ("----------")
				print(" - Spawning", tostring(CivilizationTypeName), "Start Era = ", tostring(spawnEra), "at", startingPlot:GetX(), startingPlot:GetY())
				
				if bApplyBalance then
					if player:IsMajor() then
						if isolatedPlayer then
							newStartingPlot = SpawnIsolatedPlayer(iPlayer, startingPlot, isolatedPlayer, CivilizationTypeName)
							newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
						else
							GetStartingBonuses(player)
							newStartingPlot = SpawnMajorPlayer(iPlayer, startingPlot, newStartingPlot)
							newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
						end
					elseif(not player:IsMajor()) then
						GetStartingBonuses(player)
						if bCityStateRevolts then
							newStartingPlot = SpawnMinorPlayer(iPlayer, startingPlot, newStartingPlot)
							newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
						else
							newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
						end
					end	
				elseif not bApplyBalance then
					newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
				end
				
				--Spawn any extra units specific to this Civ or start
				StartingUnits_Extra(iPlayer, startingPlot, isolatedPlayer, CivilizationTypeName)
				
				--Delete hidden settler now that we have a city or units on the map, or the AI will never build more settlers
				DeleteUnitsOffMap(iPlayer)
				
				--Display ingame notifications
				ShowSpawnNotifications(iPlayer, startingPlot, newStartingPlot, CivilizationTypeName)
				
				--Clear list of revolting cities for notifications and restore the UI values for auto end turn for the human player
				Notifications_revoltingCityPlots = {}
				
				if player:IsHuman() then
					LuaEvents.RestoreAutoValues()
				end					
				bPlayerSpawned = true
			end
		elseif(spawnYear and not bHistoricalSpawnEras and (((spawnYear >= previousTurnYear) and (spawnYear < currentTurnYear)) or ((spawnYear <= previousTurnYear) and (Game.GetCurrentGameTurn() == GameConfiguration.GetStartTurn())))) then
			Game:SetProperty(playerID .. "_YearSpawn", currentTurnYear)
			local startingPlot = player:GetStartingPlot()
			local newStartingPlot = false
			local oceanStart = false
			if startingPlot:IsWater() then oceanStart = true end
			
			--Prepare starting plot by removing units
			if not startingPlot:IsOwned() then
				local plotUnits = Units.GetUnitsInPlot(startingPlot)
				if plotUnits and #plotUnits > 0 then
					MoveStartingPlotUnits(plotUnits, startingPlot)
				end
			end
			
			print ("----------")
			print(" - Spawning", tostring(CivilizationTypeName), "Start Year = ", tostring(spawnYear), "Previous Turn Year = ", tostring(previousTurnYear), "Current Turn Year = ", tostring(currentTurnYear), "at", startingPlot:GetX(), startingPlot:GetY())
	
			if bApplyBalance then
				if player:IsMajor() then
					if isolatedPlayer then
						newStartingPlot = SpawnIsolatedPlayer(iPlayer, startingPlot, isolatedPlayer, CivilizationTypeName)
						newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
					else
						GetStartingBonuses(player)
						newStartingPlot = SpawnMajorPlayer(iPlayer, startingPlot, newStartingPlot)
						newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
					end
				elseif not player:IsMajor() then
					GetStartingBonuses(player)
					if bCityStateRevolts then
						newStartingPlot = SpawnMinorPlayer(iPlayer, startingPlot, newStartingPlot)
						newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
					else
						newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
					end
				end	
			elseif not bApplyBalance then
				newStartingPlot = SpawnStartingCity(iPlayer, startingPlot, newStartingPlot)
			end
			
			--Spawn any extra units specific to this Civ or start
			StartingUnits_Extra(iPlayer, startingPlot, isolatedPlayer, CivilizationTypeName)
			
			--Delete hidden settler now that we have a city or units on the map, or the AI will never build more settlers
			DeleteUnitsOffMap(iPlayer)
			
			--Display ingame notifications
			ShowSpawnNotifications(iPlayer, startingPlot, newStartingPlot, CivilizationTypeName)
			
			--Clear list of revolting cities for notifications and restore the UI values for auto end turn for the human player
			Notifications_revoltingCityPlots = {}
			
			if player:IsHuman() then
				LuaEvents.RestoreAutoValues()
			end
			bPlayerSpawned = true			
		end
	else
		print("WARNING: player is nil in SpawnPlayer #"..tostring(iPlayer))
	end
	return bPlayerSpawned
end


function GetStartingBonuses(player)
	-- print(" - Starting era = "..tostring(gameCurrentEra))
	SetStartingEra(player:GetID(), gameCurrentEra)
	player:GetEras():SetStartingEra(gameCurrentEra)
	local playerID = player:GetID()
	local kEraBonuses = GameInfo.StartEras[gameCurrentEra]
	local CivilizationTypeName = PlayerConfigurations[playerID]:GetCivilizationTypeName()
	local iTechsLearned = 0
	local iCivicsLearned = 0

	-- gold
	local pTreasury = player:GetTreasury()
	local playerGoldBonus = goldBonus
	if gameCurrentEra > 0 and kEraBonuses.Gold then
		playerGoldBonus = playerGoldBonus + kEraBonuses.Gold
	end
	print(" - Gold bonus = "..tostring(playerGoldBonus))
	pTreasury:ChangeGoldBalance(playerGoldBonus)
	
	-- science
	local pScience = player:GetTechs()	
	for iTech, number in pairs(knownTechs) do
		-- print("Tech is "..Locale.Lookup(GameInfo.Technologies[iTech].Name.." - "..tostring(number)))
		if number >= minCivForTech then
			if player:IsHuman() then
				pScience:SetTech(iTech, true) --use SetTech() for human player to skip popups
				print(tostring(" - " .. Locale.Lookup(GameInfo.Technologies[iTech].Name)))
				if not pScience:HasTech(iTech) then
					print(" - Tech not detected after using SetTech(). Calling pScience:SetResearchProgress(iTech, ScienceCost)")
					local ScienceCost  = pScience:GetResearchCost(iTech)
					pScience:SetResearchProgress(iTech, ScienceCost)
				end
			elseif(not player:IsHuman()) then --the AI will not research new techs or civics if we use SetTech() or SetCivic()
				local ScienceCost  = pScience:GetResearchCost(iTech)
				pScience:SetResearchProgress(iTech, ScienceCost)
			end
			iTechsLearned = iTechsLearned + 1
		elseif(bTechCivicBoost) then
			if player:IsHuman() then
				pScience:SetTech(iTech, true)
				if not pScience:HasTech(iTech) then
					print(" - Tech not detected after using SetTech(). Calling pScience:SetResearchProgress(iTech, ScienceCost)")
					local ScienceCost  = pScience:GetResearchCost(iTech)
					pScience:SetResearchProgress(iTech, ScienceCost)
				end
			elseif(not player:IsHuman()) then
				local ScienceCost  = pScience:GetResearchCost(iTech)
				pScience:SetResearchProgress(iTech, ScienceCost)
			end
			iTechsLearned = iTechsLearned + 1
		else
			pScience:TriggerBoost(iTech)
			pScience:SetResearchingTech(iTech)
		end
	end	
	print(" - Science bonus = "..tostring(scienceBonus))
	pScience:ChangeCurrentResearchProgress(scienceBonus)
	
	-- culture
	local pCulture = player:GetCulture()
	for kCivic in GameInfo.Civics() do
		local iCivic	= kCivic.Index
		local value		= kCivic.value
		if knownCivics[iCivic] then
			if knownCivics[iCivic] >= minCivForCivic then
				if player:IsHuman() then 
					pCulture:SetCivic(iCivic, true) --use SetCivic() for human player to skip popups
				elseif(not player:IsHuman()) then --the AI will not research new techs or civics if we use SetTech() or SetCivic()
					local CultureCost  = pCulture:GetCultureCost(iCivic)
					pCulture:SetCulturalProgress(iCivic, CultureCost)
					pCulture:SetCivicCompletedThisTurn(true)
				end
				iCivicsLearned = iCivicsLearned + 1
			elseif(bTechCivicBoost) then
				if player:IsHuman() then
					pCulture:SetCivic(iCivic, true)
				elseif(not player:IsHuman()) then
					local CultureCost  = pCulture:GetCultureCost(iCivic)
					pCulture:SetCulturalProgress(iCivic, CultureCost)
					pCulture:SetCivicCompletedThisTurn(true)
				end
				iCivicsLearned = iCivicsLearned + 1
			else
				pCulture:TriggerBoost(iCivic)
			end
		elseif researchedCivics[iCivic] then
			pCulture:TriggerBoost(iCivic)
			-- local CultureCost  = pCulture:GetCultureCost(iCivic)
			-- pCulture:SetCulturalProgress(iCivic, CultureCost)
		end
	end	
	
	--When spawning city-states, we only need the information up to this point
	--End the function for city-states here
	if not player:IsMajor() then
		return
	end
	
	
	-- get starting governments
	if ColonialCivs[CivilizationTypeName] then
		if GameInfo.Eras["ERA_6T_POST_CLASSICAL"] then 
			print("Historical Spawn Dates has detected the 6T Era Mod. Checking for Enlightenment Government add-on.")
			if GameInfo.Governments["GOVERNMENT_JNR_REVOLUTIONARY"] then
				pCulture:UnlockGovernment(GameInfo.Governments["GOVERNMENT_JNR_REVOLUTIONARY"].Index)
				print("Revolutionary republic government unlocked for Colonial Civilization.")
			else
				print("Could not unlock government. GameInfo.Governments['GOVERNMENT_JNR_REVOLUTIONARY'] is "..tostring(GameInfo.Governments["GOVERNMENT_JNR_REVOLUTIONARY"]))
				if GameInfo.Governments["GOVERNMENT_DEMOCRACY"] then
					pCulture:UnlockGovernment(GameInfo.Governments["GOVERNMENT_DEMOCRACY"].Index)
					print("Democracy government unlocked for Colonial Civilization.")
				else
					print("Could not unlock government. GameInfo.Governments['GOVERNMENT_DEMOCRACY'] is "..tostring(GameInfo.Governments["GOVERNMENT_DEMOCRACY"]))
				end	
			end			
		else
			-- print("No era or government mods detected.")
			if GameInfo.Governments["GOVERNMENT_DEMOCRACY"] then
				pCulture:UnlockGovernment(GameInfo.Governments["GOVERNMENT_DEMOCRACY"].Index)
				print("Democracy government unlocked for Colonial Civilization.")
			else
				print("Could not unlock government. GameInfo.Governments['GOVERNMENT_DEMOCRACY'] is "..tostring(GameInfo.Governments["GOVERNMENT_DEMOCRACY"]))
			end	
		end
	end
	
	
	-- faith
	local playerFaithBonus = faithBonus
	if gameCurrentEra > 0 and kEraBonuses.Faith then
		playerFaithBonus = playerFaithBonus + kEraBonuses.Faith
	end
	print(" - Faith bonus = "..tostring(playerFaithBonus))
	player:GetReligion():ChangeFaithBalance(playerFaithBonus)
	
	-- token
	if player:IsHuman() and (gameCurrentEra > 0) then
		tokenBonus = tokenBonus + gameCurrentEra
	end
	print(" - Token bonus = "..tostring(tokenBonus))
	player:GetInfluence():ChangeTokensToGive(tokenBonus)
	
	-- Difficulty adjustment
	if iDifficulty > 4 then
		local iBonusDifficulty = iDifficulty - 4
		if iBonusDifficulty > 0 then
			for j = 1, iBonusDifficulty, 1 do
				player:GetReligion():ChangeFaithBalance(playerFaithBonus)
				print(" - Faith bonus from difficulty = "..tostring(playerFaithBonus))
				pTreasury:ChangeGoldBalance(playerGoldBonus)
				print(" - Gold bonus from difficulty = "..tostring(playerGoldBonus))
			end
			if player:IsHuman() and (gameCurrentEra > 0) then
				player:GetInfluence():ChangeTokensToGive(iBonusDifficulty)
				print(" - Token bonus from difficulty = "..tostring(iBonusDifficulty))
			end
		end
	end
	
	-- Dramatic Ages mode era score adjustment for learning techs and civics
	if bDramaticAges then
		if iTechsLearned and (iTechsLearned > 0) then
			print("iTechsLearned is "..tostring(iTechsLearned)..". Removing excess era score.")
			Game:GetEras():ChangePlayerEraScore(playerID, -iTechsLearned)
		end
		if iCivicsLearned and (iCivicsLearned > 0) then
			print("iCivicsLearned is "..tostring(iCivicsLearned)..". Removing excess era score.")
			Game:GetEras():ChangePlayerEraScore(playerID, -iCivicsLearned)
		end
	end
	
	-- Great Person Points
	if bGrantGPP and (gameCurrentEra > 0) then 
		--[[
			Breakdown of Great Person Points or GPPoints:
			
			(((gameCurrentEra * 4)^2 * 2) * (GameSpeedMultiplier / 100))
			
			Eras are 0 based... 0,1,2,3,4,5,6,7
			Starts in Classical (1)
			
			Classical Era: 	1 * 4 = 4 
							4^2 = 16
							16 * 2 = 32
							32 * (GameSpeedMultiplier / 100) = final value (32 at standard speed, 16 at online, 96 at marathon)
							
							Standard speed multiplier: 100 / 100 = 1
							Online: 50 / 100 = .5
							Marathon: 300 / 100 = 3			
		]]--
		--Default GPPoints
		local GPPoints = (((gameCurrentEra * 4)^2 * 2) * (GameSpeedMultiplier / 100))
		
		--Less GPP points for new era spawns starting in Medieval era
		if bHistoricalSpawnEras then
			if gameCurrentEra == 1 then
				GPPoints = (((gameCurrentEra * 4)^2 * 2) * (GameSpeedMultiplier / 100))
			elseif(gameCurrentEra == 2) then
				GPPoints = 2 * ((((gameCurrentEra-1) * 4)^2 * 2) * (GameSpeedMultiplier / 100))
			elseif((gameCurrentEra >= 3) and (gameCurrentEra < 5)) then
				GPPoints = ((((gameCurrentEra-1) * 4)^2 * 2) * (GameSpeedMultiplier / 100))
			elseif(gameCurrentEra >= 5) then
				GPPoints = 2 * ((((gameCurrentEra-1) * 4)^2 * 2) * (GameSpeedMultiplier / 100))
			end
		end
		
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatAdmiral, GPPoints)
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatGeneral, GPPoints)
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatMerchant, GPPoints)
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatProphet, GPPoints)
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatScientist, GPPoints)
		player:GetGreatPeoplePoints():ChangePointsTotal(iGreatWriter, GPPoints)	
		if gameCurrentEra > 1 then
			player:GetGreatPeoplePoints():ChangePointsTotal(iGreatEngineer, GPPoints)
		end
		if gameCurrentEra > 2 then
			player:GetGreatPeoplePoints():ChangePointsTotal(iGreatArtist, GPPoints)
		end
		if gameCurrentEra > 3 then
			player:GetGreatPeoplePoints():ChangePointsTotal(iGreatMusician, GPPoints)
		end
		print(" - GPP bonus: "..tostring(GPPoints))
	end
end

function SetCurrentBonuses()

	knownTechs		= {}
	knownCivics		= {}
	playersWithCity	= 0

	local totalScience 	= 0
	local totalCulture 	= 0
	local totalGold 	= 0
	local totalCities	= 0
	local totalToken	= 0
	local totalFaith	= 0
	
	for kEra in GameInfo.StartEras() do
		if kEra.Year and kEra.Year < currentTurnYear then
			local era = GameInfo.Eras[kEra.EraType].Index				
			if era > currentEra then
				print ("Changing current Era to current year's Era :" .. tostring(kEra.EraType))
				currentEra = era
			end		
		end
	end	
	
	for iPlayer = 0, iMaxPlayersZeroIndex do
		local player = Players[iPlayer]
		if player and player:IsMajor() and player:GetCities():GetCount() > 0 then
			local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
			-- print ("CivilizationTypeName is " .. tostring(CivilizationTypeName))		
			playersWithCity = playersWithCity + 1
			totalCities		= totalCities + player:GetCities():GetCount()
			
			
				
			-- Science	
			local pScience = player:GetTechs()
			totalScience = totalScience + pScience:GetResearchProgress( pScience:GetResearchingTech() )
			for kTech in GameInfo.Technologies() do		
				local iTech	= kTech.Index
				-- print(tostring(" -- kTech exists -- " .. Locale.Lookup(GameInfo.Technologies[iTech].Name)))
				if pScience:HasTech(iTech) then
					if not knownTechs[iTech] then
						-- print(tostring(" -- HasTech() -- " .. Locale.Lookup(GameInfo.Technologies[iTech].Name)))
						knownTechs[iTech] = 0 
					end
					knownTechs[iTech] = knownTechs[iTech] + 1
				end
			end
			
			-- Culture
			local pCulture = player:GetCulture()
			researchedCivics[pCulture:GetProgressingCivic()] = true
			for kCivic in GameInfo.Civics() do		
				local iCivic	= kCivic.Index
				if pCulture:HasCivic(iCivic) then
					if not knownCivics[iCivic] then knownCivics[iCivic] = 0 end
					knownCivics[iCivic] = knownCivics[iCivic] + 1
				end
			end
			
			-- Gold
			local pTreasury = player:GetTreasury()			
			totalGold = totalGold + pTreasury:GetGoldYield() + pTreasury:GetTotalMaintenance()			
			if pTreasury:GetGoldBalance() > 0 then
				totalGold = totalGold + pTreasury:GetGoldBalance()
			end
						
			-- Faith
			totalFaith = totalFaith + player:GetReligion():GetFaithYield()
			
			local playerUnits = player:GetUnits(); 	
			for i, unit in playerUnits:Members() do
				local unitInfo = GameInfo.Units[unit:GetType()];
				totalGold = totalGold + unitInfo.Cost
			end
			
			local era = player:GetEras():GetEra()
			if era > currentEra then
				print ("----------")
				print ("Changing current Era to "..tostring(CivilizationTypeName).." Era :" .. tostring(GameInfo.Eras[era].EraType))
				currentEra = era
			end
			
			tokenBonus = tokenBonus + player:GetInfluence():GetTokensToGive()
			for i, minorPlayer in ipairs(PlayerManager.GetAliveMinors()) do
				local iMinorPlayer 		= minorPlayer:GetID()				
				local minorInfluence	= minorPlayer:GetInfluence()		
				if minorInfluence ~= nil then
					tokenBonus = tokenBonus + minorInfluence:GetTokensReceived(iPlayer)
				end
			end
	
		end
	end
	
	if playersWithCity > 0 then
		scienceBonus 	= Round(totalScience/playersWithCity)
		minCivForTech	= playersWithCity*25/100
		minCivForCivic	= playersWithCity*10/100
		goldBonus 		= Round(totalGold/playersWithCity)
		settlersBonus 	= Round((totalCities-1)/playersWithCity)
		tokenBonus 		= Round(totalToken/playersWithCity)
		faithBonus		= Round(totalFaith * (gameCurrentEra+1) * 25/100)
	end
	
end

function SetCurrentGameEra()
	if Game.GetEras():GetCurrentEra() > gameCurrentEra then 
		gameCurrentEra = Game.GetEras():GetCurrentEra() 
	end
end

-- if bHistoricalSpawnEras then
	-- GameEvents.OnGameTurnStarted.Add(SetCurrentGameEra)
-- end

-- ===========================================================================
-- Functions related to cities, to be called from event hooks related to cities
-- ===========================================================================
function CheckEraLimit(player)
	local eraLimit = false
	if player:GetCities():GetCount() > gameCurrentEra + 1 then
		eraLimit = true
	end
	return eraLimit
end

--Currently overriden by CityWasConquered
function OnCityCaptured(iPlayer, cityID)
	local pCity = CityManager.GetCity(iPlayer, cityID)
	local pPlayer = Players[iPlayer]
	if not pPlayer:IsMajor() then return end	
	if pPlayer:GetCities():GetCount() ==  1 then
		CityManager.SetAsOriginalCapital(pCity)
		print("Player has captured their first city without using a settler. Converting to Original Capital.")
		return true
	end
	local eraLimit = CheckEraLimit(pPlayer)
	if eraLimit then 
		local pCapital = pPlayer:GetCities():GetCapitalCity()
		local loyaltyBuilding = GameInfo.Buildings["BUILDING_SUPER_MONUMENT"]
		if pCapital:GetBuildings():HasBuilding(loyaltyBuilding.Index) then
			pCapital:GetBuildings():RemoveBuilding(loyaltyBuilding.Index)
			print("Deleting Super Monument from player "..tostring(iPlayer))
		end
		return true
	end		
	return false
end

-- This function would be used to give Super Monuments to players who lose their capital
-- Needs more logic to work correctly, and the idea itself may be unbalanced, currently unused
function CapitalWasChanged(playerID, cityID)
	local pPlayer = Players[playerID]
	local pCities = pPlayer:GetCities()
	local pCity = pCities:FindID(cityID)
	local loyaltyBuilding = GameInfo.Buildings["BUILDING_SUPER_MONUMENT"].Index
	local eraLimit = CheckEraLimit(pPlayer)
	if eraLimit then 
		if GameInfo.Buildings[loyaltyBuilding] and not pCity:GetBuildings():HasBuilding(loyaltyBuilding) then
			--WorldBuilder.CityManager():CreateBuilding(city, loyaltyBuilding, 100, cityPlot)
			local pCityBuildQueue = pCity:GetBuildQueue()
			pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[loyaltyBuilding].Index, 100)
			print("Capital conquered. Spawning new "..tostring(loyaltyBuilding))
		end	
	end	
end

--Credit: LeeS from the Civ 6 Modding Guide, adapted with changes
function CityWasConquered(VictorID, LoserID, CityID, iCityX, iCityY)
	local pPlayer = Players[VictorID]
	local pCity = pPlayer:GetCities():FindID(CityID)
	local sCity_LOC = pCity:GetName()
	print("Player # " .. VictorID .. " : captured the city of " .. Locale.Lookup(sCity_LOC))
	print("Player # " .. LoserID .. " lost the city")
	print("The city is located at (or used to be located at) grid X" .. iCityX .. ", Y" .. iCityY )
	local checkOriginalCapital = ExposedMembers.CheckCityOriginalCapital(VictorID, CityID)
	if checkOriginalCapital then 
		occupiedCapitals[checkOriginalCapital] = true 
		print("An original capital has been conquered by player "..tostring(VictorID).." from player "..tostring(LoserID))
	end
	if not pPlayer:IsMajor() then return end
	local pCapital = pPlayer:GetCities():GetCapitalCity()
	local loyaltyBuilding = GameInfo.Buildings["BUILDING_SUPER_MONUMENT"].Index
	if pCity:GetBuildings():HasBuilding(loyaltyBuilding) and CityID ~= pCapital:GetID()  then
		pCapital:GetBuildings():RemoveBuilding(loyaltyBuilding)
		print("Deleting Super Monument from a recently conquered city")
	end
	local eraLimit = CheckEraLimit(pPlayer)
	if eraLimit then
		if pCapital:GetBuildings():HasBuilding(loyaltyBuilding) then
			pCapital:GetBuildings():RemoveBuilding(loyaltyBuilding)
			print("Deleting Super Monument from player "..tostring(VictorID))
		end
	end		
end

-- Main function that applies bonuses to new cities, note that it is called indirectly during SpawnPlayer,
-- if a player founds their first city during the execution of that function
function OnCityInitialized(iPlayer, cityID, x, y)
	local cityPlot = Map.GetPlot(x,y)
	local pCity = Cities.GetCityInPlot(cityPlot)
	local city = CityManager.GetCity(iPlayer, cityID)
	local player = Players[iPlayer]
	
	local freeCities = false
	if iPlayer == 62 then freeCities = true end
	
	if not city and not pCity then 
		print("OnCityInitialized detected a null city")
		return
	elseif(not city and pCity) then
		print("City not detected by ID. Reverting to city in plot")
		city = pCity
	end
	
	local cityOriginalPopulation :number = city:GetPopulation()
	local pCapital = player:GetCities():GetCapitalCity()
	local iLoyaltyBuilding = GameInfo.Buildings["BUILDING_SUPER_MONUMENT"].Index	
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local CityName = city:GetName()
	print("------------")
	print("Initializing new city for " .. tostring(CivilizationTypeName) ..", "..Locale.Lookup(CityName))
	local bOriginalOwner = false
	if city:GetOriginalOwner() ~= nil then
		bOriginalOwner = true
		-- print("Original owner is "..tostring(city:GetOriginalOwner()))
	end
	
	if freeCities then return end
	
	local playerEra = GetStartingEra(iPlayer)
	local kEraBonuses = GameInfo.StartEras[playerEra]
	
	--City States will use this code then the function will terminate
	if not player:IsMajor() and not freeCities and player:GetCities():GetCount() == 1 then 
		print("Era = "..tostring(playerEra))
		print("StartingPopulationCapital = "..tostring(kEraBonuses.StartingPopulationCapital))
		print("StartingPopulationOtherCities = "..tostring(kEraBonuses.StartingPopulationOtherCities))
		
		if kEraBonuses.StartingPopulationCapital and city == player:GetCities():GetCapitalCity() then 
			city:ChangePopulation(kEraBonuses.StartingPopulationCapital-1)
		elseif kEraBonuses.StartingPopulationOtherCities then
			city:ChangePopulation(kEraBonuses.StartingPopulationOtherCities-1)
		end
		
		for kBuildings in GameInfo.StartingBuildings() do
			if GameInfo.Eras[kBuildings.Era].Index <= playerEra and kBuildings.District == "DISTRICT_CITY_CENTER" then
				local iBuilding = GameInfo.Buildings[kBuildings.Building].Index
				if not city:GetBuildings():HasBuilding(iBuilding) then
					print("Starting Building = "..tostring(kBuildings.Building))
					WorldBuilder.CityManager():CreateBuilding(city, kBuildings.Building, 100, cityPlot)
				end
			end
		end		
		print("------------")
		return 
	end
	
	--totalslacker: check for capital for Super Monument
	local superMonument = false
	if city == player:GetCities():GetCapitalCity() then superMonument = true end
	
	--totalslacker: add era buildings
	local eraBuildingSpawn = false
	local eraBuildingForAll = false
	if ColonialCivs[CivilizationTypeName] then eraBuildingSpawn = true end
	if bEraBuilding then eraBuildingForAll = true end
	
	--Remove all Era Buildings present in city before adding more
	for kEra in GameInfo.Eras() do
		local EraBuilding = GameInfo.Buildings["BUILDING_CENTER_"..tostring(kEra.EraType)]
		if EraBuilding and city:GetBuildings():HasBuilding(EraBuilding.Index) then
			city:GetBuildings():RemoveBuilding(EraBuilding.Index)
			print("Deleting existing Era Building from city")
		end
	end
	
	-- Era Start Building for Era bonuses
	if eraBuildingSpawn and not eraBuildingForAll then
		local EraBuilding = "BUILDING_CENTER_"..tostring(GameInfo.Eras[playerEra].EraType)
		print("Starting Era Building = "..tostring(EraBuilding))
		if GameInfo.Buildings[EraBuilding] then
			--WorldBuilder.CityManager():CreateBuilding(city, EraBuilding, 100, cityPlot)
			local pCityBuildQueue = city:GetBuildQueue();
			pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[EraBuilding].Index, 100);
		end	
	elseif(eraBuildingForAll) then
		local EraBuilding = "BUILDING_CENTER_"..tostring(GameInfo.Eras[playerEra].EraType)
		print("Starting Era Building = "..tostring(EraBuilding))
		if GameInfo.Buildings[EraBuilding] then
			--WorldBuilder.CityManager():CreateBuilding(city, EraBuilding, 100, cityPlot)
			local pCityBuildQueue = city:GetBuildQueue();
			pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[EraBuilding].Index, 100);
		end		
	end
	

	-- Convert first settled city to the Original Capital (not necessary and not working as intended)
	-- if player:GetCities():GetCount() >  1 then
		-- if pCapital:GetOriginalOwner() ~= nil and bOriginalOwner then 
			-- if city:GetOriginalOwner() == iPlayer and pCapital:GetOriginalOwner() ~= iPlayer and not occupiedCapitals[iPlayer] then
				-- CityManager.SetAsOriginalCapital(city)
				-- print("Player has settled their first original city, converting to Original Capital")
			-- end			
		-- end
	-- end
	
	--totalslacker: the line below will prevent every new city after the era limit from spawning units, buildings and population
	--TODO: conditional based on list ?
	local eraLimit = CheckEraLimit(player)
	if eraLimit then 
		local loyaltyBuilding = GameInfo.Buildings["BUILDING_SUPER_MONUMENT"]
		if pCapital:GetBuildings():HasBuilding(loyaltyBuilding.Index) then
			pCapital:GetBuildings():RemoveBuilding(loyaltyBuilding.Index)
			print("Deleting Super Monument from player "..tostring(iPlayer))
		end
		print("Current era is "..tostring(gameCurrentEra))
		print("------------")
		return 
	end	
	
	print("Era = "..tostring(playerEra))
	print("StartingPopulationCapital = "..tostring(kEraBonuses.StartingPopulationCapital))
	print("StartingPopulationOtherCities = "..tostring(kEraBonuses.StartingPopulationOtherCities))
	
	if kEraBonuses.StartingPopulationCapital and (city == player:GetCities():GetCapitalCity()) then 
		if iDifficulty < 5 then
			if not (cityOriginalPopulation >= kEraBonuses.StartingPopulationCapital) then
				SetCityPopulation(city, kEraBonuses.StartingPopulationCapital)
				print("Changing starting population for capital city...")
			end
		end
		if iDifficulty >= 5 then
			SetCityPopulation(city, cityOriginalPopulation + kEraBonuses.StartingPopulationCapital)
			print("Changing starting population for capital city...")
		end
		ConvertInnerRingToCity(iPlayer, cityPlot)
	elseif kEraBonuses.StartingPopulationOtherCities then
		if iDifficulty < 5 then
			if not (cityOriginalPopulation >= kEraBonuses.StartingPopulationOtherCities) then
				SetCityPopulation(city, kEraBonuses.StartingPopulationOtherCities)
				print("Changing starting population for other city...")
			end
		end
		if iDifficulty >= 5 then
			SetCityPopulation(city, cityOriginalPopulation + kEraBonuses.StartingPopulationOtherCities)
			print("Changing starting population for other city...")
		end
	end
	
	for kBuildings in GameInfo.StartingBuildings() do
		if GameInfo.Eras[kBuildings.Era].Index <= playerEra and kBuildings.District == "DISTRICT_CITY_CENTER" then
			local iBuilding = GameInfo.Buildings[kBuildings.Building].Index
			if not city:GetBuildings():HasBuilding(iBuilding) then
				print("Starting Building = "..tostring(kBuildings.Building))
				WorldBuilder.CityManager():CreateBuilding(city, kBuildings.Building, 100, cityPlot)
			end
		end
	end
	
	-- Super Monument
	local iTurn = Game.GetCurrentGameTurn()
	-- local startTurn = GameConfiguration.GetStartTurn()	
	if superMonument and (iTurn ~= 1) then
		local loyaltyBuilding = "BUILDING_SUPER_MONUMENT"
		print("Spawning "..tostring(loyaltyBuilding))
		if GameInfo.Buildings[loyaltyBuilding] then
			--WorldBuilder.CityManager():CreateBuilding(city, loyaltyBuilding, 100, cityPlot)
			local pCityBuildQueue = city:GetBuildQueue()
			pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[loyaltyBuilding].Index, 100)
		end	
	end	
	
	-- Check for Palace
	if pCapital then
		local palaceBuilding = GameInfo.Buildings["BUILDING_PALACE"].Index		
		-- print("Has a palace is "..tostring(pCapital:GetBuildings():HasBuilding(palaceBuilding)))
		if pCapital:GetBuildings():HasBuilding(palaceBuilding) then

			-- print("Palace detected in capital.")
		else
			local pCityBuildQueue = pCapital:GetBuildQueue()
			pCityBuildQueue:CreateIncompleteBuilding(palaceBuilding, 100)			
			-- WorldBuilder.CityManager():CreateBuilding(city, palaceBuilding, 100, cityPlot)
			print("Palace not detected in capital. Spawning a new Palace")
		end
	end
	
	for kUnits in GameInfo.MajorStartingUnits() do
		if GameInfo.Eras[kUnits.Era].Index == playerEra and kUnits.OnDistrictCreated and not (kUnits.AiOnly) then
			local numUnit = math.max(kUnits.Quantity, 1)	
			for i = 0, numUnit - 1, 1 do
				UnitManager.InitUnitValidAdjacentHex(iPlayer, kUnits.Unit, x, y)
				print(" - "..tostring(kUnits.Unit).." = "..tostring(numUnit))
			end
		end
	end	
	print("------------")
end

-- test capture or creation (these functions are no longer being used)
-- totalslacker: The capture test will only work the first time a city is conquered
--	It checks the Player ID at the time the city center is removed and compares to original owner ID
local cityCaptureTest = {}
function CityCaptureDistrictRemoved(iPlayer, districtID, cityID, iX, iY)
	local key = iX..","..iY
	cityCaptureTest[key]			= {}
	cityCaptureTest[key].Turn 		= Game.GetCurrentGameTurn()
	cityCaptureTest[key].iPlayer 	= iPlayer
	cityCaptureTest[key].CityID 	= cityID
end
function CityCaptureCityInitialized(iPlayer, cityID, iX, iY)
	local key = iX..","..iY
	local bCaptured = false
	if (	cityCaptureTest[key]
		and cityCaptureTest[key].Turn 	== Game.GetCurrentGameTurn() )
	then
		cityCaptureTest[key].CityInitializedXY = true
		local city = CityManager.GetCity(iPlayer, cityID)
		local originalOwnerID 	= city:GetOriginalOwner()
		local currentOwnerID	= city:GetOwner()
		if cityCaptureTest[key].iPlayer == originalOwnerID then
			print("City captured")
			cityCaptureTest[key] = {}
			bCaptured = true
			OnCityCaptured(currentOwnerID, cityID)
		end
	end
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	print (tostring(CivilizationTypeName) .. " is founding a city.")	
	if not bCaptured then
		OnCityInitialized(iPlayer, cityID, iX, iY)
	end
end

-- ===========================================================================
-- Raging Barbarians Mode  (also in ScenarioFunctions.lua)
-- ===========================================================================

function UpgradeBarbarianTech(previousEra, newEra)
	-- print("previousEra is "..tostring(previousEra))
	-- print("newEra is "..tostring(newEra))
	local iNewEraID = newEra
	for iPlayer = 0, iMaxPlayersZeroIndex do
		local pPlayer = Players[iPlayer]
		if pPlayer and pPlayer:IsBarbarian() then
			-- print("UpgradeBarbarianTech detected a barbarian player")
			local pScience = pPlayer:GetTechs()	
			for kTech in GameInfo.Technologies() do
				local iTech	= kTech.Index
				if not pScience:HasTech(iTech) then
					--Learn all previous era techs
					if (kTech.EraType == "ERA_ANCIENT") and (iNewEraID >= 1) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					if (kTech.EraType == "ERA_CLASSICAL") and (iNewEraID >= 2) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					if (kTech.EraType == "ERA_MEDIEVAL") and (iNewEraID >= 3) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					if (kTech.EraType == "ERA_RENAISSANCE") and (iNewEraID >= 4) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					if (kTech.EraType == "ERA_INDUSTRIAL") and (iNewEraID >= 5) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					if (kTech.EraType == "ERA_MODERN") and (iNewEraID >= 6) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned "..tostring(kTech.TechnologyType))
					end
					--Learn specific techs from the current era
					-- if (kTech.TechnologyType == "TECH_MASONRY") and (iNewEraID >= 0) then
						-- -- print("Learn Masonry for early Battering Ram")
						-- pScience:SetTech(iTech, true)
						-- print("Barbarian player learned a bonus tech from the current era: "..tostring(kTech.TechnologyType))
					-- end
					if (kTech.TechnologyType == "TECH_IRON_WORKING") and (iNewEraID >= 1) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned a bonus tech from the current era: "..tostring(kTech.TechnologyType))
					end
					if (kTech.TechnologyType == "TECH_STIRRUPS") and (iNewEraID >= 2) then
						pScience:SetTech(iTech, true)
						print("Barbarian player learned a bonus tech from the current era: "..tostring(kTech.TechnologyType))
					end
				end
			end
		end
	end
end

--Unused, not working
function Invasions_SpawnInvasionByContinent()
	local eraCountdown = ExposedMembers.GetEraCountdown()
	if eraCountdown == 10 then
		local invasionPlot = false
		local continentCityPlots = {}
		local cityOwnerIDs = {}
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			local continentPlotsIndexTable = Map.GetContinentPlots(iContinent)	
			--Iterate through list of continent plots and gather all cities into table
			for j, iPlotIndex in ipairs(continentPlotsIndexTable) do
				local pPlot = Map.GetPlotByIndex(iPlotIndex)
				if pPlot then
					local isCity = false
					if pPlot:IsCity() ~= nil then isCity = pPlot:IsCity() end
					if isCity then
						local pCity = Cities.GetCityInPlot(pPlot)
						if pCity then
							table.insert(continentCityPlots, pPlot)
							print("New city plot found")
							print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
						else
							print("City is nil in continentPlots")
						end
					end	
				end
			end
			--Iterate through list of cities and get owner
			if #continentCityPlots > 0 then
				for j, pPlot in ipairs(continentCityPlots) do
					local pCity = Cities.GetCityInPlot(pPlot)
					if pCity then
						local cityOwner = pCity:GetOwner()
						if cityOwner and not cityOwnerIDs[cityOwner] then
							-- cityOwnerIDs[cityOwner] = cityOwner
							table.insert(cityOwnerIDs, cityOwner)
							print("New city owner found: Player #"..tostring(cityOwner))
						end
					else
						print("City was nil in continentCityPlots")
					end
				end
			end
			--Iterate through list of city owners
			for j, cityOwner in ipairs(cityOwnerIDs) do
				local pPlayer = Players[cityOwner]
				local sLeaderTypeName = PlayerConfigurations[cityOwner]:GetLeaderTypeName()
				print("Checking invasion conditions for leader: "..tostring(sLeaderTypeName))
			end
			continentCityPlots = {}
			cityOwnerIDs = {}
			-- if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then		
				
			-- end
		end
	end
end

function Invasions_SpawnInvasion(iPlayer)
	local pPlayer = Players[iPlayer]
	local bBarbarian = false
	local bFreeCities = false
	local bCityState = false
	local bEraLimit = false
	local iEra = 0
	if GameInfo.Eras["ERA_6T_POST_CLASSICAL"] then 
		-- print("Historical Spawn Dates has detected the 6T Era Mod")
		-- print("Increase the era count for the additional era")
		-- iEra = 1
	end
	if (gameCurrentEra >= (3 + iEra)) then
		bEraLimit = true
	end	
	if not pPlayer:IsMajor() then bCityState = true end
	if pPlayer:IsBarbarian() then bBarbarian = true end
	if iPlayer == 62 then bFreeCities = true end
	if pPlayer then
		if not bBarbarian and not bFreeCities and not bCityState and not bEraLimit then
			local iCitiesOwnedByPlayer = pPlayer:GetCities():GetCount()
			-- print("iCitiesOwnedByPlayer is "..tostring(iCitiesOwnedByPlayer))
			if iCitiesOwnedByPlayer and (iCitiesOwnedByPlayer < 1) then
				-- print("Player #"..tostring(iPlayer).." has no cities. Cannot spawn invasion.")
				return false
			end
			local eraCountdown = ExposedMembers.GetEraCountdown()
			if eraCountdown == 10 then
				local bInvasion = Invasions_SpawnUniqueInvasion(iPlayer)
				if bInvasion then
					print("Successfully spawned invasion.")
				end
			end
		else
			-- print("Player #"..tostring(iPlayer).." is a city-state, barbarian or free city player. Cannot spawn invasion.")
		end
	else
		print("WARNING: player is nil in SpawnInvasion #"..tostring(iPlayer))
	end
end

function Invasions_SpawnUniqueInvasion(iPlayer)
	local pPlayer = Players[iPlayer]
	if pPlayer then
		local pCapital = pPlayer:GetCities():GetCapitalCity()
		if pCapital then
			local cityPlot = Map.GetPlot(pCapital:GetX(), pCapital:GetY())
			local campPlot = FindClosestStartingPlotByContinent(cityPlot)
			local continentIndex = cityPlot:GetContinentType()
			local ContinentType = GameInfo.Continents[continentIndex].ContinentType
			if not GameInfo.BarbarianTribes["TRIBE_MELEE"] then
				print("Default barbarian tribes not detected! Cannot spawn invasions!")
				return false
			end
			local iTribeIndex = GameInfo.BarbarianTribes["TRIBE_MELEE"].Index
			if not campPlot then
				print("Failed to find a free plot for barbarian invasion on this continent!")
				return false
			end
			if campPlot and iTribeIndex then
				print("Spawning invasion at "..tostring(campPlot:GetX())..", "..tostring(campPlot:GetY()))
				Game:SetProperty("InvasionCamp_"..campPlot:GetIndex(), iPlayer)
				local iBarbarianTribe = CreateTribeAt(iTribeIndex, campPlot:GetIndex())
				-- print("Spawning empty invasion tribe #"..tostring(iTribeIndex))
				return true
			end
		end
	end
	return false
end

-- ===========================================================================
-- Bug Fixes
-- ===========================================================================

-- Credits: Zegangani / Tiramasu from Free City States mod

function RemoveFreeCityUnit( playerID:number, unitID:number )
--This function fixes a bug where a converted city from the Free Cities starts to spawn units of the Free Cities Player. This bug seems to be caused by using the Cities.DestroyCity function on a city of the Free Cities. Even if you do not place a new city on the plot of the destroyed free city the plot will keep spawning free city units. 
--Note that this bug does not occure if you set a free city yourself. It only happens to cities that became free because of loyalty loss.
	if (playerID == 62) and unitID then
		local pUnit = UnitManager.GetUnit(playerID, unitID)
		if pUnit then
			local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
			if pPlot then
				local iOwnerID = pPlot:GetOwner()		
				if (iOwnerID ~= 62) then
					UnitManager.Kill(pUnit, false)
					print("Deleting Free City State Unit with ID " .. unitID)
				end			
			end
		end
	end	
end
Events.UnitAddedToMap.Add(RemoveFreeCityUnit)

-- ===========================================================================
-- Initialize
-- ===========================================================================

function OnLoadScreenClosed()
	ShowLoadingPopup()
	GetContinentDimensions()
	GameEvents.OnGameTurnStarted.Add(SetCurrentGameEra)
	GameEvents.PlayerTurnStarted.Add(SpawnPlayer)
	if bApplyBalance then
		-- Events.DistrictRemovedFromMap.Add(CityCaptureDistrictRemoved)
		-- Events.CapitalCityChanged.Add(CapitalWasChanged)
		Events.CityInitialized.Add(OnCityInitialized)
		GameEvents.CityConquered.Add(CityWasConquered)
		GameEvents.OnGameTurnStarted.Add(SetCurrentBonuses)
	end
	if bColonizationMode then
		Events.ResearchCompleted.Add(Colonization_OnTechLearned)
		Events.PlayerEraChanged.Add(Colonization_OnPlayerEraChanged)
		-- Events.GameEraChanged.Add(Colonization_OnGameEraChanged)
	end
	if bRagingBarbarians then
		if bBarbarianInvasions then
			GameEvents.PlayerTurnStarted.Add(Invasions_SpawnInvasion)
		end
		Events.ImprovementAddedToMap.Add(SpawnBarbarians)
		Events.GameEraChanged.Add(UpgradeBarbarianTech)
	end
end

Events.LoadScreenClose.Add(OnLoadScreenClosed)

end
----------------------------------------------------------------------------------------
-- Historical Spawn Dates >>>>>
----------------------------------------------------------------------------------------