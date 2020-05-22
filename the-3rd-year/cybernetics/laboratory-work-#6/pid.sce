//----- непрерывный случай ---------------------------------------------
T0 = 0.76;
n = 3;
Tau = 0;
K = 4.7;
Ti = 2.5;
Td = 0.25 * Ti;
Tc = Td / 8;

s = poly(0, 's');
W1 = K * (1 + 1 / (s * Ti) + s * Td / (1 + Tc * s)) * ((-Tau * s + 2 * n)^n / (Tau * s + 2 * n)^n) / (1 + s * T0)^n;
W = W1 / (1 + W1);
Sys = syslin('c', W);

// получаем матрицы A, B, C, D из КНФ
[A, B, C, D] = abcd(Sys);
// уравнение Ляпунова
H = lyap(A, -eye(A), 'c');
I = spec(H);
disp(I);
// вычисление запаса устойчивости
if I > 0 then
    kappa = norm(H, 2);
else
    kappa = %inf;
end;
printf("непрывный случай: ||H|| = %f", kappa);

//----- дискретный случай ----------------------------------------------
T0 = 0.76;
n = 3;
Tau = 1.2;
K = 0.990429598092472398908886366054156368531953775584922568457;
Ti = 1.75703736;
Td = 0.25 * Ti;
Tc = Td / 8;

h = Tau / 100;

// дискретизация
s = poly(0, 's');
W1 = K * (1 + 1 / (s * Ti) + s * Td / (1 + Tc * s)) * ((-Tau * s + 2 * n)^n / (Tau * s + 2 * n)^n) / (1 + s * T0)^n;
W = W1 / (1 + W1);
Sys = syslin('c', W);
// получаем матрицы A, B, C, D из КНФ
Sysd = dscr(Sys, h);
// уравнение Ляпунова
H = lyap(Sysd.A, -eye(Sysd.A), 'd');
I = spec(H);
disp(I);
// вычисление запаса устойчивости
if I > 0 then
    kappa = norm(H, 2);
else
    kappa = %inf;
end;
printf("дискретный случай: ||H|| = %f", kappa);



