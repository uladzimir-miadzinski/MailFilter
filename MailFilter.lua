local ADDON_NAME, namespace = ...
local L = namespace.L

function alert(text)
    local addon = '|cffFF0000[' .. ADDON_NAME .. ']: |r'
    print(addon .. text)
end

function arrToString(arr, indentLevel)
    local str = '['
    local indentStr = ''

    if (indentLevel == nil) then
        return arrToString(arr, 0)
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. '\t'
    end

    for index, value in pairs(arr) do
        if type(value) == 'table' then
            str = str .. indentStr .. index .. ': \n' .. arrToString(value, (indentLevel + 1))
        else
            str = str .. "'" .. value .. "', "
        end
    end

    if (string.len(str) > 1) then
        str = string.sub(str, 0, -3)
    end

    return str .. ']'
end

-- slash commands
-- /mf_ignore_sender nil

SLASH_MF1 = '/mf'
SLASH_MF_IGNORE_SENDER1 = '/mf_ignore_sender'
SLASH_MF_IGNORE_HEADING1 = '/mf_ignore_heading'
SLASH_MF_CLEAR_SENDERS1 = '/mf_clear_senders'
SLASH_MF_CLEAR_HEADINGS1 = '/mf_clear_headings'
SLASH_MF_SHOW_SENDERS1 = '/mf_show_senders'
SLASH_MF_SHOW_HEADINGS1 = '/mf_show_headings'
SLASH_MF_RESET1 = '/mf_reset'

SlashCmdList['MF'] = function(msg)
    local title = '|cff00ffff Mail Filter |r' .. L['by'] .. ' ' .. L['author'] .. '\n'
    local slashCommands =
        table.concat(
        {
            '|cff00ffff /mf |r - ' .. L['this_menu'],
            '|cff00ffff /mf_ignore_sender |r- ' .. L['mf_ignore_sender_descr'],
            L['example'] .. ': |cff00ff00 /mf_ignore_sender ' .. L['goldseller'],
            '|cff00ffff /mf_ignore_heading |r- ' .. L['mf_ignore_heading_descr'],
            L['example'] .. ': |cff00ff00 /mf_ignore_heading ' .. L['need_gold_heading'],
            '|cff00ffff /mf_clear_senders |r- ' .. L['mf_clear_senders_descr'],
            '|cff00ffff /mf_clear_headings |r- ' .. L['mf_clear_headings_descr'],
            '|cff00ffff /mf_show_senders |r- ' ..
                L['mf_show_senders_descr'] '|cff00ffff /mf_show_headings |r- ' .. L['mf_show_headings_descr']
        },
        '\n'
    )

    alert(title .. slashCommands .. L['credentials'])
end

SlashCmdList['MF_IGNORE_SENDER'] = function(senderToIgnore)
    if (not includes(MailFilterDB.ignore.senders, senderToIgnore)) then
        table.insert(MailFilterDB.ignore.senders, senderToIgnore)
        alert(L['success'] .. 'Отправитель \'|cFFFFF569' .. senderToIgnore .. '|r\'' .. L['added_to_ignore_list'])
    else
        alert(L['warning'] .. 'Отправитель \'|cFFFFF569' .. senderToIgnore .. '|r\'' .. L['already_exists'])
    end
end

SlashCmdList['MF_IGNORE_HEADING'] = function(headingToIgnore)
    if (not includes(MailFilterDB.ignore.headings, headingToIgnore)) then
        table.insert(MailFilterDB.ignore.headings, headingToIgnore)
        alert(L['success'] .. 'Заголовок \'|cFFFFF569' .. headingToIgnore .. '|r\'' .. L['added_to_ignore_list'])
    else
        alert(L['warning'] .. 'Заголовок \'|cFFFFF569' .. headingToIgnore .. '|r\'' .. L['already_exists'])
    end
end

SlashCmdList['MF_CLEAR_SENDERS'] = function()
    MailFilterDB.ignore.senders = {}
    alert(L['success'] .. L['senders_cleared'])
end

SlashCmdList['MF_CLEAR_HEADINGS'] = function()
    MailFilterDB.ignore.headings = {}
    alert(L['success'] .. L['headings_cleared'])
end

SlashCmdList['MF_SHOW_SENDERS'] = function()
    local senders = arrToString(MailFilterDB.ignore.senders)
    alert(L['senders'] .. senders)
end

SlashCmdList['MF_SHOW_HEADINGS'] = function()
    local headings = arrToString(MailFilterDB.ignore.headings)
    alert(L['headings'] .. headings)
end

SlashCmdList['MF_RESET'] = function()
    initAddonDB()
    alert(L['addon_reset'])
end

-- core

local frame = CreateFrame('FRAME', 'MailFilterFrame')
local ADDON_LOADED = 'ADDON_LOADED'
local MAIL_INBOX_UPDATE = 'MAIL_INBOX_UPDATE'
local MAIL_SHOW = 'MAIL_SHOW'

frame:RegisterEvent(ADDON_LOADED)
frame:RegisterEvent(MAIL_SHOW)
frame:RegisterEvent(MAIL_INBOX_UPDATE)

function includes(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end

    return false
end

function initAddonDB()
    MailFilterDB = {
        ignore = {
            senders = {
                '', -- addon will automatically remove mails without sender (if character was removed)
                'nil' -- addon will automatically remove mails without sender (if character was removed)
            },
            headings = {}
        }
    }
end

function onGlobalEvent(self, event)
    local waitInboxTimeout = .3 -- need to wait for loading mails

    -- This is the first time this addon is loaded; initialize to object.
    if (event == ADDON_LOADED and MailFilterDB == nil) then
        initAddonDB()
    end

    if (event == MAIL_SHOW) then
        CheckInbox()
    end

    if (event == MAIL_INBOX_UPDATE) then
        frame:SetScript(
            'OnUpdate',
            function(f, e)
                waitInboxTimeout = waitInboxTimeout - e
                if waitInboxTimeout < 0 then
                    removeExtraMail()
                    f:SetScript('OnUpdate', nil)
                end
            end
        )
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
                local mailFrom = L['mail_from'] .. '|cff00ffff' .. sender
                local mailHeading = L['with_heading'] .. '|cffffff00' .. heading

                alert(mailFrom .. mailHeading .. L['was_removed'])
            end
        end
    end
end

frame:SetScript('OnEvent', onGlobalEvent)
