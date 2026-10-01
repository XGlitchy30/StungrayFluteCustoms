--[[
Acquaspecchio Infrangibile
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When a card or effect is activated that targets a "Gishki" Ritual Monster(s) you control: Send 1 "Gishki" Ritual Monster from your Deck to the GY, and if you do, negate the activation.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(s.negcon,nil,s.negtg,s.negop)
	c:RegisterEffect(e1)
	--[[When a "Gishki" monster effect is activated: You can banish this card from your GY; place 1 "Gishki" Ritual Monster from your GY on the top of the Deck, except a monster sent there this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,Cost.SelfBanish,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GISHKI}
s.listed_card_types={TYPE_RITUAL|TYPE_MONSTER}

--E1
function s.negcfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(SET_GISHKI) and c:IsRitualMonster()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.negcfilter,1,nil,tp) and Chain.IsNegatable(ev)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_GISHKI) and c:IsRitualMonster() and c:IsAbleToGrave()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGraveAndCheck(g) then
		Duel.NegateActivation(ev)
	end
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsCardType(TYPE_MONSTER) and re:IsCardSetcode(SET_GISHKI)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_GISHKI) and c:IsRitualMonster() and c:IsAbleToDeck()
		and (c:GetTurnID()~=Duel.GetTurnCount() or c:IsReason(REASON_RETURN))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.PlaceOnTopOfDeck(g,tp)
	end
end