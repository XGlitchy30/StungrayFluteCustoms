Glitchy=Glitchy or {}
xgl=Glitchy

Duel.LoadScript("glitchylib_names.lua")

--Custom Categories
CATEGORY_ATTACH				=	0x1
CATEGORY_SET_SPELLTRAP		=	0x2
CATEGORY_PLACE_IN_PZONE		=	0x4

CATEGORY_FLAG_ANCESTAGON_PLASMATAIL = 0x1

CATEGORIES_SEARCH 			= 	CATEGORY_SEARCH|CATEGORY_TOHAND
CATEGORIES_ATKDEF 			= 	CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE
CATEGORIES_FUSION_SUMMON 	= 	CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON
CATEGORIES_TOKEN 			= 	CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN

--Custom Effects
EFFECT_CANNOT_MODIFY_ATTACK			= 	2001	--Players affected by this effect cannot change ATK of the specified cards. Needed for implementation of "Hidden Monastery of Necrovalley".
EFFECT_CANNOT_MODIFY_DEFENSE		=	2002	--Players affected by this effect cannot change DEF of the specified cards. Needed for implementation of "Hidden Monastery of Necrovalley"
EFFECT_SUMMONABLE_BY_OPPONENT		=	2003	--The card has an effect that allows the opponent to Normal Summon it (see Moblins' Packmate)
EFFECT_CANNOT_EQUIP_XGL				=	2004    --FUTUREPROOFING: Players affected by this effect cannot equip cards (specified by the value function) to the monsters specified by the target function
EFFECT_BECOME_EXTRA_LINKED			=	2005	--Cards affected by this effect are treated as being Extra Linked (see "Dian Keto the Disco Master"). Requires glitchymods_link to be loaded
EFFECT_UPDATE_LP					=	2006	--Effect that continuously updates the LP of a players, in a similar vein to a continuous ATK modifier for monsters (see "Dian Keto the Disco Master"). Requires glitchymods_lifepoints to be loaded
EFFECT_REMEMBER_XYZ_HOLDER			=	2007	--Effect that makes it possible for a card to retain memory of the most recent Xyz Monster that had it as material. Requires glitchymods_xyz to be loaded.
EFFECT_ASSUME_LOCATION				=	2008	--Cards affected by this effect are treated as if they were in the location specified as this effect's value. Requires glitchylib_redirect to be loaded
EFFECT_CANNOT_TO_EXTRA_P			=	2009	--[[Players affected by this effect cannot add Pendulum Cards to the Extra Deck, face-up. Can also be applied to a card instead of a player. Futureproofing for "Ancestagon Plasmatail" and similar cards]]
EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED	=	2010	--[[Players affected by this effect can use old MR3 rulings when Special Summoning monsters from the Extra Deck that meet the Target Function's requirements, and only to Summon them to the zones indicated by the Value Function. Requires glitchylib_MR3spsummon to be loaded]]

--Locations

--Rating types
RATING_LEVEL	 = 	0x1
RATING_RANK		=	0x2
RATING_LINK		=	0x4

--Stat types
STAT_ATTACK  = 0x1
STAT_DEFENSE = 0x2

--COIN RESULTS
COIN_HEADS = 1
COIN_TAILS = 0

--Effects
EFFECT_FLAG_EFFECT	=	0x10000000

--Properties
EFFECT_FLAG_DD = EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL
EFFECT_FLAG_DDD = EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL

--zone constants
EXTRA_MONSTER_ZONE=0x60

--resets
-- RESETS_REDIRECT_FIELD 			= 0x047e0000
-- RESETS_STANDARD_UNION 			= RESETS_STANDARD&(~(RESET_TOFIELD|RESET_LEAVE))
-- RESETS_STANDARD_TOFIELD 		= RESETS_STANDARD&(~(RESET_TOFIELD))
-- RESETS_STANDARD_EXC_GRAVE 		= RESETS_STANDARD&~(RESET_LEAVE|RESET_TOGRAVE)
RESETS_STANDARD_FACEDOWN 		= RESETS_STANDARD&~RESET_TURN_SET

--timings
RELEVANT_TIMINGS = TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_END_PHASE
RELEVANT_BATTLE_TIMINGS = TIMING_BATTLE_PHASE|TIMING_BATTLE_END|TIMING_ATTACK|TIMING_BATTLE_START|TIMING_BATTLE_STEP_END|TIMING_DAMAGE_STEP|TIMING_DAMAGE_CAL

--Operation Info Special Values
OPINFO_FLAG_HALVE	= 0x1
OPINFO_FLAG_DOUBLE 	= 0x2
OPINFO_FLAG_UNKNOWN = 0x4
OPINFO_FLAG_HIGHER 	= 0x8
OPINFO_FLAG_LOWER 	= 0x10
OPINFO_FLAG_FUNCTION= 0x20
OPINFO_FLAG_SET		= 0x40
OPINFO_FLAG_ORIGINAL= 0x80

--win
WIN_REASON_CUSTOM = 0xff

--constants aliases
TYPE_ST			= TYPE_SPELL|TYPE_TRAP
--TYPE_GEMINI		= TYPE_DUAL

RACES_BEASTS = RACE_BEAST|RACE_BEASTWARRIOR|RACE_WINGEDBEAST

LOCATION_ALL 		= LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
LOCATION_GB  		= LOCATION_GRAVE|LOCATION_REMOVED
LOCATIONS_PRIVATE 	= LOCATION_HAND|LOCATION_DECK

LINK_MARKER_ALL = 0x1ef

MAX_RATING = 14

RESET_TURN_SELF = RESET_SELF_TURN
RESET_TURN_OPPO = RESET_OPPO_TURN

--All-purpose
--[[Effect.Evaluate
Get the value of an effect. If the effect has a function as value, it calculates the value of the function
]]
function Effect.Evaluate(e,...)
	local extraargs={...}
	local val=e:GetValue()
	if not val then return false end
	if type(val)=="function" then
		local results={val(e,table.unpack(extraargs))}
		return table.unpack(results)
	else
		return val
	end
end
function Effect.EvaluateInteger(e,...)
	local extraargs={...}
	local val=e:GetValue()
	if not val then return 0 end
	if type(val)=="function" then
		local results={val(e,table.unpack(extraargs))}
		return table.unpack(results)
	else
		return val
	end
end

--Attach as material
function Card.IsCanBeAttachedTo(c,xyzc,e,p,r)
	p = p or (e and e:GetHandlerPlayer()) or xyzc:GetControler()
	r = r or REASON_EFFECT
	return not c:IsOriginalType(TYPE_TOKEN) and (c:IsOnField() or not c:IsForbidden()) and (xyzc:GetControler()==c:GetControler() or c:IsAbleToChangeControler()) --futureproofing
end
function Duel.Attach(c,xyz,transfer,e,r,rp)
	r = r or REASON_EFFECT
	rp = rp or (e and e:GetHandlerPlayer()) or xyz:GetControler()
	if type(c)=="Card" then
		if not c:IsCanBeAttachedTo(xyz,e,rp,r) or (e and r&REASON_EFFECT>0 and c:IsImmuneToEffect(e)) then
			return false
		end
		local og=c:GetOverlayGroup()
		if #og>0 then
			if transfer then
				Duel.Overlay(xyz,og)
			else
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		Duel.Overlay(xyz,Group.FromCards(c))
		return xyz:GetOverlayGroup():IsContains(c)
			
	elseif type(c)=="Group" then
		for tc in aux.Next(c) do
			local og=tc:GetOverlayGroup()
			if tc:IsCanBeAttachedTo(xyz,e,rp,r) and not (e and r&REASON_EFFECT>0 and tc:IsImmuneToEffect(e)) then
				if #og>0 then
					if transfer then
						Duel.Overlay(xyz,og)
					else
						Duel.SendtoGrave(og,REASON_RULE)
					end
				end
			end
		end
		Duel.Overlay(xyz,c)
		return c:FilterCount(function (card,group) return group:IsContains(card) end, nil, xyz:GetOverlayGroup())
	end
end

--Banish
function Card.IsAbleToRemoveFacedown(c,tp,r)
	if not r then r=REASON_EFFECT end
	return c:IsAbleToRemove(tp,POS_FACEDOWN,r)
end
function Card.IsAbleToRemoveTemp(c,tp,r)
	if not r then r=REASON_EFFECT end
	local pos = c:GetPosition()&POS_FACEDOWN>0 and POS_FACEDOWN or POS_FACEUP
	return c:IsAbleToRemove(tp,pos,r|REASON_TEMPORARY)
end

--Chain Relation
local _IsRelateToChain, _GetTargetCards = Card.IsRelateToChain, Duel.GetTargetCards

Card.IsRelateToChain = function(c,ch)
	local ch = ch or 0
	return _IsRelateToChain(c,ch)
end

Duel.GetTargetCards = function(e)
	if e then
		return _GetTargetCards(e)
	else
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		return tg and tg:Filter(Card.IsRelateToChain,nil) or nil
	end
end

--Custom Categories
if not global_effect_category_table_global_check then
	global_effect_category_table_global_check=true
	global_effect_category_table={}
	global_effect_info_table={}
	global_possible_custom_effect_info_table={}
	global_additional_info_table={}
	
	original_effect_category_table={}
end
function Effect.SetCustomCategory(e,cat,flags)
	if not cat then cat=0 end
	if not flags then flags=0 end
	if not global_effect_category_table[e] then global_effect_category_table[e]={} end
	global_effect_category_table[e][1]=cat
	global_effect_category_table[e][2]=flags
end
function Effect.GetCustomCategory(e)
	if not global_effect_category_table[e] then return 0,0 end
	return global_effect_category_table[e][1], global_effect_category_table[e][2]
end
function Effect.IsHasCustomCategory(e,cat1,cat2)
	local ocat1,ocat2=e:GetCustomCategory()
	return (cat1 and ocat1&cat1>0) or (cat2 and ocat2&cat2>0)
end

function Effect.SetOriginalCategory(e,cat)
	if not cat then cat=0 end
	e:SetCategory(cat)
	original_effect_category_table[e]=cat
end
function Effect.GetOriginalCategory(e)
	if not global_effect_category_table[e] then return e:GetCategory() end
	return global_effect_category_table[e]
end
function Effect.IsHasOriginalCategory(e,cat)
	local ocat=e:GetOriginalCategory()
	return ocat&cat>0
end

--Card Actions

function Duel.Banish(g,pos,r)
	if not pos then pos=POS_FACEUP end
	if not r then r=REASON_EFFECT end
	return Duel.Remove(g,pos,r)
end

--For cards that equip other cards to themselves ONLY
function Duel.EquipAndRegisterLimit(e,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)
						return e:GetOwner()==c
					end
				   )
		be_equip:RegisterEffect(e1)
		return true
	end
	return false
end
--For effects that equip a card to another card
function Duel.EquipToOtherCardAndRegisterLimit(e,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(equip_to)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)
						return e:GetLabelObject()==c
					end
				   )
		be_equip:RegisterEffect(e1)
		return true
	end
	return false
end
function Duel.EquipAndRegisterCustomLimit(f,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(equip_to)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(f)
		be_equip:RegisterEffect(e1)
	end
	return res and equip_to:GetEquipGroup():IsContains(be_equip)
end

function Card.CheckNegateConjunction(c,e1,e2,e3)
	return not c:IsImmuneToEffect(e1) and not c:IsImmuneToEffect(e2) and (not e3 or not c:IsImmuneToEffect(e3))
end

TYPE_NEGATE_ALL = TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP
function Duel.Negate(g,e,reset,notfield,forced,typ,cond)
	local rct=1
	if not reset then
		reset=0
	elseif type(reset)=="table" then
		rct=reset[2]
		reset=reset[1]
	end
	if not typ then typ=0 end
	
	local returntype=type(g)
	if returntype=="Card" then
		g=Group.FromCards(g)
	end
	local check=0
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		if cond then
			e1:SetCondition(cond)
		end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
		tc:RegisterEffect(e1,forced)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		if cond then
			e2:SetCondition(cond)
		end
		if not notfield then
			e2:SetValue(RESET_TURN_SET)
		end
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
		tc:RegisterEffect(e2,forced)
		if not notfield and typ&TYPE_TRAP>0 and tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			if cond then
				e3:SetCondition(cond)
			end
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
			tc:RegisterEffect(e3,forced)
			local res=tc:CheckNegateConjunction(e1,e2,e3)
			if res then
				Duel.AdjustInstantly(tc)
			end
			return e1,e2,e3,res
		end
		local res=tc:CheckNegateConjunction(e1,e2)
		if res then
			Duel.AdjustInstantly(tc)
		end
		if returntype=="Card" then
			return e1,e2,res
		elseif res then
			check=check+1
		end
	end
	return check
end
function Duel.NegateInGY(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|reset)
	tc:RegisterEffect(e2)
	return e1,e2
end
function Duel.Search(g,p,r)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if not r then r=REASON_EFFECT end
	local ct=Duel.SendtoHand(g,p,r)
	local cg=g:Filter(aux.PLChk,nil,p,LOCATION_HAND)
	if #cg>0 then
		if p then
			Duel.ConfirmCards(1-p,cg)
		else
			for tp=0,1 do
				local pg=cg:Filter(Card.IsControler,nil,tp)
				if #pg>0 then
					Duel.ConfirmCards(1-tp,pg)
				end
			end
		end
	end
	return ct,#cg,cg
end
function Duel.SearchAndCheck(g,p,brk,r)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if not r then r=REASON_EFFECT end
	local ct=Duel.SendtoHand(g,p,r)
	local cg=g:Filter(aux.PLChk,nil,p,LOCATION_HAND)
	if #cg>0 then
		local ignore_confirm=false
		if type(brk)~="nil" then
			if brk==true then
				Duel.BreakEffect()
			elseif brk==false then
				ignore_confirm=true
			end
		end
		if not ignore_confirm then
			if p then
				Duel.ConfirmCards(1-p,cg)
			else
				for tp=0,1 do
					local pg=cg:Filter(Card.IsControler,nil,tp)
					if #pg>0 then
						Duel.ConfirmCards(1-tp,pg)
					end
				end
			end
		end
	end
	return ct>0 and #cg>0
end
function Duel.Bounce(g)
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,nil,LOCATION_HAND)
	return ct,#cg,cg
end

function Duel.SendtoGraveAndCheck(g,p,r)
	if type(g)=="Card" then g=Group.FromCards(g) end
	r = r or REASON_EFFECT
	local ct=Duel.SendtoGrave(g,r)
	if ct<=0 then return false end
	local cg=g:Filter(aux.PLChk,nil,p,LOCATION_GRAVE)
	return #cg>0
end

function Duel.ShuffleIntoDeck(g,p,loc,seq,r,f,rp)
	if not loc then loc=LOCATION_DECK|LOCATION_EXTRA end
	if not seq then seq=SEQ_DECKSHUFFLE end
	if not r then r=REASON_EFFECT end
	local ct=Duel.SendtoDeck(g,p,seq,r,rp)
	if ct>0 then
		if seq==SEQ_DECKSHUFFLE then
			aux.AfterShuffle(g)
		end
		if type(g)=="Card" and aux.PLChk(g,p,loc) and (not f or f(g)) then
			return 1
		elseif type(g)=="Group" then
			local sg=g:Filter(aux.PLChk,nil,p,loc)
			if f then
				sg=sg:Filter(f,nil,sg)
			end
			return #sg
		end
	end
	return 0
end
function Duel.PlaceOnTopOfDeck(g,p)
	local ct=Duel.SendtoDeck(g,p,SEQ_DECKTOP,REASON_EFFECT)
	if ct>0 then
		local og=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
		for pp=tp,1-tp,1-2*tp do
			local dg=og:Filter(Card.IsControler,nil,pp)
			if #dg>1 then
				Duel.SortDecktop(p,pp,#dg)
			end
		end
		return ct
	end
	return 0
end

function Auxiliary.PLChk(c,p,loc,min,pos)
	if type(c)=="Card" then
		if min and not pos then pos=min end
		return (not p or c:IsControler(p)) and (not loc or c:IsLocation(loc)) and (not pos or c:IsPosition(pos))
	elseif type(c)=="Group" then
		if not min then min=1 end
		return c:IsExists(aux.PLChk,min,nil,p,loc,pos)
	else
		return false
	end
end
function Auxiliary.AfterShuffle(g)
	for p=0,1 do
		if aux.PLChk(g,p,LOCATION_DECK) then
			Duel.ShuffleDeck(p)
		end
	end
end

--Card Action Filters
function Glitchy.ActivateFilter(f)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and c:GetActivateEffect():IsActivatable(tp,true,true)
			end
end
function Glitchy.AttachFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
			end
end
function Glitchy.AttachFilter2(f)
	return	function(c,...)
				return (not f or f(c,e,...)) and c:IsType(TYPE_XYZ)
			end
end
function Glitchy.BanishFilter(f,cost,pos)
	pos = pos and pos or POS_FACEUP
	return	function(c,_,tp,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToRemove(tp,pos) or cost and c:IsAbleToRemoveAsCost(pos))
			end
end
function Glitchy.ControlFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsControlerCanBeChanged()
			end
end
function Glitchy.DestroyFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and (c:IsOnField() or c:IsDestructable(e))
			end
end
function Glitchy.DiscardFilter(f,cost)
	local r = cost and REASON_EFFECT or REASON_COST
	return	function(c)
				return (not f or f(c)) and c:IsDiscardable(r)
			end
end
function Glitchy.RevealFilter(f)
	return	function(c,...)
				return not c:IsPublic() and (not f or f(c,...))
			end
end
function Glitchy.SearchFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsAbleToHand()
			end
end
function Glitchy.SSetFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsSSetable()
			end
end
function Glitchy.ToDeckFilter(f,cost,loc)
	if not cost then
		return	function(c,...)
			return (not f or f(c,...)) and c:IsAbleToDeck()
		end
	else
		local check=Card.IsAbleToDeckOrExtraAsCost
		if loc then
			if loc==LOCATION_DECK then
				check=Card.IsAbleToDeckAsCost
			elseif loc==LOCATION_EXTRA then
				check=Card.IsAbleToExtraAsCost
			end
		end
		return	function(c,...)
					return (not f or f(c,...)) and check(c)
				end
	end
end
function Glitchy.ToExtraPFilter(f,cost)
	local ableto=cost and Card.IsAbleToExtraFaceupAsCost or Card.IsAbleToExtraFaceup
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...)) and ableto(c,e,tp)
			end
end
function Glitchy.ToGraveFilter(f,cost)
	local ableto=cost and Card.IsAbleToGraveAsCost or Card.IsAbleToGrave
	return	function(c,...)
				return (not f or f(c,...)) and ableto(c)
			end
end
function Glitchy.TributeFilter(f,cost)
	local ableto=cost and Card.IsReleasable or Card.IsReleasableByEffect
	return	function(c,...)
				return (not f or f(c,...)) and ableto(c)
			end
end

--Battle Phase
function Card.IsCapableOfAttacking(c,tp)
	if not tp then tp=Duel.GetTurnPlayer() end
	return not c:IsForbidden() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_ATTACK_DISABLED) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_BP)
end

--Card Filters
function Card.IsFaceupEx(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) or c:IsFaceup()
end

function Card.IsMonster(c,typ)
	return c:IsType(TYPE_MONSTER) and (type(typ)~="number" or c:IsType(typ))
end
function Card.IsSpell(c,typ)
	return c:IsType(TYPE_SPELL) and (type(typ)~="number" or c:IsType(typ))
end
function Card.IsTrap(c,typ)
	return c:IsType(TYPE_TRAP) and (type(typ)~="number" or c:IsType(typ))
end
-- function Card.IsNormalSpell(c)
	-- return c:GetType()&(TYPE_SPELL|TYPE_CONTINUOUS|TYPE_RITUAL|TYPE_EQUIP|TYPE_QUICKPLAY|TYPE_FIELD)==TYPE_SPELL
-- end
-- function Card.IsNormalTrap(c)
	-- return c:GetType()&(TYPE_TRAP|TYPE_CONTINUOUS|TYPE_COUNTER)==TYPE_TRAP
-- end
function Card.IsNormalST(c)
	return c:IsNormalSpell() or c:IsNormalTrap()
end
function Card.IsST(c,typ)
	return c:IsType(TYPE_ST) and (type(typ)~="number" or c:IsType(typ))
end
function Card.MonsterOrFacedown(c)
	return c:IsMonster() or c:IsFacedown()
end

function Card.IsAttributeRace(c,attr,race)
	return c:IsAttribute(attr) and c:IsRace(race)
end
function Card.IsOriginalAttributeRace(c,attr,race)
	return c:IsOriginalAttribute(attr) and c:IsOriginalRace(race)
end

function Card.IsAppropriateEquipSpell(c,ec,tp)
	return c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end

function Card.HasAttack(c)
	return true
end
-- function Card.HasDefense(c)
	-- return not c:IsOriginalType(TYPE_LINK)
-- end

function Card.HasHighest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)>val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasLowest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)<val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasHighestATK(c,g,f)
	return c:HasHighest(Card.GetAttack,g,f)
end
function Card.HasLowestATK(c,g,f)
	return c:HasLowest(Card.GetAttack,g,f)
end
function Card.HasHighestDEF(c,g,f)
	return c:HasHighest(Card.GetDefense,g,f)
end
function Card.HasLowestDEF(c,g,f)
	return c:HasLowest(Card.GetDefense,g,f)
end

function Card.HasOriginalLevel(c)
	return not c:IsOriginalType(TYPE_XYZ+TYPE_LINK)
end

-- function Card.IsOriginalType(c,typ)
	-- return c:GetOriginalType()&typ>0
-- end
-- function Card.IsOriginalRace(c,rc)
	-- return c:GetOriginalRace()&rc>0
-- end

function Card.HasRank(c)
	return c:IsType(TYPE_XYZ) or c:IsOriginalType(TYPE_XYZ) or c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY)
end

function Card.GetRating(c)
	local list={false,false,false,false}
	if c:HasLevel() then
		list[1]=c:GetLevel()
	end
	if c:IsOriginalType(TYPE_XYZ) then
		list[2]=c:GetRank()
	end
	if c:IsOriginalType(TYPE_LINK) then
		list[3]=c:GetLink()
	end
	return list
end
function Card.GetRatingAuto(c)
	if c:HasLevel() then
		return c:GetLevel(),0
	end
	if c:IsOriginalType(TYPE_XYZ) then
		return c:GetRank(),TYPE_XYZ
	end
	if c:IsOriginalType(TYPE_LINK) then
		return c:GetLink(),TYPE_LINK
	end
	return 0,nil
end
function Card.GetOriginalRating(c)
	local list={false,false,false}
	if c:HasLevel(true) then
		list[1]=c:GetOriginalLevel()
	end
	if c:IsOriginalType(TYPE_XYZ) then
		list[2]=c:GetOriginalRank()
	end
	if c:IsOriginalType(TYPE_LINK) then
		list[3]=c:GetOriginalLink()
	end
	return list
end
function Card.GetOriginalRatingAuto(c)
	if c:HasLevel(true) then
		return c:GetOriginalLevel(),0
	end
	if c:IsOriginalType(TYPE_XYZ) then
		return c:GetOriginalRank(),TYPE_XYZ
	end
	if c:IsOriginalType(TYPE_LINK) then
		return c:GetOriginalLink(),TYPE_LINK
	end
	return 0,nil
end
	
function Card.IsRating(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevel(n)) or (rk and c:HasRank() and c:IsRank(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLink(n)) then
			return true
		end
	end
	return false
end
function Card.IsRatingAbove(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevelAbove(n)) or (rk and c:HasRank() and c:IsRankAbove(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkAbove(n)) then
			return true
		end
	end
end
function Card.IsRatingBelow(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevelBelow(n)) or (rk and c:HasRank() and c:IsRankBelow(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkBelow(n)) then
			return true
		end
	end
end

function Card.GetTotalStats(c)
	return c:GetAttack()+c:GetDefense()
end
function Card.GetMinStat(c)
	return math.min(c:GetAttack(),c:GetDefense())
end
function Card.GetMaxStat(c)
	return math.max(c:GetAttack(),c:GetDefense())
end
function Card.GetMinBaseStat(c)
	return math.min(c:GetBaseAttack(),c:GetBaseDefense())
end
function Card.GetMaxBaseStat(c)
	return math.max(c:GetBaseAttack(),c:GetBaseDefense())
end
function Card.IsStats(c,atk,def)
	return (not atk or c:IsAttack(atk)) and (not def or c:IsDefense(def))
end
function Card.GetStats(c)
	return c:GetAttack(),c:GetDefense()
end
function Card.IsBaseStats(c,atk,def)
	return (not atk or c:GetBaseAttack()==atk) and (not def or c:GetBaseDefense()==def)
end
function Card.IsTextStats(c,atk,def)
	return (not atk or c:GetTextAttack()==atk) and (not def or c:GetTextDefense()==def)
end
function Card.IsStat(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttack(n))) and (not def or (c:HasDefense() and c:IsDefense(n))) then
			return true
		end
	end
	return false
end
function Card.IsStatBelow(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttackBelow(n))) or (not def or (c:HasDefense() and c:IsDefenseBelow(n))) then
			return true
		end
	end
	return false
end
function Card.IsStatAbove(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttackAbove(n))) or (not def or (c:HasDefense() and c:IsDefenseAbove(n))) then
			return true
		end
	end
	return false
end

function Card.ByBattleOrEffect(c,f,p)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and (not f or re and f(re:GetHandler(),e,tp,eg,ep,ev,re,r,rp)) and (not p or rp~=(1-p))
			end
end

function Card.IsContained(c,g,exc)
	return g:IsContains(c) and (not exc or not exc:IsContains(c))
end

function Card.GetResidence(c)
	return c:GetControler(),c:GetLocation(),c:GetSequence(),c:GetPosition()
end
function Card.GetLocationSimple(c)
	if c:IsOnField() then
		return LOCATION_ONFIELD
	else
		return c:GetLocation()
	end
end

--Chain Info
function Duel.GetTargetPlayer()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
end
function Duel.GetTargetParam()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
end

function Effect.GetChainLink(e)
	local max=Duel.GetCurrentChain()
	if max==0 then return 0 end
	for i=1,max do
		local ce=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if ce==e then
			return i
		end
	end
	return 0
end

--Cloned Effects
function Effect.SpecialSummonEventClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EVENT_SPSUMMON_SUCCESS)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
function Effect.FlipSummonEventClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
function Effect.UpdateDefenseClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EFFECT_UPDATE_DEFENSE)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end

--codes
-- function Card.IsOriginalCode(c,code)
	-- return c:GetOriginalCode()==code
-- end

--Columns
function Card.GlitchyGetColumnGroup(c,left,right,without_center)
	local left = (left and type(left)=="number" and left>=0) and left or 0
	local right = (right and type(right)=="number" and right>=0) and right or 0
	if left==0 and right==0 then
		return c:GetColumnGroup()
	else
		local f = 	function(card,refc,val)
						local refseq
						if refc:GetSequence()<5 then
							refseq=refc:GetSequence()
						else
							if refc:GetSequence()==5 then
								refseq = 1
							elseif refc:GetSequence()==6 then
								refseq = 3
							end
						end
						
						if card:GetSequence()<5 then
							if card:IsControler(refc:GetControler()) then
								return math.abs(refseq-card:GetSequence())==val
							else
								return math.abs(refseq+card:GetSequence()-4)==val
							end
						
						elseif card:GetSequence()==5 then
							local seq = card:IsControler(refc:GetControler()) and 1 or 3
							return math.abs(refseq-seq)==val
						elseif card:GetSequence()==6 then
							local seq = card:IsControler(refc:GetControler()) and 3 or 1
							return math.abs(refseq-seq)==val
						end
					end
					
		local lg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,left)
		local cg = without_center and Group.CreateGroup() or c:GetColumnGroup()
		local rg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,right)
		cg:Merge(lg)
		cg:Merge(rg)
		return cg
	end
end
function Card.GlitchyGetPreviousColumnGroup(c,left,right)
	local left = (left and type(left)=="number" and left>=0) and left or 0
	local right = (right and type(right)=="number" and right>=0) and right or 0
	if left==0 and right==0 then
		return c:GetColumnGroup()
	else
		local f = 	function(card,refc,val)
						local refseq
						if refc:GetPreviousSequence()<5 then
							refseq=refc:GetPreviousSequence()
						else
							if refc:GetPreviousSequence()==5 then
								refseq = 1
							elseif refc:GetPreviousSequence()==6 then
								refseq = 3
							end
						end
						
						if card:GetPreviousSequence()<5 then
							if card:IsPreviousControler(refc:GetPreviousControler()) then
								return math.abs(refseq-card:GetPreviousSequence())==val
							else
								return math.abs(refseq+card:GetPreviousSequence()-4)==val
							end
						
						elseif card:GetPreviousSequence()==5 then
							local seq = card:IsPreviousControler(refc:GetPreviousControler()) and 1 or 3
							return math.abs(refseq-seq)==val
						elseif card:GetPreviousSequence()==6 then
							local seq = card:IsPreviousControler(refc:GetPreviousControler()) and 3 or 1
							return math.abs(refseq-seq)==val
						end
					end
					
		local lg=Duel.Group(f,c:GetPreviousControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,left)
		local cg = Group.CreateGroup()
		local rg=Duel.Group(f,c:GetPreviousControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,right)
		cg:Merge(lg)
		cg:Merge(rg)
		return cg
	end
end

--Control
function Card.CanOnlyControlOne(c,id)
	return c:SetUniqueOnField(1,0,id)
end
function Card.OnlyOneOnField(c,id)
	return c:SetUniqueOnField(1,1,id)
end

--Delayed Operation (supports card_or_group == nil)
function Glitchy.DelayedOperation(card_or_group,phase,flag,e,tp,oper,cond,reset,reset_count,hint,effect_desc)
	local g
	if card_or_group then
		g=(type(card_or_group)=="Group" and card_or_group or Group.FromCards(card_or_group))
	end
	reset=reset or (RESET_PHASE|phase)
	reset_count=reset_count or 1
	local fid=e:GetFieldID()
	local function agfilter(c,lbl) return flag and c:GetFlagEffectLabel(flag)==lbl end
	local function get_affected_group(e)
		if not e:GetLabelObject() then return end
		return e:GetLabelObject():Filter(agfilter,nil,e:GetLabel())
	end
	local turncount=Duel.GetTurnCount()

	--Apply operation
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	if effect_desc then e1:SetDescription(effect_desc) end
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE|phase)
	e1:SetReset(reset,reset_count)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	if g then
		e1:SetLabelObject(g)
	end
	if card_or_group then
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			local g=get_affected_group(e)
			if #g==0 then
				e:Reset()
				return false
			end
			return not cond or cond(g,e,tp,eg,ep,ev,re,r,rp,turncount)
		end)
	else
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			local g=get_affected_group(e)
			return not cond or cond(g,e,tp,eg,ep,ev,re,r,rp,turncount)
		end)
	end
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=get_affected_group(e)
		if oper then oper(g,e,tp,eg,ep,ev,re,r,rp,turncount) end
	end)
	Duel.RegisterEffect(e1,tp)

	--Flag cards
	if g and #g>0 and flag then
		local flagprop=hint and EFFECT_FLAG_CLIENT_HINT or 0
		local function flagcond() return not e1:IsDeleted() end
		for tc in g:Iter() do
			tc:RegisterFlagEffect(flag,RESET_EVENT|RESETS_STANDARD|reset,flagprop,reset_count,fid,hint):SetCondition(flagcond)
		end
		g:KeepAlive()
	end

	return e1
end

--Exception
function Glitchy.GetSelfTargetExceptionForSpellTrap(e)
	local c=e:GetHandler()
	local chk=c:IsStatus(STATUS_CHAINING)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsType(TYPE_CONTINUOUS|TYPE_FIELD|TYPE_EQUIP) and not c:IsHasEffect(EFFECT_REMAIN_FIELD) and (not chk or c:IsRelateToChain(e:GetChainLink())) then
		return c
	else
		return nil
	end
end
function Auxiliary.ExceptThis(c,e)
	if type(c)=="Effect" then c=c:GetHandler() end
	local ch=type(e)=="Effect" and e:GetChainLink() or 0
	if c:IsRelateToChain(ch) then return c else return nil end
end

--Deep Label Objects
function Effect.SetLabelObjectObject(e,obj)
	return e:GetLabelObject():SetLabelObject(obj)
end
function Effect.GetLabelObjectObject(e)
	return e:GetLabelObject():GetLabelObject()
end

--Descriptions
local _SetDescription = Effect.SetDescription

Effect.SetDescription = function(e,id,str)
	if not str then
		return _SetDescription(e,id)
	else
		return _SetDescription(e,aux.Stringid(id,str))
	end
end

function Glitchy.Option(id,tp,desc,...)
	if id<2 then
		id,tp=tp,id
	end
	local list={...}
	local off=1
	local ops={}
	local opval={}
	local truect=1
	for ct,b in ipairs(list) do
		local check=b
		local localid
		local localdesc
		if type(b)=="table" then
			check=b[1]
			if #b==3 then
				localid=b[2]
				localdesc=b[3]
			else
				localid=false
				localdesc=b[2]
			end
		else
			localid=id
			localdesc=desc+truect-1
			truect=truect+1
		end
		if check==true then
			if localid then
				ops[off]=aux.Stringid(localid,localdesc)
			else
				ops[off]=localdesc
			end
			opval[off]=ct-1
			off=off+1
		end
	end
	if #ops==0 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	--Duel.Hint(HINT_OPSELECTED,1-tp,ops[op])
	return sel
end

--Equip
function Card.IsAppropriateEquipSpell(c,ec,tp)
	return c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
function Card.IsCanBeEquippedWith(c,ec,e,p,r,ignore_faceup)
	r = r or REASON_EFFECT
	return (ignore_faceup or c:IsFaceup()) and (not ec or (not ec:IsForbidden() and ec:CheckUniqueOnField(p,LOCATION_SZONE)))
	--futureproofing (more checks could be added in the future)
end
function Duel.IsPlayerCanEquipCardTo(tp,be_equip,equip_to,e,checkLocationOnly)
	local eset={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_EQUIP_XGL)}
	for _,ce in ipairs(eset) do
		local tg=ce:GetTarget()
		if not tg or tg(ce,equip_to,e,tp) then
			local res=ce:Evaluate(be_equip,equip_to,e,tp)
			if res and (not checkLocationOnly or res==checkLocationOnly) then
				return false
			end
		end
	end
	return true
end
function Card.IsEquippedWith(c,eq)
	local g=c:GetEquipGroup()
	if not g or #g==0 then return false end
	if type(eq)=="Card" then
		return g:IsContains(eq)
	elseif type(eq)=="number" then
		return g:IsExists(aux.FaceupFilter(Card.IsCode,eq),1,nil)
	elseif type(eq)=="function" then
		return g:IsExists(eq,1,nil,c)
	end
	return false
end
function Glitchy.EquipToOtherCardAndRegisterLimit(e,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		if e:GetHandler()==be_equip then
			local x={...}
			local flag=(#x>0 and type(x[#x])=="number") and x[#x] or be_equip:GetOriginalCode()
			be_equip:RegisterFlagEffect(flag,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,STRING_EQUIPPED_BY_OWN_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(equip_to)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)
						return e:GetLabelObject()==c
					end
				   )
		be_equip:RegisterEffect(e1)
		return true
	end
	return false
end

--Excavate
function Auxiliary.excthfilter(c,tp)
	if not Duel.IsPlayerCanSendtoHand(tp,c) then return false end
	local eset={c:IsHasEffect(EFFECT_CANNOT_TO_HAND)}
	for _,e in ipairs(eset) do
		if e:GetOwner()~=c then
			return false
		end
	end
	return true
end
function Duel.IsPlayerCanExcavateAndSearch(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	return #g==ct and g:FilterCount(aux.excthfilter,nil,tp)>0
end
function Duel.IsPlayerCanExcavateAndSpecialSummon(tp)
	return Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,CARD_EHERO_BLAZEMAN)
end

--Filters
function Glitchy.Filter(f,...)
	local ext_params={...}
	return aux.FilterBoolFunction(f,table.unpack(ext_params))
end
function Glitchy.BuildFilter(f,...)
	local ext_params={...}
	return	function(c)
				for _,func in ipairs(ext_params) do
					if type(func)=="function" then
						if not func(c) then
							return false
						end
					elseif type(func)=="table" then
						if not func[1](c,func[2]) then
							return false
						end
					end
				end
				return true
			end
	
end
function Auxiliary.Faceup(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFaceup()
			end
end
function Auxiliary.Facedown(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFacedown()
			end
end
function Glitchy.FaceupExFilter(f,...)
	local ext_params={...}
	return	function(target)
				return target:IsFaceupEx() and f(target,table.unpack(ext_params))
			end
end
function Glitchy.ArchetypeFilter(set,f,...)
	local ext_params={...}
	return	function(target)
				return target:IsSetCard(set) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Glitchy.MonsterFilter(typ,f,...)
	local ext_params={...}
	if type(typ)=="function" then
		if type(f)~="nil" then
			table.insert(ext_params,1,f)
		end
		f=typ
		typ=nil
	end
	return	function(target)
				return target:IsMonster(typ) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Glitchy.RaceFilter(race,f,...)
	local ext_params={...}
	return	function(target)
				return target:IsRace(race) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Glitchy.SpellTrapFilter(f,...)
	local ext_params={...}
	return	function(target)
				return target:IsSpellTrap() and (not f or f(target,table.unpack(ext_params)))
			end
end

--Flag Effects
function Card.GetFlagEffectWithSpecificLabel(c,flag,label,reset)
	flag=flag&0xfffffff
	local eset={c:IsHasEffect(flag|0x10000000)}
	for i=#eset,1,-1 do
		local e=eset[i]
		local x=e:GetLabel()
		if x==label then
			if not reset then
				return e
			else
				e:Reset()
			end
		end
	end
	return
end
function Duel.GetFlagEffectWithSpecificLabel(p,flag,label,reset)
	flag=flag&0xfffffff
	local eset={Duel.GetPlayerEffect(p,flag|0x10000000)}
	for i=#eset,1,-1 do
		local e=eset[i]
		local x=e:GetLabel()
		if x==label then
			if not reset then
				return e
			else
				e:Reset()
			end
		end
	end
	return
end

function Card.HasFlagEffect(c,id,...)
	local flags={...}
	if id then
		table.insert(flags,id)
	end
	for _,flag in ipairs(flags) do
		if c:GetFlagEffect(flag)>0 then
			return true
		end
	end
	
	return false
end
function Duel.PlayerHasFlagEffect(p,id,...)
	local flags={...}
	if id then
		table.insert(flags,id)
	end
	for _,flag in ipairs(flags) do
		if Duel.GetFlagEffect(p,flag)>0 then
			return true
		end
	end
	
	return false
end
function Card.UpdateFlagEffectLabel(c,id,ct)
	if not ct then ct=1 end
	return c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+ct)
end
function Duel.UpdateFlagEffectLabel(p,id,ct)
	if not ct then ct=1 end
	return Duel.SetFlagEffectLabel(p,id,Duel.GetFlagEffectLabel(p,id)+ct)
end
function Card.HasFlagEffectLabel(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label==val then
			return true
		end
	end
	return false
end
function Card.HasFlagEffectLabelLower(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label<val then
			return true
		end
	end
	return false
end
function Card.HasFlagEffectLabelHigher(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label>val then
			return true
		end
	end
	return false
end
function Duel.PlayerHasFlagEffectLabel(tp,id,val)
	if Duel.GetFlagEffect(tp,id)==0 then return false end
	for _,label in ipairs({Duel.GetFlagEffectLabel(tp,id)}) do
		if label==val then
			return true
		end
	end
	return false
end

--Gain Effect
function Auxiliary.GainEffectType(c,oc,reset)
	if not oc then oc=c end
	if not reset then reset=0 end
	if not c:IsType(TYPE_EFFECT) then
		local e=Effect.CreateEffect(oc)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetCode(EFFECT_ADD_TYPE)
		e:SetValue(TYPE_EFFECT)
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset)
		c:RegisterEffect(e,true)
	end
end

--Grant Effect
function Glitchy.RegisterGrantEffect(c,range,s,o,tg,...)
	local effs={...}
	if #effs==0 then return end
	local returns={}
	for _,e in ipairs(effs) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
		e1:SetRange(range)
		e1:SetTargetRange(s,o)
		e1:SetTarget(tg)
		e1:SetLabelObject(e)
		c:RegisterEffect(e1)
		table.insert(returns,e1)
	end
	return table.unpack(returns)
end
function Glitchy.RegisterEquipGrantEffect(c,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	return xgl.RegisterGrantEffect(c,LOCATION_SZONE,LOCATION_MZONE,LOCATION_MZONE,function(_e,_c) return _c==_e:GetHandler():GetEquipTarget() end,...)
end

--Hint timing
function Effect.SetRelevantTimings(e,extra_timings)
	if not extra_timings then extra_timings=0 end
	return e:SetHintTiming(extra_timings,RELEVANT_TIMINGS|extra_timings)
end
function Effect.SetRelevantBattleTimings(e,extra_timings)
	if not extra_timings then extra_timings=0 end
	return e:SetHintTiming(extra_timings,RELEVANT_BATTLE_TIMINGS|extra_timings)
end

--Iterators
--iterator for getting playerid of current turn player and the other player
function Auxiliary.TurnPlayers()
	local i=0
	return	function()
				i=i+1
				if i==1 then return Duel.GetTurnPlayer() end
				if i==2 then return 1-Duel.GetTurnPlayer() end
			end
end

--Labels
function Effect.SetLabelPair(e,l1,l2)
	if l1 and l2 then
		e:SetLabel(l1,l2)
	elseif l1 then
		local _,o2=e:GetLabel()
		e:SetLabel(l1,o2)
	else
		local o1,_=e:GetLabel()
		e:SetLabel(o1,l2)
	end
end
function Effect.SetSpecificLabel(e,l,pos)
	if not pos then pos=1 end
	local tab={e:GetLabel()}
	if pos==0 or #tab<pos then
		if pos~=0 then
			for i=1,pos-#tab-1 do
				table.insert(tab,0)
			end
		end
		table.insert(tab,l)
	else
		tab[pos]=l
	end
	e:SetLabel(table.unpack(tab))
end
function Effect.GetSpecificLabel(e,pos)
	if not pos then pos=1 end
	local tab={e:GetLabel()}
	if #tab<pos then return end
	return tab[pos]
end
function Effect.GetLabelCount(e)
	local tab={e:GetLabel()}
	if not tab then return 0 end
	return #tab
end

--Link Markers

--LP
function Duel.LoseLP(p,val)
	return Duel.SetLP(tp,Duel.GetLP(tp)-math.abs(val))
end

--Locations
function Card.IsBanished(c,pos)
	return c:IsLocation(LOCATION_REMOVED) and (not pos or c:IsPosition(pos))
end
function Card.IsInExtra(c,fu)
	return c:IsLocation(LOCATION_EXTRA) and (fu==nil or (fu==true or fu==POS_FACEUP) and c:IsFaceup() or (fu==false or fu==POS_FACEDOWN) and c:IsFacedown())
end
function Card.IsInGY(c)
	return c:IsLocation(LOCATION_GRAVE)
end
function Card.IsInMMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function Card.IsInEMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>=5
end
function Card.IsInBackrow(c,pos)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and (not pos or c:IsPosition(pos))
end
function Card.IsSequence(c,seq)
	return c:GetSequence()==seq
end
function Card.IsSequenceBelow(c,seq)
	return c:GetSequence()<=seq
end
function Card.IsSequenceAbove(c,seq)
	return c:GetSequence()>=seq
end
function Card.IsInMainSequence(c)
	return c:IsSequenceBelow(4)
end

function Card.IsSpellTrapOnField(c)
	return not c:IsLocation(LOCATION_MZONE) or (c:IsFaceup() and c:IsST())
end
function Card.NotOnFieldOrFaceup(c)
	return not c:IsOnField() or c:IsFaceup()
end
function Card.NotBanishedOrFaceup(c)
	return not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()
end
function Card.NotInExtraOrFaceup(c)
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end


--Sumtypes
function Card.IsFusionSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function Card.IsRitualSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function Card.IsSynchroSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Card.IsXyzSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
function Card.IsPendulumSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Card.IsLinkSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function Card.IsSelfSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

function Card.GetMechanicSummonType(c)
	local ctypes={
		[TYPE_FUSION]=SUMMON_TYPE_FUSION;
		[TYPE_RITUAL]=SUMMON_TYPE_RITUAL;
		[TYPE_SYNCHRO]=SUMMON_TYPE_SYNCHRO;
		[TYPE_XYZ]=SUMMON_TYPE_XYZ;
		[TYPE_LINK]=SUMMON_TYPE_LINK;
	}
	for typ,sumtyp in pairs(ctypes) do
		if c:IsType(typ) then
			return sumtyp
		end
	end
	return 0
end

--Zones
function Card.GetZone(c,tp)
	local rzone=0
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		rzone = c:IsControler(tp) and (1<<seq) or (1 << (16+seq))
		if c:IsSequence(5,6) then
			rzone = rzone | (c:IsControler(tp) and (1 << (16+11-seq)) or (1 << (11-seq)))
		end
	elseif c:IsLocation(LOCATION_SZONE) then
		rzone = c:IsControler(tp) and (1 << (8+seq)) or (1 << (24+seq))
	end
	
	return rzone
end
function Card.GetPreviousZone(c,tp)
	local rzone = c:IsControler(tp) and (1 <<c:GetPreviousSequence()) or (1 << (16+c:GetPreviousSequence()))
	if c:GetPreviousSequence()==5 or c:GetPreviousSequence()==6 then
		rzone = rzone | (c:IsControler(tp) and (1 << (16 + 11 - c:GetPreviousSequence())) or (1 << (11 - c:GetPreviousSequence())))
	end
	return rzone
end

--Returns all zones from the column with sequence (seq) from the player's own POV.
--If (loc) is specified, only zones from that location(s) will be returned (only LOCATION_MZONE and/or LOCATION_SZONE are valid values)
--If (seq) is taken from the opponent's POV, (isOpponentSeq) shall be set to true
--The player's zones are described by the first 8 hex digits (from the right), while the opponent's zones are described by the remaining 8 digits
function Duel.GetFullColumnZoneFromSequence(seq,loc,isOpponentSeq)
	local zones=0
	if not loc then
		loc=LOCATION_ONFIELD
	else
		if loc&LOCATION_ONFIELD==0 then
			return 0
		end
	end
	
	if isOpponentSeq then
		seq=seq<=4 and 4-seq or seq==5 and 6 or 5
	end
	
	if seq<=4 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|(1<<seq)|(1<<(16+(4-seq)))
			if seq==1 then
				zones = zones|((1<<5)|(1<<(16+6)))
			end
			if seq==3 then
				zones = zones|((1<<6)|(1<<(16+5)))
			end
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|(1<<seq+8)|(1<<(16+8+(4-seq)))
		end
	
	elseif seq==5 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 1) | (1 << (16 + 3))) | ((1<<5) | (1<<(16+6)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 1)) | (1 << (16 + 8 + 3)))
		end
	
	elseif seq==6 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 3) | (1 << (16 + 1))) | ((1<<6) | (1<<(16+5)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 3)) | (1 << (16 + 8 + 1)))
		end
	end
	
	--Debug.Message(zones)
	return zones
end

--Behaves like the previous function, but it excludes the zone of the (seqloc) location from the player's own POV
function Duel.GetColumnZoneFromSequence(seq,seqloc,loc)
	local zones=0
	if not seqloc then
		seqloc=LOCATION_ONFIELD
	else
		if seqloc&LOCATION_ONFIELD==0 or (seqloc==LOCATION_SZONE and seq>=5) then
			return 0
		end 
	end
	if not loc then
		loc=LOCATION_ONFIELD
	else
		if loc&LOCATION_ONFIELD==0 then
			return 0
		end
	end
	
	if seq<=4 then
		if loc&LOCATION_MZONE~=0 then
			if seqloc&LOCATION_MZONE==0 then
				zones = zones|(1<<seq)
			end
			zones = zones|(1<<(16+(4-seq)))
			if seq==1 then
				zones = zones|((1<<5)|(1<<(16+6)))
			end
			if seq==3 then
				zones = zones|((1<<6)|(1<<(16+5)))
			end
		end
		if loc&LOCATION_SZONE~=0 then
			if seqloc&LOCATION_SZONE==0 then
				zones = zones|(1<<seq+8)
			end
			zones = zones|(1<<(16+8+(4-seq)))
		end
	
	elseif seq==5 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 1) | (1 << (16 + 3)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 1)) | (1 << (16 + 8 + 3)))
		end
	
	elseif seq==6 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 3) | (1 << (16 + 1)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 3)) | (1 << (16 + 8 + 1)))
		end
	end
	
	--Debug.Message(zones)
	return zones
end
function Duel.GetColumnGroupFromSequence(tp,seq)
	local column_mzone,column_szone = Duel.GetFullColumnZoneFromSequence(seq,LOCATION_MZONE),Duel.GetFullColumnZoneFromSequence(seq,LOCATION_SZONE)
	local g1=Duel.GetCardsInZone(column_mzone,tp,LOCATION_MZONE)
	local g2=Duel.GetCardsInZone(column_mzone>>16,1-tp,LOCATION_MZONE)
	local g3=Duel.GetCardsInZone(column_szone>>8,tp,LOCATION_SZONE)
	local g4=Duel.GetCardsInZone(column_szone>>24,1-tp,LOCATION_SZONE)
	g1:Merge(g2)
	g1:Merge(g3)
	g1:Merge(g4)
	return g1
end
function Duel.GetCardsInZone(zone,tp,loc)
	if loc&LOCATION_ONFIELD==0 then return end
	local g=Group.CreateGroup()
	local v = loc==LOCATION_MZONE and Duel.GetFieldGroup(tp,LOCATION_MZONE,0) or Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(Card.IsSequenceBelow,nil,4)
	for tc in aux.Next(v) do
		local icheck=1<<tc:GetSequence()
		if zone&icheck~=0 then
			g:AddCard(tc)
		end
	end
	return g
end

function Card.IsInLinkedZone(c,cc)
	return cc:GetLinkedGroup():IsContains(c)
end
function Card.WasInLinkedZone(c,cc)
	return cc:GetLinkedZone(c:GetPreviousControler())&c:GetPreviousZone()~=0
end
function Card.HasBeenInLinkedZone(c,cc)
	return cc:GetLinkedGroup():IsContains(c) or (not c:IsLocation(LOCATION_MZONE) and cc:GetLinkedZone(c:GetPreviousControler())&c:GetPreviousZone()~=0)
end

function Duel.GetMZoneCountFromLocation(tp,up,g,c)
	if c:IsInExtra() then
		return Duel.GetLocationCountFromEx(tp,up,g,c)
	else
		return Duel.GetMZoneCount(tp,g,up)
	end
end

--Location Groups
function Duel.GetHand(p)
	if not p then
		return Duel.GetFieldGroup(0,LOCATION_HAND,LOCATION_HAND)
	else
		return Duel.GetFieldGroup(p,LOCATION_HAND,0)
	end
end
function Duel.GetHandCount(p)
	if not p then
		return Duel.GetFieldGroupCount(0,LOCATION_HAND,LOCATION_HAND)
	else
		return Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	end
end
function Duel.GetDeck(p)
	return Duel.GetFieldGroup(p,LOCATION_DECK,0)
end
function Duel.GetDeckCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
end
function Duel.GetGY(p)
	if not p then
		return Duel.GetFieldGroup(0,LOCATION_GRAVE,LOCATION_GRAVE)
	else
		return Duel.GetFieldGroup(p,LOCATION_GRAVE,0)
	end
end
function Duel.GetGYCount(p)
	if not p then
		return Duel.GetFieldGroupCount(0,LOCATION_GRAVE,LOCATION_GRAVE)
	else
		return Duel.GetFieldGroupCount(LOCATION_GRAVE)
	end
end
function Duel.GetBanishment(p)
	if not p then
		return Duel.GetFieldGroup(0,LOCATION_REMOVED,LOCATION_REMOVED)
	else
		return Duel.GetFieldGroup(p,LOCATION_REMOVED,0)
	end
end
function Duel.GetBanishmentCount(p)
	if not p then
		return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)
	else
		return Duel.GetFieldGroupCount(p,LOCATION_REMOVED,0)
	end
end
function Duel.GetExtraDeck(p)
	return Duel.GetFieldGroup(p,LOCATION_EXTRA,0)
end
function Duel.GetExtraDeckCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_EXTRA,0)
end
function Duel.GetPendulums(p,c)
	if c then
		return Duel.GetFieldGroup(p,LOCATION_PZONE,0):Filter(aux.TRUE,c):GetFirst()
	else
		return Duel.GetFieldGroup(p,LOCATION_PZONE,0)
	end
end
function Duel.GetPendulumsCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_PZONE,0)
end

--Materials

--Normal Summon/set
-- function Card.IsSummonableOrSettable(c)
	-- return c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
-- end
-- function Duel.SummonOrSet(tp,tc,ignore_limit,min)
	-- if not ignore_limit then ignore_limit=true end
	-- if tc:IsSummonable(ignore_limit,min) and (not tc:IsMSetable(ignore_limit,min) or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
		-- Duel.Summon(tp,tc,ignore_limit,min)
	-- else
		-- Duel.MSet(tp,tc,ignore_limit,min)
	-- end
-- end

--Set Monster/Spell/Trap
function Card.IsCanBeSet(c,e,tp,ignore_mzone,ignore_szone)
	if c:IsMonster() then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and (not ignore_mzone or Duel.GetMZoneCount(tp)>0)
	elseif c:IsST() then
		return c:IsSSetable(ignore_szone)
	end
end
function Duel.Set(tp,g)
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	local mg=g:Filter(Card.IsMonster,nil)
	if #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		for tc in aux.Next(mg) do
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
	local sg=g:Filter(Card.IsST,nil)
	if #sg>0 then
		for tc in aux.Next(sg) do
			if tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				ct=ct+Duel.SSet(tp,tc)
			end
		end
	end
	ct=ct+Duel.SpecialSummonComplete()
	return ct
end

--Once per turn
function Effect.OPT(e,ct)
	if not ct then ct=1 end
	if type(ct)=="boolean" then
		return e:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	else
		return e:SetCountLimit(ct)
	end
end

if not Auxiliary.HOPTTracker then
	Auxiliary.HOPTTracker={}
end
function Effect.HOPT(e,oath,ct)
	if not e:GetOwner() then return end
	if not ct then ct=1 end
	local c=e:GetOwner()
	local cid=c:GetOriginalCode()
	if not aux.HOPTTracker[c] then
		aux.HOPTTracker[c]=-1
	end
	aux.HOPTTracker[c]=aux.HOPTTracker[c]+1
	local flag=0
	if oath then
		oath=type(oath)=="number" and oath or EFFECT_COUNT_CODE_OATH
		flag=flag|oath
	end
	if flag==0 then
		return e:SetCountLimit(ct,{cid,aux.HOPTTracker[c]})
	else
		return e:SetCountLimit(ct,{cid,aux.HOPTTracker[c]},flag)
	end
end
function Effect.SHOPT(e,oath)
	if not e:GetOwner() then return end
	local c=e:GetOwner()
	local cid=c:GetOriginalCode()
	if not aux.HOPTTracker[c] then
		aux.HOPTTracker[c]=0
	end
	
	local flag=0
	if oath then
		oath=type(oath)=="number" and oath or EFFECT_COUNT_CODE_OATH
		flag=flag|oath
	end
	
	if flag==0 then
		return e:SetCountLimit(1,{cid,aux.HOPTTracker[c]})
	else
		return e:SetCountLimit(1,{cid,aux.HOPTTracker[c]},flag)
	end
end

--Operated Groups
function Glitchy.BecauseOfThisEffect(e)
	return	function(c)
				return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REDIRECT) and c:GetReasonEffect()==e
			end
end
function Duel.GetGroupOperatedByThisEffect(e,exc)
	return Duel.GetOperatedGroup():Filter(xgl.BecauseOfThisEffect(e),exc)
end
function Glitchy.BecauseOfThisCost(e)
	return	function(c)
				return c:IsReason(REASON_COST) and not c:IsReason(REASON_REDIRECT) and c:GetReasonEffect()==e
			end
end
function Duel.GetGroupOperatedByThisCost(e,exc)
	return Duel.GetOperatedGroup():Filter(xgl.BecauseOfThisCost(e),exc)
end
function Glitchy.BecauseOfThisRule(e)
	return	function(c)
				return c:IsReason(REASON_RULE) and not c:IsReason(REASON_REDIRECT) and c:GetReasonEffect()==e
			end
end
function Duel.GetGroupOperatedByThisRule(e,exc)
	return Duel.GetOperatedGroup():Filter(xgl.BecauseOfThisRule(e),exc)
end

--Operation Infos

function Auxiliary.ClearCustomOperationInfo(e,tp,eg,ep,ev,re,r,rp)
	for i,chtab in pairs(global_effect_info_table) do
		for _,tab in ipairs(chtab) do
			local dg=tab[2]
			if dg then
				dg:DeleteGroup()
			end
		end
		global_effect_info_table[i]=nil
	end
	e:Reset()
end
function Duel.SetCustomOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if g then
		if type(g)=="Card" then
			g=Group.FromCards(g)
		end
		g:KeepAlive()
	end
	if not global_effect_info_table[chain] then
		global_effect_info_table[chain]={}
	end
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(aux.ClearCustomOperationInfo)
	Duel.RegisterEffect(e1,0)
	table.insert(global_effect_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end
function Duel.GetCustomOperationInfo(chain,cat)
	if not global_effect_info_table[chain] then return end
	if not cat then
		return global_effect_info_table[chain]
	else
		local res={}
		local global=global_effect_info_table[chain]
		for _,tab in ipairs(global) do
			if tab[1]&cat==cat then
				table.insert(res,tab)
			end
		end
		return res
	end
end

function Auxiliary.ClearPossibleCustomOperationInfo(e,tp,eg,ep,ev,re,r,rp)
	for i,chtab in pairs(global_possible_custom_effect_info_table) do
		for _,tab in ipairs(chtab) do
			local dg=tab[2]
			if dg then
				dg:DeleteGroup()
			end
		end
		global_possible_custom_effect_info_table[i]=nil
	end
	e:Reset()
end
function Duel.SetPossibleCustomOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if g then
		if type(g)=="Card" then
			g=Group.FromCards(g)
		end
		g:KeepAlive()
	end
	if not global_possible_custom_effect_info_table[chain] then
		global_possible_custom_effect_info_table[chain]={}
	end
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(aux.ClearPossibleCustomOperationInfo)
	Duel.RegisterEffect(e1,0)
	table.insert(global_possible_custom_effect_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end

function Auxiliary.ClearAdditionalOperationInfo(e,tp,eg,ep,ev,re,r,rp)
	for i,chtab in pairs(global_additional_info_table) do
		for _,tab in ipairs(chtab) do
			local dg=tab[2]
			if dg then
				dg:DeleteGroup()
			end
		end
		global_additional_info_table[i]=nil
	end
	e:Reset()
end
function Duel.SetAdditionalOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if g then
		if type(g)=="Card" then
			g=Group.FromCards(g)
		end
		g:KeepAlive()
	end
	if not global_additional_info_table[chain] then
		global_additional_info_table[chain]={}
	end
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(aux.ClearAdditionalOperationInfo)
	Duel.RegisterEffect(e1,0)
	table.insert(global_additional_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end

function Duel.SetCardOperationInfo(g,cat)
	local tc = type(g)=="Card" and g or g:GetFirst()
	local ct = type(g)=="Card" and 1 or #g
	return Duel.SetOperationInfo(0,cat,g,ct,tc:GetControler(),tc:GetLocation())
end
function Duel.SetConditionalOperationInfo(f,ch,cat,g,ct,p,val,...)
	if f then
		Duel.SetOperationInfo(ch,cat,g,ct,p,val)
	else
		Duel.SetPossibleOperationInfo(ch,cat,g,ct,p,val,...)
	end
end
function Duel.SetConditionalCustomOperationInfo(f,ch,cat,g,ct,p,val,...)
	if f then
		Duel.SetCustomOperationInfo(ch,cat,g,ct,p,val,...)
	else
		Duel.SetPossibleCustomOperationInfo(ch,cat,g,ct,p,val,...)
	end
end

--Operation Info templates 
function Duel.SetCardOperationInfo(g,cat)
	if type(g)=="Card" then g=Group.FromCards(g) end
	return Duel.SetOperationInfo(0,cat,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation())
end

function Auxiliary.Info(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
				return Duel.SetOperationInfo(0,ctg,nil,ct,p,v)
			end
end
function Auxiliary.DamageInfo(p,v)
	return Auxiliary.Info(CATEGORY_DAMAGE,0,p,v)
end
function Auxiliary.DrawInfo(p,v)
	return Auxiliary.Info(CATEGORY_DRAW,0,p,v)
end
function Auxiliary.MillInfo(p,v)
	return Auxiliary.Info(CATEGORY_DECKDES,0,p,v)
end
function Auxiliary.RecoverInfo(p,v)
	return Auxiliary.Info(CATEGORY_RECOVER,0,p,v)
end

--Phases
function Glitchy.IsDrawPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_DRAW
end
function Glitchy.IsStandbyPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function Glitchy.IsMainPhase(tp,ct)
	return (not tp or Duel.GetTurnPlayer()==tp)
		and (not ct and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) or ct==1 and Duel.GetCurrentPhase()==PHASE_MAIN1 or ct==2 and Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function Glitchy.IsBattlePhase(tp)
	local ph=Duel.GetCurrentPhase()
	return (not tp or Duel.GetTurnPlayer()==tp) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function Glitchy.IsEndPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_END
end

function Duel.GetNextPhaseCount(ph,p)
	if not ph and not p then return 1 end
	if (not ph or Duel.GetCurrentPhase()==ph) and (not p or Duel.GetTurnPlayer()==p) then
		return 2
	else
		return 1
	end
end
function Duel.GetNextMainPhaseCount(p)
	if Duel.IsMainPhase() and (not p or Duel.GetTurnPlayer()==p) then
		return 2
	else
		return 1
	end
end
function Duel.GetNextBattlePhaseCount(p)
	if Duel.IsBattlePhase() and (not p or Duel.GetTurnPlayer()==p) then
		return 2
	else
		return 1
	end
end

--Player Actions
function Duel.IsPlayerCanDiscardHand(p,ct,r)
	ct = ct or 1
	r = r or REASON_EFFECT
	if r&REASON_COST>0 then
		return not Duel.IsPlayerAffectedByEffect(p,EFFECT_CANNOT_DISCARD_HAND)
	else
		--futureproofing
		return true
	end
end
function Duel.IsPlayerCanSendtoHandFromLocation(p,loc,c)
	--futureproof
	return true
end

--PositionChange
function Duel.PositionChange(c)
	return Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function Duel.Flip(c,pos)
	if not c or (pos&POS_FACEUP==0 and pos&POS_FACEDOWN==0) then return 0 end
	if type(c)=="Card" then
		if (pos&POS_FACEUP>0 and c:IsFaceup()) or (pos&POS_FACEDOWN>0 and c:IsFacedown()) then return 0 end
		local position = pos&POS_FACEUP>0 and c:GetPosition()>>1 or c:GetPosition()<<1
		return Duel.ChangePosition(c,position)
	else
		local ct=0
		for tc in aux.Next(c) do
			ct=ct+Duel.Flip(tc,pos)
		end
		return ct
	end
end
function Card.IsCanTurnSetGlitchy(c)
	if c:IsPosition(POS_FACEDOWN_DEFENSE) then return false end
	if not c:IsPosition(POS_FACEDOWN_ATTACK) then
		return c:IsCanTurnSet()
	else
		return not c:IsType(TYPE_LINK|TYPE_TOKEN) and not c:IsHasEffect(EFFECT_CANNOT_TURN_SET) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TURN_SET)
	end
end

--Previous
function Card.IsPreviousCodeOnField(c,code,...)
	local codes={...}
	table.insert(codes,1,code)
	local precodes={c:GetPreviousCodeOnField()}
	for _,prename in ipairs(precodes) do
		for _,name in ipairs(codes) do
			if prename==name then
				return true
			end
		end
	end
	return false
end
function Card.IsPreviousTypeOnField(c,typ)
	return c:GetPreviousTypeOnField()&typ==typ
end
function Card.IsPreviousLevelOnField(c,lv)
	return c:GetPreviousLevelOnField()==lv
end
function Card.IsPreviousRankOnField(c,lv)
	return c:GetPreviousRankOnField()==lv
end
function Card.IsPreviousAttributeOnField(c,att)
	return c:GetPreviousAttributeOnField()&att==att
end
function Card.IsPreviousRaceOnField(c,rac)
	return c:GetPreviousRaceOnField()&rac==rac
end
function Card.IsPreviousAttackOnField(c,atk)
	return c:GetPreviousAttackOnField()==atk
end
function Card.IsPreviousDefenseOnField(c,def)
	return c:GetPreviousDefenseOnField()==def
end

--Pendulum-related
function Card.IsAbleToExtraFaceup(c,e,tp,r,recp)
	if not (c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,c) and not c:IsHasEffect(EFFECT_CANNOT_TO_EXTRA_P)) then return false end
	tp = tp or c:GetControler()
	r = r or REASON_EFFECT
	recp = recp or c:GetOwner()
	local eset={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_TO_EXTRA_P)}
	for _,ce in ipairs(eset) do
		local tg=ce:GetTarget()
		if not tg or tg(ce,c,e,tp,r,recp) then
			return false
		end
	end
	return true
end
function Card.IsCapableSendToExtra(c,tp)
	if not c:IsMonster(TYPE_EXTRA|TYPE_PENDULUM) or c:IsHasEffect(EFFECT_CANNOT_TO_DECK) or not Duel.IsPlayerCanSendtoDeck(tp,c) then return false end
	return true
end
function Card.IsAbleToExtraFaceupAsCost(c,e,tp,recp)
	if not c:IsAbleToExtraFaceup(e,tp,REASON_COST,recp) or c:IsHasEffect(EFFECT_CANNOT_USE_AS_COST) then return false end
	local redirect=0
	local dest=0
	
	if c:IsOnField() then
		redirect=c:GetLeaveFieldRedirect(REASON_COST)&0xffff
	end
	if redirect~=0 then
		dest=redirect
	end
	redirect = c:GetRealDestinationRedirect(dest,REASON_COST)&0xffff
	if redirect~=0 then
		dest=redirect
	end
	return dest==0
end
function Card.IsCanBePlacedInPZone(c,e,tp)
	return not c:IsForbidden() --futureproof
end

--Reason
function Effect.HasReasonArchetype(re,setcode)
	local rc=re:GetHandler()
	local trig_loc,trig_setcodes=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SETCODES)
	if not Duel.IsChainSolving() or (rc:IsRelateToEffect(re) and rc:IsLocation(trig_loc)
		and (not rc:IsLocation(LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_EXTRA) or rc:IsFaceup())) then
		return rc:IsSetCard(setcode)
	end
	for _,set in ipairs(trig_setcodes) do
		if (setcode&0xfff)==(set&0xfff) and (setcode&set)==setcode then return true end
	end
end

--Redirect
function Card.IsAbleToLocationAsCost(c,loc)
	local loclist={
		[LOCATION_HAND]=Card.IsAbleToHandAsCost;
		[LOCATION_GRAVE]=Card.IsAbleToGraveAsCost;
		[LOCATION_DECK]=Card.IsAbleToDeckAsCost;
		[LOCATION_EXTRA]=Card.IsAbleToExtraAsCost;
		[LOCATION_REMOVED]=Card.IsAbleToRemoveAsCost;
	}
	return loclist[loc](c)
end
function Card.GetDestinationReset(c)
	if c:IsOriginalType(TYPE_TOKEN) then return 0 end
	local dest=c:GetDestination()
	local options={
		[LOCATION_HAND]=RESET_TOHAND;
		[LOCATION_DECK]=RESET_TODECK;
		[LOCATION_EXTRA]=RESET_TODECK;
		[LOCATION_GRAVE]=RESET_TOGRAVE;
		[LOCATION_REMOVED]=RESET_REMOVE|RESET_TEMP_REMOVE;
		[LOCATION_ONFIELD]=RESET_TOFIELD;
		[LOCATION_OVERLAY]=RESET_OVERLAY;
	}
	
	for loc,eloc in pairs(options) do
		if dest&loc>0 then
			return eloc
		end
	end
	
	return 0
end
function Card.GetRealDestinationRedirect(c,dest,r)
	local eset
	if c:IsOriginalType(TYPE_TOKEN) then return 0 end
	local options={
		[LOCATION_HAND]=EFFECT_TO_HAND_REDIRECT;
		[LOCATION_DECK]=EFFECT_TO_DECK_REDIRECT;
		[LOCATION_GRAVE]=EFFECT_TO_GRAVE_REDIRECT;
		[LOCATION_REMOVED]=EFFECT_REMOVE_REDIRECT
	}
	for loc,eloc in pairs(options) do
		if dest==loc then
			eset={c:IsHasEffect(eloc)}
			break
		end
	end
	if not eset then return 0 end
	for _,e in ipairs(eset) do
		local p=e:GetHandlerPlayer()
		local val=e:Evaluate(c)
		if val&LOCATION_HAND>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_HAND) and Duel.IsPlayerCanSendtoHand(p,c) then
			return LOCATION_HAND
		end
		if val&LOCATION_DECK>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(p,c) then
			return LOCATION_DECK
		end
		if val&LOCATION_REMOVED>0 and not c:IsHasEffect(EFFECT_CANNOT_REMOVE) and Duel.IsPlayerCanRemove(p,c,r) then
			return LOCATION_REMOVED
		end
		if val&LOCATION_GRAVE>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_GRAVE) and Duel.IsPlayerCanSendtoGrave(p,c) then
			return LOCATION_GRAVE
		end
	end
	return 0
end
function Card.GetLeaveFieldRedirect(c,r)
	local redirects=0
	if c:IsOriginalType(TYPE_TOKEN) then return 0 end
	local eset={c:IsHasEffect(EFFECT_LEAVE_FIELD_REDIRECT)}
	for _,e in ipairs(eset) do
		local p=e:GetHandlerPlayer()
		local val=e:Evaluate(c)
		if val&LOCATION_HAND>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_HAND) and Duel.IsPlayerCanSendtoHand(p,c) then
			redirects = redirects|LOCATION_HAND
		end
		if val&LOCATION_DECK>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(p,c) then
			redirects = redirects|LOCATION_DECK
		end
		if val&LOCATION_REMOVED>0 and not c:IsHasEffect(EFFECT_CANNOT_REMOVE) and Duel.IsPlayerCanRemove(p,c,r) then
			redirects = redirects|LOCATION_REMOVED
		end
	end
	if redirects&LOCATION_REMOVED>0 then return LOCATION_REMOVED end
	if redirects&LOCATION_DECK>0 then
		if redirects&LOCATION_DECKBOT==LOCATION_DECKBOT then
			return LOCATION_DECKBOT
		end
		if redirects&LOCATION_DECKSHF==LOCATION_DECKSHF then
			return LOCATION_DECKSHF
		end
		return LOCATION_DECK
	end
	if redirects&LOCATION_HAND>0 then return LOCATION_HAND end
	return 0
end

--Relation

--Ritual-Related
function Card.IsMentionedByRitualSpell(c,spell)
	return (spell.fit_monster and c:IsCode(table.unpack(spell.fit_monster))) or spell:ListsCode(c:GetCode())
end

--Set Backrow
function Glitchy.SetSuccessfullyFilter(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE)
end
function Card.MustWaitOneTurnToActivateAfterBeingSet(c)
	return c:IsTrap() or c:IsSpell(TYPE_QUICKPLAY)
end
function Duel.SSetAndFastActivation(p,g,e,cond,brk)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if Duel.SSet(p,g)>0 and (not cond or cond==true or cond(e,p)) then
		local c=e:GetHandler()
		local og=g:Filter(aux.AND(Card.MustWaitOneTurnToActivateAfterBeingSet,xgl.SetSuccessfullyFilter),nil)
		if #og>0 and brk then
			Duel.BreakEffect()
		end
		for tc in aux.Next(og) do
			local code = tc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_FAST_ACTIVATION)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(code)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function Duel.SSetAndRedirect(p,g,e)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if Duel.SSet(p,g)>0 then
		local c=e:GetHandler()
		local og=g:Filter(xgl.SetSuccessfullyFilter,nil)
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_BANISH_REDIRECT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
			tc:RegisterEffect(e1,true)
		end
	end
end

--Shortcuts
function Duel.IsExists(target,f,tp,loc1,loc2,min,exc,...)
	if type(target)~="boolean" then Debug.Message("Duel.IsExists: First argument should be boolean") return false end
	local func = (target==true) and Duel.IsExistingTarget or Duel.IsExistingMatchingCard
	
	return func(f,tp,loc1,loc2,min,exc,...)
end
function Duel.Select(hint,target,tp,f,pov,loc1,loc2,min,max,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,pov,loc1,loc2,min,max,exc,...)
	return g
end
function Duel.ForcedSelect(hint,target,tp,f,pov,loc1,loc2,min,max,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,pov,loc1,loc2,min,max,exc,...)
	if not g or #g==0 then
		g=func(tp,f,pov,loc1,loc2,min,max,exc)
	end
	return g
end
function Duel.Group(f,tp,loc1,loc2,exc,...)
	local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,...)
	return g
end
function Duel.HintMessage(tp,msg)
	Duel.Hint(HINT_SELECTMSG,tp,msg)
end
function Card.Activation(c,oath,timings,cond,cost,tg,op,stop)
	local e1=Effect.CreateEffect(c)
	if c:IsOriginalType(TYPE_PENDULUM) then
		e1:SetDescription(STRING_ACTIVATE_PENDULUM)
	end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if oath then
		e1:HOPT(true)
	end
	if timings then
		e1:SetRelevantTimings()
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	if not stop then
		c:RegisterEffect(e1)
	end
	return e1
end
function Effect.SetFunctions(e,cond,cost,tg,op,val)
	if cond then
		e:SetCondition(cond)
	end
	if cost then
		e:SetCost(cost)
	end
	if tg then
		e:SetTarget(tg)
	end
	if op then
		e:SetOperation(op)
	end
	if val then
		e:SetValue(val)
	end
end
function Duel.Highlight(g)
	if #g>0 then
		Duel.HintSelection(g)
		return true
	else
		return false
	end
end

--Shortcuts for filters
function Auxiliary.Necro(f)
	return aux.NecroValleyFilter(f)
end
function Glitchy.PlasmatailFilter(targeting_player,f)
	return	function(c,...)
				if f and not f(c,...) then return false end
				local eset={c:IsHasEffect(CARD_ANCESTAGON_PLASMATAIL)}
				for _,e in ipairs(eset) do
					local val=e:Evaluate(c)
					if targeting_player==val then
						return false
					end
				end
				return true
			end
end

--Special Summons
function Duel.SpecialSummonRedirect(redirect,e,g,sumtype,sump,fieldp,ignore_sumcon,ignore_revive_limit,pos,zone,desc)
	if type(redirect)=="Effect" then
		redirect,e,g,sumtype,sump,fieldp,ignore_sumcon,ignore_revive_limit,pos,zone = LOCATION_REMOVED,redirect,e,g,sumtype,sump,fieldp,ignore_sumcon,ignore_revive_limit,pos
	end
	if type(g)=="Card" then g=Group.FromCards(g) end
	
	if not desc then
		if redirect==LOCATION_REMOVED then
			desc=STRING_BANISH_REDIRECT
		elseif redirect==LOCATION_DECK then
			desc=STRING_TOP_OF_DECK_REDIRECT
		elseif redirect==SEQ_DECKBOT then
			desc=STRING_BOTTOM_OF_DECK_REDIRECT
		elseif redirect==LOCATION_DECKSHF then
			desc=STRING_SHUFFLE_INTO_DECK_REDIRECT
		end
	end
	
	local owner=e:GetHandler()
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[fieldp+1]
			if dg:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revive_limit,pos,1-fieldp,zone[2-fieldp])
			and (not dg:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revive_limit,pos,fieldp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				fieldp=1-fieldp
				finalzone=zone[fieldp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,sumtype,sump,fieldp,ignore_sumcon,ignore_revive_limit,pos,finalzone) then
			local e1=Effect.CreateEffect(owner)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			if desc then
				e1:SetDescription(desc)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			else
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			end
			e1:SetValue(redirect)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
			dg:RegisterEffect(e1,true)
		end
	end
	return Duel.SpecialSummonComplete()
end

--Special Summon Procedures and After Effect Resolution
function Glitchy.RegisterResetAfterSpecialSummonRule(c,tp,...)
	local effs={...}
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_SPSUMMON)
	e0:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
		for _,e in ipairs(effs) do
			e:Reset()
		end
		_e:Reset()
	end
	)
	Duel.RegisterEffect(e0,tp)
	return e0
end


--Stat Modifiers (futureproofing)
function Card.HasATK(c)
	return c:IsMonster()
end
function Card.IsCanUpdateATK(c,atk,e,tp,r,exactly)
	return c:IsFaceup() and c:HasATK() and (not exactly or atk>=0 or c:IsAttackAbove(-atk))
end
function Card.IsCanChangeATK(c,atk,e,tp,r)
	return c:IsFaceup() and c:HasATK() and (not atk or not c:IsAttack(atk))
end

function Card.HasDEF(c)
	return c:IsMonster() and not c:IsOriginalType(TYPE_LINK) and not c:IsMaximumMode()
end
function Card.IsCanUpdateDEF(c,def,e,tp,r,exactly)
	return c:IsFaceup() and c:HasDEF() (not exactly or def>=0 or c:IsDefenseAbove(-def))
end
function Card.IsCanChangeDEF(c,def,e,tp,r)
	return c:IsFaceup() and c:HasDEF() and (not def or not c:IsDefense(def))
end

function Card.IsCanChangeStats(c,atk,def,e,tp,r)
	return c:IsCanChangeATK(atk,e,tp,r) or c:IsCanChangeDEF(def,e,tp,r)
end
function Card.IsCanUpdateStats(c,atk,def,e,tp,r,exactly)
	return c:IsCanUpdateATK(atk,e,tp,r) or c:IsCanUpdateDEF(def,e,tp,r)
end

--Tables

--Generate a table that contains all cards contained by the input group
function Group.GetEquivalentTable(g)
	local tab={}
	for c in g:Iter() do
		table.insert(tab,c)
	end
	return tab
end

function Glitchy.FindInTable(tab,...)
	local extras={...}
	if #extras==0 then return false end
	
	for _,param in ipairs(extras) do
		for _,elem in ipairs(tab) do
			if elem==param then
				return true
			end
		end
	end
	
	return false
end
function Glitchy.CopyTable(tab,...)
	if not tab then return end
	local copy={}
	local pre={...}
	for _,b in ipairs(pre) do
		table.insert(copy,b)
	end
	
	for _,a in ipairs(tab) do
		table.insert(copy,a)
	end
	return copy
end
function Glitchy.ClearTable(tab)
	local size=#tab
	if size>0 then
		for k=1,size do
			table.remove(tab)
		end
	end
end
function Glitchy.ClearTableRecursive(tab)
	for k,v in pairs(tab) do
		if type(v)=="table" then
			xgl.ClearTableRecursive(v)
		end
		tab[k]=nil
	end
end
function Glitchy.TableRemove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

--Target function
function aux.DummyTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

--Xyz Materials
function Card.IsAbleToDetachAsCost(c,e,tp)
	if not c:IsLocation(LOCATION_OVERLAY) then return false end
	local xyz=c:GetOverlayTarget()
	return xyz and xyz:IsType(TYPE_XYZ) --futureproofing
end
function Card.HasCardAttached(c,ac)
	if not c:IsType(TYPE_XYZ) then return false end
	if not ac then
		return c:GetOverlayCount()>0
	else
		return c:GetOverlayGroup():IsContains(ac)
	end
end
function Card.IsAttachedTo(c,xyzc)
	return c:IsLocation(LOCATION_OVERLAY) and xyzc:HasCardAttached(c)
end
function Group.CheckRemoveOverlayCard(g,tp,ct,r)
	return g:IsExists(Card.CheckRemoveOverlayCard,1,nil,tp,ct,r)
end
function Group.RemoveOverlayCard(g,tp,min,max,r)
	local res=0
	Duel.HintMessage(tp,HINTMSG_REMOVEXYZ)
	local tg=g:FilterSelect(tp,Card.CheckRemoveOverlayCard,1,1,nil,tp,min,r)
	if #tg>0 then
		res=tg:GetFirst():RemoveOverlayCard(tp,min,max,r)
	end
	return res
end
function Duel.GetXyzMaterialGroup(tp,s,o,xyzf,matf,...)
	xyzf=xyzf and xyzf or aux.TRUE
	matf=matf and matf or aux.TRUE
	local sloc=s==1 and LOCATION_MZONE or 0
	local oloc=o==1 and LOCATION_MZONE or 0
	local g=Group.CreateGroup()
	local xyzg=Duel.Group(xyzf,tp,sloc,oloc,nil,...):Filter(Card.IsType,nil,TYPE_XYZ)
	if #xyzg>0 then
		for xyz in aux.Next(xyzg) do
			local matg=xyz:GetOverlayGroup():Filter(matf,nil,...)
			if #matg>0 then
				g:Merge(matg)
			end
		end
	end
	return g
end
function Duel.GetXyzMaterialGroupCount(tp,s,o,xyzf,matf,...)
	local g=Duel.GetXyzMaterialGroup(tp,s,o,xyzf,matf,...)
	return #g
end
function Group.GetXyzMaterialGroup(xyzg,matf,...)
	matf=matf and matf or aux.TRUE
	xyzg=xyzg:Filter(Card.IsType,nil,TYPE_XYZ)
	local g=Group.CreateGroup()
	if #xyzg>0 then
		for xyz in aux.Next(xyzg) do
			local matg=xyz:GetOverlayGroup():Filter(matf,nil,...)
			if #matg>0 then
				g:Merge(matg)
			end
		end
	end
	return g
end

--Zones
-- Recursively collects every way to assign 'cards' into 'available_zones'
local function _collectAssignments(cards, idx, available_zones, current, results, p, up)
    if idx > #cards then
        -- snapshot current assignment
        local snap = {}
        for card, zone in pairs(current) do
            snap[card] = zone
        end
        table.insert(results, snap)
        return
    end

    local c = cards[idx]
    -- build list of possible zones for this card
    local zones = {}
    do
        local _, mask
        if c:IsLocation(LOCATION_EXTRA) then
            _, mask = Duel.GetLocationCountFromEx(p, up, nil, c)
        else
            _, mask = Duel.GetLocationCount(p, LOCATION_MZONE, up, nil)
        end
        mask = 0x7f & ~mask 
        for _, z in aux.BitSplit(mask) do
            table.insert(zones, z)
        end
    end

    for _, z in ipairs(zones) do
        if (available_zones & z) ~= 0 then
            current[c] = z
            _collectAssignments(cards, idx+1, available_zones & ~z, current, results, p, up)
            current[c] = nil
        end
    end
end

--- Returns a list of all valid zone‐assignments for exactly the given group of cards.
-- @param sg  a Group containing exactly the cards you want to place
-- @param p   player ID
-- @param up  position (e.g. POS_FACEUP)
-- @return    an array of tables; each table maps each card→zone bitmask
function Glitchy.GetZoneAssignmentsForGroup(sg, p, up)
    local cards = (type(sg)=="Group") and sg:GetEquivalentTable() or sg

    -- compute the starting available‐zones bitmask
    local available = 0x7f & ~(select(2, Duel.GetLocationCount(p, LOCATION_MZONE, up)))
    if Duel.CheckLocation(p, LOCATION_MZONE, 5) then available = available | 0x20 end
    if Duel.CheckLocation(p, LOCATION_MZONE, 6) then available = available | 0x40 end

    -- collect all assignments
    local unfilteredResults,results = {},{}
    _collectAssignments(cards, 1, available, {}, unfilteredResults, p, up)
	
	for _,tab in ipairs(unfilteredResults) do
		local emzct=0
		for c,z in pairs(tab) do
			if z>0x10 then
				emzct=emzct+1
			end
		end
		if emzct<=1 then
			table.insert(results, tab)
		end
	end
	
    return results
end


--LOAD OTHER LIBRARIES
Duel.LoadScript("glitchylib_subgroup.lua")	--FUNCTIONS FOR SUBGROUP CHECKING/SELECTION
Duel.LoadScript("glitchylib_cond.lua")		--CONDITIONS
Duel.LoadScript("glitchylib_cost.lua")		--COSTS
Duel.LoadScript("glitchylib_single.lua")	--SINGLE-TYPE EFFECTS TEMPLATES
Duel.LoadScript("glitchylib_field.lua")		--FIELD-TYPE EFFECTS TEMPLATES
Duel.LoadScript("glitchylib_activated.lua")	--ACTIVATED EFFECTS TEMPLATES