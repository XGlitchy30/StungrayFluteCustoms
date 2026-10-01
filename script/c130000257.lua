--[[
Cantatrice Gishki
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_disclosure.lua")
function s.initial_effect(c)
	--[[If this card is sent to the GY by a "Gishki" card: You can target 1 Ritual Monster or Ritual Spell in your GY; place it on the top of the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e1)
	--[[If a card(s) is revealed from a player's hand or top of their Deck by a "Gishki" card while this card is in the GY (except during the Damage Step): You can Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DISCLOSE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	xgl.EnableDisclosureWatcher()
end
s.listed_series={SET_GISHKI}
s.listed_card_types={TYPE_RITUAL}

--E1
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	if re then
		return re:IsCardSetcode(SET_GISHKI)
	else
		local rc=e:GetHandler():GetReasonCard()
		return rc and rc:IsSetCard(SET_GISHKI)
	end
end
function s.tdfilter(c)
	return (c:IsRitualMonster() or c:IsRitualSpell()) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.PlaceOnTopOfDeck(tc,tp)
	end
end

--E2
function s.decktopcheck(g,p)
	local dg=g:Filter(aux.PLChk,nil,p,LOCATION_DECK)
	return #dg>0 and #(dg-Duel.GetDecktopGroup(p,#dg))==0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if ev&DISCLOSURE_REVEAL==0 or not re then return false end
	return re:IsCardSetcode(SET_GISHKI)
		and (eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) or s.decktopcheck(eg,0) or s.decktopcheck(eg,1))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end