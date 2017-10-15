using POMDPs, MCTS

@withkw type ReversiState
    board::Matrix{Int} = initboard()
end

type ReversiWorld <: MDP{ReversiState, Int}
  ai::Function
end

Base.hash(s::ReversiState, h::UInt64 = zero(UInt64)) = hash(s.board, h)
Base.:(==)(s1::ReversiState, s2::ReversiState) = s1.board == s2.board

function POMDPs.actions(mdp::ReversiWorld, s::ReversiState)
  a = [sub2ind((8, 8), i, j) for (i, j) in legalpos(s.board, 1)]
  isempty(a) && (a = [1])
  return a
end

function POMDPs.isterminal(mdp::ReversiWorld, s::ReversiState)
  totalpieces(s.board) >= 64 || (noway(s.board, 1) && noway(s.board, 0))
end

function POMDPs.transition(mdp::ReversiWorld, state::ReversiState, action::Int)
    board, player = copy(state.board), 1
    x, y = ind2sub((8, 8), action)
    if noway(board, player)
      player = getadv(player)
    elseif islegalpos(board, player, x, y)
      player = update!(board, player, x, y)
    end
    if noway(board, player)
      player = getadv(player)
    elseif player == 0
      x, y = mdp.ai(board, player)
      player = update!(board, player, x, y)
    end
    return [ReversiState(board)]
end

function POMDPs.reward(mdp::ReversiWorld, state::ReversiState, action::Int, statep::ReversiState)
    totalpieces(state.board) >= 63 ? finalreward(state.board) : 0
end

function mcts_ai(board, player; ai_black = greedy_ai, rev = false, o...)
  mdp = ReversiWorld(ai_black)
  solver = MCTSSolver(;o...)
  policy = MCTSPlanner(solver, mdp)
  rev && (board = revboard(board))
  s = ReversiState(copy(board))
  POMDPs.isterminal(mdp, s) && return nothing
  a = action(policy, s)
  ind2sub((8, 8), a)
end

type RolloutPolicy <: Policy
  ai::Function
end
#
function POMDPs.action(p::RolloutPolicy, s::ReversiState)
  noway(s.board, 1) ? 1 : sub2ind((8, 8), p.ai(s.board, 1)...)
end
