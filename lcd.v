module LCD(
    input clk,
    input wire [2:0] opcode,
	 input wire [3:0] endreg,
	 input wire [6:0] imm,
    output EN_out, RW_out, RS_out,
    output [7:0] out,
    output led1, led2
);

    parameter MS = 50_000;
    parameter INIT = 0, WAIT = 1, OPRT = 2, ENDR = 3, DATA = 4;
    reg[2:0] state = INIT;

    reg l1, l2;
    reg EN, RS;
    reg [7:0] data;
    reg [7:0] instructions = 0;
    reg [31:0] counter = 0;
    reg init_done = 0; // Indica se INIT foi concluído
	 reg oprt_done = 0; // Indica se OPRT foi concluido
	 reg endr_done = 0; // Indica se ENDR foi concluido
	 reg data_done = 0; // Indica se DATA foi concluido

    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (counter >= MS - 1) begin
                    counter <= 0;
                    if (instructions < 39) begin
                        instructions <= instructions + 1;
                        state <= WAIT;
                    end else begin
                        instructions <= 0; 
								init_done <= 1; // Marca que o INIT foi concluído
                        state <= OPRT;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end

            WAIT: begin
                if (counter >= MS - 1) begin
                    counter <= 0;
						  if (oprt_done && data_done && init_done && data_done) begin
								oprt_done <= 0;
								data_done <= 0;
								endr_done <= 0;
						  end else if (endr_done) begin
                        state <= DATA;
						  end else if (oprt_done) begin
                        state <= ENDR;
                    end else if (data_done) begin
                        state <= WAIT;
                    end else if (init_done) begin
                        state <= OPRT;
                    end else if (!init_done) begin
                        state <= INIT;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end

            OPRT: begin
                if (counter >= MS - 1) begin
                    counter <= 0;
                    if (instructions < 5) begin
                        instructions <= instructions + 1;
                        state <= WAIT;
                    end else begin
                        oprt_done <= 1; //FLAG QUE PERMITE MUDANÇA DE REGS E DATA
                        instructions <= 0;
                        state <= WAIT;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end
				
				ENDR: begin
					if (counter >= MS - 1) begin
                    counter <= 0;
                    if (instructions < 12) begin
                        instructions <= instructions + 1;
                        state <= WAIT;
						  end else begin
								endr_done <= 1;
								instructions <= 0;
								state <= WAIT;
						  end
                end else begin
                    counter <= counter + 1;
                end
				end
				
				DATA: begin
                if (counter >= MS - 1) begin
                    counter <= 0;
                    if (instructions < 18) begin
                        instructions <= instructions + 1;
                        state <= WAIT;
                    end else begin
                        data_done <= 1;
                        instructions <= 0;
                        state <= WAIT;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        case (state)
            INIT, OPRT, ENDR, DATA: EN <= 1;
            WAIT: EN <= 0;
        endcase

        case (state)
            INIT: begin
                case (instructions)
                    1: begin data <= 8'h38; RS <= 0; end // Seta duas linhas
                    //2: begin data <= 8'h0E; RS <= 0; end // Ativa cursor
                    3: begin data <= 8'h01; RS <= 0; end // Limpa o display
                    4: begin data <= 8'h02; RS <= 0; end // Home
                    5: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
                    6: begin data <= 8'h2D; RS <= 1; end // Caractere '-'
                    7: begin data <= 8'h2D; RS <= 1; end 
                    8: begin data <= 8'h2D; RS <= 1; end 
                    9: begin data <= 8'h2D; RS <= 1; end 
                    10: begin data <= 8'h14; RS <= 0; end
                    11: begin data <= 8'h14; RS <= 0; end
                    12: begin data <= 8'h14; RS <= 0; end
                    13: begin data <= 8'h14; RS <= 0; end
                    14: begin data <= 8'h14; RS <= 0; end
                    15: begin data <= 8'h14; RS <= 0; end
                    16: begin data <= 8'h5B; RS <= 1; end // '['
                    17: begin data <= 8'h2D; RS <= 1; end //'-'
                    18: begin data <= 8'h2D; RS <= 1; end 
                    19: begin data <= 8'h2D; RS <= 1; end 
                    20: begin data <= 8'h2D; RS <= 1; end 
                    21: begin data <= 8'h5D; RS <= 1; end // ']'
                    22: begin data <= 8'hC0; RS <= 0; end // Segunda linha
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
						 //default: begin data <= 8'h02; RS <= 0; end // home
                endcase
            end

            OPRT: begin
				    l1 <= 1'b0;
                case (opcode)
						  3'b000:begin
								case(instructions)
									0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
									1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
									2: begin data <= 8'h4C; RS <= 1; end // 'L'
									3: begin data <= 8'h4F; RS <= 1; end // 'O'
									4: begin data <= 8'h41; RS <= 1; end // 'A'
									5: begin data <= 8'h44; RS <= 1; end // 'D'
									//default: begin data <= 8'h02; RS <= 0; end // Home
								endcase
						  end
                    3'b001: begin
                        case (instructions)
                            0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
                            1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
                            2: begin data <= 8'h41; RS <= 1; end // 'A'
                            3: begin data <= 8'h44; RS <= 1; end // 'D'
                            4: begin data <= 8'h44; RS <= 1; end // 'D'
									 5: begin data <= 8'h20; RS <= 1; end // espaço
                            //default: begin data <= 8'h02; RS <= 0; end // Home
                        endcase
                    end
						  3'b010: begin
                        case (instructions)
                            0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
                            1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
                            2: begin data <= 8'h41; RS <= 1; end // 'A'
                            3: begin data <= 8'h44; RS <= 1; end // 'D'
                            4: begin data <= 8'h44; RS <= 1; end // 'D'
									 5: begin data <= 8'h49; RS <= 1; end // 'I'
                            //default: begin data <= 8'h02; RS <= 0; end // Home
                        endcase
                    end
						  3'b011: begin
                        case (instructions)
                            0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
                            1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
                            2: begin data <= 8'h53; RS <= 1; end // 'S'
                            3: begin data <= 8'h55; RS <= 1; end // 'U'
                            4: begin data <= 8'h42; RS <= 1; end // 'B'
									 5: begin data <= 8'h20; RS <= 1; end // espaço
                            //default: begin data <= 8'h02; RS <= 0; end // Home
                        endcase
                    end
						  3'b100:begin//subI
								case(instructions)
									 0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
                            1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
                            2: begin data <= 8'h53; RS <= 1; end // 'S'
                            3: begin data <= 8'h55; RS <= 1; end // 'U'
                            4: begin data <= 8'h42; RS <= 1; end // 'B'
									 5: begin data <= 8'h49; RS <= 1; end // 'I'
									 //default: begin data <= 8'h02; RS <= 0; end // Home
								endcase
							end
							3'b101:begin//MUL
								case(instructions)
									0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
									1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
									2: begin data <= 8'h4D; RS <= 1; end // 'M'
									3: begin data <= 8'h55; RS <= 1; end // 'U'
									4: begin data <= 8'h4C; RS <= 1; end // 'L'
									5: begin data <= 8'h20; RS <= 1; end // espaço
									//default: begin data <= 8'h02; RS <= 0; end // Home
								endcase
							end
							3'b110:begin//CLR
								case(instructions)
									0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
									1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
									2: begin data <= 8'h43; RS <= 1; end // 'C'
									3: begin data <= 8'h4C; RS <= 1; end // 'L'
									4: begin data <= 8'h52; RS <= 1; end // 'R'
									5: begin data <= 8'h20; RS <= 1; end // espaço
									//default: begin data <= 8'h02; RS <= 0; end // Home
								endcase
							end
							3'b111:begin//DPL
								case(instructions)
									0: begin data <= 8'h02; RS <= 0; l2 <= 1'b1; end // Home
									1: begin data <= 8'h06; RS <= 0; end // Move cursor para direita
									2: begin data <= 8'h44; RS <= 1; end // 'D'
									3: begin data <= 8'h50; RS <= 1; end // 'P'
									4: begin data <= 8'h4C; RS <= 1; end // 'L'
									5: begin data <= 8'h20; RS <= 1; end // espaço
									//default: begin data <= 8'h02; RS <= 0; end // Home
								endcase
							end
					 endcase
				end
					
				ENDR: begin
					l1 <= 1'b1;
					case(instructions)
						  0: begin data <= 8'h14; RS <= 0; end
						  1: begin data <= 8'h14; RS <= 0; end
						  2: begin data <= 8'h14; RS <= 0; end
						  3: begin data <= 8'h14; RS <= 0; end
						  4: begin data <= 8'h14; RS <= 0; end
						  5: begin data <= 8'h14; RS <= 0; end
						  6: begin data <= 8'h5B; RS <= 1; end // '['
						  7: begin data <= ((opcode==3'b110)? 8'h2D :(endreg[3] ? 8'h31 : 8'h30)); RS <= 1; end // '1' ou '0'
						  8: begin data <= ((opcode==3'b110)? 8'h2D :(endreg[2] ? 8'h31 : 8'h30)); RS <= 1; end // '1' ou '0'
						  9: begin data <= ((opcode==3'b110)? 8'h2D :(endreg[1] ? 8'h31 : 8'h30)); RS <= 1; end // '1' ou '0'
						  10: begin data <=((opcode==3'b110)? 8'h2D :(endreg[0] ? 8'h31 : 8'h30)); RS <= 1; end // '1' ou '0'
						  11: begin data <= 8'h5D; RS <= 1; end // ']'
						  //default: begin data <= 8'h02; RS <= 0; end // Home
					 endcase
				end
				
				DATA: begin
                case (instructions)
                    0: begin data <= 8'hC0; RS <= 0; end // Segunda linha
                    1: begin data <= 8'hC0; RS <= 0; end // Segunda Linha
						  2: begin data <= 8'h14; RS <= 0; end // 0-1
						  3: begin data <= 8'h14; RS <= 0; end // 1-2
						  4: begin data <= 8'h14; RS <= 0; end // 2-3
						  5: begin data <= 8'h14; RS <= 0; end // 3-4
						  6: begin data <= 8'h14; RS <= 0; end // 4-5
					  	  7: begin data <= 8'h14; RS <= 0; end // 5-6
						  8: begin data <= 8'h14; RS <= 0; end // 7-8
						  9: begin data <= 8'h14; RS <= 0; end // 8-9
						  10: begin data <= 8'h14; RS <= 0; end // 9-10
						  11: begin data <= 8'h14; RS <= 0; end // 10-11
                    12: begin data <= (imm[6] && imm[5:0]!=6'b000000) ? 8'h2D : 8'h2B; RS <= 1; end // '-' se negativo, '+' se positivo
                    13: begin data <= 8'h30 + ((imm[5:0] / 10000) % 10); RS <= 1; end // Dígito da dezena de milhar
                    14: begin data <= 8'h30 + ((imm[5:0]/1000) % 10); RS <= 1; end // Dígito da unidade de milhar
						  15: begin data <= 8'h30 + ((imm[5:0]/100) % 10); RS <= 1; end // Dígito da centenas
						  16: begin data <= 8'h30 + ((imm[5:0]/10) % 10); RS <= 1; end // Dígito da dezenas
						  17: begin data <= 8'h30 + (imm[5:0] % 10); RS <= 1; end // Dígito da unidades
                endcase
            end
		endcase	
	 end
    assign out = data;
    assign RS_out = RS;
    assign EN_out = EN;
    assign led1 = l2;
    assign led2 = l1;
    assign RW_out = 0; // Sempre em modo de escrita
endmodule
