--[[
Spirit of Perfection
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
end
s.listed_names={CARD_REGRESSED_RITUAL_ART}