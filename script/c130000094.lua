--[[
Nova Queltz
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[When your opponent activates a monster effect on the field (Quick Effect): You can target 7 banished cards; shuffle all 7 into the Deck, and if you do, negate the effects of that opponent's
	monster, also, during the End Phase, if it is in the same column, banish it, face-down]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e1)
	--[[During the End Phase: Banish the top 5 cards of each player's Deck, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetFunctions(nil,nil,s.rmtg2,s.rmop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}

--E1
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	local rc=re:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,7,nil) and rc:IsRelateToChain(ev)
			and rc:IsControler(1-tp) and rc:IsNegatableMonster()
	end
	local tg=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,7,7,nil)
	rc:CreateEffectRelation(e)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(rc,CATEGORY_DISABLE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==7 and Duel.ShuffleIntoDeck(g)==7 then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(e) and rc:IsRelateToChain(ev) and rc:IsControler(1-tp) and rc:IsFaceup() and rc:IsCanBeDisabledByEffect(e) then
			local c=e:GetHandler()
			rc:NegateEffects(c)
			if rc:IsRelateToEffect(e) then
				local p,seq=rc:GetControler(),rc:GetSequence()
				xgl.DelayedOperation(rc,PHASE_END,id,e,tp,s.delayedop,s.delayedcon(p,seq),nil,RESET_PHASE|PHASE_END,1,aux.Stringid(id,2),aux.Stringid(id,3))
			end
		end
	end
end
function s.delayedcon(p,seq)
	return	function(g,e,tp,eg,ep,ev,re,r,rp,turncount)
				local c=g:GetFirst() 
				return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsColumn(seq,p,LOCATION_MZONE)
			end
end
function s.delayedop(g,e,tp,eg,ep,ev,re,r,rp)
	local c=g:GetFirst()
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
end

--E2
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,PLAYER_ALL,LOCATION_DECK)
end

function s.rmop2(c,e,tp)
	Duel.DisableShuffleCheck()
	local g=Duel.GetDecktopGroup(0,5)+Duel.GetDecktopGroup(1,5)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end