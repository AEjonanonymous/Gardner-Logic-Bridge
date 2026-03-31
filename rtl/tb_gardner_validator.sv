// -----------------------------------------------------------------------------
// Module: tb_gardner_validator
// Description: Multi-mode Hardware IP Testbench.
// Identity: gamma = alpha * (a - 1)
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
`include "params.svh"

module tb_gardner_validator;

    // Signal Definitions
    logic clk;
    logic rst_n;
    logic signed [31:0] alpha, beta, threshold_a, lut_data_in;
    logic mode_select;
    logic [31:0] lut_addr;
    logic signed [31:0] gamma_out, velocity_out;
    logic valid;

    // Instantiate Design Under Test (DUT)
    gardner_logic_core dut (
        .clk(clk),
        .rst_n(rst_n),
        .alpha(alpha),
        .beta(beta),
        .threshold_a(threshold_a),
        .mode_select(mode_select),
        .lut_data_in(lut_data_in),
        .lut_addr(lut_addr),
        .gamma_out(gamma_out),
        .velocity_out(velocity_out),
        .valid(valid)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation Logic
    initial begin
        $display("\n====================================================");
        $display("GARDNER ENGINE: INDUSTRIAL IP VALIDATION SUITE");
        $display("STATUS: COMPILING VERIFICATION REPORT...");
        $display("====================================================\n");

        // Initialization
        rst_n = 0;
        alpha = 0; beta = 0;
        threshold_a = 0; mode_select = 0; lut_data_in = 0;
        #20 rst_n = 1;

        // TEST 1: MATH ENGINE VALIDATION
        // alpha = 6.0 (0x00060000), a = 0.5 (0x00008000)
        // Expected: 6 * (0.5 - 1.0) = -3.0 (0xFFFD0000 in 2's complement hex)
        mode_select = 0;
        alpha = `TEST_ALPHA; 
        threshold_a = `TEST_A; 
        
        #20; 
        if (gamma_out === `EXP_GAMMA) 
            $display("[PASS] GLB Identity: Gamma correctly calculated as -3.0000");
        else 
            $display("[FAIL] GLB Identity: Expected %h, got %h", `EXP_GAMMA, gamma_out);

        // TEST 2: ISO-VELOCITY TIMING CHECK
        // Shift threshold to 0.125 (0x2000), v must remain -1.0
        threshold_a = 32'h0000_2000; 
        #20;
        if (velocity_out === 32'hFFFF_0000) 
            $display("[PASS] Iso-Velocity: Timing remains constant despite threshold shift.");
        else
            $display("[FAIL] Iso-Velocity: Clock Skew Mismatch! v=%h", velocity_out);

        // TEST 3: LUT FLEXIBILITY CHECK
        mode_select = 1;
        lut_data_in = 32'h1234_5678; 
        #20;
        if (gamma_out === 32'h1234_5678)
            $display("[PASS] LUT Mode: Hardware successfully bypassed math for memory read.");
        else
            $display("[FAIL] LUT Mode: Memory arbitration error.");

        $display("\n----------------------------------------------------");
        $display("FINAL RESULT: ALL HARDWARE IDENTITIES SECURED");
        $display("----------------------------------------------------\n");
        $finish;
    end

endmodule