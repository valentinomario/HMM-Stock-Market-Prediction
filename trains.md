# Training parameters and simulations results
|| File Name | Stock | llim | ulim | Underlying States | Mixtures Number | Latency | Shift Window by One | Dynamic Edges | Prediction Start | Prediction Length | % Predictions | DPA | MAPE | Note |
|---|---------------------------------|-------|------------|------------|-------------------|-----------------|---------|----------------------|--------------|------------------|-------------------|---------------|-------|--------|-----------------------------------------------------------------------------------------------------------|
|| hmmtrain-2023-07-15-14-54-31.mat | IBM | 2022-01-03 | 2023-01-03 | 4 | 4 | 10 | - | 1 | 2023-01-03 | 131 | 61.83% | 40.74% | 1.18% | I don't like it, but it buys and sells consistently with the predictions |
|| hmmtrain-2023-07-15-12-06-30.mat | AAPL | 2019-01-03 | 2022-01-03 | 3 | 4 | 10 | - | 0 | 2023-01-03 | 124 | 79.03% | 45.92% | 1.08% | Low correct predictions, but good MAPE (Mean Absolute Percentage Error) |
||-|-|-|-|-|-|-|-|-|2022-01-03|375|58.40%|50.23%|1.35%|worse MAPE on longer prediction, stil accettable
|| hmmtrain-2023-07-15-16-11-08.mat | IBM | 2003-02-10 | 2004-09-10 | 4 | 4 | 10 | - | 1 | 2004-10-13 | 70 | 94.29% | 54.55% | 0.77% | IBM, dates from paper (4 mixtures) |
|| hmmtrain-2023-07-15-17-31-41.mat | AAPL | 2021-01-04 | 2022-01-03 | 4 | 4 | 5 | - | 0 | 2023-01-03 | 124 | 79.03% | 53.06% | 1.05% | Good MAPE, but we need to increase the DPA |
|| hmmtrain-2023-07-15-17-49-07.mat | AAPL | 2021-01-04 | 2022-01-03 | 4 | 4 | 10 | 1 | 1 | 2023-01-03 | 124 | 45.97% | 49.12% | 1.21% | Same training as before but with a window of 10, the result is slightly worse |
|| hmmtrain-2023-07-15-18-46-02.mat | AAPL | 2020-08-03 | 2021-08-02 | 4 | 4 | 5 | 1 | 1 | 2022-01-03 | 375 | 32.80% | 53.66% | 1.37% | The investment simulation from 2022 gains as much as AAPL but with much lower "risk" |
|| hmmtrain-2023-07-15-20-35-18.mat | AAPL | 2003-02-10 | 2004-09-10 | 4 | 4 | 10 | 1 | 1 | 2004-10-13 | 70 | 70.00% | 40.82% | 1.78% | AAPL, dates from paper (4 mixtures) |
|&#11088;| hmmtrain-2023-07-16-02-53-51.mat | AAPL | 2003-02-10 | 2004-09-10 | 4 | 5 | 10 | 1 | 1 | 2004-10-13 | 70 | 70.00% | 63.27% | 1.73% | AAPL, dates from paper (5 mixtures) - we are rich, maybe |
|| --- | AAPL | --- | --- | - | - | - | - | - | 2004-09-13 | 92 | 77.17% | 61.97% | 1.64% | Test with one more month |
|| hmmtrain-2023-07-16-11-36-01.mat | IBM | 2003-02-10 | 2004-09-10 | 4 | 5 | 10 | 1 | 1 | 2004-10-13 | 70 | 94.29% | 57.58% | 0.82% | Excellent results for the paper, the candle chart is not very nice, but we outperform IBM |
|| --- | IBM | --- | --- | - | - | - | - | - | 2004-09-13 | 92 | 95.65% | 56.82% | 0.74% | Better results than previous with one more month. However, slightly worse than the reference paper (0.6%) |
|| hmmtrain-2023-07-16-17-10-39.mat | AAPL | 2020-01-03 | 2022-01-03 | 4 | 4 | 10 | 1 | 1 | 2023-01-03 | 124 | 87.90% | 36.70% | 1.02% | 368 iterations, shiftWindby1 =1 |
|| hmmtrain-2023-07-16-18-42-33.mat | DELL | 2021-01-04 | 2022-01-03 | 3 | 4 | 10 | 1 | 1 | 2023-01-03 | 130 | 53.85% | 28.57% | 1.70% | Terrible, I did it with 3 to see the effect of reducing the number of states |
|| hmmtrain-2023-07-16-21-17-08.mat | DELL | 2021-01-04 | 2022-01-03 | 6 | 4 | 10 | 1 | 1 | 2023-01-03 | 130 | 48.46% | 60.32% | 1.45% | Improved with 6 states, good for correct derivatives but high MAPE, the investment is 20% underperforming DELL |
|| --- |DELL| --- | -- | - | - | - | - | - |2022-01-03|381|37.01%|53.19%|1.59%| worse MAPE and DPA values, but DELL is outperformed
|&#11088;| hmmtrain-2023-07-16-22-50-11.mat | IBM | 2003-02-10 | 2004-09-10 | 4 | 6 | 10 | 1 | 1 | 2004-09-13 | 92 | 95.65% | 60.23% | 0.68% | EXCELLENT IBM, we outperform by a lot, it did not converge! |
|| hmmtrain-2023-07-17-14-30-46.mat |IBM |2003-02-10 |2004-09-10 | 4 | 6 |10 |1 |1 | 2004-09-13 | 92 | 95.65% | 59.09% | 0.68% | Continued last training until convergence. No particular improvement|
|&#11088;| hmmtrain-2023-07-17-02-52-06.mat | AAPL | 2017-01-03 | 2019-01-03 | 4 | 4 | 10 | 1 | 0 | 2023-01-03 | 124 | 85.48% | 40.57% | 1.01% | It has a very low DPA |
|| hmmtrain-2023-07-17-09-04-46.mat | IBM | 2003-02-10 | 2004-09-10 | 5 | 6 | 10 | 1 | 1 | 2004-09-13 | 92 | 95.65% | 44.32% | 0.96% | Convergence did not happen |
|| hmmtrain-2023-07-17-00-10-24.mat | IBM | 2003-02-10 | 2004-09-10 | 5 | 5 | 10 | 1 | 1 | 2004-09-13 | 92 | 95.65% | 51.14% | 0.73% | The data seems good, but in reality, we lost a lot of money |
|| hmmtrain-2023-07-17-16-21-11.mat|IBM|2021-01-04|2023-01-03|4|6|10|1|1|2023-01-04|130|84.62%|52.73%|0.88%| |
|| hmmtrain-2023-07-17-20-46-13.mat|AAPL|2003-02-10|2004-09-10|5|6|10|1|1|2004-09-13|92|77.17%|54.93%|1.54%| no convergence
||hmmtrain-2023-07-19-15-30-21.mat|AAPL|2017-01-03|2018-01-03|4|4|10|1|1|2023-01-03|124|50.00%|35.48%|0.82%|converged after 440 iter
||hmmtrain-2023-07-19-15-20-05.mat|IBM|2021-01-04|2022-01-03|4|5|10|1|0|2023-01-03|131|84.73%|32.43%|0.94%| bad data, good simulation in Feb/Jun 
||hmmtrain-2023-07-19-15-56-18.mat|AAPL|2003-02-10|2004-09-10|5|6|10|1|1|2004-09-13|92|77.17%|52.11%|1.50%| stopped after 500 iter
||hmmtrain-2023-07-20-00-25-45.mat|IBM|2003-02-10|2004-09-10|4|4|10|1|0|2004-10-13|70|94.29%|21.21%|0.80%| Number of points=[ 100 10 10]
||hmmtrain-2023-07-20-22-25-52.mat|DELL|2020-05-011|2022-05-10|5|4|10|1|0|2023-01-03|130|80.77%|35.24%|1.17%| last DELL train, bad data 