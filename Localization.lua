local _, namespace = ...

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

namespace.L = L

local LOCALE = GetLocale()

if (LOCALE == 'enUS' or LOCALE == 'enGB') then
    -- English translations go here
    L['by'] = 'by';
    L['author'] = 'Uladzimir Miadzinski';
    L['this_menu'] = 'this menu';
    L['mf_ignore_sender_descr'] = 'to add one more sender to ignore';
    L['mf_ignore_subject_descr'] = 'to add one more subject to ignore';
    L['mf_clear_senders_descr'] = 'to clear senders ignore list';
    L['mf_clear_subjects_descr'] = 'to clear subjects ignore list';
    L['example'] = 'Example';
    L['goldseller'] = 'Goldseller';
    L['need_gold_subject'] = 'Do you need gold?';
    L['credentials'] = '|r\n\nThe way you can say thanks (WebMoney)\n|cff00ffff R706771842841, Z358792642716';
    L['success'] = '|cff00ff00Success! :) |r';
    L['reload_for_effect'] = '|cff00ffff/reload |r to take effect.';
    L['added_to_ignore_list'] = ' was added to ignore list. ' .. L['reload_for_effect'];
    L['senders_cleared'] = 'Ignore list with senders was cleared. ' .. L['reload_for_effect'];
    L['subjects_cleared'] = 'Ignore list with subjects was cleared. ' .. L['reload_for_effect'];
    L['already_exists'] = ' already exists in ignore list.';
    L['warning'] = '|cffff7d0aWarning! |r';
    L['mail_from'] = 'Mail from ';
    L['with_subject'] = '|r with subject ';
    L['was_removed'] = '|r was removed.';
    L['mf_show_senders_descr'] = 'show currently ignored senders.';
    L['mf_show_subjects_descr'] = 'show currently ignored subjects.';
    L['senders'] = '|cFFFFF569Ignored senders: |r';
    L['subjects'] = '|cFFFFF569Ignored subjects: |r';
    L['sender'] = 'Sender';
    L['subject'] = 'Subject';
    L['addon_reset'] = 'Addon has been reset to defaults.';
    L['mf_reset_descr'] = 'reset addon to default values.';
    return
end

if LOCALE == 'ruRU' then
    -- Russian translations go here
    L['by'] = 'от';
    L['author'] = 'Владимира Мединского';
    L['this_menu'] = 'это меню';
    L['mf_ignore_sender_descr'] = 'добавить еще одного отправителя, чтобы игнорировать';
    L['mf_ignore_subject_descr'] = 'добавить еще один заголовок, чтобы игнорировать';
    L['mf_clear_senders_descr'] = 'очистить список игнорирования отправителей';
    L['mf_clear_subjects_descr'] = 'очистить список игнорирования заголовков писем';
    L['example'] = 'Пример';
    L['goldseller'] = 'Продавецголды';
    L['need_gold_subject'] = 'Нужно золото?';
    L['credentials'] = '|r\n\nВы можете сказать спасибо автору аддона через WebMoney \n|cff00ffff R706771842841, Z358792642716';
    L['success'] = '|cff00ff00Успех! :) |r';
    L['reload_for_effect'] = '|cff00ffff/reload |r для того, чтобы изменения вступили в силу.';
    L['added_to_ignore_list'] = ' был добавлен в список игнорируемых. ' .. L['reload_for_effect'];
    L['senders_cleared'] = 'Список игнорируемых отправителей был очищен. ' .. L['reload_for_effect'];
    L['subjects_cleared'] = 'Список игнорируемых заголовков был очищен. ' .. L['reload_for_effect'];
    L['already_exists'] = ' уже существует в списке игнорируемых.';
    L['warning'] = '|cffff7d0aПредупреждение! |r';
    L['mail_from'] = 'Почта от ';
    L['with_subject'] = '|r с заголовком ';
    L['was_removed'] = '|r была удалена.';
    L['mf_show_senders_descr'] = 'показать текущий список игнорирования отправителей.';
    L['mf_show_subjects_descr'] = 'показать текущий список игнорирования заголовков.';
    L['senders'] = '|cFFFFF569Игнорируемые отправители: |r';
    L['subjects'] = '|cFFFFF569Игнорируемые заголовки: |r';
    L['sender'] = 'Отправитель';
    L['subject'] = 'Заголовок';
    L['addon_reset'] = 'Аддон был сброшен до значений по умолчанию.';
    L['mf_reset_descr'] = 'сбросить аддон до значений по умолчанию';
    return
end