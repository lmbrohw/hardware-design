//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  ex
// File:    ex.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 执行阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex(

	input wire										rst,
	
	//送到执行阶段的信息
	input wire[`AluOpBus]         aluop_i,
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]           reg1_i,  // 对应着操作数
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,    // 写到寄存器的地址
	input wire                    wreg_i,  // 是否写


	// 因为数据移动指令(HILO)而添加的接口
	input wire[`RegBus]			  hi_i,  // 对应Hilo寄存器的值
	input wire[`RegBus]			  lo_i,
	input wire                    mem_whilo_i,  // 处于访存阶段的指令是不是要写Hilo
	input wire[`RegBus]			  mem_hi_i,  // 访存阶段要写入hi寄存器的值
	input wire[`RegBus]			  mem_lo_i,  // 访存阶段要写入lo寄存器的值
	input wire                    wb_whilo_i,  // 处于写回阶段的指令是不是要写Hilo
	input wire[`RegBus]			  wb_hi_i,  // 写回阶段要写入hi寄存器的值
	input wire[`RegBus]			  wb_lo_i,  // 写回阶段要写入lo寄存器的值
	output reg                    whilo_o,  // 是否要写Hilo
	output reg[`RegBus]			  hi_o,  // 写入hi的值 
	output reg[`RegBus]			  lo_o,  // 写入lo的值


	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus]			  wdata_o
	
);

	reg[`RegBus] logicres;  // 保留逻辑运算结果
	reg[`RegBus] shiftres;  // 保留移位运算结果
	reg[`RegBus] Hilores;  // 保留数据移动指令(HILO)运算结果
	reg[`RegBus] shiftzerores;  // 保留movn和movz两条指令的结果
	reg[`RegBus] HI;
	reg[`RegBus] LO;

	// 逻辑运算
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_AND_OP: begin
					logicres <= reg1_i & reg2_i;
				end
				`EXE_OR_OP:			begin
					logicres <= reg1_i | reg2_i;
				end
				`EXE_XOR_OP:			begin
					logicres <= reg1_i ^ reg2_i;
				end
				`EXE_NOR_OP:			begin
					logicres <= ~(reg1_i | reg2_i);
				end
				default:				begin
					logicres <= `ZeroWord;
				end
			endcase
		end    
	end

	// 移位运算
	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP: begin
					// shiftres <= reg2_i << reg1_i;  // 默认用0填充
					shiftres <= reg2_i << reg1_i[4:0];  // 默认用0填充, 立即数的低五位
				end
				`EXE_SRL_OP:			begin
					// shiftres <= reg2_i >> reg1_i;
					shiftres <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP:			begin
					// shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) 
					// 							| reg2_i >> reg1_i[4:0];
					// shiftres <= ({32{reg2_i[31]}} << (~reg1_i[4:0]))  // 32-1，不可行
					// 							| reg2_i >> reg1_i[4:0];
					shiftres <= ($signed(reg2_i)) >>> reg1_i[4:0];
				end
				default:				begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    
	end   


	// HILO指令
	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			// whilo_o <= `WriteDisable;  // 默认不向Hilo寄存器写,向这一种写法在这里不可以可能受到干扰
			case (aluop_i)
				`EXE_MFHI_OP: begin
					whilo_o <= `WriteDisable;
					if(mem_whilo_i == 1'b1) begin
						hi_o <= mem_hi_i;
					end else if (wb_whilo_i == 1'b1) begin
						hi_o <= wb_hi_i;
					end else begin
						hi_o <= hi_i;
					end
					Hilores <= hi_o;
				end
				`EXE_MFLO_OP:			begin
					whilo_o <= `WriteDisable;
					// if(wb_whilo_i == 1'b1) begin  // 就是这个顺序写反了, 
					// 	lo_o <= wb_lo_i;
					// end else if (mem_whilo_i == 1'b1) begin
					// 	lo_o <= mem_lo_i;
					// end else begin
					// 	lo_o <= lo_i;
					// end
					if(mem_whilo_i == 1'b1) begin
						lo_o <= mem_lo_i;
					end else if (wb_whilo_i == 1'b1) begin
						lo_o <= wb_lo_i;
					end else begin
						lo_o <= lo_i;
					end
					Hilores <= lo_o;
				end
				// 首先要解决数据相关问题,这样写的MTHI，MTLO指令
				// 会产生一个问题,因为写Hilo寄存器是同时写的
				// 就是当需要写Hilo寄存器的时候,导致没有写的寄存器中的值变为x
				// `EXE_MTHI_OP:			begin 
				// 	whilo_o <= `WriteEnable;
				// 	hi_o <= reg1_i;
				// 	// Hilores <= hi_o;
				// end
				// `EXE_MTLO_OP:			begin
				// 	whilo_o <= `WriteEnable;
				// 	lo_o <= reg1_i;
				// 	// Hilores <= lo_o;
				// end
				default:				begin
					Hilores <= `ZeroWord;
				end
			endcase
		end    
	end   
	
	
	//得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
	always @ (*) begin
		if(rst == `RstEnable) begin
			{HI,LO} <= {`ZeroWord,`ZeroWord};
		end else if(mem_whilo_i == `WriteEnable) begin
			{HI,LO} <= {mem_hi_i,mem_lo_i};
		end else if(wb_whilo_i == `WriteEnable) begin
			{HI,LO} <= {wb_hi_i,wb_lo_i};
		end else begin
			{HI,LO} <= {hi_i,lo_i};			
		end
	end	


	//MFHI、MFLO、MTHI、MTLO指令 这里分别处理
	//MFHI、MFLO、MOVN、MOVZ指令
	// always @ (*) begin
	// 	if(rst == `RstEnable) begin
	//   	Hilores <= `ZeroWord;
	//   end else begin
	// //    Hilores <= `ZeroWord;
	// //    whilo_o <= `WriteDisable;
	//    case (aluop_i)
	//    	`EXE_MFHI_OP:		begin
	//    		Hilores <= HI;
	//    	end
	//    	`EXE_MFLO_OP:		begin
	//    		Hilores <= LO;
	//    	end
	//    	// `EXE_MOVZ_OP:		begin
	//    	// 	Hilores <= reg1_i;
	//    	// end
	//    	// `EXE_MOVN_OP:		begin
	//    	// 	Hilores <= reg1_i;
	//    	// end
	//    	default : begin
	//    	end
	//    endcase
	//   end
	// end	 
	always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		end else if(aluop_i == `EXE_MTHI_OP) begin  //hilo_reg.v里面要写都写,所以这里要这样处理
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;  // 这里首先通过reg1_i得到rs的值
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i; // 这里首先通过reg1_i得到rs的值
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end


	// movn和movz两条指令
	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftzerores <= `ZeroWord;
		end else begin
			// whilo_o <= `WriteDisable; 
			case (aluop_i)
				`EXE_MOVN_OP: begin
					shiftzerores <= reg1_i;
				end 
				`EXE_MOVZ_OP: begin
					shiftzerores <= reg1_i;
				end
				default:				begin
					shiftzerores <= reg1_i;
				end
			endcase
		end    
	end        


	// 这一模块处理写
	always @ (*) begin
		wd_o <= wd_i;	 	 	
		wreg_o <= wreg_i;
		case ( alusel_i ) 
		`EXE_RES_LOGIC:		begin
			wdata_o <= logicres;
		end
		`EXE_RES_SHIFT:		begin
			wdata_o <= shiftres;
		end
		`EXE_RES_HILO:		begin
			wdata_o <= Hilores;
		end
		`EXE_RES_ZERO:		begin  // 增加的movn和movz
			wdata_o <= shiftzerores;
		end
		default:					begin
			wdata_o <= `ZeroWord;
		end
		endcase
	end	

	

endmodule