--[[
Queltz Dagger
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsAttributeRace,ATTRIBUTE_FIRE,RACE_THUNDER)
	--[[This card can be used to Ritual Summon any FIRE Thunder Ritual Monster. You must also banish cards from the top of your Deck, face-down, equal to the Level of the Ritual Monster you Ritual
	Summon.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(
		nil,
		xgl.SSRestrictionCost(nil,true,nil,id,LOCATION_DECK,1),
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can activate 1 of these effects.
	● Target 1 FIRE Thunder Ritual Monster in your GY; banish this card from your GY, face-down, and if you do, add that target to your hand.
	● Banish 1 other card from your GY, face-down; add this card from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,xgl.LabelCost,s.gytg,s.gyop)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c,e,tp,lp)
	if not c:IsRitualMonster() or not c:IsAttributeRace(ATTRIBUTE_FIRE,RACE_THUNDER) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then
		return false
	end
	local lv=c:GetLevel()
	local g=Duel.GetDecktopGroup(tp,lv)
	return g:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)==lv
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetDeckCount(tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetDeckCount(tp)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		local g=Duel.GetDecktopGroup(tp,tc:GetLevel())
		Duel.DisableShuffleCheck()
		if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)==#g then
			tc:SetMaterial(nil)
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

--E2
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsAttributeRace(ATTRIBUTE_FIRE,RACE_THUNDER) and c:IsAbleToHand()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.thfilter(chkc)
	end
	local b1=c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExists(true,s.thfilter,tp,LOCATION_GRAVE,0,1,c)
	local b2=e:GetLabel()==1 and c:IsAbleToHand() and Duel.IsExists(false,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,c,POS_FACEDOWN)
	e:SetLabel(0)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,3,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_REMOVE|CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_ATOHAND,true,tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
		Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
		Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	elseif opt==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,c,POS_FACEDOWN)
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
		Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	end
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local opt=Duel.GetTargetParam()
	if opt==0 then
		if Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)>0 then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToChain() and s.thfilter(tc) then
				Duel.Search(tc)
			end
		end
	elseif opt==1 then
		Duel.Search(c)
	end
end