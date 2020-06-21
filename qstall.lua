UTILS = {}

function UTILS:QsPrint(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100QStall|r|CFFFF0000>|r"..(msg or "nil"));
end
function UTILS:QsWhisper(content, playerName)
	local selfName,_ = UnitName("player")
	UTILS:QsPrint("[QsWhisper] ["..playerName.."] ["..selfName.."]")
    if string.find(playerName, selfName) then
    	UTILS:QsPrint("WHISPER:"..content)
    else
    	SendChatMessage(content, "WHISPER", nil, playerName)
    end
end

function UTILS:StrSplit(text, delimiter)
   local list = {}
   local pos = 1
   if strfind("", delimiter, 1) then
      error("delimiter matches empty string!")
   end
   while 1 do
      local first, last = strfind(text, delimiter, pos)
      if first then
         tinsert(list, strsub(text, pos, first-1))
         pos = last+1
      else
         tinsert(list, strsub(text, pos))
         break
      end
   end
   return list
end

function UTILS:arrPrint(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end

function UTILS:queueNew()
  return {first = 0, last = -1}
end

function UTILS:queuePush(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
  UTILS:arrPrint(list, 2)
end

function UTILS:queuePop(list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil
  list.first = first + 1
  UTILS:arrPrint(list, 2)
  return value
end


QsMain = {}

QsMain.StallTip = "1g开门，密我地点：奥格OG，雷霆TB，幽暗UC"
QsMain.DesQueue = UTILS:queueNew()

function QsMain:switchChange(switchOn)
	if switchOn then
		QStallConfigCharacter.SwitchOn = true
        UTILS:QsPrint('QStall switch on!')

    	SendChatMessage(QsMain.StallTip, "YELL")
    	SendChatMessage(QsMain.StallTip, "DND")
    else
    	QStallConfigCharacter.SwitchOn = false
        UTILS:QsPrint("QStall switch off!")
    	SendChatMessage("", "DND")
    end
end

QsMain.DestinationDef = {OG="AG|ag|Ag|AUG|aug|Aug|OG|og|Og|奥|澳", UC="YA|ya|Ya|UC|uc|Uc|幽", TB="TB|tb|Tb|LT|lt|Lt|雷"}

function QsMain:teleportPlayer(playerName, des)
	UTILS:QsPrint("[teleportPlayer] ["..playerName.."] ["..des.."]")
	if des == "OG" then
    	UTILS:queuePush(QsMain.DesQueue, des)
    	UTILS:QsWhisper("[奥格瑞玛] 1g，请交易", playerName)
    	UTILS:QsWhisper("[奥格瑞玛] 1g，请交易", playerName)
    elseif des == "UC" then
    	UTILS:queuePush(QsMain.DesQueue, des)
    	UTILS:QsWhisper("[幽暗城] 1g，请交易", playerName)
    	UTILS:QsWhisper("[幽暗城] 1g，请交易", playerName)
    elseif des == "TB" then
    	UTILS:queuePush(QsMain.DesQueue, des)
    	UTILS:QsWhisper("[雷霆崖] 1g，请交易", playerName)
    	UTILS:QsWhisper("[雷霆崖] 1g，请交易", playerName)
    else
    	UTILS:QsWhisper(QsMain.StallTip, playerName)
    	return
    end
	UTILS:QsPrint("[InitiateTrade] ["..playerName.."]")
    InitiateTrade(playerName)
end


local function handler(msg, editBox)
    if msg == 'on' then
    	QsMain:switchChange(true)
    elseif msg == 'off' then
    	QsMain:switchChange(false)
    else
        UTILS:QsPrint("Usage: /qstall [on | off]")
    end
end

SLASH_QSTALL1, SLASH_QSTALL2 = '/qs', '/qstall';
SlashCmdList["QSTALL"] = handler;


local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("TRADE_ACCEPT_UPDATE")
frame:RegisterEvent("PLAYER_TRADE_MONEY")
frame:RegisterEvent("CHAT_MSG_MONEY")

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5)
    if event == "ADDON_LOADED" and arg1 == "qstall" then
    	if QStallConfigCharacter == nil then
    		QStallConfigCharacter = {}
    		QStallConfigCharacter.SwitchOn = false
    	end
    	UTILS:QsPrint("QStall loaded.")
    	QsMain:switchChange(QStallConfigCharacter.SwitchOn)
    end

    if event == "CHAT_MSG_WHISPER" and QStallConfigCharacter.SwitchOn then
		UTILS:QsPrint("[OnEvent:"..event.."] ["..(arg1 or "nil").."] ["..(arg5 or "nil").."]")
    	local text, playerName = arg1, arg5
    	local des = nil

    	-- UTILS:QsWhisper("先退出其它队伍。", playerName)
    	InviteUnit(playerName)
    	
    	for k,v in pairs(QsMain.DestinationDef) do
    		for w in string.gmatch(v, '([^|]+)') do
	   			if string.find(text, w) then
	   				des = k
	   			end
			end
    	end

    	UTILS:QsPrint("[Destination Match] ["..playerName.."] ["..(des or '').."]")

    	if des ~= nil then
    		QsMain:teleportPlayer(playerName, des)
    	else
    		UTILS:QsWhisper("1g开门，密我地点：奥格OG，雷霆TB，幽暗UC", playerName)
    	end
    end

    if event == "TRADE_ACCEPT_UPDATE" and QStallConfigCharacter.SwitchOn then
		UTILS:QsPrint("[OnEvent:"..event.."] ["..(arg1 or "nil").."] ["..(arg2 or "nil").."]")
    	local playerAccepted, targetAccepted = arg1, arg2
    	if targetAccepted == 1 then
    		AcceptTrade()
    		local targetTradeMoney = GetTargetTradeMoney();
			UTILS:QsPrint("[targetTradeMoney] ["..tostring(targetTradeMoney).."]")
    		if targetTradeMoney < 2 then
    			SendChatMessage("请付款，至少1g", "YELL")
    		else
    			des = UTILS:queuePop(QsMain.DesQueue)
    			if des ~= nil then
    				if des == "OG" then
    					CastSpellByName("传送门：奥格瑞玛")
    				elseif des == "UC" then
    					CastSpellByName("传送门：幽暗城")
    				elseif des == "TB" then
    					CastSpellByName("传送门：雷霆崖")
    				end
    			end
    		end
    	end
    end
    
    if event == "PLAYER_TRADE_MONEY" and QStallConfigCharacter.SwitchOn then
		UTILS:QsPrint("[OnEvent:"..event.."] ["..(arg1 or "nil").."] ["..(arg2 or "nil").."]")
    	local playerAccepted, targetAccepted = arg1, arg2
    	if targetAccepted == 1 then
    		AcceptTrade()
    	end
    end

end)


-- todo: 队内聊天也要处理；
