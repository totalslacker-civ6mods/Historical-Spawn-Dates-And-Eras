--	TSL Earth Remastered Civilopedia 
--	Author: totalslacker

-- CivilopediaPageGroups
--------------------------------------------------------------
INSERT OR REPLACE INTO CivilopediaPageGroups
		(SectionID,		PageGroupId,			SortIndex,	VisibleIfEmpty,	Tooltip,	Name)
VALUES	('CONCEPTS',	'HSD',	-20,			0,				'',			'LOC_PEDIA_CONCEPTS_PAGEGROUP_HSD_NAME');
--------------------------------------------------------------

-- CivilopediaPages
--------------------------------------------------------------
INSERT OR REPLACE INTO CivilopediaPages
		(SectionId,		PageId,			PageGroupId,		SortIndex,		PageLayoutId,		Tooltip,	Name)
VALUES	('CONCEPTS',	'HSD_RULES',					'HSD',	1,			'HSD_RULES',					'',			'LOC_PEDIA_CONCEPTS_PAGE_HSD_RULES_CHAPTER_HSD_BASE_TITLE'),
		('CONCEPTS',	'HSD_TIMELINES',				'HSD',	2,			'HSD_TIMELINES',				'',			'LOC_PEDIA_CONCEPTS_PAGE_HSD_TIMELINES_CHAPTER_HSD_BASE_TITLE'),
		('CONCEPTS',	'HSD_COLONIZATION',				'HSD',	3,			'HSD_COLONIZATION',				'',			'LOC_PEDIA_CONCEPTS_PAGE_HSD_COLONIZATION_CHAPTER_MODE_TITLE'),
		('CONCEPTS',	'HSD_RAGING_BARBARIANS',				'HSD',	4,			'HSD_RAGING_BARBARIANS',				'',			'LOC_PEDIA_CONCEPTS_PAGE_HSD_RAGING_BARBARIANS_CHAPTER_MODE_TITLE'),
		('CONCEPTS',	'HSD_HISTORICAL_VICTORY',				'HSD',	5,			'HSD_HISTORICAL_VICTORY',				'',			'LOC_PEDIA_CONCEPTS_PAGE_HSD_HISTORICAL_VICTORY_CHAPTER_MODE_TITLE');
--------------------------------------------------------------

-- CivilopediaPageLayouts
--------------------------------------------------------------
INSERT OR REPLACE INTO CivilopediaPageLayouts
		(PageLayoutId,						ScriptTemplate)
VALUES	('HSD_RULES',				'Simple'),
		('HSD_TIMELINES',			'Simple'),
		('HSD_COLONIZATION',		'Simple'),
		('HSD_RAGING_BARBARIANS',	'Simple'),
		('HSD_HISTORICAL_VICTORY',	'Simple');
--------------------------------------------------------------

-- CivilopediaPageLayoutChapters
--------------------------------------------------------------
--RULES
INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RULES',	'HSD_BASE',		10);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RULES',	'SPAWN_ZONES',	20);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RULES',	'GAME_BALANCE',	30);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RULES',	'PLAYERTYPES',	40);

--MAPS
INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'HSD_BASE',		10);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'TIMELINE01',	20);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'TIMELINE02',	30);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'TIMELINE03',	40);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'TIMELINE04',	50);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'TIMELINE05',	60);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_TIMELINES',	'INPUT_HSD',	70);

-- Colonization MODE
INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_COLONIZATION',	'MODE',		10);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_COLONIZATION',	'LOYAL_HARBORS',	20);

-- Raging Barbarians MODE
INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RAGING_BARBARIANS',	'MODE',		10);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_RAGING_BARBARIANS',	'INVASIONS',	20);

-- Historical Victory MODE
INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_HISTORICAL_VICTORY',	'MODE',		10);

INSERT OR REPLACE INTO CivilopediaPageLayoutChapters
		(PageLayoutId,					ChapterId,			SortIndex)	
VALUES	('HSD_HISTORICAL_VICTORY',	'LEADER',	20);