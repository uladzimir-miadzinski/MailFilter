local _, namespace = ...
local C = namespace.Colors

local L =
    setmetatable(
    {},
    {
        __index = function(t, k)
            local v = tostring(k)
            rawset(t, k, v)
            return v
        end
    }
)

namespace.Localization = L

local LOCALE = GetLocale()

if (LOCALE == "enUS" or LOCALE == "enGB") then
    -- English translations go here
    L["by"] = "by"
    L["author"] = "Uladzimir Miadzinski"
    L["mf_descr"] = "open addon gui"
    L["mf_help_descr"] = "show addon help"
    L["mf_ignore_descr"] = "to add one more sender or subject to ignore"
    L["mf_clear_descr"] = "to clear senders or subjects ignore list"
    L["example"] = "Example: "
    L["goldseller"] = "Goldseller"
    L["need_gold_subject"] = "Do you need gold?"
    L["credentials"] = "|r\n\nThe way you can say thanks (WebMoney)\n" .. C.CYAN .. "\nR706771842841, Z358792642716\n"
    L["success"] = C.GREEN .. "Success! |r"
    L["reload_for_effect"] = "Reload interface " .. C.CYAN .. "/reload|r to take effect."
    L["added_to_ignore_list"] = " was added to ignore list. " .. L["reload_for_effect"]
    L["senders_cleared"] = "Ignore list with senders was cleared. " .. L["reload_for_effect"]
    L["subjects_cleared"] = "Ignore list with subjects was cleared. " .. L["reload_for_effect"]
    L["already_exists"] = " already exists in ignore list."
    L["warning"] = C.ORANGE .. "Warning! |r"
    L["mail_from"] = "Mail from "
    L["with_subject"] = "|r with subject "
    L["was_removed"] = "|r was removed."
    L["mf_show_descr"] = "show addon ui frame or (with params) show currently ignored senders or subjects."
    L["senders"] = C.YELLOW .. "Ignored senders: |r"
    L["senders_label"] = "Ignored senders:"
    L["list_senders"] = "Senders"
    L["subjects"] = C.YELLOW .. "Ignored subjects: |r"
    L["subjects_label"] = "Ignored subjects:"
    L["list_subjects"] = "Subjects"
    L["sender"] = "Sender"
    L["subject"] = "Subject"
    L["addon_reset"] = "Addon has been reset to defaults."
    L["mf_reset_descr"] = "reset addon to default values."
    L["mf_hide_descr"] = "hide addon ui frame."
    L["close_btn"] = "Close"
    L["select_ignore_list"] = "Ignore list"
    L['add_to_ignore_list'] = "Add to ignore"
    L['ignore_text'] = "Ignore text:"
    L['empty_str'] = "<empty string>"
    L["nil"] = "<non-value>"
    L["addon_loaded"] = "Addon loaded."
    L["clear_senders_list"] = "Clear senders"
    L["clear_subjects_list"] = "Clear subjects"
    L["reload_ui"] = "Reload UI"
    L["add_to_ignore_pane_title"] = "Add new ignore item"
    L["clear_ignore_lists_pane_title"] = "Clear ignore lists"
    return
end

if LOCALE == "ruRU" then
    -- Russian translations go here
    L["by"] = "от"
    L["author"] = "Владимира Мединского"
    L["mf_descr"] = "открыть окно аддона"
    L["mf_help_descr"] = "показать помощь по аддону"
    L["mf_ignore_descr"] = "добавить еще одного отправителя или один заголовок, чтобы игнорировать"
    L["mf_clear_descr"] = "очистить список игнорирования отправителей или заголовков писем"
    L["example"] = "Пример: "
    L["goldseller"] = "Продавецголды"
    L["need_gold_subject"] = "Нужно золото?"
    L["credentials"] =
        "|r\n\nВы можете сказать спасибо автору аддона через WebMoney: " .. C.CYAN .. "\nR706771842841, Z358792642716\n"
    L["success"] = C.GREEN .. "Успех! |r"
    L["reload_for_effect"] = "Перезагрузите интерфейс " .. C.CYAN .. "/reload|r, чтобы изменения вступили в силу."
    L["added_to_ignore_list"] = " был добавлен в список игнорируемых. " .. L["reload_for_effect"]
    L["senders_cleared"] = "Список игнорируемых отправителей был очищен. " .. L["reload_for_effect"]
    L["subjects_cleared"] = "Список игнорируемых заголовков был очищен. " .. L["reload_for_effect"]
    L["already_exists"] = " уже существует в списке игнорируемых."
    L["warning"] = C.ORANGE .. "Предупреждение! |r"
    L["mail_from"] = "Почта от "
    L["with_subject"] = "|r с заголовком "
    L["was_removed"] = "|r была удалена."
    L["mf_show_descr"] =
        "показать окно аддона или (с параметрами) показать текущий список игнорирования отправителей или заголовков."
    L["senders"] = C.YELLOW .. "Игнорируемые отправители писем: |r"
    L["senders_label"] = "Игнорируемые отправители:"
    L["list_senders"] = "Отправители писем"
    L["subjects"] = C.YELLOW .. "Игнорируемые заголовки писем: |r"
    L["subjects_label"] = "Игнорируемые заголовки:"
    L["list_subjects"] = "Заголовки писем"
    L["sender"] = "Отправитель"
    L["subject"] = "Заголовок"
    L["addon_reset"] = "Аддон был сброшен до значений по умолчанию."
    L["mf_reset_descr"] = "сбросить аддон до значений по умолчанию."
    L["mf_hide_descr"] = "скрыть окно аддона."
    L["close_btn"] = "Закрыть"
    L["select_ignore_list"] = "Список игнорирования"
    L['add_to_ignore_list'] = "Добавить в игнорирование"
    L['ignore_text'] = "Игнорировать текст:"
    L['empty_str'] = "<пустая строка>"
    L["nil"] = "<нет значения>"
    L["addon_loaded"] = "Аддон загружен."
    L["clear_senders_list"] = "Очистить отправителей"
    L["clear_subjects_list"] = "Очистить заголовки"
    L["reload_ui"] = "Перезагрузить интерфейс"
    L["add_to_ignore_pane_title"] = "Добавить новое игнорирование"
    L["clear_ignore_lists_pane_title"] = "Очистка списков игнорирования"
    return
end
