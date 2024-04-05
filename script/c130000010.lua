--[[
Tigress Huntress
Card Author: Ani
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--When this card declares an attack: You can return 1 card you control to the hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.rttg,s.rtop)
	c:RegisterEffect(e1)
	--When this card is targeted for an attack: You can either change it to Defense Position, or return it to the hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_POSITION|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e2)
end

--E1
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_ONFIELD)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_RTOHAND,false,tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (not c:IsDefensePos() and c:IsCanChangePosition()) or c:IsAbleToHand()
	end
	local p,loc=c:GetResidence()
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,c,1,p,loc)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,p,loc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local b1=not c:IsDefensePos() and c:IsCanChangePosition()
	local b2=c:IsAbleToHand()
	local opt=Duel.SelectEffect(tp,{b1,STRING_CHANGE_POSITION},{b2,STRING_ADD_TO_HAND})
	if not opt then return end
	if opt==1 then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	elseif opt==2 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end