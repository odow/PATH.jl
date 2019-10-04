using PATH, Test

using MathOptInterface
const MOI = MathOptInterface

@testset "MOI.Name" begin
    model = PATH.Optimizer()
    @test MOI.get(model, MOI.SolverName()) == PATH.c_api_Path_Version()
end

@testset "Example 1" begin
    model = PATH.Optimizer()
    x = MOI.add_variables(model, 4)
    MOI.add_constraint.(model, MOI.SingleVariable.(x), MOI.Interval(0.0, 10.0))
    MOI.set.(model, MOI.VariablePrimalStart(), x, 0.0)
    M = Float64[
        0  0 -1 -1;
        0  0  1 -2;
        1 -1  2 -2;
        1  2 -2  4
    ]
    q = [2; 2; -2; -6]
    for i in 1:4
        terms = [
            MOI.VectorAffineTerm(2, MOI.ScalarAffineTerm(1.0, x[i]))
        ]
        for j in 1:4
            iszero(M[i, j]) && continue
            push!(
                terms,
                MOI.VectorAffineTerm(1, MOI.ScalarAffineTerm(M[i, j], x[j]))
            )
        end
        MOI.add_constraint(
            model,
            MOI.VectorAffineFunction(terms, [q[i], 0.0]),
            PATH.Complements()
        )
    end
    @test MOI.get(model, MOI.TerminationStatus()) == MOI.OPTIMIZE_NOT_CALLED
    MOI.optimize!(model)
    @test MOI.get(model, MOI.TerminationStatus()) == MOI.LOCALLY_SOLVED
    x_val = MOI.get.(model, MOI.VariablePrimal(), x)
    @test isapprox(x_val, [2.8, 0.0, 0.8, 1.2])
end