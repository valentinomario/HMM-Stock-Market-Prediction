trans = [0.95, 0.05;
         0.10, 0.90];
emis = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
        1/10, 1/10, 1/10, 1/10, 1/10, 1/2];
symb = ['a' 'b' 'c' 'd' 'e' 'f'];

seq1 = hmmgenerate(100,trans,emis,Symbols=symb);
seq2 = hmmgenerate(200,trans,emis,Symbols=symb);
seqs = {seq1,seq2};
[estTR,estE] = hmmtrain(seq1,trans,emis, Verbose=false,Symbols=symb);
