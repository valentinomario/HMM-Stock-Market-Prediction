# HMM-Stock-Market-Prediction
## Abstract
The stock market presents a challenging environment for accurately predicting future stock prices due to its intricate and ever-changing nature. However, the utilization of advanced methodologies can significantly enhance the precision of stock price predictions. One such method is Hidden Markov Models (HMMs). HMMs are statistical models that can be used to model the behavior of a partially observable system, making them suitable for modeling stock prices based on historical data. Accurate stock price predictions can help traders make better investment decisions, leading to increased profits.

In this article, we trained and tested a Hidden Markov Model for the purpose of predicting a stock closing price based on its opening price and the preceding day's prices. The model's performance has been evaluated using two indicators:  Mean Average Prediction Error (MAPE), which specifies the average accuracy of our model, and Directional Prediction Accuracy (DPA),  a newly introduced indicator that accounts for the number of fractional change predictions that are correct in sign.

<div align = center>

[<kbd> <br> Paper <br> </kbd>][pdf] 

[<kbd> <br> Simulation results <br> </kbd>][simres]

</div>

[pdf]: ./docs/HMM-Stock-Market-Prediction.pdf
[simres]: ./trains.md
## Setup and usage
MATLAB requires the following add-ons:
- Financial Toolbox&trade; (only used for plotting candlestick charts)
- Statistics and Machine Learning Toolbox&trade;

Clone the repository, then run `setup()` to add the folders to MATLAB path. You can use `setup(1)` to only update the path for the current MATLAB session.
Customize train/test parameters in `init.m`. Notice that if `TRAIN = 0`, the program will only make predictions using the pre-trained checkpoint specified in the `filename` variable. 
Run `main.m` to start the program.
MATLAB will print in the Command Window a string ready to be added to the [train table](./trains.md).

## License
See [License](./LICENSE.md) file.
