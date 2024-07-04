--[[
Sphinx of Black Quartz, Judge My Vow
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--[[Once per turn, if a Beast monster(s) is sent to the GY: Choose 2 vertically adjacent zones; excavate cards from the top of your Deck
	until you excavate a number of Beast monsters equal to the number of Beast Monster Cards in the chosen zones, and if you do, send those monster(s) to the GY,
	also shuffle the rest into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(s.tgcon,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e1)
end

function s.CheckExtra(seq,ismzone,s)
	return not mzone or seq<5 or seq~=s
end
function s.GetVerticalAdjacentZones(tp,z,refp,refloc,seq)
	local zones=0
	local isMZone,isSZone = refloc==LOCATION_MZONE,refloc==LOCATION_SZONE
	local exchk=isMZone and (seq==5 or seq==6)
	if exchk then
		seq = seq==5 and 1 or 3
	end
	
	--Get Monster Zones
	if isSZone or exchk then
		local newzones = exchk and (1<<seq)|(1<<(16+(4-seq))) or refp==tp and 1<<seq or 1<<(16+(4-seq))
		zones = zones | newzones
	end
	if isMZone and not exchk and Duel.GetDuelType()&DUEL_EMZONE>0 then
		if seq==1 and s.CheckExtra(seq,isMZone,5) then
			zones = zones | ( (1<<5) | (1<<(16+6)) )
		elseif seq==3 and s.CheckExtra(seq,isMZone,6) then
			zones = zones | ( (1<<6) | (1<<(16+5)) )
		end
	end
	
	--Get Spell&Trap Zones
	if isMZone and not exchk then
		local newzones = refp==tp and 1<<(8+seq) or 1<<(16+8+(4-seq))
		zones = zones | newzones
	end
	
	return zones
end

--E1
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsRace,1,nil,RACE_BEAST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsRace(RACE_BEAST)
end
function s.excfilter(c)
	return c:IsMonster() and c:IsRace(RACE_BEAST)
end
function s.zonefilter(c,zones,tp)
	return s.filter(c) and aux.IsZone(c,zones,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE|LOCATION_SZONE,LOCATION_MZONE|LOCATION_SZONE,nil)
	local z1,z2=0,0
	if #g>0 then
		local tc1=g:Select(tp,1,1,nil):GetFirst()
		z1=tc1:GetZone(tp)
		local p,loc,seq=tc1:GetControler(),tc1:GetLocation(),tc1:GetSequence()
		if p==1-tp then
			seq=4-seq
		end
		local available_zones=s.GetVerticalAdjacentZones(tp,z1,p,loc,seq)
		z2=Duel.SelectFieldZone(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xffffffff&~available_zones)
	else
		z1=Duel.SelectFieldZone(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0x20002000)
		local p,loc,seq
		local log2=math.log(2)
		if z1&0xffffff00==0 then
			p,loc,seq=tp,LOCATION_MZONE,math.floor(math.log(z1)/log2)
		elseif z1&0xffff00ff==0 then
			p,loc,seq=tp,LOCATION_SZONE,math.floor(math.log(z1>>8)/log2)
		elseif z1&0xff00ffff==0 then
			p,loc,seq=1-tp,LOCATION_MZONE,4-math.floor(math.log(z1>>16)/log2)
		elseif z1&0xffffff==0 then
			p,loc,seq=1-tp,LOCATION_SZONE,4-math.floor(math.log(z1>>24)/log2)
		end
		Debug.Message(seq)
		local available_zones=s.GetVerticalAdjacentZones(tp,z1,p,loc,seq)
		z2=Duel.SelectFieldZone(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xffffffff&~available_zones)
	end
	local zones=z1|z2
	Duel.Hint(HINT_ZONE,0,zones)
	Duel.SetTargetParam(zones)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local zones=Duel.GetTargetParam()
	local ct=Duel.GetMatchingGroupCount(s.zonefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,zones,tp)
	if ct==0 then return end
	local g=Duel.Group(s.excfilter,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local seq1,seq2=-1,-1
	local tc1,tc2=nil,nil
	for tc in g:Iter() do
		local newseq=tc:GetSequence()
		if newseq>seq then
			seq1,seq2=newseq,seq1
			tc1,tc2=tc,tc1
			seq=ct==2 and math.min(seq1,seq2) or newseq
		end
	end
	seq=seq==-1 and 0 or seq
	Duel.ConfirmDecktop(tp,dcount-seq)
	if tc1 then
		local tg=Group.FromCards(tc1)
		if ct==2 and tc2 then tg:AddCard(tc2) end
		tg=tg:Match(Card.IsAbleToGrave,nil)
		if #tg>0 then
			Duel.DisableShuffleCheck()
			Duel.SendtoGrave(tg,REASON_EFFECT|REASON_EXCAVATE)
		end
	end
	Duel.ShuffleDeck(tp)
end