Glitchy=Glitchy or {}
xgl=Glitchy

Duel.LoadScript("glitchylib_new.lua")

self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = nil, nil, nil, nil, nil, nil, nil, nil, nil

CHK_ANCESTAGON_PLASMATAIL				=	130000138

--
local _RegisterEffect = Card.RegisterEffect

local function IsEffectCode(code0,...)
	local x={...}
	for _,code in ipairs(x) do
		if code0==code then
			return true
		end
	end
	return false
end

local function IsPassiveEffect(type)
	local types={EFFECT_TYPE_SINGLE,EFFECT_TYPE_EQUIP,EFFECT_TYPE_TARGET,EFFECT_TYPE_XMATERIAL,EFFECT_TYPE_FIELD}
	for _,t in ipairs(types) do
		if type==t then
			return true
		end
	end
	return false
end


function Card.RegisterEffect(c,eff,...)
	local e=eff
	if e:IsHasType(EFFECT_TYPE_GRANT) then
		e=e:GetLabelObject()
	end
	local typ,prop,code,cond,val=e:GetType(),e:GetProperty(),e:GetCode(),e:GetCondition(),e:GetValue()
	
	local isPassive = IsPassiveEffect(typ)
	local isHasExceptionType = typ==EFFECT_TYPE_XMATERIAL or typ==EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD or typ&EFFECT_TYPE_GRANT~=0
	
	if isPassive and typ~=EFFECT_TYPE_SINGLE then
	
		if IsEffectCode(code,EFFECT_SPSUMMON_PROC) and eff:GetRange()&LOCATION_EXTRA>0 then
			--[[Implement EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED for inherent SS procedures from the ED]]
			
			local op=eff:GetOperation()
			local new_op = 	function(_e,tp,eg,_ep,ev,re,r,rp,c)
								if c:IsLocation(LOCATION_EXTRA) then
									local e1,e2
									local eset={Duel.GetPlayerEffect(tp,EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)}
									local descs,validEffs={},{}
									for _,e in ipairs(eset) do
										local tg=e:GetTarget()
										if not tg or tg(e,c) then
											table.insert(descs,e:GetDescription())
											table.insert(validEffs,e)
										end
									end
									local mr3_eff
									local ct=#validEffs
									if ct>0 then
										local opt=Duel.SelectOption(tp,STRING_DO_NOT_APPLY,table.unpack(descs))
										if opt>0 then
											mr3_eff=validEffs[opt]
										end
									end
									
									if mr3_eff then
										local ep=mr3_eff:GetOwnerPlayer()
										local zones=mr3_eff:GetValue()
										if tp==1-ep then
											zones=zones>>16
										end
										zones=zones&0x7f
										e1=Effect.GlobalEffect()
										e1:SetType(EFFECT_TYPE_FIELD)
										e1:SetProperty(EFFECT_FLAG_OATH)
										e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
										e1:SetValue(zones)
										Duel.RegisterEffect(e1,ep)
										e2=Effect.GlobalEffect()
										e2:SetType(EFFECT_TYPE_FIELD)
										e2:SetCode(EFFECT_FORCE_MZONE)
										e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH)
										e2:SetTargetRange(1,0)
										e2:SetValue(zones)
										Duel.RegisterEffect(e2,tp)
										
										local op=mr3_eff:GetOperation()
										if op then
											op(mr3_eff,ep,c)
										end
										
										if e1 then
											xgl.RegisterResetAfterSpecialSummonRule(c,tp,e1,e2)
										end
									end
									
								end
							end
			
			if op then
				eff:SetOperation(function(e,tp,eg,ep,ev,re,r,rp,c)
					new_op(e,tp,eg,ep,ev,re,r,rp,c)
					op(e,tp,eg,ep,ev,re,r,rp,c)
				end
				)
			else
				eff:SetOperation(new_op)
			end
	
		elseif IsEffectCode(code,EFFECT_SPSUMMON_PROC_G) then
			--[["Lazy" implementation for EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED into the Pendulum Summoning procedures (this method does not force me to modify the scripts of all cards that perform a Pendulum Summon immediately after their effect's resolution and/or that grant additional Pendulum Summons)]]
		
			local op=eff:GetOperation()
			
			eff:SetOperation(function(_e,tp,eg,_ep,ev,re,r,rp,c,sg,inchain)
				local ok = true
				
				while ok do
					op(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
					ok=false
					
					local eset={Duel.GetPlayerEffect(tp,EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)}
					if #sg*#eset==0 then return end
						
					local validAssignments = xgl.GetZoneAssignmentsForGroup(sg,tp,tp)
					
					--LEAVE FOR DEBUG PURPOSES
					-- for i, assign in ipairs(validAssignments) do
						-- Debug.Message("Option #"..i)
						-- for card, zone in pairs(assign) do
							-- Debug.Message("  "..card:GetOriginalCode().." → 0x"..string.format("%X", zone))
						-- end
					-- end
					
					if #validAssignments==0 then
						sg:Clear()
						Debug.Message("Glitchy warns: you selected an invalid group of cards for Pendulum Summon. Please try again")
						ok=true
					else
					
						local tempDisableEffs,alreadyChosen,ogct={},{},0
						
						for tc in sg:Iter() do
							
							if not tc:IsLocation(LOCATION_EXTRA) then
								local z = 0x7f & ~(select(2, Duel.GetLocationCount(tp, LOCATION_MZONE)))
								alreadyChosen[tc]=z
							else
								local validZones = 0
								for _,tab in ipairs(validAssignments) do
									local z=tab[tc]
									local ct,goal=0,0
									for c,cz in pairs(tab) do
										if alreadyChosen[c] then
											goal=goal+1
											if alreadyChosen[c]&cz>0 then
												ct=ct+1
											end
										end
									end
									if ct==goal then
										validZones = validZones|z
									end
								end
								
								
								local e1,e2
								local descs,validEffs={},{}
								for _,e in ipairs(eset) do
									local tg=e:GetTarget()
									local zones=e:Evaluate(tc)
									if (not tg or tg(e,tc)) and validZones&zones>0 then
										table.insert(descs,e:GetDescription())
										table.insert(validEffs,e)
									end
								end
								local mr3_eff
								local ct=#validEffs
								
								if ct>0 then
									Duel.ConfirmCards(tp,tc)
									if Duel.GetOriginalLocationCountFromEx(tp,tp,nil,tc)-ogct<=0 then
										local opt=Duel.SelectOption(tp,table.unpack(descs))
										mr3_eff=validEffs[opt+1]
									else
										local opt=Duel.SelectOption(tp,STRING_DO_NOT_APPLY,table.unpack(descs))
										if opt>0 then
											mr3_eff=validEffs[opt]
										end
									end
								end
								
								if mr3_eff then
									local ep=mr3_eff:GetOwnerPlayer()
									local zones=mr3_eff:Evaluate(tc)
									if tp==1-ep then
										zones=zones>>16
									end
									zones=zones&validZones
									alreadyChosen[tc]=zones
									e1=Effect.GlobalEffect()
									e1:SetType(EFFECT_TYPE_FIELD)
									e1:SetProperty(EFFECT_FLAG_OATH)
									e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
									e1:SetValue(zones)
									Duel.RegisterEffect(e1,ep)
									table.insert(tempDisableEffs,e1)
									
									e2=Effect.CreateEffect(tc)
									e2:SetType(EFFECT_TYPE_SINGLE)
									e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_OATH)
									e2:SetCode(EFFECT_FORCE_MZONE)
									e2:SetValue(zones)
									e2:SetReset(RESET_EVENT|RESETS_STANDARD)
									tc:RegisterEffect(e2)
									
									local op=mr3_eff:GetOperation()
									if op then
										if not xgl.MR3SpSummonEffectOperation[mr3_eff] then
											xgl.MR3SpSummonEffectOperation[mr3_eff]={op,tp,tp,tc}
										end
									end
									
									if e1 then
										xgl.RegisterResetAfterSpecialSummonRule(tc,tp,e1)
									end
									
								elseif ct>0 then
									ogct = ogct+1
									for _,tde in ipairs(tempDisableEffs) do
										tde:SetCondition(aux.FALSE)
									end
									local _,zones=Duel.GetOriginalLocationCountFromEx(tp,tp,nil,tc)
									for _,tde in ipairs(tempDisableEffs) do
										tde:SetCondition(aux.TRUE)
									end
									
									local z=(~zones)&0x7f
									alreadyChosen[tc]=z
									
									e2=Effect.CreateEffect(tc)
									e2:SetType(EFFECT_TYPE_SINGLE)
									e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_OATH)
									e2:SetCode(EFFECT_FORCE_MZONE)
									e2:SetValue(z)
									e2:SetReset(RESET_EVENT|RESETS_STANDARD)
									tc:RegisterEffect(e2)
								end
							end
						end
						
						local e0=Effect.GlobalEffect()
						e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
						e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
						e0:SetCode(EVENT_SPSUMMON)
						e0:SetOperation(function(_e)
							for mr3eff,tab in pairs(xgl.MR3SpSummonEffectOperation) do
								local op,_ep,up,tc=table.unpack(tab)
								op(mr3eff,_ep,up,tc)
							end
							xgl.ClearTableRecursive(xgl.MR3SpSummonEffectOperation)
							_e:Reset()
						end
						)
						Duel.RegisterEffect(e0,tp)
					end
				end
			end
			)
		
		elseif IsEffectCode(code,EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE) and not aux.BaseStatsModCheck then
			--[[Fix interaction between continuous original stats modifiers and lingering current+original stats modifiers (both activated and non): for example, if Shrink's effect is applied to a monster and Unstable Evolution is later equipped to that monster, the original ATK of that monster should be determined by the effect of Unstable Evolution. Currently, EDOPro applies the effects in an incorrect order, which means that Unstable Evolution's modifier is overwritten by the one of Shrink, even if the former was applied strictly after the latter. The interaction between Darkworld Shackles and Shrink is also problematic, as the ATK of a monster affected by Shackles is supposed to remain unchanged even after Shrink is applied to it.
			REMOVE THIS CODE ONLY AFTER THE BUG IS FIXED IN THE CORE]]
		
			aux.BaseStatsModCheck=true
			local ge=Effect.CreateEffect(c)
			ge:SetType(EFFECT_TYPE_FIELD)
			ge:SetCode(EFFECT_SET_ATTACK_FINAL)
			ge:SetProperty(EFFECT_FLAG_REPEAT|EFFECT_FLAG_DELAY)
			ge:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			ge:SetLabel(EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE)
			ge:SetTarget(function(E,C)
				aux.PreventBaseStatsModLoop=true
				local elist={C:IsHasEffect(EFFECT_SET_BASE_ATTACK)}
				aux.PreventBaseStatsModLoop=false
				for _,eff in ipairs(elist) do
					if eff:GetType()~=EFFECT_TYPE_SINGLE then
						return true
					end
				end
				
				return false
			end)
			ge:SetValue(function(E,C)
				return C:GetAttack()
			end)
			Duel.RegisterEffect(ge,0)
			local ge2=Effect.CreateEffect(c)
			ge2:SetType(EFFECT_TYPE_FIELD)
			ge2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			ge2:SetProperty(EFFECT_FLAG_REPEAT|EFFECT_FLAG_DELAY)
			ge2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			ge2:SetLabel(EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE)
			ge2:SetTarget(function(E,C)
				aux.PreventBaseStatsModLoop=true
				local elist={C:IsHasEffect(EFFECT_SET_BASE_DEFENSE)}
				aux.PreventBaseStatsModLoop=false
				for _,eff in ipairs(elist) do
					if eff:GetType()~=EFFECT_TYPE_SINGLE then
						return true
					end
				end
				
				return false
			end)
			ge2:SetValue(function(E,C)
				return C:GetDefense()
			end)
			Duel.RegisterEffect(ge2,0)
		end
	
	elseif not isPassive then
		local condition,cost,tg,op,val = e:GetCondition(),e:GetCost(),e:GetTarget(),e:GetOperation(),e:GetValue()
		
		if cost and not isHasExceptionType then
			local newcost =	function(...)
								local x={...}
								local e,tp,eg,ep,ev,re,r,rp,chk,chkc = table.unpack(x)
								
								local previous_state = {self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk}
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(x)
								
								-- if #x>=9 and chk~=0 and (#x<10 or not chkc) and not cost then
									-- Duel.RaiseEvent(e:GetHandler(),EVENT_CHAIN_CREATED,e,0,tp,tp,Duel.GetCurrentChain())
								-- end
								
								e:SetCostChecked(true)
								local res=cost(table.unpack(x))
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(previous_state)

								return res
								
							end
			e:SetCost(newcost)
		end
		
		if tg and not isHasExceptionType then
			local newtg =	function(...)
								local x={...}
								local e,tp,eg,ep,ev,re,r,rp,chk,chkc = table.unpack(x)
								
								local previous_state = {self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk}
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(x)
								
								-- if #x>=9 and chk~=0 and (#x<10 or not chkc) and not cost then
									-- Duel.RaiseEvent(e:GetHandler(),EVENT_CHAIN_CREATED,e,0,tp,tp,Duel.GetCurrentChain())
								-- end
								
								local res=tg(table.unpack(x))
								e:SetCostChecked(false)
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(previous_state)
								
								if xgl.TargetParamsTable and xgl.TargetParamsTable[e] then
									xgl.ClearTableRecursive(xgl.TargetParamsTable[e])
								end
								
								if chk==CHK_ANCESTAGON_PLASMATAIL then
									res=xgl.CopyTable(xgl.AncestagonPlasmatailReturns)
									xgl.ClearTable(xgl.AncestagonPlasmatailReturns)
								end
								return res
								
							end
			e:SetTarget(newtg)
		end
	
		if op and not isHasExceptionType then
			local newop =	function(...)
								local x={...}
								local e,tp,eg,ep,ev,re,r,rp,chk,chkc = table.unpack(x)
								
								local previous_state = {self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk}
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(x)
								
								-- if #x>=9 and chk~=0 and (#x<10 or not chkc) and not cost then
									-- Duel.RaiseEvent(e:GetHandler(),EVENT_CHAIN_CREATED,e,0,tp,tp,Duel.GetCurrentChain())
								-- end
								
								local res=op(table.unpack(x))
								
								self_reference_effect, last_tp, last_eg, last_ep, last_ev, last_re, last_r, last_rp, last_chk = table.unpack(previous_state)
								
								
								return res
								
							end
			e:SetOperation(newop)
			
		end
	end
	
	local res=_RegisterEffect(c,eff,...)
	
	return res
end

--PROCEDURE FOR CUSTOMS THAT REPLACE OFFICIAL CARDS AT THE START OF THE GAME (e.g: Numbers Revolution)
--Must be called in aux.GlobalCheck
--modcodes is an array formatted like this: {[officialID1]=replacementID1; [officialID2]=replacementID2; ...}
function Glitchy.ReplaceOfficialCards(modcodes)
	return	function()
				local ge1=Effect.GlobalEffect()
				ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				ge1:SetCode(EVENT_STARTUP)
				ge1:SetOperation(Glitchy.ReplaceOfficialCardsOperation(modcodes))
				Duel.RegisterEffect(ge1,0)
			end
end
local function IsOfficialCardToReplace(c,modcodes)
	return modcodes[c:GetOriginalCode()]
end
function Glitchy.ReplaceOfficialCardsOperation(modcodes)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if Duel.GetPlayersCount(0)*Duel.GetPlayersCount(1)~=1 and not Duel.IsDuelType(DUEL_RELAY) then
					local pcount=0
					for p=0,1 do
						local pct=Duel.GetPlayersCount(p)
						for i=1,pct do
							local g=Duel.GetMatchingGroup(IsOfficialCardToReplace,p,LOCATION_ALL,0,nil,modcodes)
							for tc in g:Iter() do
								local code=tc:GetOriginalCode()
								local modcode=modcodes[code]
								tc:Recreate(modcode,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
							end
							if pct>1 then
								Duel.TagSwap(p)
							end
						end
					end
					
				else
					local g=Duel.GetMatchingGroup(IsOfficialCardToReplace,0,LOCATION_ALL,LOCATION_ALL,nil,modcodes)
					for tc in g:Iter() do
						local code=tc:GetOriginalCode()
						local modcode=modcodes[code]
						tc:Recreate(modcode,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
					end
				end
			end
end

--PROCEDURE TO ADD OFFICIAL CARDS TO A CUSTOM ARCHETYPE (e.g: Inversion of Nature)
--Must be called in aux.GlobalCheck
--modcodes is an array formatted like this: {[officialID1]=replacementID1; [officialID2]=replacementID2; ...}
function Glitchy.AddArchetypeToOfficialCards(setc,modcodes)
	return	function()
				local ge1=Effect.GlobalEffect()
				ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				ge1:SetCode(EVENT_STARTUP)
				ge1:SetOperation(Glitchy.AddArchetypeToOfficialCardsOperation(setc,modcodes))
				Duel.RegisterEffect(ge1,0)
			end
end
function Glitchy.AddArchetypeToOfficialCardsOperation(setc,modcodes)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if Duel.GetPlayersCount(0)*Duel.GetPlayersCount(1)~=1 and not Duel.IsDuelType(DUEL_RELAY) then
					for p=0,1 do
						local pct=Duel.GetPlayersCount(p)
						for i=1,pct do
							local g=Duel.GetMatchingGroup(IsOfficialCardToReplace,p,LOCATION_ALL,0,nil,modcodes)
							for tc in g:Iter() do
								local code=tc:GetOriginalCode()
								tc:Recreate(code,nil,setc,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
							end
							if pct>1 then
								Duel.TagSwap(p)
							end
						end
					end
					
				else
					local g=Duel.GetMatchingGroup(IsOfficialCardToReplace,0,LOCATION_ALL,LOCATION_ALL,nil,modcodes)
					for tc in g:Iter() do
						local code=tc:GetOriginalCode()
						tc:Recreate(code,nil,setc,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
					end
				end
			end
end

--FIX FOR INCORRECT HANDLING OF CONTINUOUS EFFECTS THAT CHANGE ORIGINAL ATK/DEF
local _GetBaseAttack,_GetBaseDefense,_GetAttack,_GetDefense = Card.GetBaseAttack,Card.GetBaseDefense,Card.GetAttack,Card.GetDefense

aux.TempBaseAttack=math.maxinteger
aux.TempBaseDefense=math.maxinteger
aux.TempAttack=math.maxinteger
aux.TempDefense=math.maxinteger

function Auxiliary.CheckBaseStatsModCondition(c,ignore_linkchk)
	local ecodes={EFFECT_SET_BASE_ATTACK}
	if ignore_linkchk or not c:IsOriginalType(TYPE_LINK) then
		table.insert(ecodes,EFFECT_SET_BASE_DEFENSE)
	end
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			if e:GetType()~=EFFECT_TYPE_SINGLE then
				return true
			end
		end
	end
	
	return false
end

function Card.GetBaseAttack(c)
	if not aux.CheckBaseStatsModCondition(c) then
		return _GetBaseAttack(c)
	end
	
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonsterType() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempBaseAttack~=math.maxinteger then
		return aux.TempBaseAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseAttack=batk
	
	local swap=false
	if not c:IsOriginalType(TYPE_LINK) and c:IsHasEffect(EFFECT_SWAP_BASE_AD) then
		swap=true
	end
	local ecode=swap and EFFECT_SET_BASE_DEFENSE or EFFECT_SET_BASE_ATTACK
	local eset={c:IsHasEffect(ecode)}
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	xgl.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				aux.TempBaseAttack=batk
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				return false
			end
		end
		return true
	end)
	
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		if code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		aux.TempBaseAttack=batk
	end
	
	aux.TempBaseAttack=math.maxinteger
	return batk
end
function Card.GetBaseDefense(c)
	if not aux.CheckBaseStatsModCondition(c,true) then
		return _GetBaseDefense(c)
	end
	if c:IsOriginalType(TYPE_LINK) or (not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonsterType() and not c:IsHasEffect(EFFECT_PRE_MONSTER)) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextDefense()
	end
	if aux.TempBaseDefense~=math.maxinteger then
		return aux.TempBaseDefense
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseDefense=bdef
	
	local swap=false
	if not c:IsOriginalType(TYPE_LINK) and c:IsHasEffect(EFFECT_SWAP_BASE_AD) then
		swap=true
	end
	local ecode=swap and EFFECT_SET_BASE_ATTACK or EFFECT_SET_BASE_DEFENSE
	local eset={c:IsHasEffect(ecode)}
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	xgl.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				aux.TempBaseDefense=bdef
				return false
			end
		end
		return true
	end)
	
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		if code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		aux.TempBaseDefense=bdef
	end
	
	aux.TempBaseDefense=math.maxinteger
	return bdef
end

function Card.GetAttack(c)
	if not aux.CheckBaseStatsModCondition(c) then
		return _GetAttack(c)
	end
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonsterType() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempAttack~=math.maxinteger then
		return aux.TempAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseAttack=batk
	aux.TempAttack=batk
	
	local atk=-1
	local up_atk,upc_atk=0,0
	local swap_final=false
	
	local eset={}
	local ecodes={EFFECT_UPDATE_ATTACK,EFFECT_SET_ATTACK,EFFECT_SET_ATTACK_FINAL,EFFECT_SWAP_ATTACK_FINAL,EFFECT_SET_BASE_ATTACK}
	if not c:IsOriginalType(TYPE_LINK) then
		table.insert(ecodes,EFFECT_SWAP_AD)
		table.insert(ecodes,EFFECT_SWAP_BASE_AD)
		table.insert(ecodes,EFFECT_SET_BASE_DEFENSE)
	end
	
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			local l1,l2=e:GetLabel()
			if ecode~=EFFECT_SET_ATTACK_FINAL or (l1~=EFFECT_SET_BASE_ATTACK and l2~=EFFECT_SET_BASE_DEFENSE) then
				table.insert(eset,e)
			end
		end
	end
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	local rev=false
	local revset={c:IsHasEffect(EFFECT_REVERSE_UPDATE)}
	for _,e in ipairs(revset) do
		if not e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) or not c:IsImmuneToEffect(e) then
			rev=true
			break
		end
	end
	
	local effects_atk,effects_atk_r={},{}
	
	xgl.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				aux.TempBaseAttack=batk
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				return false
			end
		end
		return true
	end)
	
	aux.TempAttack=batk
	
	local hasActivatedSetStatFinalEffect=false
	local hasContinuousSetStatEffect=false
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		local isSingle=eff:IsHasType(EFFECT_TYPE_SINGLE)
		local HasSingleRange=eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
		local val=eff:Evaluate(c)
		if code==EFFECT_UPDATE_ATTACK then
			if isSingle and not HasSingleRange then
				up_atk = up_atk+val
			else
				upc_atk = upc_atk+val
			end
			
		elseif code==EFFECT_SET_ATTACK then
			atk=val
			if not isSingle or HasSingleRange then
				if not isSingle then
					up_atk=0
				end
				hasContinuousSetStatEffect=true
			end
		
		elseif code==EFFECT_SET_ATTACK_FINAL then
			if isSingle and not HasSingleRange then
				hasActivatedSetStatFinalEffect=true
				atk=val
				up_atk,upc_atk=0,0
			else
				if not eff:IsHasProperty(EFFECT_FLAG_DELAY) then
					table.insert(effects_atk,eff)
				else
					table.insert(effects_atk_r,eff)
				end
			end
			
		elseif code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(val,0)
			if not hasActivatedSetStatFinalEffect and not hasContinuousSetStatEffect then
				atk=-1
			end
		
		elseif code==EFFECT_SWAP_ATTACK_FINAL then
			atk=val
			up_atk,upc_atk=0,0
			
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(val,0)
			
		elseif code==EFFECT_SWAP_AD then
			swap_final = not swap_final
			
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		
		aux.TempBaseAttack=batk
		aux.TempAttack = math.max(0,(atk<0 and batk or atk) + (up_atk + upc_atk)*(not rev and 1 or -1))
	end
	
	for _,eff in ipairs(effects_atk) do
		aux.TempAttack=eff:Evaluate(c)
	end
	
	if aux.TempDefense==math.maxinteger then
		if swap_final then
			aux.TempAttack=c:GetDefense()
		end
		for _,eff in ipairs(effects_atk_r) do
			aux.TempAttack=eff:Evaluate(c)
			if eff:IsHasProperty(EFFECT_FLAG_REPEAT) then
				aux.TempAttack=eff:Evaluate(c)
			end
		end
	end
	
	atk = math.max(0,aux.TempAttack)
	
	aux.TempBaseAttack=math.maxinteger
	aux.TempAttack=math.maxinteger
	return atk 
end

function Card.GetDefense(c)
	if not aux.CheckBaseStatsModCondition(c,true) then
		return _GetDefense(c)
	end
	if c:IsOriginalType(TYPE_LINK) then
		return 0
	end
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonsterType() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempAttack~=math.maxinteger then
		return aux.TempAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseDefense=bdef
	aux.TempDefense=bdef
	
	local def=-1
	local up_def,upc_def=0,0
	local swap_final=false
	
	local eset={}
	local ecodes={EFFECT_UPDATE_DEFENSE,EFFECT_SET_DEFENSE,EFFECT_SET_DEFENSE_FINAL,EFFECT_SWAP_DEFENSE_FINAL,EFFECT_SET_BASE_DEFENSE,EFFECT_SWAP_AD,EFFECT_SWAP_BASE_AD,EFFECT_SET_BASE_ATTACK}
	
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			local l1,l2=e:GetLabel()
			if ecode~=EFFECT_SET_DEFENSE_FINAL or (l1~=EFFECT_SET_BASE_ATTACK and l2~=EFFECT_SET_BASE_DEFENSE) then
				table.insert(eset,e)
			end
		end
	end
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	local rev=false
	local revset={c:IsHasEffect(EFFECT_REVERSE_UPDATE)}
	for _,e in ipairs(revset) do
		if not e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) or not c:IsImmuneToEffect(e) then
			rev=true
			break
		end
	end
	
	local effects_def,effects_def_r={},{}
	
	xgl.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				aux.TempBaseDefense=bdef
				return false
			end
		end
		return true
	end)
	
	aux.TempDefense=bdef
	
	local hasActivatedSetStatFinalEffect=false
	local hasContinuousSetStatEffect=false
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		local isSingle=eff:IsHasType(EFFECT_TYPE_SINGLE)
		local HasSingleRange=eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
		local val=eff:Evaluate(c)
		if code==EFFECT_UPDATE_DEFENSE then
			if isSingle and not HasSingleRange then
				up_def = up_def+val
			else
				upc_def = upc_def+val
			end
			
		elseif code==EFFECT_SET_DEFENSE then
			def=val
			if not isSingle or HasSingleRange then
				if not isSingle then
					up_def=0
				end
				hasContinuousSetStatEffect=true
			end
		
		elseif code==EFFECT_SET_DEFENSE_FINAL then
			if isSingle and not HasSingleRange then
				hasActivatedSetStatFinalEffect=true
				def=val
				up_def,upc_def=0,0
			else
				if not eff:IsHasProperty(EFFECT_FLAG_DELAY) then
					table.insert(effects_def,eff)
				else
					table.insert(effects_def_r,eff)
				end
			end
			
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(val,0)
			if not hasActivatedSetStatFinalEffect and not hasContinuousSetStatEffect then
				def=-1
			end
		
		elseif code==EFFECT_SWAP_DEFENSE_FINAL then
			def=val
			up_def,upc_def=0,0
			
		elseif code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(val,0)
			
		elseif code==EFFECT_SWAP_AD then
			swap_final = not swap_final
			
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		
		aux.TempBaseDefense=bdef
		aux.TempDefense = math.max(0,(def<0 and bdef or def) + (up_def + upc_def)*(not rev and 1 or -1))
	end
	
	for _,eff in ipairs(effects_def) do
		aux.TempDefense=eff:Evaluate(c)
	end
	
	if aux.TempAttack==math.maxinteger then
		if swap_final then
			aux.TempDefense=c:GetAttack()
		end
		for _,eff in ipairs(effects_def_r) do
			aux.TempDefense=eff:Evaluate(c)
			if eff:IsHasProperty(EFFECT_FLAG_REPEAT) then
				aux.TempDefense=eff:Evaluate(c)
			end
		end
	end
	
	def = math.max(0,aux.TempDefense)
	
	aux.TempBaseDefense=math.maxinteger
	aux.TempDefense=math.maxinteger
	return def 
end