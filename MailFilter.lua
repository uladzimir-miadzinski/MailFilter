-- slash commands

SLASH_MAILFILTER1 = "/mailfilter";

SlashCmdList["MAILFILTER"] = function(msg)
   print('R706771842841, Z358792642716 - You can say thanks through webmoney. Uladzimir Miadzinski');
end;

-- core

local frame = CreateFrame("FRAME", "MailFilterFrame");
local MAIL_INBOX_UPDATE = "MAIL_INBOX_UPDATE";

frame:RegisterEvent(MAIL_INBOX_UPDATE);

function onGlobalEvent(self, event)
	print("Hello World! Hello " .. event);
	if (event == MAIL_INBOX_UPDATE) then
		print('Mail inbox update!');
	end;
end

frame:SetScript("OnEvent", onGlobalEvent);