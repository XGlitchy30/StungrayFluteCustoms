--[[
B.E.F. Zelos Force
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BES)
	--[[When this card is activated: Place 3 counters on it.]]
	local e0=c:Activation(nil,nil,nil,nil,s.target,s.activate,true)
	e0:SetCategory(CATEGORY_COUNTER)
	c:RegisterEffect(e0)
	--[["B.E.S." monsters you control gain 300 ATK/DEF.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_BES))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--[[Once per turn, if a "B.E.S." monster(s) is sent to your GY, even during the Damage Step: You can place 1 counter on this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e2)
	--[[If a counter(s) would be removed from a "B.E.S." monster by its own effect, or to activate its own effect, you can remove that many counters from this card instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_RCOUNTER_REPLACE+COUNTER_BES)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.rcon)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BES}
s.counter_place_list={COUNTER_BES}

--E0
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_BES,3,false,LOCATION_SZONE) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,3,tp,COUNTER_BES)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_BES,3) then
		c:AddCounter(COUNTER_BES,3)
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsMonster() and c:IsSetCard(SET_BES) and c:IsControler(tp)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_BES,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_BES)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_BES,1) then
		c:AddCounter(COUNTER_BES,1)
	end
end

--E3
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(COUNTER_BES)<ev or r&(REASON_EFFECT|REASON_COST)==0 or not re or not re:IsActiveType(TYPE_MONSTER) or re:GetActivateLocation()~=LOCATION_MZONE then return false end
	local rc=re:GetHandler()
	return rc:IsFaceup() and rc:IsSetCard(SET_BES)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,COUNTER_BES,ev,REASON_EFFECT)
end