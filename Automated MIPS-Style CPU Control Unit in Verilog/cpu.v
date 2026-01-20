module yMux1(z, a, b, c);
output z;
input a, b, c;
wire notC, upper, lower;

not my_not(notC, c); // not gate
and upperAnd(upper, a, notC); // and gate
and lowerAnd(lower, c, b); // and gate
or my_or(z, upper, lower); // or gate

endmodule




module yMux(z, a, b, c);
parameter SIZE = 2; // localizing the value of the bus size to 2
output [SIZE-1:0] z; // 2-bit output
input [SIZE-1:0] a, b; // 2-bit inputs
input c; // 1-bit input

yMux1 mine[SIZE-1:0](z, a, b, c); // array-based instantiation

endmodule




module yMux4to1(z, a0,a1,a2,a3, c);
parameter SIZE = 2; // localizing the value of the bus size to 2
output [SIZE-1:0] z; // 2-bit output
input [SIZE-1:0] a0, a1, a2, a3; // 2-bit inputs
input [1:0] c; // 2-bit input
wire [SIZE-1:0] zLo, zHi; // 2-bit wires

yMux #(SIZE) lo(zLo, a0, a1, c[0]); // parameter value is set to SIZE
yMux #(SIZE) hi(zHi, a2, a3, c[0]); // parameter value is set to SIZE
yMux #(SIZE) final(z, zLo, zHi, c[1]); // parameter value is set to SIZE

endmodule




module yAdder1(z, cout, a, b, cin);
output z, cout;
input a, b, cin;

xor left_xor(tmp, a, b); // xor gate
xor right_xor(z, cin, tmp); // xor gate
and left_and(outL, a, b); // and gate
and right_and(outR, tmp, cin); // and gate
or my_or(cout, outR, outL); // or gate

endmodule




module yAdder(z, cout, a, b, cin);
output [31:0] z; // 32-bit output
output cout; // 1-bit output
input [31:0] a, b; // 32-bit inputs
input cin; // 1-bit input
wire[31:0] in, out; // 32-bit wires

yAdder1 mine[31:0](z, out, a, b, in);

assign in[0] = cin;
assign in[1] = out[0];
assign in[2] = out[1];
assign in[3] = out[2];
assign in[4] = out[3];
assign in[5] = out[4];
assign in[6] = out[5];
assign in[7] = out[6];
assign in[8] = out[7];
assign in[9] = out[8];
assign in[10] = out[9];
assign in[11] = out[10];
assign in[12] = out[11];
assign in[13] = out[12];
assign in[14] = out[13];
assign in[15] = out[14];
assign in[16] = out[15];
assign in[17] = out[16];
assign in[18] = out[17];
assign in[19] = out[18];
assign in[20] = out[19];
assign in[21] = out[20];
assign in[22] = out[21];
assign in[23] = out[22];
assign in[24] = out[23];
assign in[25] = out[24];
assign in[26] = out[25];
assign in[27] = out[26];
assign in[28] = out[27];
assign in[29] = out[28];
assign in[30] = out[29];
assign in[31] = out[30];
assign cout = out[31];

endmodule




module yArith(z, cout, a, b, ctrl);
// add if ctrl=0, subtract if ctrl=1
output [31:0] z; // 32-bit output
output cout; // 1-bit output
input [31:0] a, b; // 32-bit inputs
input ctrl; // 1-bit input
wire[31:0] notB, tmp; // 32-bit wires
wire cin; // 1-bit wire

// instantiate the components and connect them
// Hint: about 4 lines of code

assign notB = ~b;
assign tmp = ctrl ? notB : b; // if ctrl = 1, then tmp = notB. Else, tmp = b
assign cin = ctrl;

yAdder my_yAdder(z, cout, a, tmp, cin);

endmodule




module yAlu(z, ex, a, b, op);
input [31:0] a, b; // 32-bit inputs
input [2:0] op; // 3-bit input
output [31:0] z; // 32-bit output
output ex; // 1-bit output

wire [15:0] z16;
wire [7:0] z8;
wire [3:0] z4;
wire [1:0] z2;
wire z1;

wire [31:0] and_result, or_result, arith_result, slt; // 32-bit wires
wire cout; // 1-bit wire

wire signDiff; // 1-bit wire

assign slt[31:1] = 0; // upper bits are always 0

// instantiate a circuit to set slt[0]
// Hint: about 2 lines of code

xor(signDiff, a[31], b[31]); // xor gate
assign slt[0] = signDiff ? a[31] : arith_result[31];

// instantiate the components and connect them
// Hint: about 4 lines of code

assign and_result = a & b; // AND operation
assign or_result = a | b; // OR operation

or or16[15:0] (z16, z[15:0], z[31:16]);
or or8[7:0] (z8, z16[7:0], z16[15:8]);
or or4[3:0] (z4, z8[3:0], z8[7:4]);
or or2[1:0] (z2, z4[1:0], z4[3:2]);
or or1 (z1, z2[0], z2[1]);
assign ex = ~z1;  // Invert the final OR result


yArith my_yArith(arith_result, cout, a, b, op[2]);

yMux4to1 #(32) my_yMux4to1(z, and_result, or_result, arith_result, slt, op[1:0]);

endmodule




module yIF(ins, PCp4, PCin, clk);
output [31:0] ins, PCp4; // 32-bit output
input [31:0] PCin; // 32-bit input
input clk; // 1-bit input

wire [31:0] PC; // 32-bit wire

// build and connect the circuit
register #(32) my_register(PC, PCin, clk, 1'b1);
yAlu my_yAlu(PCp4, ex, 4, PC, 3'b010);
mem my_mem(ins, PC, 0, clk, 1'b1, 1'b0);

endmodule




module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
output [31:0] rd1, rd2, imm; // 32-bit outputs
output [25:0] jTarget; // 26-bit output
input [31:0] ins, wd; // 32-bit inputs
input RegDst, RegWrite, clk; // 1-bit inputs

wire [4:0] rn1, rn2, rn3, wn; // 2-bit wires

assign rn1 = ins[25:21];
assign rn2 = ins[20:16];
assign rn3 = ins[15:11];
assign jTarget = ins[25:0];
assign imm[15:0] = ins[15:0];

yMux #(16) se(imm[31:16], 16'b0, 16'hffff, ins[15]);
yMux #(5) my_yMux(wn, rn2, rn3, RegDst);
rf my_rf(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);

endmodule




module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
output [31:0] z; // 32-bit output
output zero; // 1-bit output
input [31:0] rd1, rd2, imm; // 32-bit inputs
input [2:0] op; // 3-bit input
input ALUSrc; // 1-bit input

wire [31:0] b; // 32-bit wire

yMux #(32) my_yMux(b, rd2, imm, ALUSrc);
yAlu my_yAlu(z, zero, rd1, b, op);

endmodule




module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;

// instantiate the circuit (only one line)
mem my_mem(memOut, exeOut, rd2, clk, MemRead, MemWrite);

endmodule




module yWB(wb, exeOut, memOut, Mem2Reg);
output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;

// instantiate the circuit (only one line)
yMux #(32) my_yMux(wb, exeOut, memOut, Mem2Reg);

endmodule




module yPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm;
input [25:0] jTarget;
input INT, zero, branch, jump;

wire [31:0] immX4, jTargetX4, bTarget, choiceA, choiceB;
wire doBranch, zf;

assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;
yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);

assign jTargetX4[31:28] = PCp4[31:28];
assign jTargetX4[27:2] = jTarget[25:0];
assign jTargetX4[1:0] = 2'b00;
yMux #(32) mux2(choiceB, choiceA, jTargetX4, jump);

yMux #(32) mux3(PCin, choiceB, entryPoint, INT);

endmodule




module yC1(rtype, lw, sw, jump, branch, opCode);
output rtype, lw, sw, jump, branch;
input [5:0] opCode;

wire not5, not4, not3, not2, not1, not0;
not (not5, opCode[5]);
not (not4, opCode[4]);
not (not3, opCode[3]);
not (not2, opCode[2]);
not (not1, opCode[1]);
not (not0, opCode[0]);
and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]); // 100011
and (sw, opCode[5], not4, opCode[3], not2, opCode[1], opCode[0]); // 101011
and (branch, not5, not4, not3, opCode[2], not1, not0); // 000100
and (jump, not5, not4, not3, not2, opCode[1], not0); // 000010
and (rtype, not5, not4, not3, not2, not1, not0); // 000000

endmodule




module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch;

assign RegDst = rtype;
nor (ALUSrc, rtype, branch);
nor (RegWrite, branch, sw);
assign Mem2Reg = lw;
assign MemRead = lw;
assign MemWrite = sw;

endmodule




module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;

// build the circuit
// Hint: you can do it in only 2 lines
assign ALUop[1] = rtype;
assign ALUop[0] = branch;

endmodule




module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;

// instantiate and connect
or (or1, fnCode[0], fnCode[3]);
and (and1, fnCode[1], ALUop[1]);
and (op[0], ALUop[1], or1);
or (op[2], ALUop[0], and1);
or (op[1], ~ALUop[1], ~fnCode[2]);

endmodule




module yChip(ins, rd2, wb, entryPoint, INT, clk);
output [31:0] ins, rd2, wb;
input [31:0] entryPoint;
input INT, clk;

wire [2:0] op; // 3-bit wire
wire [31:0] wd, rd1, imm, PCp4, z, memOut, PCin; // 32-bit wire
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

endmodule
