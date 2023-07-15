## Sintesi train
| Nome file | Azione | llim | ulim | underlyingStates | mixturesNumber | latency | Dynamic Edges |inizio predizione | prediction length | % predizioni | % predizioni corrette | MAPE | note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hmmtrain-2023-07-07-00-14-40.mat | AAPL | 2022-01-03 | 2023-01-03   | 5 | 4 | 10 | 0 |2023-01-03| 101| 88%| 56% |1.52%| mi ricordavo fosse 100% prediction ma evidentemente mi sbagliavo...|
| hmmtrain-2023-07-07-11-12-06.mat | AAPL | 2020-07-15 | 2021-07-15   | 4 | 4 | 10 | 0 ||||| 1.39%| Length 491, 72.10% valide|
| hmmtrain-2023-07-07-01-16-35.mat | AAPL | 2020-01-03 | 2022-01-03 | 4 | 4 | 10 | 0 | 2022-01-03 |101|64%|49%|1.89%|Fa schifo|
|hmmtrain-2023-07-08-11-08-54.mat| AAPL | 2020-07-15 | 2021-07-15 | 5| 4| 10| 0 | 2022-01-03|101|53.48%|58.49%|1.89%|non converge|
|hmmtrain-2023-07-08-20-54-54.mat| AAPL | 2020-04-01|2021-04-01|4|4|10| 0 |2022-01-03|360|65.14%|53.51%|1.86%| da qui in poi le formule sono corrette|
|hmmtrain-2023-07-09-12-42-29.mat| AAPL |2018-04-02|2021-04-01|4|2|10| 0 |2022-01-03|350|80%|57.86%|1.69|finestra che va di 10 in 10 con orizzonte di 3 anni
|-|-|-|-|-|-|-|-|2023-01-03|101|88.12%|60.67%|1.12%|stesso modello predizioni diverse
|hmmtrain-2023-07-10-18-58-44.mat| AAPL |2017-01-03|2018-01-02|4|4|10| 0 |2023-01-03|101|59.41%|39.00%|0.89%|risultato molto buono, è stato addestrato nel bull market degli anni prima del covid e testato dal 2023 in poi. Non è andato a convergenza!
|hmmtrain-2023-07-12-10-50-11.mat| AAPL |2017-01-03|2018-01-02|4|4|10| 0 |2023-01-03|101|59.41%|5.00%|0.95%|Per qualche motivo è andato malissimo
|hmmtrain-2023-07-12-13-47-04.mat| AAPL |2020-01-03|2022-01-03|4|4|5| 0 |2023-01-03|101|92.08%|58.06%|1.22%|Ottimi risultati ma rendimento simulazione un pò scadente
|hmmtrain-2023-07-12-15-01-17.mat| AAPL |2020-04-02|2022-04-01|4|4|10| 0 |2023-01-03|101|50.50%|62.75%|1.20%|50% delle previsioni non mi piace|
|hmmtrain-2023-07-13-21-00-52.mat|DELL|2021-01-04|2022-01-03|4|4|10|1|2022-04-08|300|51.00%|53.59%|1.45%|:\( |
|hmmtrain-2023-07-13-22-14-14.mat|AAPL|2021-01-04|2022-01-03|4|4|10|0|2022-04-08|300|54.33%|25.77%|1.23%| % corrette pessima ma mape basso, l'investimento fa rendimento 0 a causa dei tantissimi errori
|hmmtrain-2023-07-14-00-34-47.mat|IBM|2021-01-04|2022-01-03|4|4|10|1|2022-04-08|300|91.00%|49.08%|1.08%|peccato
|hmmtrain-2023-07-14-11-17-54.mat|DELL|2021-04-01|2022-04-01|4|4|10|1|2023-01-03|101|59.41%|53.33%|1.49%| simulazione investimento non buona BASTA CON DELL PER ME
|hmmtrain-2023-07-14-13-32-34.mat|AAPL|2020-04-01|2020-10-01|4|4|10|0|2023-01-03|120|50.83%|68.85%|1.26%|
|hmmtrain-2023-07-14-14-32-00.mat|IBM|2020-01-03|2022-01-03|4|4|10|1|2023-01-03|130|100.00%|51.54%|0.86%|compra sempre :(
|hmmtrain-2023-07-14-17-53-07.mat|IBM|2003-02-10|2004-09-10|4|4|10|1|2004-10-13|100|100.00%|62.00%|0.68%|TRAIN PAPER IBM - ma compra sempre sto deficiente - dynamic edges scemo
|hmmtrain-2023-07-14-18-21-31.mat|AAPL|2019-01-03|2022-01-03|4|4|10|1|2023-01-03|101|86.14%|41.38%|0.93%| 
|hmmtrain-2023-07-14-21-59-54.mat|AAPL|2017-01-03|2018-01-02|4|4|10|1|2023-01-03|101|89.11%|70.00%|0.90%|
#### Nuova versione
| Nome file | Azione | llim | ulim | underlyingStates | mixturesNumber | latency |shift window by one| Dynamic Edges |inizio predizione | prediction length | % predizioni | % predizioni corrette | MAPE | note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|hmmtrain-2023-07-15-14-54-31.mat|IBM|2022-01-03|2023-01-03|4|4|10||1|2023-01-03|131|61.83%|40.74%|1.18%| non mi piace ma compra e vende coerentemente con le previsioni 
|hmmtrain-2023-07-15-12-06-30.mat|AAPL|2019-01-03|2022-01-03|3|4|10||0|2023-01-03|124|79.03%|45.92%|1.08%|basse predizioni corrette ma buon MAPE
|hmmtrain-2023-07-15-16-11-08.mat|IBM|2003-02-10|2004-09-10|4|4|10||1|2004-10-13|70|94.29%|54.55%|0.77%| TRAIN PAPER IBM
|hmmtrain-2023-07-15-17-31-41.mat|AAPL|2021-01-04|2022-01-03|4|4|5||0|2023-01-03|124|79.03%|53.06%|1.05%|Buon MAPE, dobbiamo alzare il DPA
|hmmtrain-2023-07-15-17-49-07.mat|AAPL|2021-01-04|2022-01-03|4|4|10|1|1|2023-01-03|124|45.97%|49.12%|1.21%|stessa train di prima ma con una finestra di 10, il risultato è leggermente peggiore

