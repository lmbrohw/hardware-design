#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=F:/Xilinx/Vivado/2019.1/ids_lite/ISE/bin/nt64;F:/Xilinx/Vivado/2019.1/ids_lite/ISE/lib/nt64:F:/Xilinx/Vivado/2019.1/bin
else
  PATH=F:/Xilinx/Vivado/2019.1/ids_lite/ISE/bin/nt64;F:/Xilinx/Vivado/2019.1/ids_lite/ISE/lib/nt64:F:/Xilinx/Vivado/2019.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='D:/practice_code/subject/hardware_design/my_cpu/my_cpu.runs/inst_mem_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log inst_mem.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source inst_mem.tcl
