outbound(x, y) = x < 1 || x > 8 || y < 1 || y > 8

getadv(player) = (player + 1) % 2

function islegaldir(board, player, x, y, i, j, already_legal)
    adversary = getadv(player); x += i; y += j
    (outbound(x, y) || i == 0 && j == 0) && (return false)
    (board[x, y] == adversary) && (return islegaldir(board, player, x, y, i, j, true))
    (board[x, y] == player) && (return already_legal)
    return false
end

function islegalpos(board, player, x, y)
    (outbound(x, y) || board[x, y] !== -1) && (return false)
    for i = -1:1, j = -1:1
        islegaldir(board, player, x, y, i, j, false) && (return true)
    end
    return false
end

function legalpos(board, player)
  [(i, j) for i in 1:8 for j in 1:8 if islegalpos(board, player, i, j)]
end

function flip!(board, player, x, y)
    for i = -1:1, j = -1:1
        islegaldir(board, player, x, y, i, j, false) && flipdir!(board, player, x, y, i, j)
    end
end

function flipdir!(board, player, x, y, i, j)
    adversary = getadv(player)
    x += i; y += j
    while !outbound(x, y) && (board[x, y] == adversary)
        board[x, y] = player
        x += i; y += j
    end
end

function npieces(board)
    nwhite = nblack = 0
    for i = 1:8, j = 1:8
        (board[i, j] == 1) ? (nwhite += 1) :
        (board[i, j] == 0) ? (nblack += 1): nothing
    end
    return nblack, nwhite
end

totalpieces(board) = sum(1 for x in board if x !== -1)

function finalreward(board)
  n_black, n_white = npieces(board)
  sign(n_white - n_black)
end

function flipscore(board, player, x, y)
    board_tmp = copy(board)
    flip!(board_tmp, player, x, y)
    score = npieces(board_tmp)[player + 1]
    return score
end

noway(board, player) = isempty(legalpos(board, player))

function initboard()
    board = fill(-1, 8, 8)
    board[4, 4] = 1; board[5, 5] = 1
    board[4, 5] = 0; board[5, 4] = 0
    return board
end

function update!(board, player, x, y)
  !islegalpos(board, player, x, y) && return player
  board[x, y] = player
  flip!(board, player, x, y)
  next_player = getadv(player)
  noway(board, next_player) ? player : next_player
end
