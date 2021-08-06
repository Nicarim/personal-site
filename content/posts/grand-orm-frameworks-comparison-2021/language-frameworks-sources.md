---
title: "Languages and frameworks. Sources and choice"
date: 2021-08-06T13:59:34+02:00
draft: true
---

## Sources
List of places I consulted for finding informations. I also used Google to find frameworks, but didn't include search here as that may not lead to same information.

### Choice of languages to consider
- https://pypl.github.io/PYPL.html
- https://www.tiobe.com/tiobe-index/
- Personal curation based on percieved popularity (Like adding Elixir thanks to BEAM stack)

### General
- https://en.wikipedia.org/wiki/List_of_object%E2%80%93relational_mapping_software

### Python
- https://vertabelo.com/blog/orms-under-the-hood/
- https://github.com/topics/python?o=desc&q=orm&s=stars

### C#
- https://grauenwolf.github.io/DotNet-ORM-Cookbook/ORMs.htm
- https://www.reddit.com/r/dotnet/comments/fi7ztw/best_net_orm_in_2020/

### Java
- https://www.reddit.com/r/java/comments/5oit04/finding_the_best_java_orm_framework_for_postgresql/
- https://www.reddit.com/r/java/comments/einrg0/for_java_applications_is_orm_or_sql_more_common/
- https://dzone.com/articles/best-java-orm-frameworks-for-postgresql

### Go
- https://github.com/shafferjohn/Go-ORM-Frameworks-Ranking
- https://www.reddit.com/r/golang/comments/fzs8p1/what_orm_are_you_use/
- https://awesome-go.com/#orm

### Javascript/Node.js
- https://www.prisma.io/dataguide/database-tools/top-nodejs-orms-query-builders-and-database-libraries
- https://github.com/sindresorhus/awesome-nodejs#database
- https://www.reddit.com/r/node/comments/ifbgmr/best_orm_for_node/

### Rust
- https://github.com/rust-unofficial/awesome-rust#database-1
- https://crates.io/keywords/orm

### Ruby
- https://github.com/markets/awesome-ruby#web-frameworks
- http://ramaze.net/documentation/file.models.html
- https://padrinorb.com/guides/getting-started/basic-projects/

### Elixir
- https://github.com/h4cc/awesome-elixir

### C++
- https://www.reddit.com/r/cpp/comments/698f5j/why_does_the_c_community_dont_have_a_famous_orm/
- https://github.com/fffaraz/awesome-cpp#database
- https://www.reddit.com/r/cpp/comments/9g9qky/whats_your_opinion_about_the_current_state_of_orm/

### PHP
- https://github.com/ziadoz/awesome-php#database
- https://www.slant.co/topics/5639/~php-orms

### Scala
- https://stackoverflow.com/questions/1140448/what-orms-work-well-with-scala

### Dart
- https://project-awesome.org/yissachar/awesome-dart#orm

### C
- https://stackoverflow.com/questions/10577006/is-there-some-convenient-orm-library-framework-for-c

### Perl
- https://stackoverflow.com/questions/281440/is-there-an-orm-for-perl
- https://github.com/hachiojipm/awesome-perl#database

### R
- https://stackoverflow.com/questions/11988011/is-there-a-package-for-object-relational-mapping-in-r

### Obj-C
- https://stackoverflow.com/questions/8545392/objective-c-orm/23690458

### COBOL
- https://github.com/mickaelandrieu/awesome-cobol

## Criterias

- Supports following databases, be it by acknowledged community effort or officially.
  - MySQL/MariaDB
  - PostgreSQL
  - SQLite

- By acknowledged community effort it is meant that documentation of specific framework mentions that as possibility. Support for these databases must also be considered stable.
- Framework must have been updated in at least last 18 months (As of 2021-08-06, so last release must be newer than 2020-02-06)
- Framework must not be paid, or should have non-commercial license for testing purposes
- Linux support - most of nowadays web software is deployed on Linux servers.

Motivation for this specific choice is to make it humanly possible to test it, and to provide the most value out of this comparison :)

## Considered languages
This is the list of languages that were considered for following comparison. 
- Python
- C#
- Java
- Go
- JavaScript/node.js
- Rust
- Ruby
- C++
- Elixir
- PHP
- Scala
- Swift
- Kotlin
- Perl
- Julia
- Pascal
- Groovy
- Common Lisp
- Ada

These languages were considered, but didn't have viable candidates (no popular ORM framework matching criterias)
- Dart
- C
- Lua
- R
- Obj-C
- COBOL

## Considered frameworks

According to chosen languages, I've made a research on available ORM frameworks and have written down these that I'll cover

- (✓) - means framework was checked for mentioned criterias
- (?) - means I couldn't find information at hand
<!-- TODO: Add urls to respective frameworks, add sources for disqualifications -->

### Python
- [Django ORM](https://docs.djangoproject.com/) (✓)
- [SQLAlchemy](https://www.sqlalchemy.org/) (✓)
- [PeeWee](http://docs.peewee-orm.com/en/latest/) (✓)
- [PonyORM](https://ponyorm.org/) (✓)
- [SQLObject](http://www.sqlobject.org/) (✓)
- [MasoniteORM](https://orm.masoniteproject.com/) (✓)
- [pugsql](https://pugsql.org/) (?)
- [~~records~~](https://github.com/kennethreitz/records) - Too old
- [~~canoncial/Storm~~](https://storm.canonical.com/) - Disqualified due to lack of MySQL support
- [~~Piccolo~~](https://github.com/piccolo-orm/piccolo) - lack of MySQL support, limited SQLite support

### C#
- [EFCore](https://github.com/dotnet/efcore) (?)
- [Dapper](https://github.com/StackExchange/dapper-dot-net) (?)
- [Entity Framework 6](https://github.com/dotnet/ef6) (?)
- [NHibernate](https://github.com/nhibernate/nhibernate-core) (?)
- [RepoDB](https://github.com/mikependon/RepoDB) (?)
- [ServiceStack](https://github.com/ServiceStack/ServiceStack) (?)
- [LINQ to DB](https://github.com/linq2db/linq2db) (?)
- [SubSonic 3.0](https://github.com/subsonic/Subsonic-3.0) (?)
- [PetaPoco](https://github.com/CollaboratingPlatypus/PetaPoco) (?)
- [~~Massive~~](https://github.com/FransBouma/Massive) - Last update 5 years ago
- [~~LLBLGen Pro~~](https://www.llblgen.com/) - their built in ORM doesn't support [SQLite](https://www.llblgen.com/Pages/LLBLGenProRTF.aspx)
- [~~BFC Professional~~](https://contentgalaxy.com/software/bfc) - no clue how to use it, no docs easily available
- [~~Chain~~](https://github.com/docevaad/Chain) - no built in MySQL support
- ~~ADO.NET~~ - [TIL: it is not ORM](https://stackoverflow.com/questions/40506382/what-is-the-difference-between-an-orm-and-ado-net) :)

### Java
- [Hibernate](https://github.com/hibernate/hibernate-orm) (?)
- [Apache Cayenne](https://github.com/apache/cayenne) (?)
- [Apache OpenJPA](http://openjpa.apache.org/) (?)
- [DataNucleus](https://www.datanucleus.org/) (?)
- [Ebean ORM](https://ebean.io/) (?)
- [EclipseLink](https://www.eclipse.org/eclipselink/) (?)
- [Jakarta EE](https://jakarta.ee/) (?)
- [Apache JDO](http://db.apache.org/jdo/index.html) (?)
- [jOOQ](https://www.jooq.org/) (?)
- [Oracle TopLink](https://www.oracle.com/middleware/technologies/top-link.html) (?)
- [relademo](https://github.com/goldmansachs/reladomo) (?)
- [speedment stream](https://github.com/goldmansachs/reladomo) (?)
- [~~jdbi~~](http://jdbi.org/#_third_party_integration) - no mysql support

### Go
- [GORM](https://gorm.io/) (✓)
- [xorm](https://gitea.com/xorm/xorm) - note - github is not updated as they moved to gitea (✓)
- [bun](https://bun.uptrace.dev/) (✓)
- [sqlboiler](https://github.com/volatiletech/sqlboiler) (✓)
- [xo](https://github.com/xo/xo) (✓)
- [upper/db](https://github.com/upper/db) (✓)
- [reform](https://github.com/go-reform/reform) (✓)
- [gobuffalo/pop](https://github.com/gobuffalo/pop) (✓)
- [go-sqlbuilder](https://github.com/huandu/go-sqlbuilder) (✓)
- [beego](https://github.com/beego/beego) (✓)
- [grimoire](https://github.com/Fs02/grimoire) (✓)
- [marlow](https://github.com/marlow/marlow) (✓)
- [ent](https://github.com/ent/ent) (✓)
- [rel](https://github.com/go-rel/rel/) (✓)
- [prisma-client-go](https://github.com/prisma/prisma-client-go) (?)
- [sqlc](https://github.com/kyleconroy/sqlc) (?)
- [~~gosql~~](https://github.com/rushteam/gosql) - only supports mysql
- [~~gorp~~](https://github.com/go-gorp/gorp) - last release 2019-11-01
- [~~go-pg~~](https://github.com/go-pg/pg) - PostgreSQL specific, rewrite is called `bun`
- [~~gormt~~](https://github.com/xxjwxc/gormt) - only supports mysql
- [~~lore~~](https://github.com/abrahambotros/lore) - last updated 2017-05-07

### JavaScript/Node.js
- [prisma](https://www.prisma.io/) (✓)
- [sequelize](https://github.com/sequelize/sequelize/) (✓)
- [TypeORM](https://github.com/typeorm/typeorm) (✓)
- [bookshelf.js](https://github.com/bookshelf/bookshelf) (✓)
- [objection.js](https://github.com/Vincit/objection.js) (✓)
- [waterline](https://github.com/balderdashy/waterline) - part of sails (✓)
- [MikroORM](https://github.com/mikro-orm/mikro-orm) (✓)
- [~~mongoosejs~~](https://mongoosejs.com/) - only MongoDB
- [~~massive.js~~](https://gitlab.com/dmfay/massive-js) - only postgresql, data mapper
- [~~openrecord~~](https://github.com/PhilWaldmann/openrecord) - archived by author, no notes

### Rust
- [rbatis](https://github.com/rbatis/rbatis) (✓)
- [sqlx](https://github.com/launchbadge/sqlx) (?) - not quite sure if its just SQL builder or ORM
- [diesel](https://github.com/diesel-rs/diesel) (✓)
- [~~rustorm~~](https://github.com/ivanceras/rustorm) - no documented mysql support

### Ruby
- [RubyOnRails ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html) (✓)
- [sequel](https://github.com/jeremyevans/sequel) (✓)
- [hanami::model](https://github.com/hanami/model) (✓)
- [Ruby Object Mapper](https://rom-rb.org/) (?)
- [~~DataMapper~~](https://github.com/datamapper/dm-core) - not in active development since 2016-05-25
- [~~ripple~~](https://github.com/riak-ripple/ripple) - not in active development since 2016-10-06

### Elixir
- [Ecto](https://hexdocs.pm/ecto/Ecto.html) (✓)
- [~~atlas~~](https://github.com/chrismccord/atlas) - not in active development since 2014-06-05

### C++
- [sqlpp11](https://github.com/rbock/sqlpp11) (✓)
- [QxORM](https://github.com/QxOrm/QxOrm) (✓)
- [~~odb~~](https://www.codesynthesis.com/products/odb/) - not in active development since 2019-03-19
- [~~GigaBASE~~](https://sourceforge.net/projects/gigabase/) - not in active development since 2017-04-11 
- [~~bun~~](https://github.com/BrainlessLabs/bun) - not in active development since 2019-10-24
- [~~libpqxx~~](http://pqxx.org/development/libpqxx/) - only postgreSQL
- [~~sqlite_orm~~](https://github.com/fnc12/sqlite_orm) - only SQLite

### PHP
- [doctrine](https://www.doctrine-project.org/) (✓)
- [laravel eloquent](https://laravel.com/) (✓)
- [Yii2 framework ActiveRecord](https://www.yiiframework.com/) (✓)
- [Atlas.Orm](https://github.com/atlasphp/Atlas.Orm) (✓)
- [CakePHP ORM](https://github.com/cakephp/orm) (✓)
- [RedBeanPHP](https://redbeanphp.com/index.php) (✓)
- [Cycle ORM](https://github.com/cycle/orm) (✓)
- [Propel](https://github.com/propelorm/Propel2) (✓)
- [f3-cortex](https://github.com/ikkez/f3-cortex) (✓)
- [~~nextras ORM~~](https://github.com/nextras/orm) - no [sqlite support](https://github.com/nextras/orm/issues/358)
- [~~analogueorm~~](https://github.com/analogueorm/analogue) - not in active development since 2020-02-11 (yeaah, 5 days difference nah)
- [~~paris~~](https://github.com/j4mie/paris) - not in active development since 2017-03-21
- [~~spot2~~](https://github.com/spotorm/spot2) - not in active development since 2018-08-01
- [~~Pomm~~](https://github.com/chanmix51/Pomm) - supports only postgres, not in active development since 2014-11-04
- [~~VoodOrm~~](https://github.com/mardix/VoodOrm) - not in active development since 2014-05-05

### Scala
- [Slick](https://scala-slick.org/) - more like FRM (Functional relational mapping?) (?)
- [~~circumflex ORM~~](https://github.com/inca/circumflex) - not in active development since 2012-10-14 
- [~~lift ORM~~](https://liftweb.net) - not in active development since 2018-07-21

### Dart
- [~~liquidart ORM~~](https://aldrinsartfactory.github.io/liquidart/) - no support for mysql / sqlite
- [~~jaguar_orm~~](https://github.com/Jaguar-dart/jaguar_orm) - no support for mysql / sqlite, not in active development since 2019-06-29
- [~~Conduit ORM~~](https://gitbook.theconduit.dev/) - no support for SQLite
- [~~Aqueduct ORM~~](https://aqueduct.io) - only supports postgreSQL
- [~~Dart ORM~~](https://github.com/ustims/DartORM) - not in active development since 2018-06-03
- Unable to find viable framework.

### Swift
- [Swift Kuery ORM](https://github.com/Kitura/Swift-Kuery-ORM) (✓)
- [fluent](https://github.com/vapor/fluent) (✓)
- [~~Perfect CRUD~~](https://github.com/PerfectlySoft/Perfect-CRUD) - not in active development since 2020-01-21

### Kotlin
- [ktorm](https://github.com/kotlin-orm/ktorm) (✓)
- [Exposed](https://github.com/JetBrains/Exposed) (✓)
- Anything in Java like ebean (?) 

### C
- This was really just an attempt, at [best found this](http://ales.jikos.cz/smorm/) 

### Lua
- [~~Orbit ORM~~](http://keplerproject.github.io/orbit/reference.html) - supports only sqlite / mysql

### Perl
- [DBIx-Class](https://metacpan.org/dist/DBIx-Class) (✓)
- [~~Rose-DB~~](https://metacpan.org/release/JSIRACUSA/Rose-DB-0.758/view/lib/Rose/DB.pm) - not in active development since 2010-01-26
- [~~Fey ORM~~](https://metacpan.org/dist/Fey-ORM) - not in active development since 2015-07-12

### Obj-C
- [~~Shark ORM~~](https://github.com/sharksync/sharkorm) - not in active development since 2019-12-21

### Julia
- [SeachLight](https://github.com/GenieFramework/SearchLight.jl) (✓)

### Pascal
- [mORMot](https://github.com/synopse/mORMot) (✓)

### Groovy
- [grails gorm](https://gorm.grails.org/) (✓)

### Common Lisp
- [Mito](https://github.com/fukamachi/mito) (✓)
- [~~clsql-orm~~](https://github.com/AccelerationNet/CLSQL-ORM) - not in active development since 2016-01-04

### Ada
- [Ada Ado](https://github.com/stcarrez/ada-ado) (✓)