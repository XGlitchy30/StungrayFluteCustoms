--[[
Wiccink Evocation
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Discard 1 card; Special Summon 1 "Wiccink Token" (Spellcaster/EARTH/Level 2/ATK 300/DEF 300), but it cannot be Tributed or used as material for a Synchro or Link Summon]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(nil,xgl.DiscardCost(nil,1,1,true),s.target,s.activate)
	c:RegisterEffect(e1)
	--[[During your opponent's End Phase: You can banish this card from your GY; destroy 1 "Wiccink Token" you control,
	and if you do, Special Summon 1 "Wiccink" monster from your Deck or Extra Deck, ignoring its Summoning conditions]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(xgl.TurnPlayerCond(1),aux.bfgcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_WICCINK,SET_WICCINK,TYPES_TOKEN,300,300,2,RACE_SPELLCASTER,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s.target(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_WICCINK)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			token:CannotBeTributed(1,nil,true,c)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(130000043,2)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end

--E2
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(TOKEN_WICCINK) and (not e or Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,c,c,e,tp))
end
function s.spfilter(c,tk,e,tp)
	return c:IsMonsterType() and c:IsSetCard(SET_WICCINK) and Duel.GetMZoneCountFromLocation(tp,tp,tk,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.desfilter,tp,LOCATION_ONFIELD,0,nil,e,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.ForcedSelect(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local spg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,nil,e,tp)
			if #spg>0 then
				Duel.SpecialSummon(spg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end