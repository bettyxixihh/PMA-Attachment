

## Adapted from: 
https://github.com/maxcountryman/flask-login
https://www.digitalocean.com/community/tutorials/how-to-add-authentication-to-your-app-with-flask-login

## Installation

Install the extension with pip:

```sh
$ pip install flask-login
```

## Usage

To set up a Flask app:

```python
import flask

app = flask.Flask(__name__)
app.secret_key = 'super secret string'  # Change this!
```

Flask-Login works via a login manager. To kick things off, we'll set up the
login manager by instantiating it and telling it about our Flask app:

```python
import flask_login

login_manager = flask_login.LoginManager()

login_manager.init_app(app)
```

To keep things simple we're going to use a dictionary to represent a database
of users. In a real application, this would be an actual persistence layer.

```python
# Our mock database.
users = {'foo@bar.tld': {'password': 'secret'}}
```

We also need to tell Flask-Login how to load a user from a Flask request and
from its session. To do this we need to define our user object, a
`user_loader` callback, and a `request_loader` callback.

```python
class User(flask_login.UserMixin):
    pass


@login_manager.user_loader
def user_loader(email):
    if email not in users:
        return

    user = User()
    user.id = email
    return user


@login_manager.request_loader
def request_loader(request):
    email = request.form.get('email')
    if email not in users:
        return

    user = User()
    user.id = email
    return user
```

Now we're ready to define our views. We can start with a login view, which will
populate the session with authentication bits. After that we can define a view
that requires authentication.

```python
@app.route('/login', methods=['GET', 'POST'])
def login():
    if flask.request.method == 'GET':
        return '''
               <form action='login' method='POST'>
                <input type='text' name='email' id='email' placeholder='email'/>
                <input type='password' name='password' id='password' placeholder='password'/>
                <input type='submit' name='submit'/>
               </form>
               '''

    email = flask.request.form['email']
    if email in users and flask.request.form['password'] == users[email]['password']:
        user = User()
        user.id = email
        flask_login.login_user(user)
        return flask.redirect(flask.url_for('protected'))

    return 'Bad login'


@app.route('/protected')
@flask_login.login_required
def protected():
    return 'Logged in as: ' + flask_login.current_user.id
```

Finally we can define a view to clear the session and log users out:

```python
@app.route('/logout')
def logout():
    flask_login.logout_user()
    return 'Logged out'
```

We now have a basic working application that makes use of session-based
authentication. To round things off, we should provide a callback for login
failures:

```python
@login_manager.unauthorized_handler
def unauthorized_handler():
    return 'Unauthorized', 401
```

## Configuring the Database
You will be using an SQLite database. You could create an SQLite database on your own, but let’s have Flask-SQLAlchemy do it for you. You already have the path of the database specified in the __init__.py file, so you will need to tell Flask-SQLAlchemy to create the database in the Python REPL.

```python
from project import db, create_app, models
db.create_all(app=create_app()) # pass the create_app result so Flask-SQLAlchemy gets the configuration.
```
