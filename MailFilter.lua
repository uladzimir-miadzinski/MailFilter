local ADDON_NAME, namespace = ...
local L = namespace.Localization
local C = namespace.Colors
local ADDON_LOADED = "ADDON_LOADED"
local MAIL_INBOX_UPDATE = "MAIL_INBOX_UPDATE"
local MAIL_SHOW = "MAIL_SHOW"

--------------------------------------------------------------------------------
--  HELPERS
--------------------------------------------------------------------------------

function alert(text)
    print(C.RED .. "[" .. ADDON_NAME .. "]: |r" .. text)
end

function arrToString(arr, indentLevel)
    local str = "["
    local indentStr = ""

    if (indentLevel == nil) then
        return arrToString(arr, 0)
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. "\t"
    end

    for index, value in pairs(arr) do
        if type(value) == "table" then
            str = str .. indentStr .. index .. ": \n" .. arrToString(value, (indentLevel + 1))
        else
            str = str .. "'" .. value .. "', "
        end
    end

    if (string.len(str) > 1) then
        str = string.sub(str, 0, -3)
    end

    return str .. "]"
end
--

--------------------------------------------------------------------------------
--  SLASH COMMANDS
--------------------------------------------------------------------------------

--[[
    /mf - help
    /mf reset - reset addon to defaults
    /mf show [senders|subjects]? - show frame | show list of ignored senders/subjects
    /mf [i|ignore] [sender|subject] %arg% - add smth to ignored senders/subjects list
    /mf hide - hide frame
]] SLASH_MF1 =
    "/mf"

SlashCmdList["MF"] = function(arg)
    local action, category, param = strsplit(" ", arg)

    if (action == "hide") then
        return MailFilterFrame:Hide()
    end

    if (action == "show") then
        if (category == "senders") then
            return showSenders()
        end

        if (category == "subjects") then
            return showSubjects()
        end

        return MailFilterFrame:Show()
    end

    if (action == "clear") then
        if (category == "senders") then
            return clearSenders()
        end

        if (category == "subjects") then
            return clearSubjects()
        end
    end

    if (action == "i" or action == "ignore") then
        return addToIgnoreCategory(category, param)
    end

    if (action == "reset") then
        return resetAddon()
    end

    showAddonHelp()
end

--------------------------------------------------------------------------------
--  CORE
--------------------------------------------------------------------------------

function addToIgnoreCategory(category, text)
    if (category == "sender") then
        return ignoreSender(text)
    end

    if (category == "subject") then
        return ignoreSubject(text)
    end
end

function ignoreSender(sender)
    local coloredSender = L["sender"] .. " '" .. C.YELLOW .. sender .. "|r'"

    if (not includes(MailFilterDB.ignore.senders, sender)) then
        table.insert(MailFilterDB.ignore.senders, sender)
        alert(L["success"] .. coloredSender .. L["added_to_ignore_list"])
    else
        alert(L["warning"] .. coloredSender .. L["already_exists"])
    end
end

function ignoreSubject(subject)
    local coloredSubject = "Заголовок '" .. C.YELLOW .. subject .. "|r'"

    if (not includes(MailFilterDB.ignore.subjects, subject)) then
        table.insert(MailFilterDB.ignore.subjects, subject)
        alert(L["success"] .. coloredSubject .. L["added_to_ignore_list"])
    else
        alert(L["warning"] .. coloredSubject .. L["already_exists"])
    end
end

function showAddonHelp()
    local title = C.CYAN .. "\n" .. ADDON_NAME .. "|r " .. L["by"] .. " " .. L["author"] .. "\n"
    local slashCommands =
        table.concat(
        {
            C.CYAN .. "/mf|r - " .. L["this_menu"],
            C.CYAN .. "/mf reset|r - " .. L["mf_reset_descr"],
            C.CYAN .. "/mf [ i, ignore ] [ sender, subject ]|r - " .. L["mf_ignore_descr"],
            L["example"] .. C.GREEN .. "/mf i sender " .. L["goldseller"] .. "|r",
            L["example"] .. C.GREEN .. "/mf i subject " .. L["need_gold_subject"] .. "|r",
            C.CYAN .. "/mf clear [ senders, subjects ]|r - " .. L["mf_clear_descr"],
            L["example"] .. C.GREEN .. "/mf clear subjects",
            C.CYAN .. "/mf show [ senders, subjects ]|r - " .. L["mf_show_descr"],
            L["example"] .. C.GREEN .. "/mf show|r",
            L["example"] .. C.GREEN .. "/mf show senders|r",
            C.CYAN .. "/mf hide|r - " .. L["mf_hide_descr"],
            L["example"] .. C.GREEN .. "/mf hide|r"
        },
        "\n"
    )

    alert(title .. slashCommands .. L["credentials"])
end

function clearSenders()
    MailFilterDB.ignore.senders = getDefaultSenders()
    alert(L["success"] .. L["senders_cleared"])
end

function clearSubjects()
    MailFilterDB.ignore.subjects = {}
    alert(L["success"] .. L["subjects_cleared"])
end

function showSenders()
    alert(L["senders"] .. arrToString(MailFilterDB.ignore.senders))
end

function showSubjects()
    alert(L["subjects"] .. arrToString(MailFilterDB.ignore.subjects))
end

function getDefaultSenders()
    return {
        "", -- addon will automatically remove mails without sender (if character was removed)
        "nil" -- addon will automatically remove mails without sender (if character was removed)
    }
end

function includes(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end

    return false
end

function resetAddon()
    alert(L["addon_reset"])
    initAddonDB()
end

function initAddonDB()
    MailFilterDB = {
        ignore = {
            senders = getDefaultSenders(),
            subjects = {}
        }
    }
end

function onGlobalEvent(self, event)
    local waitInboxTimeout = .2 -- need to wait for loading mails

    -- This is the first time this addon is loaded; initialize to object.
    if (event == ADDON_LOADED and MailFilterDB == nil) then
        initAddonDB()
    end

    if (event == MAIL_SHOW) then
        CheckInbox()
    end

    if (event == MAIL_INBOX_UPDATE) then
        MailFilterFrame:SetScript(
            "OnUpdate",
            function(f, e)
                waitInboxTimeout = waitInboxTimeout - e
                if waitInboxTimeout < 0 then
                    removeExtraMail()
                    f:SetScript("OnUpdate", nil)
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
        local subject = tostring(_subject)

        -- check for money and items to prevent removing emails with money or items
        if (money == 0 and not hasItem) then
            -- for 0.1 version let it be strict equal comparison
            if (includes(MailFilterDB.ignore.senders, sender) or includes(MailFilterDB.ignore.subjects, subject)) then
                DeleteInboxItem(index)
                local mailFrom = L["mail_from"] .. C.CYAN .. sender
                local mailSubject = L["with_subject"] .. C.YELLOW .. subject

                alert(mailFrom .. mailSubject .. L["was_removed"])
            end
        end
    end
end

function onLoad()
    MailFilterFrame:RegisterEvent(ADDON_LOADED)
    MailFilterFrame:RegisterEvent(MAIL_SHOW)
    MailFilterFrame:RegisterEvent(MAIL_INBOX_UPDATE)
    MailFilterFrame:SetScript("OnEvent", onGlobalEvent)
    MailFilterFrame:RegisterForDrag("LeftButton")
    MailFilterFrame:SetBackdrop(
        {
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tileSize = 16,
            edgeSize = 16,
            insets = {left = 5, right = 5, top = 5, bottom = 5}
        }
    )
    CloseButton:SetText(L["close_btn"])
end
