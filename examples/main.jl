using AlphaReversi

if ispath("net.jld")
  net = JLD.load("net.jld", "net")
else
  net = ANN.CnnClassifier(;model = ANN.convnet)
  net.param = ANN.CnnParameter(;nhid = 1, hidden1 = 1000, nconv = 2,
              window1 = 2, window2 = 2, channel1 = 50, channel2 = 50)
  net.updater = partial(ANN.Adam; lr = 1e-3)
  AR.supervised_train!(net, 100, 30; splitratio = 0.2)
  empty!(net.dtrn); empty!(net.dtst)
end

ai_pool = [AR.greedy_ai, AR.random_ai]
for t in 1:150
  # t % 10 == 0 && push!(ai_pool, AR.net2ai(net; rev = true))
  # length(ai_pool) > 50 && deleteat!(ai_pool, 3:2:length(ai_pool))
  @repeat 100 AR.rl_train!(net, rand(ai_pool); lr = 1)
  reward = [AR.test(AR.net2ai(net), ai, 500) for ai in ai_pool[1:2]]
  Logging.info("t = $t, reward = $reward")
end

# JLD.save("net.jld", "net", net)

include(AR.dir("examples", "gui.jl"))

白棋AI = partial(AR.mcts_ai; ai_black = AR.greedy_ai,
                n_iterations = 100, depth = 100,
                exploration_constant = 2.0)

白棋AI = AR.net2ai(net; rev = true)

est = AR.RolloutEstimator(AR.RolloutPolicy(AR.net2ai(net)))
白棋AI = partial(AR.mcts_ai; ai_black = AR.net2ai(net; rev=true),
                n_iterations = 100, depth = 100,
                exploration_constant = 1.0,
                estimate_value = est)

AR.test(AR.net2ai(net), AR.greedy_ai, 1000)
AR.test(AR.net2ai(net), AR.random_ai, 1000)
AR.test(AR.greedy_ai, AR.net2ai(net),  1000)
AR.test(AR.random_ai, AR.net2ai(net),  1000)
AR.test(AR.greedy_ai, AR.net2ai(net; rev=true),  1000)
AR.test(AR.random_ai, AR.net2ai(net; rev=true),  1000)

AR.test(白棋AI, AR.greedy_ai, 10)
AR.test(白棋AI, AR.random_ai, 100)
AR.test(白棋AI, AR.net2ai(net), 100)
AR.test(白棋AI, AR.net2ai(net; rev=false), 100)
