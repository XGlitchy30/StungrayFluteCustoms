--[[
Adira, Apotheosized
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
end
s.listed_names={CARD_ADIRAS_WILL}