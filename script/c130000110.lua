--[[
Lunar Fire
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 Fusion Monster on the field; it gains 700 ATK, also gain 700 LP.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this Set card is sent from the field to the GY: You can target 1 Fusion Monster on the field; excavate cards from the top of your Deck equal to its Level, and if you do, equip 1 appropriate
	excavated Equip Spell to it, also shuffle the rest into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetFunctions(
		s.eqcon,
		nil,
		s.eqtg,
		s.eqop
	)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,700)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,700)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		tc:UpdateATK(700,true,{e:GetHandler(),true})
	end
	Duel.Recover(tp,700,REASON_EFFECT)
end

--E2
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.eqlimfilter(c,tp,ec,e)
	return Duel.IsPlayerCanEquipCardTo(tp,c,ec,e,LOCATION_DECK)
end
function s.excfilter(c,e,tp)
	if not s.filter(c) or not c:IsLevelAbove(1) then return false end
	local ct=c:GetLevel()
	local g=Duel.GetDecktopGroup(tp,ct)
	return #g>=ct and g:FilterCount(s.eqlimfilter,nil,tp,c,e)>0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.excfilter(chkc,e,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsInBackrow() then
			ft=ft-1
		end
		return ft>0 and Duel.IsExistingTarget(s.excfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.excfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsFaceup() then return end
	local ct=tc:GetLevel()
	if ct<=0 then return end
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	if #g>0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local eqc=g:FilterSelect(tp,Card.IsAppropriateEquipSpell,1,1,nil,tc,tp):GetFirst()
			if eqc then
				g:RemoveCard(eqc)
				Duel.DisableShuffleCheck(true)
				xgl.EquipToOtherCardAndRegisterLimit(e,tp,eqc,tc)
				Duel.DisableShuffleCheck(false)
			end
		end
		if #g>0 then
			Duel.ShuffleDeck(tp)
		end
	end
end