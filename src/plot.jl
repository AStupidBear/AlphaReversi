using Cairo, Colors

function draw_board!(cnvs, ctx, board)
  w, h = width(cnvs) / 8, height(cnvs) / 8
  for i = 0:7, j = 0:7
      rectangle(ctx, j * w, i * h, w, h)
      set_source_rgb(ctx, board2color(-1)...)
      fill(ctx)
      arc(ctx, (j + 0.5) * w , (i + 0.5) * h, min(w, h) / 2.1, 0, 2π)
      set_source_rgb(ctx, board2color(board[i + 1, j + 1])...)
      fill(ctx)
  end
  set_source(ctx, colorant"brown")
  for i = 1:7
      move_to(ctx, 0, i * h)
      line_to(ctx, 8 * w, i * h)
      move_to(ctx, i * w, 0)
      line_to(ctx, i * w, 8 * h )
  end
  stroke(ctx)
end

function board2color(x)
    x == 1 ? (1, 1, 1) :
    x == 0 ? (0, 0, 0) : (0, 0.5, 0)
end

function boards2gif(boards)
  cnvs = CairoRGBSurface(256,256)
  ctx = CairoContext(cnvs)
  root = tempdir()
  for (i, board) in enumerate(boards)
    draw_board!(cnvs, ctx, board)
    fn = joinpath(root, @sprintf("board_%02d.png", i))
    write_to_png(cnvs, fn)
  end
  prefix = is_windows() ? "imconvert.exe" : "convert"
  run(`$prefix -delay 30 -loop 0 $root/board_*.png -alpha off $(timename("board.gif"))`)
  try foreach(rm, glob("board_*.png", root)) end
end
