#== Game start
width, height, my_id = gets.split(" ").map { |x| x.to_i }
lines = []

height.times do
  lines << gets.chomp.split("")
end

map = Map.new(*lines)
# debug("map came out as:\n#{ map.inspect }")

graph = GridMatrixToGraph.new(map, minimum_neighbors: MINIMUM_NEIGHBORS).call
# debug "Graph structure is:\n#{ graph.send(:structure) }"

full_graph = GridMatrixToGraph.new(map).call
# debug "FullGraph structure is:\n#{ full_graph.send(:structure) }"

debug("Starting path precrunch..")
long_path_150 = LongPathFinder.new(map, full_graph).call
debug("Long path came out as #{ long_path_150 }")

# Starting cell
start_node = long_path_150.first #=> [0, 0]
puts "#{start_node[0]} #{start_node[1]}"

captain = Captain.new(
  *start_node,
  map: map, graph: graph, full_graph: full_graph,
  long_path: long_path_150
)
#== Game start end
