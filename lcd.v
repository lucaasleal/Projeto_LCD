module LCD(
    input clk,
	 input wire[2:0] opcode,
    output EN_out, RW_out, RS_out,
    output [7:0] out,
    output led1, led2
);

	parameter MS = 50_000;
	parameter INIT = 0, WRITE = 1, WAIT = 2, UPDATE = 3;
	reg[2:0] state = INIT;

	reg l1, l2;
	reg EN, RS;
	reg [7:0] data;
	reg [7:0] instructions = 1;
	reg [31:0] counter = 0;
	

	always @(posedge clk) begin
		 case (state)
			  INIT: begin
					if (counter >= MS - 1) begin
						 counter <= 0;
						 if (instructions < 39)begin 
							instructions <= instructions + 1;
							state<=WAIT;
							end
						 else begin
							instructions <= 0;
							state <= UPDATE;
						 end
					end else begin
						 counter <= counter + 1;
					end
			  end

			  WAIT: begin
					if (counter >= MS - 1) begin
						 counter <= 0;
						 state <= INIT;
					end else begin
						 counter <= counter + 1;
						 
					end
			  end

			  UPDATE: begin
					if (counter >= MS - 1) begin
						 counter <= 0;
						 if (instructions < 5) instructions <= instructions + 1;
						 else begin
							instructions <= 1;
							state <= INIT;
						 end
					end else begin
						 counter <= counter + 1;
					end
			  end
		 endcase
	end

	always @(posedge clk) begin
		 case (state)
			  INIT, UPDATE: EN <= 1;
			  WAIT: EN <= 0;
			  default: EN <= EN;
		 endcase

		 case (state)
			  INIT: begin
					l1 <= 1'b1;
					case (instructions)
						 1: begin data <= 8'h38; RS <= 0; end // seta duas linhas
						 2: begin data <= 8'h0E; RS <= 0; end // ativa cursor
						 3: begin data <= 8'h01; RS <= 0; end // limpa o display
						 4: begin data <= 8'h02; RS <= 0; end // home
						 5: begin data <= 8'h06; RS <= 0; end // home de verdade
						 6: begin data <= 8'h2D; RS <= 1; end
						 7: begin data <= 8'h2D; RS <= 1; end
						 8: begin data <= 8'h2D; RS <= 1; end
						 9: begin data <= 8'h2D; RS <= 1; end
						 10: begin data <= 8'h14; RS <= 0; end // 4-5
						 11: begin data <= 8'h14; RS <= 0; end // 5-6
						 12: begin data <= 8'h14; RS <= 0; end // 6-7
						 13: begin data <= 8'h14; RS <= 0; end // 7-8
						 14: begin data <= 8'h14; RS <= 0; end // 8-9
						 15: begin data <= 8'h14; RS <= 0; end // 8-9
						 16: begin data <= 8'h5B; RS <= 1; end // [
						 17: begin data <= 8'h2D; RS <= 1; end // -
						 18: begin data <= 8'h2D; RS <= 1; end
						 19: begin data <= 8'h2D; RS <= 1; end
						 20: begin data <= 8'h2D; RS <= 1; end
						 21: begin data <= 8'h5D; RS <= 1; end // ]
						 22: begin data <= 8'hC0; RS <= 0; end // Segunda Linha
						 23: begin data <= 8'h14; RS <= 0; end // 0-1
						 24: begin data <= 8'h14; RS <= 0; end // 1-2
						 25: begin data <= 8'h14; RS <= 0; end // 2-3
						 26: begin data <= 8'h14; RS <= 0; end // 3-4
						 27: begin data <= 8'h14; RS <= 0; end // 4-5
						 28: begin data <= 8'h14; RS <= 0; end // 5-6
						 29: begin data <= 8'h14; RS <= 0; end // 7-8
						 30: begin data <= 8'h14; RS <= 0; end // 8-9
						 31: begin data <= 8'h14; RS <= 0; end // 9-10
						 32: begin data <= 8'h14; RS <= 0; end // 10-11
						 33: begin data <= 8'h2B; RS <= 1; end // +
						 34: begin data <= 8'h30; RS <= 1; end // 0
						 35: begin data <= 8'h30; RS <= 1; end
						 36: begin data <= 8'h30; RS <= 1; end
						 37: begin data <= 8'h30; RS <= 1; end
						 38: begin data <= 8'h30; RS <= 1; end
						 default: begin data <= 8'h02; RS <= 0; end // home
					endcase
			  end
			  UPDATE: begin
					l2 <= 1'b1;
					case (opcode)						
						3'b001: begin
							case (instructions)
							0: begin data <= 8'h02; RS <= 0; end // home
							1: begin data <= 8'h06; RS <= 0; end // home de verdade
							2: begin data <= 8'h41; RS <= 1; end // A
							3: begin data <= 8'h44; RS <= 1; end // D
							4: begin data <= 8'h44; RS <= 1; end // D
							endcase
						end
						default: begin data <= 8'h02; RS <= 0; end 
					endcase
						
				
						/* 0: begin data <= 8'h02; RS <= 0; end // home
						 1: begin data <= 8'h06; RS <= 0; end // home de verdade
						 2: begin data <= 8'h41; RS <= 1; end // A
						 3: begin data <= 8'h42; RS <= 1; end // B
						 4: begin data <= 8'h43; RS <= 1; end // C
						 5: begin data <= 8'h44; RS <= 1; end // D
						 6: begin data <= 8'h02; RS <= 0; end // home*/
			  end
			  
		 endcase
	end

	assign out = data;
	assign RS_out = RS;
	assign EN_out = EN;
	assign led1 = l2;
	assign led2 = l1;

endmodule
