# Hibernate Upgrade Guide

Upgrade to Hibernate Reactive 4:

* Use Mutiny (`Uni`, `Multi`) APIs.
* Replace `Stage.Session` patterns.
* Fetch associations explicitly, no lazy support.
* Transactions via `.withSession()` / `.withTransaction()`.
* Use schema generation from Hibernate, not Flyway/Liquibase unless modularized.