--[[
glitchymods_disclosure.lua
Card disclosure terms ("reveal", "show", "look at", "excavate") as distinguishable events.

The core cannot tell these terms apart: Duel.ConfirmCards serves all of them (and the technical confirmation that follows
most searches), Duel.ConfirmDecktop serves both "reveal" and "excavate", and EFFECT_PUBLIC makes cards public without raising
any event. This library gives every term its own entry point, all raising the same custom event with the term in its value.

EVENT_DISCLOSE (eg, ep, ev, re, r, rp)
	eg	the disclosed cards, still in the location they were disclosed from when the event is raised
	ev	DISCLOSURE_* term bit, plus DISCLOSURE_PERSISTENT when the cards were made public by an EFFECT_PUBLIC effect
	re	the effect that performed the disclosure (for DISCLOSURE_PERSISTENT events raised by the watcher: the EFFECT_PUBLIC effect;
		use Glitchy.GetDisclosureSource(re) to get the card responsible in both cases)
	r	REASON_EFFECT while a chain is resolving, otherwise REASON_COST (the same rule the core uses for EVENT_CONFIRM),
		unless the caller passes an explicit reason
	rp	the reason player
	ep	for card disclosures, the opponent of the player the cards were confirmed to (as for EVENT_CONFIRM);
		for Deck-top disclosures and persistent disclosures, the controller of the disclosed cards

Temporary disclosures (same signatures as the base methods, plus an optional reason):
	Duel.RevealCards(p,g[,r])		Duel.ShowCards(p,g[,r])		Duel.LookAtCards(p,g[,r])
	Duel.RevealDecktop(p,ct[,r])	Duel.ExcavateDecktop(p,ct[,r])	(both return the disclosed group, like Duel.ConfirmDecktop)
Persistent disclosures (EFFECT_PUBLIC):
	Glitchy.DiscloseCardsPersistent(term,e,g[,reset,rct,r]) / Duel.RevealCardsPersistent(e,g[,reset,rct,r])
	Effect.SetDisclosureTerm(e,term)	marks an EFFECT_PUBLIC effect registered by other means (default term: DISCLOSURE_REVEAL)
Consumers:
	Glitchy.EnableDisclosureWatcher()	must be called in initial_effect of every card that listens to EVENT_DISCLOSE. It installs:
		- the wrappers that report the "reveal" call sites of the official cards listed in Glitchy.OfficialRevealSites;
		- the EVENT_ADJUST watcher that reports hand cards that become public through EFFECT_PUBLIC effects not registered
		  with Glitchy.DiscloseCardsPersistent (official cards, field-type effects applying to cards that enter the hand later).
]]
Glitchy=Glitchy or {}
xgl=Glitchy

--Disclosure terms (value of EVENT_DISCLOSE)
DISCLOSURE_REVEAL		=	0x1
DISCLOSURE_SHOW			=	0x2
DISCLOSURE_LOOK			=	0x4
DISCLOSURE_EXCAVATE		=	0x8
DISCLOSURE_PERSISTENT	=	0x100

--Custom event raised for every disclosure (the passcode belongs to "Gishki Songstress", the first card that needed it)
EVENT_DISCLOSE			=	EVENT_CUSTOM+130000257

--Base methods, captured once so that the helpers never go through the wrappers installed by Glitchy.EnableDisclosureWatcher
xgl.ConfirmCardsBase = xgl.ConfirmCardsBase or Duel.ConfirmCards
xgl.ConfirmDecktopBase = xgl.ConfirmDecktopBase or Duel.ConfirmDecktop

--[[
Returns (re,r,rp) of a disclosure performed now.
The reason (r) can be manually overwritten.
Must be called BEFORE the base method.
]]
function Glitchy.GetDisclosureReason(r)
	local re=Duel.GetReasonEffect()
	local rp=Duel.GetReasonPlayer()
	if not r then
		r=Duel.IsChainSolving() and REASON_EFFECT or REASON_COST
	end
	return re,r,rp
end

--Raise EVENT_DISCLOSE with the appropriate DISCLOSURE_ term
function Glitchy.RaiseDisclosureEvent(g,term,re,r,rp,ep)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if not g or #g==0 then return end
	Duel.RaiseEvent(g,EVENT_DISCLOSE,re,r,rp,ep,term)
end

--Returns the card responsible for a disclosure: the owner of an EFFECT_PUBLIC effect, the handler of any other effect.
function Glitchy.GetDisclosureSource(re)
	if not re then return nil end
	if re:GetCode()==EFFECT_PUBLIC then
		return re:GetOwner()
	end
	return re:GetHandler()
end

--=====================
--TEMPORARY DISCLOSURES
--=====================

function Glitchy.DiscloseCards(term,p,g,r)
	if type(g)=="Card" then g=Group.FromCards(g) end
	if not g or #g==0 then return end
	local re,rr,rp=xgl.GetDisclosureReason(r)
	xgl.ConfirmCardsBase(p,g)
	xgl.RaiseDisclosureEvent(g,term,re,rr,rp,1-p)
end
function Glitchy.DiscloseDecktop(term,p,ct,r)
	local re,rr,rp=xgl.GetDisclosureReason(r)
	local g=xgl.ConfirmDecktopBase(p,ct)
	if g and #g>0 then
		xgl.RaiseDisclosureEvent(g,term,re,rr,rp,p)
	end
	return g
end
function Duel.RevealCards(p,g,r)
	return xgl.DiscloseCards(DISCLOSURE_REVEAL,p,g,r)
end
function Duel.ShowCards(p,g,r)
	return xgl.DiscloseCards(DISCLOSURE_SHOW,p,g,r)
end
function Duel.LookAtCards(p,g,r)
	return xgl.DiscloseCards(DISCLOSURE_LOOK,p,g,r)
end
function Duel.RevealDecktop(p,ct,r)
	return xgl.DiscloseDecktop(DISCLOSURE_REVEAL,p,ct,r)
end
function Duel.ExcavateDecktop(p,ct,r)
	return xgl.DiscloseDecktop(DISCLOSURE_EXCAVATE,p,ct,r)
end

--=====================
--PERSISTENT DISCLOSURE
--=====================

--Term applied by each EFFECT_PUBLIC effect (effects not listed default to DISCLOSURE_REVEAL, see Effect.GetDisclosureTerm)
xgl.PublicEffectTerms = xgl.PublicEffectTerms or {}

--(Annoying) EFFECT_PUBLIC cards whose text does not say "reveal"...
xgl.OfficialPublicTerms = {
	[69217334]	=	DISCLOSURE_SHOW,	--Breaking of the World
	[8951260]	=	DISCLOSURE_SHOW,	--Respect Play
}

function Effect.SetDisclosureTerm(e,term)
	xgl.PublicEffectTerms[e]=term
end
function Effect.GetDisclosureTerm(e)
	local term=xgl.PublicEffectTerms[e]
	if term then return term end
	local owner=e:GetOwner()
	if owner then
		term=xgl.OfficialPublicTerms[owner:GetOriginalCode()]
		if term then return term end
	end
	return DISCLOSURE_REVEAL
end

--Hand cards already reported as kept public: [card]=field ID at the time of the report
xgl.PublicHandState = xgl.PublicHandState or {}
function Glitchy.IsKeptPublicInHand(c)
	return c:IsLocation(LOCATION_HAND) and c:IsHasEffect(EFFECT_PUBLIC)
end

--[[
Keeps the cards in g public by registering one EFFECT_PUBLIC effect on each of them (owner: the handler of e), and immediately
raises EVENT_DISCLOSE (term|DISCLOSURE_PERSISTENT) for the hand cards that were not already public. Those cards are recorded as
reported, so the watcher does not report them again.
- reset, rct: expiration of the EFFECT_PUBLIC effects (RESET_EVENT|RESETS_STANDARD is always included)
- r: reason of the event (default: see Glitchy.GetDisclosureReason). Costs should pass REASON_COST.
Returns the registered effects.
]]
function Glitchy.DiscloseCardsPersistent(term,e,g,reset,rct,r)
	if type(g)=="Card" then g=Group.FromCards(g) end
	local re,rr,rp=xgl.GetDisclosureReason(r)
	local c=e:GetHandler()
	local newly=Group.CreateGroup()
	local effs={}
	for tc in g:Iter() do
		local was_public=tc:IsPublic() or xgl.IsKeptPublicInHand(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|(reset or 0),rct or 1)
		local reg=tc:RegisterEffect(e1)
		e1:SetDisclosureTerm(term)
		table.insert(effs,e1)
		if not was_public and tc:IsLocation(LOCATION_HAND) and reg and not tc:IsImmuneToEffect(e1) then
			newly:AddCard(tc)
			xgl.PublicHandState[tc]=tc:GetFieldID()
		end
	end
	for p=0,1 do
		local pg=newly:Filter(Card.IsControler,nil,p)
		if #pg>0 then
			xgl.RaiseDisclosureEvent(pg,term|DISCLOSURE_PERSISTENT,re,rr,rp,p)
		end
	end
	return table.unpack(effs)
end
function Duel.RevealCardsPersistent(e,g,reset,rct,r)
	return xgl.DiscloseCardsPersistent(DISCLOSURE_REVEAL,e,g,reset,rct,r)
end

--=====================
--OFFICIAL CARDS
--=====================

DISCLOSURE_SITE_CARDS	=	0x1		--Duel.ConfirmCards
DISCLOSURE_SITE_DECKTOP	=	0x2		--Duel.ConfirmDecktop

--[[Official cards whose "reveal" is performed through the base methods.
- Key: original code of the owner of the reason effect.
- Value: the base method(s) that perform the reveal. For DISCLOSURE_SITE_CARDS, only calls that confirm the cards to the opponent of the reason player count (this excludes the "look at" calls of Evigishki Levianima and Gishki Chain).

Only the official "Gishki" cards are listed as of now]]
xgl.OfficialRevealSites={
	[72403299]	=	DISCLOSURE_SITE_DECKTOP,	--Gishki Diviner: ConfirmDecktop(tp,1)
	[66729231]	=	DISCLOSURE_SITE_CARDS,		--Gishki Zielgigas: ConfirmCards(1-tp,drawn card)
	[71203602]	=	DISCLOSURE_SITE_CARDS,		--Evigishki Levianima: ConfirmCards(1-tp,drawn card);
	[66399675]	=	DISCLOSURE_SITE_CARDS,		--Gishki Chain: ConfirmCards(1-tp,added card)
}

--Returns the DISCLOSURE_SITE_ flag with which the latest reveal was performed, along with the effect that performed the reveal
function Glitchy.GetOfficialRevealSite()
	local re=Duel.GetReasonEffect()
	if not re then return 0 end
	local owner=re:GetOwner()
	if not owner then return 0 end
	return xgl.OfficialRevealSites[owner:GetOriginalCode()] or 0, re
end
--Wrapper for Duel.ConfirmCards
function Glitchy.ConfirmCardsWrapper(p,g,...)
	local site,re=xgl.GetOfficialRevealSite()
	if site&DISCLOSURE_SITE_CARDS==0 or p~=1-Duel.GetReasonPlayer() then
		return xgl.ConfirmCardsBase(p,g,...)
	end
	local _,r,rp=xgl.GetDisclosureReason()
	xgl.ConfirmCardsBase(p,g,...)
	xgl.RaiseDisclosureEvent(g,DISCLOSURE_REVEAL,re,r,rp,1-p)
end
--Wrapper for Duel.ConfirmDecktop
function Glitchy.ConfirmDecktopWrapper(p,ct,...)
	local site,re=xgl.GetOfficialRevealSite()
	if site&DISCLOSURE_SITE_DECKTOP==0 then
		return xgl.ConfirmDecktopBase(p,ct,...)
	end
	local _,r,rp=xgl.GetDisclosureReason()
	local g=xgl.ConfirmDecktopBase(p,ct,...)
	if g and #g>0 then
		xgl.RaiseDisclosureEvent(g,DISCLOSURE_REVEAL,re,r,rp,p)
	end
	return g
end

--=====================
--WATCHER
--=====================

--Returns the EFFECT_PUBLIC effect considered responsible for a card being public (the oldest created one that applies to it)
function Glitchy.GetResponsiblePublicEffect(c)
	local eset={c:IsHasEffect(EFFECT_PUBLIC)}
	local res
	for _,pe in ipairs(eset) do
		if not res or pe:GetFieldID()<res:GetFieldID() then
			res=pe
		end
	end
	return res
end
function Glitchy.DisclosureWatcherOperation(e,tp,eg,ep,ev,re,r,rp)
	local state=xgl.PublicHandState
	local silent=not xgl.DisclosureWatcherInitialized
	xgl.DisclosureWatcherInitialized=true
	--Forget the cards that left the hand or stopped being kept public
	for c,fid in pairs(state) do
		if c:GetFieldID()~=fid or not xgl.IsKeptPublicInHand(c) then
			state[c]=nil
		end
	end
	--Collect the hand cards that became public, grouped by responsible effect (in order)
	local list={}
	for c in Duel.GetFieldGroup(0,LOCATION_HAND,LOCATION_HAND):Iter() do
		if xgl.IsKeptPublicInHand(c) and state[c]~=c:GetFieldID() then
			state[c]=c:GetFieldID()
			if not silent then
				local pe=xgl.GetResponsiblePublicEffect(c)
				local entry
				for _,v in ipairs(list) do
					if v[1]==pe then
						entry=v
						break
					end
				end
				if not entry then
					entry={pe,Group.CreateGroup()}
					table.insert(list,entry)
				end
				entry[2]:AddCard(c)
			end
		end
	end
	for _,entry in ipairs(list) do
		local pe,g=entry[1],entry[2]
		local term=pe:GetDisclosureTerm()|DISCLOSURE_PERSISTENT
		for p=0,1 do
			local pg=g:Filter(Card.IsControler,nil,p)
			if #pg>0 then
				xgl.RaiseDisclosureEvent(pg,term,pe,REASON_EFFECT,pe:GetHandlerPlayer(),p)
			end
		end
	end
end
function Glitchy.EnableDisclosureWatcher()
	if xgl.DisclosureWatcherEnabled then return end
	xgl.DisclosureWatcherEnabled=true
	Duel.ConfirmCards=xgl.ConfirmCardsWrapper
	Duel.ConfirmDecktop=xgl.ConfirmDecktopWrapper
	local ge=Effect.GlobalEffect()
	ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	ge:SetCode(EVENT_ADJUST)
	ge:SetOperation(xgl.DisclosureWatcherOperation)
	Duel.RegisterEffect(ge,0)
end