extends Node

# FABRICATOR BOSS test t(-_-t)

var ai: MonsterMachine
var allies := 0

func _ready() -> void:
    ai = preload("res://fabricator.gd").make_fabricator(self)
    ai.move_chosen.connect(_on_move_chosen)
    for i in 10:
        await take_turn()

func take_turn() -> void:
    var move := ai.roll_move()
    await get_tree().create_timer(0.4).timeout
    await move.perform.call()

func _on_move_chosen(intents: Array) -> void:
    print("telegraph: ", intents)


func can_fabricate() -> bool:
    return allies < 4

func fabricate() -> void:
    allies += 1
    print("built a minion (%d)" % allies)

func fab_strike() -> void:
    allies += 1
    print("attack + minion (%d)" % allies)

func disintegrate() -> void:
    print("big attack (%d - full)" % allies)
