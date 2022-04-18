# flask-msearch
Adapted from: https://github.com/honmaple/flask-msearch

## Installation
   To install flask-msearch:

```sh
   pip install flask-msearch
   # when MSEARCH_BACKEND = "whoosh"
   pip install whoosh blinker
   # when MSEARCH_BACKEND = "elasticsearch", only for 6.x.x
   pip install elasticsearch==6.3.1
   #+END_SRC
```


## Quickstart

```python
     from flask_msearch import Search
     [...]
     search = Search()
     search.init_app(app)

     # models.py
     class Post(db.Model):
         __tablename__ = 'post'
         __searchable__ = ['title', 'content']

     # views.py
     @app.route("/search")
     def w_search():
         keyword = request.args.get('keyword')
         results = Post.query.msearch(keyword,fields=['title'],limit=20).filter(...)
         # or
         results = Post.query.filter(...).msearch(keyword,fields=['title'],limit=20).filter(...)
         # elasticsearch
         keyword = "title:book AND content:read"
         # more syntax please visit https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
         results = Post.query.msearch(keyword,limit=20).filter(...)
         return ''
```
## Config

```python
     # when backend is elasticsearch, MSEARCH_INDEX_NAME is unused
     # flask-msearch will use table name as elasticsearch index name unless set __msearch_index__
     MSEARCH_INDEX_NAME = 'msearch'
     # simple,whoosh,elaticsearch, default is simple
     MSEARCH_BACKEND = 'whoosh'
     # table's primary key if you don't like to use id, or set __msearch_primary_key__ for special model
     MSEARCH_PRIMARY_KEY = 'id'
     # auto create or update index
     MSEARCH_ENABLE = True
     # logger level, default is logging.WARNING
     MSEARCH_LOGGER = logging.DEBUG
     # SQLALCHEMY_TRACK_MODIFICATIONS must be set to True when msearch auto index is enabled
     SQLALCHEMY_TRACK_MODIFICATIONS = True
     # when backend is elasticsearch
     ELASTICSEARCH = {"hosts": ["127.0.0.1:9200"]}
```

## Usage
```python
     from flask_msearch import Search
     [...]
     search = Search()
     search.init_app(app)

     class Post(db.Model):
         __tablename__ = 'basic_posts'
         __searchable__ = ['title', 'content']

         id = db.Column(db.Integer, primary_key=True)
         title = db.Column(db.String(49))
         content = db.Column(db.Text)

         def __repr__(self):
             return '<Post:{}>'.format(self.title)
```

   if raise *sqlalchemy ValueError*,please pass db param to Search
```python
  db = SQLalchemy()
  search = Search(db=db)
```


### Create_index
```sh
   search.create_index()
   search.create_index(Post)
```

### Update_index
```python
    search.update_index()
    search.update_index(Post)
    # or
    search.create_index(update=True)
    search.create_index(Post, update=True)
```

### Delete_index
```python
    search.delete_index()
    search.delete_index(Post)
    # or
    search.create_index(delete=True)
    search.create_index(Post, delete=True)
```
### Custom Analyzer
    only for whoosh backend
```python
      from jieba.analyse import ChineseAnalyzer
      search = Search(analyzer=ChineseAnalyzer())
```

    or use =__msearch_analyzer__= for special model
```python
      class Post(db.Model):
          __tablename__ = 'post'
          __searchable__ = ['title', 'content', 'tag.name']
          __msearch_analyzer__ = ChineseAnalyzer()
```

### Custom index name
    If you want to set special index name for some model.
```python
     class Post(db.Model):
         __tablename__ = 'post'
         __searchable__ = ['title', 'content', 'tag.name']
         __msearch_index__ = "post111"
```

### Custom schema
```python
     from whoosh.fields import ID

     class Post(db.Model):
         __tablename__ = 'post'
         __searchable__ = ['title', 'content', 'tag.name']
         __msearch_schema__ = {'title': ID(stored=True, unique=True), 'content': 'text'}
```

    *Note:* if you use =hybrid_property=, default field type is =Text= unless set special =__msearch_schema__=

### Custom parser
```python
      from whoosh.qparser import MultifieldParser

      class Post(db.Model):
          __tablename__ = 'post'
          __searchable__ = ['title', 'content']

          def _parser(fieldnames, schema, group, **kwargs):
              return MultifieldParser(fieldnames, schema, group=group, **kwargs)

          __msearch_parser__ = _parser
```

    *Note:* Only for =MSEARCH_BACKEND= is =whoosh=

### Custom index signal
    *flask-msearch* uses flask signal to update index by default, if you want to use other asynchronous tools such as celey to update index, please set special =MSEARCH_INDEX_SIGNAL=
```python
      # app.py
      app.config["MSEARCH_INDEX_SIGNAL"] = celery_signal
      # or use string as variable
      app.config["MSEARCH_INDEX_SIGNAL"] = "modulename.tasks.celery_signal"
      search = Search(app)

      # tasks.py
      from flask_msearch.signal import default_signal

      @celery.task(bind=True)
      def celery_signal_task(self, backend, sender, changes):
          default_signal(backend, sender, changes)
          return str(self.request.id)

      def celery_signal(backend, sender, changes):
          return celery_signal_task.delay(backend, sender, changes)
```

## Relate index(*Experimental*)
   for example
```python
     class Tag(db.Model):
         __tablename__ = 'tag'

         id = db.Column(db.Integer, primary_key=True)
         name = db.Column(db.String(49))

     class Post(db.Model):
         __tablename__ = 'post'
         __searchable__ = ['title', 'content', 'tag.name']

         id = db.Column(db.Integer, primary_key=True)
         title = db.Column(db.String(49))
         content = db.Column(db.Text)

         # one to one
         tag_id = db.Column(db.Integer, db.ForeignKey('tag.id'))
         tag = db.relationship(
             Tag, backref=db.backref(
                 'post', uselist=False), uselist=False)

         def __repr__(self):
             return '<Post:{}>'.format(self.title)
```

   You must add *msearch_FUN* to Tag model,or the *tag.name* can't auto update.
```python
   class Tag....
     ......
     def msearch_post_tag(self, delete=False):
         from sqlalchemy import text
         sql = text('select id from post where tag_id=' + str(self.id))
         return {
             'attrs': [{
                 'id': str(i[0]),
                 'tag.name': self.name
             } for i in db.engine.execute(sql)],
             '_index': Post
         }
```