--[[
Falling Demonisu
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
function s.initial_effect(c)
	c:AddCardActivationResolutionCheck()
	local e0=c:Activation()
	e0:SetHintTiming(TIMING_TOHAND,TIMING_BATTLE_START)
	--[[If a monster(s) returns to your hand (except during the Damage Step): You can draw 1 card, then discard 1 card.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_TO_HAND,s.cfilter,id,nil,nil,nil,nil,nil,nil,nil,true)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:HOPT()
	e1:SetFunctions(
		aux.ContTrapMergedEventCheckCond,
		nil,
		s.drawtg,
		s.drawop
	)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1x:SetCode(EVENT_TO_HAND)
	e1x:SetCondition(s.drawcon)
	c:RegisterEffect(e1x)
	--[[At the start of your opponent's Battle Phase: You can target 1 "Demonisu" monster you control; destroy it, and if you do, immediately after this effect resolves, Normal Summon 1 "Demonisu"
	monster with a different name from your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetFunctions(
		xgl.TurnPlayerCond(1),
		nil,
		s.nstg,
		s.nsop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DEMONISU}

--E1
function s.cfilter(c,_,tp)
	return c:IsMonster() and c:IsControler(tp) and not c:IsPreviousLocation(LOCATION_DECK)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsHasEffect(EFFECT_CARD_HAS_RESOLVED) and eg:IsExists(s.cfilter,1,nil,nil,tp)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDiscardHand(tp) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end

--E2
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_DEMONISU) and (not tp or Duel.IsExists(false,s.nsfilter,tp,LOCATION_HAND,0,1,c,Duel.GetMZoneCount(tp,c),c:GetCode()))
end
function s.nsfilter(c,ft,...)
	if not (c:IsSetCard(SET_DEMONISU) and not c:IsCode(...)) then return false end
	if c:IsSummonable(true,nil) then
		return true
	elseif ft and ft==1 then
		local e=Effect.CreateEffect(c)
		e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetCode(EFFECT_SUMMON_PROC)
		e:SetRange(LOCATION_HAND)
		e:SetCondition(s.nscon_fix)
		c:RegisterEffect(e)
		local res=c:IsSummonable(true,e)
		e:Reset()
		return res
	end
end
function s.nscon_fix(e,c)
	if c==nil then return true end
	return true
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local codes={tc:GetCode()}
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local nc=Duel.Select(HINTMSG_SUMMON,false,tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil,nil,table.unpack(codes)):GetFirst()
			if nc then
				Duel.Summon(tp,nc,true,nil)
			end
		end
	end
end