library verilog;
use verilog.vl_types.all;
entity alu is
    generic(
        ADD             : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        SUB             : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        MUL             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        DIV             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \NOT\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        \XOR\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        \OR\            : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi0);
        \AND\           : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi1)
    );
    port(
        oc              : in     vl_logic_vector(2 downto 0);
        a               : in     vl_logic_vector(3 downto 0);
        b               : in     vl_logic_vector(3 downto 0);
        f               : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADD : constant is 1;
    attribute mti_svvh_generic_type of SUB : constant is 1;
    attribute mti_svvh_generic_type of MUL : constant is 1;
    attribute mti_svvh_generic_type of DIV : constant is 1;
    attribute mti_svvh_generic_type of \NOT\ : constant is 1;
    attribute mti_svvh_generic_type of \XOR\ : constant is 1;
    attribute mti_svvh_generic_type of \OR\ : constant is 1;
    attribute mti_svvh_generic_type of \AND\ : constant is 1;
end alu;
