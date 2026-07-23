static func make_fabricator(boss) -> MonsterMachine:
    var fab     := MonsterAI.MoveState.new("FAB", boss.fabricate, ["summon"])
    var strike  := MonsterAI.MoveState.new("STRIKE", boss.fab_strike, ["attack","summon"])
    var disint  := MonsterAI.MoveState.new("DISINT", boss.disintegrate, ["attack"])

    var roll := MonsterAI.RandomBranch.new(); roll.id = "ROLL"
    roll.add("FAB",    func(): return 1.0)
    roll.add("STRIKE", func(): return 1.0)

    var gate := MonsterAI.ConditionalBranch.new(); gate.id = "GATE"
    gate.add("ROLL",   func(): return boss.can_fabricate())
    gate.add("DISINT", func(): return not boss.can_fabricate())

    fab.follow_up = "GATE"; strike.follow_up = "GATE"; disint.follow_up = "GATE"
    return MonsterMachine.new([fab, strike, disint, roll, gate], gate)
