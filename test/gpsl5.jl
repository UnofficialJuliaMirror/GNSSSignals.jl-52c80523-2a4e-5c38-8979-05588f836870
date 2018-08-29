@testset "Shift register" begin
    registers = 8191
    for i = 1:8191
        output_xb, registers = @inferred GNSSSignals.shift_register(registers, [1, 3, 4, 6, 7, 8, 12, 13])
        results = [2788, 2056 , 3322, 2087, 6431]
        if (i in [266, 804, 1559, 3471, 5343])
            @test registers in results
        end
    end
    @test registers == 8191
end

@testset "GPS L5" begin
    gps_l5 = GPSL5()
    code = @inferred gen_code(gps_l5, 0:10229, 10230, 0, 10230, 1)
    power = code.' * code / 10230
    @test power == 1 
    @test code == L5_SAT1_Code

    early = @inferred gen_code(gps_l5, 1:40920, 1023e4, 3.5, 4 * 1023e4, 2)
    prompt = @inferred gen_code(gps_l5, 1:40920, 1023e4, 4, 4 * 1023e4, 2)
    late = @inferred gen_code(gps_l5, 1:40920, 1023e4, 4.5, 4 * 1023e4, 2)
    @test early' * prompt == late' * prompt
end 

@testset "Neuman sequence" begin
    gps_l5 = GPSL5()
    code = gen_code(gps_l5, 0:103199, 10230, 0, 10230, 1)
    satellite_code = code[1:10230]
    NH_code = [0,0,0,0,1,1,0,1,0,1]
    for i = 1:10
        @test code[1+10230*(i-1):10230*i]== (satellite_code .* (Int8(-1)^NH_code[i]))
    end
    @test code[1:10230] == code[10231:20460]
end