using CellularAutomata

const rule0 = DCA(0)
@test rule0.ruleset == [0, 0, 0, 0, 0, 0, 0, 0] #http://atlas.wolfram.com/01/01/0/

const rule1 = DCA(1)
@test rule1.ruleset == [1, 0, 0, 0, 0, 0, 0, 0] #http://atlas.wolfram.com/01/01/1/

const rule2 = DCA(2)
@test rule2.ruleset == [0, 1, 0, 0, 0, 0, 0, 0] #http://atlas.wolfram.com/01/01/2/

const rule3 = DCA(3)
@test rule3.ruleset == [1, 1, 0, 0, 0, 0, 0, 0] #http://atlas.wolfram.com/01/01/2/

const rule30 = DCA(30)
@test rule30.ruleset == [0, 1, 1, 1, 1, 0, 0, 0] #http://atlas.wolfram.com/01/01/30/

