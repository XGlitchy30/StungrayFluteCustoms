--[[
Hieratic Dragon of Heka
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can Tribute 1 monster from your hand, and if you do, add 1 "Hieratic" monster from your Deck to your hand, or, if you Tributed a "Hieratic"
	Normal Monster with this effect, you can add 1 "Hieratic" Spell/Trap instead. You cannot Special Summon monsters the turn you activate this effect, except LIGHT Dragon monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RELEASE|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.SSRestrictionCost(aux.FilterBoolFunction(Card.IsAttributeRace,ATTRIBUTE_LIGHT,RACE_DRAGON),true,nil,id,nil,1),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is Tributed: Special Summon 1 Dragon Normal Monster from your hand, Deck, or GY, but make its ATK/DEF 0.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RELEASE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HIERATIC}

function s.rlfilter(c,tp)
	if not c:IsMonsterType() or not c:IsReleasableByEffect() then return false end
	if not tp then return true end
	local isNormalHieratic=c:IsType(TYPE_NORMAL) and c:IsSetCard(SET_HIERATIC)
	return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil,isNormalHieratic)
end
function s.thfilter(c,isNormalHieratic)
	return c:IsSetCard(SET_HIERATIC) and c:IsAbleToHand() and (c:IsMonsterType() or (isNormalHieratic and c:IsSpellTrap()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rg=Duel.GetReleaseGroup(tp,true,false,REASON_EFFECT):Filter(s.rlfilter,nil,tp)
		return #rg>0
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local rg0=Duel.GetReleaseGroup(tp,true,false,REASON_EFFECT)
	if #rg0==0 then return end
	local rg=rg0:Filter(s.rlfilter,nil,tp)
	if #rg==0 then
		rg=rg0:Filter(s.rlfilter,nil)
	end
	if #rg==0 then return end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local rsg=rg:Select(tp,1,1,nil)
	if #rsg>0 then
		Duel.ConfirmCards(1-tp,rsg)
		local rc=rsg:GetFirst()
		local isNormalHieratic=rc:IsType(TYPE_NORMAL) and rc:IsSetCard(SET_HIERATIC)
		if Duel.Release(rsg,REASON_EFFECT)>0 then
			local enableSpellsTraps=isNormalHieratic and xgl.BecauseOfThisEffect(e)(rc) and rc:IsReason(REASON_RELEASE)
			local tg=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,enableSpellsTraps)
			if #tg>0 then
				Duel.Search(tg)
			end
		end
	end
end

--E3
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end