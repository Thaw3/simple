from flask import Blueprint

root_bp = Blueprint('root', __name__)

@root_bp.route('/')
def hello_rom():
    return "ROM Dynamics API ROOT URL's working!"