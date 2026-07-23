class_name MonsterMachine extends RefCounted

signal move_chosen(intents)
var states := {}
var current: MonsterAI.State
var initial: MonsterAI.State
var move_log: Array[String] = []
var rng := RandomNumberGenerator.new()

func _init(state_list: Array, _initial: MonsterAI.State, seed_value := 0):
    for s in state_list: states[s.id] = s
    current = _initial; initial = _initial
    rng.seed = seed_value

func roll_move() -> MonsterAI.MoveState:
    for _hop in 32:
        var next := current.get_next(self)
        current = states[next] if next != "" else initial
        if current.is_move:
            var move := current as MonsterAI.MoveState
            move_log.append(move.id)
            move_chosen.emit(move.intents)
            return move
    push_error("no reachable move from '%s'" % current.id)
    return null
