-- Historical Spawn Dates Civilopedia Text
-- Author: totalslacker

-- BaseGameText
--------------------------------------------------------------
INSERT OR REPLACE INTO BaseGameText
		(Tag, Text)
VALUES	-- General Text
		('LOC_PEDIA_CONCEPTS_PAGEGROUP_HSD_NAME',
		'Historical Spawn Dates'),
		
		-- Rule Changes
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_HSD_BASE_TITLE',
		'Gameplay Changes'),

		-- ('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_HSD_BASE_PARA_1',
		-- 'Hark, ye seekers of the uncharted! Behold a mod that springs from the spirit of Rhye''s and Fall – a name known to the winds of history. Picture civilizations emerging like stars in the celestial tale of the ages. Sumeria and Egypt, awakened in 4000 BC, and America''s fire igniting in 1776 AD. Elect thine path: era''s embrace or year''s precision. In the wake of new arrivals, revolutions shall stir, sweeping cityscapes with conversions and free city rebellions. Bonuses and legions, a dance of progress and era''s sway. As isolation daunts, revere not the lack of boon, or in colonial fervor, march forth! Cast unto the realm unseen, the curtain lifts only at thy destined hour. In this realm, ye script thy destiny anew.[NEWLINE]'),
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_HSD_BASE_PARA_1',
		'The following gameplay changes can be configured from the mod files or the Advanced Setup Menu during new game creation.'),
		
		-- ('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_HSD_BASE_PARA_2',
		-- 'User Settings:[NEWLINE][NEWLINE][ICON_Bullet]To change the default number of players for a new game, open Config.xml from the Data folder, and search for DefaultPlayers. Uncomment this section of the file by deleting the comment tags, <!-- --> , to activate.[NEWLINE][ICON_Bullet]Setting this to 42 will ensure that all civilizations appear in the game when using random leaders.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_SPAWN_ZONES_TITLE',
		'Spawn Zones and Invasions'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_SPAWN_ZONES_PARA_1',
		'[ICON_Bullet]Spawn zones increase in size around the starting plot based on the game era (maximum 6 plots in all directions by Medieval).[NEWLINE][ICON_Bullet]Cities in the spawn zone will revolt if they don''t have an established governor.[NEWLINE][ICON_Bullet]Original capitals and City State players will not revolt by default.[NEWLINE][ICON_Bullet]New players will declare war on the city owner if it has an established governor, and they receive military units (compatible with all unit mods) dynamically based on tech and civic progress. AI players will attack nearby cities.[NEWLINE]'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_GAME_BALANCE_TITLE',
		'Gameplay Balance'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_GAME_BALANCE_PARA_1',
		'Receive bonus technologies, civics, yields and great person points based on the progress of other players and the game difficulty setting. Isolated players receive minor bonuses to yields based on the game era.[NEWLINE]The Super Monument building provides bonus loyalty pressure from all citizens to help sustain new players. It is spawned in the capital until the number of cities owned by the player exceeds the era limit. The era limit is the numerical value of the game era (Ancient = 1, Classical = 2, etc)[NEWLINE]New cities receive bonus population, buildings and units until the era limit is reached.[NEWLINE]Players receive 1 Era Score per turn before they spawn, after the first Civ enters the Classical Era. Later starting players will spawn in a Normal or Golden Age, depending on factors such as number of players and game speed, while earlier starting players are more likely to start in a Dark Age.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_PLAYERTYPES_TITLE',
		'Isolated and Colonial Civilizations'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_PLAYERTYPES_PARA_1',
		'Isolated Civs spawn without any bonuses, but they receive a stronger version of the Grand Embassy trait which provides extra Science and Culture from Trade Routes to more advanced Civilizations (defined in IsolatedCivs.sql)[NEWLINE][NEWLINE]Isolated Civilizations:[NEWLINE][ICON_BULLET]Aztec, Cree, Inca, Mapuche, Maya, Maori[NEWLINE][NEWLINE]Late-game Colonial Civs start with the Democracy government unlocked and receive a copy of the Grand Embassy trait and the Era Building which provides bonus yields in every city depending on the Starting Era (defined in IsolatedCivs.sql)[NEWLINE][NEWLINE]Colonial Civilizations:[NEWLINE][ICON_BULLET]America, Australia, Brazil, Colombia, Canada'),
		
		--Timelines
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_HSD_BASE_TITLE',
		'Timelines'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_HSD_BASE_PARA_1',
		'Timelines are selected from the Advanced Setup Menu when starting a new game.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE01_TITLE',
		'Standard Timeline'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE01_PARA_1',
		'Based on culture. The timeline is set from the file HSD_Standard.sql in the Tables folder.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE02_TITLE',
		'True Historical Start'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE02_PARA_1',
		'Based on the founding date in the Civilopedia. The timeline is set from the file HSD_TrueHSD.sql in the Tables folder.'),
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE03_TITLE',
		'Leader Start'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE03_PARA_1',
		'Based on the birth date of leaders. The timeline is set from the file HSD_LeaderHSD.sql in the Tables folder.'),		

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE04_TITLE',
		'Era Start'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE04_PARA_1',
		'Based on era start dates. Optionally converts any year-based timeline into era start. The timeline is set from the file HSD_Eras.sql in the Tables folder.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE05_TITLE',
		'Lite Mode'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_TIMELINE05_PARA_1',
		'Isolated and Colonial Civilizations receive historical start dates. All other civilizations start the game normally on Turn 1.'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_INPUT_HSD_TITLE',
		'User Settings and Mod Support'),		
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_INPUT_HSD_PARA_1',
		'Start dates for Civilizations and City-States can be set in the corresponding timeline files. Supports civilizations and leaders, with leader dates taking precedence if available. Support for custom Civilization mods can also be added the same way.[NEWLINE][NEWLINE]Start dates can also be set from the Advanced Setup Menu. Overriding the start dates during game setup will prevent them from being saved as in-game traits and appearing in-game in the UI and Civilopedia.'),
		
		-- Colonization Mode
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_COLONIZATION_CHAPTER_MODE_TITLE',
		'Colonization Mode'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_COLONIZATION_CHAPTER_MODE_PARA_1',
		'European Civilizations spawn colonies on foreign continents after discovering Cartography and advancing into every new era until the Modern Era. Colonies start with military units, workers and a Harbor. Colonies will spawn on different continents depending on the player, and will select the best plot location based on historical conditions. Includes option to create colonies for AI players only.[NEWLINE][NEWLINE]For Earth maps. Detects the following continents: Africa, Asia, Australia, North America, South America, Oceania, Siberia, Zealandia'),
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_COLONIZATION_CHAPTER_LOYAL_HARBORS_TITLE',
		'Loyal Harbors'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_COLONIZATION_CHAPTER_LOYAL_HARBORS_PARA_1',
		'Coastal cities on foreign continents with a Harbor that is not pillaged are always loyal to the owner.'),
		
		-- Raging Barbarians Mode
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RAGING_BARBARIANS_CHAPTER_MODE_TITLE',
		'Raging Barbarians Mode'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RAGING_BARBARIANS_CHAPTER_MODE_PARA_1',
		'Barbarian camps have historical names and spawn unique units based on the continent and game era. These units are weaker versions of civilization unique units and can be viewed from the Civilopedia. Tribe name visible on unit tooltip.[NEWLINE][NEWLINE]For Earth maps. Detects the following continents: Africa, Asia, Australia, Europe, Greenlandia, Madagascaria, North America, South America, Oceania, Siberia, Zealandia'),
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RAGING_BARBARIANS_CHAPTER_INVASIONS_TITLE',
		'Barbarian Invasions'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_RAGING_BARBARIANS_CHAPTER_INVASIONS_PARA_1',
		'Barbarians will invade all major players at the end of the Ancient, Classical and Medieval Eras, starting when the era countdown begins. Players receive an invasion event popup message. Invasions for Europe and Asia have historical names based on location. The number of invasion units scales with difficulty and era. Invasions will spawn from a nearby unoccupied plot on the same continent.'),
		
		-- Historical Victory Mode
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_HISTORICAL_VICTORY_CHAPTER_MODE_TITLE',
		'Historical Victory Mode'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_HISTORICAL_VICTORY_CHAPTER_MODE_PARA_1',
		'Civilizations receive three unique victory conditions based on their historical acheivements and failures. These consist of multiple objectives that must be completed for each victory condition. Completing an entire victory conditon awards era score. Completing all three victory conditions unlocks the Historical Victory project which can be completed at any time to claim the victory.'),
		
		('LOC_PEDIA_CONCEPTS_PAGE_HSD_HISTORICAL_VICTORY_CHAPTER_LEADER_TITLE',
		'Leader Victories'),

		('LOC_PEDIA_CONCEPTS_PAGE_HSD_HISTORICAL_VICTORY_CHAPTER_LEADER_PARA_1',
		'Leaders will use unique victory conditions if defined. Defaults to Civilization victory conditions if does not exist.');