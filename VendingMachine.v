module PROJECT_1(clk, token, select, buy, load, seg0, seg1, seg2, items, empty);

	input clk; 
	input token;                    // type of currency
	input [4:0] select;             // select item from inventory. 5 unique trays with 7 items (SW0-4)
	input buy;
	input [4:0] load;               // restock items (SW5-9)
	output reg [6:0] seg0;          // display money on 7-Segment display (HEX0)
	output reg [6:0] seg1;          // display money on 7-Segment display (HEX1)
	output reg [6:0] seg2;          // displays inventory (HEX4)
	output reg [4:0] items = 0;     // notifies when an item is dispensed
	output reg [4:0] empty = 0;     // notifies when stock is empty
	
	
   reg [3:0] money = 4'b0000;   //will be withdrawn when spent
	reg token_prev;
	reg buy_prev;
	
	reg[3:0] stock0=3'b0111; //7 items, [1] redbull    1 token
	reg[3:0] stock1=3'b0111; //7 items, [2] lays chips 2 tokens
	reg[3:0] stock2=3'b0111; //7 items, [3] coffee     3 tokens
	reg[3:0] stock3=3'b0111; //7 items, [4] water      4 tokens
	reg[3:0] stock4=3'b0111; //7 items, [5] coke       4 tokens

	
   wire [6:0] seg_out0;
	wire [6:0] seg_out1;
	wire [6:0] seg_out2;
	wire [3:0] remainingItems;

	bcdToSevenSegment displaymoney(money, seg_out0, seg_out1);    // calls bcdToSevenSegment
	
	viewInventory Inventory(select, stock0, stock1, stock2, stock3, stock4, remainingItems);
	
	bcdToSevenSegment displayInventory(remainingItems, seg_out2); 
	
	always@(posedge clk)
	
	begin
	
   seg0 <= seg_out0;
	seg1 <= seg_out1;
	seg2 <= seg_out2;
	token_prev <= token;
	buy_prev <= buy;
	
   if(token_prev == 1'b0 && token == 1'b1) // if a token is inserted
	money <= money + 3'b0001;               // money increases by 1
	
	else if (buy_prev == 1'b0 && buy ==1'b1) // if an item is bought
	
	
	case (select)

		5'b00001: //redbull 1 token

		if (money >= 4'b0001 && stock0 > 0)
		begin
		items[0] <= 1'b1;      // item is despensed if above statement is true
		stock0 <= stock0 - 1'b1;  // i.e. 9 - 1 = 8 tokens left
		money <= money - 4'b0001; // machine withdraws price of item from total money
		end

		5'b00010: //lays chips 2 tokens

		if (money >= 4'b0010 && stock1 > 0)
		begin
		items[1] <= 1'b1;
		stock1 <= stock1 - 1'b1;
		money <= money - 4'b0010;
		end

		5'b00100: //coffee 3 tokens

		if (money >= 4'b0011 && stock2 > 0)
		begin
		items[2] <= 1'b1;
		stock2 <= stock2 - 1'b1;
		money <= money - 4'b0011;
		end

		5'b01000: //water 4 tokens

		if (money >= 4'b0100 && stock3 > 0)
		begin
		items[3] <= 1'b1;
		stock3 <= stock3 - 1'b1;
		money <= money - 4'b0100;
		end
		
		5'b10000: //coke 4 tokens

		if (money >= 4'b0100 && stock4 > 0)
		begin
		items[4] <= 1'b1;
		stock4 <= stock4 - 1'b1;
		money <= money - 4'b0100;
		end
		
	endcase
	
	else if (buy_prev == 1'b1 && buy == 1'b0) // if the user does not hit the buy, no item is dispensed
	begin
	items [0] <=1'b0;
	items [1] <=1'b0;
	items [2] <=1'b0;
	items [3] <=1'b0;
	items [4] <=1'b0;
	end
	
	// if items run out, empty goes to high
	else begin

	if (stock0 == 3'b000)
	empty[0] <=1'b1;
	else empty[0] <= 1'b0;

	if (stock1 == 3'b000)
	empty[1] <= 1'b1;
	else empty[1] <= 1'b0;

	if (stock2 == 3'b000)
	empty[2] <=1'b1;
	else empty[2] <= 1'b0;

	if (stock3 == 3'b000)
	empty[3] <=1'b1;
	else empty[3] <= 1'b0;
	
	if (stock4 == 3'b000)
	empty[4] <=1'b1;
	else empty[4] <= 1'b0;

	// putting the load switch to high will restock the item back to 7
	case (load)
		5'b00001: stock0 <= 4'b0111;
		5'b00010: stock1 <= 4'b0111;
		5'b00100: stock2 <= 4'b0111;
		5'b01000: stock3 <= 4'b0111;
		5'b10000: stock4 <= 4'b0111;
	endcase
	end
	end
	
endmodule

module bcdToSevenSegment(money, seg1, seg2); 

    input [3:0] money;      // 4-bit value from vending machine money 0-9 tokens

    output [6:0] seg1;      // seg1, seg2 7-segment LED display	 
	 output [6:0] seg2;

    reg[6:0] seg1; 
	 reg[6:0] seg2; 

always @(*)  

begin  

    case(money)  

        4'b0000: begin // Digit 0
                seg1 <= 7'b1000000;
                seg2 <= 7'b1000000;
            end
				
            4'b0001: begin // Digit 1
                seg1 <= 7'b1111001;
                seg2 <= 7'b1000000;
            end
				
            4'b0010: begin // Digit 2
                seg1 <= 7'b0100100;
                seg2 <= 7'b1000000;
            end
				
            4'b0011: begin // Digit 3
                seg1 <= 7'b0110000;
                seg2 <= 7'b1000000;
            end
				
            4'b0100: begin // Digit 4
                seg1 <= 7'b0011001;
                seg2 <= 7'b1000000;
            end
				
            4'b0101: begin // Digit 5
                seg1 <= 7'b0010010;
                seg2 <= 7'b1000000;
            end
				
            4'b0110: begin // Digit 6
                seg1 <= 7'b0000010;
                seg2 <= 7'b1000000;
            end
				
            4'b0111: begin // Digit 7
                seg1 <= 7'b1111000;
                seg2 <= 7'b1000000;
            end
				
            4'b1000: begin // Digit 8
                seg1 <= 7'b0000000;
                seg2 <= 7'b1000000;
            end
				
            4'b1001: begin // Digit 9
                seg1 <= 7'b0010000;
                seg2 <= 7'b1000000;
            end
				
            4'b1010: begin // Digit 10 
                seg1 <= 7'b1000000;
                seg2 <= 7'b1111001;
            end
				
            4'b1011: begin // Digit 11 
                seg1 <= 7'b1111001;
                seg1 <= 7'b1111001;
            end
				
            4'b1100: begin // Digit 12
                seg1 <= 7'b0100100;
                seg1 <= 7'b1111001;
            end
				
            4'b1101: begin // Digit 13
                seg1 <= 7'b0110000;
                seg1 <= 7'b1111001;
            end
				
            4'b1110: begin // Digit 14
                seg1 <= 7'b0011001;
                seg1 <= 7'b1111001;
            end
				
            4'b1111: begin // Digit 15
                seg1 <= 7'b0010010;
                seg1 <= 7'b1111001;
            end
				
            default: begin // Invalid digit
                seg1 <= 7'b1111111;
                seg2 <= 7'b1111111;
            end 

    endcase  

end  

endmodule


module viewInventory(select, stock0, stock1, stock2, stock3, stock4, remainingItems); 

    input [4:0] select;      // determines which item is selected
	 input [3:0] stock0;
	 input [3:0] stock1;
	 input [3:0] stock2;
	 input [3:0] stock3;
    input [3:0] stock4;
	 
    output [3:0] remainingItems;         

    reg[3:0] remainingItems;  

always @(*)  

begin  

    case(select)  

        5'b00001: remainingItems <= stock0; // Display stock0  

        5'b00010: remainingItems <= stock1; // Display stock1  

        5'b00100: remainingItems <= stock2; // Display stock2  

        5'b01000: remainingItems <= stock3; // Display stock3  

        5'b10000: remainingItems <= stock4; // Display stock4  

        default:  remainingItems <= 4'b0000; // set display to 0 

    endcase  

end  

endmodule

 

