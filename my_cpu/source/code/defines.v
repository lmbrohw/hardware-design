//全局
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000        // 就是用来表示数值0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 7:0                 // 译码阶段输出的aluop_o的宽度
`define AluSelBus 2:0                // 译码阶段输出的alusel_o的宽度
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1             // 
`define NotInDelaySlot 1'b0
`define Branch 1'b1                  // 是否为分支指令
`define NotBranch 1'b0               
`define InterruptAssert 1'b1         // 
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1              // 
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1              // 芯片使能
`define ChipDisable 1'b0



// 指令 op位
`define EXE_SPECIAL_INST 6'b000000  // 包括R型逻辑，R移位,数据移位
// `define EXE_REGIMM_INST 6'b000001   // 
`define EXE_HILO_INST 6'b011100



//指令 功能码
// 8条逻辑指令
`define EXE_AND  6'b100100  
`define EXE_OR   6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

// 6条移位指令
`define EXE_SLL  6'b000000
`define EXE_SLLV  6'b000100
`define EXE_SRL  6'b000010
`define EXE_SRLV  6'b000110
`define EXE_SRA  6'b000011
`define EXE_SRAV  6'b000111

`define EXE_SYNC  6'b001111
`define EXE_PREF  6'b110011

`define EXE_NOP 6'b000000
`define SSNOP 32'b00000000000000000000000001000000

// 4条数据移动指令Hilo
`define EXE_MFHI  6'b010000
`define EXE_MFLO  6'b010010
`define EXE_MTHI  6'b010001
`define EXE_MTLO  6'b010011
`define EXE_MOVN  6'b001011  //
`define EXE_MOVZ  6'b001010  //

// 14条算术运算指令
`define EXE_AND  6'b100100  
`define EXE_OR   6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111





//AluOp 对于special，需要知道运算的子类型
// 8条逻辑指令
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100  

// 6条移位指令
`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_NOP_OP    8'b00000000

// 4条数据移动指令Hilo
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011
`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011



//AluSel 对应着现在已经实现的指令类型
`define EXE_RES_LOGIC 3'b001   
`define EXE_RES_SHIFT 3'b010  
// `define EXE_RES_HILO 3'b010  // 这个地方我的天
`define EXE_RES_HILO 3'b011

`define EXE_RES_ZERO 3'b111 //movn movz两条指令
`define EXE_RES_NOP 3'b000


//指令存储器inst_rom
`define InstAddrBus 31:0          // ROM地址总线的宽度
`define InstBus 31:0              // ROM数据的宽度
`define InstMemNum 131071         // 
`define InstMemNumLog2 17


//通用寄存器regfile
`define RegAddrBus 4:0           // 寄存器堆的地址线宽度
`define RegBus 31:0              // 寄存器堆的数据线宽度
`define RegWidth 32              // 通用寄存器的宽度
`define DoubleRegWidth 64        // 两倍通用寄存器的宽度
`define DoubleRegBus 63:0
`define RegNum 32                // 寄存器堆数量
`define RegNumLog2 5
`define NOPRegAddr 5'b00000
