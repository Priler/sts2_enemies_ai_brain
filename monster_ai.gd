class_name MonsterAI # Inspired by STS2 MonsterAI brain <3


class State extends RefCounted:
    var id: String
    var is_move := false

    func get_next(ctx) -> String: return ""


class MoveState extends State:
    var intents: Array
    var perform: Callable
    var follow_up := ""

    func _init(_id, _perform, _intents := [], _follow := ""):
        id = _id; perform = _perform; intents = _intents; follow_up = _follow
        is_move = true

    func get_next(ctx) -> String: return follow_up


class RandomBranch extends State:
    var branches: Array = []

    func add(state: String, weight: Callable, cooldown := 0, max_repeats := -1):
        branches.append({state=state, weight=weight, cd=cooldown, max=max_repeats})

    func get_next(ctx) -> String:
        var next := _roll(ctx, false)
        if next == "":
            next = _roll(ctx, true)
        return next

    func _roll(ctx, ignore_limits: bool) -> String:
        var live := []; var total := 0.0
        for b in branches:
            var w: float = (b.weight.call() if (ignore_limits or _ok(b, ctx)) else 0.0)
            if w > 0.0: live.append({s=b.state, w=w}); total += w
        if total <= 0.0: return ""
        var roll: float = ctx.rng.randf() * total
        for e in live:
            roll -= e.w
            if roll <= 0.0: return e.s
        return live[-1].s

    func _ok(b, ctx) -> bool:
        var log: Array = ctx.move_log
        for i in min(b.cd, log.size()):
            if log[log.size()-1-i] == b.state: return false
        if b.max >= 0:
            var streak := 0
            for i in range(log.size()-1, -1, -1):
                if log[i] == b.state: streak += 1
                else: break
            if streak >= b.max: return false
        return true

class ConditionalBranch extends State:
    var arms: Array = []

    func add(state: String, cond: Callable): arms.append({state=state, cond=cond})

    func get_next(ctx) -> String:
        for a in arms:
            if a.cond.call(): return a.state
        push_error("no valid branch"); return ""
