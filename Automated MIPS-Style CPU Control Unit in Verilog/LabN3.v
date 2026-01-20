module labN;
reg [31:0] entryPoint; // 32-bit register
reg clk, INT; // 1-bit registers
wire [2:0] op; // 3-bit wire
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb, PCin; // 32-bit wire
wire [25:0] jTarget; // 26-bit wire
wire zero, RegDst, RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, branch, jump; // 1-bit wires
wire [5:0] opCode, fnCode; // 6-bit wires
wire [1:0] ALUop; // 2-bit wire

yIF myIF(ins, PCp4, PCin, clk); // instruction fetch
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk); // instruction decoding
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc); // executing
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite); // data memory
yWB myWB(wb, z, memOut, Mem2Reg); // write back
assign wd = wb;
yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump); // program counter

assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, jump, branch, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);

assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, branch);
yC4 myC4(op, ALUop, fnCode);

initial
begin
  //------------------------------------Entry point
  entryPoint = 128;
  INT = 1;
  #1;
  //------------------------------------Run program
  repeat (43)
  begin
    //---------------------------------Fetch an ins
    clk = 1; #1; INT = 0;
    //---------------------------------Set control signals
    
    //---------------------------------Execute the ins
    clk = 0; #1;
    //---------------------------------View results
    $display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d", ins, rd1, rd2, z, zero, wb);
    //---------------------------------Prepare for the next ins

  end
  $finish;
end
endmodule
