## Sintesi train
| Nome file | llim | ulim | underlyingStates | mixturesNumber | latency |inizio predizione | prediction length | % predizioni | % predizioni corrette | MAPE | note |
|---|---|---|---|---|---|---|---|---|---|---|---|
| hmmtrain-2023-07-07-00-14-40.mat | 2022-01-03 | 2023-01-03   | 5                | 4              | 10      |2023-01-03| 101| 88%| 56% |1.52%| mi ricordavo fosse 100% prediction ma evidentemente mi sbagliavo...|
| hmmtrain-2023-07-07-11-12-06.mat | 2020-07-15 | 2021-07-15   | 4                | 4              | 10      |||||| Length 491, 72.10% valide, MAPE 1.39                      |
| hmmtrain-2023-07-07-01-16-35.mat | 2020-01-03 | 2022-01-03 | 4                | 4              | 10      | 2022-01-03 |101|64%|49%|1.89%|Fa schifo|
|hmmtrain-2023-07-08-11-08-54.mat| 2020-07-15 | 2021-07-15 | 5| 4| 10| 2022-01-03|101|53.48%|58.49%|1.89%|non converge|
|hmmtrain-2023-07-08-20-54-54.mat| 2020-04-01|2021-04-01|4|4|10|2022-01-03|360|65.14%|53.51%|1.86%| da qui in poi le formule sono corrette|
|hmmtrain-2023-07-09-12-42-29|2018-04-02|2021-04-01|4|2|10|2022-01-03|350|80%|57.86%|1.69|finestra che va di 10 in 10 con orizzonte di 3 anni
|-|-|-|-|-|-|2023-01-03|101|88.12%|60.67%|1.12%|stesso modello predizioni diverse
|hmmtrain-2023-07-10-18-58-44|2017-01-03|2018-01-02|4|4|10|2023-01-03|101|59.41%|39.00%|0.89%|risultato molto buono, è stato addestrato nel bull market degli anni prima del covid e testato dal 2023 in poi. Non è andato a convergenza!
|hmmtrain-2023-07-12-10-50-11.mat|2017-01-03|2018-01-02|4|4|10|2023-01-03|101|59.41%|5.00%|0.95%|Per qualche motivo è andato malissimo
|hmmtrain-2023-07-12-13-47-04.mat|2020-01-03|2022-01-03|4|4|5|2023-01-03|101|92.08%|58.06%|1.22%|Ottimi risultati ma rendimento simulazione un pò scadente
