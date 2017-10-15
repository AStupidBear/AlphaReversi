using ANN, StatsBase

function board2img(board)
  white, black, green = zeros(board), zeros(board), zeros(board)
  for i in eachindex(board)
    board[i] == 1 ? (white[i] = 1) :
    board[i] == 0 ? (black[i] = 1) : (green[i] = 1)
  end
  return vcat(white, black, green)
end

revboard(board) = [x == 1 ? -1 : x == -1 ? 1 : 0  for x in board]

function net_ai(net, board, player; rev = false, o...)
  legal = [sub2ind((8, 8), i, j) for i in 1:8 for j in 1:8 if islegalpos(board, player, i, j)]
  isempty(legal) && return nothing
  rev && (board = revboard(board))
  x = board2img(colvec(board))
  p = ANN.predict_prob(net, x)
  ind = StatsBase.sample(legal, StatsBase.weights(p[legal]))
  return ind2sub((8, 8), ind)
end

function getdata(ndata; o...)
  x, y, n = -ones(64, ndata + 4), [zeros(ndata); 28; 29; 36; 37], 1
  while n <= ndata
    board, player = initboard(), 1
    for step in 1:100
      (n > ndata || totalpieces(board) >= 64) && break
      pos = (player == 1) ? greedy_ai(board, player) : random_ai(board, player)
      pos == nothing && (player = getadv(player); continue)
      if player == 1
        x[:, n], y[n], n = vec(board), sub2ind((8, 8), pos...), n + 1
      else
        x[:, n], y[n], n = revboard(vec(board)), sub2ind((8, 8), pos...), n + 1
      end
      player = update!(board, player, pos...)
    end
  end
  x = board2img(x)
  return x, y
end

function supervised_train!(net, ndata, epochs; o...)
  x, y = getdata(ndata; o...)
  ANN.initialize!(net, x, y; shapes = (8, 8, 3), o...)
  ANN.train!(net, epochs; o...)
  x, y = getdata(ndata; o...)
  ANN.test(net, x, y)
end

function rl_train!(net, ai_black; o...)
    ai_white = net2ai(net)
    x, r, y = rollout(ai_white, ai_black; o...)
    ANN.policygrad!(net, x, r, y; o...)
end

net2ai(net; o...) = partial(net_ai, deepcopy(net); o...)
