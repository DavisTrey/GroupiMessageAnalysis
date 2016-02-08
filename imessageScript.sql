--/Users/drewtreybig/Library/Messages/chat.db--
--Use the follow example command to run a sql script against a sqlite3 database:--
--sqlite3 test.db < test.sql--

-- Run this with  sqlite3 /Users/drewtreybig/Library/Messages/chat.db < imessageScript.sql --


--Tables = attachment, chat_message_join, handle, chat, message, chat_handle_join, message_attachment_join
---Handle: senders/people. Schema is (ROWID, id(aka, phone #), country, service (aka, often "iMessage"))
--Sometimes the handle id is instead the icloud/gmail account, ie, "davis.treybig@gmail.com", "geordicn@icloud.com"
--Example : "39, +12103556874, US, iMessage"


/* Note that dateSent is the actual date info. julianday is a way to compare dates easily (pure number, days since some date)
The built in "Date" is SECONDS since the unix epoch.  (http://stackoverflow.com/questions/10746562/parsing-date-field-of-iphone-sms-file-from-backup)
*/

CREATE VIEW combinedTable2 AS
SELECT *
FROM message as m LEFT JOIN handle as h on h.rowid = m.handle_id;


--Amy:     +12107880523 -- 
--Mehul:   +15124844893 -- 
--Brian:   +15129834663 --
--Joanna:  +16095981227 --
--Natalie: +18652747424 -- 
--Adil:    +18653233805 --

--"text" for text -- 
--"id" for phone number --



CREATE VIEW tableWithChats AS
SELECT *, chat.guid as groupguid
FROM combinedTable2, chat_message_join, chat
WHERE chat_message_join.chat_id = chat.ROWID
AND chat_message_join.message_id = combinedTable2.ROWID;

CREATE VIEW tableWithChatsAndDate AS
SELECT *, datetime(date + strftime('%s','2001-01-01'), 'unixepoch') as dateSent
FROM tableWithChats;





PRAGMA table_info(tableWithChatsAndDate);


------------------------------------------------- RUTH ANALYSIS ----------------------------
/*
-- how many times have ruth and I sent each other I love you -- 

SELECT is_from_me, COUNT(*)
FROM tableWithChats
WHERE tableWithChats.groupguid = "iMessage;-;+12142809238"
AND text LIKE '%I love you%'
OR text LIKE '%i love you%'
GROUP BY is_from_me;

SELECT is_from_me, COUNT(*)
FROM tableWithChats
WHERE tableWithChats.groupguid = "iMessage;-;+12142809238"
AND text LIKE '%lahv%'
GROUP BY is_from_me;

-- Total texts sent by ruth and me, grouped -- 
SELECT is_from_me, count(*)
FROM tableWithChats
WHERE tableWithChats.groupguid = "iMessage;-;+12142809238"
GROUP BY is_from_me;
*/




-------------------------------------------- Friend Group Analysis ---------------------------------------------------


/*
--Find total texts sent by everyone -- 
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
GROUP BY id;
*/


-- Longest Text message in friend group text -- 
/*
SELECT text, id
FROM combinedTable2
WHERE cache_roomnames = "chat465960929646925700"
AND NOT EXISTS (SELECT *
				FROM combinedTable2 as T
				WHERE cache_roomnames = "chat465960929646925700"
				AND length(T.text)>length(combinedTable2.text));
*/


-- Text with most question marks --
/*
SELECT text, id
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (length(text) - length(REPLACE(text, '?', ''))) =  
	(SELECT MAX(length(T.text) - length(REPLACE(T.text, '?', '')))
	FROM tableWithChats as T
	WHERE groupguid = "iMessage;+;chat465960929646925700");
*/

-- Total number of question marks per person -- 
/*
SELECT id, SUM(questions)
FROM (
	Select id, length(text) - length(REPLACE(text, '?', '')) as questions
	FROM tableWithChats
	WHERE groupguid = "iMessage;+;chat465960929646925700")
GROUP BY id;
*/


-- User who uses the most exclamation points -- 
/*
SELECT id, SUM(exclamation)
FROM (
	Select id, length(text) - length(REPLACE(text, '!', '')) as exclamation
	FROM tableWithChats
	WHERE groupguid = "iMessage;+;chat465960929646925700")
GROUP BY id;
*/



------ WORD CLOUD FILES --- 
/*
.mode csv
.output amyWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+12107880523';

.output mehulWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+15124844893';

.output brianWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+15129834663';

.output joannaWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+16095981227';

.output natalieWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+18652747424';

.output adilWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+18653233805';

.output davisWords.csv
SELECT text
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND is_from_me = 1;

.output stdout
*/

-- Counting 'lol' -- 
/*
SELECT COUNT(*), id
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (text like '%lol%'
OR text like '%LOL%'
OR text like '%Lol'
OR text like '%LoL%')
GROUP BY id;

*/


-- Who says what names -- 
/*
.output whoSaysWhatNames.csv
.print "Mehul's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%mehul%')
OR UPPER(text) like UPPER('%meguk%'))
GROUP BY id;

.print "Amy's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%amy%'))
GROUP BY id;


.print "Davis's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%davis%')
OR UPPER(text) like UPPER('%davy%'))
GROUP BY id;

.print "Adil's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%adil%'))
GROUP BY id;

.print "Natalie's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%natalie%'))
GROUP BY id;


.print "Joanna's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%joanna%')
OR UPPER(text) like UPPER('%jo%'))
GROUP BY id;

.print "Brian's Name:"
SELECT id, COUNT(*)
FROM tableWithChats
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND (UPPER(text) like UPPER('%brian%'))
GROUP BY id;

.output stdout
*/



-------- TEXT MESSAGE LENGTH COUNTS ------ 
.mode csv
.output amyLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+12107880523';

.output mehulLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+15124844893';

.output brianLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+15129834663';

.output joannaLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+16095981227';

.output natalieLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+18652747424';

.output adilLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND id = '+18653233805';

.output davisLength.csv
SELECT length(text)
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
AND is_from_me = 1;

.output stdout


--------------- EMOJI COUNTS ---------

/*
SELECT id, COUNT(*) FROM tableWithChatsAndDate 
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND text LIKE '%😊%' GROUP BY id;

SELECT id, COUNT(*) FROM tableWithChatsAndDate 
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND text LIKE '%😉%' GROUP BY id;

SELECT id, COUNT(*) FROM tableWithChatsAndDate 
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND text LIKE '%💩%' GROUP BY id;

SELECT id, COUNT(*) FROM tableWithChatsAndDate 
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND text LIKE '%😢%' GROUP BY id;


SELECT id, COUNT(*) FROM tableWithChatsAndDate 
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND text LIKE '%😎%' GROUP BY id;
*/

--------- AVG Message Length --------

/*
SELECT id, AVG(length(text))
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700" 
GROUP by id;

*/

------- DATE of first message  (look manually)-------
/*
SELECT id, text, date, dateSent
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
ORDER BY date desc;
*/


---- Output all text dates for a histogram --
/*
.output histogramData.csv
SELECT dateSent
FROM tableWithChatsAndDate
WHERE groupguid = "iMessage;+;chat465960929646925700"
ORDER BY date desc;
.output stdout
*/

------- first and last message dates  (NOT WORKING....stupid imessage date comparisons)----- 

/*
SELECT id, text, dateSent
FROM tableWithChatsAndDate as table1
WHERE groupguid = "iMessage;+;chat465960929646925700" 
AND NOT EXISTS (SELECT *
				FROM tableWithChatsAndDate as table2
				WHERE table2.groupguid = "iMessage;+;chat465960929646925700" 
				AND julianday(table2.dateSent) < julianday(table1.dateSent));


*/




-- Average time until a response (in minutes). Note that I artificially constrain the dataset -- 
-- so that it does not include gaps of more than 10 days. This is for pure performance reasons, --
-- and realistically I dont think there should be any points in the group text where a response -- 
-- time was longer than 10 days -- 


/*

CREATE TABLE newAttempt AS
SELECT t1.id as senderID, t2.id as responderID, t1.dateSent as dateSent, t2.dateSent as dateResponse, julianday(t2.dateSent) - julianday(t1.dateSent) as timeToResponse,
t1.text as senderText, t2.text as responderText
FROM tableWithChatsAndDate as t1, tableWithChatsAndDate as t2
WHERE t1.groupguid = "iMessage;+;chat465960929646925700"
AND t2.groupguid = "iMessage;+;chat465960929646925700"
AND julianday(t2.dateSent) > julianday(t1.dateSent)

*/

/*
CREATE TABLE ResponseTable AS
SELECT t1.id as senderID, t2.id as responderID, t1.dateSent as dateSent, t2.dateSent as dateResponse, julianday(t2.dateSent) - julianday(t1.dateSent) as timeToResponse,
t1.text as senderText, t2.text as responderText
FROM tableWithChatsAndDate as t1, tableWithChatsAndDate as t2
WHERE t1.groupguid = "iMessage;+;chat465960929646925700"
AND t2.groupguid = "iMessage;+;chat465960929646925700"
AND t2.date > t1.date
AND NOT EXISTS (
				SELECT *
				from tableWithChatsAndDate as t3
				WHERE t3.groupguid = "iMessage;+;chat465960929646925700"
				AND t3.date > t1.date
				AND t3.date < t2.date
				);
*/

/*
SELECT *
FROM tableWithChatsAndDate as t1, tableWithChatsAndDate as t2
WHERE t1.groupguid = "iMessage;+;chat465960929646925700"
AND t2.groupguid = "iMessage;+;chat465960929646925700"
*/



/*
CREATE TABLE Responses AS
SELECT t1.id as senderID, t2.id as responderID, t1.dateSent as dateSent, t2.dateSent as dateResponse, julianday(t2.dateSent) - julianday(t1.dateSent) as timeToResponse,
t1.text as senderText, t2.text as responderText
FROM tableWithChatsAndDate as t1, tableWithChatsAndDate as t2
WHERE t1.groupguid = "iMessage;+;chat465960929646925700"
AND t2.groupguid = "iMessage;+;chat465960929646925700"
AND t2.date - t1.date > 0
AND t2.date - t1.date < 3600
AND NOT EXISTS (
				SELECT *
				FROM tableWithChatsAndDate as t3
				WHERE t3.groupguid = "iMessage;+;chat465960929646925700"
				AND t3.date > t1.date
				AND t3.date < t2.date
				)
;

Select * from Responses;
*/

/*
A.senderID, A.responderID, A.d1, A.d2, A.timeToResponse
FROM (
	SELECT t1.id as senderID, t2.id as responderID, t1.dateSent as d1, t2.dateSent as d2, julianday(t2.dateSent) - julianday(t1.dateSent) as timeToResponse
	FROM tableWithChatsAndDate as t1, tableWithChatsAndDate as t2
	WHERE t1.groupguid = "iMessage;+;chat465960929646925700"
	AND t2.groupguid = "iMessage;+;chat465960929646925700"
	AND julianday(t2.dateSent) - julianday(t1.dateSent) > 0
    AND julianday(t2.dateSent) - julianday(t1.dateSent) < 10) as A
WHERE NOT EXISTS (
				SELECT *
				FROM tableWithChatsAndDate as t3
				WHERE t3.groupguid = "iMessage;+;chat465960929646925700"
				AND julianday(t3.dateSent) > julianday(A.d1)
				AND julianday(t3.dateSent) < julianday(A.d2)
				)
;
*/



DROP VIEW combinedTable2;
DROP VIEW tableWithChats;
DROP VIEW tableWithChatsAndDate;

---------------------------------------- SELECTING DATES ---------------------------
-- compare with julianday(date)
-- ie SELECT id, text, dateSent, julianday(dateSent) as a, (julianday(dateSent) - julianday('2015-10-20 00:00:00'))*24 as temp
 --FROM tableWithChatsAndDate;
 --Note that subtracting juliandays gives the difference in FRACTIONAL DAYS. 

--Below finds all messages from dates after 2015-10-20
 --SELECT id, text, dateSent
-- FROM tableWithChatsAndDate
-- WHERE (julianday(dateSent) - julianday('2015-10-20 00:00:00')) > 0;
-- Good Date/time resource: https://www.sqlite.org/lang_datefunc.html-- 

----------------------------------------  Other Info -----------------------------

-- Chat ID can also define a group. IE ruth and I are chat.id = 133 -- 
-- id and handle_id both define a person/handle. Ruth is handle_id 92, id=+1214280923
-- message.is_from_me determines whether a message is from me

-- chat.guid defines the group. For a group it is of the form iMessage;+;chat465960929646925700
-- For a single person it is of the form "iMessage;-;+12142809238"
--- Ruth groupguid: iMessage;-;+12142809238   FriendGroup groupguid = iMessage;+;chat465960929646925700
