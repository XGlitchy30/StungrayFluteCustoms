--[[
Ronin Kappa
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 "Kappa" Tuner + 1+ non-Tuner "Kappa" monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_KAPPA),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_KAPPA),1,99)
	--FLIP: Target 1 "Kappa" monster you control; it gains 500 ATK or DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(500))
	c:RegisterEffect(e1)
	--If this card is Synchro Summoned: You can target 1 "Kappa" monster you control; it gains 1000 ATK or DEF.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		xgl.SynchroSummonedCond,
		nil,
		s.target2,
		s.operation(1000)
	)
	c:RegisterEffect(e2)
	--You can target 1 monster you control; change it to either face-up or face-down Defense Position.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,4)
	e3:SetCategory(CATEGORY_POSITION|CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		nil,
		s.postg,
		s.posop
	)
	c:RegisterEffect(e3)
	--If this card is targeted for an attack: You can change the attack target to 1 face-down Defense Position monster you control.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,5)
	e4:SetCustomCategory(CATEGORY_CHANGE_ATTACK_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:HOPT()
	e4:SetTarget(s.catg)
	e4:SetOperation(s.caop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_KAPPA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetFirst():HasDefense() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,500)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,500)
	else
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,500)
	end
end
function s.operation(val)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=Duel.GetFirstTarget()
				if tc and tc:IsRelateToChain() and tc:IsFaceup() then
					local c=e:GetHandler()
					local opt=xgl.Option(tp,id,1,true,tc:HasDefense())
					if opt==0 then
						tc:UpdateATK(val,true,{c,true})	
					else
						tc:UpdateDEF(val,true,{c,true})
					end
				end
			end
end

--E2
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetFirst():HasDefense() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,1000)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,1000)
	else
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,1000)
	end
end

--E3
function s.posfilter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) or c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
	Duel.SetConditionalOperationInfo(g:GetFirst():IsPosition(POS_FACEUP_DEFENSE),0,CATEGORY_SET,g,#g,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and s.posfilter(tc) then
		local pos=not tc:IsPosition(POS_FACEUP_DEFENSE) and POS_FACEUP_DEFENSE or POS_FACEDOWN_DEFENSE
		if not tc:IsPosition(POS_FACEUP_DEFENSE) and tc:IsCanTurnSet() then
			pos=Duel.SelectPosition(tp,tc,POS_DEFENSE)
		end
		Duel.ChangePosition(tc,pos)
	end
end

--E4
function s.cafilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cafilter,tp,LOCATION_MZONE,0,Duel.GetAttackTarget())
	if chk==0 then return #g>0 end
	Duel.SetCustomOperationInfo(0,CATEGORY_CHANGE_ATTACK_TARGET,g,1,tp,0)
end
function s.caop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a or not a:IsRelateToBattle() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
	local g=Duel.SelectMatchingCard(tp,s.cafilter,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	if Duel.Highlight(g) and a:CanAttack() and not a:IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(g:GetFirst())
	end
end