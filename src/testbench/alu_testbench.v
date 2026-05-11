`timescale 1ns/1ps

module alu_testbench;

    parameter N=8;
    
    reg [N-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0]INP_VALID;
    reg [3:0] CMD;

    wire [2*N-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [2*N-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    alu_rtl #(.WIDTH(N)) dut (
        .OPA(OPA), .OPB(OPB),
        .CLK(CLK), .RST(RST), .CE(CE), .MODE(MODE), .CIN(CIN),
        .INP_VALID(INP_VALID), .CMD(CMD),
        .RES(RES_dut), .COUT(COUT_dut), .OFLOW(OFLOW_dut),
        .G(G_dut), .E(E_dut), .L(L_dut), .ERR(ERR_dut)
    );

    ALU_reference_model #(N) ref_model (
        .OPA(OPA), .OPB(OPB),
        .MODE(MODE), .CIN(CIN), .INP_VALID(INP_VALID), .CMD(CMD),
        .EXP_RES(RES_ref), .EXP_COUT(COUT_ref), .EXP_OFLOW(OFLOW_ref),
        .EXP_G(G_ref), .EXP_E(E_ref), .EXP_L(L_ref), .EXP_ERR(ERR_ref)
    );

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        RST = 1; CE = 1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0; INP_VALID = 0;
        
        #12;
        RST = 0;
        @(posedge CLK);

        $display("\n=== Testing CE Disable ===");
        test_ce_disable();

        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    task test_ce_disable;
        begin
            @(negedge CLK);
            CE = 0;
            OPA = 8'hAA;
            OPB = 8'h55;
            MODE = 0;
            CMD = 4'b0000;
            INP_VALID = 2'b11;

            @(posedge CLK);
            @(posedge CLK);

            @(negedge CLK);
            CE = 1;
            OPA = 0;
            OPB = 0;
            CMD = 0;
            INP_VALID = 0;

            @(posedge CLK);
        end
    endtask

    task test_arithmetic();
        begin
            apply_test(8'h01, 8'h01, 4'b0000, 2'b11, "ADD basic 1+1", 2);
            apply_test(8'h00, 8'h00, 4'b0000, 2'b11, "ADD zero+zero", 2);
            apply_test(8'hFF, 8'h00, 4'b0000, 2'b11, "ADD max+zero", 2);
            apply_test(8'hFF, 8'h01, 4'b0000, 2'b11, "ADD FF+1 with cout", 2);
            apply_test(8'hFF, 8'hFF, 4'b0000, 2'b11, "ADD FF+FF with cout", 2);
            apply_test(8'hAA, 8'h55, 4'b0000, 2'b11, "ADD alternating AA+55", 2);
            apply_test(8'h00, 8'h00, 4'b0000, 2'b00, "ADD wrong inp_valid 00", 2);
            apply_test(8'h00, 8'h00, 4'b0000, 2'b01, "ADD wrong inp_valid 01", 2);
            apply_test(8'h00, 8'h00, 4'b0000, 2'b10, "ADD wrong inp_valid 10", 2);

            apply_test(8'd5, 8'd1, 4'b0001, 2'b11, "SUB basic 5-1", 2);
            apply_test(8'd0, 8'd0, 4'b0001, 2'b11, "SUB zero-zero", 2);
            apply_test(8'd5, 8'd5, 4'b0001, 2'b11, "SUB same operands 5-5", 2);
            apply_test(8'd0, 8'd1, 4'b0001, 2'b11, "SUB borrow 0-1", 2);
            apply_test(8'd2, 8'd3, 4'b0001, 2'b11, "SUB borrow 2-3", 2);
            apply_test(8'd255, 8'd1, 4'b0001, 2'b11, "SUB max-1", 2);
            apply_test(8'd255, 8'd255, 4'b0001, 2'b11, "SUB max-max", 2);
            apply_test(8'hAA, 8'h55, 4'b0001, 2'b11, "SUB alternating AA-55", 2);
            apply_test(8'd5, 8'd1, 4'b0001, 2'b00, "SUB wrong inp_valid 00", 2);
            apply_test(8'd5, 8'd1, 4'b0001, 2'b01, "SUB wrong inp_valid 01", 2);
            apply_test(8'd5, 8'd1, 4'b0001, 2'b10, "SUB wrong inp_valid 10", 2);

            CIN = 1'b1;
            apply_test(8'd0, 8'd0, 4'b0010, 2'b11, "ADD_CIN 0+0+1", 2);
            apply_test(8'd3, 8'd3, 4'b0010, 2'b11, "ADD_CIN basic 3+3+1", 2);
            apply_test(8'd255, 8'd0, 4'b0010, 2'b11, "ADD_CIN 255+0+1 with cout", 2);
            apply_test(8'd255, 8'd255, 4'b0010, 2'b11, "ADD_CIN 255+255+1 with cout", 2);
            apply_test(8'd128, 8'd127, 4'b0010, 2'b11, "ADD_CIN 128+127+1 with cout", 2);
            apply_test(8'd3, 8'd3, 4'b0010, 2'b00, "ADD_CIN wrong inp_valid 00", 2);
            apply_test(8'd3, 8'd3, 4'b0010, 2'b01, "ADD_CIN wrong inp_valid 01", 2);
            apply_test(8'd3, 8'd3, 4'b0010, 2'b10, "ADD_CIN wrong inp_valid 10", 2);
            CIN = 1'b0;
            apply_test(8'd2, 8'd2, 4'b0010, 2'b11, "ADD_CIN with CIN 0", 2);

            CIN = 1'b1;
            apply_test(8'd5, 8'd1, 4'b0011, 2'b11, "SUB_CIN basic 5-1-1", 2);
            apply_test(8'd0, 8'd0, 4'b0011, 2'b11, "SUB_CIN 0-0-1 borrow", 2);
            apply_test(8'd5, 8'd5, 4'b0011, 2'b11, "SUB_CIN same operands 5-5-1 borrow", 2);
            apply_test(8'd0, 8'd1, 4'b0011, 2'b11, "SUB_CIN 0-1-1 borrow", 2);
            apply_test(8'd255, 8'd1, 4'b0011, 2'b11, "SUB_CIN max-1-1", 2);
            apply_test(8'd255, 8'd255, 4'b0011, 2'b11, "SUB_CIN max-max-1 borrow", 2);
            apply_test(8'hAA, 8'h55, 4'b0011, 2'b11, "SUB_CIN alternating AA-55-1", 2);
            apply_test(8'd5, 8'd1, 4'b0011, 2'b00, "SUB_CIN wrong inp_valid 00", 2);
            apply_test(8'd5, 8'd1, 4'b0011, 2'b01, "SUB_CIN wrong inp_valid 01", 2);
            apply_test(8'd5, 8'd1, 4'b0011, 2'b10, "SUB_CIN wrong inp_valid 10", 2);
            CIN = 1'b0;
            apply_test(8'd5, 8'd1, 4'b0011, 2'b11, "SUB_CIN with CIN 0", 2);

            apply_test(8'd5, 8'd0, 4'b0100, 2'b01, "INC_A basic 5+1", 2);
            apply_test(8'd0, 8'd0, 4'b0100, 2'b01, "INC_A 0+1", 2);
            apply_test(8'd255, 8'd0, 4'b0100, 2'b01, "INC_A FF+1", 2);
            apply_test(8'd5, 8'd0, 4'b0100, 2'b11, "INC_A both valid", 2);
            apply_test(8'd5, 8'd0, 4'b0100, 2'b00, "INC_A wrong inp_valid 00", 2);
            apply_test(8'd5, 8'd0, 4'b0100, 2'b10, "INC_A wrong inp_valid 10", 2);

            apply_test(8'd5, 8'd0, 4'b0101, 2'b01, "DEC_A basic 5-1", 2);
            apply_test(8'd1, 8'd0, 4'b0101, 2'b01, "DEC_A 1-1 gives zero", 2);
            apply_test(8'd0, 8'd0, 4'b0101, 2'b01, "DEC_A 0-1 underflow", 2);
            apply_test(8'd5, 8'd0, 4'b0101, 2'b11, "DEC_A both valid", 2);
            apply_test(8'd5, 8'd0, 4'b0101, 2'b00, "DEC_A wrong inp_valid 00", 2);
            apply_test(8'd5, 8'd0, 4'b0101, 2'b10, "DEC_A wrong inp_valid 10", 2);

            apply_test(8'd0, 8'd5, 4'b0110, 2'b10, "INC_B basic 5+1", 2);
            apply_test(8'd0, 8'd0, 4'b0110, 2'b10, "INC_B 0+1", 2);
            apply_test(8'd0, 8'd255, 4'b0110, 2'b10, "INC_B FF+1", 2);
            apply_test(8'd0, 8'd5, 4'b0110, 2'b11, "INC_B both valid", 2);
            apply_test(8'd0, 8'd5, 4'b0110, 2'b00, "INC_B wrong inp_valid 00", 2);
            apply_test(8'd0, 8'd5, 4'b0110, 2'b01, "INC_B wrong inp_valid 01", 2);

            apply_test(8'd0, 8'd5, 4'b0111, 2'b10, "DEC_B basic 5-1", 2);
            apply_test(8'd0, 8'd1, 4'b0111, 2'b10, "DEC_B 1-1 gives zero", 2);
            apply_test(8'd0, 8'd0, 4'b0111, 2'b10, "DEC_B 0-1 underflow", 2);
            apply_test(8'd0, 8'd5, 4'b0111, 2'b11, "DEC_B both valid", 2);
            apply_test(8'd0, 8'd5, 4'b0111, 2'b00, "DEC_B wrong inp_valid 00", 2);
            apply_test(8'd0, 8'd5, 4'b0111, 2'b01, "DEC_B wrong inp_valid 01", 2);

            apply_test(8'd5, 8'd3, 4'b1000, 2'b11, "COMPARE A greater than B", 2);
            apply_test(8'd3, 8'd5, 4'b1000, 2'b11, "COMPARE A less than B", 2);
            apply_test(8'd5, 8'd5, 4'b1000, 2'b11, "COMPARE A equal B", 2);
            apply_test(8'd0, 8'd0, 4'b1000, 2'b11, "COMPARE zero equal zero", 2);
            apply_test(8'd255, 8'd0, 4'b1000, 2'b11, "COMPARE max greater than zero", 2);
            apply_test(8'd0, 8'd255, 4'b1000, 2'b11, "COMPARE zero less than max", 2);
            apply_test(8'hAA, 8'h55, 4'b1000, 2'b11, "COMPARE alternating AA greater than 55", 2);
            apply_test(8'd5, 8'd3, 4'b1000, 2'b00, "COMPARE wrong inp_valid 00", 2);
            apply_test(8'd5, 8'd3, 4'b1000, 2'b01, "COMPARE wrong inp_valid 01", 2);
            apply_test(8'd5, 8'd3, 4'b1000, 2'b10, "COMPARE wrong inp_valid 10", 2);

            apply_test(8'd1, 8'd1, 4'b1001, 2'b11, "INC_MUL basic (1+1)*(1+1)", 3);
            apply_test(8'd0, 8'd0, 4'b1001, 2'b11, "INC_MUL zero zero (0+1)*(0+1)", 3);
            apply_test(8'd2, 8'd3, 4'b1001, 2'b11, "INC_MUL normal (2+1)*(3+1)", 3);
            apply_test(8'd255, 8'd0, 4'b1001, 2'b11, "INC_MUL max A (255+1)*(0+1)", 3);
            apply_test(8'd0, 8'd255, 4'b1001, 2'b11, "INC_MUL max B (0+1)*(255+1)", 3);
            apply_test(8'd255, 8'd255, 4'b1001, 2'b11, "INC_MUL max max (255+1)*(255+1)", 3);
            apply_test(8'hAA, 8'h55, 4'b1001, 2'b11, "INC_MUL alternating (AA+1)*(55+1)", 3);
            apply_test(8'd2, 8'd3, 4'b1001, 2'b00, "INC_MUL wrong inp_valid 00", 3);
            apply_test(8'd2, 8'd3, 4'b1001, 2'b01, "INC_MUL wrong inp_valid 01", 3);
            apply_test(8'd2, 8'd3, 4'b1001, 2'b10, "INC_MUL wrong inp_valid 10", 3);

            apply_test(8'd1, 8'd1, 4'b1010, 2'b11, "MUL_2 basic (1<<1)*1", 3);
            apply_test(8'd0, 8'd5, 4'b1010, 2'b11, "MUL_2 zero A", 3);
            apply_test(8'd5, 8'd0, 4'b1010, 2'b11, "MUL_2 zero B", 3);
            apply_test(8'd2, 8'd3, 4'b1010, 2'b11, "MUL_2 normal (2<<1)*3", 3);
            apply_test(8'd7, 8'd2, 4'b1010, 2'b11, "MUL_2 edge (7<<1)*2", 3);
            apply_test(8'd128, 8'd2, 4'b1010, 2'b11, "MUL_2 shift edge (128<<1)*2", 3);
            apply_test(8'd255, 8'd1, 4'b1010, 2'b11, "MUL_2 max A", 3);
            apply_test(8'd255, 8'd255, 4'b1010, 2'b11, "MUL_2 max max", 3);
            apply_test(8'hAA, 8'h55, 4'b1010, 2'b11, "MUL_2 alternating AA and 55", 3);
            apply_test(8'd2, 8'd3, 4'b1010, 2'b00, "MUL_2 wrong inp_valid 00", 3);
            apply_test(8'd2, 8'd3, 4'b1010, 2'b01, "MUL_2 wrong inp_valid 01", 3);
            apply_test(8'd2, 8'd3, 4'b1010, 2'b10, "MUL_2 wrong inp_valid 10", 3);

            apply_test(8'sd3, 8'sd2, 4'b1011, 2'b11, "SIGNED_ADD positive + positive 3+2", 2);
            apply_test(-8'sd2, -8'sd1, 4'b1011, 2'b11, "SIGNED_ADD negative + negative -2 + -1", 2);
            apply_test(-8'sd1, 8'sd3, 4'b1011, 2'b11, "SIGNED_ADD negative + positive -1 + 3", 2);
            apply_test(8'sd127, 8'sd1, 4'b1011, 2'b11, "SIGNED_ADD positive overflow 127+1", 2);
            apply_test(-8'sd128, -8'sd1, 4'b1011, 2'b11, "SIGNED_ADD negative overflow -128 + -1", 2);
            apply_test(8'sd0, 8'sd0, 4'b1011, 2'b11, "SIGNED_ADD zero + zero", 2);
            apply_test(8'sd10, -8'sd5, 4'b1011, 2'b11, "SIGNED_ADD positive plus negative", 2);
            apply_test(-8'sd10, 8'sd5, 4'b1011, 2'b11, "SIGNED_ADD negative plus positive", 2);
            apply_test(8'sd3, 8'sd2, 4'b1011, 2'b00, "SIGNED_ADD wrong inp_valid 00", 2);
            apply_test(8'sd3, 8'sd2, 4'b1011, 2'b01, "SIGNED_ADD wrong inp_valid 01", 2);
            apply_test(8'sd3, 8'sd2, 4'b1011, 2'b10, "SIGNED_ADD wrong inp_valid 10", 2);

            apply_test(8'sd5, 8'sd2, 4'b1100, 2'b11, "SIGNED_SUB positive - positive 5-2", 2);
            apply_test(-8'sd2, -8'sd1, 4'b1100, 2'b11, "SIGNED_SUB negative - negative -2 - -1", 2);
            apply_test(8'sd3, -8'sd1, 4'b1100, 2'b11, "SIGNED_SUB positive - negative 3 - -1", 2);
            apply_test(-8'sd1, 8'sd3, 4'b1100, 2'b11, "SIGNED_SUB negative - positive -1 - 3", 2);
            apply_test(8'sd127, -8'sd1, 4'b1100, 2'b11, "SIGNED_SUB positive overflow 127 - -1", 2);
            apply_test(-8'sd128, 8'sd1, 4'b1100, 2'b11, "SIGNED_SUB negative overflow -128 - 1", 2);
            apply_test(8'sd0, 8'sd0, 4'b1100, 2'b11, "SIGNED_SUB zero - zero", 2);
            apply_test(8'sd10, 8'sd5, 4'b1100, 2'b11, "SIGNED_SUB positive-positive", 2);
            apply_test(-8'sd10, -8'sd5, 4'b1100, 2'b11, "SIGNED_SUB negative-negative", 2);
            apply_test(8'sd5, 8'sd2, 4'b1100, 2'b00, "SIGNED_SUB wrong inp_valid 00", 2);
            apply_test(8'sd5, 8'sd2, 4'b1100, 2'b01, "SIGNED_SUB wrong inp_valid 01", 2);
            apply_test(8'sd5, 8'sd2, 4'b1100, 2'b10, "SIGNED_SUB wrong inp_valid 10", 2);

            apply_test(8'd10, 8'd5, 4'b1111, 2'b11, "ARITH invalid command 1111", 2);
        end
    endtask

    task test_logical();
        begin
            apply_test(8'hAA, 8'h55, 4'b0000, 2'b11, "AND valid AA&55", 2);
            apply_test(8'hFF, 8'hAA, 4'b0000, 2'b11, "AND valid FF&AA", 2);
            apply_test(8'hAA, 8'h55, 4'b0000, 2'b00, "AND wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0000, 2'b01, "AND wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0000, 2'b10, "AND wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b0001, 2'b11, "NAND valid AA&55", 2);
            apply_test(8'hFF, 8'hAA, 4'b0001, 2'b11, "NAND valid FF&AA", 2);
            apply_test(8'hAA, 8'h55, 4'b0001, 2'b00, "NAND wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0001, 2'b01, "NAND wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0001, 2'b10, "NAND wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b0010, 2'b11, "OR valid AA|55", 2);
            apply_test(8'h00, 8'h55, 4'b0010, 2'b11, "OR valid 00|55", 2);
            apply_test(8'hAA, 8'h55, 4'b0010, 2'b00, "OR wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0010, 2'b01, "OR wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0010, 2'b10, "OR wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b0011, 2'b11, "NOR valid AA|55", 2);
            apply_test(8'h00, 8'h00, 4'b0011, 2'b11, "NOR valid 00|00", 2);
            apply_test(8'hAA, 8'h55, 4'b0011, 2'b00, "NOR wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0011, 2'b01, "NOR wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0011, 2'b10, "NOR wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b0100, 2'b11, "XOR valid AA^55", 2);
            apply_test(8'hFF, 8'hFF, 4'b0100, 2'b11, "XOR valid FF^FF", 2);
            apply_test(8'hAA, 8'h55, 4'b0100, 2'b00, "XOR wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0100, 2'b01, "XOR wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0100, 2'b10, "XOR wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b0101, 2'b11, "XNOR valid AA^55", 2);
            apply_test(8'hFF, 8'hFF, 4'b0101, 2'b11, "XNOR valid FF^FF", 2);
            apply_test(8'hAA, 8'h55, 4'b0101, 2'b00, "XNOR wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h55, 4'b0101, 2'b01, "XNOR wrong inp_valid 01", 2);
            apply_test(8'hAA, 8'h55, 4'b0101, 2'b10, "XNOR wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h00, 4'b0110, 2'b01, "NOT_A valid ~AA", 2);
            apply_test(8'hFF, 8'h00, 4'b0110, 2'b01, "NOT_A valid ~FF", 2);
            apply_test(8'hAA, 8'h00, 4'b0110, 2'b11, "NOT_A both valid", 2);
            apply_test(8'hAA, 8'h00, 4'b0110, 2'b00, "NOT_A wrong inp_valid 00", 2);
            apply_test(8'hAA, 8'h00, 4'b0110, 2'b10, "NOT_A wrong inp_valid 10", 2);

            apply_test(8'h00, 8'hAA, 4'b0111, 2'b10, "NOT_B valid ~AA", 2);
            apply_test(8'h00, 8'hFF, 4'b0111, 2'b10, "NOT_B valid ~FF", 2);
            apply_test(8'h00, 8'hAA, 4'b0111, 2'b11, "NOT_B both valid", 2);
            apply_test(8'h00, 8'hAA, 4'b0111, 2'b00, "NOT_B wrong inp_valid 00", 2);
            apply_test(8'h00, 8'hAA, 4'b0111, 2'b01, "NOT_B wrong inp_valid 01", 2);

            apply_test(8'b10101010, 8'h00, 4'b1000, 2'b01, "SHR_A valid 10101010>>1", 2);
            apply_test(8'b00000001, 8'h00, 4'b1000, 2'b01, "SHR_A valid 00000001>>1", 2);
            apply_test(8'b10101010, 8'h00, 4'b1000, 2'b11, "SHR_A both valid", 2);
            apply_test(8'b10101010, 8'h00, 4'b1000, 2'b00, "SHR_A wrong inp_valid 00", 2);
            apply_test(8'b10101010, 8'h00, 4'b1000, 2'b10, "SHR_A wrong inp_valid 10", 2);

            apply_test(8'b01010101, 8'h00, 4'b1001, 2'b01, "SHL_A valid 01010101<<1", 2);
            apply_test(8'b10000000, 8'h00, 4'b1001, 2'b01, "SHL_A valid 10000000<<1", 2);
            apply_test(8'b01010101, 8'h00, 4'b1001, 2'b11, "SHL_A both valid", 2);
            apply_test(8'b01010101, 8'h00, 4'b1001, 2'b00, "SHL_A wrong inp_valid 00", 2);
            apply_test(8'b01010101, 8'h00, 4'b1001, 2'b10, "SHL_A wrong inp_valid 10", 2);

            apply_test(8'h00, 8'b10101010, 4'b1010, 2'b10, "SHR_B valid 10101010>>1", 2);
            apply_test(8'h00, 8'b00000001, 4'b1010, 2'b10, "SHR_B valid 00000001>>1", 2);
            apply_test(8'h00, 8'b10101010, 4'b1010, 2'b11, "SHR_B both valid", 2);
            apply_test(8'h00, 8'b10101010, 4'b1010, 2'b00, "SHR_B wrong inp_valid 00", 2);
            apply_test(8'h00, 8'b10101010, 4'b1010, 2'b01, "SHR_B wrong inp_valid 01", 2);

            apply_test(8'h00, 8'b01010101, 4'b1011, 2'b10, "SHL_B valid 01010101<<1", 2);
            apply_test(8'h00, 8'b10000000, 4'b1011, 2'b10, "SHL_B valid 10000000<<1", 2);
            apply_test(8'h00, 8'b01010101, 4'b1011, 2'b11, "SHL_B both valid", 2);
            apply_test(8'h00, 8'b01010101, 4'b1011, 2'b00, "SHL_B wrong inp_valid 00", 2);
            apply_test(8'h00, 8'b01010101, 4'b1011, 2'b01, "SHL_B wrong inp_valid 01", 2);

            apply_test(8'b10010110, 8'd0, 4'b1100, 2'b11, "ROL_A rotate by 0 no change", 2);
            apply_test(8'b10010110, 8'd1, 4'b1100, 2'b11, "ROL_A rotate by 1", 2);
            apply_test(8'b10010110, 8'd2, 4'b1100, 2'b11, "ROL_A rotate by 2", 2);
            apply_test(8'b10010110, 8'd3, 4'b1100, 2'b11, "ROL_A rotate by 3", 2);
            apply_test(8'b10010110, 8'd4, 4'b1100, 2'b11, "ROL_A rotate by 4", 2);
            apply_test(8'b10010110, 8'd5, 4'b1100, 2'b11, "ROL_A rotate by 5", 2);
            apply_test(8'b10010110, 8'd6, 4'b1100, 2'b11, "ROL_A rotate by 6", 2);
            apply_test(8'b10010110, 8'd7, 4'b1100, 2'b11, "ROL_A rotate by 7", 2);
            apply_test(8'b00000000, 8'd1, 4'b1100, 2'b11, "ROL_A all zero no rotate effect", 2);
            apply_test(8'b11111111, 8'd2, 4'b1100, 2'b11, "ROL_A all ones no rotate effect", 2);
            apply_test(8'b10010110, 8'b00010000, 4'b1100, 2'b11, "ROL_A OPB4 error", 2);
            apply_test(8'b10010110, 8'b00100000, 4'b1100, 2'b11, "ROL_A OPB5 error", 2);
            apply_test(8'b10010110, 8'b01000000, 4'b1100, 2'b11, "ROL_A OPB6 error", 2);
            apply_test(8'b10010110, 8'b10000000, 4'b1100, 2'b11, "ROL_A OPB7 error", 2);
            apply_test(8'b10010110, 8'b11110000, 4'b1100, 2'b11, "ROL_A all upper OPB error", 2);
            apply_test(8'b10010110, 8'd1, 4'b1100, 2'b00, "ROL_A wrong inp_valid 00", 2);
            apply_test(8'b10010110, 8'd1, 4'b1100, 2'b01, "ROL_A wrong inp_valid 01", 2);
            apply_test(8'b10010110, 8'd1, 4'b1100, 2'b10, "ROL_A wrong inp_valid 10", 2);

            apply_test(8'b10010110, 8'd0, 4'b1101, 2'b11, "ROR_A rotate by 0 no change", 2);
            apply_test(8'b10010110, 8'd1, 4'b1101, 2'b11, "ROR_A rotate by 1", 2);
            apply_test(8'b10010110, 8'd2, 4'b1101, 2'b11, "ROR_A rotate by 2", 2);
            apply_test(8'b10010110, 8'd3, 4'b1101, 2'b11, "ROR_A rotate by 3", 2);
            apply_test(8'b10010110, 8'd4, 4'b1101, 2'b11, "ROR_A rotate by 4", 2);
            apply_test(8'b10010110, 8'd5, 4'b1101, 2'b11, "ROR_A rotate by 5", 2);
            apply_test(8'b10010110, 8'd6, 4'b1101, 2'b11, "ROR_A rotate by 6", 2);
            apply_test(8'b10010110, 8'd7, 4'b1101, 2'b11, "ROR_A rotate by 7", 2);
            apply_test(8'b00000000, 8'd1, 4'b1101, 2'b11, "ROR_A all zero no rotate effect", 2);
            apply_test(8'b11111111, 8'd2, 4'b1101, 2'b11, "ROR_A all ones no rotate effect", 2);
            apply_test(8'b10010110, 8'b00010000, 4'b1101, 2'b11, "ROR_A OPB4 error", 2);
            apply_test(8'b10010110, 8'b00100000, 4'b1101, 2'b11, "ROR_A OPB5 error", 2);
            apply_test(8'b10010110, 8'b01000000, 4'b1101, 2'b11, "ROR_A OPB6 error", 2);
            apply_test(8'b10010110, 8'b10000000, 4'b1101, 2'b11, "ROR_A OPB7 error", 2);
            apply_test(8'b10010110, 8'b11110000, 4'b1101, 2'b11, "ROR_A all upper OPB error", 2);
            apply_test(8'b10010110, 8'd1, 4'b1101, 2'b00, "ROR_A wrong inp_valid 00", 2);
            apply_test(8'b10010110, 8'd1, 4'b1101, 2'b01, "ROR_A wrong inp_valid 01", 2);
            apply_test(8'b10010110, 8'd1, 4'b1101, 2'b10, "ROR_A wrong inp_valid 10", 2);

            apply_test(8'hAA, 8'h55, 4'b1111, 2'b11, "LOGIC invalid command 1111", 2);
        end
    endtask

    task apply_test;
        input [N-1:0] a, b;
        input [3:0] cmd;
        input [1:0] inp_valid;
        input [80*8:1] test_name;
        input integer wait_cycles;
        integer i;

        begin
            @(negedge CLK);

            OPA = a;
            OPB = b;
            CMD = cmd;
            INP_VALID = inp_valid;

            for(i=0; i<wait_cycles; i=i+1)
                @(posedge CLK);

            test_count = test_count + 1;

            if(compare_outputs(1'b0)) begin
                $display("[PASS] %s", test_name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] %s", test_name);
                display_mismatch();
                fail_count = fail_count + 1;
            end
        end
    endtask

    function compare_outputs;
        input dummy;

        begin
            compare_outputs =
                (RES_dut    === RES_ref)   &&
                (COUT_dut  === COUT_ref)  &&
                (OFLOW_dut === OFLOW_ref) &&
                (G_dut     === G_ref)     &&
                (E_dut     === E_ref)     &&
                (L_dut     === L_ref)     &&
                (ERR_dut   === ERR_ref);
        end
    endfunction

    task display_mismatch;
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut,
                     G_dut, E_dut, L_dut, ERR_dut);

            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref,
                     G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule
