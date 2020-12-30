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
// Module:  id
// File:    id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 译码阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id(

	input wire					rst,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]        inst_i,

	//处于执行阶段的指令要写入的目的寄存器信息
	input wire					ex_wreg_i,  // 执行阶段是否要写寄存器
	input wire[`RegBus]			ex_wdata_i, // 写的数据 
	input wire[`RegAddrBus]     ex_wd_i,    // 写到寄存器堆中的地址
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire					mem_wreg_i,
	input wire[`RegBus]			mem_wdata_i,
	input wire[`RegAddrBus]     mem_wd_i,

	input wire[`RegBus]         reg1_data_i,
	input wire[`RegBus]         reg2_data_i,

	//送到regfile的信息
	output reg                  reg1_read_o,
	output reg                  reg2_read_o,     
	output reg[`RegAddrBus]     reg1_addr_o,
	output reg[`RegAddrBus]     reg2_addr_o, 	      
	
	//送到执行阶段的信息
	output reg[`AluOpBus]       aluop_o,
	output reg[`AluSelBus]      alusel_o,
	output reg[`RegBus]         reg1_o,
	output reg[`RegBus]         reg2_o,
	output reg[`RegAddrBus]     wd_o,
	output reg                  wreg_o
);

  wire[5:0] op = inst_i[31:26];    // ori指令只需要高六位即可判断指令类型
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];     // 功能码
  wire[4:0] op4 = inst_i[20:16];
  reg[`RegBus]	imm;
  reg instvalid;

  wire [`RegBus]shiftres_rt;
  
 
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;			
	  end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];  // 默认位置
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;			
		//   case (op)
		//   	`EXE_ORI:begin            //ORI指令
		//   		wreg_o <= `WriteEnable;	
        //         alusel_o <= `EXE_RES_LOGIC;	     // 运算类型是逻辑运算   
        //         aluop_o <= `EXE_OR_OP;           // 运算子类型是或
        //         reg1_read_o <= 1'b1;	
        //         reg2_read_o <= 1'b0;	  	
        //         imm <= {16'h0, inst_i[15:0]};		
        //         wd_o <= inst_i[20:16];
        //         instvalid <= `InstValid;	
		//   	end 							 
		//     default:			begin
		//     end
		//   endcase		  //case op		
			case (op)
				`EXE_SPECIAL_INST:		begin
					case (op2)
						5'b00000:			begin
							case (op3)
								`EXE_OR:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
									alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
									instvalid <= `InstValid;	
									end  
								`EXE_AND:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
									alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
									instvalid <= `InstValid;	
									end  	
								`EXE_XOR:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
									alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
									instvalid <= `InstValid;	
									end  				
								`EXE_NOR:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_NOR_OP;
									alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
									instvalid <= `InstValid;	
									end 
								`EXE_SLLV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
								alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
								instvalid <= `InstValid;	
								end 
								`EXE_SRLV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
								instvalid <= `InstValid;	
								end 					
								`EXE_SRAV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
								instvalid <= `InstValid;			
								end			
								// `EXE_SYNC: begin
								// 	wreg_o <= `WriteDisable;		aluop_o <= `EXE_NOP_OP;
								// alusel_o <= `EXE_RES_NOP;		reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;
								// instvalid <= `InstValid;	
								// end

								//HILO操作
								`EXE_MFHI:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_MFHI_OP;
									alusel_o <= `EXE_RES_HILO; 	reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
									instvalid <= `InstValid;	
								end 
								`EXE_MFLO:	begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_MFLO_OP;
									alusel_o <= `EXE_RES_HILO; 	reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
									instvalid <= `InstValid;	
								end 
								`EXE_MTHI:	begin
									wreg_o <= `WriteDisable;  // 其实上面默认是不写的	
									aluop_o <= `EXE_MTHI_OP;  // `EXE_MFHI_OP;这里没改
									alusel_o <= `EXE_RES_HILO; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
									instvalid <= `InstValid;	
								end 
								`EXE_MTLO:	begin
									wreg_o <= `WriteDisable;		
									aluop_o <= `EXE_MTLO_OP;
									alusel_o <= `EXE_RES_HILO; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
									instvalid <= `InstValid;	
								end 

								`EXE_MOVN:	begin
									wreg_o <=  shiftres_rt ? `WriteEnable : `WriteDisable;		
									aluop_o <= `EXE_MOVN_OP;
									alusel_o <= `EXE_RES_ZERO; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
									instvalid <= `InstValid;	
								end
								`EXE_MOVZ:	begin
									wreg_o <=  !shiftres_rt ? `WriteEnable : `WriteDisable;			
									aluop_o <= `EXE_MOVZ_OP;
									alusel_o <= `EXE_RES_ZERO; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
									instvalid <= `InstValid;	
								end

								default:	begin
								end
							endcase
						end
						default: begin
						end
					endcase	
				end	

				`EXE_ORI:			begin                        //ORI指令
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];
						instvalid <= `InstValid;	
				end
				`EXE_ANDI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
					alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
						instvalid <= `InstValid;	
					end	 	
				`EXE_XORI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
					alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
						instvalid <= `InstValid;	
					end	 		
				`EXE_LUI:			begin  
					// 注意，这里把这个指令转换为了ori指令，所以wd_o想其他指令一样对应更换，又因为rs刚好是
					// $0,对应他的值reg1_addr_o，所以不需要在做其他修改
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
						instvalid <= `InstValid;	
					end		
				// `EXE_PREF:			begin
				// wreg_o <= `WriteDisable;		aluop_o <= `EXE_NOP_OP;
				// alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;	  	  	
				// 	instvalid <= `InstValid;	
				// end										  	
				default:			begin
				end
		  	endcase		  //case op
		  
			if (inst_i[31:21] == 11'b00000000000) begin  // 对于sll,sra,srl指令来说
				if (op3 == `EXE_SLL) begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
					alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
						imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
						instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRL ) begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
				alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
				alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end
			end
		end       //if
	end         //always
	



	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
		
		// 数据前推（回写的那个前推在regfile.v中解决了——先读后写）
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i;
		
		end else if(reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
		end else if(reg1_read_o == 1'b0) begin
			reg1_o <= imm;
		end else begin
			reg1_o <= `ZeroWord;
		end
	end
	
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		
		// 数据前推
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;

		end else if(reg2_read_o == 1'b1) begin
			reg2_o <= reg2_data_i;
		end else if(reg2_read_o == 1'b0) begin
			reg2_o <= imm;
		end else begin
			reg2_o <= `ZeroWord;
		end
	end

	assign shiftres_rt = reg2_o;

endmodule