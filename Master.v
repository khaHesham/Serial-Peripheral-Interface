module Master (
input wire clk, reset, start,
input wire[1:0] slaveSelect,
input wire [7:0] masterDataToSend,
output reg [7:0] masterDataReceived,
output wire sclk,
output reg [0:2] CS,
output reg MOSI,
input wire MISO
);

reg [7:0] Register; // Master shift register

assign sclk = clk; // sclk to be sent to slaves

reg transmit = 0; // Boolean: To allow transmitting of bits

integer maxCount = 0; // Counter that indicates transfer is complete when max is reached

always @(posedge start or posedge reset) begin // Reset - Start
if (!transmit && start) begin
	Register <= masterDataToSend; // Initialize shift register
	masterDataReceived <= 8'bxxxxxxxx; // Initialize data received with dont cares
	maxCount <= 0; // Initial value of count
	transmit <= 1; // Allow transmission between master & slave
	if (slaveSelect == 0) begin
		CS <= 3'b011; // First slave selected
	end
	else if (slaveSelect == 1) begin
		CS <= 3'b101; // Second slave selected
	end
	else if (slaveSelect == 2) begin
		CS <= 3'b110; // Third slave selected
	end
	else begin
		CS <= 3'b111; // No slave selected
	end
end
if (reset) begin
	Register <= 0; // Reset the register to zero
end
end

always @(posedge clk) // Shifting
begin
if (transmit) begin
	Register <= Register >> 1; // Shift
	MOSI <= Register[0]; // Write to MOSI
end
end

always @(negedge clk) // Sampling
begin
if (maxCount >= 7) begin // Max count reached (All bits transferred)
	transmit <= 0; // Disallow transmission
	CS <= 3'b111; // Unselect slave
end
if (transmit) begin
	Register[7] <= MISO; // Read from MISO
	masterDataReceived <= {MISO, masterDataReceived[7:1]}; // Update Data Received from slave
	maxCount <= maxCount + 1; // Increment counter
end
end
endmodule
