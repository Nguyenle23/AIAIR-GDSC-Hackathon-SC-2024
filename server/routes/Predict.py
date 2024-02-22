from flask import Blueprint

from controllers.PredictController import PredictController

Predict = Blueprint('Predict', __name__)

Predict.route('/lr/temp', methods = ['POST'])(PredictController.predictLRTemp)
Predict.route('/lr/humi', methods = ['POST'])(PredictController.predictLRHumi)
Predict.route('/lr/co2', methods = ['POST'])(PredictController.predictLRCO2)
Predict.route('/lr/co', methods = ['POST'])(PredictController.predictLRCO)
Predict.route('/lr/uv', methods = ['POST'])(PredictController.predictLRUV)
Predict.route('/lr/pm25', methods = ['POST'])(PredictController.predictLRPM25)

Predict.route('/prophet/temp', methods = ['POST'])(PredictController.predictTempProphet)
Predict.route('/prophet/humi', methods = ['POST'])(PredictController.predictHumiProphet)
Predict.route('/prophet/co2', methods = ['POST'])(PredictController.predictCO2Prophet)
Predict.route('/prophet/co', methods = ['POST'])(PredictController.predictCOProphet)
Predict.route('/prophet/uv', methods = ['POST'])(PredictController.predictUVProphet)
Predict.route('/prophet/pm25', methods = ['POST'])(PredictController.predictPM25Prophet)

Predict.route('/prophet-lstm/temp', methods = ['POST'])(PredictController.predictTempProphetLSTM)

Predict.route('/lstm/temp', methods = ['POST'])(PredictController.predictTempLSTM)
Predict.route('/lstm/humi', methods = ['POST'])(PredictController.predictHumiLSTM)
Predict.route('/lstm/co2', methods = ['POST'])(PredictController.predictCO2LSTM)
Predict.route('/lstm/co', methods = ['POST'])(PredictController.predictCOLSTM)
Predict.route('/lstm/uv', methods = ['POST'])(PredictController.predictUVLSTM)
Predict.route('/lstm/pm25', methods = ['POST'])(PredictController.predictPM25LSTM)

Predict.route('/gb/temp', methods = ['POST'])(PredictController.predictGBTemp)
Predict.route('/gb/humi', methods = ['POST'])(PredictController.predictGBHumi)
Predict.route('/gb/co2', methods = ['POST'])(PredictController.predictGBCO2)
Predict.route('/gb/co', methods = ['POST'])(PredictController.predictGBCO)
Predict.route('/gb/uv', methods = ['POST'])(PredictController.predictGBUV)
Predict.route('/gb/pm25', methods = ['POST'])(PredictController.predictGBPM25)

Predict.route('/xgb/temp', methods = ['POST'])(PredictController.predictXGBTemp)
Predict.route('/xgb/humi', methods = ['POST'])(PredictController.predictXGBHumi)
Predict.route('/xgb/co2', methods = ['POST'])(PredictController.predictXGBCO2)
Predict.route('/xgb/co', methods = ['POST'])(PredictController.predictXGBCO)
Predict.route('/xgb/uv', methods = ['POST'])(PredictController.predictXGBUV)
Predict.route('/xgb/pm25', methods = ['POST'])(PredictController.predictXGBPM25)

Predict.route('/rf/temp', methods = ['POST'])(PredictController.predictRFTemp)
Predict.route('/rf/humi', methods = ['POST'])(PredictController.predictRFHumi)
Predict.route('/rf/co2', methods = ['POST'])(PredictController.predictRFCO2)
Predict.route('/rf/co', methods = ['POST'])(PredictController.predictRFCO)
Predict.route('/rf/uv', methods = ['POST'])(PredictController.predictRFUV)
Predict.route('/rf/pm25', methods = ['POST'])(PredictController.predictRFPM25)