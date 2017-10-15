module AlphaReversi

export AR
const AR = AlphaReversi

include("game.jl")
include("plot.jl")
include("ai.jl")
include("network.jl")
try include("mcts.jl") end

dir(names...) = normpath(dirname(@__FILE__), "..", names...)
end
