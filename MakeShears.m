function [S1, S2] = MakeShears(theta)

S1 = eye(2);
S2 = eye(2);

S1(1,2) = -tan(theta/2);
S2(2,1) = sin(theta);
