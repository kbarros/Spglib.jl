using Test

using Spglib

function type2dict(dt)
    di = Dict{Symbol,Any}()
    for n in propertynames(dt)
        di[n] = getproperty(dt, n)
    end
    return di
end

@testset "Construct a `Cell`" begin
    lattice = [
        [5.0759761474456697, 5.0759761474456697, 0],  # a
        [-2.8280307701821314, 2.8280307701821314, 0],  # b
        [0, 0, 8.57154746],  # c
    ]
    positions = [
        [0.0, 0.84688439, 0.1203133],
        [0.0, 0.65311561, 0.6203133],
        [0.0, 0.34688439, 0.3796867],
        [0.0, 0.15311561, 0.8796867],
        [0.5, 0.34688439, 0.1203133],
        [0.5, 0.15311561, 0.6203133],
        [0.5, 0.84688439, 0.3796867],
        [0.5, 0.65311561, 0.8796867],
    ]
    types = fill(35, length(positions))
    cell = Cell(lattice, positions, types)
    @test cell == Cell(
        [
            5.07597614744567 -2.8280307701821314 0.0
            5.07597614744567 2.8280307701821314 0.0
            0.0 0.0 8.57154746
        ],
        positions,
        types,
    )
    @test cell == Cell(
        lattice,
        [
            0.0 0.0 0.0 0.0 0.5 0.5 0.5 0.5
            0.84688439 0.65311561 0.34688439 0.15311561 0.34688439 0.15311561 0.84688439 0.65311561
            0.1203133 0.6203133 0.3796867 0.8796867 0.1203133 0.6203133 0.3796867 0.8796867
        ],
        types,
    )
    @test cell == Cell(
        [
            5.07597614744567 -2.8280307701821314 0.0
            5.07597614744567 2.8280307701821314 0.0
            0.0 0.0 8.57154746
        ],
        [
            0.0 0.0 0.0 0.0 0.5 0.5 0.5 0.5
            0.84688439 0.65311561 0.34688439 0.15311561 0.34688439 0.15311561 0.84688439 0.65311561
            0.1203133 0.6203133 0.3796867 0.8796867 0.1203133 0.6203133 0.3796867 0.8796867
        ],
        types,
    )
end

@testset "Test `get_spacegroup_type`" begin
    # Adapted from https://github.com/unkcpz/LibSymspg.jl/blob/53d2f6d/test/test_api.jl#L7-L12
    spacegroup_type = get_spacegroup_type(101)
    @test spacegroup_type.number == 15
    @test spacegroup_type.hall_symbol == "-I 2a"
    @test spacegroup_type.arithmetic_crystal_class_symbol == "2/mC"
    # These results are compared with Python's spglib results.
    @test type2dict(get_spacegroup_type(419)) == Dict(
        :number => 136,
        :international_short => "P4_2/mnm",
        :international_full => "P 4_2/m 2_1/n 2/m",
        :international => "P 4_2/m n m",
        :schoenflies => "D4h^14",
        :hall_symbol => "-P 4n 2n",
        :choice => "",
        :pointgroup_schoenflies => "D4h",
        :pointgroup_international => "4/mmm",
        :arithmetic_crystal_class_number => 36,
        :arithmetic_crystal_class_symbol => "4/mmmP",
    )
    @test type2dict(get_spacegroup_type(1)) == Dict(
        :number => 1,
        :international_short => "P1",
        :international_full => "P 1",
        :international => "P 1",
        :schoenflies => "C1^1",
        :hall_symbol => "P 1",
        :choice => "",
        :pointgroup_schoenflies => "C1",
        :pointgroup_international => "1",
        :arithmetic_crystal_class_number => 1,
        :arithmetic_crystal_class_symbol => "1P",
    )
    @test type2dict(get_spacegroup_type(525)) == Dict(
        :number => 227,
        :international_short => "Fd-3m",
        :international_full => "F 4_1/d -3 2/m",
        :international => "F d -3 m",
        :schoenflies => "Oh^7",
        :hall_symbol => "F 4d 2 3 -1d",
        :choice => "1",
        :pointgroup_schoenflies => "Oh",
        :pointgroup_international => "m-3m",
        :arithmetic_crystal_class_number => 72,
        :arithmetic_crystal_class_symbol => "m-3mF",
    )
    @test type2dict(get_spacegroup_type(485)) == Dict(
        :number => 191,
        :international_short => "P6/mmm",
        :international_full => "P 6/m 2/m 2/m",
        :international => "P 6/m m m",
        :schoenflies => "D6h^1",
        :hall_symbol => "-P 6 2",
        :choice => "",
        :pointgroup_schoenflies => "D6h",
        :pointgroup_international => "6/mmm",
        :arithmetic_crystal_class_number => 58,
        :arithmetic_crystal_class_symbol => "6/mmm",
    )
end

# @testset "Test MgB2 structure" begin
#     a = 3.07
#     c = 3.52
#     lattice = [
#         a 0 0
#         -a/2 a/2*sqrt(3) 0
#         0 0 c
#     ]
#     positions = [
#         0 0 0
#         1.0/3 2.0/3 0.5
#         2.0/3 1.0/3 0.5
#     ]
#     types = [12, 5, 5]
#     MgB2 = Cell(lattice, positions, types)
# end

# From https://github.com/unkcpz/LibSymspg.jl/blob/53d2f6d/test/test_api.jl#L34-L77
@testset "Get symmetry operations" begin
    @testset "Normal symmetry" begin
        lattice = [
            4.0 0.0 0.0
            0.0 4.0 0.0
            0.0 0.0 4.0
        ]
        positions = [
            0.0 0.5
            0.0 0.5
            0.0 0.5
        ]
        types = [1, 1]
        cell = Cell(lattice, positions, types)
        num_atom = length(types)
        max_size = num_atom * 48
        rotation = Array{Cint,3}(undef, 3, 3, max_size)
        translation = Array{Float64,2}(undef, 3, max_size)
        get_symmetry!(rotation, translation, cell, 1e-5)
        @test size(rotation) == (3, 3, 96)
        @test size(translation) == (3, 96)
        @test get_hall_number_from_symmetry(rotation, translation, max_size, 1e-5) == 529
    end
    # See https://github.com/spglib/spglib/blob/deb6695/python/test/test_collinear_spin.py#L18-L37
    @testset "Get symmetry with collinear spins" begin
        lattice = [
            4.0 0.0 0.0
            0.0 4.0 0.0
            0.0 0.0 4.0
        ]
        positions = [
            0.0 0.5
            0.0 0.5
            0.0 0.5
        ]
        types = [1, 1]
        @testset "Test ferromagnetism" begin
            magmoms = [1.0, 1.0]
            cell = Cell(lattice, positions, types, magmoms)
            rotation, translation, equivalent_atoms = get_symmetry_with_collinear_spin(
                cell, 1e-5
            )
            @test size(rotation) == (3, 3, 96)
            @test equivalent_atoms == [0, 0]
        end
        @testset "Test antiferromagnetism" begin
            magmoms = [1.0, -1.0]
            cell = Cell(lattice, positions, types, magmoms)
            rotation, translation, equivalent_atoms = get_symmetry_with_collinear_spin(
                cell, 1e-5
            )
            @test size(rotation) == (3, 3, 96)
            @test equivalent_atoms == [0, 0]
        end
        @testset "Test broken magmoms" begin
            magmoms = [1.0, 2.0]
            cell = Cell(lattice, positions, types, magmoms)
            rotation, translation, equivalent_atoms = get_symmetry_with_collinear_spin(
                cell, 1e-5
            )
            @test size(rotation) == (3, 3, 48)
            @test size(translation) == (3, 48)
            @test equivalent_atoms == [0, 1]
        end
    end

    @testset "Get multiplicity" begin
        lattice = [
            4.0 0.0 0.0
            0.0 4.0 0.0
            0.0 0.0 4.0
        ]
        positions = [
            0.0 0.5
            0.0 0.5
            0.0 0.5
        ]
        types = [1, 1]
        cell = Cell(lattice, positions, types)
        @test get_multiplicity(cell, 1e-5) == 96
    end
end
