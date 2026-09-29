--[[
Spider Girl Helper 
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:HOPT()
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end

--E1
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase(tp) then return false end
    --local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PERCUSSION_BEETLE),tp,LOCATION_MZONE,0,nil)
	return true--g:GetClassCount(Card.GetCode)>=3 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.AddBattlePhase()
end