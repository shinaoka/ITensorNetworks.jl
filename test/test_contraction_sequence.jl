using ITensors
using ITensorNetworks
using OMEinsumContractionOrders
using Random
using Test

Random.seed!(1234)

ITensors.disable_warn_order()

@testset "contraction_sequence" begin
  dims = (2, 3)
  g = named_grid(dims)
  s = siteinds("S=1/2", g)
  χ = 10
  ψ = randomITensorNetwork(s; link_space=χ)
  tn = norm_sqr_network(ψ)
  seq_optimal = contraction_sequence(tn; alg="optimal")
  res_optimal = contract(tn; sequence=seq_optimal)[]
  seq_greedy = contraction_sequence(tn; alg="greedy")
  res_greedy = contract(tn; sequence=seq_greedy)[]
  seq_tree_sa = contraction_sequence(tn; alg="tree_sa")
  res_tree_sa = contract(tn; sequence=seq_tree_sa)[]
  seq_sa_bipartite = contraction_sequence(tn; alg="sa_bipartite")
  res_sa_bipartite = contract(tn; sequence=seq_sa_bipartite)[]
  @test res_optimal ≈ res_greedy ≈ res_tree_sa ≈ res_sa_bipartite

  if !Sys.iswindows()
    # KaHyPar doesn't work on Windows
    # https://github.com/kahypar/KaHyPar.jl/issues/9
    using Pkg
    Pkg.add("KaHyPar")
    using KaHyPar
    seq_kahypar_bipartite = contraction_sequence(tn; alg="kahypar_bipartite", sc_target=200)
    res_kahypar_bipartite = contract(tn; sequence=seq_kahypar_bipartite)[]
    @test res_optimal ≈ res_kahypar_bipartite
  end
end
