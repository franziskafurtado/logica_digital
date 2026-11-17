module sistema_x (
    input  wire [3:0] X,
    output wire       Q
);

    wire nX2, nX1;

    CLKINVX1HVT inv_x2 (
        .A(X[2]),
        .Y(nX2)
    );

    CLKINVX1HVT inv_x1 (
        .A(X[1]),
        .Y(nX1)
    );

    AND4X1HVT and4 (
        .A(X[3]),
        .B(nX2),
        .C(nX1),
        .D(X[0]),
        .Y(Q)
    );

endmodule
