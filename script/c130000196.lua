--[[
Ancient Fairy Dragon - Resplendent
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Once per Chain, if your opponent Special Summons a monster(s) (except during the Damage Step)*: You can Special Summon 1 Level 4 or lower monster that mentions "Ancient Fairy Dragon" from your hand or GY with a name different from the monsters you control, and if you do, gain 1000 LP.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:OPC()
	e1:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[You can target 1 Field Spell on the field; destroy it, and if you do, gain 1000 LP, also, during the End Phase, its owner can add 1 Field Spell from their Deck to their hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_RECOVER|CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.destg,
		s.desop
	)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ANCIENT_FAIRY_DRAGON}

--E1
function s.cfilter(c,_,tp)
	return c:IsSummonPlayer(1-tp)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExists(false,aux.Faceup(Card.IsCode),tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end

--E2
function s.desfilter(c)
	return c:IsLocation(LOCATION_FZONE) or (c:IsFaceup() and c:IsFieldSpell())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tc:GetOwner(),LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.Recover(tp,1000,REASON_EFFECT)
		end
		xgl.DelayedOperation(nil,PHASE_END,id,e,tc:GetOwner(),s.thop,nil,nil,nil,nil,aux.Stringid(id,2))
	end
end
function s.thfilter(c)
	return c:IsFieldSpell() and c:IsAbleToHand()
end
function s.thop(g,e,tp,eg,ep,ev,re,r,rp,turncount)
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,1,1,nil)
			if #tg>0 then
				Duel.Search(tg)
			end
		end
	end
end