-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
-- Date        : Fri Feb 13 11:45:26 2026
-- Host        : MIN running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_zynq_ultra_ps_e_0_0_stub.vhdl
-- Design      : design_1_zynq_ultra_ps_e_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xck26-sfvc784-2LV-c
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    maxihpm0_fpd_aclk : in STD_LOGIC;
    maxigp0_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_awlock : out STD_LOGIC;
    maxigp0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awvalid : out STD_LOGIC;
    maxigp0_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awready : in STD_LOGIC;
    maxigp0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_wlast : out STD_LOGIC;
    maxigp0_wvalid : out STD_LOGIC;
    maxigp0_wready : in STD_LOGIC;
    maxigp0_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_bvalid : in STD_LOGIC;
    maxigp0_bready : out STD_LOGIC;
    maxigp0_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_arlock : out STD_LOGIC;
    maxigp0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arvalid : out STD_LOGIC;
    maxigp0_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_arready : in STD_LOGIC;
    maxigp0_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_rlast : in STD_LOGIC;
    maxigp0_rvalid : in STD_LOGIC;
    maxigp0_rready : out STD_LOGIC;
    maxigp0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pl_ps_irq0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    pl_resetn0 : out STD_LOGIC;
    pl_clk0 : out STD_LOGIC
  );

  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_zynq_ultra_ps_e_0_0,zynq_ultra_ps_e_v3_5_8_zynq_ultra_ps_e,{}";
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_zynq_ultra_ps_e_0_0,zynq_ultra_ps_e_v3_5_8_zynq_ultra_ps_e,{x_ipProduct=Vivado 2025.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=zynq_ultra_ps_e,x_ipVersion=3.5,x_ipCoreRevision=8,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_DP_USE_AUDIO=0,C_DP_USE_VIDEO=0,C_MAXIGP0_DATA_WIDTH=32,C_MAXIGP1_DATA_WIDTH=128,C_MAXIGP2_DATA_WIDTH=32,C_SAXIGP0_DATA_WIDTH=128,C_SAXIGP1_DATA_WIDTH=128,C_SAXIGP2_DATA_WIDTH=128,C_SAXIGP3_DATA_WIDTH=128,C_SAXIGP4_DATA_WIDTH=128,C_SAXIGP5_DATA_WIDTH=128,C_SAXIGP6_DATA_WIDTH=128,C_USE_DIFF_RW_CLK_GP0=0,C_USE_DIFF_RW_CLK_GP1=0,C_USE_DIFF_RW_CLK_GP2=0,C_USE_DIFF_RW_CLK_GP3=0,C_USE_DIFF_RW_CLK_GP4=0,C_USE_DIFF_RW_CLK_GP5=0,C_USE_DIFF_RW_CLK_GP6=0,C_EN_FIFO_ENET0=0,C_EN_FIFO_ENET1=0,C_EN_FIFO_ENET2=0,C_EN_FIFO_ENET3=0,C_PL_CLK0_BUF=TRUE,C_PL_CLK1_BUF=FALSE,C_PL_CLK2_BUF=FALSE,C_PL_CLK3_BUF=FALSE,C_TRACE_PIPELINE_WIDTH=8,C_EN_EMIO_TRACE=0,C_TRACE_DATA_WIDTH=32,C_USE_DEBUG_TEST=0,C_SD0_INTERNAL_BUS_WIDTH=5,C_SD1_INTERNAL_BUS_WIDTH=5,C_NUM_F2P_0_INTR_INPUTS=1,C_NUM_F2P_1_INTR_INPUTS=1,C_EMIO_GPIO_WIDTH=1,C_NUM_FABRIC_RESETS=1}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "maxihpm0_fpd_aclk,maxigp0_awid[15:0],maxigp0_awaddr[39:0],maxigp0_awlen[7:0],maxigp0_awsize[2:0],maxigp0_awburst[1:0],maxigp0_awlock,maxigp0_awcache[3:0],maxigp0_awprot[2:0],maxigp0_awvalid,maxigp0_awuser[15:0],maxigp0_awready,maxigp0_wdata[31:0],maxigp0_wstrb[3:0],maxigp0_wlast,maxigp0_wvalid,maxigp0_wready,maxigp0_bid[15:0],maxigp0_bresp[1:0],maxigp0_bvalid,maxigp0_bready,maxigp0_arid[15:0],maxigp0_araddr[39:0],maxigp0_arlen[7:0],maxigp0_arsize[2:0],maxigp0_arburst[1:0],maxigp0_arlock,maxigp0_arcache[3:0],maxigp0_arprot[2:0],maxigp0_arvalid,maxigp0_aruser[15:0],maxigp0_arready,maxigp0_rid[15:0],maxigp0_rdata[31:0],maxigp0_rresp[1:0],maxigp0_rlast,maxigp0_rvalid,maxigp0_rready,maxigp0_awqos[3:0],maxigp0_arqos[3:0],pl_ps_irq0[0:0],pl_resetn0,pl_clk0";
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of maxihpm0_fpd_aclk : signal is "xilinx.com:signal:clock:1.0 M_AXI_HPM0_FPD_ACLK CLK";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of maxihpm0_fpd_aclk : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of maxihpm0_fpd_aclk : signal is "XIL_INTERFACENAME M_AXI_HPM0_FPD_ACLK, ASSOCIATED_BUSIF M_AXI_HPM0_FPD, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxigp0_awid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWID";
  attribute X_INTERFACE_MODE of maxigp0_awid : signal is "master";
  attribute X_INTERFACE_PARAMETER of maxigp0_awid : signal is "XIL_INTERFACENAME M_AXI_HPM0_FPD, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 16, ARUSER_WIDTH 16, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxigp0_awaddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWADDR";
  attribute X_INTERFACE_INFO of maxigp0_awlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLEN";
  attribute X_INTERFACE_INFO of maxigp0_awsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWSIZE";
  attribute X_INTERFACE_INFO of maxigp0_awburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWBURST";
  attribute X_INTERFACE_INFO of maxigp0_awlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLOCK";
  attribute X_INTERFACE_INFO of maxigp0_awcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWCACHE";
  attribute X_INTERFACE_INFO of maxigp0_awprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWPROT";
  attribute X_INTERFACE_INFO of maxigp0_awvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWVALID";
  attribute X_INTERFACE_INFO of maxigp0_awuser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWUSER";
  attribute X_INTERFACE_INFO of maxigp0_awready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWREADY";
  attribute X_INTERFACE_INFO of maxigp0_wdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WDATA";
  attribute X_INTERFACE_INFO of maxigp0_wstrb : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WSTRB";
  attribute X_INTERFACE_INFO of maxigp0_wlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WLAST";
  attribute X_INTERFACE_INFO of maxigp0_wvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WVALID";
  attribute X_INTERFACE_INFO of maxigp0_wready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WREADY";
  attribute X_INTERFACE_INFO of maxigp0_bid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BID";
  attribute X_INTERFACE_INFO of maxigp0_bresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BRESP";
  attribute X_INTERFACE_INFO of maxigp0_bvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BVALID";
  attribute X_INTERFACE_INFO of maxigp0_bready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BREADY";
  attribute X_INTERFACE_INFO of maxigp0_arid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARID";
  attribute X_INTERFACE_INFO of maxigp0_araddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARADDR";
  attribute X_INTERFACE_INFO of maxigp0_arlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLEN";
  attribute X_INTERFACE_INFO of maxigp0_arsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARSIZE";
  attribute X_INTERFACE_INFO of maxigp0_arburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARBURST";
  attribute X_INTERFACE_INFO of maxigp0_arlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLOCK";
  attribute X_INTERFACE_INFO of maxigp0_arcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARCACHE";
  attribute X_INTERFACE_INFO of maxigp0_arprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARPROT";
  attribute X_INTERFACE_INFO of maxigp0_arvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARVALID";
  attribute X_INTERFACE_INFO of maxigp0_aruser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARUSER";
  attribute X_INTERFACE_INFO of maxigp0_arready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARREADY";
  attribute X_INTERFACE_INFO of maxigp0_rid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RID";
  attribute X_INTERFACE_INFO of maxigp0_rdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RDATA";
  attribute X_INTERFACE_INFO of maxigp0_rresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RRESP";
  attribute X_INTERFACE_INFO of maxigp0_rlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RLAST";
  attribute X_INTERFACE_INFO of maxigp0_rvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RVALID";
  attribute X_INTERFACE_INFO of maxigp0_rready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RREADY";
  attribute X_INTERFACE_INFO of maxigp0_awqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWQOS";
  attribute X_INTERFACE_INFO of maxigp0_arqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARQOS";
  attribute X_INTERFACE_INFO of pl_ps_irq0 : signal is "xilinx.com:signal:interrupt:1.0 PL_PS_IRQ0 INTERRUPT";
  attribute X_INTERFACE_MODE of pl_ps_irq0 : signal is "slave";
  attribute X_INTERFACE_PARAMETER of pl_ps_irq0 : signal is "XIL_INTERFACENAME PL_PS_IRQ0, SENSITIVITY LEVEL_HIGH, PortWidth 1";
  attribute X_INTERFACE_INFO of pl_resetn0 : signal is "xilinx.com:signal:reset:1.0 PL_RESETN0 RST";
  attribute X_INTERFACE_MODE of pl_resetn0 : signal is "master";
  attribute X_INTERFACE_PARAMETER of pl_resetn0 : signal is "XIL_INTERFACENAME PL_RESETN0, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of pl_clk0 : signal is "xilinx.com:signal:clock:1.0 PL_CLK0 CLK";
  attribute X_INTERFACE_MODE of pl_clk0 : signal is "master";
  attribute X_INTERFACE_PARAMETER of pl_clk0 : signal is "XIL_INTERFACENAME PL_CLK0, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of stub : architecture is "zynq_ultra_ps_e_v3_5_8_zynq_ultra_ps_e,Vivado 2025.2";
begin
end;
