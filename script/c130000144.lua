--[[
Ancestagon High Omnirex
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
if not Ancestagon then
	Ancestagon = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[If an "Ancestagon" monster(s) is Tributed: Draw 1 card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(0,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT(nil,2)
	e1:SetCondition(xgl.EventGroupCond(s.cfilter))
	e1:SetDrawFunctions(0,1,true)
	c:RegisterEffect(e1)
	--[[If this card is face-up in your Extra Deck: You can Tribute 2 "Ancestagon" monsters; Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCost(Ancestagon.DukeSilveraptorTributeCost)
	e2:SetSpecialSummonSelfFunctions(true)
	c:RegisterEffect(e2)
	--[[Once per turn (Quick Effect): You can banish 1 "Ancestagon" monster from your hand or face-up Extra Deck; destroy 1 card your opponent controls.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetRelevantTimings()
	e3:SetCost(xgl.BanishCost(s.rmcfilter,LOCATION_HAND|LOCATION_EXTRA))
	e3:SetSendtoFunctions(0,false,aux.TRUE,0,LOCATION_ONFIELD,1,1,nil)
	c:RegisterEffect(e3)
	--[[When a card(s) you control is Tributed (except during the Damage Step): You can place 1 of your banished cards on the top or bottom of your Deck]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,3)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e4:SetCode(EVENT_RELEASE)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		xgl.EventGroupCond(s.cfilter2),
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.cfilter(c)
	local current_state = not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonsterType() and c:IsSetCard(SET_ANCESTAGON)
	local previous_state = c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(SET_ANCESTAGON)
	return current_state or previous_state
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ANCESTAGON,SET_ANCESTAGON,TYPES_TOKEN,0,0,2,RACE_DINOSAUR,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local token=Duel.CreateToken(tp,TOKEN_ANCESTAGON)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,3)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(s.matlimit)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.matlimit(e,sc,sumtype,tp)
	if sc:IsSetCard(SET_ANCESTAGON) then return false end
	local not_allowed={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK}
	local sum=(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ)&sumtype
	for _,val in pairs(not_allowed) do
		if sum==val then return true end
	end
	return false
end

--E3
function s.rmcfilter(c)
	return c:IsFaceupEx() and c:IsMonsterType() and c:IsSetCard(SET_ANCESTAGON)
end

--E4
function s.cfilter2(c,_,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
	if Duel.Highlight(g) then
		local seq = Duel.SelectOption(tp,STRING_DECKTOP,STRING_DECKBOTTOM)==0 and SEQ_DECKTOP or SEQ_DECKBOTTOM
		Duel.SendtoDeck(g,nil,seq,REASON_EFFECT)
	end
end