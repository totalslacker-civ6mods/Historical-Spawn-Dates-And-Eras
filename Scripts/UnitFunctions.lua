-- ===========================================================================
-- Helper functions related to unit spawns
-- ===========================================================================

function CreateUnitWithExp(unitType, expFactor, pPlayerUnits, pPlot)
	local pUnit = pPlayerUnits:Create(GameInfo.Units[unitType].Index, pPlot:GetX(), pPlot:GetY())
	local iXP = expFactor * (pUnit:GetExperience():GetExperienceForNextLevel() - pUnit:GetExperience():GetExperiencePoints())
	pUnit:GetExperience():ChangeExperience(iXP)	
	-- print("CreateUnitWithExp created a unit")
	return true
end

function GetPlayerTraits(iPlayer, sTrait)
	local pPlayer = Players[iPlayer]
	local playerTraits = {}
	local bHasTrait = false
	local sLeaderTypeName = PlayerConfigurations[iPlayer]:GetLeaderTypeName()
	for trait in GameInfo.LeaderTraits() do
		if (trait.LeaderType == sLeaderTypeName) and (trait.TraitType == sTrait) then
			playerTraits[iPlayer] = Players[iPlayer]
			bHasTrait = true
		end
	end
	if not playerTraits[iPlayer] then
		local sCivTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
		for trait in GameInfo.CivilizationTraits() do
			if (trait.CivilizationType == sCivTypeName) and (trait.TraitType == sTrait) then
				playerTraits[iPlayer] = Players[iPlayer]
				bHasTrait = true
			end
		end
	end
	return bHasTrait
end

function GetMostAdvancedUnit(iPlayer, promotionClass)
	print("Return UnitType of most advanced unit "..tostring(PlayerConfigurations[iPlayer]:GetLeaderTypeName()).." can build from promotion class "..tostring(promotionClass))
	local pPlayer = Players[iPlayer]
	local pScience = pPlayer:GetTechs()
	local playerTechs = {}
	local iTechCost = -1
	local pCulture = pPlayer:GetCulture()
	local playerCivics = {}
	local iCivicCost = -1
	local selectedUnit = false
	-- print("Gather list of techs known by player")
	for kTech in GameInfo.Technologies() do		
		local iTech	= kTech.Index
		if pScience:HasTech(iTech) then
			if not playerTechs[iTech] then playerTechs[iTech] = 0 end
			playerTechs[iTech] = playerTechs[iTech] + 1
		end
	end
	-- print("Gather list of civics known by player")
	for kCivic in GameInfo.Civics() do		
		local iCivic = kCivic.Index
		if pCulture:HasCivic(iCivic) then
			if not playerCivics[iCivic] then playerCivics[iCivic] = 0 end
			playerCivics[iCivic] = playerCivics[iCivic] + 1
		end
	end
	-- print("Check prereq tech for all units in promotion class against techs known by player")
	for kUnit in GameInfo.Units() do
		-- local iUnit = kUnit.Index
		if kUnit and kUnit.PromotionClass and (kUnit.PromotionClass == promotionClass) then
			local bUnitHasTrait = false
			local bCivHasTrait = false
			if kUnit.TraitType then bUnitHasTrait = true end
			if GetPlayerTraits(iPlayer, kUnit.TraitType) then bCivHasTrait = true end
			if (not kUnit.PrereqTech) and (not kUnit.PrereqCivic) then
				-- print("Check for starting units")
				if bUnitHasTrait and not bCivHasTrait then
					print("Unique unit not available to player")
				else
					if (iTechCost < 0) then
						iTechCost = 0
						selectedUnit = kUnit.UnitType
					elseif(iTechCost == 0) then
						if bUnitHasTrait then
							selectedUnit = kUnit.UnitType
						end
					end
				end
			elseif(kUnit.PrereqTech and playerTechs[GameInfo.Technologies[kUnit.PrereqTech].Index]) then
				if bUnitHasTrait and not bCivHasTrait then
					print("Unique unit not available to player")
				else
					if (GameInfo.Technologies[kUnit.PrereqTech].Cost > iTechCost) then
						iTechCost = GameInfo.Technologies[kUnit.PrereqTech].Cost
						selectedUnit = kUnit.UnitType
					elseif(GameInfo.Technologies[kUnit.PrereqTech].Cost == iTechCost) then
						if bUnitHasTrait then
							selectedUnit = kUnit.UnitType
						end
					end
				end
			elseif(kUnit.PrereqCivic and playerCivics[GameInfo.Civics[kUnit.PrereqCivic].Index]) then
				if bUnitHasTrait and not bCivHasTrait then
					print("Unique unit not available to player")
				else
					if ((GameInfo.Units[kUnit.UnitType].MandatoryObsoleteTech and not playerTechs[GameInfo.Technologies[(GameInfo.Units[kUnit.UnitType].MandatoryObsoleteTech)].Index]) or (not GameInfo.Units[kUnit.UnitType].MandatoryObsoleteTech)) and ((GameInfo.UnitUpgrades[kUnit.UnitType] and not playerTechs[GameInfo.Technologies[(GameInfo.Units[(GameInfo.UnitUpgrades[kUnit.UnitType].UpgradeUnit)].PrereqTech)].Index]) or (not GameInfo.UnitUpgrades[kUnit.UnitType])) then
						if (GameInfo.Civics[kUnit.PrereqCivic].Cost > iCivicCost) then
							iCivicCost = GameInfo.Civics[kUnit.PrereqCivic].Cost
							selectedUnit = kUnit.UnitType
						elseif(GameInfo.Civics[kUnit.PrereqCivic].Cost == iCivicCost) then
							if bUnitHasTrait then
								selectedUnit = kUnit.UnitType
							end
						end
					end
				end
			end
		end
	end
	if selectedUnit then
		-- print("Check for unique unit replacements")
		local bCivHasTrait = false
		for kUnit in GameInfo.UnitReplaces() do
			if kUnit and (kUnit.ReplacesUnitType == selectedUnit) then
				local unitTrait = GameInfo.Units[kUnit.CivUniqueUnitType].TraitType
				if GetPlayerTraits(iPlayer, unitTrait) then bCivHasTrait = true end
				if bCivHasTrait then
					selectedUnit = kUnit.CivUniqueUnitType
				end
			end
		end
		print("Found most advanced unit: "..tostring(selectedUnit))
		return selectedUnit
	else
		print("WARNING: No unit could be found! Returning boolean false")
		return selectedUnit
	end
end

-- ===========================================================================
-- Main functions related to unit spawns
-- ===========================================================================

--Isolated player starting units
function IsolatedPlayerSeige(iPlayer, startingPlot, isolatedSpawn, CivilizationTypeName)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local pTreasury = pPlayer:GetTreasury()
	local gameCurrentEra = Game.GetEras():GetCurrentEra()
	if not gameCurrentEra then gameCurrentEra = 0 end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_AZTEC" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_AZTEC_EAGLE_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_AZTEC_EAGLE_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_AZTEC_EAGLE_WARRIOR", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_AZTEC_EAGLE_WARRIOR", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_CREE" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_HORSEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_HORSEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CREE_OKIHTCITAW", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CREE_OKIHTCITAW", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAORI" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_MAORI_TOA", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_MAORI_TOA", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_MAORI_TOA", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_MAORI_TOA", gameCurrentEra, pPlayerUnits, startingPlot)
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAORI_TOA", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAORI_TOA", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAORI_TOA", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAORI_TOA", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAYA" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_MAYAN_HULCHE", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_MAYAN_HULCHE", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAYAN_HULCHE", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAYAN_HULCHE", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_INCA" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_INCA_WARAKAQ", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_INCA_WARAKAQ", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_PIKEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_PIKEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			if gameCurrentEra >= 2 then
				for i = 0, gameCurrentEra - 1, 1 do
					CreateUnitWithExp("UNIT_INCA_WARAKAQ", gameCurrentEra, pPlayerUnits, startingPlot)
				end
			end
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_INCA_WARAKAQ", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_INCA_WARAKAQ", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAPUCHE" then
		if gameCurrentEra > 0 then
			pTreasury:ChangeGoldBalance(gameCurrentEra * 100)
			CreateUnitWithExp("UNIT_PIKEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_PIKEMAN", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
			CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		else
			pTreasury:ChangeGoldBalance(100)
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", startingPlot:GetX(), startingPlot:GetY())
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", startingPlot:GetX(), startingPlot:GetY())
			print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
			return true		
		end
	end
	return false
end

-- Starting units for all players, called by SpawnPlayer
function EraSiegeUnits(iPlayer, pPlot, currentGameEra, settlersBonus)
	local player = Players[iPlayer]
	local playerResources = player:GetResources()	
	local startingPlot = player:GetStartingPlot()
	local reconPlot = PlayerBuffer(startingPlot)
	local currentEra = currentGameEra
	
	print(" - Settlers = "..tostring(settlersBonus))
	if settlersBonus > 0  then
		for i = 0, settlersBonus - 1, 1 do
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SETTLER", pPlot:GetX(), pPlot:GetY())
			print(" - UNIT_SETTLER spawned")
		end
	end
	
	-- print("Spawning default starting units")	
	-- for kUnits in GameInfo.MajorStartingUnits() do
		-- if GameInfo.Eras[kUnits.Era].Index == gameCurrentEra and not kUnits.OnDistrictCreated and not kUnits.AiOnly then
			-- local numUnit = math.max(kUnits.Quantity, 1)	
			-- for i = 0, numUnit - 1, 1 do
				-- UnitManager.InitUnitValidAdjacentHex(iPlayer, kUnits.Unit, pPlot:GetX(), pPlot:GetY())
				-- print(" - "..tostring(kUnits.Unit).." = "..tostring(numUnit))
			-- end
		-- end
	-- end	
	
	if bSubtractEra then
		currentEra = currentEra - 1
	end
	if currentEra == -1 then
		--Ancient Era (Lesser Era mode)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SLINGER", pPlot:GetX(), pPlot:GetY())
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", pPlot:GetX(), pPlot:GetY())
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", pPlot:GetX(), pPlot:GetY())
		return true 
	end	
	if currentEra == 0 then
		--Ancient Era
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		return true 
	end
	if currentEra == 1 then
		--Classical Era
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_HORSES'].Index, 20)		
		end
		SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		if iDifficulty > 3 then
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		if iDifficulty > 5 then
			SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		end
		return true 
	end		
	if currentEra == 2 then
		--Medieval Era
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_HORSES'].Index, 20)		
		end
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		if iDifficulty > 3 then
			SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		if iDifficulty > 4 then
			SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		end
		if iDifficulty > 5 then
			SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		end
		return true 
	end		
	if currentEra == 3 then
		--Renaissance
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 40)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_NITER'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_HORSES'].Index, 40)		
		end
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		if iDifficulty > 3 then
			SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		if iDifficulty > 4 then
			SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		end
		if iDifficulty > 5 then
			SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		end
		return true 
	end
	if currentEra == 4 then
		--Industrial
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_NITER'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_HORSES'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_COAL'].Index, 40)
		end
		SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		return true 
	end
	if currentEra == 5 then
		--Modern
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 40)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_NITER'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_HORSES'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_COAL'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_OIL'].Index, 40)
		end
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		return true 
	end
	if currentEra == 6 then
		--Atomic
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_COAL'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_OIL'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_URANIUM'].Index, 10)		
		end
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_TANK", pPlot:GetX(), pPlot:GetY())	
		return true 
	end		
	if currentEra == 7 then
		--Information
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_COAL'].Index, 40)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_OIL'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_ALUMINUM'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_URANIUM'].Index, 20)		
		end
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ANTIAIR_GUN", pPlot:GetX(), pPlot:GetY())	
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MODERN_ARMOR", pPlot:GetX(), pPlot:GetY())			
		return true 
	end
	if currentEra == 8 then
		--Future
		if bGatheringStormActive then
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_IRON'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_COAL'].Index, 20)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_OIL'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_ALUMINUM'].Index, 60)
			playerResources:ChangeResourceAmount(GameInfo.Resources['RESOURCE_URANIUM'].Index, 60)			
		end
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Siege(iPlayer, pPlot, currentEra)
		SpawnUnit_Recon(iPlayer, reconPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MOBILE_SAM", pPlot:GetX(), pPlot:GetY())
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MODERN_ARMOR", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	return false
end

--Units that spawn in converted cities
function ConvertCitiesUnits(iPlayer, pPlot, currentGameEra)
	local player = Players[iPlayer]
	local startingPlot = player:GetStartingPlot()
	local currentEra = currentGameEra
	if iDifficulty <= 3 then
		print("Do not spawn extra units in converted city for difficulty less than King")
		return false
	end
	if bSubtractEra then
		currentEra = currentEra - 1
	end
	if currentEra == -1 then
		--Ancient Era (Lesser Era mode)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", pPlot:GetX(), pPlot:GetY())
		return true 
	end	
	if currentEra == 0 then
		--Ancient Era
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		end
		return true 
	end
	if currentEra == 1 then
		--Classical Era
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		return true 
	end		
	if currentEra == 2 then
		--Medieval Era
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		return true 
	end		
	if currentEra == 3 then
		--Renaissance
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Melee(iPlayer, pPlot, currentEra)
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		return true 
	end
	if currentEra == 4 then
		--Industrial
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Melee(iPlayer, pPlot, currentEra)
			SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
		end
		return true 
	end
	if currentEra == 5 then
		--Modern
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		if iDifficulty > 4 then
			SpawnUnit_Melee(iPlayer, pPlot, currentEra)
			SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		end
		return true 
	end
	if currentEra == 6 then
		--Atomic
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_TANK", pPlot:GetX(), pPlot:GetY())	
		if iDifficulty > 4 then
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_TANK", pPlot:GetX(), pPlot:GetY())	
		end
		return true 
	end		
	if currentEra == 7 then
		--Information
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ANTIAIR_GUN", pPlot:GetX(), pPlot:GetY())	
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MODERN_ARMOR", pPlot:GetX(), pPlot:GetY())	
		if iDifficulty > 4 then
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MODERN_ARMOR", pPlot:GetX(), pPlot:GetY())	
		end		
		return true 
	end
	if currentEra == 8 then
		--Future
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		SpawnUnit_Melee(iPlayer, pPlot, currentEra)
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MOBILE_SAM", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	return false
end

-- Used to spawn any extra units specific to a civilization (there could be any amount of logic used here, 
-- currently gives a starting unique unit to isolated civilizations)
function UnitSpawns(iPlayer, startingPlot, isolatedSpawn, CivilizationTypeName)
	local gameCurrentEra = Game.GetEras():GetCurrentEra()
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_AZTEC" then
		CreateUnitWithExp("UNIT_AZTEC_EAGLE_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_AZTEC_EAGLE_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_CREE" then
		CreateUnitWithExp("UNIT_CREE_OKIHTCITAW", (2 * gameCurrentEra), pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_CREE_OKIHTCITAW", (2 * gameCurrentEra), pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_CREE_OKIHTCITAW", (2 * gameCurrentEra), pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_CREE_OKIHTCITAW", (2 * gameCurrentEra), pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAORI" then
		CreateUnitWithExp("UNIT_MAORI_TOA", gameCurrentEra, pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAYA" then
		CreateUnitWithExp("UNIT_MAYAN_HULCHE", gameCurrentEra, pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_INCA" then
		CreateUnitWithExp("UNIT_INCA_WARAKAQ", gameCurrentEra, pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	if isolatedSpawn and CivilizationTypeName == "CIVILIZATION_MAPUCHE" then
		CreateUnitWithExp("UNIT_SPEARMAN", gameCurrentEra, pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_ARCHER", gameCurrentEra, pPlayerUnits, startingPlot)
		CreateUnitWithExp("UNIT_WARRIOR", gameCurrentEra, pPlayerUnits, startingPlot)
		UnitManager.InitUnit(iPlayer, "UNIT_BUILDER", startingPlot:GetX(), startingPlot:GetY())
		if gameCurrentEra >= 3 then
			for i = 0, gameCurrentEra - 1, 1 do
				CreateUnitWithExp("UNIT_MAPUCHE_MALON_RAIDER", gameCurrentEra, pPlayerUnits, startingPlot)
			end
		end
		print("Spawning units for " ..tostring(CivilizationTypeName) .. " at " ..tostring(startingPlot:GetX()) ..", " ..tostring(startingPlot:GetY()))
		return true
	end
	return false
end

function SpawnUnit_AntiCav(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_GREECE" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_GREEK_HOPLITE", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SCYTHIAN_HORSE_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", pPlot:GetX(), pPlot:GetY())
				return true
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 1 then
		--Classical Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_GREECE" then
				CreateUnitWithExp("UNIT_GREEK_HOPLITE", 1, pPlayerUnits, pPlot)
				return true		
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				CreateUnitWithExp("UNIT_SCYTHIAN_HORSE_ARCHER", 1, pPlayerUnits, pPlot)
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SPEARMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 2 then
		--Medieval Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_ZULU" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ZULU_IMPI", pPlot:GetX(), pPlot:GetY())
				return true		
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PIKEMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PIKEMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_SWEDEN" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SWEDEN_CAROLEAN", pPlot:GetX(), pPlot:GetY())
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 1, pPlayerUnits, pPlot)
				return true					
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PIKE_AND_SHOT", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PIKE_AND_SHOT", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_SWEDEN" then
				CreateUnitWithExp("UNIT_SWEDEN_CAROLEAN", 3, pPlayerUnits, pPlot)
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 3, pPlayerUnits, pPlot)
				return true		
			else
				CreateUnitWithExp("UNIT_PIKE_AND_SHOT", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_PIKE_AND_SHOT", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 5 then
		--Modern Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_AT_CREW", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 6 then
		--Atomic Era
		CreateUnitWithExp("UNIT_AT_CREW", 3, pPlayerUnits, pPlot)
		return true 
	end
	if currentEra == 7 then
		--Information Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MODERN_AT", pPlot:GetX(), pPlot:GetY())
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		CreateUnitWithExp("UNIT_MODERN_AT", 3, pPlayerUnits, pPlot)
		return true 	
	end
end

function SpawnUnit_Cavalry(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_EGYPT" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_EGYPTIAN_CHARIOT_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SCYTHIAN_HORSE_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HEAVY_CHARIOT", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HEAVY_CHARIOT", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 1 then
		--Classical Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_EGYPT" then
				CreateUnitWithExp("UNIT_EGYPTIAN_CHARIOT_ARCHER", 1, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_INDIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_INDIAN_VARU", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MACEDON") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MACEDONIAN_HETAIROI", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				CreateUnitWithExp("UNIT_SCYTHIAN_HORSE_ARCHER", 1, pPlayerUnits, pPlot)
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HORSEMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HORSEMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 2 then
		--Medieval Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_ARABIA" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARABIAN_MAMLUK", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_BYZANTIUM" and GameInfo.Units['UNIT_BYZANTINE_TAGMA'].Index ~= nil) then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_BYZANTINE_TAGMA", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ETHIOPIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ETHIOPIAN_OROMO_CAVALRY", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_HUNGARY") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HUNGARY_BLACK_ARMY", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_INDIA") then
				CreateUnitWithExp("UNIT_INDIAN_VARU", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_JAPAN") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_JAPANESE_SAMURAI", pPlot:GetX(), pPlot:GetY())
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_MACEDON") then
				CreateUnitWithExp("UNIT_MACEDONIAN_HETAIROI", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MALI") then
				CreateUnitWithExp("UNIT_MALI_MANDEKALU_CAVALRY", 1, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_POLAND") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_POLISH_HUSSAR", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ZULU_IMPI", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KNIGHT", pPlot:GetX(), pPlot:GetY())
				return true
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KNIGHT", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_ARABIA" then
				CreateUnitWithExp("UNIT_ARABIAN_MAMLUK", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_BYZANTIUM" and GameInfo.Units['UNIT_BYZANTINE_TAGMA'].Index ~= nil) then
				CreateUnitWithExp("UNIT_BYZANTINE_TAGMA", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ETHIOPIA") then
				CreateUnitWithExp("UNIT_ETHIOPIAN_OROMO_CAVALRY", 3, pPlayerUnits, pPlot)
				return true				
			elseif(CivilizationTypeName == "CIVILIZATION_HUNGARY") then
				CreateUnitWithExp("UNIT_HUNGARY_BLACK_ARMY", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MALI") then
				CreateUnitWithExp("UNIT_MALI_MANDEKALU_CAVALRY", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_POLAND") then
				CreateUnitWithExp("UNIT_POLISH_HUSSAR", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 1, pPlayerUnits, pPlot)
				return true				
			else
				CreateUnitWithExp("UNIT_KNIGHT", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_KNIGHT", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_AMERICA" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_AMERICAN_ROUGH_RIDER", pPlot:GetX(), pPlot:GetY())
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_CANADA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CANADA_MOUNTIE", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_GRAN_COLOMBIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_COLOMBIAN_LLANERO", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_HUNGARY") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HUNGARY_HUSZAR", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_RUSSIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_RUSSIAN_COSSACK", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 4, pPlayerUnits, pPlot)
				return true					
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CAVALRY", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CAVALRY", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 5 then
		--Modern Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_AMERICA" then
				CreateUnitWithExp("UNIT_AMERICAN_ROUGH_RIDER", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_CANADA") then
				CreateUnitWithExp("UNIT_CANADA_MOUNTIE", 3, pPlayerUnits, pPlot)
				return true				
			elseif(CivilizationTypeName == "CIVILIZATION_GRAN_COLOMBIA") then
				CreateUnitWithExp("UNIT_COLOMBIAN_LLANERO", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_HUNGARY") then
				CreateUnitWithExp("UNIT_HUNGARY_HUSZAR", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_RUSSIA") then
				CreateUnitWithExp("UNIT_RUSSIAN_COSSACK", 3, pPlayerUnits, pPlot)
				return true				
			else
				CreateUnitWithExp("UNIT_CAVALRY", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_CAVALRY", 3, pPlayerUnits, pPlot)
			return true 		
		end 
	end
	if currentEra == 6 then
		--Atomic Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HELICOPTER", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 7 then
		--Information Era
		CreateUnitWithExp("UNIT_HELICOPTER", 1, pPlayerUnits, pPlot)
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		CreateUnitWithExp("UNIT_HELICOPTER", 3, pPlayerUnits, pPlot)
		return true 	
	end
end

function SpawnUnit_Melee(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_AZTEC" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_AZTEC_EAGLE_WARRIOR", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_GAUL" and GameInfo.Units['UNIT_GAUL_GAESATAE']) then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_GAUL_GAESATAE", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_WARRIOR", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 1 then
		--Classical Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_GREECE" then
				local sUnitType = GetMostAdvancedUnit(iPlayer, "PROMOTION_CLASS_ANTI_CAVALRY")
				-- CreateUnitWithExp("UNIT_GREEK_HOPLITE", 1, pPlayerUnits, pPlot)
				if sUnitType then
					CreateUnitWithExp(sUnitType, 1, pPlayerUnits, pPlot)
				else
					print("sUnitType was false")
				end
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_GAUL" and GameInfo.Units['UNIT_GAUL_GAESATAE']) then
				CreateUnitWithExp("UNIT_GAUL_GAESATAE", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_KONGO") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KONGO_SHIELD_BEARER", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MACEDON") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MACEDONIAN_HYPASPIST", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MAORI") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAORI_TOA", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MONGOLIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HORSEMAN", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_NORWAY") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_NORWEGIAN_BERSERKER", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_PERSIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PERSIAN_IMMORTAL", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ROME") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ROMAN_LEGION", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_HORSEMAN", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SWORDSMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SWORDSMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 2 then
		--Medieval Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_GEORGIA" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_GEORGIAN_KHEVSURETI", pPlot:GetX(), pPlot:GetY())
				return true		
			elseif(CivilizationTypeName == "CIVILIZATION_JAPAN") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_JAPANESE_SAMURAI", pPlot:GetX(), pPlot:GetY())
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_KONGO") then
				CreateUnitWithExp("UNIT_KONGO_SHIELD_BEARER", 3, pPlayerUnits, pPlot)
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_MACEDON") then
				CreateUnitWithExp("UNIT_MACEDONIAN_HYPASPIST", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MONGOLIA") then
				if bGatheringStormActive then
					CreateUnitWithExp("UNIT_COURSER", 1, pPlayerUnits, pPlot)
				else
					CreateUnitWithExp("UNIT_HORSEMAN", 3, pPlayerUnits, pPlot)
				end
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_NORWAY") then
				CreateUnitWithExp("UNIT_NORWEGIAN_BERSERKER", 1, pPlayerUnits, pPlot)
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_PERSIA") then
				CreateUnitWithExp("UNIT_PERSIAN_IMMORTAL", 3, pPlayerUnits, pPlot)
				return true				
			elseif(CivilizationTypeName == "CIVILIZATION_ROME") then
				CreateUnitWithExp("UNIT_ROMAN_LEGION", 3, pPlayerUnits, pPlot)
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				if bGatheringStormActive then
					CreateUnitWithExp("UNIT_COURSER", 1, pPlayerUnits, pPlot)
				else
					CreateUnitWithExp("UNIT_HORSEMAN", 3, pPlayerUnits, pPlot)
				end
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ZULU_IMPI", pPlot:GetX(), pPlot:GetY())
				return true					
			else
				CreateUnitWithExp("UNIT_MAN_AT_ARMS", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_MAN_AT_ARMS", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_GEORGIA" then
				CreateUnitWithExp("UNIT_GEORGIAN_KHEVSURETI", 3, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_OTTOMAN") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SULEIMAN_JANISSARY", pPlot:GetX(), pPlot:GetY())
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_JAPAN") then
				CreateUnitWithExp("UNIT_JAPANESE_SAMURAI", 3, pPlayerUnits, pPlot)
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_KONGO") then
				CreateUnitWithExp("UNIT_KONGO_SHIELD_BEARER", 4, pPlayerUnits, pPlot)
				return true 				
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 1, pPlayerUnits, pPlot)
				return true					
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MUSKETMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MUSKETMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_FRANCE" then
				CreateUnitWithExp("UNIT_FRENCH_GARDE_IMPERIALE", 1, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_ENGLAND") then
				CreateUnitWithExp("UNIT_ENGLISH_REDCOAT", 1, pPlayerUnits, pPlot)
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_OTTOMAN") then
				CreateUnitWithExp("UNIT_SULEIMAN_JANISSARY", 3, pPlayerUnits, pPlot)
				return true 
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				CreateUnitWithExp("UNIT_ZULU_IMPI", 4, pPlayerUnits, pPlot)
				return true	
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_LINE_INFANTRY", pPlot:GetX(), pPlot:GetY())
				return true 
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_LINE_INFANTRY", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 5 then
		--Modern Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_AUSTRALIA" then
				CreateUnitWithExp("UNIT_DIGGER", 3, pPlayerUnits, pPlot)
				return true
			else
				CreateUnitWithExp("UNIT_INFANTRY", 3, pPlayerUnits, pPlot)
				return true 
			end
		else
			CreateUnitWithExp("UNIT_INFANTRY", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 6 then
		--Atomic Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_AUSTRALIA" then
				CreateUnitWithExp("UNIT_DIGGER", 6, pPlayerUnits, pPlot)
				return true
			else
				CreateUnitWithExp("UNIT_INFANTRY", 6, pPlayerUnits, pPlot)
				return true 
			end
		else
			CreateUnitWithExp("UNIT_INFANTRY", 6, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 7 then
		--Information Era
		CreateUnitWithExp("UNIT_MECHANIZED_INFANTRY", 3, pPlayerUnits, pPlot)
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		if bGatheringStormActive then
			--GDR does not earn experience
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_GIANT_DEATH_ROBOT", pPlot:GetX(), pPlot:GetY())
			return true
		else
			CreateUnitWithExp("UNIT_MECHANIZED_INFANTRY", 6, pPlayerUnits, pPlot)
			return true 
		end	
	end
end

function SpawnUnit_Ranged(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_EGYPT" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_EGYPTIAN_CHARIOT_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_NUBIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_NUBIAN_PITATI", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_MAYA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MAYAN_HULCHE", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_SCYTHIAN_HORSE_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 1 then
		--Classical Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_EGYPT" then
				CreateUnitWithExp("UNIT_EGYPTIAN_CHARIOT_ARCHER", 1, pPlayerUnits, pPlot)
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_NUBIA") then
				CreateUnitWithExp("UNIT_NUBIAN_PITATI", 1, pPlayerUnits, pPlot)
				return true				
			elseif(CivilizationTypeName == "CIVILIZATION_MAYA") then
				CreateUnitWithExp("UNIT_MAYAN_HULCHE", 1, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_PERSIA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_PERSIAN_IMMORTAL", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_SCYTHIA") then
				CreateUnitWithExp("UNIT_SCYTHIAN_HORSE_ARCHER", 1, pPlayerUnits, pPlot)
				return true
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARCHER", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 2 then
		--Medieval Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_KHMER" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KHMER_DOMREY", pPlot:GetX(), pPlot:GetY())
				return true 
			elseif CivilizationTypeName == "CIVILIZATION_KOREA" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KOREAN_HWACHA", pPlot:GetX(), pPlot:GetY())
				return true
			elseif CivilizationTypeName == "CIVILIZATION_VIETNAM" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_VIETNAMESE_VOI_CHIEN", pPlot:GetX(), pPlot:GetY())
				return true	
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CROSSBOWMAN", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CROSSBOWMAN", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_KOREA" then
				CreateUnitWithExp("UNIT_KOREAN_HWACHA", 3, pPlayerUnits, pPlot)
				return true
			elseif CivilizationTypeName == "CIVILIZATION_VIETNAM" then
				CreateUnitWithExp("UNIT_VIETNAMESE_VOI_CHIEN", 3, pPlayerUnits, pPlot)
				return true					
			else
				CreateUnitWithExp("UNIT_CROSSBOWMAN", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_CROSSBOWMAN", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_SWEDEN" then
				--Placeholder, no unique Industrial Era ranged units
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_FIELD_CANNON", pPlot:GetX(), pPlot:GetY())
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_ZULU") then
				--Placeholder, no unique Industrial Era ranged units
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_FIELD_CANNON", pPlot:GetX(), pPlot:GetY())
				return true		
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_FIELD_CANNON", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_FIELD_CANNON", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 5 then
		--Modern Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_MACHINE_GUN", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 6 then
		--Atomic Era
		CreateUnitWithExp("UNIT_MACHINE_GUN", 1, pPlayerUnits, pPlot)
		return true 
	end
	if currentEra == 7 then
		--Information Era
		CreateUnitWithExp("UNIT_MACHINE_GUN", 3, pPlayerUnits, pPlot)
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		CreateUnitWithExp("UNIT_MACHINE_GUN", 6, pPlayerUnits, pPlot)
		return true 	
	end
end

function SpawnUnit_Recon(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_CREE" then
				UnitManager.InitUnit(iPlayer, "UNIT_CREE_OKIHTCITAW", pPlot:GetX(), pPlot:GetY())
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_BABYLON_STK") then
				UnitManager.InitUnit(iPlayer, "UNIT_BABYLONIAN_SABUM_KIBITTUM", pPlot:GetX(), pPlot:GetY())
				return true	
			else
				UnitManager.InitUnit(iPlayer, "UNIT_SCOUT", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnit(iPlayer, "UNIT_SCOUT", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 1 then
		--Classical Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_CREE" then
				CreateUnitWithExp("UNIT_CREE_OKIHTCITAW", 2, pPlayerUnits, pPlot)
				return true	
			elseif(CivilizationTypeName == "CIVILIZATION_BABYLON_STK") then
				CreateUnitWithExp("UNIT_BABYLONIAN_SABUM_KIBITTUM", 2, pPlayerUnits, pPlot)
				return true					
			else
				CreateUnitWithExp("UNIT_SCOUT", 2, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_SCOUT", 2, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 2 then
		--Medieval Era
		if not bGatheringStormActive then
			CreateUnitWithExp("UNIT_SCOUT", 4, pPlayerUnits, pPlot)
			return true
		end
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_INCA" then
				CreateUnitWithExp("UNIT_INCA_WARAKAQ", 2, pPlayerUnits, pPlot)
				return true		
			else
				CreateUnitWithExp("UNIT_SKIRMISHER", 2, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_SKIRMISHER", 2, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if not bGatheringStormActive then
			CreateUnitWithExp("UNIT_SCOUT", 6, pPlayerUnits, pPlot)
			return true
		end
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_INCA" then
				CreateUnitWithExp("UNIT_INCA_WARAKAQ", 4, pPlayerUnits, pPlot)
				return true					
			else
				CreateUnitWithExp("UNIT_SKIRMISHER", 4, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_SKIRMISHER", 4, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_SCOTLAND" then
				CreateUnitWithExp("UNIT_SCOTTISH_HIGHLANDER", 3, pPlayerUnits, pPlot)
				return true		
			else
				CreateUnitWithExp("UNIT_RANGER", 3, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_RANGER", 3, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 5 then
		--Modern Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_SCOTLAND" then
				CreateUnitWithExp("UNIT_SCOTTISH_HIGHLANDER", 6, pPlayerUnits, pPlot)
				return true		
			else
				CreateUnitWithExp("UNIT_RANGER", 6, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_RANGER", 6, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 6 then
		--Atomic Era
		UnitManager.InitUnit(iPlayer, "UNIT_SPEC_OPS", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 7 then
		--Information Era
		CreateUnitWithExp("UNIT_SPEC_OPS", 3, pPlayerUnits, pPlot)
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		CreateUnitWithExp("UNIT_SPEC_OPS", 6, pPlayerUnits, pPlot)
		return true 	
	end
end

function SpawnUnit_Siege(iPlayer, pPlot, currentEra)
	local pPlayer = Players[iPlayer]
	local pPlayerUnits = pPlayer:GetUnits()
	local CivilizationTypeName = PlayerConfigurations[iPlayer]:GetCivilizationTypeName()
	if currentEra == 0 then
		--Ancient Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_BATTERING_RAM", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 1 then
		--Classical Era
		CreateUnitWithExp("UNIT_CATAPULT", 1, pPlayerUnits, pPlot)
		return true 
	end
	if currentEra == 2 then
		--Medieval Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_CHINA" then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_CHINESE_CROUCHING_TIGER", pPlot:GetX(), pPlot:GetY())
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_KOREA") then
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_KOREAN_HWACHA", pPlot:GetX(), pPlot:GetY())
				return true									
			else
				CreateUnitWithExp("UNIT_TREBUCHET", 1, pPlayerUnits, pPlot)
				return true 					
			end
		else
			CreateUnitWithExp("UNIT_TREBUCHET", 1, pPlayerUnits, pPlot)
			return true 		
		end
	end
	if currentEra == 3 then
		--Renaissance Era
		if bSpawnUniqueUnits then
			if CivilizationTypeName == "CIVILIZATION_CHINA" then
				CreateUnitWithExp("UNIT_CHINESE_CROUCHING_TIGER", 4, pPlayerUnits, pPlot)
				return true
			elseif(CivilizationTypeName == "CIVILIZATION_KOREA") then
				CreateUnitWithExp("UNIT_KOREAN_HWACHA", 4, pPlayerUnits, pPlot)
				return true									
			else
				UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_BOMBARD", pPlot:GetX(), pPlot:GetY())
				return true 					
			end
		else
			UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_BOMBARD", pPlot:GetX(), pPlot:GetY())
			return true 		
		end
	end
	if currentEra == 4 then
		--Industrial Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_FIELD_CANNON", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 5 then
		--Modern Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ARTILLERY", pPlot:GetX(), pPlot:GetY())
		return true 
	end
	if currentEra == 6 then
		--Atomic Era
		CreateUnitWithExp("UNIT_ARTILLERY", 3, pPlayerUnits, pPlot)
		return true 
	end
	if currentEra == 7 then
		--Information Era
		UnitManager.InitUnitValidAdjacentHex(iPlayer, "UNIT_ROCKET_ARTILLERY", pPlot:GetX(), pPlot:GetY())
		return true 	
	end
	if currentEra == 8 then
		--Future Era
		CreateUnitWithExp("UNIT_ROCKET_ARTILLERY", 3, pPlayerUnits, pPlot)
		return true 	
	end
end