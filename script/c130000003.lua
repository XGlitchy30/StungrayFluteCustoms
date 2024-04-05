--[[
Regressed Ritual Art
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[This card can be used to Ritual Summon any 1 non-Effect Ritual Monster. You must also send Normal Monsters from your Deck to the GY whose total Levels equal the Level of that Ritual Monster.]]
	local e1=Ritual.CreateProc(
		{handler=c,
		lvtype=RITPROC_EQUAL,
		desc=aux.Stringid(id,0),
		filter=s.filter,
		extrafil=s.extrafil,
		extratg=s.extratg,
		extraop=s.extraop,
		matfilter=s.forcedgroup}
	)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return not c:IsType(TYPE_EFFECT)
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroup(tp,LOCATION_DECK,0)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	return Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end