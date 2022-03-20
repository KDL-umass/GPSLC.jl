@testset "Kernel Functions" begin
    @testset "rbfKernelLog" begin
        @testset "Int64" begin
            expected = [-(11 - 11)^2 / 0.1]
            actual = rbfKernelLog([11], [11], 0.1)
            @test expected ≈ actual
        end
        @testset "Float64" begin
            val = 11.1
            expected = [-(val - val)^2 / 0.1]
            actual = rbfKernelLog([val], [val], 0.1)
            @test expected ≈ actual
        end
        @testset "Bool true" begin
            val = true
            expected = [-(val - val)^2 / 0.1]
            actual = rbfKernelLog([val], [val], 0.1)
            @test expected ≈ actual
        end
        @testset "Bool false" begin
            val = false
            expected = [-(val - val)^2 / 0.1]
            actual = rbfKernelLog([val], [val], 0.1)
            @test expected ≈ actual
        end
        @testset "PersistentVector Bool true" begin
            val = true
            expected = [-(val - val)^2 / 0.1]
            actual = rbfKernelLog(FunctionalCollections.PersistentVector{}([val]), FunctionalCollections.PersistentVector{}([val]), 0.1)
            @test expected ≈ actual
        end
        @testset "PersistentVector Bool false" begin
            val = false
            expected = [-(val - val)^2 / 0.1]
            actual = rbfKernelLog(FunctionalCollections.PersistentVector{}([val]), FunctionalCollections.PersistentVector{}([val]), 0.1)
            @test expected ≈ actual
        end
    end
    @testset "processCov" begin
        @testset "scale" begin
            scale = 2.0
            expected = ones(1, 1) * scale
            actual = processCov(zeros(1, 1), scale)
            @test expected == actual
        end
        @testset "noise" begin
            noise = 1e-5
            scale = 0.0
            expected = zeros(1, 1) .+ noise
            actual = processCov(zeros(1, 1), scale, noise)
            @test expected == actual
        end
        @testset "scale and noise" begin
            noise = 1e-5
            scale = 2.0
            expected = ones(1, 1) * scale .+ noise
            actual = processCov(zeros(1, 1), scale, noise)
            @test expected == actual
        end
    end
    @testset "logit" begin
        @test logit(0.5) == 0
    end
    @testset "expit" begin
        @test expit(0) == 0.5
    end
end