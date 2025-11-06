--[[
Flamespear Style - Immolator Lance
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When this card is activated: If you control a Level 7/Rank 5/Link 4 or higher Spellcaster monster, you can discard 1 card (or if you control "Valerie the Flamespear", you can activate this effect without discarding); destroy 1 Spell/Trap your opponent controls, and if your opponent controls a monster(s) in that same column, halve its ATK/DEF.]]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetCost(xgl.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If you activate a Spell/Trap Card in the same column as a Spellcaster monster you control (except during the Damage Step): You can add 1 Level 4 or lower Spellcaster monster from your face-up Extra Deck or GY to your hand. ]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(id,3)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:HOPT()
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_VALERIE_THE_FLAMESPEAR}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and (c:IsLevelAbove(7) or c:IsRankAbove(5) or c:IsLinkAbove(4))
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(CARD_VALERIE_THE_FLAMESPEAR)
end
function s.atkfilter(c,p)
	return c:IsFaceup() and c:IsControler(p) and c:IsLocation(LOCATION_MZONE)
end
function s.actchk(e,tp,eg,ep,ev,re,r,rp,b1,b2)
	return not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and (b1 or b2)
		and Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost=Cost.Discard()
	local isCostChecked=e:GetLabel()==1
	e:SetLabel(0)
	local b1=not isCostChecked or Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
	local b2=cost(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then
		return true
	end
	local param
	if s.actchk(e,tp,eg,ep,ev,re,r,rp,b1,b2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DESTROY|CATEGORIES_ATKDEF)
		param=1
		local opt
		if not isCostChecked then
			opt=0
		else
			opt = (b2 and not b1) and 1 or Duel.SelectEffect(tp,{b2,aux.Stringid(id,1)},{b1,aux.Stringid(id,2)})
		end
		if opt==1 then
			cost(e,tp,eg,ep,ev,re,r,rp,chk)
		end
		local g1=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		local g2=Group.CreateGroup()
		for tc in g1:Iter() do
			local cg=tc:GetColumnGroup():Filter(s.atkfilter,tc,1-tp)
			g2:Merge(cg)
		end
		Duel.SetPossibleCustomOperationInfo(0,CATEGORIES_ATKDEF,g2,math.max(1,#g2),1-tp,LOCATION_MZONE,-2,OPINFO_FLAG_HALVE)
	else
		e:SetCategory(0)
		param=0
	end
	Duel.SetTargetParam(param)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local param=Duel.GetTargetParam()
	if param==1 then
		local tc=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if tc then
			local cg=tc:GetColumnGroup():Filter(aux.FaceupFilter(Card.IsControler,1-tp),nil)
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				for cc in cg:Iter() do
					cc:HalveATKDEF(true,{e:GetHandler(),true})
				end
			end
		end
	end
end

--E2
function s.colfilter(c,seq,p)
	return c:IsColumn(seq,p,LOCATION_SZONE)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==tp and re:IsSpellTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
	local g=Duel.Group(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,nil)
	local p,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_SEQUENCE)
	return g:IsExists(s.colfilter,1,nil,seq,p)
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end