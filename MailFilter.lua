local ADDON_NAME, namespace = ...
local L = namespace.Localization
local C = namespace.Colors
local ADDON_LOADED = "ADDON_LOADED"
local MAIL_INBOX_UPDATE = "MAIL_INBOX_UPDATE"
local VARIABLES_LOADED = "VARIABLES_LOADED"
local AceGUI = LibStub("AceGUI-3.0")
local MailFilter = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceTimer-3.0")

function MailFilter:WaitMailInbox()
    self:CancelAllTimers()
    removeExtraMail()
end

function MailFilter:ADDON_LOADED()
    -- This is the first time this addon is loaded; initialize to object.
    if (MailFilterDB == nil) then
        initAddonDB()
    end
end

function MailFilter:MAIL_INBOX_UPDATE()
    self:ScheduleTimer("WaitMailInbox", 0.2) -- need to wait for loading mails
end

    
function MailFilter:VARIABLES_LOADED()
    init()
end;

MailFilter:RegisterEvent(VARIABLES_LOADED)
MailFilter:RegisterEvent(ADDON_LOADED)
MailFilter:RegisterEvent(MAIL_INBOX_UPDATE)

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

        return init()
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

function getButtonAddToIgnoreList(editBoxIgnoreText, dropdownIgnoreLists)
    local btn = AceGUI:Create("Button")

    btn:SetWidth(200)
    btn:SetText(L["add_to_ignore_list"])
    btn:SetCallback(
        "OnClick",
        function()
            local ignoreText = editBoxIgnoreText:GetText()
            local ignoreList = dropdownIgnoreLists:GetValue()

            if (ignoreText == nil) then
                ignoreText = ""
            end
            alert(ignoreText)
            alert(ignoreList)
        end
    )

    return btn
end

function getDropdownIgnoreLists()
    local dropdown = AceGUI:Create("Dropdown")
    local ignoreLists = {
        L["list_senders"],
        L["list_subjects"]
    }

    dropdown:SetWidth(200)
    dropdown:SetList(ignoreLists)
    dropdown:SetValue(1)
    dropdown:SetLabel(L["select_ignore_list"])

    return dropdown
end

function getEditBoxIgnoreText()
    local editbox = AceGUI:Create("EditBox")

    editbox:SetLabel(L["ignore_text"])
    editbox:SetWidth(200)
    editbox:DisableButton(true)

    return editbox
end

function releaseWidget(widget)
    AceGUI:Release(widget)
end

function setupMailFilterFrame()
    local MailFilterFrame = AceGUI:Create("Frame")
    MailFilterFrame:SetCallback("OnClose", releaseWidget)
    MailFilterFrame:SetTitle("Mail Filter v0.1.0")
    MailFilterFrame:SetStatusText(L["Addon_loaded"])
    MailFilterFrame:SetLayout("Flow")
    MailFilterFrame:SetWidth(635)
    MailFilterFrame:SetHeight(480)
    MailFilterFrame:Show()

    return MailFilterFrame
end

function getListPane(title, ignoreList)
    local pane = AceGUI:Create("SimpleGroup")
    pane:SetLayout("List")

    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetWidth(295)
    scrollcontainer:SetHeight(334)
    scrollcontainer:SetLayout("Fill")

    local sendersScrollPaneLabel = AceGUI:Create("Label")
    sendersScrollPaneLabel:SetText(title)
    sendersScrollPaneLabel:SetHeight(15)
    sendersScrollPaneLabel:SetColor(0.94, 0.77, 0)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    scrollcontainer:AddChild(scroll)

    for i, ignoreText in ipairs(ignoreList) do
        local label = AceGUI:Create("Label")
        label:SetText(ignoreText)
        scroll:AddChild(label)
    end

    pane:AddChild(sendersScrollPaneLabel)
    pane:AddChild(scrollcontainer)

    return pane
end

function init()
    local MailFilterFrame = setupMailFilterFrame()
    local editBoxIgnoreText = getEditBoxIgnoreText()
    local dropdownIgnoreLists = getDropdownIgnoreLists()
    local buttonAddToIgnoreList = getButtonAddToIgnoreList(editBoxIgnoreText, dropdownIgnoreLists)

    MailFilterFrame:AddChild(editBoxIgnoreText)
    MailFilterFrame:AddChild(dropdownIgnoreLists)
    MailFilterFrame:AddChild(buttonAddToIgnoreList)

    local sendersPane = getListPane(L["senders_label"], MailFilterDB.ignore.senders)
    local subjectsPane = getListPane(L["subjects_label"], MailFilterDB.ignore.subjects)

    MailFilterFrame:AddChild(sendersPane)
    MailFilterFrame:AddChild(subjectsPane)
end
