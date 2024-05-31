--[[
Jinzo - Parallel
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Once while this card is face-up on the field, if a Trap Card is activated (Quick Effect): Target that card; negate its effects. While this card is equipped with "Amplifier", you cannot activate the previous effect in response to your Trap Card activations.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL|EFFECT_FLAG_NO_TURN_RESET|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:OPT()
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_names={CARD_AMPLIFIER}

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and (not c:IsEquippedWith(CARD_AMPLIFIER) or rp~=tp)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanBeEffectTarget(e) and rc:IsNegatableSpellTrap() end
	if rc:IsRelateToChain(ev) and Duel.GetCurrentChain()==ev+1 then
		Duel.SetTargetCard(rc)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain(ev) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		Duel.Negate(tc,e,0,false,false,TYPE_TRAP)
	end
end