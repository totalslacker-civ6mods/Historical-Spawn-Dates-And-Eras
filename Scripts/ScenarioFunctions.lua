-- ===========================================================================
-- Scenario functions (optional scripted events)
-- ===========================================================================
--
include("UnitFunctions");

local bDramaticAges = GameConfiguration.GetValue("GAMEMODE_DRAMATICAGES")

function Notification_NewColony(iPlayer :number, pPlot :object)
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
local InvasionEuropeTribe = GameInfo.BarbarianTribes["TRIBE_INVASION_EUROPE"]

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
		bBarbarian = SpawnUniqueBarbarianTribe(campPlot, closestPlayerName)
	end
	return bBarbarian
end

function SpawnBarbsByContinent(campPlot)
	local bBarbarian = false
	local continentType = campPlot:GetContinentType()
	if continentType and GameInfo.Continents[continentType] then
		bBarbarian = SpawnUniqueBarbarianTribe(campPlot, GameInfo.Continents[continentType].ContinentType)
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

function SpawnUniqueBarbarianTribe(campPlot, sCivTypeName)
	print("Spawning a unique barbarian camp for "..tostring(sCivTypeName))
	local bBarbarian = false
	local bIsCoastalCamp = false
	local pBarbManager = Game.GetBarbarianManager() 
	local iRange = 3;
	local iUnitDifficulty = math.floor((iDifficulty/2))
	local iEra = ((Game.GetEras():GetCurrentEra()) + 1) --Game eras are zero indexed
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
					if ZuluBarbarianTribe then
						local iBarbarianTribeType = ZuluBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(ZuluBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Indian coast
					if BarbaryCoastTribe then
						local iBarbarianTribeType = BarbaryCoastTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(BarbaryCoastTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--North African coast
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Maghreb
					if BarbaryCoastTribe then
						local iBarbarianTribeType = BarbaryCoastTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(BarbaryCoastTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Libya
					if GreekBarbarianTribe then
						local iBarbarianTribeType = GreekBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(GreekBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
				if KongoBarbarianTribe then
					local iBarbarianTribeType = KongoBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(KongoBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			elseif(campPlot:GetY() < lowerHalf) then
				--Subsaharan Africa
				if ZuluBarbarianTribe then
					local iBarbarianTribeType = ZuluBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(ZuluBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--North Africa
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Mali
					if MaliBarbarianTribe then
						local iBarbarianTribeType = MaliBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaliBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Nubian
					if NubianBarbarianTribe then
						local iBarbarianTribeType = NubianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(NubianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
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
					if BarbaryCoastTribe then
						local iBarbarianTribeType = BarbaryCoastTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(BarbaryCoastTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Indochina
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Asia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Asia
					if ScythianBarbarianTribe then
						local iBarbarianTribeType = ScythianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(ScythianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--East Asia
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Asia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Middle East
					if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
						if VaruBarbarianTribe then
							local iBarbarianTribeType = VaruBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(VaruBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
						end
					else
						if PersianBarbarianTribe then
							local iBarbarianTribeType = PersianBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PersianBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
						end
					end
				else
					--Indochina
					if VaruBarbarianTribe then
						local iBarbarianTribeType = VaruBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(VaruBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Asia
				if campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index then
					if VaruBarbarianTribe then
						local iBarbarianTribeType = VaruBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(VaruBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				elseif ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Asia / Middle East
					if not ((campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_GRASS_HILLS"].Index) or (campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_PLAINS_HILLS"].Index) or (campPlot:GetTerrainType() == GameInfo.Terrains["TERRAIN_DESERT_HILLS"].Index)) then
						if ScythianBarbarianTribe then
							local iBarbarianTribeType = ScythianBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(ScythianBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
						end
					else
						if PersianBarbarianTribe then
							local iBarbarianTribeType = PersianBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PersianBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
						end
					end
				else
					--East Asia
					if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS_GRASSLAND"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FLOODPLAINS_PLAINS"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"].Index)) then
						if MongolBarbarianTribe then
							local iBarbarianTribeType = MongolBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MongolBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
						end
					else
						if EastAsianBarbarianTribe then
							local iBarbarianTribeType = EastAsianBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(EastAsianBarbarianTribe.TribeType))
						else
							print("Tribe type is nil")
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
					if AustralianTribe then
						local iBarbarianTribeType = AustralianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--NSW & Victoria
					if AustralianTribe then
						local iBarbarianTribeType = AustralianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Australia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Northern Territories
					if AustralianTribe then
						local iBarbarianTribeType = AustralianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Queensland
					if AustralianTribe then
						local iBarbarianTribeType = AustralianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Australia
				if AustralianTribe then
					local iBarbarianTribeType = AustralianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--Northern Australia
				if AustralianTribe then
					local iBarbarianTribeType = AustralianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AustralianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_EUROPE") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Western Mediterranean
					if GreekBarbarianTribe then
						local iBarbarianTribeType = GreekBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(GreekBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Eastern Mediterranean
					if GreekBarbarianTribe then
						local iBarbarianTribeType = GreekBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(GreekBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Europe
				if VikingBarbarianTribe then
					local iBarbarianTribeType = VikingBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(VikingBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					if CelticBarbarianTribe then
						local InvasionCamp = Game:GetProperty("InvasionCamp_"..campPlot:GetIndex())
						if not InvasionCamp then
							local iBarbarianTribeType = CelticBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(CelticBarbarianTribe.TribeType))
						else
							local iBarbarianTribeType = InvasionEuropeTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(InvasionEuropeTribe.TribeType))
							Game:SetProperty("InvasionCamp_"..campPlot:GetIndex(), false)
						end
					else
						print("Tribe type is nil")
					end
				else
					if BalkansBarbarianTribe then
						local InvasionCamp = Game:GetProperty("InvasionCamp_"..campPlot:GetIndex())
						if not InvasionCamp then
							local iBarbarianTribeType = BalkansBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(BalkansBarbarianTribe.TribeType))
						else
							local iBarbarianTribeType = InvasionEuropeTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(InvasionEuropeTribe.TribeType))
							Game:SetProperty("InvasionCamp_"..campPlot:GetIndex(), false)
						end
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Europe
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					if CelticBarbarianTribe then
						local InvasionCamp = Game:GetProperty("InvasionCamp_"..campPlot:GetIndex())
						if not InvasionCamp then
							local iBarbarianTribeType = CelticBarbarianTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(CelticBarbarianTribe.TribeType))
						else
							local iBarbarianTribeType = InvasionEuropeTribe.Index
							local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
							print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(InvasionEuropeTribe.TribeType))
							Game:SetProperty("InvasionCamp_"..campPlot:GetIndex(), false)
						end
					else
						print("Tribe type is nil")
					end
				else
					if SlavicBarbarianTribe then
						local iBarbarianTribeType = SlavicBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SlavicBarbarianTribe.TribeType))
						local InvasionCamp = Game:GetProperty("InvasionCamp_"..campPlot:GetIndex())
						if InvasionCamp then
							if (iDifficulty <= 2) then
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (2 + iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (1 + iEra), campPlot:GetIndex(), iRange)
							elseif(iDifficulty <= 4) then
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", iEra, campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (1 + iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (1 + iUnitDifficulty + iEra), campPlot:GetIndex(), iRange)
							elseif(iDifficulty >= 6) then
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SUPPORT", (1 + iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SIEGE", (1 + iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_SLAVIC", (3 * iEra), campPlot:GetIndex(), iRange)
								pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_BARB_VARANGIAN", (2 * iEra), campPlot:GetIndex(), iRange)
							end
							--Get tribe units and attack nearest city
							Game:SetProperty("InvasionCamp_"..campPlot:GetIndex(), false)
						end						
					else
						print("Tribe type is nil")
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
					if AztecBarbarianTribe then
						local iBarbarianTribeType = AztecBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AztecBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Atlantic Coast
					if PirateBarbarianTribe then
						local iBarbarianTribeType = PirateBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PirateBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern NA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Alaska / PNW
					if HaidaBarbarianTribe then
						local iBarbarianTribeType = HaidaBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(HaidaBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Quebec
					if CreeBarbarianTribe then
						local iBarbarianTribeType = CreeBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(CreeBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern NA
				if AztecBarbarianTribe then
					local iBarbarianTribeType = AztecBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(AztecBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--Northern NA
				if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_TUNDRA"].Index) or (campPlot:GetTerrainClassType() == GameInfo.TerrainClasses["TERRAIN_CLASS_SNOW"].Index)) then
					if ComancheBarbarianTribe then
						local iBarbarianTribeType = ComancheBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(ComancheBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					if CreeBarbarianTribe then
						local iBarbarianTribeType = CreeBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(CreeBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
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
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Easter Island
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Pacific
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Guam
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Hawaii
					if MaoriBarbarianTribe then
						local iBarbarianTribeType = MaoriBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Pacific
				if MaoriBarbarianTribe then
					local iBarbarianTribeType = MaoriBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--Northern Pacific
				if MaoriBarbarianTribe then
					local iBarbarianTribeType = MaoriBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_SIBERIA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Siberia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Russia
					if SiberianBarbarianTribe then
						local iBarbarianTribeType = SiberianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Far Eastern Russia
					if SiberianBarbarianTribe then
						local iBarbarianTribeType = SiberianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern Siberia
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Central Russia
					if SiberianBarbarianTribe then
						local iBarbarianTribeType = SiberianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Far Eastern Russia
					if SiberianBarbarianTribe then
						local iBarbarianTribeType = SiberianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern Siberia
				if SiberianBarbarianTribe then
					local iBarbarianTribeType = SiberianBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--Northern Siberia
				if SiberianBarbarianTribe then
					local iBarbarianTribeType = SiberianBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SiberianBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_SOUTH_AMERICA") then
		if bIsCoastalCamp then
			if (campPlot:GetY() < lowerHalf) then
				--Southern SA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Pacific Coast
					if PatagonianBarbarianTribe then
						local iBarbarianTribeType = PatagonianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PatagonianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--Atlantic Coast
					if PatagonianBarbarianTribe then
						local iBarbarianTribeType = PatagonianBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PatagonianBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			else
				--Northern SA
				if ((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX))) then
					--Colombian Coast
					if IncanBarbarianTribe then
						local iBarbarianTribeType = IncanBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(IncanBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					--North Brazilian Coast
					if SouthAmericanTribe then
						local iBarbarianTribeType = SouthAmericanTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SouthAmericanTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		elseif(not bIsCoastalCamp) then
			if (campPlot:GetY() < lowerHalf) then
				--Southern SA
				if PatagonianBarbarianTribe then
					local iBarbarianTribeType = PatagonianBarbarianTribe.Index
					local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
					print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(PatagonianBarbarianTribe.TribeType))
				else
					print("Tribe type is nil")
				end
			else
				--Northern SA
				if not ((campPlot:GetFeatureType() == GameInfo.Features["FEATURE_FOREST"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_JUNGLE"].Index) or (campPlot:GetFeatureType() == GameInfo.Features["FEATURE_MARSH"].Index)) or (((campPlot:GetX() < rightHalf) and (campPlot:GetX() >= baseX)) or ((baseX > rightHalf) and ((campPlot:GetX() < rightHalf) or (campPlot:GetX() >= baseX)))) then
					if IncanBarbarianTribe then
						local iBarbarianTribeType = IncanBarbarianTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(IncanBarbarianTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				else
					if SouthAmericanTribe then
						local iBarbarianTribeType = SouthAmericanTribe.Index
						local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
						print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(SouthAmericanTribe.TribeType))
					else
						print("Tribe type is nil")
					end
				end
			end
		end
	elseif(sCivTypeName == "CONTINENT_ZEALANDIA") then
		if bIsCoastalCamp then
			if MaoriBarbarianTribe then
				local iBarbarianTribeType = MaoriBarbarianTribe.Index
				local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
				print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
			else
				print("Tribe type is nil")
			end
		elseif(not bIsCoastalCamp) then
			if MaoriBarbarianTribe then
				local iBarbarianTribeType = MaoriBarbarianTribe.Index
				local iBarbarianTribe = CreateTribeAt(iBarbarianTribeType, campPlot:GetIndex())
				print("Spawning tribe #"..tostring(iBarbarianTribeType)..", "..tostring(MaoriBarbarianTribe.TribeType))
			else
				print("Tribe type is nil")
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
	if sCivTypeName == "CIVILIZATION_KONGO" then
		local eBarbarianTribeType = 3 --Kongo
		local iBarbarianTribe = CreateTribeAt(eBarbarianTribeType, campPlot:GetIndex())
		pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_MELEE", 2, campPlot:GetIndex(), iRange);
		pBarbManager:CreateTribeUnits(iBarbarianTribe, "CLASS_RANGED", 1, campPlot:GetIndex(), iRange);
	end
	return bBarbarian
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
function RemoveBarbScouts( playerID:number, unitID:number )
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