--[[
Moblins? Moblins!
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 "Moblins" monster you control or in your GY; return it to the hand, then you can apply this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SUMMON_SUCCESS)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
		local ge2=ge:Clone()
		ge2:SetCode(EVENT_MSET)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={SET_MOBLINS}

local FLAG_HAS_SUMMONED_MOBLINS	  = id

function s.regfilter(c,p)
	return c:IsSetCard(SET_MOBLINS) and c:IsSummonPlayer(p)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.regfilter,1,nil,p) then
			Duel.RegisterFlagEffect(p,FLAG_HAS_SUMMONED_MOBLINS,RESET_PHASE|PHASE_END,0,1)
		end
	end
end

--E1
function s.thfilter(c)
	return c:IsSetCard(SET_MOBLINS) and c:IsFaceupEx() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.IsPlayerCanSummon(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		--You can Normal Summon 1 "Moblins" monster during your Main Phase this turn, in addition to your Normal Summon/Set of a "Moblins" monster. (You can only gain this effect once per turn.)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
		e1:SetCondition(s.nscon)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MOBLINS))
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.nscon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.PlayerHasFlagEffect(tp,FLAG_HAS_SUMMONED_MOBLINS)
end