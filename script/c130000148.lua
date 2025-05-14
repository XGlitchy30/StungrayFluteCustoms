--[[
Ancestagon Survival
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[This turn, "Ancestagon" monsters you control cannot be destroyed by card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,nil,nil,s.activate)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY; add 1 "Ancestagon" Spell/Trap from your Deck to your hand, except "Ancestagon Survival"]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetCost(aux.bfgcost)
	e2:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ANCESTAGON}

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.condition(e,tp,eg,ep,ev,re,r,rp) then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ANCESTAGON))
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end

--E2
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_ANCESTAGON) and not c:IsCode(id)
end