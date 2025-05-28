from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/send", methods=["POST"])
def send():
    data = request.json
    response = send_data(data.get("message", ""))
    return jsonify({"response": response})
