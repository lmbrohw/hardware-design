`timescale 1ns / 1ps


module top(
        input wire clk,rst,
        output wire[31:0] writedata,dataadr,  // writedata和dataadr->sw 其中writedata是要存的数据
        output wire memwrite  // dataaddr是alu计算的结果M阶段
    );
    data_mem data_mem0 (
        .clka(clka),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [3 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina(dina),    // input wire [31 : 0] dina
        .douta(douta)  // output wire [31 : 0] douta
    );

    inst_mem inst_mem0 (
        .clka(clka),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [3 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina(dina),    // input wire [31 : 0] dina
        .douta(douta)  // output wire [31 : 0] douta
    );
endmodule

