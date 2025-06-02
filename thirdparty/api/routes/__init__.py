from .root_routes import root_bp
from .sql_routes import sql_bp

def register_routes(app):
    app.register_blueprint(root_bp)
    app.register_blueprint(sql_bp)
# Register all routes in the application
    # This function can be expanded to include more blueprints as needed
    # For example, you could add:
    # from .user_routes import user_bp
    # app.register_blueprint(user_bp)
    # This allows for modular route management and easier maintenance.
    # You can also add error handling routes or other blueprints here
    # as your application grows.
    # This modular approach helps keep the code organized and maintainable.
    # You can also add more blueprints for other parts of your application
    # as needed, such as authentication, user management, etc.
    # This way, you can keep your routes organized and easily manageable.   