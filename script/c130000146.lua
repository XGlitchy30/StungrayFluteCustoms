--[[
Ancestagon Frontline
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Special Summon 1 Level 2 "Ancestagon" monster from your hand, GY or face-up Extra Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetSpecialSummonFunctions(nil,nil,s.spfilter,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY; add 1 Level 8 or higher "Ancestagon" monster from your Deck to your Extra Deck, face-up.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(aux.bfgcost)
	e2:SetSendtoFunctions(LOCATION_EXTRA,nil,s.tefilter,LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.spfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(SET_ANCESTAGON) and c:IsLevel(2)
end

--E2
function s.tefilter(c)
	return c:IsSetCard(SET_ANCESTAGON) and c:IsLevelAbove(8)
end