--[[
Miracolo Cristallo
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Fusion Summon 1 "Ultimate Crystal" Fusion Monster from your Extra Deck, using Monster Cards from your hand or field as Fusion Materials. If your opponent controls a monster, you can also banish "Crystal Beast" monsters from your GY as material.
	local e1=Fusion.CreateSummonEff({
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ULTIMATE_CRYSTAL),
		extrafil=s.fextra,
		extraop=s.extraop,
		extratg=s.extratg
	})
	e1:SetDescription(id,0)
	e1:SetCategory(e1:GetCategory()|CATEGORY_REMOVE)
	e1:HOPT()
	c:RegisterEffect(e1)
	--If you take damage and you now have 1000 or less LP: You can add this card from your GY to your hand, and if you do, send 1 "Crystal Beast" card from your Deck to the GY.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ULTIMATE_CRYSTAL,SET_CRYSTAL_BEAST}

--E1
function s.extrafieldfilter(c)
	return c:IsMonsterCard() and c:IsAbleToGrave(REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
end
function s.gymatfilter(c,fc,p)
	return c:IsMonster() and c:IsSetCard(SET_CRYSTAL_BEAST,fc,SUMMON_TYPE_FUSION,p) and c:IsAbleToRemove(p,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.extrafieldfilter,tp,LOCATION_SZONE,0,nil)
	if Duel.GetMonstersCount(1-tp)>0 then
		local gy=Duel.GetMatchingGroup(s.gymatfilter,tp,LOCATION_GRAVE,0,nil,e:GetHandler(),tp)
		if #gy>0 then
			eg:Merge(gy)
		end
	end
	return eg
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.tgfilter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLP(tp)<=1000 and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SearchAndCheck(c) then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end