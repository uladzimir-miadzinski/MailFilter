-- slash commands
-- /mf_ignore_sender nil

SLASH_MF1 = '/mf'
SLASH_MF_IGNORE_SENDER1 = '/mf_ignore_sender'
SLASH_MF_IGNORE_HEADING1 = '/mf_ignore_heading'
SLASH_MF_CLEAR_SENDERS1 = '/mf_clear_senders'
SLASH_MF_CLEAR_HEADINGS1 = '/mf_clear_headings'

SlashCmdList['MF'] = function(msg)
    print(
        '|cff00ffff Mail Filter |r by Uladzimir Miadzinski\n' ..
            '|cff00ffff /mf |r - this menu\n' ..
                '|cff00ffff /mf_ignore_sender |r- to add one more sender to ignore. \n Example: |cff00ff00 /mf_ignore_sender Goldseller\n' ..
                    '|cff00ffff /mf_ignore_heading |r- to add one more heading to ignore. \n Example: |cff00ff00 /mf_ignore_heading WTS Gold\n' ..
                        '|cff00ffff /mf_clear_senders |r- to clear senders ignore list.\n' ..
                            '|cff00ffff /mf_clear_headings |r- to clear headings ignore list.\n\n' ..
                                '|r The way you can say thanks (WebMoney)\n|cff00ffff R706771842841, Z358792642716 |r'
    )
end

SlashCmdList['MF_IGNORE_SENDER'] = function(senderToIgnore)
    if (not includes(MailFilterDB.ignore.senders, senderToIgnore)) then
        table.insert(MailFilterDB.ignore.senders, senderToIgnore)
        print(
            '|cff00ff00 SUCCESS! :) |r' ..
                senderToIgnore .. ' was added to ignore list. |cff00ffff /reload |r to take effect.'
        )
    else
        print('|cffff7d0a WARNING! |r' .. senderToIgnore .. ' already exists in ignore list.')
    end
end

SlashCmdList['MF_IGNORE_HEADING'] = function(headingToIgnore)
    if (not includes(MailFilterDB.ignore.headings, headingToIgnore)) then
        table.insert(MailFilterDB.ignore.headings, headingToIgnore)
        print(
            '|cff00ff00 SUCCESS! :) |r' ..
                headingToIgnore .. ' was added to ignore list. |cff00ffff /reload |r to take effect.'
        )
    else
        print('|cffff7d0a WARNING! |r' .. headingToIgnore .. ' already exists in ignore list.')
    end
end

SlashCmdList['MF_CLEAR_SENDERS'] = function()
    MailFilterDB.ignore.senders = {}
    print('|cff00ff00 SUCCESS! :) |r Ignore list with senders was cleared. |cff00ffff /reload |r to take effect.')
end

SlashCmdList['MF_CLEAR_HEADINGS'] = function()
    MailFilterDB.ignore.headings = {}
    print('|cff00ff00 SUCCESS! :) |r Ignore list with headings was cleared. |cff00ffff /reload |r to take effect.')
end

-- core

local frame = CreateFrame('FRAME', 'MailFilterFrame')
local ADDON_LOADED = 'ADDON_LOADED'
local MAIL_INBOX_UPDATE = 'MAIL_INBOX_UPDATE'
local MAIL_SHOW = 'MAIL_SHOW'

frame:RegisterEvent(ADDON_LOADED)
frame:RegisterEvent(MAIL_INBOX_UPDATE)
frame:RegisterEvent(MAIL_SHOW)

function includes(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end

    return false
end

function onGlobalEvent(self, event)
    -- This is the first time this addon is loaded; initialize to object.
    if (event == ADDON_LOADED and MailFilterDB == nil) then
        MailFilterDB = {
            ignore = {
                senders = {
                    'nil' -- addon will automatically remove mails without sender (if character was removed)
                },
                headings = {}
            }
        }
    end

    if (event == MAIL_SHOW) then
        CheckInbox()
    end

    if (event == MAIL_INBOX_UPDATE) then
        removeExtraMail()
    end
end

function removeExtraMail()
    local mailsCount = GetInboxNumItems()

    for index = 1, mailsCount do
        local _, _, _sender, _subject, money, _, _, hasItem = GetInboxHeaderInfo(index)
        local sender = tostring(_sender)
        local heading = tostring(_subject)

        -- check for money and items to prevent removing emails with money or items
        if (money == 0 and not hasItem) then
            -- for 0.1 version let it be strict equal comparison
            if (includes(MailFilterDB.ignore.senders, sender) or includes(MailFilterDB.ignore.headings, heading)) then
                DeleteInboxItem(index)
                print('Mail from |cff00ffff' .. sender .. '|r with heading |cffffff00' .. heading .. '|r was removed.')
            end
        end
    end
end

frame:SetScript('OnEvent', onGlobalEvent)