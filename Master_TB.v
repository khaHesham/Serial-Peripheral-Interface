module Master_tb ();
reg clk, reset, start;
reg[1:0] slaveSelect;
wire [7:0] masterDataToSend;
wire [7:0] masterDataReceived;
wire sclk;
wire [0:2] CS;
reg MISO;
wire MOSI;

localparam PERIOD = 5;

reg [7:0] slave = 8'b11010011;

assign masterDataToSend = 8'b11010110;


initial begin
clk = 0;
reset = 0;
start = 1;
slaveSelect = 0;
#PERIOD start = 0;
$display ("          Master     Slave");
$display ("Initial: %b | %b", masterDataToSend, slave);
#(PERIOD*17) if (masterDataReceived == 8'b11010011) begin
	$display ("Final:   %b | %b", masterDataReceived, slave);
	$display ("Success!");
	$finish;
end
else begin
	$display ("Failed!");
	$finish;
end
end
always begin
	#PERIOD clk = ~clk;
end
always @(posedge clk) begin
if (!CS[0]) begin
	MISO = slave[0];
	slave = slave >> 1;
end
end
always @(negedge clk) begin
if (!CS[0]) begin
	slave[7] = MOSI;
end
end

Master M(
clk, 
reset,
start, 
slaveSelect,
masterDataToSend,
masterDataReceived,
sclk,
CS,
MOSI,
MISO
);


endmodule
