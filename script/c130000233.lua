--[[
Genesi dei Kappa
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Add 1 "Kappa" monster from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e1)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_KAPPA)
end