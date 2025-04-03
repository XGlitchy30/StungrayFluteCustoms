--[[
Mystic Six Samurai - Rihyo
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a "Six Samurai" monster or a card that mentions Bushido Counters on it, you can Special Summon this card (from your hand). You can only Special Summon "Mystic Six Samurai -
	Rihyo" once per turn this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spscon)
	c:RegisterEffect(e1)
	--[[During your Standby Phase: You can pay 500 LP; Special Summon this card from your GY. You must control a "Six Samurai" monster or a card that mentions Bushido Counters on it to activate and
	resolve this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		s.spcon,
		aux.PayLPCost(500),
		xgl.SpecialSummonSelfTarget(),
		s.spop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SIX_SAMURAI}
s.counter_list={COUNTER_BUSHIDO}

--E1
function s.spfilter(c)
	return c:IsFaceup() and ((c:IsSetCard(SET_SIX_SAMURAI) and c:IsLocation(LOCATION_MZONE)) or c:ListsCounter(COUNTER_BUSHIDO))
end
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

--E3
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end