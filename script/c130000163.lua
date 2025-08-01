--[[
Kiki, Flamespear's Familiar
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is in your hand: You can send 1 Spellcaster from your Deck to your GY, and if you do, you cannot activate monster effects for the rest of this turn, except Spellcaster monster effects, also banish this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.tgtg,
		s.tgop
	)
	c:RegisterEffect(e1)
	--[[You can shuffle this banished card into your Deck; Fusion Summon 1 Spellcaster Fusion Monster from your Extra Deck, using monsters from your hand or field. If you control "Valerie the Flamespear", you can also use monsters in your GY as material by shuffling them into the Main Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:SHOPT()
	e2:SetCost(Cost.SelfToDeck)
	e2:SetTarget(Fusion.SummonEffTG{
		fusfilter	= s.fusfilter,
		extrafil 	= s.fextra,
		extratg 	= s.extratg
		}
	)
	e2:SetOperation(Fusion.SummonEffOP{
		fusfilter	= s.fusfilter,
		extrafil 	= s.fextra,
		extraop 	= s.extraop
		}
	)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_VALERIE_THE_FLAMESPEAR}

--E1
function s.tgfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToRemove()
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,1)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclim)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if c:IsRelateToChain() then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
function s.aclim(e,re)
	return re:IsMonsterEffect() and not re:GetHandler():IsRace(RACE_SPELLCASTER)
end

--E2
function s.fusfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
function s.fextrafilter(c)
	return c:IsMonster() and not c:IsOriginalType(TYPE_EXTRA) and c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)
end
function s.fextra(e,tp,mg)
	local sg=Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_GRAVE,0,nil)
	if Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_VALERIE_THE_FLAMESPEAR),tp,LOCATION_ONFIELD,0,1,nil) and #sg>0 then
		return sg
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.fextrafilter,nil)
	if #rg>0 then
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:Sub(rg)
	end
end