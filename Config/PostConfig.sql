-- Create new parameters dynamically based on the active players in the Players UI table
	
INSERT OR REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
	SELECT	'HSD' || '_' || LeaderType, LeaderName, CivilizationName, 'text', 0, 'Map', 'HSD' || '_' || LeaderType, 'AdvancedOptions', 315
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
	SELECT	'HSD' || '_' || CivilizationType, Name, Name, 'text', 0, 'Map', 'HSD' || '_' || CivilizationType, 'AdvancedOptions', 316
	FROM CityStates WHERE Domain='Expansion2CityStates';

-- Set the dependencies for the new parameters

INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	SELECT	'HSD' || '_' || LeaderType, 'Map', 'InputHSD', 'Equals', '1'
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	SELECT	'HSD' || '_' || CivilizationType, 'Map', 'InputHSD', 'Equals', '1'
	FROM CityStates WHERE Domain='Expansion2CityStates';
	
-- Set the default values for the InputHSD options
	
UPDATE Parameters SET DefaultValue = (SELECT StartYear FROM HistoricalSpawnDates_input WHERE Civilization = ParameterId) WHERE ParameterId = (SELECT Civilization FROM HistoricalSpawnDates_input WHERE Civilization = ParameterId);

-----------------------------------------------
-- ConfigurationUpdates
-- Change the values for the InputHSD options based on the timeline settings
-----------------------------------------------

-- Standard Timeline

INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 0, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = LeaderType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 0, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = CivilizationType)  AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 0, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = CivilizationType);
	
-- True Start Timeline

INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 1, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 1, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 1, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType);
	
-- Leader Start Timeline
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 2, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 2, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 2, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType);
	
-- Era Start Timeline
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 3, 'Map', 'HSD' || '_' || LeaderType, (SELECT Era FROM HistoricalSpawnEras WHERE Civilization = LeaderType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 3, 'Map', 'HSD' || '_' || LeaderType, (SELECT Era FROM HistoricalSpawnEras WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 3, 'Map', 'HSD' || '_' || CivilizationType, (SELECT Era FROM HistoricalSpawnEras WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = CivilizationType);

-----------------------------------------------
-- ParameterDependencies for player domains (not working)
-----------------------------------------------

-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_STANDARD'
	-- FROM Players WHERE Domain='Players:StandardPlayers';
	
-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_EXPANSION_1'
	-- FROM Players WHERE Domain='Players:Expansion1_Players';
	
-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_EXPANSION_2'
	-- FROM Players WHERE Domain='Players:Expansion2_Players';
	
-- INSERT OR REPLACE INTO PlayerItems (Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	-- SELECT	Domain, CivilizationType, LeaderType, 'UNIT_COMANDANTE_GENERAL', '', 'Historical Spawn Date', (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 9
	-- FROM Players WHERE Domain='Players:Expansion2_Players';

-----------------------------------------------
-- GameModePlayerItemOverrides
-- Add the player items for the starting date in the setup menu
-----------------------------------------------

--Standard Timeline

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_STANDARD', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = LeaderType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = LeaderType);

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_STANDARD', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = LeaderType);

--True Start Timeline

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_TRUESTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_TRUESTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);	

--Leader Start Timeline

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_LEADER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType);

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_LEADER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType);	

--Era Start Timeline
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_ERASTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_ERASTART_NAME', (SELECT Name FROM Eras WHERE SortIndex = (SELECT ((Era + 1) * 10) FROM HistoricalSpawnEras WHERE Civilization = LeaderType)), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_ERASTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_ERASTART_NAME', (SELECT Name FROM Eras WHERE SortIndex = (SELECT ((Era + 1) * 10) FROM HistoricalSpawnEras WHERE Civilization = CivilizationType)), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = LeaderType);	
	
-- Isolated Players

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_ISOLATED_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_ISOLATED_NAME', "LOC_HSD_ISOLATED_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM IsolatedCivs WHERE Civilization = CivilizationType);
	
-- Colonial Players
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_COLONIAL_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_COLONIAL_NAME', "LOC_HSD_COLONIAL_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM ColonialCivs WHERE Civilization = CivilizationType);
	
-- Colonizers

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_COLONIZING_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_COLONIZING_NAME', "LOC_HSD_COLONIZING_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM ColonizerCivs WHERE Civilization = CivilizationType);
	
-- Restricted Spawns List

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_RESTRICTED_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_RESTRICTED_PLAYER_NAME', "LOC_HSD_RESTRICTED_PLAYER_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM RestrictedSpawns WHERE Civilization = CivilizationType);

-- Peaceful Spawns List

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_PEACEFUL_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_PEACEFUL_PLAYER_NAME', "LOC_HSD_PEACEFUL_PLAYER_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM PeacefulSpawns WHERE Civilization = CivilizationType);

-- Unique Spawns List

INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_UNIQUE_SPAWN_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_UNIQUE_SPAWN_PLAYER_NAME', "LOC_HSD_UNIQUE_SPAWN_PLAYER_DESCRIPTION", 8
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM UniqueSpawnZones WHERE Civilization = CivilizationType);
	
-- Historical Victories List

-- INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	-- SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_HISTORICAL_VICTORY_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', CivilizationType, LeaderType, 8
	-- FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM CivilizationVictories WHERE Civilization = CivilizationType);
	
-- INSERT INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	-- SELECT	'GAMEMODE_HSD', 'Players:Expansion2_Players', Civilization, Leader, 'HSD_HISTORICAL_VICTORY_PLAYER', 'ICON_GAMEMODE_HSD_PLAYERITEM', VictoryName, VictoryDescription, 8
	-- FROM CivilizationVictories;
	
-- INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
-- SELECT
    -- 'GAMEMODE_HSD',
    -- p.Domain,
    -- p.CivilizationType,
    -- p.LeaderType,
    -- 'HSD_HISTORICAL_VICTORY_PLAYER',
    -- 'ICON_GAMEMODE_HSD_PLAYERITEM',
    -- cv.VictoryName,
    -- cv.VictoryDescription,
    -- 8
-- FROM 
    -- Players p
-- INNER JOIN 
    -- CivilizationVictories cv ON p.CivilizationType = cv.Civilization
-- WHERE 
    -- p.Domain = 'Players:Expansion2_Players'
    -- AND EXISTS (
        -- SELECT * 
        -- FROM CivilizationVictories 
        -- WHERE Civilization = p.CivilizationType
    -- );

-- INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
-- SELECT
    -- 'GAMEMODE_HSD',
    -- p.Domain,
    -- p.CivilizationType,
    -- p.LeaderType,
    -- 'HSD_HISTORICAL_VICTORY_PLAYER',
    -- 'ICON_GAMEMODE_HSD_PLAYERITEM',
    -- cv.VictoryName,
    -- cv.VictoryDescription,
    -- 8
-- FROM 
    -- CivilizationVictories cv
-- INNER JOIN 
    -- Players p ON cv.Civilization = p.CivilizationType
-- WHERE 
    -- p.Domain = 'Players:Expansion2_Players';

