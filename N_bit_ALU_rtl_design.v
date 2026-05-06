module N_bit_ALU_rtl_design #(parameter N = 4)(
    input [N-1:0] OPA, OPB,
    input CLK, RST, CE, MODE, CIN,
    input [1:0]INP_VALID,
    input [3:0]CMD,
    output reg [2*N-1:0] RES=0,
    output reg COUT=0,
    output reg OFLOW=0,
    output reg G=0,
    output reg E=0,
    output reg L=0,
    output reg ERR=0);
        reg [N-1:0] OPA_1, OPB_1; 
      reg [1:0]   mul_cnt;   
    reg [2*N-1:0] mul_temp;
    reg  mul_active;
    reg [3:0] mul_cmd;
    wire is_mul_cmd;
    assign is_mul_cmd = (CMD == 4'b1001 || CMD == 4'b1010);
    reg [N:0] diff;
    reg [N:0] sum;

    always @(posedge CLK)
    begin
        if (RST)  
        begin
            RES <= 0;
            COUT <= 0;
            OFLOW <= 0;
            G <= 0;
            E <= 0;
            L <= 0;
            ERR <= 0;
            OPA_1 <= 0;        
            OPB_1 <= 0;        
            mul_cnt <= 0;
            mul_active <= 0;
            mul_cmd <= 0;
        end

        else if (CE)
        begin
            COUT <= 0;
            OFLOW <= 0;
            G <= 0;
            E <= 0;
            L <= 0;
            ERR <= 0;

            if (mul_active)
            begin
                if (INP_VALID != 2'b11)
                begin
                    RES <= 0;
                    ERR <= 1;
                    mul_active <= 0;
                    mul_cnt <= 0;
                end
                else if (CMD != mul_cmd)
                begin
                    mul_active <= 0;
                    mul_cnt <= 0;
          else
               begin
              mul_cnt <= mul_cnt + 1;
              if (mul_cnt == 0)
               begin
        
                RES <= {2*N{1'bx}};
               end
            else if (mul_cnt == 1)
          begin
        RES <= mul_temp;
        mul_active <= 0;
        mul_cnt <= 0;
    end
end
            end
            else if (MODE)
            begin
                case (CMD)
                    4'b0000: 
                    if (INP_VALID == 2'b11)
                    begin
                      RES <= OPA + OPB;
                      COUT <= {1'b0,OPA} + {1'b0,OPB}>>N;                    
                    end
                    else ERR <= 1;
           
                    4'b0001:
                    begin
                        if (INP_VALID == 2'b11)
                        begin
                            OFLOW <= (OPA < OPB) ? 1 : 0;
                            RES <= OPA - OPB;
                        end
                        else
                            ERR <= 1'b1;
                    end

                  4'b0010:
                    begin
                        if (INP_VALID == 2'b11)
                        begin
                            RES <= OPA + OPB + CIN;
                          COUT <= {1'b0,OPA} + {1'b0,OPB}>>N;                    
                        end
                        else
                            ERR <= 1'b1;
                    end

                   4'b0011:            
                    begin
                        if (INP_VALID == 2'b11)
                        begin
                            OFLOW <= (OPA < OPB) ? 1 : 0;
                            RES   <= OPA - OPB - CIN;
                        end
                        else
                            ERR <= 1'b1;
                    end

                    4'b0100:             
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)  
                           RES<=(OPA + 1'b1) & {N{1'b1}};
                        else
                            ERR <= 1'b1;
                    end

                    4'b0101:             
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)  
                          RES <= (OPA - 1'b1) & {N{1'b1}};
                        else
                            ERR <= 1'b1;
                    end

                    4'b0110:            
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)  
                          RES <= (OPB + 1'b1) & {N{1'b1}};
                        else
                            ERR <= 1'b1;
                    end

                    4'b0111:             
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)  
                           RES <= (OPB - 1'b1) & {N{1'b1}};
                        else
                            ERR <= 1'b1;
                    end

                    4'b1000:              
                    begin
                        RES <= {2*N{1'b0}};
                        if (INP_VALID == 2'b11)
                        begin
                            if (OPA == OPB)
                            begin
                                E <= 1'b1;
                                G <= 1'b0;
                                L <= 1'b0;
                            end
                            else if (OPA > OPB)
                            begin
                                E <= 1'b0;
                                G <= 1'b1;
                                L <= 1'b0;
                            end
                            else
                            begin
                                E <= 1'b0;
                                G <= 1'b0;
                                L <= 1'b1;
                            end
                        end
                        else
                            ERR <= 1'b1;
                    end

                   
                    4'b1001: 
                    if (INP_VALID == 2'b11)
                    begin
                        OPA_1      <= OPA + 1;
                        OPB_1      <= OPB + 1;
                        mul_temp   <= (OPA + 1) * (OPB + 1);
                        mul_cnt    <= 0;
                        mul_active <= 1;
                        mul_cmd    <= CMD;
                    end
                    else ERR <= 1;

                    4'b1010: 
                    if (INP_VALID == 2'b11)
                    begin
                        OPA_1 <= OPA << 1;
                        mul_temp   <= (OPA << 1) * OPB;
                        mul_cnt    <= 0;
                        mul_active <= 1;
                        mul_cmd    <= CMD;
                    end
                    else ERR <= 1;

                    4'b1011:
                    if (INP_VALID == 2'b11)
                    begin

                     sum = $signed(OPA) + $signed(OPB);

                      RES <= sum[N-1:0];   

                     OFLOW <= (~OPA[N-1] & ~OPB[N-1] & sum[N-1]) |( OPA[N-1] &  OPB[N-1] & ~sum[N-1]);
                       end
                       else
                      begin
                      ERR <= 1;
                      end

                    4'b1100:
                    if (INP_VALID == 2'b11)
                    begin
                    
                    diff = $signed(OPA) - $signed(OPB);

                    RES <= diff[N-1:0];

                    OFLOW <= (~OPA[N-1] & OPB[N-1] & diff[N-1]) |( OPA[N-1] & ~OPB[N-1] & ~diff[N-1]);
                    end
                   else
                   begin
                   ERR <= 1;
                   RES <= 0;
                   end

                endcase
            end
          else          
            begin
                RES   <= {2*N{1'b0}};
                COUT  <= 1'b0;
                OFLOW <= 1'b0;
                G     <= 1'b0;
                E     <= 1'b0;
                L     <= 1'b0;
                ERR   <= 1'b0;
                case (CMD)    

                    4'b0000:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, OPA & OPB};     
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b0001:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, ~(OPA & OPB)};   
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b0010:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, OPA | OPB};     
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b0011:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, ~(OPA | OPB)};   
                        else
                            ERR <= 1'b1;                  
                    end

                    4'b0100:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, OPA ^ OPB};      
                        else
                            ERR <= 1'b1;                  
                    end

                    4'b0101:
                    begin
                        if (INP_VALID == 2'b11)
                            RES <= {1'b0, ~(OPA ^ OPB)};   
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b0110:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)  
                            RES <= {1'b0, ~OPA};           
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b0111:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)  
                            RES <= {1'b0, ~OPB};          
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b1000:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)  
                            RES <= {1'b0, OPA >> 1};       
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b1001:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)  
                            RES <= {1'b0, OPA << 1};       
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b1010:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)  
                            RES <= {1'b0, OPB >> 1};       
                        else
                            ERR <= 1'b1;                   
                    end

                    4'b1011:
                    begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)  
                            RES <= {1'b0, OPB << 1};       
                        else
                            ERR <= 1'b1;                  
                    end

                    4'b1100:                               
                    begin
                        if (INP_VALID == 2'b11)
                        begin
                            if (|OPB[(N-1):(N/2)])
                                ERR <= 1'b1;
                            else
                                RES <= {{N{1'b0}}, (OPA << OPB[$clog2(N)-1:0]) | (OPA >> (N - OPB[$clog2(N)-1:0]))};
                        end
                        else
                            ERR <= 1'b1;
                    end

                    4'b1101:                               
                    begin
                        if (INP_VALID == 2'b11)
                        begin
                            if (|OPB[(N-1):(N/2)])
                                ERR <= 1'b1;
                            else
                                RES <= {{N{1'b0}}, (OPA >> OPB[$clog2(N)-1:0]) | (OPA << (N - OPB[$clog2(N)-1:0]))};
                        end
                        else
                            ERR <= 1'b1;
                    end
                    default:    
                    begin
                        RES <= 0;
                        COUT <= 0;
                        OFLOW <= 0;
                        G <= 0;
                        E <= 0;
                        L <= 0;
                        ERR <= 0;
                    end
                endcase
            end
        end
    end
endmodule
