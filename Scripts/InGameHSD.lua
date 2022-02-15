------------------------------------------------------------------------------
--	FILE:	 InGameHSD.lua
--  Gedemon (2017)
--	totalslacker (2020-2021)
------------------------------------------------------------------------------

include("ScriptHSD.lua");

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
-- Calendar Functions
----------------------------------------------------------------------------------------

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

function GetEraCountdown()
	local pGameEras:table = Game.GetEras()
	local nextEraCountdown = pGameEras:GetNextEraCountdown() + 1; -- 0 turns remaining is the last turn, shift by 1 to make sense to non-programmers
	print("nextEraCountdown is "..tostring(nextEraCountdown))
	return nextEraCountdown
end

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
-- Initialize all functions and link to the the necessary in-game event hooks
----------------------------------------------------------------------------------------

function InitializeHSD_UI()
	-- Update calendar functions from UI for gameplay scripts
	Events.TurnEnd.Add( SetTurnYear )
	LuaEvents.SetAutoValues.Add(SetAutoValues)
	LuaEvents.RestoreAutoValues.Add(RestoreAutoValues)
	LuaEvents.SetStartingEra.Add( SetStartingEra )
	-- Share UI context functions with gameplay scripts
	ExposedMembers.CheckCity.CheckCityGovernor = CheckCityGovernor
	ExposedMembers.CheckCityCapital = CheckCityCapital
	ExposedMembers.CheckCityOriginalCapital = CheckCityOriginalCapital
	ExposedMembers.GetPlayerCityUIDatas = GetPlayerCityUIDatas
	ExposedMembers.GetEraCountdown = GetEraCountdown
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