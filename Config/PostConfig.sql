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
	
-- Change the values for the InputHSD options based on the timeline settings
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 0, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 0, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 1, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 1, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 2, 'Map', 'HSD' || '_' || LeaderType, (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 2, 'Map', 'HSD' || '_' || CivilizationType, (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 3, 'Map', 'HSD' || '_' || LeaderType, (SELECT Era FROM HistoricalSpawnEras WHERE Civilization = CivilizationType), 0
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ConfigurationUpdates (SourceGroup,	SourceId,	SourceValue,	TargetGroup,	TargetId,	TargetValue,	'Static')
	SELECT	'Map', 'SpawnDateTables', 3, 'Map', 'HSD' || '_' || CivilizationType, (SELECT Era FROM HistoricalSpawnEras WHERE Civilization = CivilizationType), 0
	FROM CityStates WHERE Domain='Expansion2CityStates';

-- ParameterDependencies for player domains (not working)

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
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_STANDARD', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = CivilizationType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates WHERE Civilization = CivilizationType);
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_TRUESTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType);	
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_LEADER', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnDates_LeaderHSD WHERE Civilization = LeaderType);	
	
INSERT OR REPLACE INTO GameModePlayerItemOverrides (GameModeType, Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
	SELECT	'GAMEMODE_HSD', Domain, CivilizationType, LeaderType, 'HSD_ERASTART', 'ICON_GAMEMODE_HSD_PLAYERITEM', 'LOC_HSD_ERASTART_NAME', (SELECT Name FROM Eras WHERE SortIndex = (SELECT ((Era + 1) * 10) FROM HistoricalSpawnEras WHERE Civilization = CivilizationType)), 9
	FROM Players WHERE Domain='Players:Expansion2_Players' AND EXISTS (SELECT * FROM HistoricalSpawnEras WHERE Civilization = CivilizationType);	