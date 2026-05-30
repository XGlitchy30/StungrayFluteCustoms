--[[
Tenders of Nature
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	--If this card is added to your hand, except by drawing it: You can Special Summon it.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e1:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e1)
	--If this card is Special Summoned: Gain 1000 LP.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	--Once per turn: You can declare 1 card name; excavate the top card of either player's Deck, then, if it is the declared card, this card gains 300 ATK. Also, place the excavated card on the top or bottom of the Deck.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end

--E2
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,v=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,v,REASON_EFFECT)
end

--E3
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDeckCount()>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,300)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct1,ct2=Duel.GetDeckCount(tp),Duel.GetDeckCount(1-tp)
	if ct1<=0 and ct2<=0 then return end
	local opt=xgl.Option(tp,id,3,ct1>0,ct2>0)
	if not opt then return end
	local p = opt==0 and tp or 1-tp
	Duel.ConfirmDecktop(p,1)
	local g=Duel.GetDecktopGroup(p,1)
	local tc=g:GetFirst()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	Duel.DisableShuffleCheck()
	if tc:IsCode(ac) and c:IsRelateToChain() and c:IsFaceup() then
		Duel.BreakEffect()
		c:UpdateATK(300,true)
	end
	local opt=Duel.SelectOption(tp,STRING_DECKTOP,STRING_DECKBOTTOM)
	if opt==1 then
		Duel.MoveToDeckBottom(tc)
	end
end