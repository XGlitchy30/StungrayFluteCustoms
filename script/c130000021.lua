--[[
Adira's Will
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	Ritual.AddProcGreaterCode(c,6,nil,CARD_ADIRA_APOTHEOSIZED)
end