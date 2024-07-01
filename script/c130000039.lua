--[[
Moblins' 'Mazing Find!
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Add 1 "Moblins" monster from your Deck to your hand. You can only activate 1 "Moblins' 'Mazing Find!" per Duel.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(EFFECT_COUNT_CODE_OATH|EFFECT_COUNT_CODE_DUEL)
	e1:SetFunctions(
		nil,
		nil,
		xgl.SearchTarget(s.filter),
		xgl.SearchOperation(s.filter)
	)	
	c:RegisterEffect(e1)
end
s.listed_series={SET_MOBLINS}

function s.filter(c)
	return c:IsMonster() and c:IsSetCard(SET_MOBLINS)
end