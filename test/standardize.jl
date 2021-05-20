# This example is from https://spglib.github.io/spglib/definition.html#transformation-to-a-primitive-cell
@testset "Transformation to a primitive cell" begin
    lattice = [[7.17851431, 0, 0], [0, 3.99943947, 0], [0, 0, 8.57154746]]
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
    types = fill(8, length(positions))
    cell = Cell(lattice, positions, types)
    primitive_cell = find_primitive(cell)
    # Write transformation matrix directly
    @test primitive_cell.lattice ==
          cell.lattice * [
              1//2 1//2 0
              -1//2 1//2 0
              0 0 1
          ] ==
          [
              3.589257155 3.589257155 0.0
              -1.999719735 1.999719735 0.0
              0.0 0.0 8.57154746
          ]
    @test primitive_cell.positions ≈ [  # Python results
        0.15311561 0.34688439 0.65311561 0.84688439
        0.84688439 0.65311561 0.34688439 0.15311561
        0.1203133 0.6203133 0.3796867 0.8796867
    ]
    @test primitive_cell.types == [8, 8, 8, 8] ./ 8  # Python results
    @testset "Another way of writing the lattice and atomic positions" begin
        lattice = [
            7.17851431 0.0 0.0
            0.0 3.99943947 0.0
            0.0 0.0 8.57154746
        ]
        positions = [
            0.0 0.0 0.0 0.0 0.5 0.5 0.5 0.5
            0.84688439 0.65311561 0.34688439 0.15311561 0.34688439 0.15311561 0.84688439 0.65311561
            0.1203133 0.6203133 0.3796867 0.8796867 0.1203133 0.6203133 0.3796867 0.8796867
        ]
        cell = Cell(lattice, positions, types)
        # Results should not change
        new_primitive_cell = find_primitive(cell)
        @test primitive_cell == new_primitive_cell
        @test primitive_cell.lattice == new_primitive_cell.lattice
        @test primitive_cell.positions == new_primitive_cell.positions
        @test primitive_cell.types == new_primitive_cell.types
    end
end

@testset "Rotate the basis vectors rigidly in the above example" begin
    lattice = [
        [5.0759761474456697, 5.0759761474456697, 0],
        [-2.8280307701821314, 2.8280307701821314, 0],
        [0, 0, 8.57154746],
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
    types = fill(8, length(positions))
    cell = Cell(lattice, positions, types)
    primitive_cell = find_primitive(cell)
    # Compare with documented results
    @test cell.lattice * [
        1//2 1//2 0
        -1//2 1//2 0
        0 0 1
    ] ≈ [
        3.95200346 1.12397269 0.0
        1.12397269 3.95200346 0.0
        0.0 0.0 8.57154746
    ]
    # Compare with documented and Python results
    @test primitive_cell.lattice ≈ [
        3.58925715 3.58925715 0.0
        -1.99971973 1.99971973 0.0
        0.0 0.0 8.57154746
    ]
    @test primitive_cell.positions ≈ [  # Python results
        0.15311561 0.34688439 0.65311561 0.84688439
        0.84688439 0.65311561 0.34688439 0.15311561
        0.1203133 0.6203133 0.3796867 0.8796867
    ]
    @test primitive_cell.types == [8, 8, 8, 8] ./ 8  # Python results
    @testset "Obtain the rotated primitive cell basis vectors" begin
        primitive_cell = standardize_cell(cell, to_primitive = true, no_idealize = true)
        @test primitive_cell.lattice ≈ [
            3.95200346 1.12397269 0.0
            1.12397269 3.95200346 0.0
            0.0 0.0 8.57154746
        ]
    end
    @testset "Another way of writing the lattice and atomic positions" begin
        lattice = [
            5.07597614744567 -2.8280307701821314 0.0
            5.07597614744567 2.8280307701821314 0.0
            0.0 0.0 8.57154746
        ]
        positions = [
            0.0 0.0 0.0 0.0 0.5 0.5 0.5 0.5
            0.84688439 0.65311561 0.34688439 0.15311561 0.34688439 0.15311561 0.84688439 0.65311561
            0.1203133 0.6203133 0.3796867 0.8796867 0.1203133 0.6203133 0.3796867 0.8796867
        ]
        cell = Cell(lattice, positions, types)
        # Results should not change
        new_primitive_cell = find_primitive(cell)
        @test primitive_cell == new_primitive_cell
        @test primitive_cell.lattice == new_primitive_cell.lattice
        @test primitive_cell.positions == new_primitive_cell.positions
        @test primitive_cell.types == new_primitive_cell.types
    end
end