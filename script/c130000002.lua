--[[
Jet the Stream
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),4,2)
	c:EnableReviveLimit()
end