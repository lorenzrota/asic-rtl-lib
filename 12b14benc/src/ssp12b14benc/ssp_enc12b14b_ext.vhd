----------------------------------------------------------------------------------------------------
-- Title      : 12b14b ssp encoder wrapper with test pattern generation
----------------------------------------------------------------------------------------------------
-- File       : ssp_enc12b14b_ext.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20180425
-- Platform   : Generic
-- Standard   : VHDL'93/02
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
        ---- changed by Aseem G on May 21, 2019 to add latches---------------
----------------------------------------------------------------------------------------------------
        ---- changed by Aseem G on July 2,2019 to remove the fclk_i(8MHZ slowest clk or SAMPL_CLK from BE)---------------
----------------------------------------------------------------------------------------------------
-- Description:
-- 12b14b Encoder wrapper with test pattern and bypass options.
----------------------------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2018 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssp_enc12b14b_ext is
    port(
        start_ro: in  std_logic; -- start DAQ 
        clk_i   : in  std_logic; -- input clock
        rst_n_i : in  std_logic; -- active-low reset
        valid_i : in  std_logic; -- valid input for encoder
        mode_i  : in  std_logic_vector(2 downto 0); -- mode of operation
        data_i  : in  std_logic_vector(11 downto 0); -- data to be encoded
        data_o  : out std_logic_vector(13 downto 0) -- output data
    );
end entity ssp_enc12b14b_ext;

----- passing data through FF--- using process in VHDL ----- 


architecture rtl of ssp_enc12b14b_ext is
    -- test pattern constants
    constant c_patterna : std_logic_vector(13 downto 0) := "10" & x"AAA"; -- "10_1010_1010_1010"
    constant c_patternb : std_logic_vector(13 downto 0) := "01" & x"555"; -- "01_0101_0101_0101"

    signal s_pattern  : std_logic_vector(13 downto 0); -- wire, choosing any of the patterns below

    signal s_pattern0  : std_logic_vector(13 downto 0); -- passing UNENCODED DATA from BE to SERIALIZER
    signal s_pattern1  : std_logic_vector(13 downto 0); -- 0xA's followed by 0x5's
    signal s_pattern2  : std_logic_vector(13 downto 0); -- 000's followed by 111's
    signal s_pattern3  : std_logic_vector(13 downto 0); -- wire, LSB to MSB incremental ramp

    signal s_cnt_ramp  : unsigned(13 downto 0); -- pattern3 ramp counter

    signal s_data_i      : std_logic_vector(11 downto 0);  -- data_i
    signal s_data_o      : std_logic_vector(13 downto 0);  -- data_out
    signal s_data_o_mux  : std_logic_vector(13 downto 0);  -- mux to select
                                                           -- between encoded
                                                           -- and not encoded
                                                           -- data_out
    signal s_valid_i     : std_logic; -- encoder data_i valid
    signal s_evenodd     : std_logic; -- toggle flag

 ------- assigning data into the latches first & last --------------------

    signal data_i_latched    : std_logic_vector(11 downto 0);  -- data_i_latched
    signal valid_i_latched   : std_logic;  -- valid_i_latched
    signal s_data_o_latched  : std_logic_vector(13 downto 0);  -- data_o_latched
        
  

    ---SSP 12b14b Enconder
    -- uses SLAC's naming convention
    component Cryo_SspEncoder12b14b is
        generic(
            RST_POLARITY_G : std_logic;
            RST_ASYNC_G    : boolean;
            AUTO_FRAME_G   : boolean;
            FLOW_CTRL_EN_G : boolean
        );
        port(
            clk_i   : in  std_logic;
            rst_n_i : in  std_logic;
            valid_i : in  std_logic;
            data_i  : in  std_logic_vector(11 downto 0);
            data_o  : out std_logic_vector(13 downto 0)
        );
    end component;
begin
    -- component instantiation
    U_Cryo_SspEncoder12b14b : Cryo_SspEncoder12b14b
        generic map(
            RST_POLARITY_G => '0',
            RST_ASYNC_G    => true,
            AUTO_FRAME_G   => true,
            FLOW_CTRL_EN_G => false)
        port map(
            clk_i   => clk_i,
            rst_n_i => rst_n_i,
            valid_i => s_valid_i,
            data_i  => s_data_i,
            data_o  => s_data_o
        );

    -- Test Patterns:
    -- Test Pattern0: frame clk (receiver uses LSB to recover frame clk)
    -- Test Pattern1: 0xA's followed by 0x5's
    -- Test Pattern2: 000's followed by 111's
    -- Test Pattern3: Ramp 0x0000 to 0x3FFF (or 0xFFF when encoded)
    s_pattern0 <=  "00" & data_i_latched;
    s_pattern1 <= c_patterna when s_evenodd = '0' else c_patternb;
    s_pattern2 <= (others => '0') when s_evenodd = '0' else (others => '1');
    s_pattern3 <= std_logic_vector(s_cnt_ramp);


    -- modes of operation
    -- M2 M1 M0 | Description
    -- -------- | -----------
    -- 0  0  0  | Normal: ADC   -> DMUX -> ENC  -> Serializer
    -- 0  0  1  | Test Pattern1 -> ENC           -> Serializer
    -- 0  1  0  | Test Pattern2 -> ENC           -> Serializer
    -- 0  1  1  | Test Pattern3 -> ENC           -> Serializer
    -- 1  0  0  | Noy Enc: ADC  -> DMUX          -> Serializer
    -- 1  0  1  | Test Pattern1                  -> Serializer
    -- 1  1  0  | Test Pattern2                  -> Serializer
    -- 1  1  1  | Test Pattern3                  -> Serializer

    s_pattern <= s_pattern0  when mode_i(1 downto 0) = "00" else
                 s_pattern1  when mode_i(1 downto 0) = "01" else
                 s_pattern2  when mode_i(1 downto 0) = "10" else
                 s_pattern3  when mode_i(1 downto 0) = "11" else
                 (others => '0');

       -- generate s_patterns
    tpattern : process(clk_i, rst_n_i)
    begin
        if rst_n_i = '0' then -- async reset
            -- s_pattern0 <= (others => '0');
            s_cnt_ramp <= (others => '0');
            s_evenodd <= '0';
            data_i_latched   <= (others => '0');
            valid_i_latched   <= '0';
            s_data_o_latched <= (others => '0');

        elsif rising_edge(clk_i) then
            -- pattern0
            -- s_pattern0 <= s_pattern0(12 downto 0) & fclk_i; -- MSB is oldest in time
            -----------------fclk_i is commented above as it is not used in Mode 4 anymore------
            
            -- toggle flag for pattern1 and 2
            s_evenodd <= not s_evenodd;

            -- pattern3
            s_cnt_ramp <= s_cnt_ramp + 1; -- will auto wrap
            -- wrap early if we are feeding encoder i.e. 12 bits only
            if mode_i(2) = '0' and s_cnt_ramp >= x"FFF" then
                s_cnt_ramp <= (others => '0');
            end if;
            -- added latches for input 12 bit data and output 14bit data
            data_i_latched    <=   data_i;
    	    valid_i_latched   <=  valid_i;
            s_data_o_latched  <= s_data_o_mux;
        end if;
    end process;
  
          ---- changed on May 15,2019 by Dionisio and Aseem -----
  ----s_valid_i <= valid_i when mode_i(2) = '0' else '0';
 -----s_valid_i <= valid_i when mode_i = "000" else '1';
    s_valid_i <= valid_i_latched when mode_i = "000" else  start_ro ;

    
            --- changed to pass latched data to Cryo_SspEncoder12b14b module---- 
    s_data_i      <=   data_i_latched   when mode_i = "000"  else s_pattern(11 downto 0);
    s_data_o_mux  <=   s_data_o when mode_i(2) = '0' else s_pattern;
    data_o        <= s_data_o_latched;

end architecture rtl;
