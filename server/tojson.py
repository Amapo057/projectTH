from json import *

def ToJson(type, data, data2):
    sendData = {
        'type': type,
        'action': data,
        'action2': data2
    }
    return dump(sendData)