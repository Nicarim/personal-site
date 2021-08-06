---
title: "Languages and frameworks. Sources and choice"
date: 2021-08-06T13:59:34+02:00
draft: true
---

## Sources
List of places I consulted for finding informations

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
- 
  
These languages were considered, but didn't have viable candidates (no popular ORM framework matching criterias)


## Considered frameworks

According to chosen languages, I've made a research on available ORM frameworks and have written down these that I'll cover

<!-- TODO: Add urls to respective frameworks, add sources for disqualifications -->

### Python
- Django ORM (✓)
- SQLAlchemy (✓)
- PeeWee (✓)
- PonyORM (✓)
- SQLObject (✓)
- MasoniteORM (✓)
- ~~records~~ - Too old
- ~~canoncial/Storm~~ - Disqualified due to lack of MySQL support
- ~~Piccolo~~ - lack of MySQL support, limited SQLite support

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
- ~~Chain~~ - no built in MySQL support
- ~~ADO.NET~~ - TIL: it is not ORM :)

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
- [~~jdbi~~](http://jdbi.org/#_third_party_integration) - no mysql support

###