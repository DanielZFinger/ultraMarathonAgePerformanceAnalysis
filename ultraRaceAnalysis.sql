--*******************************************************************************************************************************************************************
--**********************************************************************[Data Cleaning Project Statement]************************************************************
--*******************************************************************************************************************************************************************

-- I am an avid runner myself and recently have noticed that the average age of athletes in Ultramarathons (races over 26.2 miles) seems to be significantly higher than that of shorter races ex. 5k, 10k, half marathon. On top of that the podium places (1-3) seem often more populated by
-- older runners.
-- With that in mind, the goal for this data analysis project is to see if there is a coorelation between age and success(defined by how well they place) in ultramarthons and if that coorelation has grown stronger or weaker in recent years. For races that are held every year I will also analyze the
-- performance at the same race each year to see if the trend is isolated per race or with ultrarunning as a whole.

--*******************************************************************************************************************************************************************
--**********************************************************************[Data Cleaning Outline]**********************************************************************
--*******************************************************************************************************************************************************************

-- To determine the answer to this project statement I have pulled a datset containing ultramarthons from 1792 - 2022 and will be analyzing these values to get my answer.
-- My rough outline for the data cleaning portion will be to
-- A) Reformat the race dates. Currently it is in DD.MM.YYYY form I would like Day, Month and Year to be in its own column.
-- B) Get rid of uneeded columns. For this analysis I am not interested in Athlete Club, Athelete Country, Athlete ID, Athlete gender nor am I interested in Athlete year of birth since Athlete age is already a column. These columns will be removed to get rid of unwanted data.
-- C) Parse through 'Event distance length' and only keep races that are a set distance (either km or M). All races that are based on time eg.12h races, 6h races and 24 hr, races will not be included. Only races with a set distance. All athletes with no age category privded will have their rows removed.
-- D) take off the gender in 'Athlete age category' bc not needed in this analysis. I just want a raw age of each athlete.
--Just looking at dataset
SELECT *
  FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]

  --**********************************************************************[STEP 1]**********************************************************************

  
--Reformat 'Event Dates' from DD.MM.YYYY to "day_of_event" containing the day or days of the event, "month_of_event" containing the string version of the month ex. 01 = January, "Year of event" already exists so we will just change the name of it to "year_of_event" to match the format 

Select [Event dates],
	CASE
		WHEN CHARINDEX('-', [Event dates]) > 0 THEN --check if '-' exists 
			CAST(SUBSTRING([Event dates], 1, CHARINDEX('-', [Event dates]) + 2) AS VARCHAR) --if '-' exists we take the range of days as opposed to a single day
		ELSE
			CAST(SUBSTRING([Event dates], 1, 2) AS VARCHAR) --if '-' doesn't exist we just get the singular day
	END AS day_of_event,
	CASE
		WHEN CHARINDEX('-', [Event dates]) > 0 THEN --check if '-' exists 
			DATENAME(MONTH, CAST(SUBSTRING([Event dates], CHARINDEX('-', [Event dates]) + 4, 2) AS INT)) --if '-' exists shift forward 4 spots in char from '-' to grab month ---- DATENAME(MONTH , ...) converts 1 to january, 2 to february, etc
		ELSE
			DATENAME(MONTH, CAST(SUBSTRING([Event dates], CHARINDEX('.', [Event dates]) + 1, 2) AS INT)) --if '-' doesn't exist shift 1 spot in char from '.' to grab month  ---- DATENAME(MONTH , ...) converts 1 to january, 2 to february, etc
	END AS month_of_event,
	[Year of event] AS year_of_event --change 'Year of event' to 'year_of_event'
FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]

--**********************************************************************[STEP 2]**********************************************************************

--******Update what we did above from just viewable to a permanent change in the database******

-- Start by adding the new tables

ALTER TABLE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
ALTER COLUMN [Event dates] VARCHAR(10); 

ALTER TABLE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES] --adding new 'day_of_event' column to dataset
ADD day_of_event VARCHAR(255);

ALTER TABLE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES] --adding new 'month_of_event' column to dataset
ADD month_of_event VARCHAR(255); 

--**********************************************************************[STEP 3]**********************************************************************

--next update the data

UPDATE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
SET 
    day_of_event = CASE
                        WHEN CHARINDEX('-', [Event dates]) > 0 THEN --check if '-' exists 
                            CAST(SUBSTRING([Event dates], 1, CHARINDEX('-', [Event dates]) + 2) AS VARCHAR) --if '-' exists take the range of days
                        ELSE
                            CAST(SUBSTRING([Event dates], 1, 2) AS VARCHAR) --if '-' doesn't exist just get the singular day
                    END,
    month_of_event = CASE
                        WHEN CHARINDEX('-', [Event dates]) > 0 THEN --check if '-' exists 
                            DATENAME(MONTH, CAST(SUBSTRING([Event dates], CHARINDEX('-', [Event dates]) + 4, 2) AS INT)) --if '-' exist grab the month and conert to STRING equivalent
                        ELSE
                            DATENAME(MONTH, CAST(SUBSTRING([Event dates], CHARINDEX('.', [Event dates]) + 1, 2) AS INT)) --if '-' doesn't exist, grab the month and conert to STRING equivalent
                    END;

--rename the [Year of event] column to [year_of_event]
USE ultraDB;
EXEC sp_rename 'ultraDB.dbo.TWO_CENTURIES_OF_UM_RACES.[Year of event]', 'year_of_event', 'COLUMN';

 --**********************************************************************[STEP 4]**********************************************************************
 --remove unwanted columns

ALTER TABLE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
DROP COLUMN [Athlete club],
			[Athlete country],
			[Athlete year of birth],
			[Athlete ID],
			[Athlete gender]
--since I made seperate columns for year, month and day of event I no longer need 'Event dates' so i will remove that aswell
ALTER TABLE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
DROP COLUMN [Event dates]

--**********************************************************************[STEP 5]**********************************************************************
--remove rows with 'Event distance length' measured in hours 

--below we will select all rows with 'Event distance length not ending in 'h'. This way we will remove all rows with race distance measured in hours
SELECT *
FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
WHERE RIGHT([Event distance length], 1) != 'h';

--The code above is just temporary to see if it does what I expect it to do. It does so now we will do this permanently to the dataset except we need to reverse the != 'h' because it will delete eveything that does not equal 'h' so instead we will delete evrything equal to 'h' by replacing != with =
DELETE FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
WHERE RIGHT([Event distance length], 1) = 'h';

--below we will select all rows with 'Athlete age category" with an actual value. This way we will remove all rows with race distance measured in hours
SELECT *
FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
WHERE [Athlete age category] = '';

--The code above is just temporary to see if it does what I expect it to do. It does so now we will do this permanently to the dataset
DELETE FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
WHERE [Athlete age category] = '';

--**********************************************************************[STEP 6]**********************************************************************
--remove the gender tag in front of the ages
--below is temporary look for testing
SELECT 
    CASE 
        WHEN [Athlete age category] LIKE 'M%' OR [Athlete age category] LIKE 'W%' OR [Athlete age category] LIKE 'U%' THEN SUBSTRING([Athlete age category], 2, LEN([Athlete age category]) - 1)
        ELSE [Athlete age category]
    END AS Athlete_age_category_without_prefix
FROM [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES];

--above looks good so lets finalize it on the dataset
UPDATE [ultraDB].[dbo].[TWO_CENTURIES_OF_UM_RACES]
SET [Athlete age category] = 
    CASE 
        WHEN [Athlete age category] LIKE 'M%' OR [Athlete age category] LIKE 'W%' OR [Athlete age category] LIKE 'U%' THEN SUBSTRING([Athlete age category], 2, LEN([Athlete age category]) - 1)
        ELSE [Athlete age category]
    END;
