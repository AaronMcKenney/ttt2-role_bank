local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[BANKER.name] = "Banker"
L["info_popup_" .. BANKER.name] = [[You are a Banker. A banker is a "detective" who receives all of the credits that everyone else spends.]]
L["body_found_" .. BANKER.abbr] = "They were a Banker."
L["search_role_" .. BANKER.abbr] = "This person was a Banker!"
L["target_" .. BANKER.name] = "Banker"
L["ttt2_desc_" .. BANKER.name] = [[You are a Banker. A banker is a "detective" who receives all of the credits that everyone else spends.]]

-- OTHER ROLE LANGUAGE STRINGS
L["receive_credits_" .. BANKER.name] = "Someone has bought something. Your cut of the profit is {c} credit(s)."
L["will_" .. BANKER.name] = "You received {c} credit(s) for killing a banker!"
L["broadcast_suicide_" .. BANKER.name] = "{name} has committed suicide!"
L["broadcast_death_" .. BANKER.name] = "A banker has perished! Long live their credits!"
L["broadcast_murderer_" .. BANKER.name] = "{name} has killed a banker!"
L["broadcast_unknown_murderer_" .. BANKER.name] = "A banker has died under mysterious circumstances!"
L["broadcast_covert_search_" .. BANKER.name] = "{name} has covertly searched a banker's corpse!"
L["handouts_given_" .. BANKER.name] = "{n} handout(s) have been given so far."
L["remaining_handouts_" .. BANKER.name] = "{n} handout(s) remain."
L["no_handouts_" .. BANKER.name] = "No more handouts!"

-- EVENT STRINGS
-- Need to be very specifically worded, due to how the system translates them.
L["title_event_bank_credit"] = "A Banker has benefited from a sale"
L["desc_event_bank_credit"] = "{name1} received {c} credit(s) from {name2}'s shop purchase."
L["title_event_bank_will"] = "A player was listed in a Banker's will"
L["desc_event_bank_will"] = "{name1} received {c} credit(s) from {name2}'s will."
L["tooltip_bank_will_score"] = "Collected a Banker's Will: {score}"
L["bank_will_score"] = "Collected a Banker's Will:"