module digit_splitter #(
    parameter DATA_BIT = 9 // 9비트로 수정
) (
    input  wire [DATA_BIT-1:0] digit_data,
    output wire [3:0] digit_ones,
    output wire [3:0] digit_tens,
    output wire [3:0] digit_hundreds // 백의 자리 추가
);

    assign digit_ones = digit_data % 10;
    assign digit_tens = (digit_data / 10) % 10;
    assign digit_hundreds = (digit_data / 100) % 10;
endmodule