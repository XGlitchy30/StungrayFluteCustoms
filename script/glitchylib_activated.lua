--Target check constants
TGCHECK_IT 					= 0
TGCHECK_THAT_TARGET			= 1
TGCHECK_ALL_THOSE_TARGETS	= 2

--Create chkc line
function Glitchy.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,...)
	if exc and chkc==e:GetHandler() then return false end
	if f and not f(chkc,...) then return false end
	if loc1==loc2 then
		return chkc:IsLocation(loc1) 
	else
		return (chkc:IsLocation(loc1) and chkc:IsControler(tp)) or (chkc:IsLocation(loc2) and chkc:IsControler(1-tp))
	end
end

--Create check for targets at the time of resolution
function Glitchy.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,g,f,...)
	local ctchk
	if tgcheck==TGCHECK_ALL_THOSE_TARGETS then
		local ogtg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local fg=g:Filter(xgl.CreateChkc,nil,nil,tp,loc1,loc2,nil,f,...)
		return #ogtg==#fg, g
	else
		if tgcheck==TGCHECK_THAT_TARGET then
			g:Match(xgl.CreateChkc,nil,nil,tp,loc1,loc2,nil,f,...)
		end
		return #g>0, g
	end
end

--Targeting template
Glitchy.Target = aux.FunctionWithNamedArgs(
function(f,loc1,loc2,min,max,exc,extrachk,hint,extratg,extraparams)
	loc1 = loc1 or 0
	loc2 = loc2 or 0
	min = min or 1
	max = max or min
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				if chkc then return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,e,tp) end
				local x=extraparams and {extraparams(e,tp,eg,ep,ev,re,r,rp,chk)} or {}
				if chk==0 then
					return (not extrachk or extrachk(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExists(true,f,tp,loc1,loc2,min,exc,e,tp,table.unpack(x))
				end
				local g=Duel.Select(hint,true,tp,f,tp,loc1,loc2,min,max,exc,e,tp,table.unpack(x))
				if extratg then extratg(g,e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end,
"f","loc1","loc2","min","max","exc","extrachk","hint","extratg","extraparams"
)

--Draw effect template
function Glitchy.DrawTarget(p,val,ignore_chk)
	p = p and p or 0
	val=val and val or 1
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local p=p==0 and tp or 1-tp
				if chk==0 then return ignore_chk or Duel.IsPlayerCanDraw(p,val) end
				Duel.SetTargetPlayer(p)
				Duel.SetTargetParam(val)
				aux.DrawInfo(p,val)
			end
end
function Glitchy.DrawOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				Duel.Draw(p,d,REASON_EFFECT)
			end
end
function Effect.SetDrawFunctions(e,p,val,ignore_chk)
	e:SetTarget(xgl.DrawTarget(p,val,ignore_chk))
	e:SetOperation(xgl.DrawOperation())
end

--Search effect templates: Add N card(s) from LOCATION to your hand
function Glitchy.SearchTarget(f,loc,min,exc)
	f=xgl.SearchFilter(f)
	loc=loc or LOCATION_DECK
	min=min or 1
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local exc=exc and e:GetHandler() or nil
					return Duel.IsExistingMatchingCard(f,tp,loc,0,min,exc,e,tp)
				end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
			end
end
function Glitchy.SearchOperation(f,loc,min,max,exc)
	loc=loc or LOCATION_DECK
	f=xgl.SearchFilter(f)
	if loc&LOCATION_GRAVE>0 then
		f=aux.NecroValleyFilter(f)
	end
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=exc and e:GetHandler() or nil
				local g=Duel.Select(HINTMSG_ATOHAND,false,tp,f,tp,loc,0,min,max,exc,e,tp)
				if #g>0 then
					Duel.Search(g)
				end
			end
end
function Effect.SetSearchFunctions(e,f,loc,min,max,exc)
	e:SetTarget(xgl.SearchTarget(f,loc,min,exc))
	e:SetOperation(xgl.SearchOperation(f,loc,min,max,exc))
end

--Special Summon effect template
function Glitchy.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)
			end
end
function Glitchy.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and Duel.GetLocationCountFromEx(sump,recp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)
			end
end
function Glitchy.SpecialSummonFilterX(ftcheck,f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				if not ((not f or f(c,e,tp)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)) then return false end
				local edchk=c:IsInExtra()
				if edchk then
					return Duel.GetLocationCountFromEx(sump,recp,nil,c)>0
				else
					return ftcheck
				end
			end
end
function Glitchy.SpecialSummonTarget(tgchk,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	sumtype=sumtype or 0
	pos=pos or POS_FACEUP
	if ignore_sumcon==nil then ignore_sumcon=false end
	if ignore_revlim==nil then ignore_revlim=false end
	local locs=loc1|loc2
	local EDchk=locs&LOCATION_EXTRA>0
	local minchk=min==1
	if not tgchk then
		if not EDchk then
			return	function(e,tp,eg,ep,ev,re,r,rp,chk)
						local exc=exc and e:GetHandler() or nil
						local sump=IsOpponentSummons and 1-tp or tp
						local recp=IsOpponentReceives and 1-tp or tp
						if chk==0 then
							if min>1 and Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) then return false end
							local ft=Duel.GetMZoneCount(sump,nil,recp)
							return ft>=min and Duel.IsExists(false,xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
						end
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
					end
		elseif minchk then
			if locs==LOCATION_EXTRA then
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							if chk==0 then
								return Duel.IsExists(false,xgl.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
							end
							local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
						end
			else
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							if chk==0 then
								local ft=Duel.GetMZoneCount(sump,nil,recp)
								return Duel.IsExists(false,xgl.SpecialSummonFilterX(ft>0,f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
							end
							local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
						end
			end
		end
	
	elseif tgchk and not edchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					local sump=IsOpponentSummons and 1-tp or tp
					local recp=IsOpponentReceives and 1-tp or tp
					local spf=xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,spf,e,tp)
					end
					local ft=Duel.GetMZoneCount(sump,nil,recp)
					if chk==0 then
						if min>1 and Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) then return false end
						return ft>=min and Duel.IsExists(true,spf,tp,loc1,loc2,min,exc,e,tp)
					end
					local maxc=Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) and 1 or math.min(max,ft)
					local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
					if #g>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
					else
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
					end
				end
	end
end

function Glitchy.SpecialSummonOperation(spmod,tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos)
	local spfunc,spparams=nil,{}
	if type(f)=="number" then
		
		tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos = spmod,tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim
		
		spmod=nil
	else
		if type(spmod)=="table" then
			spfunc=spmod[1]
			if #spmod>=2 then
				for i=2,#spmod do
					table.insert(spparams,spmod[i])
				end
			end
		else
			spfunc=spmod
		end
	end
	
	if not loc1 and not loc2 then Debug.Message("Undefined locations when calling Glitchy.SpecialSummonOperation") return end
	loc1=loc1 or 0
	loc2=loc2 or 0
	sumtype=sumtype or 0
	pos=pos or POS_FACEUP
	if ignore_sumcon==nil then ignore_sumcon=false end
	if ignore_revlim==nil then ignore_revlim=false end
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		local EDchk=locs&LOCATION_EXTRA>0
		local minchk = min==1 and max==1
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		if not EDchk then
			return	function(e,tp,eg,ep,ev,re,r,rp)
						local exc=exc and e:GetHandler() or nil
						local sump=IsOpponentSummons and 1-tp or tp
						local recp=IsOpponentReceives and 1-tp or tp
						local ft=Duel.GetMZoneCount(sump,nil,recp)
						if ft<=0 then return end
						local blue_eyes_spirit_check=Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT)
						if min>1 and blue_eyes_spirit_check then return false end
						local maxc=blue_eyes_spirit_check and 1 or math.min(max,ft)
						local spf=xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
						local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
						if #g>=min then
							if not spmod then
								Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							else
								spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
							end
						end
					end
					
		elseif minchk then
			if locs==LOCATION_EXTRA then
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							local spf=xgl.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,max,exc,e,tp)
							if #g>=min then
								if not spmod then
									Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
								else
									spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
								end
							end
						end
			else
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							local ft=Duel.GetMZoneCount(sump,nil,recp)
							local spf=xgl.SpecialSummonFilterX(ft>0,f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,max,exc,e,tp)
							if #g>=min then
								if not spmod then
									Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
								else
									spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
								end
							end
						end
			end
		end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local sump=IsOpponentSummons and 1-tp or tp
					local recp=IsOpponentReceives and 1-tp or tp
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						if not spmod then
							Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
						else
							spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
						end
					end
				end
	end
end

function Effect.SetSpecialSummonFunctions(e,spmod,tgchk,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos)
	e:SetTarget(xgl.SpecialSummonTarget(tgchk,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos))
	e:SetOperation(xgl.SpecialSummonOperation(spmod,tgchk,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos))
end

--Sendto template: Move a card(s) from a location to another
Glitchy.SendtoFilters={
	[LOCATION_DECK]=xgl.ToDeckFilter;
	[LOCATION_GRAVE]=xgl.ToGraveFilter;
	[LOCATION_HAND]=xgl.SearchFilter;
	[LOCATION_REMOVED]=xgl.BanishFilter;
	[LOCATION_EXTRA]=xgl.ToExtraPFilter;
}
Glitchy.SendtoHints={
	[0]=HINTMSG_DESTROY;
	[LOCATION_DECK]=HINTMSG_TODECK;
	[LOCATION_GRAVE]=HINTMSG_TOGRAVE;
	[LOCATION_HAND]=HINTMSG_RTOHAND;
	[LOCATION_REMOVED]=HINTMSG_REMOVE;
	[LOCATION_EXTRA]=HINTMSG_TOEXTRA;
}
Glitchy.SendtoCategories={
	[0]=CATEGORY_DESTROY;
	[LOCATION_DECK]=CATEGORY_TODECK;
	[LOCATION_GRAVE]=CATEGORY_TOGRAVE;
	[LOCATION_HAND]=CATEGORY_TOHAND;
	[LOCATION_REMOVED]=CATEGORY_REMOVE;
	[LOCATION_EXTRA]=CATEGORY_TOEXTRA;
}
Glitchy.SendtoActions={
	[0]=function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end;
	[LOCATION_DECK]=function(g,e,tp,seq,p)
		seq=seq and seq or SEQ_DECKSHUFFLE
		Duel.SendtoDeck(g,p,seq,REASON_EFFECT)
	end;
	[LOCATION_GRAVE]=function(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end;
	[LOCATION_HAND]=function(g,e,tp,p)
		Duel.SendtoHand(g,p,REASON_EFFECT)
	end;
	[LOCATION_REMOVED]=function(g,e,tp,pos)
		Duel.Remove(g,pos,REASON_EFFECT)
	end;
	[LOCATION_EXTRA]=function(g,e,tp)
		Duel.SendtoExtraP(g,tp,REASON_EFFECT)
	end;
}
function Glitchy.SendtoAuxiliaryFunction(destination,f,...)
	local destf=destination==0 and f or xgl.SendtoFilters[destination](f,false,...)
	local hint=xgl.SendtoHints[destination]
	local category=xgl.SendtoCategories[destination]
	local action=xgl.SendtoActions[destination]
	return destf,hint,category,action
end
function Glitchy.SendtoTarget(destination,tgchk,f,loc1,loc2,min,max,exc,...)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	local locs=loc1|loc2
	local f,hint,category=xgl.SendtoAuxiliaryFunction(destination,f,...)
	if not tgchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=exc and e:GetHandler() or nil
					if chk==0 then
						return Duel.IsExists(false,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
					Duel.SetOperationInfo(0,category,nil,min,players,locs)
				end
	
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,e,tp)
					end
					if chk==0 then
						return Duel.IsExists(true,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local g=Duel.Select(hint,true,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						Duel.SetOperationInfo(0,category,g,#g,0,0)
					else
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,category,nil,min,players,locs)
					end
				end
	end
end

function Glitchy.SendtoOperation(destination,tgcheck,f,loc1,loc2,min,max,exc,...)
	local extras={...}
	loc1=loc1 or 0
	loc2=loc2 or 0
	local f,hint,_,CardActionFunction=xgl.SendtoAuxiliaryFunction(destination,f,...)
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=exc and e:GetHandler() or nil
					local g=Duel.Select(hint,false,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>=min then
						Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED))
						CardActionFunction(g,e,tp,table.unpack(extras))
					end
				end
					
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						CardActionFunction(g,e,tp,table.unpack(extras))
					end
				end
	end
end

function Effect.SetSendtoFunctions(e,destination,tgcheck,f,loc1,loc2,min,max,exc,...)
	e:SetTarget(xgl.SendtoTarget(destination,tgcheck,f,loc1,loc2,min,max,exc,...))
	e:SetOperation(xgl.SendtoOperation(destination,tgcheck,f,loc1,loc2,min,max,exc,...))
end

--Template for effects that Set (min to max) Spells/Traps (that match the filter f, excluding exc) from locations (loc1,loc2)
function Glitchy.SSetTarget(tgchk,f,loc1,loc2,min,max,exc)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	local locs=loc1|loc2
	f=xgl.SSetFilter(f)
	if not tgchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=exc and e:GetHandler() or nil
					if chk==0 then
						return Duel.IsExists(false,f,tp,loc1,loc2,min,exc,e,tp)
					end
					if locs==LOCATION_GRAVE then
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,min,players,0)
					end
				end
	
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,e,tp)
					end
					if chk==0 then
						return Duel.IsExists(true,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local g=Duel.Select(HINTMSG_SET,true,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					local tg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
					if #tg>0 then
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
					elseif locs==LOCATION_GRAVE then
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,min,players,0)
					end
				end
	end
end

function Glitchy.SSetOperation(setmod,tgcheck,f,loc1,loc2,min,max,exc)
	if not loc1 and not loc2 then Debug.Message("Undefined locations when calling Glitchy.SSetOperation") return end
	loc1=loc1 or 0
	loc2=loc2 or 0
	local setfunc,setparams=nil,{}
	if type(f)=="number" then
		tgcheck,f,loc1,loc2,min,max,exc = setmod,tgcheck,f,loc1,loc2,min,max
		setmod=nil
	else
		if type(setmod)=="table" then
			setfunc=setmod[1]
			if #setmod>=2 then
				for i=2,#setmod do
					table.insert(setparams,setmod[i])
				end
			end
		else
			setfunc=setmod
		end
	end
	f=xgl.SSetFilter(f)
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=exc and e:GetHandler() or nil
					local g=Duel.Select(HINTMSG_SET,false,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>=min then
						if not setmod then
							Duel.SSet(tp,g)
						else
							setmod(tp,g,e,table.unpack(setparams))
						end
					end
				end
					
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						if not setmod then
							Duel.SSet(tp,g)
						else
							setmod(tp,g,e,table.unpack(setparams))
						end
					end
				end
	end
end
function Effect.SetSSetFunctions(e,setmod,tgcheck,f,loc1,loc2,min,max,exc)
	e:SetTarget(xgl.SSetTarget(tgcheck,f,loc1,loc2,min,max,exc))
	e:SetOperation(xgl.SSetOperation(setmod,tgcheck,f,loc1,loc2,min,max,exc))
end

--Self action templates

--Special Summon "this card"
--[[Parameters
1) handlecost = If true, cost already handles the MZone check
2) redirect = Redirect the card to the specified location when it leaves the field
]]
function Glitchy.SpecialSummonSelfTarget(handlecost)
	if handlecost then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						local isCostChecked = e:GetLabel()==1
						e:SetLabel(0)
						return (isCostChecked or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
					end
					e:SetLabel(0)
					Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
					end
					Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
				end
	end
end
function Glitchy.SpecialSummonSelfOperation(redirect)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsRelateToChain() then
					if redirect then
						Duel.SpecialSummonRedirect(redirect,e,c,0,tp,tp,false,false,POS_FACEUP)
					else
						Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
end
function Effect.SetSpecialSummonSelfFunctions(e,handlecost,redirect)
	e:SetTarget(xgl.SpecialSummonSelfTarget(handlecost))
	e:SetOperation(xgl.SpecialSummonSelfOperation(redirect))
end

--Add "this card" to hand
function Glitchy.ToHandSelfTarget()
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then
					return c:IsAbleToHand()
				end
				Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
			end
end
function Glitchy.ToHandSelfOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsRelateToChain() then
					Duel.Search(c)
				end
			end
end
function Effect.SetToHandSelfFunctions(e)
	e:SetTarget(xgl.ToHandSelfTarget())
	e:SetOperation(xgl.ToHandSelfOperation())
end