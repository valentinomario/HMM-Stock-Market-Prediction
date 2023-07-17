## Sintesi train
| Nome file | Azione | llim | ulim | underlyingStates | mixturesNumber | latency | Dynamic Edges |inizio predizione | prediction length | % predizioni | DPA | MAPE | note |
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
| Nome file | Azione | llim | ulim | underlyingStates | mixturesNumber | latency |shift window by one| Dynamic Edges |inizio predizione | prediction length | % predizioni | DPA | MAPE | note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|hmmtrain-2023-07-15-14-54-31.mat|IBM |2022-01-03|2023-01-03|4|4|10|-|1|2023-01-03|131|61.83%|40.74%|1.18%| non mi piace ma compra e vende coerentemente con le previsioni 
|hmmtrain-2023-07-15-12-06-30.mat|AAPL|2019-01-03|2022-01-03|3|4|10|-|0|2023-01-03|124|79.03%|45.92%|1.08%|basse predizioni corrette ma buon MAPE
|hmmtrain-2023-07-15-16-11-08.mat|IBM |2003-02-10|2004-09-10|4|4|10|-|1|2004-10-13|70 |94.29%|54.55%|0.77%| TRAIN PAPER IBM (4 mixtures)
|hmmtrain-2023-07-15-17-31-41.mat|AAPL|2021-01-04|2022-01-03|4|4|5 |-|0|2023-01-03|124|79.03%|53.06%|1.05%|Buon MAPE, dobbiamo alzare il DPA
|hmmtrain-2023-07-15-17-49-07.mat|AAPL|2021-01-04|2022-01-03|4|4|10|1|1|2023-01-03|124|45.97%|49.12%|1.21%|stessa train di prima ma con una finestra di 10, il risultato è leggermente peggiore
|hmmtrain-2023-07-15-18-46-02.mat|AAPL|2020-08-03|2021-08-02|4|4|5 |1|1|2022-01-03|375|32.80%|53.66%|1.37%|la simulazione di investimento dal 2022 guadagna quanto aapl ma con un "rischio" molto più basso
|hmmtrain-2023-07-15-20-35-18.mat|AAPL|2003-02-10|2004-09-10|4|4|10|1|1|2004-10-13|70 |70.00%|40.82%|1.78%|TRAIN PAPER AAPL (4 mixtures)
|hmmtrain-2023-07-16-02-53-51.mat|AAPL|2003-02-10|2004-09-10|4|5|10|1|1|2004-10-13|70 |70.00%|63.27%|1.73%|train paper AAPL (5 mixtures) - siamo ricchi forse
|---|AAPL|---|---|-|-|-|-|-|2004-09-13|92|77.17%|61.97%|1.64%|test con un mese in più
|hmmtrain-2023-07-16-11-36-01.mat|IBM|2003-02-10|2004-09-10|4|5|10|1|1|2004-10-13|70|94.29%|57.58%|0.82%|Ottimi risultati per il paper, grafico a candele non bellissimo ma sovraperformiamo IBM
|---|IBM|---|---|-|-|-|-|-|2004-09-13|92|95.65%|56.82%|0.74%|risultati migliori dei precedenti con un mese in più. Comunque leggermente peggiore del paper di riferimento (0.6%)
|hmmtrain-2023-07-16-17-10-39.mat|AAPL|2020-01-03|2022-01-03|4|4|10|1|1|2023-01-03|124|87.90%|36.70%|1.02%|368 iterations, shiftWindby1 =1
|hmmtrain-2023-07-16-18-42-33.mat|DELL|2021-01-04|2022-01-03|3|4|10|1|1|2023-01-03|130|53.85%|28.57%|1.70%| Pessima, l'ho fatta con 3 per vedere che effetto ha la diminuzione del numero di stati
|hmmtrain-2023-07-16-21-17-08.mat|DELL|2021-01-04|2022-01-03|6|4|10|1|1|2023-01-03|130|48.46%|60.32%|1.45%| Migliorata con 6 stati, buono per le derivate corrette ma MAPE alto, l'investimento fa un 20% pottoperformando un pò DELL 
|hmmtrain-2023-07-16-22-50-11.mat|IBM|2003-02-10|2004-09-10|4|6|10|1|1|2004-09-13|92|95.65%|60.23%|0.68%|OTTIMA IBM sovraperformiamo di molto, non è andata a convergenza!
|hmmtrain-2023-07-17-02-52-06.mat|AAPL|2017-01-03|2019-01-03|4|4|10|1|0|2023-01-03|124|85.48%|40.57%|1.01%| ha un DMA bassissimo 