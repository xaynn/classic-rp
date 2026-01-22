 dbFunc = 
{
	queries = 0,
	connectDate = 0,

	host 	= "127.0.0.1",
	user 	= "admin",
	pass 	= "",
	db 		= "rp_database",

	dbHandler = nil
}

 function dbFunc.connect()
	dbFunc.dbHandler = dbConnect("mysql", string.format("dbname=%s;host=%s;charset=utf8", dbFunc.db, dbFunc.host), dbFunc.user, dbFunc.pass, "share=1")
	if dbFunc.dbHandler then
		outputDebugString("[DB] Połączono z bazą danych")
		query("SET NAMES utf8")
		dbFunc.connectDate = getRealTime().timestamp
	else
		outputDebugString("[DB] Błąd łączenia z bazą danych")
	end
end
addEventHandler("onResourceStart", resourceRoot, dbFunc.connect)

 function dbFunc.disconnect()
	if isElement(dbFunc.dbHandler) then
	end
	outputDebugString(string.format("[DB] Rozłączono z bazą danych | Wykonano %d zapytań | Połączenie trwało %d sekund", dbFunc.queries, math.floor((getRealTime().timestamp - dbFunc.connectDate))))
end
addEventHandler("onResourceStop", resourceRoot, dbFunc.disconnect)

 function query(...)
    local data = {...}
    dbFunc.queries = dbFunc.queries + 1
    local prepareString = dbPrepareString(dbFunc.dbHandler, ...)
    -- outputDebugString(string.format("[DB] query: [%s]", prepareString))
	local queryHandler = dbQuery(dbFunc.dbHandler, prepareString)
    if not queryHandler then return false end 
    local res, rows, lastID = dbPoll(queryHandler, -1)
	if res then return res, rows, lastID else return false end
end

function query_free(...)
	local data = {...}
	dbFunc.queries = dbFunc.queries + 1
	local prepareString = dbPrepareString(dbFunc.dbHandler, ...)
	-- outputDebugString(string.format("[DB] queryFree: [%s]", prepareString))
	local queryHandler = dbQuery(dbFunc.dbHandler, prepareString)
	if not queryHandler then return false end
	if dbFree(queryHandler) then return true else return false end
end

function escapeStrings(str)
	local String = string.gsub(tostring(str),"'","")
	String = string.gsub(String,'"',"")
	String = string.gsub(String,';',"")
	String = string.gsub(String,"\\","")
	String = string.gsub(String,"/*","")
	String = string.gsub(String,"*/","")
	String = string.gsub(String,"'","")
	String = string.gsub(String,"`","")
	return String
end
