local ADDON_NAME, namespace = ...
local L = namespace.Localization
local C = namespace.Colors
local ADDON_LOADED = "ADDON_LOADED"
local MAIL_INBOX_UPDATE = "MAIL_INBOX_UPDATE"
local VARIABLES_LOADED = "VARIABLES_LOADED"
local AceGUI = LibStub("AceGUI-3.0")
local MailFilter = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceTimer-3.0")
local Font = "Fonts\\FRIZQT__.TTF"

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
   -- init() -- for debug needs init after vars loaded
end

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
    /mf - open addon gui
    /mf help
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

    if (action == "help") then
        return showAddonHelp()
    end

    init()
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

function ignoreSender(sender, MailFilterFrame)
    local coloredSender = L["sender"] .. " '" .. C.YELLOW .. sender .. "|r'"

    if (not includes(MailFilterDB.ignore.senders, sender)) then
        table.insert(MailFilterDB.ignore.senders, sender)
        local statusText = L["success"] .. coloredSender .. L["added_to_ignore_list"]
        alert(statusText)
        MailFilterFrame:SetStatusText(statusText)
    else
        local statusText = L["warning"] .. coloredSender .. L["already_exists"]
        alert(statusText)
        MailFilterFrame:SetStatusText(statusText)
    end
end

function ignoreSubject(subject, MailFilterFrame)
    local coloredSubject = "Заголовок '" .. C.YELLOW .. subject .. "|r'"

    if (not includes(MailFilterDB.ignore.subjects, subject)) then
        table.insert(MailFilterDB.ignore.subjects, subject)
        local statusText = L["success"] .. coloredSubject .. L["added_to_ignore_list"]
        alert(statusText)
        MailFilterFrame:SetStatusText(statusText)
    else
        local statusText = L["warning"] .. coloredSubject .. L["already_exists"]
        alert(statusText)
        MailFilterFrame:SetStatusText(statusText)
    end
end

function getAddonHelp()
    local title = C.CYAN .. ADDON_NAME .. "|r " .. L["by"] .. " " .. L["author"] .. "\n\n"
    local slashCommands =
        table.concat(
        {
            C.CYAN .. "/mf|r - " .. L["mf_descr"],
            C.CYAN .. "/mf help|r - " .. L["mf_help_descr"],
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
    local credentials = L["credentials"]

    return title, slashCommands, credentials
end

function showAddonHelp()
    local title, slashCommands, credentials = getAddonHelp()
    alert("\n" .. title .. slashCommands .. credentials)
end

function clearSenders(MailFilterFrame)
    local statusText = L["success"] .. L["senders_cleared"]
    MailFilterDB.ignore.senders = getDefaultSenders()
    alert(statusText)
    MailFilterFrame:SetStatusText(statusText)
end

function clearSubjects(MailFilterFrame)
    local statusText = L["success"] .. L["subjects_cleared"]
    MailFilterDB.ignore.subjects = {}
    alert(statusText)
    MailFilterFrame:SetStatusText(statusText)
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

function getButtonAddToIgnoreList(editBoxIgnoreText, dropdownIgnoreLists, MailFilterFrame)
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

            editBoxIgnoreText:SetText("")
            AceGUI:SetFocus(editBoxIgnoreText.editbox:ClearFocus())

            if (ignoreList == 1) then -- senders
                return ignoreSender(ignoreText, MailFilterFrame)
            end

            if (ignoreList == 2) then -- subjects
                return ignoreSubject(ignoreText, MailFilterFrame)
            end
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

    dropdown.label:SetFont(Font, 12)
    dropdown.dropdown:SetWidth(200)
    dropdown:SetList(ignoreLists)
    dropdown:SetValue(1)
    dropdown:SetLabel(L["select_ignore_list"])

    return dropdown
end

function getEditBoxIgnoreText()
    local editbox = AceGUI:Create("EditBox")

    editbox.label:SetFont(Font, 12)
    editbox:SetLabel(L["ignore_text"])
    editbox:SetWidth(200)
    editbox:DisableButton(true)

    return editbox
end

function releaseWidget(widget)
    AceGUI:Release(widget)
end

function setupMailFilterFrame()
    local width, height = 950, 600
    local MailFilterFrame = AceGUI:Create("Frame")
    MailFilterFrame:SetCallback("OnClose", releaseWidget)
    MailFilterFrame:SetTitle("Mail Filter v0.1.0")
    MailFilterFrame:SetStatusText(L["addon_loaded"])
    MailFilterFrame:SetLayout("Flow")
    MailFilterFrame:SetWidth(width)
    MailFilterFrame:SetHeight(height)
    MailFilterFrame.frame:SetMaxResize(width, height)
    MailFilterFrame.frame:SetMinResize(width, height)
    MailFilterFrame:Show()

    return MailFilterFrame
end

function getListPane(title, ignoreList)
    local pane = AceGUI:Create("InlineGroup")
    pane:SetTitle(title)
    pane:SetLayout("List")
    pane:SetWidth(214)
    pane:SetHeight(600)

    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetWidth(194)
    scrollcontainer:SetHeight(484)
    scrollcontainer:SetLayout("Fill")

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    scrollcontainer:AddChild(scroll)

    for i = 1, getn(ignoreList) do
        local label = AceGUI:Create("Label")
        local labelText = ignoreList[i]

        if (labelText == "") then
            labelText = L["empty_str"]
        elseif (labelText == "nil" or labelText == nil) then
            labelText = L["nil"]
        end

        label:SetText(C.GREENYELLOW .. "'|r" .. labelText .. C.GREENYELLOW .. "'|r")
        label:SetFont(Font, 13)
        label:SetHeight(13)
        scroll:AddChild(label)
    end

    pane:AddChild(scrollcontainer)

    return pane
end

function getButtonClearList(label, MailFilterFrame, cb)
    local btn = AceGUI:Create("Button")

    btn:SetWidth(200)
    btn:SetText(label)
    btn:SetCallback(
        "OnClick",
        function()
            cb(MailFilterFrame)
        end
    )

    return btn
end

function getButtonReloadUI()
    local btn = AceGUI:Create("Button")

    btn:SetWidth(200)
    btn:SetText(L["reload_ui"])
    btn:SetCallback("OnClick", ReloadUI)

    return btn
end

function getAddToIgnorePane(MailFilterFrame)
    local buttonReloadUI = getButtonReloadUI()
    local editBoxIgnoreText = getEditBoxIgnoreText()
    local dropdownIgnoreLists = getDropdownIgnoreLists()
    local buttonAddToIgnoreList = getButtonAddToIgnoreList(editBoxIgnoreText, dropdownIgnoreLists, MailFilterFrame)

    local addToIgnorePane = AceGUI:Create("InlineGroup")
    addToIgnorePane:SetTitle(L["add_to_ignore_pane_title"])
    addToIgnorePane:SetLayout("List")
    addToIgnorePane:SetWidth(423)
    addToIgnorePane:SetHeight(200)

    local addToIgnoreInputsPane = AceGUI:Create("SimpleGroup")
    addToIgnoreInputsPane:SetLayout("Flow")
    addToIgnoreInputsPane:SetWidth(400)
    addToIgnoreInputsPane:SetHeight(100)

    local addToIgnoreButtonsPane = AceGUI:Create("SimpleGroup")
    addToIgnoreButtonsPane:SetLayout("Flow")
    addToIgnoreButtonsPane:SetWidth(400)
    addToIgnoreButtonsPane:SetHeight(100)

    addToIgnoreInputsPane:AddChild(editBoxIgnoreText)
    addToIgnoreInputsPane:AddChild(dropdownIgnoreLists)
    addToIgnoreButtonsPane:AddChild(buttonAddToIgnoreList)
    addToIgnoreButtonsPane:AddChild(buttonReloadUI)

    addToIgnorePane:AddChild(addToIgnoreInputsPane)
    addToIgnorePane:AddChild(addToIgnoreButtonsPane)

    return addToIgnorePane
end

function getHelpPane()
    local title, slashCommands, credentials = getAddonHelp()
    local help = title .. slashCommands .. credentials
    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetHeight(294)
    scrollcontainer:SetLayout("Fill") -- important!

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    local helpText = AceGUI:Create("Label")
    helpText:SetFullWidth(true)
    helpText:SetText(help)
    helpText:SetFont(Font, 13)

    scroll:AddChild(helpText)

    return scrollcontainer
end

function init()
    local MailFilterFrame = setupMailFilterFrame()
    local buttonClearSenders = getButtonClearList(L["clear_senders_list"], MailFilterFrame, clearSenders)
    local buttonClearSubjects = getButtonClearList(L["clear_subjects_list"], MailFilterFrame, clearSubjects)
    local addToIgnorePane = getAddToIgnorePane(MailFilterFrame)
    local sendersPane = getListPane(L["senders_label"], MailFilterDB.ignore.senders)
    local subjectsPane = getListPane(L["subjects_label"], MailFilterDB.ignore.subjects)

    local leftPane = AceGUI:Create("SimpleGroup")
    leftPane:SetLayout("List")
    leftPane:SetWidth(450)

    local rightPane = AceGUI:Create("SimpleGroup")
    rightPane:SetLayout("Flow")
    rightPane:SetWidth(450)

    local clearIgnoreListsPane = AceGUI:Create("InlineGroup")
    clearIgnoreListsPane:SetTitle(L["clear_ignore_lists_pane_title"])
    clearIgnoreListsPane:SetLayout("Flow")
    clearIgnoreListsPane:SetWidth(423)
    clearIgnoreListsPane:AddChild(buttonClearSenders)
    clearIgnoreListsPane:AddChild(buttonClearSubjects)

    local helpPane = getHelpPane()
    local placeholder = AceGUI:Create("InlineGroup")
    placeholder:SetHeight(270)
    placeholder:SetWidth(423)
    placeholder:AddChild(helpPane)

    leftPane:AddChild(addToIgnorePane)
    leftPane:AddChild(clearIgnoreListsPane)
    leftPane:AddChild(placeholder)

    rightPane:AddChild(sendersPane)
    rightPane:AddChild(subjectsPane)

    MailFilterFrame:AddChild(leftPane)
    MailFilterFrame:AddChild(rightPane)
end
