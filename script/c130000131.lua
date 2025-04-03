--[[
B.E.S. Covered Core Mk-2
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BES)
	--[[If this card is Summoned: Place 4 counters on it.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetFunctions(
		nil,
		nil,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
	--[[Once per turn: You can remove 2 counters from this card; add 1 "B.E.S." card from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetCost(xgl.RemoveCounterSelfCost(COUNTER_BES,2))
	e2:SetSearchFunctions(xgl.ArchetypeFilter(SET_BES))
	c:RegisterEffect(e2)
	--[[At the end of the Damage Step, if this card battled: Activate the appropriate effect, based on the number of counters on it.
	● 0: Destroy this card.
	● 1+: Toss a coin and call it. If you call it wrong, remove 1 counter from this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetTarget(s.rcttg)
	e3:SetOperation(s.rctop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BES}
s.counter_place_list={COUNTER_BES}
s.toss_coin=true

--E1
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,4,tp,COUNTER_BES)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_BES,4) then
		c:AddCounter(COUNTER_BES,4)
	end
end

--E3
function s.rcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:HasCounter(COUNTER_BES) then
		e:SetCategory(CATEGORY_COIN)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetTargetParam(0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	end
end
function s.rctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetTargetParam()
	if opt==0 then
		if c:IsRelateToChain() then
			Duel.Destroy(c,REASON_EFFECT)
		end
	elseif opt==1 then
		if not Duel.CallCoin(tp) and c:IsRelateToChain() and c:IsCanRemoveCounter(tp,COUNTER_BES,1,REASON_EFFECT) then
			c:RemoveCounter(tp,COUNTER_BES,1,REASON_EFFECT)
		end
	end
end