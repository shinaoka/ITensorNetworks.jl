abstract type AbstractIndsNetwork{V,I} <: AbstractDataGraph{V,Vector{I},Vector{I}} end

# Field access
data_graph(graph::AbstractIndsNetwork) = not_implemented()

# Overload if needed
is_directed(::Type{<:AbstractIndsNetwork}) = false

# AbstractDataGraphs overloads
vertex_data(graph::AbstractIndsNetwork, args...) = vertex_data(data_graph(graph), args...)
edge_data(graph::AbstractIndsNetwork, args...) = edge_data(data_graph(graph), args...)

# TODO: Define a generic fallback for `AbstractDataGraph`?
edge_data_type(::Type{<:AbstractIndsNetwork{V,I}}) where {V,I} = Vector{I}

# 
# Index access
# 

function uniqueinds(is::AbstractIndsNetwork, edge::AbstractEdge)
  inds = IndexSet(get(is, src(edge), Index[]))
  for ei in setdiff(incident_edges(is, src(edge)), [edge])
    inds = unioninds(inds, get(is, ei, Index[]))
  end
  return inds
end

function uniqueinds(is::AbstractIndsNetwork, edge::Pair)
  return uniqueinds(is, edgetype(is)(edge))
end

function union(tn1::AbstractIndsNetwork, tn2::AbstractIndsNetwork; kwargs...)
  return IndsNetwork(union(data_graph(tn1), data_graph(tn2); kwargs...))
end

function rename_vertices(f::Function, tn::AbstractIndsNetwork)
  return IndsNetwork(rename_vertices(f, data_graph(tn)))
end

# 
# Convenience functions
# 

function union_all_inds(is_in::AbstractIndsNetwork...)
  @assert all(map(ug -> ug == underlying_graph(is_in[1]), underlying_graph.(is_in)))
  is_out = IndsNetwork(underlying_graph(is_in[1]))
  for v in vertices(is_out)
    if any(isassigned(is, v) for is in is_in)
      is_out[v] = unioninds([get(is, v, Index[]) for is in is_in]...)
    end
  end
  for e in edges(is_out)
    if any(isassigned(is, e) for is in is_in)
      is_out[e] = unioninds([get(is, e, Index[]) for is in is_in]...)
    end
  end
  return is_out
end
