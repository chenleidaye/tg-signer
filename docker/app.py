from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello tg-signer!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)  # 确保监听0.0.0.0，端口8080
