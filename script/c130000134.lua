--[[
Reinforcements of the Six Samurai
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BUSHIDO)
	--[[When this card is activated, or if a Six Samurai monster(s) is sent to the GY: Place 1 Bushido Counter on this card]]
	local e0=c:Activation(nil,nil,nil,nil,s.target,s.activate,true)
	e0:SetCategory(CATEGORY_COUNTER)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e1)
	--[["Six Samurai" monsters you control gain 100 ATK for each Bushido Counter on this card]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SIX_SAMURAI))
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--[[You can remove 6 Bushido Counters from this card, then target 1 "Six Samurai" monster in your GY or banishment; Special Summon it.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(xgl.RemoveCounterSelfCost(COUNTER_BUSHIDO,6))
	e2:SetSpecialSummonFunctions(nil,TGCHECK_IT,xgl.FaceupExFilter(Card.IsSetCard,SET_SIX_SAMURAI),LOCATION_GB,0,1,1,nil)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SIX_SAMURAI}
s.counter_place_list={COUNTER_BUSHIDO}

--E0
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_BUSHIDO,1,false,LOCATION_SZONE) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_BUSHIDO)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_BUSHIDO,1) then
		c:AddCounter(COUNTER_BUSHIDO,1)
	end
end

--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_SIX_SAMURAI)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_BUSHIDO)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_BUSHIDO,1) then
		c:AddCounter(COUNTER_BUSHIDO,1)
	end
end

--E2
function s.atkval(e,c)
	return math.max(0,e:GetHandler():GetCounter(COUNTER_BUSHIDO))*100
end