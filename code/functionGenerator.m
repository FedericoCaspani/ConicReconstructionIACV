%computeLambda and computeDelta Generator

A = sym('A', [4 4]);
B = sym('B', [4 4]);
lam = sym('lam');

C = A + lam * B;
a4_lam = det(C);
coeffs_a4 = fliplr(coeffs(a4_lam, lam));

I2 = coeffs_a4(2);
I3 = coeffs_a4(3);
I4 = coeffs_a4(4);

lambda = -I3 / (2*I2);
delta = I3^2 - 4*I2*I4;

ht = matlabFunction(lambda, "File", "computeLambda.m","Vars", {A,B});
ht2 = matlabFunction(delta, "File", "computeDelta.m", "Vars", {A,B});