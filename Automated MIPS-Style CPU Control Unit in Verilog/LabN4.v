module labN;
reg [31:0] entryPoint; // 32-bit register
reg clk, INT; // 1-bit registers
wire [31:0] ins, rd2, wb; // 32-bit wire

yChip myChip(ins, rd2, wb, entryPoint, INT, clk);

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
    $display("%h: rd2=%2d wb=%2d", ins, rd2, wb);

  end
  $finish;
end
endmodule
