--[[
EROE Malvagio Corruttrice
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 "Evil HERO" monster + 1 "Elemental HERO" monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_EVIL_HERO),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ELEMENTAL_HERO))
	--Must be Special Summoned with "Dark Fusion"
	c:AddMustBeSpecialSummonedByDarkFusion()
	--You can only control 1 "Evil HERO Corrupter".
	c:SetUniqueOnField(1,0,id)
	--When this card is Fusion Summoned using a Normal Monster as material: You can target 1 monster your opponent controls; change its battle position.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	--Once per turn: You can target 1 of your banished "HERO" monsters; shuffle it into the Deck, and if you do, this card gains ATK equal to its Level x 100 until the end of the turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetFunctions(nil,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_card_types={TYPE_NORMAL}
s.listed_series={SET_EVIL_HERO,SET_ELEMENTAL_HERO}
s.material_setcode={SET_EVIL_HERO,SET_ELEMENTAL_HERO}

--E0
function s.valcheck(e,c)
	local eff=e:GetLabelObject()
	local g=c:GetMaterial()
	if g and g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		eff:SetLabel(1)
	else
		eff:SetLabel(0)
	end
end
--E1
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFusionSummoned() and e:GetLabel()==1
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end

--E2
function s.tdfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_HERO) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	local tc=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetCardOperationInfo(tc,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.ShuffleIntoDeck(tc)>0 then
		local c=e:GetHandler()
		local lv=tc:GetLevel()
		if c:IsRelateToChain() and c:IsFaceup() and lv>0 then
			c:UpdateATK(lv*100,RESET_PHASE|PHASE_END,c)
		end
	end
end