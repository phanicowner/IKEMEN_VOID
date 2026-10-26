-- VOID hook pre-shim (3.0.1 workaround)
-- Place this file in: external/mods/_hook.lua
--
-- Fixes: selectplus.lua crash on startup
--   "attempt to index global 'hook' (a nil value)"
--   Symptom: title screen loads but Enter/Start exits immediately;
--            character select never opens.
--
-- How it works: selectplus.lua calls hook.add() at load time, before
-- void_compat.lua has had a chance to define hook. This file loads
-- first (alphabetical order: _ sorts before s) and pre-defines hook
-- so selectplus.lua finds it. void_compat's later "hook = hook or {}"
-- keeps this same table intact — no conflict.
--
-- Safe to leave in place after updating to a newer VOID build.
-- This file has no effect once the fix is built into the engine.

hook = hook or {}
hook._cbs = hook._cbs or {}

if not hook.add then
    function hook.add(point, id, fn)
        if hook._cbs[point] == nil then hook._cbs[point] = {} end
        hook._cbs[point][id] = fn
    end
end

if not hook.fire then
    function hook.fire(point)
        local cbs = hook._cbs[point]
        if cbs then
            for id, fn in pairs(cbs) do pcall(fn) end
        end
    end
end
