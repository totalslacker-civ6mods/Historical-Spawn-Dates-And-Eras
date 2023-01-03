-- ===========================================================================
-- Scenario functions (optional scripted events)
-- ===========================================================================

include("UnitFunctions")

-- ===========================================================================
-- UI Context from ExposedMembers
-- ===========================================================================

ExposedMembers.GetTribeNameType = {}

-- ===========================================================================
-- Set local variables
-- ===========================================================================

local bDramaticAges = GameConfiguration.GetValue("GAMEMODE_DRAMATICAGES")

-- ===========================================================================
-- Notifications
-- ===========================================================================

function Notification_NewColony(iPlayer, pPlot)
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	local name = Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_DESCRIPTION")
	local adjective = Locale.Lookup("LOC_"..tostring(CivilizationTypeName).."_ADJECTIVE")
	local pCity = Cities.GetCityInPlot(pPlot)
	local headText = "New Colony Settled!"
	-- local bodyText = "The "..tostring(name).." founded the new colony of "..Locale.Lookup(pCity:GetName()).." at "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()).."!"
	local bodyText = "The "..tostring(name).." founded the colony of "..Locale.Lookup(pCity:GetName()).." on the continent of "..Locale.Lookup(GameInfo.Continents[pPlot:GetContinentType()].Description).."!"
	local notification = false
	local aPlayers = PlayerManager.GetAliveMajors()
	for loop, pPlayer in ipairs(aPlayers) do
		if pPlayer:IsHuman() then
			notification = NotificationManager.SendNotification(pPlayer, NotificationTypes.REBELLION, headText, bodyText, pPlot:GetX(), pPlot:GetY())
		end
	end
	print("Spawning "..tostring(adjective).." colonizer units at plot "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))
	-- return notification
end

-- ===========================================================================
-- Raging Barbarians & Unique Barbarians mode
-- ===========================================================================

local g_CurrentBarbarianCamp = {}

local iNavalBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_NAVAL"]
local iCavalryBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_CAVALRY"]
local iMeleeBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_MELEE"]
local KongoBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_KONGO"]
local ZuluBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_ZULU"]
local NubianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_NUBIAN"]
local CelticBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_CELTIC"]
local GreekBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_GREEK"]
local VikingBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_VIKING"]
local BarbaryCoastTribe = GameInfo.BarbarianTribes["TRIBE_BARBARY"]
local CreeBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_CREE"]
local ScythianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_SCYTHIAN"]
local AztecBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_AZTEC"]
local MaoriBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_MAORI"]
local VaruBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_VARU"]
local IberianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_IBERIAN"]
local BalkansBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_BALKANS"]
local SlavicBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_SLAVIC"]
local HaidaBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_HAIDA"]
local PirateBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_PIRATES"]
local PersianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_PERSIAN"]
local ComancheBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_COMANCHE"]
local PatagonianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_PATAGONIAN"]
local SouthAmericanTribe = GameInfo.BarbarianTribes["TRIBE_SOUTH_AMERICAN"]
local AustralianTribe = GameInfo.BarbarianTribes["TRIBE_AUSTRALIAN"]
local IncanBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_INCAN"]
local MaliBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_MALI"]
local EastAsianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_EASTASIAN"]
local SiberianBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_SIBERIAN"]
local GermanicBarbarianTribe = GameInfo.BarbarianTribes["TRIBE_GERMANIC"]
local InvasionEuropeTribe = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE"]
local InvasionEuropeWestAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_WEST_ANCIENT"]
local InvasionEuropeWestClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_WEST_CLASSICAL"]
local InvasionEuropeWestMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_WEST_MEDIEVAL"]
local InvasionEuropeEastAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_EAST_ANCIENT"]
local InvasionEuropeEastClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_EAST_CLASSICAL"]
local InvasionEuropeEastMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_EAST_MEDIEVAL"]
local InvasionEuropeNorthAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_NORTH_ANCIENT"]
local InvasionEuropeNorthClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_NORTH_CLASSICAL"]
local InvasionEuropeNorthMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE_NORTH_MEDIEVAL"]
local InvasionMiddleEastAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_MIDDLE_EAST_ANCIENT"]
local InvasionMiddleEastClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_MIDDLE_EAST_CLASSICAL"]
local InvasionMiddleEastMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_MIDDLE_EAST_MEDIEVAL"]
local InvasionCentralAsiaAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_CENTRAL_ASIA_ANCIENT"]
local InvasionCentralAsiaClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_CENTRAL_ASIA_CLASSICAL"]
local InvasionCentralAsiaMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_CENTRAL_ASIA_MEDIEVAL"]
local InvasionEastAsiaAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_EAST_ASIA_ANCIENT"]
local InvasionEastAsiaClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_EAST_ASIA_CLASSICAL"]
local InvasionEastAsiaMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_EAST_ASIA_MEDIEVAL"]
local InvasionEasternSteppeAncient = GameInfo.BarbarianTribes["TRIBE_INVASION_EASTERN_STEPPE_ANCIENT"]
local InvasionEasternSteppeClassical = GameInfo.BarbarianTribes["TRIBE_INVASION_EASTERN_STEPPE_CLASSICAL"]
local InvasionEasternSteppeMedieval = GameInfo.BarbarianTribes["TRIBE_INVASION_EASTERN_STEPPE_MEDIEVAL"]

ContinentDimensions = {} --Global variable

function GetContinentDimensions()
	print("Gathering continent dimensions...")
	local g_iW, g_iH = Map.GetGridSize()
	print("Map width is "..tostring(g_iW).." and Map height is "..tostring(g_iH))
	local tContinents = Map.GetContinentsInUse()
	for i,iContinent in ipairs(tContinents) do
		if (GameInfo.Continents[iContinent].ContinentType) then
			print("Continent type is "..tostring(GameInfo.Continents[iContinent].ContinentType))
			local baseY = 300;
			local maxY = 0;
			local spanY = 0;
			local lowerHalf = 0;
			local baseX = 300;
			local maxX = 0;
			local spanX = 0;
			local rightHalf = 0;
			local wrapContinent = false
			local continentTypeName = GameInfo.Continents[iContinent].ContinentType
			local continentPlotIndexes = Map.GetContinentPlots(iContinent)
			for j, pPlot in ipairs(continentPlotIndexes) do
				local continentPlot = Map.GetPlotByIndex(pPlot); --get plot by index, continentPlotIndexes is an index table, not plot objects
				if continentPlot:GetX() > maxX then maxX = continentPlot:GetX() end
				if continentPlot:GetX() < baseX then baseX = continentPlot:GetX() end
				if continentPlot:GetY() > maxY then maxY = continentPlot:GetY() end
				if continentPlot:GetY() < baseY then baseY = continentPlot:GetY() end
			end
			-- print("Finding the height and width of the continent, and the central axes")
			spanX = maxX - baseX
			rightHalf = (maxX - (spanX/2))
			spanY = maxY - baseY
			lowerHalf = (maxY - (spanY/2))
			if (baseX == 0) and (maxX == (g_iW - 1)) then
				print("Detected continent that crosses the edge of the map")
				wrapContinent = true
				local xSpanTable = {}
				local ContinentPlots = {}
				local Nullspace = {}
				local iCount = 0
				local largestNullSpace = 0
				local boundaryIndex = 0
				for j, pPlot in ipairs(continentPlotIndexes) do
					local continentPlot = Map.GetPlotByIndex(pPlot); --get plot by index, continentPlotIndexes is an index table, not plot objects
					if not ContinentPlots[continentPlot:GetX()] then
						ContinentPlots[continentPlot:GetX()] = continentPlot:GetX()
					end
				end
				for i = 0, (g_iW - 1), 1 do
					if ContinentPlots[i] then
						table.insert(xSpanTable, ContinentPlots[i])
					else
						table.insert(xSpanTable, -1)
						table.insert(Nullspace, i)
					end
				end
				-- print("Iterate null space")
				-- for j, pPlot in ipairs(Nullspace) do
					-- print(Nullspace[j])
				-- end
				for j, nullPlot in ipairs(Nullspace) do
					if (Nullspace[j + 1] ==  (nullPlot + 1)) then
						iCount = iCount + 1
					else
						if largestNullSpace < iCount then
							largestNullSpace = iCount
							boundaryIndex = Nullspace[j - largestNullSpace]
							print("Largest null space is "..tostring(largestNullSpace))
							print("Boundary index is "..tostring(boundaryIndex))
						end
						iCount = 0
					end
				end
				-- print("Iterate span table")
				-- for j, pPlot in ipairs(xSpanTable) do
					-- print(xSpanTable[j])
				-- end
				baseX = boundaryIndex + largestNullSpace
				maxX = maxX + boundaryIndex
				spanX = maxX - baseX
				rightHalf = (maxX - (spanX/2))
				if rightHalf > (g_iW - 1) then
					print("Right half of continent begins beyond the edge of the map")
					rightHalf = rightHalf - g_iW
				end
			end	
			print("Base X is : "..tostring(baseX))
			print("Max X is : "..tostring(maxX))
			print("Span of X is : "..tostring(spanX))
			print("Right half of X begins at : "..tostring(rightHalf))
			print("Base Y is : "..tostring(baseY))
			print("Max Y is : "..tostring(maxY))
			print("Span of Y is : "..tostring(spanY))
			print("Lower half of Y begins at : "..tostring(lowerHalf))
			ContinentDimensions[continentTypeName] = {maxX = maxX, spanX = spanX, rightHalf = rightHalf, maxY = maxY, spanY = spanY, lowerHalf = lowerHalf, baseX = baseX}
			-- print("Table results: maxX is "..tostring(ContinentDimensions[continentTypeName].maxX))
		end
	end	
end

function CreateTribeAt( eType, iPlotIndex )
	local pBarbManager = Game.GetBarbarianManager()
	local pPlot = Map.GetPlotByIndex(iPlotIndex)
	-- print("Clearing existing camp")
	ImprovementBuilder.SetImprovementType(pPlot, -1, NO_PLAYER)
	-- print("New camp created")
	local iTribeNumber = pBarbManager:CreateTribeOfType(eType, iPlotIndex)
	-- print("Spawning camp defender of type "..tostring(GameInfo.BarbarianTribes[eType].DefenderTag))
	-- pBarbManager:CreateTribeUnits(eType, GameInfo.BarbarianTribes[eType].DefenderTag, 1, iPlotIndex, 1)
	return iTribeNumber
end

function SpawnBarbsByPlayer(campPlot)
	local bBarbarian = false
	local isBarbarian = false
	local isFreeCities = false
	local iShortestDistance = 10000
	local closestPlayerName = false
	for iPlayer = 0, 63 do
		local pPlayer = Players[iPlayer]
		if pPlayer and pPlayer:IsMajor() then
			-- unfinished
		end
		local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		if pPlayer and pPlayer:IsBarbarian() then isBarbarian = true end
		if iPlayer == 62 then isFreeCities = true end
		if pPlayer and not isBarbarian and not isFreeCities then
			local startingPlot = pPlayer:GetStartingPlot()
			local iDistance = Map.GetPlotDistance(startingPlot:GetX(), startingPlot:GetY(), campPlot:GetX(), campPlot:GetY())
			if iDistance and (iDistance < iShortestDistance) then
				closestPlayerName = sCivTypeName;
				iShortestDistance = iDistance;
			end
		end		
	end
	if closestPlayerName then
		bBarbarian = SpawnUniqueBarbarians(campPlot, closestPlayerName)
	end
	return bBarbarian
end

function SpawnBarbsByContinent(campPlot)
	local bBarbarian = false
	local continentType = campPlot:GetContinentType()
	if continentType and GameInfo.Continents[continentType] then
		bBarbarian = SpawnUniqueBarbarians(campPlot, GameInfo.Continents[continentType].ContinentType)
	end
	return bBarbarian
end

function SpawnRagingBarbs(iBarbarianTribe, campPlot)
	local iRange = 3
	if iBarbarianTribe == ZuluBarbarianTribe then
		pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", 1, campPlot:GetIndex(), iRange);
	end
end

function CheckForSurroundingResource(campPlot, resourceType)
	local bResourceFound = false
	local range = 3
	for dx = -range, range do
		for dy = -range, range do
			print("Searching for nearby resource: "..tostring(resourceType))
			local otherPlot = Map.GetPlotXY(campPlot:GetX(), campPlot:GetY(), dx, dy, range)
			if otherPlot and (otherPlot:GetResourceType() ~= -1) then
				local otherPlotResource = otherPlot:GetResourceType()
				print("Detected resource of type: "..tostring(otherPlotResource))
				if (otherPlotResource == resourceType) or (GameInfo.Resources[otherPlotResource].ResourceType == resourceType) then
					bResourceFound = true
					print("Detected resource matches resourceType")
				end
			end
		end
	end
	return bResourceFound
end

function FindNearestTargetCity(iStartX, iStartY)
	print("FindNearestTargetCity will find the nearest city of any major player to the invasion")
	local pCity = false
	local iShortestDistance = 10000
	-- print("Finding closest city distance...")
	local aPlayers = PlayerManager.GetAliveMajors()
	for loop, pPlayer in ipairs(aPlayers) do
		local pPlayerCities:table = pPlayer:GetCities()
		for i, pLoopCity in pPlayerCities:Members() do
			local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
			if iDistance and (iDistance < iShortestDistance) then
				pCity = pLoopCity
				iShortestDistance = iDistance
			end
		end
	end
	if pCity then
		print ("FindNearestTargetCity() found a target city")
	else
		print ("FindNearestTargetCity() failed to find a target city")
	end
    return pCity
end

function FindNearestPlayerCity(iStartX, iStartY, iPlayer)
	print("FindNearestPlayerCity will find the nearest city of the player that triggered the invasion")
	local pCity = false
	local iShortestDistance = 10000
	-- print("Finding closest city distance...")
	local pPlayer = Players[iPlayer]
	local pPlayerCities:table = pPlayer:GetCities()
	for i, pLoopCity in pPlayerCities:Members() do
		local iDistance = Map.GetPlotDistance(iStartX, iStartY, pLoopCity:GetX(), pLoopCity:GetY())
		if iDistance and (iDistance < iShortestDistance) then
			pCity = pLoopCity
			iShortestDistance = iDistance
		end
	end
	if pCity then
		print ("FindNearestPlayerCity() found a target city")
	else
		print ("FindNearestPlayerCity() failed to find a target city")
	end
    return pCity
end

function InvadeFromPlot(pPlot, iBarbarianTribe, iPlayer)
	local pBarbManager = Game.GetBarbarianManager()
	local iBarbType = ExposedMembers.GetTribeNameType(iBarbarianTribe)
	local pBarbTribe = false
	if(iBarbType >= 0)then
		pBarbTribe = GameInfo.BarbarianTribeNames[iBarbType]
		print("Tribe name is "..Locale.Lookup(pBarbTribe.TribeDisplayName))
	end
	local pTargetCity = false
	pTargetCity = FindNearestPlayerCity(pPlot:GetX(), pPlot:GetY(), iPlayer)
	--TODO: Check here to see if city is reachable
	if not pTargetCity then
		print("Could not find the nearest city of the player that spawned the invasion. Searching for nearest city of any major player.")
		pTargetCity = FindNearestTargetCity(pPlot:GetX(), pPlot:GetY())
	end
	if pTargetCity then
		local pTargetOwnerID = pTargetCity:GetOwner()
		pBarbManager:StartOperationWithCityTarget(iBarbarianTribe, "Barbarian City Assault", pTargetOwnerID, pTargetCity:GetID())
		print("Barbarian invasion spawned for "..Locale.Lookup(pTargetCity:GetName()))
		local eventKey = GameInfo.EventPopupData["HSD_RAGING_BARBARIANS_INVASION_WARNING"].Type
		local eventEffectString = Locale.Lookup("LOC_HSD_BARB_INVASION_MESSAGE", pBarbTribe.TribeDisplayName, pTargetCity:GetName())
		ReportingEvents.Send("EVENT_POPUP_REQUEST", { ForPlayer = pTargetOwnerID, EventKey = eventKey, EventEffect = eventEffectString })
	else
		print("pTargetCity was "..tostring(pTargetCity))
	end
	-- print("Clearing game property for plot flagged for invasion")
	Game:SetProperty("InvasionCamp_"..pPlot:GetIndex(), false)
	return pTargetCity
end

function SpawnBarbarianTribe(pPlot, pTribe)
	local iBarbarianTribe = false
	if not pPlot then
		print("pPlot is "..tostring(pPlot))
	end
	if not pTribe then
		print("pTribe is "..tostring(pTribe))
	end
	if pTribe and pPlot then
		local iBarbarianTribeType = pTribe.Index
		iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, pPlot:GetIndex())
		print("Spawning tribe type #"..tostring(iBarbarianTribeType)..", "..tostring(pTribe.TribeType)..", individual tribe #"..tostring(iBarbarianTribe))
	end
	return iBarbarianTribe
end

-- Unused function. Decided to make invasion units unique depending on region
-- This function can be used if every invasion is standardised
function SpawnInvasion(pPlot, iBarbarianTribe, sUnitClass1, sUnitClass2)
	local iEra = ((Game.GetEras():GetCurrentEra()) + 1) --Game eras are zero indexed
	local iRange = 3
	local iDifficulty = GameInfo.Difficulties[PlayerConfigurations[0]:GetHandicapTypeID()].Index
	local iUnitDifficulty = math.ceil((iDifficulty/2))
	local InvasionCamp = Game:GetProperty("InvasionCamp_"..pPlot:GetIndex())
	if InvasionCamp then
		pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, pPlot:GetIndex(), iRange)
		pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), pPlot:GetIndex(), iRange)
		pBarbManager:CreateTribeUnits(iBarbarianTribe, sUnitClass1, (iUnitDifficulty + iEra), pPlot:GetIndex(), iRange)
		pBarbManager:CreateTribeUnits(iBarbarianTribe, sUnitClass2, (iUnitDifficulty + iEra), pPlot:GetIndex(), iRange)
		InvadeFromPlot(pPlot, iBarbarianTribe, InvasionCamp)
		Game:SetProperty("InvasionCamp_"..pPlot:GetIndex(), false)
	else
		-- print("Invasion not detected for this plot.")
	end
end

function SpawnUniqueBarbarians(campPlot, sCivTypeName)
	print("Spawning a unique barbarian camp for "..tostring(sCivTypeName))
	local iBarbarianTribe = false
	local bIsCoastalCamp = false
	local pBarbManager = Game.GetBarbarianManager() 
	local iRange = 3;
	local iUnitDifficulty = math.ceil((iDifficulty/2))
	local szTribeName = ""
	local iEra = ((Game.GetEras():GetCurrentEra()) + 1) --Game eras are zero indexed
	local InvasionCamp = Game:GetProperty("InvasionCamp_"..campPlot:GetIndex())
	-- print("Gathering contient dimensions")
	local maxY = ContinentDimensions[sCivTypeName].maxY
	local spanY = ContinentDimensions[sCivTypeName].spanY
	local lowerHalf = ContinentDimensions[sCivTypeName].lowerHalf
	local maxX = ContinentDimensions[sCivTypeName].maxX
	local spanX = ContinentDimensions[sCivTypeName].spanX
	local rightHalf = ContinentDimensions[sCivTypeName].rightHalf
	local baseX = ContinentDimensions[sCivTypeName].baseX
	-- print("Checking barbarian camp surroundings")
	if campPlot:IsCoastalLand() then
		-- print("Coastal land camp detected. Checking adjacent plots...")
		local iWaterAdjacent = 0
		for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
			local adjacentPlot = Map.GetAdjacentPlot(campPlot:GetX(), campPlot:GetY(), direction)
			if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
				iWaterAdjacent = iWaterAdjacent + 1
			end
		end		
		-- print("iWaterAdjacent is "..tostring(iWaterAdjacent))
		if iWaterAdjacent >= 3 then		
			print("iWaterAdjacent is high enough to spawn a naval tribe")
			bIsCoastalCamp = true
		end
	end	
	-- print("Spawning barbarian camp based on continent")
	if sCivTypeName == "CONTINENT_AFRICA" then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Africa
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Atlantic coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ZuluBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ZuluBarbarianTribe)
					end
				else
					--Indian coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ZuluBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, BarbaryCoastTribe)
					end
				end
			else
				--North African coast
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Maghreb
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaliBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MALI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NUBIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, BarbaryCoastTribe)
					end
				else
					--Libya
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, NubianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MALI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NUBIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, GreekBarbarianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
				--Any plot with a jungle
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, KongoBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_KONGO", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_KONGO", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, KongoBarbarianTribe)
				end
			elseif(campPlot:GetY() < lowerHalf) then
				--Subsaharan Africa
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, ZuluBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ZULU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, ZuluBarbarianTribe)
				end
			else
				--North Africa
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--West Africa
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaliBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MALI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NUBIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaliBarbarianTribe)
					end
				else
					--East Africa
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, NubianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_ETHIOPIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NUBIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, NubianBarbarianTribe)
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_ASIA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Asia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Middle East
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAMLUK", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PERSIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, BarbaryCoastTribe)
					end
				else
					--Indochina
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_DOMREY", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VOI_CHIEN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				end
			else
				--Northern Asia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Asia
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_TAGMA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ScythianBarbarianTribe)
					end
				else
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_EASTASIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Asia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Middle East
					if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
						if InvasionCamp then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_DOMREY", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VOI_CHIEN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
						end
					else
						if InvasionCamp then
							if (iEra == 1) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastAncient)
							elseif (iEra == 2) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastClassical)
							elseif (iEra >= 3) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastMedieval)
							end
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAMLUK", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PERSIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, PersianBarbarianTribe)
						end
					end
				else
					--Indochina
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VOI_CHIEN", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_DOMREY", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
					end
				end
			else
				--Northern Asia
				if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARU", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VOI_CHIEN", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARU", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_DOMREY", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, VaruBarbarianTribe)
					end
				elseif ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Asia / Middle East
					if not ((campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_GRASS_HILLS"].Index) or (campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_PLAINS_HILLS"].Index) or (campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_DESERT_HILLS"].Index)) then
						--Flatlands
						if InvasionCamp then
							if (iEra == 1) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaAncient)
							elseif (iEra == 2) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaClassical)
							elseif (iEra >= 3) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionCentralAsiaMedieval)
							end
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SCYTHIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_TAGMA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, ScythianBarbarianTribe)
						end
					else
						--Hills
						if InvasionCamp then
							if (iEra == 1) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastAncient)
							elseif (iEra == 2) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastClassical)
							elseif (iEra >= 3) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionMiddleEastMedieval)
							end
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAMLUK", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PERSIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, PersianBarbarianTribe)
						end
					end
				else
					--East Asia
					if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS_GRASSLAND"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS_PLAINS"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"].Index)) then
						--Plots without features, and northern terrain
						if InvasionCamp then
							if (iEra == 1) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEasternSteppeAncient)
							elseif (iEra == 2) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEasternSteppeClassical)
							elseif (iEra >= 3) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEasternSteppeMedieval)
							end
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_HEAVYCAV", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_LIGHTCAV", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, MongolBarbarianTribe)
						end
					else
						--Features present on plot
						if InvasionCamp then
							if (iEra == 1) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaAncient)
							elseif (iEra == 2) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaClassical)
							elseif (iEra >= 3) then
								iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEastAsiaMedieval)
							end
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_EASTASIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						else
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, EastAsianBarbarianTribe)
						end
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_AUSTRALIA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Australia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Western Australia
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					end
				else
					--NSW & Victoria
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					end
				end
			else
				--Northern Australia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Northern Territories
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					end
				else
					--Queensland
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Australia
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
				end
			else
				--Northern Australia
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AUSTRALIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AustralianTribe)
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_EUROPE") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Western Mediterranean
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, GreekBarbarianTribe)
					end
				else
					--Eastern Mediterranean
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, GreekBarbarianTribe)
					end
				end
			else
				--Northern Europe
				if InvasionCamp then
					if (iEra == 1) then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthAncient)
					elseif (iEra == 2) then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthClassical)
					elseif (iEra >= 3) then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthMedieval)
					end
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					--Spawn Naval Units
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, VikingBarbarianTribe)
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Western Mediterranean
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeWestMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, CelticBarbarianTribe)
						elseif (iEra >= 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, GermanicBarbarianTribe)
						end
					end
				else
					--Eastern Mediterranean
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeEastMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, BalkansBarbarianTribe)
					end
				end
			else
				--Northern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Western Europe
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, CelticBarbarianTribe)
						elseif (iEra >= 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, GermanicBarbarianTribe)
						end
					end
				else
					--Eastern Europe
					if InvasionCamp then
						if (iEra == 1) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthAncient)
						elseif (iEra == 2) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthClassical)
						elseif (iEra >= 3) then
							iBarbarianTribe = SpawnBarbarianTribe(campPlot, InvasionEuropeNorthMedieval)
						end
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SlavicBarbarianTribe)
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_NORTH_AMERICA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern NA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Pacific Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AztecBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AZTEC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAYA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AztecBarbarianTribe)
					end
				else
					--Atlantic Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, AztecBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AZTEC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAYA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, PirateBarbarianTribe)
					end
				end
			else
				--Northern NA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Alaska / PNW
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, CreeBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, HaidaBarbarianTribe)
					end
				else
					--Quebec
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, CreeBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
						--Spawn Naval Units
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", iEra, campPlot:GetIndex(), iRange)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, CreeBarbarianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern NA
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AztecBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_AZTEC", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAYA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, AztecBarbarianTribe)
				end
			else
				--Northern NA
				if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"].Index)) then
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ComancheBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_COMANCHE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_COMANCHE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, ComancheBarbarianTribe)
					end
				else
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, CreeBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CREE", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, CreeBarbarianTribe)
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_OCEANIA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Pacific
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Fiji
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", (1 + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				else
					--Easter Island
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", (1 + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				end
			else
				--Northern Pacific
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Guam
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", (1 + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				else
					--Hawaii
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", (1 + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Pacific
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAORI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
				end
			else
				--Northern Pacific
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAORI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_SIBERIA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Siberia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Russia
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					end
				else
					--Far Eastern Russia
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					end
				end
			else
				--Northern Siberia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Russia
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					end
				else
					--Far Eastern Russia
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Siberia
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
				end
			else
				--Northern Siberia
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MONGOL", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, SiberianBarbarianTribe)
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_SOUTH_AMERICA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern SA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Pacific Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
					end
				else
					--Atlantic Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
					end
				end
			else
				--Northern SA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Colombian Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, IncanBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SOUTHAM", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_INCAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, IncanBarbarianTribe)
					end
				else
					--North Brazilian Coast
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SouthAmericanTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SOUTHAM", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAYA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SouthAmericanTribe)
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern SA
				if InvasionCamp then
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_PATAGONIAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
					InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
				else
					iBarbarianTribe = SpawnBarbarianTribe(campPlot, PatagonianBarbarianTribe)
				end
			else
				--Northern SA
				if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index)) or (((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX)))) then
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, IncanBarbarianTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SOUTHAM", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_INCAN", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, IncanBarbarianTribe)
					end
				else
					if InvasionCamp then
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SouthAmericanTribe)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SOUTHAM", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAYA", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
						InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
					else
						iBarbarianTribe = SpawnBarbarianTribe(campPlot, SouthAmericanTribe)
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_ZEALANDIA") then
		if bIsCoastalCamp then
			if InvasionCamp then
				iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
				pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_MELEE", iEra, campPlot:GetIndex(), iRange)
				pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_NAVAL_RANGED", (1 + iEra), campPlot:GetIndex(), iRange)
				InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
			else
				iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
			end
		elseif(not bIsCoastalCamp) then
			if InvasionCamp then
				iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
				pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_MAORI", (iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
				InvadeFromPlot(campPlot, iBarbarianTribe, InvasionCamp)
			else
				iBarbarianTribe = SpawnBarbarianTribe(campPlot, MaoriBarbarianTribe)
			end
		end
	elseif(sCivTypeName) then
		--Generic Continent
		if bIsCoastalCamp then
			print("Spawning generic naval tribes for continent "..tostring(sCivTypeName))
			local eBarbarianTribeType = iNavalBarbarianTribe
			local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
			-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_ANTI_CAVALRY", 2, campPlot:GetIndex(), iRange);
		elseif(not bIsCoastalCamp) then
			if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index then
				print("Spawning generic tribes for continent "..tostring(sCivTypeName))
				local eBarbarianTribeType = iMeleeBarbarianTribe
				local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
				-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", 2, campPlot:GetIndex(), iRange);
			elseif(campPlot:GetY() < (maxY - (spanY/2))) then
				--Southern Continent
				print("Spawning generic tribes for continent "..tostring(sCivTypeName))
				local eBarbarianTribeType = iMeleeBarbarianTribe
				local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
				-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", 2, campPlot:GetIndex(), iRange);
			else
				--Northern Continent
				print("Spawning generic tribes for continent "..tostring(sCivTypeName))
				local eBarbarianTribeType = iMeleeBarbarianTribe
				local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
				-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_CELTIC", 2, campPlot:GetIndex(), iRange);
			end
		end
	end
	--Civilizations (unused example code)
	-- if sCivTypeName == "CIVILIZATION_KONGO" then
		-- local eBarbarianTribeType = 3 --Kongo
		-- local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
		-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_MELEE", 2, campPlot:GetIndex(), iRange);
		-- pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_RANGED", 1, campPlot:GetIndex(), iRange);
	-- end
	if not iBarbarianTribe then
		print("Failed to spawn a barbarian tribe!")
	end
	return iBarbarianTribe
end

function SpawnBarbarians(iX, iY, eImprovement, playerID, resource, isPillaged, isWorked)
	local isBarbarian = false
	local isBarbCamp = false
	local pPlayer = Players[playerID]
	local campPlot : table = Map.GetPlot(iX, iY)
	-- print("Returning parameters")
	-- print("iX is "..tostring(iX)..", iY is "..tostring(iY)..", eImprovement is "..tostring(eImprovement)..", playerID is "..tostring(playerID)..", resource is "..tostring(resource)..", isPillaged is "..tostring(isPillaged)..", isWorked is "..tostring(isWorked))
	local prevCamp = Game:GetProperty("BarbarianCamp_"..campPlot:GetIndex())
	if (not prevCamp) and (Players[playerID] == Players[63]) then 
		isBarbarian = true 
		-- print("isBarbarian is "..tostring(isBarbarian))
	else
		-- print("isBarbarian is "..tostring(isBarbarian)..", prevCamp is "..tostring(prevCamp))
		return isBarbarian
	end
	if GameInfo.Improvements[eImprovement] then
		-- print("GameInfo ImprovementType is "..tostring(GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].ImprovementType))
		-- print("GameInfo eImprovement is "..tostring(GameInfo.Improvements[eImprovement].ImprovementType))
		if GameInfo.Improvements[eImprovement].ImprovementType == GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].ImprovementType then
			-- print("Barbarian camp detected from GameInfo")
			print("iX is "..tostring(iX)..", iY is "..tostring(iY))
			local plotUnits = Units.GetUnitsInPlot(campPlot)
			local barbUnits = pPlayer:GetUnits()
			local adjPlots = Map.GetAdjacentPlots(iX, iY)
			local adjPlotUnits = {}
			local toKill = {}
			
			--Obselete code below. We set the default barbarian camps to empty, instead of trying to delete the default units that spawn
			
			-- table.insert(g_CurrentBarbarianCamp, campPlot)
			-- print("#barbUnits is "..tostring(#barbUnits))
			-- ImprovementBuilder.SetImprovementType(campPlot, -1)
			-- print("Original barbarian camp destroyed")
			
			-- if plotUnits ~= nil then
				-- for i, pUnit in ipairs(plotUnits) do
					-- table.insert(toKill, pUnit)
				-- end
				-- for i, pUnit in ipairs(toKill) do
					-- UnitManager.Kill(pUnit)
					-- print("Killing original barbarian unit in camp")
				-- end	
				-- toKill = {}
			-- end	
			
			-- for i, pUnit in ipairs(barbUnits) do
				-- if pUnit then
					-- print("Barbarian unit detected at "..tostring(pUnit:GetX())..", "..tostring(pUnit:GetY()))
					-- local pUnitPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
					-- local distance = Map.GetPlotDistance(campPlot:GetIndex(), pUnitPlot:GetIndex());
					-- print("Plot distance is "..tostring(distance))
					-- if distance <= 3 then
						-- print("Barbarian scout detected")
						-- table.insert(toKill, pUnit)				
					-- end				
				-- end
			-- end
			
			-- local range = 3
			-- for dx = -range, range do
				-- for dy = -range, range do
					-- print("Searching for barbarian scouts nearby")
					-- local otherPlot = Map.GetPlotXY(campPlot:GetX(), campPlot:GetY(), dx, dy, range)
					-- if otherPlot and otherPlot:IsUnit() then
						-- local otherPlotUnits = Units.GetUnitsInPlot(otherPlot)
						-- for i, pUnit in ipairs(otherPlotUnits) do
							-- if pUnit and ((pUnit:GetTypeHash() == GameInfo.Units["UNIT_SCOUT"].Hash) or (pUnit:GetTypeHash() == GameInfo.Units["UNIT_SKIRMISHER"].Hash)) then
								-- local pUnitOwnerID = pUnit:GetOwner()
								-- if pUnitOwnerID == 63 then
									-- print("Barbarian recon unit detected")
									-- table.insert(toKill, pUnit)
								-- end
							-- end
						-- end
					-- end
				-- end
			-- end
			-- if #toKill > 0 then
				-- for i, pUnit in ipairs(toKill) do
					-- if pUnit then
						-- UnitManager.Kill(pUnit)
						-- print("Killing original barbarian scout")
					-- end
				-- end					
			-- end
			
			Game:SetProperty("BarbarianCamp_"..campPlot:GetIndex(), 1)
			
			local newBarbCamp = SpawnBarbsByContinent(campPlot)
		end
	end
	return isBarbarian
end

--Obselete code, but still functional
function RemoveBarbScouts( playerID, unitID )
	local player 			= Players[playerID]
	if not player:IsBarbarian() then
		return
	end
	local unit 				= UnitManager.GetUnit(playerID, unitID)
	local turnsFromStart 	= Game.GetCurrentGameTurn() - GameConfiguration.GetStartTurn()
	local tempTable = {}
	if unit and player and (unit:GetType() == GameInfo.Units["UNIT_SCOUT"].Index) and player:IsBarbarian() then
		local range = 3
		for dx = -range, range do
			for dy = -range, range do
				print("Searching for barbarian camps nearby")
				local otherPlot = Map.GetPlotXY(unit:GetX(), unit:GetY(), dx, dy, range)
				if otherPlot then
					local prevCamp = Game:GetProperty("BarbarianScout_"..otherPlot:GetIndex())
					local isBarbCamp  = otherPlot:GetImprovementOwner() == player:GetID()
					print("isBarbCamp is "..tostring(isBarbCamp)..", otherPlot:GetImprovementOwner() is "..tostring(otherPlot:GetImprovementOwner()))
					if not prevCamp and isBarbCamp then
						print("Unit type is "..tostring(unit:GetType()))
						print("Barbarian scout detected")
						UnitManager.Kill(unit)
						Game:SetProperty("BarbarianScout_"..otherPlot:GetIndex(), 1)
					end
				end
			end
		end
	end	
	if #tempTable > 0 then
		for i, curPlot in ipairs(tempTable) do
			if g_CurrentBarbarianCamp[curPlot] then
				print("Removing barbarian camp from list")
				table.remove(g_CurrentBarbarianCamp, curPlot)
				print("#g_CurrentBarbarianCamp is "..tostring(#g_CurrentBarbarianCamp))
			end
		end
	end
end

-- ===========================================================================
-- Colonization Mode
-- ===========================================================================

function InitiateColonization_GetCoastalPlots(coastalPlots)
	local colonyPlots = {}
	for i, iPlotIndex in ipairs(coastalPlots) do
		-- print("Checking coastal plot...")
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		local coastalLand = false
		local impassable = true
		local isOwned = true
		local isUnit  = true	
		if pPlot:IsCoastalLand() ~= nil then coastalLand = pPlot:IsCoastalLand() end
		if pPlot:IsOwned() ~= nil then isOwned = pPlot:IsOwned() end
		if pPlot:IsUnit() ~= nil then isUnit = pPlot:IsUnit() end
		if pPlot:IsImpassable() ~= nil then impassable = pPlot:IsImpassable() end
		if coastalLand and not isOwned and not impassable then 
			table.insert(colonyPlots, pPlot)
			-- print("New colony plot found")
			-- print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))	
		else
			-- print("isWater is "..tostring(isWater))
			-- print("isOwned is "..tostring(isOwned))
			-- print("isUnit is "..tostring(isUnit))
		end
	end
	if #colonyPlots == 0 then
		print("InitiateColonization_GetCoastalPlots found no coastal plots")
	end
	return colonyPlots
end

function InitiateColonization_GetWaterAdjacentPlots(coastalPlots)
	local colonyPlots = {}
	for i, iPlotIndex in ipairs(coastalPlots) do
		-- print("Checking coastal plot...")
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		local coastalLand = false
		local impassable = true
		local isOwned = true
		local isUnit  = true
		if pPlot:IsCoastalLand() ~= nil then coastalLand = pPlot:IsCoastalLand() end
		if pPlot:IsOwned() ~= nil then isOwned = pPlot:IsOwned() end
		if pPlot:IsUnit() ~= nil then isUnit = pPlot:IsUnit() end
		if pPlot:IsImpassable() ~= nil then impassable = pPlot:IsImpassable() end
		if coastalLand and not isOwned and not impassable then 
			local iWaterAdjacent = 0
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
				if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
					iWaterAdjacent = iWaterAdjacent + 1
				end
			end		
			if iWaterAdjacent >= 3 then
				table.insert(colonyPlots, pPlot)
				-- print("New colony plot found")
				-- print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
			end
		else
			-- print("isWater is "..tostring(isWater))
			-- print("isOwned is "..tostring(isOwned))
			-- print("isUnit is "..tostring(isUnit))
		end
	end
	if #colonyPlots == 0 then
		print("InitiateColonization_GetCoastalPlots found no coastal plots")
	end
	return colonyPlots
end

function InitiateColonization_GetIslandPlots(coastalPlots)
	local colonyPlots = {}
	for i, iPlotIndex in ipairs(coastalPlots) do
		-- print("Checking coastal plot...")
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		local coastalLand = false
		local impassable = true
		local isOwned = true
		local isUnit  = true	
		if pPlot:IsCoastalLand() ~= nil then coastalLand = pPlot:IsCoastalLand() end
		if pPlot:IsOwned() ~= nil then isOwned = pPlot:IsOwned() end
		if pPlot:IsUnit() ~= nil then isUnit = pPlot:IsUnit() end
		if pPlot:IsImpassable() ~= nil then impassable = pPlot:IsImpassable() end
		if coastalLand and not isOwned and not impassable then 
			local iWaterAdjacent = 0
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
				if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
					iWaterAdjacent = iWaterAdjacent + 1
				end
			end		
			if iWaterAdjacent >= 4 then
				table.insert(colonyPlots, pPlot)
				-- print("New colony plot found")
				-- print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))							
			end
		else
			-- print("isWater is "..tostring(isWater))
			-- print("isOwned is "..tostring(isOwned))
			-- print("isUnit is "..tostring(isUnit))
		end
	end
	if #colonyPlots == 0 then
		print("InitiateColonization_GetIslandPlots found no island plots")
	end
	return colonyPlots
end

function InitiateColonization_GetPlotsByFeature(coastalPlots, featureIndex)
	--Example featureIndex value:
	--GameInfo.Features["FEATURE_YOSEMITE"].Index
	local colonyPlots = {}
	for i, iPlotIndex in ipairs(coastalPlots) do
		-- print("Checking coastal plot...")				
		local pPlot = Map.GetPlotByIndex(iPlotIndex)
		local plotX = pPlot:GetX()
		local plotY = pPlot:GetY()
		if pPlot:GetFeatureType() == featureIndex then
			local range = 3
			for dx = -range, range do
				for dy = -range, range do
					-- print("Searching for plots nearby Yosemite...")								
					local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
					if otherPlot then
						local coastalLand = false
						local impassable = true
						local isOwned = true
						local isUnit  = true
						if otherPlot:IsCoastalLand() ~= nil then coastalLand = otherPlot:IsCoastalLand() end
						if otherPlot:IsOwned() ~= nil then isOwned = otherPlot:IsOwned() end
						if otherPlot:IsUnit() ~= nil then isUnit = otherPlot:IsUnit() end
						if otherPlot:IsImpassable() ~= nil then impassable = otherPlot:IsImpassable() end
						if not isOwned and not impassable then 
							table.insert(colonyPlots, otherPlot)
							-- print("New colony plot found")
							-- print("Plot: "..tostring(pPlot:GetX())..", "..tostring(pPlot:GetY()))		
						else
							-- print("isWater is "..tostring(isWater))
							-- print("isOwned is "..tostring(isOwned))
							-- print("isUnit is "..tostring(isUnit))
						end									
					end
				end
			end							
		end
	end
	if #colonyPlots == 0 then
		print("InitiateColonization_GetPlotsByFeature found no plots by feature")
		colonyPlots = false
	end
	return colonyPlots
end

function InitiateColonization_BestColonyPlot(colonyPlots)
	local plotScore = -100
	local selectedPlot = false
	for i, pPlot in ipairs(colonyPlots) do
		if pPlot then
			local iScore = ScoreColonyPlot(pPlot)
			local plotX = pPlot:GetX()
			local plotY = pPlot:GetY()
			local tooCloseToCity = false
			local range = 3
			if iScore >= plotScore then 
				for dx = -range, range do
					for dy = -range, range do
						-- print("Searching for nearby cities...")								
						local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
						if otherPlot then
							local isCity = otherPlot:IsCity()
							if isCity then
								tooCloseToCity = true
							end
						end
					end
				end	
				if not tooCloseToCity then
					plotScore = iScore 
					selectedPlot = pPlot
					if selectedPlot:IsUnit() then
						MoveStartingPlotUnits(Units.GetUnitsInPlot(selectedPlot), selectedPlot)
					end
				end
			end						
		end			
	end
	return selectedPlot
end

function InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
	local plotScore = -100
	local selectedPlot = false
	for i, pPlot in ipairs(colonyPlots) do
		if pPlot then
			local iScore = ScoreColonyPlotsByDistance(pPlot, startingPlot)
			local plotX = pPlot:GetX()
			local plotY = pPlot:GetY()	
			local tooCloseToCity = false
			local range = 3
			if iScore >= plotScore then 
				for dx = -range, range do
					for dy = -range, range do
						-- print("Searching for nearby cities...")								
						local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
						if otherPlot then
							local isCity = otherPlot:IsCity()
							if isCity then
								tooCloseToCity = true
							end
						end
					end
				end	
				if not tooCloseToCity then
					plotScore = iScore 
					selectedPlot = pPlot
					if selectedPlot:IsUnit() then
						MoveStartingPlotUnits(Units.GetUnitsInPlot(selectedPlot), selectedPlot)
					end					
				end
			end						
		end			
	end
	return selectedPlot
end

function InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
	local plotScore = -100
	local selectedPlot = false
	for i, pPlot in ipairs(colonyPlots) do
		if pPlot then
			local iScore = ScoreColonyPlotsMostDistant(pPlot, startingPlot)
			local plotX = pPlot:GetX()
			local plotY = pPlot:GetY()	
			local tooCloseToCity = false
			local range = 3
			if iScore >= plotScore then 
				for dx = -range, range do
					for dy = -range, range do
						-- print("Searching for nearby cities...")								
						local otherPlot = Map.GetPlotXY(plotX, plotY, dx, dy, range)
						if otherPlot then
							local isCity = otherPlot:IsCity()
							if isCity then
								tooCloseToCity = true
							end
						end
					end
				end	
				if not tooCloseToCity then
					plotScore = iScore 
					selectedPlot = pPlot
					if selectedPlot:IsUnit() then
						MoveStartingPlotUnits(Units.GetUnitsInPlot(selectedPlot), selectedPlot)
					end					
				end
			end						
		end			
	end
	return selectedPlot
end

function InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
	local CityManager = WorldBuilder.CityManager or ExposedMembers.CityManager
	local pOwnerID = pCity:GetOwner()
	local harborPlots = {}
	local bHarbor = false
	local harborDistrict = false
	while (harborDistrict == false) do
		if sCivTypeName == "CIVILIZATION_ENGLAND" then
			harborDistrict = GameInfo.Districts["DISTRICT_ROYAL_NAVY_DOCKYARD"].Index
		elseif(sCivTypeName == "CIVILIZATION_PHOENICIA") then
			harborDistrict = GameInfo.Districts["DISTRICT_COTHON"].Index
		else
			if GameInfo.Districts["DISTRICT_HARBOR"] then 
				harborDistrict = GameInfo.Districts["DISTRICT_HARBOR"].Index 
			end
		end
	end
	if pCity then
		local harborPlot = false
		for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
			local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
			local isResource = false
			local isFeature	= false
			if adjacentPlot and adjacentPlot:GetResourceType() ~= -1 then isResource = true end
			if adjacentPlot and adjacentPlot:GetFeatureType() ~= -1 then isFeature = true end
			if adjacentPlot and adjacentPlot:IsWater() and not isFeature and not isResource then
				harborPlot = adjacentPlot
				table.insert(harborPlots, harborPlot)
				print("Harbor plot found")
			end
		end	
		if harborPlot then
			local randPlotID = RandRange(1, #harborPlots, "Selecting adjacent water plot to build Harbor district")
			local pCityBuildQueue = pCity:GetBuildQueue()
			-- local iDistrictType = GameInfo.Districts["DISTRICT_HARBOR"].Index
			local iConstructionLevel = 100				
			pCityBuildQueue:CreateIncompleteDistrict(harborDistrict, harborPlots[randPlotID]:GetIndex(), iConstructionLevel)
			bHarbor = true
			print("Spawning harbor in city")
		else
			print("A harbor plot could not be found")
			-- totalslacker: Attempts to search further for a possible harbor plot, not tested
			-- local adjacentPlots = {}
			-- for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				-- local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
				-- if adjacentPlot then
					-- table.insert(adjacentPlots, adjacentPlot)
				-- end
			-- end	
			-- for j, pPlot in ipairs(adjacentPlots) do 
				-- for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
					-- local adjacentPlot = Map.GetAdjacentPlot(pPlot:GetX(), pPlot:GetY(), direction)
					-- if adjacentPlot then
						-- local isResource = false
						-- local isFeature	= false
						-- if adjacentPlot and adjacentPlot:GetResourceType() ~= -1 then isResource = true end
						-- if adjacentPlot and adjacentPlot:GetFeatureType() ~= -1 then isFeature = true end
						-- if adjacentPlot:IsWater() and adjacentPlot:IsAdjacentToLand() and not isResource and not isFeature then
							-- harborPlot = adjacentPlot
							-- table.insert(harborPlots, harborPlot)
							-- print("Harbor plot found")							
						-- end
					-- end
				-- end					
			-- end
			-- if harborPlot then
				-- local randPlotID = RandRange(1, #harborPlots, "Selecting adjacent water plot to build Harbor district")
				-- local plot = harborPlots[randPlotID]
				-- if CityManager then
					-- CityManager():SetPlotOwner(plot:GetX(), plot:GetY(), false )
					-- CityManager():SetPlotOwner(plot:GetX(), plot:GetY(), pOwnerID, pCity:GetID())	
					-- local pCityBuildQueue = pCity:GetBuildQueue()
					-- local iDistrictType = GameInfo.Districts["DISTRICT_HARBOR"].Index
					-- local iConstructionLevel = 100				
					-- pCityBuildQueue:CreateIncompleteDistrict(iDistrictType, plot:GetIndex(), iConstructionLevel)
					-- bHarbor = true
					-- print("Spawning harbor in city")	
				-- end					
			-- else
				-- print("A harbor plot could not be found")
			-- end
		end
	end
	return bHarbor
end

function InitiateColonization_FirstWave(PlayerID, sCivTypeName)
	local pPlayer = Players[PlayerID]
	local startingPlot = pPlayer:GetStartingPlot()
	if sCivTypeName == "CIVILIZATION_ENGLAND" then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("England is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}		
				local selectedPlot = false			
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_FRANCE") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("France is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end				
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_GERMANY") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Germany is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end			
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_NETHERLANDS") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("Netherlands is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Netherlands is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end	
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_PORTUGAL") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Portugal is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end				
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
					--Spawn water units last (Portugal gets extra Naus)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
						end
					end
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("Portugal is founding a new colony in Asia")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
					--Spawn water units last (Portugal gets extra Naus)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
						end
					end	
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SOUTH_AMERICA") then
				print("Portugal is founding a new colony in South America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end				
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
							break
						end
					end
				end
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_RUSSIA") then
		--Does not spawn on coast
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SIBERIA") then
				print(tostring(sCivTypeName).." is founding a new colony in "..tostring(GameInfo.Continents[iContinent].ContinentType))
				local selectedPlot = false	
				local continentPlotIndexes = Map.GetContinentPlots(iContinent)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(continentPlotIndexes, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if not pCity then
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_SCOTLAND") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("Scotland is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_SPAIN") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SOUTH_AMERICA") then
				print("Spain is founding a new colony in South America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnit(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("Spain is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end	
					UnitManager.InitUnit(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					Notification_NewColony(PlayerID, selectedPlot)
				end							
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("Spain is founding a new colony in Asia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				-- if GameInfo.Features["FEATURE_CHOCOLATEHILLS"] then
					-- colonyPlots = InitiateColonization_GetPlotsByFeature(coastalPlots, GameInfo.Features["FEATURE_CHOCOLATEHILLS"].Index)
					-- if colonyPlots == false then
						-- colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
					-- end
				-- else
					-- colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				-- end
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnit(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					Notification_NewColony(PlayerID, selectedPlot)
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_CARAVEL"] then
								UnitManager.InitUnit(PlayerID, "UNIT_CARAVEL", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								print("Naval unit does not exist! No dynamic spawn function for naval units has been created yet.")
							end
							break
						end
					end
				end	
			end
		end
	else
		print("Custom or modded civilization detected in ColonizerCivs table")
		print("Activating generic Colonization Mode for custom civilization: "..tostring(sCivTypeName))
		local iRandomContinent = Game.GetRandNum(2, "Random Continent Roll")
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA" and iRandomContinent == 0) then
				print("Generic or modded civilization is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SOUTH_AMERICA" and iRandomContinent == 1) then
				print("Generic or modded civilization is founding a new colony in South America...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				--Select possible colony plots
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				--Find the best plot in the selection
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				--Create colony on selected plot
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_MELEE")
					Notification_NewColony(PlayerID, selectedPlot)
				end					
			end
		end		
	end
	Game:SetProperty("Colonization_Wave01_Player_#"..PlayerID, 1)
	return selectedPlot
end

function InitiateColonization_SecondWave(PlayerID, sCivTypeName)
	local pPlayer = Players[PlayerID]
	local startingPlot = pPlayer:GetStartingPlot()
	if sCivTypeName == "CIVILIZATION_ENGLAND" then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AUSTRALIA") then
				print("England is founding a new colony in Australia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local coastalPlots = Map.GetContinentPlots(iContinent)			
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then					
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning English colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_ENGLISH_SEADOG"] then
								UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_SEADOG", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ZEALANDIA") then
				print("England is founding a new colony in Zealandia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100				
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				if selectedPlot then					
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning English colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_ENGLISH_SEADOG"] then
								UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_SEADOG", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end
				end	
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_FRANCE") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AUSTRALIA") then
				print("France is founding a new colony in Australia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning French colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_PRIVATEER"] then
								UnitManager.InitUnit(PlayerID, "UNIT_PRIVATEER", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end					
				end			
			elseif (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_OCEANIA") then
				print("France is founding a new colony in Australia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_FIELD_CANNON", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning French colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_PRIVATEER"] then
								UnitManager.InitUnit(PlayerID, "UNIT_PRIVATEER", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end					
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_GERMANY") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_OCEANIA") then
				print("Germany is founding a new colony in Oceania...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					SpawnUnit(PlayerID, selectedPlot, 1, "PROMOTION_CLASS_RANGED")
					print("Spawning German colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_PRIVATEER"] then
								UnitManager.InitUnit(PlayerID, "UNIT_PRIVATEER", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end	
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_NETHERLANDS") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AUSTRALIA") then
				print("Netherlands is founding a new colony in Australia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning Dutch colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_DE_ZEVEN_PROVINCIEN"] then
								UnitManager.InitUnit(PlayerID, "UNIT_DE_ZEVEN_PROVINCIEN", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end	
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("Netherlands is founding a new colony in Asia")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning Dutch colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_DE_ZEVEN_PROVINCIEN"] then
								UnitManager.InitUnit(PlayerID, "UNIT_DE_ZEVEN_PROVINCIEN", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end	
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_PORTUGAL") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Portugal is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning Portuguese colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (Portugal gets extra Naus)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
						end
					end	
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("Portugal is founding a new colony in Asia")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning Portuguese colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (Portugal gets extra Naus)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
						end
					end	
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SOUTH_AMERICA") then
				print("Portugal is founding a new colony in South America")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyByDistance(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					if GameInfo.Units["UNIT_RANGER"] then
						UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					else
						SpawnUnit(PlayerID, selectedPlot, Game.GetEras():GetCurrentEra(), "PROMOTION_CLASS_RECON")
					end
					print("Spawning Portuguese colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_PORTUGUESE_NAU", adjacentPlot:GetX(), adjacentPlot:GetY())
							break
						end
					end	
				end			
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_SPAIN") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_SOUTH_AMERICA") then
				print("Spain is founding a new colony in South America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnit(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning Spanish colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
				end			
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_NORTH_AMERICA") then
				print("Spain is founding a new colony in North America...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				-- if GameInfo.Features["FEATURE_YOSEMITE"] then
					-- colonyPlots = InitiateColonization_GetPlotsByFeature(coastalPlots, GameInfo.Features["FEATURE_YOSEMITE"].Index)
					-- if colonyPlots == false then
						-- colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
					-- end
				-- else
					-- colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				-- end
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnit(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning Spanish colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
				end				
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("Spain is founding a new colony in Asia")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetIslandPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_SPANISH_CONQUISTADOR", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning Spanish colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_FRIGATE", adjacentPlot:GetX(), adjacentPlot:GetY())
							break
						end
					end	
				end				
			end
		end
	else
		print("Custom or modded civilization detected in ColonizerCivs table")
		print("Activating generic Colonization Mode for custom civilization: "..tostring(sCivTypeName))
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AUSTRALIA") then
				print("Generic or modded civilization is founding a new colony in Australia...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_RANGER", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning Generic Civilization colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							if GameInfo.Units["UNIT_PRIVATEER"] then
								UnitManager.InitUnit(PlayerID, "UNIT_PRIVATEER", adjacentPlot:GetX(), adjacentPlot:GetY())
							else
								SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_RAIDER")
							end
							break
						end
					end
				end			
			end
		end		
	end
	Game:SetProperty("Colonization_Wave02_Player_#"..PlayerID, 1)
	return selectedPlot
end

function InitiateColonization_ThirdWave(PlayerID, sCivTypeName)
	local pPlayer = Players[PlayerID]
	local startingPlot = pPlayer:GetStartingPlot()
	if sCivTypeName == "CIVILIZATION_ENGLAND" then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("England is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local coastalPlots = Map.GetContinentPlots(iContinent)			
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then					
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_REDCOAT", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_REDCOAT", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning English colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_MELEE")
							break
						end
					end
				end	
			elseif(GameInfo.Continents[iContinent].ContinentType == "CONTINENT_ASIA") then
				print("England is founding a new colony in Asia...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100				
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then					
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_REDCOAT", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning English colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_MELEE")
							break
						end
					end
				end	
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_FRANCE") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("France is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_FRENCH_GARDE_IMPERIALE", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_FRENCH_GARDE_IMPERIALE", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning French colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_MELEE")
							break
						end
					end					
				end						
			end
		end
	elseif(sCivTypeName == "CIVILIZATION_GERMANY") then
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Germany is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}	
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyPlot(colonyPlots)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_FIELD_CANNON", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_FIELD_CANNON", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning German colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							SpawnUnit(PlayerID, adjacentPlot, 1, "PROMOTION_CLASS_NAVAL_MELEE")
							break
						end
					end	
				end			
			end
		end
	else
		print("Custom or modded civilization detected in ColonizerCivs table")
		print("Activating generic Colonization Mode for custom civilization: "..tostring(sCivTypeName))
		local tContinents = Map.GetContinentsInUse()
		for i,iContinent in ipairs(tContinents) do
			if (GameInfo.Continents[iContinent].ContinentType == "CONTINENT_AFRICA") then
				print("Generic or modded civilization is founding a new colony in Africa...")
				local colonyPlots = {}
				local sortedPlots = {}
				local selectedPlot = false	
				local plotScore = -100
				local coastalPlots = Map.GetContinentPlots(iContinent)
				colonyPlots = InitiateColonization_GetCoastalPlots(coastalPlots)
				selectedPlot = InitiateColonization_BestColonyMostDistant(colonyPlots, startingPlot)
				if selectedPlot then
					local pCity = pPlayer:GetCities():Create(selectedPlot:GetX(), selectedPlot:GetY())
					if pCity then
						local bHarbor = InitiateColonization_BuildHarborInColony(selectedPlot, pCity, sCivTypeName)
					else
						print("Failed to spawn city. Spawning settler instead.")
						UnitManager.InitUnit(PlayerID, "UNIT_SETTLER", selectedPlot:GetX(), selectedPlot:GetY())
					end
					UnitManager.InitUnitValidAdjacentHex(PlayerID, "UNIT_BUILDER", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_REDCOAT", selectedPlot:GetX(), selectedPlot:GetY())
					UnitManager.InitUnit(PlayerID, "UNIT_ENGLISH_REDCOAT", selectedPlot:GetX(), selectedPlot:GetY())
					print("Spawning Generic Civilization colonizer units at plot "..tostring(selectedPlot:GetX())..", "..tostring(selectedPlot:GetY()))
					--Spawn water units last (we're using a break statement)
					for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
						local adjacentPlot = Map.GetAdjacentPlot(selectedPlot:GetX(), selectedPlot:GetY(), direction)
						if adjacentPlot and adjacentPlot:IsWater() and not adjacentPlot:IsLake() then
							UnitManager.InitUnit(PlayerID, "UNIT_IRONCLAD", adjacentPlot:GetX(), adjacentPlot:GetY())
							break
						end
					end
				end			
			end
		end		
	end
	Game:SetProperty("Colonization_Wave03_Player_#"..PlayerID, 1)
	return selectedPlot
end