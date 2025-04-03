--[[
B.E.S. Armored Core
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control no non-"B.E.S." monsters, you can: Immediately after this effect resolves, Normal Summon this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		aux.NOT(xgl.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1)),
		nil,
		s.nstg,
		s.nsop
	)
	c:RegisterEffect(e1)
	--[[This card can be treated as 2 Tributes for the Tribute Summon of a "B.E.S." monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(aux.TargetBoolFunction(Card.IsSetCard,SET_BES))
	c:RegisterEffect(e2)
	--[[A "B.E.S." monster that was Normal Summoned by Tributing this card gains this effect.
	● If this card is Normal Summoned: Place 1 counter on this card, and if you do, add 1 "B.E.F. Zelos Force" from your Deck to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BEF_ZELOS_FORCE}
s.listed_series={SET_BES}
s.counter_place_list={COUNTER_BES}

--E1
function s.cfilter(c)
	return c:IsFacedown() or c:GetSetCard()~=SET_BES
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsSummonable(true,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Summon(tp,c,true,nil)
	end
end

--E3
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r&REASON_SUMMON>0 and c:IsReason(REASON_RELEASE) and rc and rc:IsSetCard(SET_BES)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(id,2)
	e1:SetCategory(CATEGORY_COUNTER|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetFunctions(
		nil,
		nil,
		s.thtg,
		s.thop
	)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	aux.GainEffectType(rc,c)
end

--GRANTED EFFECT
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_BES)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_BES,1) and c:AddCounter(COUNTER_BES,1) then
		local tc=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
		if tc then
			Duel.Search(tc)
		end
	end
end
function s.thfilter(c)
	return c:IsCode(CARD_BEF_ZELOS_FORCE) and c:IsAbleToHand()
end