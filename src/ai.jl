function greedy_ai(board, player; ϵ::Float64 = 0.05)
    legal = [(flipscore(board, player, i, j), i, j) for i in 1:8 for j in 1:8 if islegalpos(board, player, i, j)]
    isempty(legal) && return nothing
    score, x, y = vcat(legal...)
    i = rand() < ϵ ? rand(1:length(x)) : findmax(score)[2]
    return x[i], y[i]
end

function random_ai(board, player)
    legals = legalpos(board, player)
    isempty(legals) && return nothing
    i = rand(legals)
end

function rollout(ai_white, ai_black; rawimg = false, o...)
  x, r, y, board, player = [], 0, Int[], initboard(), 1
  for step in 1:100
    totalpieces(board) >= 64 && (r = finalreward(board); break)
    pos = (player == 1) ? ai_white(board, player) : ai_black(board, player)
    if pos == nothing
      player = getadv(player)
    else
      if player == 1
        push!(x, rawimg ? copy(board) : board2img(colvec(board)))
        push!(y, sub2ind((8, 8), pos...))
      end
      player = update!(board, player, pos...)
    end
  end
  rawimg ? x : hcat(x...), r * ones(y), y
end

function test(ai_white, ai_black, epochs; o...)
  mean([rollout(ai_white, ai_black; o...)[2][1] for t in 1:epochs])
end

function plotgame(ai_white, ai_black; o...)
    x, r = rollout(ai_white, ai_black; rawimg = true, o...)
    boards2gif(x)
    return r[1]
end
