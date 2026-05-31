module smoke_tb;
  initial begin
    $display("SMOKE: start");
    #1 $display("SMOKE: end");
    $finish;
  end
endmodule
