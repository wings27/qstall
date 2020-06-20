UTILS = {}
UTILS.QsPrint = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100QStall|r|CFFFF0000>|r"..(msg or "nil"));
end


local QsMain = {}

function QsMain:switchChange(switchOn)
	if switchOn then
		QStallConfigCharacter.switchOn = true
        UTILS.QsPrint('QStall switch on!')

    	SendChatMessage("1g开门，说地点：AG,", "YELL")
    	SendChatMessage("1g开门，说地点：AG,", "DND")
    else
    	QStallConfigCharacter.switchOn = false
        UTILS.QsPrint("QStall switch off!")
    end
end


local function handler(msg, editBox)
    if msg == 'on' then
    	QsMain:switchChange(true)
    elseif msg == 'off' then
    	QsMain:switchChange(false)
    else
        UTILS.QsPrint("Usage: /qstall [on | off]")
    end
end

SLASH_QSTALL1, SLASH_QSTALL2 = '/qs', '/qstall';
SlashCmdList["QSTALL"] = handler;


local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "qstall" then
    	if QStallConfigCharacter == nil then
    		QStallConfigCharacter = {}
    		QStallConfigCharacter.switchOn = false
    	end
    	UTILS.QsPrint("Plugin qstall loaded, qstall switch status:"..tostring(QStallConfigCharacter.switchOn))
    end

    if event == "CHAT_MSG_WHISPER" then
    	local text,playerName = arg1,arg2
    	UTILS.QsPrint("["..event.."] ["..arg1.."] ["..arg2.."]")
    end

    if event == "TRADE_ACCEPT_UPDATE" then
    	local playerAccepted,targetAccepted = arg1,arg2
    	UTILS.QsPrint("["..event.."] ["..arg1.."] ["..arg2.."]")
    end
end)
