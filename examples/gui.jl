using Gtk.ShortNames, GtkReactive, Graphics
using AlphaReversi: initboard, totalpieces, islegalpos, noway, getadv, islegalpos, draw_board!, update!, npieces, greedy_ai

pos2grid(x, y) = (Int(x ÷ (1/8) + 1), Int(y ÷ (1/8) + 1))

棋盘 = Signal(initboard())
棋盘记录 = foldp((x, y) -> push!(x, copy(y)), [value(棋盘)], 棋盘)
棋手 = Signal(0) # black 0, white 1, blank -1
对手类型 = Signal("AI")
总棋子数 = map(x -> sum(totalpieces(x)), 棋盘)
白棋AI = greedy_ai

g = Grid()
g[5, 1:2] = label("black: 2\nwhite: 2"; signal = map(b -> @sprintf("black: %d\nwhite: %d", npieces(b)...), 棋盘))
g[5, 3] = btn_reset = button("reset")
g[5, 4] = btn_regret = button("regret")
g[1:4, 1:4] = c = canvas(600, 600)
win = Window("Reversi") |> g
showall(win)

foreach(btn_reset) do btn
    empty!(value(棋盘记录))
    push!(棋手, 0)
    push!(棋盘, initboard())
end

foreach(btn_regret) do btn
    if length(value(棋盘记录)) > 2
        pop!(value(棋盘记录))
        pop!(value(棋盘记录))
        push!(棋盘, last(value(棋盘记录)))
    end
end

function updateall(x, y)
  board, player, adv_type, nchess = map(value, [棋盘, 棋手, 对手类型, 总棋子数])
  if noway(board, player)
    player = getadv(player); push!(棋手, player)
  elseif islegalpos(board, player, x, y)
    player = update!(board, player, x, y)
    push!(棋盘, board); push!(棋手, player); Reactive.run_till_now()
  end
  if noway(board, player)
    player = getadv(player); push!(棋手, player)
  elseif adv_type == "AI" && player == 1
    x, y =  白棋AI(board, player)
    player = update!(board, player, x, y)
    sleep(0.5); push!(棋手, player); push!(棋盘, board); Reactive.run_till_now()
  end
  if totalpieces(board) >= 64
    push!(棋手, 0); push!(棋盘, initboard())
    n_black, n_white = npieces(board)
    info_dialog(n_white > n_black ? "white win" : n_white < n_black ? "black win" : "equal")
   end
end

foreach(c.mouse.buttonpress) do btn
    if btn.button == 1 && btn.modifiers == 0
      x, y = btn.position.x / height(c), btn.position.y / width(c)
      x, y = pos2grid(y, x)
      updateall(x, y)
    end
end

draw(c, 棋盘) do cnvs, board
    draw_board!(cnvs, getgc(c), board)
end

if !isinteractive()
    con = Condition()
    signal_connect(win, :destroy) do widget
        notify(con)
    end
    wait(con)
end
