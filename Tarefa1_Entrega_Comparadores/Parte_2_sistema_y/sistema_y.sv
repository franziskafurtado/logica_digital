module sistema_y (
    input  wire [3:0] X,
    input  wire [3:0] REF,
    output wire       Q
);

    wire [3:0] igual;

    // Cada XNOR identifica se um par de bits e igual.
    XNOR2X1LVT xnor0 (
        .A(X[0]),
        .B(REF[0]),
        .Y(igual[0])
    );

    XNOR2X1LVT xnor1 (
        .A(X[1]),
        .B(REF[1]),
        .Y(igual[1])
    );

    XNOR2X1LVT xnor2 (
        .A(X[2]),
        .B(REF[2]),
        .Y(igual[2])
    );

    XNOR2X1LVT xnor3 (
        .A(X[3]),
        .B(REF[3]),
        .Y(igual[3])
    );

    // Q = 1 somente quando os quatro pares de bits sao iguais.
    AND4X1HVT and1 (
        .A(igual[0]),
        .B(igual[1]),
        .C(igual[2]),
        .D(igual[3]),
        .Y(Q)
    );

endmodule
