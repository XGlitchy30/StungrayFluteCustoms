--[[
Chloe, The Mischief Punk
Card Author: BraveFrontier
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If a Gemini monster(s) is Summoned to your field (except during the Damage Step): You can Special Summon this card from your hand, and if you do, immediately after this effect resolves,
	you can Normal Summon 1 Gemini monster]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
	--[[If this in your GY: You can target 1 Gemini monster you control; banish this card, and if you do, it becomes an Effect Monster and gains its effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(nil,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_GEMINI}

--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_GEMINI) and c:IsControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,STRING_ASK_SUMMON) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sc,true,nil) 
		end
	end
end
function s.sumfilter(c)
	return c:IsType(TYPE_GEMINI) and c:IsSummonable(true,nil)
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_GEMINI) and not c:IsGeminiStatus()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and s.filter(tc) then
			tc:EnableGeminiStatus()
		end
	end
end