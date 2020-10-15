local L = LANG.GetLanguageTableReference("english")

-- GENERAL ROLE LANGUAGE STRINGS
L[BANKER.name] = "Banker"
L["info_popup_" .. BANKER.name] = [[You are a Banker! A banker is a "detective" who receives all of the credits that everyone else spends.]]
L["body_found_" .. BANKER.abbr] = "They were a Banker."
L["search_role_" .. BANKER.abbr] = "This person was a Banker!"
L["target_" .. BANKER.name] = "Banker"
L["ttt2_desc_" .. BANKER.name] = [[You are a Banker! A banker is a "detective" who receives all of the credits that everyone else spends.]]

-- OTHER ROLE LANGUAGE STRINGS
L["receive_credits_" .. BANKER.name] = "Someone has bought something. Your cut of the profit is {c} credits."
L["will_" .. BANKER.name] = "You received {c} credits for killing a banker!"
L["no_handouts_" .. BANKER.name] = "Giving handouts enthrals beggars!"
