module Slave(
input wire reset,
input wire [7:0] slaveDataToSend, 
output reg [7:0] slaveDataReceived,
input wire sclk,
input wire CS,
input wire MOSI,
output reg MISO
);

reg [7:0] Register; // Slave shift register

reg flag = 0; // Boolean: To allow transmitting of bits

always @(negedge CS or posedge reset)
begin
if (CS == 0) begin
	Register <= slaveDataToSend; // Initialize shift register
	slaveDataReceived <= 8'bxxxxxxxx; // Initialize data received with dont cares
	flag <= 1; // Set flag to 1
end
if (reset) begin
	Register <= 0; // Reset shift register
end

end

always @(posedge CS) begin // When slave is unselected
	flag <= 0; // Disallow transmission by setting flag to 0
	MISO <= 1'bz; // Disconnect MISO from this slave
end

always @(posedge sclk) // Shifting
begin
if (flag) begin
	Register <= Register >> 1; // Shift
	MISO <= Register[0]; // Write to MISO
end
end

always @ (negedge sclk) // Sampling
begin
if (flag) begin
	Register[7] = MOSI; // Read from MOSI
	slaveDataReceived <= {MOSI, slaveDataReceived[7:1]}; // Update Data received from master
end
end
endmodule
