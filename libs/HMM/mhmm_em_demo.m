if 0
  O = 4;
  T = 10;
  nex = 50;
  M = 2;
  Q = 3;
else
  O = 1;          %Number of coefficients in a vector 
  T = 10;         %Number of vectors in a sequence 
  nex = 100;      %Number of sequences 
  M = 5;          %Number of mixtures 
  Q = 4;          %Number of states 
end
cov_type = 'full';

data = randn(O,T,nex);

% initial guess of parameters
prior0 = normalize(rand(Q,1));
transmat0 = mk_stochastic(rand(Q,Q));

if 0
  Sigma0 = repmat(eye(O), [1 1 Q M]);
  % Initialize each mean to a random data point
  indices = randperm(T*nex);
  mu0 = reshape(data(:,indices(1:(Q*M))), [O Q M]);
  mixmat0 = mk_stochastic(rand(Q,M));
else
  [mu0, Sigma0] = mixgauss_init(Q*M, data, cov_type);
  mu0 = reshape(mu0, [O Q M]);
  Sigma0 = reshape(Sigma0, [O O Q M]);
  mixmat0 = mk_stochastic(rand(Q,M));
end

[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 5);


loglik = mhmm_logprob(data, prior1, transmat1, mu1, Sigma1, mixmat1);

