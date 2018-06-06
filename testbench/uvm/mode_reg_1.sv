//mode register 1
class mode_reg_1 extends uvm_object;
`uvm_object_utils(mode_reg_1);

string m_name_1 = "MODE_REG_1";

bit   [2:0] BA=3'b001;
rand       DLL;
rand [1:0] ODS;
rand  [1:0] AL;
rand     Q_off;
rand      TQDS;
bit  RSV =1'b0;
rand [2:0]R_TT; 
rand        WL;


function new(m_name_1);
super.new(m_name_1);
endfunction


constraint DLL_c_1   { DLL == 1'b0; }        // Enable Normal
constraint ODSL_c_1  { ODSL == 2'b00; }      // RZQ/6(40 ohm(NOM))
constraint AL_c_1    { AT == 2'b00; }        // Disabled
constraint Q_off_c_1 { O_off == 1'b0; }      // Enabled
constraint R_TT_c_1  { R_TT == 3'b001; }     // RZQ/4   
constraint TDQS_c_1  { TDQS == 1'b0; }       // 1'b0;
constraint WL_c_1    { WL == 1'b0; }         // 1'b0 


function cfg_mode1_reg_t pack;
return {BA,RSV,Q_off,TDQS,RSV,R_TT[2],RSV,WL,R_TT[1],ODS[1],AL,R_TT[0],ODS[0],DLL};
endfucntion 


function string conv_to_str();
conv_to_str = $sformatf("MODE_REG_1:BA:%b,Q_off:%b,TDQS:%b,R_TT:%b,WL:%b,ODS:%b,AL:%b,DLL:%b",BA,Q_off,TDQS,R_TT,WL,ODS,AL,DLL);
endfunction


endclass 