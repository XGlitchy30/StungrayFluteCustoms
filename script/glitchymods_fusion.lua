-- Fix summary:
--   [FIX-A] SelectMix now enumerates completions as index-ordered
--           COMBINATIONS (each candidate set is visited exactly once).
--           Legality of a set is order-independent - every per-step screen
--           (EFFECT_FUSION_MAT_RESTRICTION, must-material bookkeeping) and
--           the final goal depend only on the selected SET - so this is an
--           exact r!-fold reduction, not an approximation.
--   [FIX-B] CheckMixGoal binds cards to slots with a memoized reachability
--           DP over subsets (state = assigned set + substitute budget).
--           This computes exactly "does an assignment ORDER exist", i.e.
--           the same predicate as the old DFS (filters can only observe
--           the assigned SET and the budget, never the order itself),
--           at <= 2^k*k*2 filter calls instead of ~e*k!.
--   [FIX-C] New opt-in per-card API Fusion.SetMaterialGroupCheck for
--           group-level constraints ("all different names", "must include
--           X"), so card scripts no longer have to smuggle group logic
--           into the per-card filter (which forced the old permutation
--           search to do their work). The prune hook is applied to every
--           PARTIAL selection, killing infeasible UI candidates in O(1).
--   [FIX-D] Optional (off by default) partial-group pruning through
--           Fusion.CheckAdditional, gated by Fusion.CheckAdditionalPrunable,
--           mirroring what the Rep path already does.
--============================================================================--

--[FIX-C] --------------------------------------------------------------------
--Per-card group-level material constraints.
--
--   Fusion.SetMaterialGroupCheck(c, goalcheck, prunecheck)
--
--   goalcheck(tp,sg,fc,sumtype)  -> boolean; evaluated only on COMPLETE
--       candidate material sets (inside CheckMixGoal). May be any predicate,
--       e.g. "sg must contain card X".
--   prunecheck(tp,sg,fc,sumtype) -> boolean; evaluated on every PARTIAL
--       selection during the search AND on complete sets. It MUST be
--       fail-monotone: if it returns false for a group, it must return false
--       for every superset of that group ("no two materials with the same
--       name" qualifies; "must contain X" does NOT, put that in goalcheck).
--
--Both hooks are stored on the card's metatable (shared by all copies of the
--card code, like material_count) and read back through the fc userdata
--inside the search.
function Fusion.SetMaterialGroupCheck(c,goalcheck,prunecheck)
    if c:IsStatus(STATUS_COPYING_EFFECT) then return end
    local mt=c:GetMetatable()
    mt.fusion_gcheck_goal=goalcheck
    mt.fusion_gcheck_prune=prunecheck
end

--[FIX-D]
Fusion.CheckAdditionalPrunable=nil
--[FIX-B] Material count above which CheckMixGoal falls back to the legacy
--permutation search (the subset DP allocates O(2^k) states).
Fusion.CheckMixDPLimit=10

--[FIX-B] ---------------------------------------------------------------------
--Subset-reachability replacement for the permutation search of
--Fusion.CheckMix. Computes the same predicate:
--
--   "does an ORDER of (a subset of) the cards of candg exist that binds one
--    card to each slot fun1..funk, obeying the single-substitute budget?"
--
--Equivalence argument: along any legacy DFS path the only information a
--filter call can observe is (candidate card, set of already-bound cards,
--substitute budget, constants). Order beyond that is invisible. Hence
--reachability over states (bound set, budget) - computed level by level,
--level = number of bound cards = slot index - decides existence of an
--accepting order exactly, while visiting every state once instead of once
--per path. Cost: <= 2^k * k * 2 filter calls (k = #funs) instead of ~e*k!.
--
--Faithfully reproduced details:
--  * slot i uses funs[i] (slots are positional, not interchangeable);
--  * intermediate slots evaluate the filter with the candidate ALREADY in
--    the accumulator group; the FINAL slot evaluates it with the candidate
--    NOT in the accumulator (upstream asymmetry);
--  * a card is bound "natively" first (sub=false); only if that fails and
--    the budget is intact is the substitute clause (sub=true) tried, which
--    consumes the budget;
--  * the final slot receives the remaining budget as its sub argument; if
--    a state is reachable both with and without budget, both variants are
--    tried (covers non-monotone user filters);
--  * cards of candg may remain unbound if #candg > #funs (upstream
--    behavior; in practice the callers guarantee #candg == #funs).
function Fusion.CheckMixMatch(tp,candg,fc,sub,sub2,contact,sumtype,...)
	local funs={...}
	local k=#funs
	if k==0 then return false end
	local cards={}
	for tc in aux.Next(candg) do cards[#cards+1]=tc end
	local n=#cards
	if n<k then return false end
	--reach[mask]: reachable budget states for the bound set encoded by mask
	--  bit 1 (value 1): reachable with the substitute budget still intact
	--  bit 2 (value 2): reachable with the substitute budget consumed
	local reach={[0]=1}
	local frontier={0}
	--Builds the accumulator Group for a state (optionally with one extra card)
	local function stateGroup(mask,extra)
		local g=Group.CreateGroup()
		for i=1,n do
			if (mask&(1<<(i-1)))~=0 then g:AddCard(cards[i]) end
		end
		if extra then g:AddCard(extra) end
		return g
	end
	--Levels 1..k-1: extend every reachable (set,budget) state by one card
	for slot=1,k-1 do
		local f=funs[slot]
		local nfront={}
		for _,mask in ipairs(frontier) do
			local st=reach[mask]
			for i=1,n do
				local bit=1<<(i-1)
				if (mask&bit)==0 then
					local nmask=mask|bit
					local cur=reach[nmask] or 0
					if cur~=3 then
						local mc=cards[i]
						local sgg=stateGroup(mask,mc)
						local newst=0
						if f(mc,fc,false,sub2,candg,sgg,tp,contact,sumtype) then
							--native bind: budget states carry over unchanged
							newst=st
						elseif sub and (st&1)~=0 and f(mc,fc,true,sub2,candg,sgg,tp,contact,sumtype) then
							--substitute bind: only from a budget-intact
							--state, and it consumes the budget
							newst=2
						end
						local merged=cur|newst
						if merged~=cur then
							if cur==0 then table.insert(nfront,nmask) end
							reach[nmask]=merged
						end
					end
				end
			end
		end
		if #nfront==0 then return false end
		frontier=nfront
	end
	--Final slot: evaluated with the accumulator NOT containing the candidate
	local f=funs[k]
	for _,mask in ipairs(frontier) do
		local st=reach[mask]
		local sgg=stateGroup(mask,nil)
		for i=1,n do
			if (mask&(1<<(i-1)))==0 then
				local mc=cards[i]
				if (st&1)~=0 and f(mc,fc,sub,sub2,candg,sgg,tp,contact,sumtype) then return true end
				if (st&2)~=0 and f(mc,fc,false,sub2,candg,sgg,tp,contact,sumtype) then return true end
			end
		end
	end
	return false
end
--Complete-set validation: the k selected cards can be bound to the k slots
--([FIX-B] DP, legacy fallback above the DP limit), a monster zone is
--available if requested (chkf), and every group-level constraint holds
--([FIX-C] hooks, then the effect-installed Fusion.CheckAdditional).
function Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
	--[FIX-C] per-card group constraints (cheap, so they run first)
	if fc.fusion_gcheck_prune and not fc.fusion_gcheck_prune(tp,sg,fc,sumtype,sub,sub2,contact,chkf,...) then return false end
	if fc.fusion_gcheck_goal and not fc.fusion_gcheck_goal(tp,sg,fc,sumtype,sub,sub2,contact,chkf,...) then return false end
	--[FIX-B] slot assignment
	local matched
	if #sg<=Fusion.CheckMixDPLimit then
		matched=Fusion.CheckMixMatch(tp,sg,fc,sub,sub2,contact,sumtype,...)
	else
		local g=Group.CreateGroup()
		matched=sg:IsExists(Fusion.CheckMix,1,nil,sg,g,fc,sub,sub2,contact,sumtype,tp,...)
	end
	return matched and
		(chkf==PLAYER_NONE or (fc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,fc) or Duel.GetMZoneCount(tp,sg,tp))>0)
		and (not Fusion.CheckAdditional or Fusion.CheckAdditional(tp,sg,fc,sumtype,tp))
end

--"Can the partial selection sg, extended by card c, be completed to a legal
--set?" - used both as the existence predicate of ConditionMix and as the
--per-click clickability predicate of OperationMix.
--[FIX-A] The completion search below enumerates each completion SET exactly
--once (index-ordered combinations) instead of every ORDER of it. This is
--exact because set legality is order-independent: the per-step screens
--(count limits, EFFECT_FUSION_MAT_RESTRICTION incompatibilities, must-
--material bookkeeping) and the leaf goal all depend only on the selected
--set - a pairwise conflict fails in every order at whichever step the later
--card is added, and in no order otherwise.
function Fusion.SelectMix(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
	return Fusion.SelectMixStep(c,nil,0,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
end

--[FIX-A] Internal step. pool is a Lua array snapshot of the material pool
--in deterministic Group iteration order; previdx is the pool index of the
--card chosen at the previous depth (0 = unrestricted, used at entry so the
--pinned candidate does not exclude lower-indexed completions). Deeper
--recursion only considers indices > previdx, which yields combinations.
function Fusion.SelectMixStep(c,pool,previdx,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
	local res
	local totalcount=#{...}
	local mustgcount=#mustg

    --Feasibility screens on the requirement size vs. must-materials and the
	--effect-installed count constraints (CheckExact/CheckMax/CheckMin).
	if mustgcount>totalcount then return false end
	if (Fusion.CheckExact and (Fusion.CheckExact~=totalcount or mustgcount>Fusion.CheckExact)) then return false end
	if (Fusion.CheckMax and (Fusion.CheckMax<totalcount or mustgcount>Fusion.CheckMax)) then return false end
	if (Fusion.CheckMin and Fusion.CheckMin>totalcount) then return false end
	-- local rg=Group.CreateGroup()
	local mg2=mg:Clone()
	--c has the fusion limit ("Harmonizing Magician": cannot be material
	--together with certain cards). Reject if c conflicts with an already
	--selected card, and drop future candidates conflicting with c from the
	--pool clone; if a must-material got dropped, no completion can exist.
	if not contact and c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				return false
			end
			local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			-- rg:Merge(sg2)
			mg2:Sub(sg2)
			if mustgcount>0 and not mg2:Includes(mustg) then
				return false
			end
		end
	end
	--A card in the selected group has the fusion lmit
	if not contact then
		local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					return false
				end
			end
		end
	end
	-- mg2:Sub(rg)
	sg:AddCard(c)

    --[FIX-C]/[FIX-D] Fail-monotone constraints may already rule out this
	--PARTIAL selection - this is what rejects an infeasible UI candidate in
	--O(1) instead of after an exhaustive completion search.
    if (fc.fusion_gcheck_prune and not fc.fusion_gcheck_prune(tp,sg,fc,sumtype,sub,sub2,contact,sumtype,chkf,...)) or (Fusion.CheckAdditionalPrunable and Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,sg,fc,sumtype,tp)) then
        res=false
    elseif #sg<totalcount then
        --[FIX-A] Build the pool snapshot once per top-level query, then
		--recurse forward-only. Cards already selected are skipped via sg;
		--cards pruned by restriction effects are skipped via mg2.
        if not pool then
            pool={}
            for tc in aux.Next(mg) do
                pool[#pool+1]=tc
            end
            previdx=0
        end
        res=false
        for i=previdx+1,#pool do
            local nc=pool[i]
            if not sg:IsContains(nc) and mg2:IsContains(nc) then
                if Fusion.SelectMixStep(nc,pool,i,tp,mg2,sg,mustg-sg,fc,sub,sub2,contact,sumtype,chkf,...) then
                    res=true
                    break
                end
            end
        end
	else
		res=Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
		--This is the end of the recursion
		res=res and sg:Includes(mustg)
	end
	sg:RemoveCard(c)
	-- mg2:Merge(rg)
	return res
end