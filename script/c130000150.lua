--[[
Ancestagon Duke Silveraptor
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DINOSAUR),2,2,nil,nil,Xyz.InfiniteMats)
	--[[During your Main Phase: You can add 1 Level 8 or higher "Ancestagon" Pendulum Monster you control to your Extra Deck, face-up, and if you do, you can Special Summon 1 Level 8 or higher "Ancestagon" monster from your hand or Deck with a different original name from that added monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e1)
	--[[If you would Tribute a monster(s) to activate the effect a Level 8 or higher "Ancestagon" monster that Special Summons it, you can also use appropriate materials from this card to pay that cost, by adding them to your Extra Deck, face-up, instead of Tributing them.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(CARD_ANCESTAGON_DUKE_SILVERAPTOR)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	--If this card is Xyz Summoned: You can add 1 "Ancestagon" Field Spell from your Deck or GY to your hand.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	--e3:SetCondition(xgl.XyzSummonedCond)
	e3:SetSearchFunctions(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	c:RegisterEffect(e3)
	--[[When a card your opponent controls activates its effect (Quick Effect): You can Tribute 1 "Ancestagon" card you control; banish that card.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		s.rmcon,
		xgl.TributeCost(xgl.ArchetypeFilter(SET_ANCESTAGON),1,1,LOCATION_SZONE,false,nil,nil),
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e4)
	--[[If this card is Tributed or destroyed by battle or card effect: You can place this card in your Pendulum Zone.]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(id,3)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:HOPT()
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_RELEASE)
	e6:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	c:RegisterEffect(e6)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.tefilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_ANCESTAGON) and c:IsLevelAbove(8) and c:IsAbleToExtraFaceupAsCost(e,tp)
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tefilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if Duel.Highlight(g) then
		local tc=g:GetFirst()
		local codes={tc:GetOriginalCodeRule()}
		if Duel.SendtoExtraP(tc,tp,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) and tc:IsControler(tp) and tc:IsFaceup() and Duel.GetMZoneCount(tp)>0
		and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,table.unpack(codes)) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,table.unpack(codes)):GetFirst()
			if sc then
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spfilter(c,e,tp,...)
	return c:IsLevelAbove(8) and c:IsSetCard(SET_ANCESTAGON) and not c:IsOriginalCodeRule(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--E3
function s.thfilter(c)
	return c:IsFieldSpell() and c:IsSetCard(SET_ANCESTAGON)
end

--E4
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local p,loct=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return loct&LOCATION_ONFIELD>0 and p==1-tp
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsRelateToChain(ev) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToChain() then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end

--E5
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end