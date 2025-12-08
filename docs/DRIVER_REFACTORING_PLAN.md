# Driver Refactoring Plan

## Current State (Updated 2025-12-09)

### What Exists
- `miaou_driver_common` library with:
  - `Driver_common.Make` functor for basic event loop (106 lines)
  - `Modal_utils` for modal overlay rendering
  - `Page_transition_utils` for page transitions

### What's Not Used Yet
- Neither `lambda_term_driver.ml` (945 lines) nor `sdl_driver.ml` (721 lines) use the functor
- Both implement their own custom event loops with extensive advanced features

### Detailed Feature Analysis

**lambda_term_driver.ml features** (945 lines):
- Key handler stack (Khs) - dynamic keybinding system with push/pop frames
- Footer hints - contextual key hints rendered at bottom of screen
- Pager notifications - debounced rendering updates for live widgets
- Narrow terminal warnings - responsive UI degradation
- Help system integration - '?' key intercept
- Complex key routing - fallback chains, modal priority, stack dispatch
- Signal handling - proper Ctrl+C cleanup with mouse tracking
- Terminal size detection - SIGWINCH + polling fallback
- Flicker reduction - cached rendering, smart redraws
- State refs - current_state_ref, current_key_stack_ref for pager callbacks

**sdl_driver.ml features** (721 lines):
- Chart context management - global SDL context with Obj.magic workaround
- Texture caching - reuse textures across frames
- Page transitions - text capture + SDL effects (explode/fade/slide)
- Pixel-based rendering - convert ANSI text to pixel grid
- Font management - TrueType font loading and glyph rendering
- ANSI color parsing - full 256-color + RGB support
- Event polling - SDL event loop integration

### Key Challenges

**Why the functor isn't sufficient:**

The current `Driver_common.Make` functor provides only:
- Basic event loop (poll → render → repeat)
- Simple key routing (Up/Down/Enter/q hardcoded)
- Modal overlay support
- Basic page transitions

**What's missing:**
1. **Dynamic keybinding system** - The Khs stack is central to lambda-term
2. **Stateful driver refs** - Many features need persistent refs across frames
3. **Backend-specific hooks** - Chart context setup, texture management
4. **Complex key routing** - Priority chains, stack dispatch, fallbacks
5. **Debouncing/throttling** - Pager notifications, size change handling
6. **Cleanup coordination** - Signal handlers, resource cleanup ordering

## Refactoring Strategy

### Phase 1: Extract More Common Utilities (DONE)
- ✅ Modal rendering logic → `Modal_utils`
- ✅ Page transition coordination → `Page_transition_utils`
- ✅ Basic event loop structure → `Driver_common.Make` functor

### Phase 2: Big-Bang Functor Migration (ABANDONED)

**Original plan:** Extend `DRIVER_BACKEND` with 15-20 optional hooks, expand functor to ~400-500 lines, migrate both drivers simultaneously.

**Why abandoned:**
- Too risky - touches critical rendering path
- Hard to test incrementally
- Would introduce ~30% new code in functor (high bug potential)
- Drivers have very different architectures (Khs vs chart contexts)

### Phase 2A: Incremental Utility Extraction (NEW APPROACH - IN PROGRESS)

**Philosophy:** Extract small, focused, well-tested utilities that both drivers can use, without changing the event loop structure.

**Planned extractions:**

1. **Footer rendering utilities** → `miaou_driver_common/Footer_utils`
   - `render_footer_hints : (string * string) list -> cols:int -> string`
   - `render_footer_wrapped : (string * string) list -> cols:int -> rows:int -> string`
   - Used by lambda-term, potentially useful for SDL status bars

2. **Key handler stack helpers** → `miaou_driver_common/Key_stack_utils`
   - Utilities for working with `Key_handler_stack.t`
   - Common patterns: push/pop with bindings, dispatch with fallback
   - State management helpers

3. **Pager notification manager** → `miaou_driver_common/Pager_notify`
   - Debounced notification handling
   - Timestamp tracking
   - Configurable debounce intervals

4. **Size change detection** → `miaou_driver_common/Size_tracker`
   - Track size changes with hysteresis
   - Avoid spurious resize events
   - Works with any backend

**Benefits:**
- Low risk - no changes to event loops
- Easy to test - small, pure functions
- Incremental - one utility at a time
- Immediate value - reduce duplication now
- Future-proof - utilities useful even if functor never used

**Estimated impact:**
- Extract ~150-200 lines of duplicated logic
- Improve testability
- Make drivers more maintainable
- Doesn't require changing event loop

### Phase 2B: Optional Backend Hooks (FUTURE - NOT STARTED)

Only if Phase 2A succeeds and we want to go further:

```ocaml
module type DRIVER_BACKEND = sig
  (* ... existing fields ... *)

  (** Optional: Return footer bindings for current frame *)
  val get_footer_hints : unit -> (string * string) list option

  (** Optional: Backend-specific rendering hooks *)
  val before_render : unit -> unit option
  val after_render : unit -> unit option
end
```

### Phase 3: Gradual Functor Enhancement (FUTURE - NOT STARTED)

If we ever want drivers to use the functor:
1. Add optional hooks one at a time
2. Test with one driver first
3. Migrate second driver only after first is stable
4. Keep old implementations until both work

### Phase 4: Size Reduction Target (FUTURE)

If all phases complete:
- `lambda_term_driver.ml`: 945 → ~600 lines (realistic target)
- `sdl_driver.ml`: 721 → ~500 lines (realistic target)
- `miaou_driver_common`: 106 → ~400 lines (absorbs shared logic)

## Benefits of Incremental Approach (Phase 2A)

1. **Low risk:** No event loop changes, just utility extraction
2. **Immediate value:** Reduce duplication now without big refactoring
3. **Better testing:** Small utilities are easy to unit test
4. **Gradual improvement:** One utility at a time, validate each step
5. **Future-proof:** Utilities useful regardless of functor migration

## Benefits of Full Migration (Phase 2B-4) - IF we do it

1. **Reduced duplication:** ~400 lines of event loop logic shared
2. **Easier maintenance:** Bug fixes in one place
3. **Consistent behavior:** Modal/transition handling identical across drivers
4. **Future drivers:** New backends (e.g., Web, native GUI) can reuse infrastructure

## Risks of Full Migration

1. **Regression potential:** Complex refactoring of critical code
2. **Feature parity:** Must preserve all existing functionality
3. **Testing burden:** Need comprehensive tests for both drivers
4. **Development time:** Estimated 5-10 days of focused work
5. **Architectural mismatch:** Drivers have different core designs

## Current Recommendation (Updated 2025-12-09)

**Phase 2A (Incremental Utility Extraction): DO THIS NOW**
- Extract Footer_utils, Key_stack_utils, Pager_notify, Size_tracker
- Low risk, immediate value
- ~2-3 days of work
- Reduces duplication by ~150-200 lines
- Makes codebase more maintainable

**Phase 2B-4 (Full Functor Migration): DEFER TO FUTURE**
- Complex, risky, high effort
- Only do if clear business need emerges
- Would require dedicated sprint with feature freeze
- Current code works well, no urgent need

**Next steps:**
1. ✅ Document current state (this file)
2. 🔄 Extract Footer_utils module
3. 🔄 Extract Key_stack_utils module
4. 🔄 Extract Pager_notify module
5. 🔄 Extract Size_tracker module
6. ✅ Commit incremental improvements
7. ❓ Re-evaluate full migration later
