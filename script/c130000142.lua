--[[
Ancestagon Tyranno-Legend
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
	--[[While this card is in the Pendulum Zone, you can negate the activation of an opponent's activated card effect that would destroy or banish a card(s) on the field,
	then destroy this card and place 1 "Ancestagon" Spell/Trap from your GY on the top of your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetFunctions(
		s.negcon,
		nil,
		nil,
		s.negop
	)
	c:RegisterEffect(e1)
	--[[If this card is face-up in your Extra Deck: You can Tribute 2 "Ancestagon" monsters you control; Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCost(Ancestagon.DukeSilveraptorTributeCost)
	e2:SetSpecialSummonSelfFunctions(true)
	c:RegisterEffect(e2)
	--[[Monsters destroyed by battle with this card cannot activate their effects in the GY until the end of this turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--[[This card can attack a number of times each Battle Phase, up to the number of face-up "Ancestagon" cards in your Monster Zones and Pendulum Zones.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(s.raval)
	c:RegisterEffect(e4)
	--[[This card gains 50 ATK for every "Ancestagon" monster in your face-up Extra Deck and on your field.]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	--[[If this card destroys a monster by battle: You can target 1 card in the same column as that destroyed monster; destroy it.]]
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(id,3)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetCustomCategory(0,CATEGORY_FLAG_ANCESTAGON_PLASMATAIL)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_BATTLE_DESTROYING)
	e6:HOPT(nil,2)
	e6:SetFunctions(aux.bdcon,nil,s.destg,s.desop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.tdfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_ANCESTAGON) and c:IsAbleToDeck()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (not Duel.PlayerHasFlagEffect(tp,id) and rp==1-tp and Duel.IsChainNegatable(ev) and Duel.IsExists(false,aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,1,nil)) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE) and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex1,tg1,ct1,p1,loc1=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex1 then
		if tg1==nil and p1~=PLAYER_NONE then
			loc1 = loc1~=0 and loc1 or LOCATION_ONFIELD
			if p==PLAYER_ALL or p==PLAYER_EITHER then
				tg1=Duel.GetFieldGroup(0,loc1,loc1)
			else
				tg1=Duel.GetFieldGroup(p1,loc1,0)
			end
		end
		if tg1 and ct1+tg1:FilterCount(Card.IsOnField,nil)-#tg1>0 then
			return true
		end
	end
	
	local ex2,tg2,ct2,p2,loc2=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex2 then
		if tg2==nil and p2~=PLAYER_NONE and loc2~=0 then
			loc2 = loc2~=0 and loc2 or LOCATION_ONFIELD
			if p==PLAYER_ALL or p==PLAYER_EITHER then
				tg2=Duel.GetFieldGroup(0,loc2,loc2)
			else
				tg2=Duel.GetFieldGroup(p2,loc2,0)
			end
			tg1:Match(Card.IsAbleToRemove,nil)
		end
		if tg2 and ct2+tg2:FilterCount(Card.IsOnField,nil)-#tg2>0 then
			return true
		end
	end
	
	return false
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(tp,id,RESETS_STANDARD_PHASE_END,0,1)
		local c=e:GetHandler()
		if Duel.NegateActivation(ev) and c:IsDestructable(e) and Duel.IsExists(false,aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,1,nil) then
			Duel.BreakEffect()
			if Duel.Destroy(c,REASON_EFFECT)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
				if Duel.Highlight(g) then
					Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
				end
			end
		end
	end
end

--E3
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	local d=c:GetBattleTarget()
	if not d or not d:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(function(_e) return _e:GetHandler():IsMonster() end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
	d:RegisterEffect(e1)
end

--E4
function s.raval(e,c)
	local oc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ANCESTAGON),e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_PZONE,0,nil)
	return math.max(0,oc-1)
end

--E5
function s.atkfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_ANCESTAGON)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_EXTRA,0,nil)*50
end

--E6
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if (chkc or chk==0) and not bc then return false end
	local seq=bc:GetPreviousSequence()
	local g=Duel.GetColumnGroupFromSequence(bc:GetPreviousControler(),seq):Filter(xgl.PlasmatailFilter(tp),nil)
	if chkc then
		return chkc:IsOnField() and g:IsContains(chkc)
	end
	if chk==0 then
		return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	Duel.SetTargetCard(sg)
	Duel.SetCardOperationInfo(sg,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end