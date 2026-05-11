module ALU_reference_model #(parameter N = 4)(
    input  [N-1:0]OPA,
    input  [N-1:0]OPB,
    input  MODE,
    input  CIN,
    input  [1:0]INP_VALID,
    input  [3:0]CMD,
    output reg [2*N-1:0] EXP_RES,
    output reg EXP_COUT,
    output reg EXP_OFLOW,
    output reg EXP_G,
    output reg EXP_E,
    output reg EXP_L,
    output reg EXP_ERR);

reg [N:0] temp;
integer k;
always @(*)
begin

    EXP_RES    = 0;
    EXP_COUT   = 0;
    EXP_OFLOW  = 0;
    EXP_G      = 0;
    EXP_E      = 0;
    EXP_L      = 0;
    EXP_ERR    = 0;

       if (MODE)
    begin
        case(CMD)
    
        4'b0000:
        begin
            if (INP_VALID == 2'b11)
            begin
                 EXP_RES <= OPA + OPB;
                 EXP_COUT <= ({1'b0,OPA} + {1'b0,OPB}) >> N;
            end
            else
                EXP_ERR = 1;
        end
    
        4'b0001:
        begin
            if (INP_VALID == 2'b11)
            begin
                EXP_RES    = OPA - OPB;
                EXP_OFLOW  = (OPA < OPB);
            end
            else
                EXP_ERR = 1;
        end
     
        4'b0010:
        begin
            if (INP_VALID == 2'b11)
            begin
                temp      = OPA + OPB + CIN;
                EXP_RES   = temp[N-1:0];
                EXP_COUT  = temp[N];
            end
            else
                EXP_ERR = 1;
        end
    
        4'b0011:
        begin
            if (INP_VALID == 2'b11)
            begin
                EXP_RES    = OPA - OPB - CIN;
                EXP_OFLOW  = (OPA < (OPB + CIN));
            end
            else
                EXP_ERR = 1;
        end
  
        4'b0100:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b01)
            begin
                EXP_RES = OPA + 1'b1;
            end
            else
                EXP_ERR = 1;
        end
  
        4'b0101:
        begin
            if (INP_VALID == 2'b11 || INP_VALID == 2'b01)
            begin
                EXP_RES = OPA - 1'b1;
            end
            else
                EXP_ERR = 1;
        end
    
        4'b0110:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b10)
            begin
                EXP_RES = OPB + 1'b1;
            end
            else
                EXP_ERR = 1;
        end
    
        4'b0111:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b10)
            begin
                EXP_RES = OPB - 1'b1;
            end
            else
                EXP_ERR = 1;
        end
      
        4'b1000:
        begin
            if (INP_VALID == 2'b11)
            begin
                if (OPA > OPB)
                begin
                    EXP_G = 1;
                    EXP_E = 0;
                    EXP_L = 0;
                end
                else if (OPA < OPB)
                begin
                    EXP_G = 0;
                    EXP_E = 0;
                    EXP_L = 1;
                end
                else
                begin
                    EXP_G = 0;
                    EXP_E = 1;
                    EXP_L = 0;
                end
            end
            else
                EXP_ERR = 1;
        end
     
        4'b1001:
        begin
            if (INP_VALID == 2'b11)
            begin
                EXP_RES = (OPA + 1) * (OPB + 1);
            end
            else
                EXP_ERR = 1;
        end
       
        4'b1010:
        begin
            if (INP_VALID == 2'b11)
            begin
                EXP_RES = (OPA << 1) * OPB;
            end
            else
                EXP_ERR = 1;
        end

        4'b1011:
        begin
            if (INP_VALID == 2'b11)
            begin
                temp = $signed(OPA) + $signed(OPB);
                EXP_RES = temp[N-1:0];
                EXP_OFLOW =(~OPA[N-1] & ~OPB[N-1] & temp[N-1]) |( OPA[N-1] &  OPB[N-1] & ~temp[N-1]);
                if ($signed(OPA) > $signed(OPB))
                begin
                    EXP_G = 1;
                    EXP_E = 0;
                    EXP_L = 0;
                end
                else if ($signed(OPA) < $signed(OPB))
                begin
                    EXP_G = 0;
                    EXP_E = 0;
                    EXP_L = 1;
                end
                else
                begin
                    EXP_G = 0;
                    EXP_E = 1;
                    EXP_L = 0;
                end
            end
            else
                EXP_ERR = 1;
        end
            4'b1100:
        begin
            if (INP_VALID == 2'b11)
            begin
                temp = $signed(OPA) - $signed(OPB);
                EXP_RES = temp[N-1:0];
                EXP_OFLOW =(~OPA[N-1] &  OPB[N-1] &  temp[N-1]) |( OPA[N-1] & ~OPB[N-1] & ~temp[N-1]);
                if ($signed(OPA) > $signed(OPB))
                begin
                    EXP_G = 1;
                    EXP_E = 0;
                    EXP_L = 0;
                end
                else if ($signed(OPA) < $signed(OPB))
                begin
                    EXP_G = 0;
                    EXP_E = 0;
                    EXP_L = 1;
                end
                else
                begin
                    EXP_G = 0;
                    EXP_E = 1;
                    EXP_L = 0;
                end
            end
            else
                EXP_ERR = 1;
        end
        default:
        begin
            EXP_RES    = 0;
            EXP_COUT   = 0;
            EXP_OFLOW  = 0;
            EXP_G      = 0;
            EXP_E      = 0;
            EXP_L      = 0;
            EXP_ERR    = 0;
        end
        endcase
    end
    else
    begin
       case(CMD)
        4'b0000:
        begin
            if (INP_VALID == 2'b11)
                EXP_RES = OPA & OPB;
            else
                EXP_ERR = 1;
        end
        4'b0001:
        begin
            if (INP_VALID == 2'b11)
                EXP_RES = ~(OPA & OPB);
            else
                EXP_ERR = 1;
        end
        4'b0010:
        begin
            if (INP_VALID == 2'b11)
                EXP_RES = OPA | OPB;
            else
                EXP_ERR = 1;
        end
        4'b0011:
        begin
            if (INP_VALID == 2'b11)
                EXP_RES = ~(OPA | OPB);
            else
                EXP_ERR = 1;
        end
        4'b0100:
        begin
            if (INP_VALID == 2'b11)
                EXP_RES = OPA ^ OPB;
            else
                EXP_ERR = 1;
        end
        4'b0101:
        begin
            if (INP_VALID == 2'b11)
            EXP_RES = ~(OPA ^ OPB);
            else
                EXP_ERR = 1;
        end
        4'b0110:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b01)
                EXP_RES = ~OPA;
            else
                EXP_ERR = 1;
        end
        4'b0111:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b10)
                EXP_RES = ~OPB;
            else
                EXP_ERR = 1;
        end
        4'b1000:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b01)
                EXP_RES = OPA >> 1;
            else
                EXP_ERR = 1;
        end
        4'b1001:
        begin
            if (INP_VALID == 2'b11 || INP_VALID == 2'b01)
                EXP_RES = OPA << 1;
            else
                EXP_ERR = 1;
        end
        4'b1010:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b10)
                EXP_RES = OPB >> 1;
            else
                EXP_ERR = 1;
        end
        4'b1011:
        begin
            if (INP_VALID == 2'b11 ||INP_VALID == 2'b10)
                EXP_RES = OPB << 1;
            else
                EXP_ERR = 1;
        end
        4'b1100:
        begin
            if (INP_VALID == 2'b11)
            begin
                if (|OPB[(N-1):(N/2)])
                    EXP_ERR = 1;
                else
                begin
                    k = OPB[$clog2(N)-1:0];
                    EXP_RES =(OPA << k) |(OPA >> (N-k));
                end
            end
            else
                EXP_ERR = 1;
        end
        4'b1101:
        begin
            if (INP_VALID == 2'b11)
            begin
                if (|OPB[(N-1):(N/2)])
                    EXP_ERR = 1;
                else
                begin
                    k = OPB[$clog2(N)-1:0];

                    EXP_RES =(OPA >> k) | (OPA << (N-k));
                end
            end
            else
                EXP_ERR = 1;
        end
        default:
        begin
            EXP_RES    = 0;
            EXP_COUT   = 0;
            EXP_OFLOW  = 0;
            EXP_G      = 0;
            EXP_E      = 0;
            EXP_L      = 0;
            EXP_ERR    = 0;
        end
        endcase
    end
end
endmodule
