module dm_controller(mem_w, Addr_in, Data_write, dm_ctrl, 
  Data_read_from_dm, Data_read, Data_write_to_dm, wea_mem);
  input  mem_w;                   
  input [31:0] Addr_in;            
  input [31:0] Data_write;         
  input [2:0] dm_ctrl;            
  input [31:0] Data_read_from_dm;  
  output reg [31:0] Data_read;         
  output reg [31:0] Data_write_to_dm; 
  output reg [3:0] wea_mem;          

  //write
  always @(*) begin
    if(mem_w) begin
      case (dm_ctrl)
        //write word
        3'b000: begin
          wea_mem <= 4'b1111;
          Data_write_to_dm <= Data_write;
        end

        //write halfword
        3'b001: begin
          Data_write_to_dm <= {(2){Data_write[15:0]}};
          if(Addr_in[1]==1'b0) wea_mem <= 4'b0011;
          else wea_mem <= 4'b1100;
        end

        //write halfword unsigned
        3'b010:begin
          Data_write_to_dm <= {(2){Data_write[15:0]}};
          if(Addr_in[1]==1'b0) wea_mem <= 4'b0011;
          else wea_mem <= 4'b1100;
        end

        //write byte
        3'b011: begin
          Data_write_to_dm <= {(4){Data_write[7:0]}};
          case(Addr_in[1:0])
            2'b00: wea_mem <= 4'b0001;
            2'b01: wea_mem <= 4'b0010;
            2'b10: wea_mem <= 4'b0100;
            2'b11: wea_mem <= 4'b1000;
            default: wea_mem <= 4'b0000;
          endcase
        end

        //write byte unsigned
        3'b100: begin
          Data_write_to_dm <= {(4){Data_write[7:0]}};
          case(Addr_in[1:0])
            2'b00: wea_mem <= 4'b0001;
            2'b01: wea_mem <= 4'b0010;
            2'b10: wea_mem <= 4'b0100;
            2'b11: wea_mem <= 4'b1000;
            default: wea_mem <= 4'b0000;
          endcase          
        end
      endcase
    end
    else wea_mem <= 4'b0000; //mem_w==0,read
  end

  //read
  always @(*) begin
    case (dm_ctrl)
      //read word
      3'b000: Data_read <= Data_read_from_dm;

      //read halfword
      3'b001:
        if(Addr_in[1]==0) Data_read <= {{(16){Data_read_from_dm[15]}}, Data_read_from_dm[15:0]};
        else Data_read <= {{(16){Data_read_from_dm[31]}}, Data_read_from_dm[31:16]};

      //read halfword unsigned
      3'b010:
        if(Addr_in[1]==0) Data_read <= {16'b0, Data_read_from_dm[15:0]};
        else Data_read <= {16'b0, Data_read_from_dm[31:16]};

      //read byte
      3'b011:
        case(Addr_in[1:0])
          2'b00: Data_read <= {{(24){Data_read_from_dm[7]}}, Data_read_from_dm[7:0]};
          2'b01: Data_read <= {{(24){Data_read_from_dm[15]}}, Data_read_from_dm[15:8]};
          2'b10: Data_read <= {{(24){Data_read_from_dm[23]}}, Data_read_from_dm[23:16]};
          2'b11: Data_read <= {{(24){Data_read_from_dm[31]}}, Data_read_from_dm[31:24]};
          default: Data_read <= 32'b0;
        endcase

      //read byte unsigned
      3'b100:
        case(Addr_in[1:0])
          2'b00: Data_read <= {24'b0, Data_read_from_dm[7:0]};
          2'b01: Data_read <= {24'b0, Data_read_from_dm[15:8]};
          2'b10: Data_read <= {24'b0, Data_read_from_dm[23:16]};
          2'b11: Data_read <= {24'b0, Data_read_from_dm[31:24]};
          default: Data_read <= 32'b0;
        endcase
    endcase
  end
  
endmodule