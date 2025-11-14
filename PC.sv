`timescale 1ns / 1ps 

///////////////////////////////////////////////////////////////////////////// 

module PC( 
    input CLK, 
    input [31:0] PC_Din, 
    input PC_WRITE, 
    input PC_RST, 
    output logic [31:0] PC = 0 
    ); 
    
    always_ff @ (posedge CLK)  
    begin  
      if (PC_RST == 1)// if reset, then clear output 
      PC <= 0; 
      else if (PC_WRITE == 1) //if load high, then set q to din 
      PC <= PC_Din; 

    end 
endmodule 