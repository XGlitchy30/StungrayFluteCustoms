--[[
Mx. Music
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Cannot attack unless it has activated its effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.atcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	--[[If this card is Summoned: You can apply 1 of these effects based on the Chain Link number of this effect.
	● 1: Change this card to Defense Position.
	● 2: This card gains 1000 ATK.
	● 3+: Banish this card, and if you do, Special Summon it and 1 "Mx. Music" from your Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e3)
	e3:SpecialSummonEventClone(c)
	e3:FlipSummonEventClone(c)
end
s.listed_names={id}

--E1
function s.atcon(e)
	return not e:GetHandler():HasFlagEffect(id)
end
--E2
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc==e:GetHandler() then
		rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
	end
end

--E3
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cl=Duel.GetCurrentChain()
	if chk==0 then
		if cl==0 then
			return not c:IsDefensePos() and c:IsCanChangePosition()
		elseif cl==1 then
			return c:IsCanChangeATK(1000)
		elseif cl>=2 then
			return c:IsAbleToRemove() and not c:IsHasEffect(CARD_MX_MUSIC) and Duel.GetMZoneCount(tp,c)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
				and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
				and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),{c:GetOriginalSetCard()},c:GetOriginalType(),c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalRatingAuto(),c:GetOriginalRace(),c:GetOriginalAttribute())
		end
	end
	if cl==1 then
		e:SetCategory(CATEGORY_POSITION)
		Duel.SetCardOperationInfo(c,CATEGORY_POSITION)
	elseif cl==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,LOCATION_MZONE,1000)
	elseif cl>=3 then
		e:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
		Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp==c:GetControler() and tp or PLAYER_EITHER,LOCATION_DECK|LOCATION_REMOVED)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local cl=Duel.GetCurrentChain()
	if cl==1 then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	elseif cl==2 then
		if c:IsCanChangeATK(1000) then
			c:UpdateATK(1000,0,c)
		end
	elseif cl>=3 then
		if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsBanished(POS_FACEUP) and Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
			if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
				local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end